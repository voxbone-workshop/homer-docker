#!/bin/bash
# HOMER 5 Docker (http://sipcapture.org)
# ----------------------------------------------------
# -- Run script for Homer's Web application
# ----------------------------------------------------
# Reads from environment variables to set:
# DB_PASS             MySQL password (homer_password)
# DB_USER             MySQL user (homer_user)
# DB_HOST             MySQL host (127.0.0.1 [docker0 bridge])
# KAMAILIO_HEP_PORT   Kamailio HEP Socket port (9060)
# ----------------------------------------------------

# Wait for MySQL

while [[ ! -f "/homer-semaphore/.bootstrapped" ]]; do
  echo "Homer web app, waiting for MySQL"
  sleep 2;
done

echo "Homer web app container detected MySQL is running & bootstrapped"


# HOMER API CONFIG
PATH_HOMER_CONFIG=/var/www/html/api/configuration.php
chmod 775 $PATH_HOMER_CONFIG

# Replace values in template
perl -p -i -e "s/\{\{ DB_PASS \}\}/$DB_PASS/" $PATH_HOMER_CONFIG
perl -p -i -e "s/\{\{ DB_HOST \}\}/$DB_HOST/" $PATH_HOMER_CONFIG
perl -p -i -e "s/\{\{ DB_USER \}\}/$DB_USER/" $PATH_HOMER_CONFIG

# Set Permissions for webapp
mkdir /var/www/html/api/tmp
chmod -R 0777 /var/www/html/api/tmp/
chmod -R 0775 /var/www/html/store/dashboard*

# Reconfigure rotation

export PATH_ROTATION_SCRIPT=/opt/homer_rotate
chmod 775 $PATH_ROTATION_SCRIPT
chmod +x $PATH_ROTATION_SCRIPT
perl -p -i -e "s/homer_user/$DB_USER/" $PATH_ROTATION_SCRIPT
perl -p -i -e "s/homer_password/$DB_PASS/" $PATH_ROTATION_SCRIPT

export PATH_NEW_TABLE_SCRIPT=/opt/homer_mysql_new_table.pl
perl -p -i -e "s/homer_user/$DB_USER/" $PATH_NEW_TABLE_SCRIPT
perl -p -i -e "s/homer_password/$DB_PASS/" $PATH_NEW_TABLE_SCRIPT
perl -p -i -e "s/mysql_host = \"localhost\"/mysql_host = \"$DB_HOST\"/" $PATH_NEW_TABLE_SCRIPT

# Init rotation
/opt/homer_rotate > /dev/null 2>&1

# Start the cron service in the background for rotation
cron -f &

#enable apache mod_php and mod_rewrite
a2enmod php5
a2enmod rewrite 

# Start Apache
apachectl -DFOREGROUND
# apachectl start