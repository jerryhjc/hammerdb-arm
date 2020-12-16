dbset db mysql
dbset bm TPC-H
#diset connection mysql_host localhost
diset connection mysql_host 127.0.0.1
diset connection mysql_port 3306
#diset tpch mysql_tpch_storage_engine innodb
diset tpch mysql_scale_fact 30
diset tpch mysql_tpch_dbase tpch32
diset tpch mysql_tpch_pass 12345678
diset tpch mysql_num_tpch_threads 28
print dict
buildschema
