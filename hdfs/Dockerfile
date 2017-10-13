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

ENV HADOOP_URL=http://apache.rediris.es/hadoop/common/hadoop-2.8.0/hadoop-2.8.0.tar.gz

WORKDIR /tmp

RUN wget --quiet ${HADOOP_URL}

RUN mkdir -p /opt/hadoop && tar zxf /tmp/hadoop-2.8.0.tar.gz --strip-components=1 -C /opt/hadoop/
RUN mkdir -p /opt/hadoop/logs

RUN chown -R root.root /opt/hadoop
RUN chmod -R g+rw /opt/hadoop

EXPOSE 8020 8022 50070 50010 50075 50020

WORKDIR /

ADD boot.sh /

ADD core-site.xml /opt/hadoop/etc/hadoop/core-site.xml
ADD hdfs-site.xml /opt/hadoop/etc/hadoop/hdfs-site.xml

ENTRYPOINT ["/boot.sh"]
