dbset db mysql
dbset bm tpcc
diset connection mysql_host 127.0.0.1
diset connection mysql_port 3306
diset tpcc mysql_count_ware 1000
diset tpcc mysql_partition true
diset tpcc mysql_dbase test1000
diset tpcc mysql_pass 12345678
#diset tpcc mysql_num_vu 128
diset tpcc mysql_storage_engine innodb
print dict
diset tpcc mysql_driver timed
#diset tpcc mysql_rampup 1
#diset tpcc mysql_duration 1
vuset logtotemp 1
loadscript
vuset vu 96
vurun
