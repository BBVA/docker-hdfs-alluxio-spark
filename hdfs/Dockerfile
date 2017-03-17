FROM openjdk:8-jre

ENV HADOOP_URL=http://apache.rediris.es/hadoop/common/hadoop-2.7.3/hadoop-2.7.3.tar.gz

WORKDIR /tmp

RUN wget --quiet ${HADOOP_URL}

RUN mkdir -p /opt/hadoop && tar zxf /tmp/hadoop-2.7.3.tar.gz --strip-components=1 -C /opt/hadoop/
RUN mkdir -p /opt/hadoop/logs 
RUN chmod -R g+rw /opt/hadoop

WORKDIR /
ADD boot.sh /
ADD configure.py /

ENTRYPOINT ["/boot.sh"]
