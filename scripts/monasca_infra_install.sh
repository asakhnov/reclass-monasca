#!/bin/bash -x
exec > >(tee -i /tmp/"$(basename "$0" .sh)"_"$(date '+%Y-%m-%d_%H-%M-%S')".log) 2>&1

# Install the Monasca backends

### Keepalived
salt 'mnk*' state.sls keepalived -b 1
salt 'mnk*' cmd.run "ip a | grep 172.16.10.2"

### HAproxy
salt 'mnk*' state.sls haproxy
salt 'mnk*' service.status haproxy
salt 'mnk*' service.restart rsyslog

### InfluxDB
# NOTE: this dirty hack needed in order to install InfluxDB version 0.10.0.
# There are two differences comparing to 1.2.0:
#   - Version 0.10.0 doesn't support POST request and handle only GET
#   - [[collectd]] and [[opentsdb]] sections declaration need to be changed to
#     [collectd] and [opentsdb].
# This either needs to be places in salt formula or eventually fix Monasca
# to support newer InfluxDB.
formulas_path=/srv/salt/env/prd
tmp_influxdb_conf=$(mktemp /tmp/monasca-infra.XXXXXX)
tmp_influxdb_server=$(mktemp /tmp/monasca-infra.XXXXXX)
cp $formulas_path/influxdb/files/influxdb.conf $tmp_influxdb_conf
cp $formulas_path/influxdb/server.sls $tmp_influxdb_server
sed -i '/^\[\[collectd/s/\]\]/\]/' $formulas_path/influxdb/files/influxdb.conf
sed -i '/^\[\[collectd/s/\[\[/\[/' $formulas_path/influxdb/files/influxdb.conf
sed -i '/^\[\[opentsdb/s/\]\]/\]/' $formulas_path/influxdb/files/influxdb.conf
sed -i '/^\[\[opentsdb/s/\[\[/\[/' $formulas_path/influxdb/files/influxdb.conf
sed -i 's/POST/GET/g' $formulas_path/influxdb/server.sls
salt 'mnk*' state.sls influxdb -b 1
cp $tmp_influxdb_conf $formulas_path/influxdb/files/influxdb.conf
cp $tmp_influxdb_server $formulas_path/influxdb/server.sls
rm $tmp_influxdb_server $tmp_influxdb_conf

### Zookeeper
salt 'mnk*' state.sls zookeeper -b 1

### Kafka
salt 'mnk*' state.sls kafka -b 1

### Storm
salt 'mnk*' state.sls storm -b 1

### Monasca
salt 'mnk*' state.sls monasca.api -b 1
salt 'mnk*' state.sls monasca.persister -b 1
