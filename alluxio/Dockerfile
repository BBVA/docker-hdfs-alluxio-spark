FROM openjdk:8-jre

ENV ALLUXIO_HDFS_URL=http://downloads.alluxio.org/downloads/files/1.4.0/alluxio-1.4.0-hadoop2.7-bin.tar.gz

WORKDIR /tmp

RUN wget --quiet ${ALLUXIO_HDFS_URL}

RUN mkdir -p /opt/alluxio && tar zxf /tmp/alluxio-1.4.0-hadoop2.7-bin.tar.gz --strip-components=1 -C /opt/alluxio/

RUN echo openshift-user:x:1000050000:0:root:::/bin/false >> /etc/passwd
RUN chown -R root.root /opt/alluxio
EXPOSE 19999 19998 29998 29999 30000

WORKDIR /
ADD boot.sh /

ENTRYPOINT ["/boot.sh"]
