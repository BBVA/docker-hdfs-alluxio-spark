# hadoop configuration
export HADOOP_CONF_VARS=(
	"CORE_SITE_CONF"
	"HDFS_SITE_CONF"
)

export HADOOP_CONF_FILES=(
	"/opt/hadoop/etc/hadoop/core-site.xml"
	"/opt/hadoop/etc/hadoop/hdfs-site.xml"
)

# For httpfs config
# https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/Superusers.html
# insecure defaults
read -r -d '' CORE_SITE_CONF <<EOF
<configuration>
	<property><name>fs.defaultFS</name><value>hdfs://hdfs-namenode:8020</value></property>
	<property><name>io.file.buffer.size</name><value>131072</value></property>
	<property><name>hadoop.proxyuser.openshift.hosts</name><value>172.16.0.0/12,10.0.0.0/8</value></property>
	<property><name>hadoop.proxyuser.openshift.groups</name><value>openshift,root</value></property>
	<property><name>hadoop.proxyuser.root.hosts</name><value>172.16.0.0/12,10.0.0.0/8</value></property>
	<property><name>hadoop.proxyuser.root.groups</name><value>root</value></property>
	<property><name></name><value></value></property>
</configuration>
EOF
export CORE_SITE_CONF

# https://log.rowanto.com/why-datanode-is-denied-communication-with-namenode/
# disable remote host name check, enable in production with a correct service
# discovery reverse dns set up
read -r -d '' HDFS_SITE_CONF <<EOF
<configuration>
	<property><name>dfs.namenode.name.dir</name><value>file:///data/hdfs-namenode/</value></property>
	<property><name>dfs.blocksize</name><value>33554432</value></property>
	<property><name>dfs.namenode.handler.count</name><value>100</value></property>
	<property><name>dfs.namenode.servicerpc-address</name><value>hdfs://hdfs-namenode:8022</value></property>
	<property><name>dfs.namenode.datanode.registration.ip-hostname-check</name><value>false</value></property>
	<property><name>dfs.datanode.data.dir</name><value>/data/hdfs-namenode</value></property>
	<property><name>dfs.client.use.datanode.hostname</name><value>true</value></property>
	<property><name>dfs.datanode.use.datanode.hostname</name><value>true</value></property>
</configuration>
EOF
export HDFS_SITE_CONF

# httpfs environment config
export HTTPFS_HTTP_PORT=14000
export HTTPFS_ADMIN_PORT=14001
