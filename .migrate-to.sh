#!/bin/bash
MYSQL_USER="brandqt2_drup001"
MYSQL_DATABASE="brandqt2_drup001"
DUMP_PATH="../private"

tar -xf $DUMP_PATH/migrate.tar.bz2
rm $DUMP_PATH/migrate.tar.bz2

echo "MYSQL Login"
mysql -u $MYSQL_USER -p $MYSQL_DATABASE < database-stripped.sql
rm database-stripped.sql
