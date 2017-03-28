FROM ubuntu:16.04

RUN apt-get update && apt-get --no-install-recommends install -y default-jre libnss-wrapper wget && apt-get clean

ENV SPARK_URL=http://d3kbcqa49mib13.cloudfront.net/spark-2.1.0-bin-hadoop2.7.tgz
ENV ALLUXIO_SPARK_URL=http://downloads.alluxio.org/downloads/files/1.4.0/alluxio-1.4.0-spark-client-jar-with-dependencies.jar

WORKDIR /tmp

RUN wget --quiet ${SPARK_URL}

RUN mkdir -p /opt/spark && tar zxf /tmp/spark-2.1.0-bin-hadoop2.7.tgz  --strip-components=1 -C /opt/spark/

WORKDIR /opt/spark/jars
RUN wget --quiet ${ALLUXIO_SPARK_URL}

RUN chown -R g+rw /opt/spark

EXPOSE 7077 6066 8080 35000 8081

WORKDIR /
ADD boot.sh /

ENTRYPOINT ["/boot.sh"]
