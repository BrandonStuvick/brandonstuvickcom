#!/bin/bash
MYSQL_USER="root"
MYSQL_DATABASE="drupal"
DUMP_PATH="../private"

rm -rf $DUMP_PATH/*

# Back up the database
echo "MYSQL Login"
mysqldump -u $MYSQL_USER -p $MYSQL_DATABASE > $DUMP_PATH/database.sql

# Remove any cache from the database
sed -E -e "/^INSERT INTO \`(cache|watchdog|sessions)/d" < $DUMP_PATH/database.sql > $DUMP_PATH/database-stripped.sql
rm $DUMP_PATH/database.sql

# Copy over files not tracked with git 
mkdir $DUMP_PATH/sites
mkdir $DUMP_PATH/sites/default
cp -r sites/default/files $DUMP_PATH/sites/default/
cp sites/default/settings.php $DUMP_PATH/sites/default/
mkdir $DUMP_PATH/core
cp -r vendor $DUMP_PATH/
cp -r core/assets $DUMP_PATH/core/

# Strip installation specific database settings out
sed -i -e "s/^ *'database'.*/  'database' => '',/"  -e "s/^ *'username'.*/  'username' => '',/"  -e "s/^ *'password'.*/  'password' => '',/" $DUMP_PATH/sites/default/settings.php

# Comment out any debug settings
awk '
/.*if.*\/settings\.local\.php.*/ {
  print "#" $0;
  getline;
  print "#" $0;
  getline;
  print "#" $0;
  getline;
}
{
  print;
}' $DUMP_PATH/sites/default/settings.php > $DUMP_PATH/sites/default/settings.new.php
rm $DUMP_PATH/sites/default/settings.php
mv $DUMP_PATH/sites/default/settings.new.php $DUMP_PATH/sites/default/settings.php

# Compress everything
tar -cC $DUMP_PATH database-stripped.sql sites vendor | bzip2 -z9 > $DUMP_PATH/migrate.tar.bz2
rm -rf $DUMP_PATH/vendor
rm -rf $DUMP_PATH/core
rm -rf $DUMP_PATH/sites
rm $DUMP_PATH/database-stripped.sql
