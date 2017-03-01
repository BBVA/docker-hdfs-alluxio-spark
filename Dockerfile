FROM java

ENV SPARK_URL=http://d3kbcqa49mib13.cloudfront.net/spark-2.0.0-bin-hadoop2.7.tgz

ENV ALLUXIO_URL=http://alluxio.org/downloads/files/1.4.0/alluxio-1.4.0-bin.tar.gz
ENV ALLUXIO_SPARK_URL=http://downloads.alluxio.org/downloads/files/1.4.0/alluxio-1.4.0-spark-client-jar-with-dependencies.jar
ENV ALLUXIO_HDFS_URL=http://downloads.alluxio.org/downloads/files/1.4.0/alluxio-1.4.0-hadoop2.7-bin.tar.gz
ENV HADOOP_URL=http://apache.rediris.es/hadoop/common/hadoop-2.7.3/hadoop-2.7.3.tar.gz

WORKDIR /tmp

RUN wget --quiet ${SPARK_URL}
RUN wget --quiet ${ALLUXIO_URL}
RUN wget --quiet ${HADOOP_URL}
RUN wget --quiet ${ALLUXIO_HDFS_URL}

RUN mkdir -p /opt/spark && tar zxf /tmp/spark-2.0.0-bin-hadoop2.7.tgz  --strip-components=1 -C /opt/spark/
RUN mkdir -p /opt/alluxio && tar zxf /tmp/alluxio-1.4.0-bin.tar.gz --strip-components=1 -C /opt/alluxio/
RUN mkdir -p /opt/alluxio_hdfs && tar zxf /tmp/alluxio-1.4.0-hadoop2.7-bin.tar.gz --strip-components=1 -C /opt/alluxio_hdfs/
RUN mkdir -p /opt/hadoop && tar zxf /tmp/hadoop-2.7.3.tar.gz --strip-components=1 -C /opt/hadoop/

WORKDIR /opt/spark
RUN wget --quiet ${ALLUXIO_SPARK_URL}

WORKDIR /
ADD boot.sh /

CMD ["/boot.sh"]


