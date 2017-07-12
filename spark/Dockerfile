FROM ubuntu:16.04

ARG SPARK_PKG="spark-2.1.1-bin-hadoop2.7.tgz"
ARG ALLUXIO_VERSION="1.5.0"
ARG ALLUXIO_PKG="alluxio-1.5.0-hadoop-2.8-bin.tar.gz"

RUN apt-get update && apt-get --no-install-recommends install -y default-jre libnss-wrapper wget libsnappy1v5 libsnappy-dev libsnappy-java libsnappy-jni libssl1.0.0 libssl-dev && apt-get clean
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

ENV SPARK_URL=https://d3kbcqa49mib13.cloudfront.net/$SPARK_PKG
ENV ALLUXIO_URL=http://downloads.alluxio.org/downloads/files/$ALLUXIO_VERSION/$ALLUXIO_PKG

WORKDIR /tmp

RUN wget --quiet ${SPARK_URL}
RUN wget --quiet ${ALLUXIO_URL}

RUN mkdir -p /opt/spark && tar zxf /tmp/$SPARK_PKG  --strip-components=1 -C /opt/spark/

RUN mkdir -p /tmp/alluxio && tar zxf /tmp/$ALLUXIO_PKG --strip-components=1 -C /tmp/alluxio/
RUN cp /tmp/alluxio/core/client/runtime/target/alluxio-core-client-runtime-$ALLUXIO_VERSION-jar-with-dependencies.jar /opt/spark/jars/

RUN chown -R root.root /opt/spark
RUN chmod -R g+rw /opt/spark

EXPOSE 7077 6066 8080 35000 8081

WORKDIR /
ADD boot.sh /

ADD core-site.xml /opt/spark/conf/core-site.xml
ADD hdfs-site.xml /opt/spark/conf/hdfs-site.xml
ADD alluxio-site.properties /opt/spark/conf/alluxio-site.properties
ADD spark-defaults.conf /opt/spark/conf/spark-defaults.conf
ADD log4j.properties /opt/spark/conf/log4j.properties

ENTRYPOINT ["/boot.sh"]
