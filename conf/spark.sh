# spark configuration

export spark_master="spark-master"


export SPARK_CONF_VARS=(
	"CORE_SITE_CONF"
	"HDFS_SITE_CONF"
	"SPARK_CONF"
)

export SPARK_CONF_FILES=(
	"/opt/spark/conf/core-site.xml"
	"/opt/spark/conf/hdfs-site.xml"
	"/opt/spark/conf/spark-defaults.conf"
)

export SPARK_MASTER_WEBUI_PORT=${SPARK_MASTER_WEBUI_PORT:-8080}
export SPARK_WORKER_MEMORY=${SPARK_WORKER_MEMORY:-1g}
export SPARK_WORKER_PORT=${SPARK_WORKER_PORT:-35000}
export SPARK_WORKER_WEBUI_PORT=${SPARK_WORKER_WEBUI_PORT:-8081}
export SPARK_DAEMON_MEMORY=${SPARK_DAEMON_MEMORY:-1g}

read -r -d '' SPARK_CONF <<EOF
spark.master                     spark://spark-master:7077
spark.eventLog.enabled           true
spark.eventLog.dir               hdfs://hdfs-namenode:8020/spark/eventlogs
spark.serializer                 org.apache.spark.serializer.KryoSerializer
spark.driver.memory              5g
spark.history.fs.logDirectory    hdfs://hdfs-namenode:8020/spark/eventlogs
spark.master.webui-port          8080
spark.worker.memory              1g
spark.worker.port                35000
spark.worker.webui.port          8081
spark.daemon.memory              1g
EOF
export SPARK_CONF
export HADOOP_CONF_DIR=/opt/spark/conf
