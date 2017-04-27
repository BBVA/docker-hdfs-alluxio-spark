FROM ubuntu:16.04

RUN apt-get update && apt-get --no-install-recommends install -y default-jre libnss-wrapper wget && apt-get clean
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

ENV HADOOP_URL=http://apache.rediris.es/hadoop/common/hadoop-2.7.3/hadoop-2.7.3.tar.gz

WORKDIR /tmp

RUN wget --quiet ${HADOOP_URL} 

RUN mkdir -p /opt/hadoop && tar zxf /tmp/hadoop-2.7.3.tar.gz --strip-components=1 -C /opt/hadoop/
RUN mkdir -p /opt/hadoop/logs

RUN chown -R root.root /opt/hadoop
RUN chmod -R g+rw /opt/hadoop

EXPOSE 8020 8022 50070 50010 50075 50020

WORKDIR /

ADD boot.sh /

ADD core-site.xml /opt/hadoop/etc/hadoop/core-site.xml
ADD hdfs-site.xml /opt/hadoop/etc/hadoop/hdfs-site.xml

ENTRYPOINT ["/boot.sh"]

