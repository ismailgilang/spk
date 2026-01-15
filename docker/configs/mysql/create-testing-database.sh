#!/usr/bin/env bash

mysql --user=root --password="$DB_ROOT_PASSWORD" <<-EOSQL
    CREATE DATABASE IF NOT EXISTS testing;
    GRANT ALL PRIVILEGES ON \`testing%\`.* TO '$DB_USERNAME'@'%';
EOSQL
