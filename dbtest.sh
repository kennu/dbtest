#!/bin/sh
mysql=`ab -n 1000 -c 10 'http://127.0.0.1:5000/mysql/seq/local/100'|grep 'Time per request'|head -n 1|awk '{print $4}'`
postgres=`ab -n 1000 -c 10 'http://127.0.0.1:5000/postgres/seq/local/100'|grep 'Time per request'|head -n 1|awk '{print $4}'`
mongodb=`ab -n 1000 -c 10 'http://127.0.0.1:5000/mongodb/seq/local/100'|grep 'Time per request'|head -n 1|awk '{print $4}'`
echo 'Final results (request time in ms):'
echo "MySQL: $mysql"
echo "Postgres: $postgres"
echo "MongoDB: $mongodb"
