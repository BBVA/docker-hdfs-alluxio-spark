FROM ubuntu:16.04


RUN echo deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main >> /etc/apt/sources.list.d/oracle.list
RUN echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 7B2C3B0889BF5709A105D03AC2518248EEA14886 && \
	apt-get update && apt-get --no-install-recommends install -y libnss-wrapper wget oracle-java7-installer && \
	apt-get clean

RUN update-java-alternatives -a


# ENV ALLUXIO_HDFS_URL=http://downloads.alluxio.org/downloads/files/1.4.0/alluxio-1.4.0-hadoop2.7-bin.tar.gz
ENV ALLUXIO_HDFS_URL=http://downloads.alluxio.org/downloads/files/1.3.0/alluxio-1.3.0-hadoop2.7-bin.tar.gz
WORKDIR /tmp

RUN wget --quiet ${ALLUXIO_HDFS_URL}

RUN mkdir -p /opt/alluxio && tar zxf /tmp/alluxio-1.3.0-hadoop2.7-bin.tar.gz --strip-components=1 -C /opt/alluxio/

RUN chown -R root.root /opt/alluxio
RUN chmod -R g+rw /opt/alluxio

EXPOSE 19999 19998 29998 29999 30000 39999

WORKDIR /
ADD boot.sh /

ENTRYPOINT ["/boot.sh"]
