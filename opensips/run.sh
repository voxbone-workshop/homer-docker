#!/bin/bash
# ----------------------------------------------------
# HOMER 5 Docker (http://sipcapture.org)
# ----------------------------------------------------
# -- Run script for Homer's OpenSIPS
# ----------------------------------------------------
# Reads from environment variables to set:
# DB_PASS             MySQL password (homer_password)
# DB_USER             MySQL user (homer_user)
# DB_HOST             MySQL host (127.0.0.1 [docker0 bridge])
# OPENSIPS_HEP_PORT   OpenSIPS HEP Socket port (9060)
# ----------------------------------------------------

# Wait for MySQL

while [[ ! -f "/homer-semaphore/.bootstrapped" ]]; do
  echo "OpenSIPS, waiting for MySQL"
  sleep 2;
done

echo "OpenSIPS container detected MySQL is running & bootstrapped"

# OpenSIPS config
export PATH_OPENSIPS_CFG=/usr/local/opensips/etc/opensips/opensips.cfg

# Replace values in template
# perl -p -i -e "s/9060/$OPENSIPS_HEP_PORT/" $PATH_OPENSIPS_CFG
perl -p -i -e "s/homer_password/$DB_PASS/" $PATH_OPENSIPS_CFG
perl -p -i -e "s/homer_user/$DB_USER/" $PATH_OPENSIPS_CFG

# Make an alias, kinda.
opensips=$(which opensips)

# Test the syntax.
$opensips -f $PATH_OPENSIPS_CFG -c

# It's Homer time!
$opensips -f $PATH_OPENSIPS_CFG -DD -E -e
