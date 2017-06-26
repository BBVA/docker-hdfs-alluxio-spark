# Alluxio

This image contains Alluxio 1.4.0 distribution uncompressed in /opt/alluxio. It is used to bring up master and worker roles.

In this folder there are a copy of the HDFS configuration files. This is done as a conveniencie to build the docker image, but beaware that these needs to match the ones deployed with HDFS.

Alluxio is also configured using a configuration file ```alluxio-site.properties``` which is added to the image at build time.

Please take a loot at the configuration file before using this image and modify it to your needs. Specially the node naming schemes.

