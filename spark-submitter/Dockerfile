FROM openjdk:8-jre

LABEL version="spark_2.1.0_hadoop_2.7"

ENV SPARK_DIST_URL=http://d3kbcqa49mib13.cloudfront.net/spark-2.1.0-bin-hadoop2.7.tgz

# Install requirements
RUN apt-get update \
  && apt-get install -y python

# Install Spark distribution
WORKDIR /tmp
RUN wget --quiet ${SPARK_DIST_URL}
RUN mkdir -p /opt/spark && tar zxf /tmp/spark-2.1.0-bin-hadoop2.7.tgz --strip-components=1 -C /opt/spark/

WORKDIR /
ADD boot.sh /
RUN chmod a+x /boot.sh

EXPOSE 4040

ENTRYPOINT ["/boot.sh"]
