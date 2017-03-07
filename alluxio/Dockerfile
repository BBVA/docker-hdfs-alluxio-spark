FROM java

ENV ALLUXIO_URL=http://alluxio.org/downloads/files/1.4.0/alluxio-1.4.0-bin.tar.gz
ENV ALLUXIO_HDFS_URL=http://downloads.alluxio.org/downloads/files/1.4.0/alluxio-1.4.0-hadoop2.7-bin.tar.gz

WORKDIR /tmp

RUN wget --quiet ${ALLUXIO_URL}
RUN wget --quiet ${ALLUXIO_HDFS_URL}

RUN mkdir -p /opt/alluxio && tar zxf /tmp/alluxio-1.4.0-bin.tar.gz --strip-components=1 -C /opt/alluxio/
RUN mkdir -p /opt/alluxio_hdfs && tar zxf /tmp/alluxio-1.4.0-hadoop2.7-bin.tar.gz --strip-components=1 -C /opt/alluxio_hdfs/

WORKDIR /
ADD boot.sh /
ADD configure.py /

ENTRYPOINT ["/boot.sh"]
