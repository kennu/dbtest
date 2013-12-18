#!/bin/sh
echo "CREATE USER dbtest WITH PASSWORD 'dbtest'" | psql template1
echo "CREATE DATABASE dbtest" | psql template1
echo "GRANT ALL PRIVILEGES ON DATABASE dbtest TO dbtest" | psql template1
