FROM jre:0.0.1

ADD hadoop-2.9.2.tar.gz /opt

RUN apt-get update && apt-get --yes install wget ssh rsync vim &&\
chown -R root.root /opt/hadoop-2.9.2 &&\
ln -s /opt/hadoop-2.9.2 /opt/hadoop &&\
echo "<configuration>\
<property><name>fs.defaultFS</name><value>hdfs://localhost:9000</value></property>\
</configuration>" > \
/opt/hadoop/etc/hadoop/core-site.xml && \
echo "<configuration>\
<property><name>dfs.replication</name><value>1</value></property>\
<property><name>dfs.namenode.secondary.http-address</name><value>localhost:50090</value></property>\
</configuration>" > \
/opt/hadoop/etc/hadoop/hdfs-site.xml &&\
useradd -m -s /bin/bash hadoop &&\
mkdir /opt/hadoop/logs &&\
chown hadoop.hadoop /opt/hadoop/logs &&\
su - hadoop -c 'ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && chmod 0600 ~/.ssh/authorized_keys && echo export JAVA_HOME=/opt/jre >> ~/.bashrc' &&\
su hadoop -c 'cd /opt/hadoop && bin/hdfs namenode -format' &&\
sed -i "s|export JAVA_HOME=\${JAVA_HOME}|export JAVA_HOME=/opt/jre|" /opt/hadoop/etc/hadoop/hadoop-env.sh &&\
echo \
"#!/bin/bash\n"\
"service ssh start\n"\
"su - hadoop -c 'ssh -o \"StrictHostKeyChecking no\" localhost ps'\n"\
"su hadoop -c 'ssh -o \"StrictHostKeyChecking no\" localhost ps'\n"\
"su hadoop -c 'cd /opt/hadoop ; sbin/start-dfs.sh'\n"\
> /opt/start-hadoop.sh &&\
chmod +x /opt/start-hadoop.sh
EXPOSE 8020 8042 8088 9000 10020 19888 50010 50020 50070 50075 50090
