FROM ubuntu:16.04

RUN apt-get update && apt-get --no-install-recommends install -y default-jre libnss-wrapper wget libsnappy1v5 libsnappy-dev libsnappy-java libsnappy-jni libssl1.0.0 libssl-dev && apt-get clean
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

ENV ZEPPELIN="http://www-eu.apache.org/dist/zeppelin/zeppelin-0.7.1/zeppelin-0.7.1-bin-all.tgz"
WORKDIR /tmp

RUN mkdir -p /opt/zeppelin && wget -qO- ${ZEPPELIN} | tar xzf - --strip-components=1 -C /opt/zeppelin

RUN echo openshift-user:x:1000050000:0:root:::/bin/false >> /etc/passwd
RUN chown -R root.root /opt/zeppelin
RUN chmod g+rwx /opt/zeppelin
RUN chmod -R g+rw /opt/zeppelin

WORKDIR /
ADD boot.sh /boot.sh

ADD core-site.xml /opt/zeppelin/conf/core-site.xml
ADD hdfs-site.xml /opt/zeppelin/conf/hdfs-site.xml
ADD interpreter.json /opt/zeppelin/conf/interpreter.json
ADD alluxio-site.properties /opt/zeppelin/conf/alluxio-site.properties

EXPOSE 4040 8080 8081

ENTRYPOINT ["/boot.sh"]
