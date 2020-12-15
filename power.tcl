dbset db mysql
dbset bm TPC-H
#diset connection mysql_host localhost
diset connection mysql_host 127.0.0.1
diset connection mysql_port 3306
diset tpch mysql_scale_fact 30
diset tpch mysql_tpch_dbase tpch30
diset tpch mysql_tpch_pass 12345678
#diset tpch mysql_num_tpch_threads 5
diset tpch mysql_refresh_on 1
diset tpch mysql_trickle_refresh 0
diset tpch mysql_verbose false
print dict
vuset logtotemp 1
loadscript
vuset vu 1
vurun
