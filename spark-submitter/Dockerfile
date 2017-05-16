FROM ubuntu:16.04

RUN apt-get update && apt-get --no-install-recommends install -y default-jre libnss-wrapper wget libsnappy1v5 libsnappy-java libsnappy-jni openssl && apt-get clean
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

LABEL version="spark_2.1.0_hadoop_2.7"

ENV SPARK_DIST_URL=http://d3kbcqa49mib13.cloudfront.net/spark-2.1.0-bin-hadoop2.7.tgz

# Install Spark distribution
WORKDIR /tmp
RUN wget --quiet ${SPARK_DIST_URL}
RUN mkdir -p /opt/spark && tar zxf /tmp/spark-2.1.0-bin-hadoop2.7.tgz --strip-components=1 -C /opt/spark/

WORKDIR /
ADD boot.sh /
RUN chmod a+x /boot.sh
RUN chown -R root.root /opt/spark
RUN chmod -R g+rw /opt/spark

ADD core-site.xml /opt/spark/conf/core-site.xml
ADD hdfs-site.xml /opt/spark/conf/hdfs-site.xml
ADD alluxio-site.properties /opt/spark/conf/alluxio-site.properties
ADD spark-defaults.conf /opt/spark/conf/spark-defaults.conf
ADD log4j.properties /opt/spark/conf/log4j.properties

EXPOSE 4040

ENTRYPOINT ["/boot.sh"]
