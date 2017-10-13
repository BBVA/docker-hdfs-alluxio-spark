# Copyright 2017 Banco Bilbao Vizcaya Argentaria S.A.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ubuntu:16.04

RUN apt-get update && apt-get --no-install-recommends install -y default-jre libnss-wrapper wget libsnappy1v5 libsnappy-dev libsnappy-java libsnappy-jni libssl1.0.0 libssl-dev && apt-get clean
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

ENV ZEPPELIN=http://apache.uvigo.es/zeppelin/zeppelin-0.7.2/zeppelin-0.7.2-bin-netinst.tgz
ENV SPARK_DIST_URL=https://d3kbcqa49mib13.cloudfront.net/spark-2.1.1-bin-hadoop2.7.tgz

WORKDIR /tmp

RUN mkdir -p /opt/zeppelin && wget -qO- ${ZEPPELIN} | tar xzf - --strip-components=1 -C /opt/zeppelin
RUN mkdir -p /opt/spark && wget -qO- ${SPARK_DIST_URL} | tar xzf - --strip-components=1 -C /opt/spark

RUN /opt/zeppelin/bin/install-interpreter.sh --name python,md

WORKDIR /
ADD boot.sh /boot.sh
RUN chmod a+x /boot.sh
RUN chown -R root.root /opt/zeppelin
RUN chmod -R g+rw /opt/zeppelin
RUN chown -R root.root /opt/spark
RUN chmod -R g+rw /opt/spark

ADD core-site.xml /opt/spark/conf/core-site.xml
ADD hdfs-site.xml /opt/spark/conf/hdfs-site.xml
ADD alluxio-site.properties /opt/spark/conf/alluxio-site.properties
ADD spark-defaults.conf /opt/spark/conf/spark-defaults.conf
ADD log4j.properties /opt/spark/conf/log4j.properties

ADD interpreter.json /opt/zeppelin/conf/interpreter.json
RUN chmod 666 /opt/zeppelin/conf/interpreter.json

EXPOSE 4040 8080 8081 51000 51100 51200 51400 51500

ENTRYPOINT ["/boot.sh"]
