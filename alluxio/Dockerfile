FROM ubuntu:16.04

RUN apt-get update && apt-get --no-install-recommends install -y libnss-wrapper wget && apt-get clean
# Install Oracle JDK 8u11
RUN mkdir /opt/java && cd /tmp && \
		wget --quiet --no-cookies --no-check-certificate  --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u121-b13/e9e7ea248e2c4826b92b3f075a80e441/jdk-8u121-linux-x64.tar.gz && \
    tar xf jdk-8u121-linux-x64.tar.gz -C /opt/java && \
    rm -f jdk-8u121-linux-x64.tar.gz && \
    ln -s /opt/java/jdk* /opt/java/jdk

# Define commonly used JAVA_HOME variable
# Add /srv/java and jdk on PATH variable
ENV JAVA_HOME=/opt/java/jdk \
    PATH=${PATH}:/opt/java/jdk/bin:/opt/java

ENV ALLUXIO_HDFS_URL=http://downloads.alluxio.org/downloads/files/1.4.0/alluxio-1.4.0-hadoop2.7-bin.tar.gz

WORKDIR /tmp

RUN wget --quiet ${ALLUXIO_HDFS_URL}

RUN mkdir -p /opt/alluxio && tar zxf /tmp/alluxio-1.4.0-hadoop2.7-bin.tar.gz --strip-components=1 -C /opt/alluxio/

RUN chown -R root.root /opt/alluxio
RUN chmod -R g+rw /opt/alluxio

EXPOSE 19999 19998 29998 29999 30000 39999

WORKDIR /
ADD boot.sh /

ENTRYPOINT ["/boot.sh"]
