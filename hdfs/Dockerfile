FROM openjdk:8-jre

ENV HADOOP_URL=http://apache.rediris.es/hadoop/common/hadoop-2.7.3/hadoop-2.7.3.tar.gz

WORKDIR /tmp
RUN apt-get update && apt-get install libnss-wrapper && apt-get clean

RUN wget --quiet ${HADOOP_URL}

RUN mkdir -p /opt/hadoop && tar zxf /tmp/hadoop-2.7.3.tar.gz --strip-components=1 -C /opt/hadoop/
RUN mkdir -p /opt/hadoop/logs

RUN chown -R root.root /opt/hadoop
RUN chmod g+rw /opt/hadoop

EXPOSE 8020 8022 50070 50010 50075 50020

WORKDIR /
ADD boot.sh /

ENTRYPOINT ["/boot.sh"]
