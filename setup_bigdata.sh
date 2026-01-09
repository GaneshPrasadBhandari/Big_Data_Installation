#!/bin/bash
# =========================================
# Big Data Stack Auto Installer
# Author: AI Vanguard Labs
# =========================================

set -e

echo "========================================="
echo "Starting Big Data Stack Installation..."
echo "========================================="

# --- Update System ---
sudo apt update && sudo apt upgrade -y

# --- Install Java ---
echo "Installing OpenJDK 11..."
sudo apt install openjdk-11-jdk -y
export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:/bin/java::")
echo "export JAVA_HOME=$JAVA_HOME" >> ~/.bashrc
echo "export PATH=$PATH:$JAVA_HOME/bin" >> ~/.bashrc
source ~/.bashrc
java -version

# --- Install Hadoop ---
echo "Installing Hadoop 3.3.6..."
wget -q https://downloads.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz
tar -xzf hadoop-3.3.6.tar.gz
sudo mv hadoop-3.3.6 /usr/local/hadoop
rm hadoop-3.3.6.tar.gz

cat <<EOL >> ~/.bashrc
export HADOOP_HOME=/usr/local/hadoop
export HADOOP_CONF_DIR=\$HADOOP_HOME/etc/hadoop
export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin
EOL
source ~/.bashrc

# --- Configure Hadoop ---
echo "⚙️ Configuring Hadoop..."
mkdir -p ~/hadoop_data/namenode
mkdir -p ~/hadoop_data/datanode

cat > $HADOOP_CONF_DIR/core-site.xml <<EOL
<configuration>
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://localhost:9000</value>
  </property>
</configuration>
EOL

cat > $HADOOP_CONF_DIR/hdfs-site.xml <<EOL
<configuration>
  <property>
    <name>dfs.replication</name>
    <value>1</value>
  </property>
  <property>
    <name>dfs.namenode.name.dir</name>
    <value>file:///home/$USER/hadoop_data/namenode</value>
  </property>
  <property>
    <name>dfs.datanode.data.dir</name>
    <value>file:///home/$USER/hadoop_data/datanode</value>
  </property>
</configuration>
EOL

hdfs namenode -format

# --- Install Spark ---
echo "Installing Apache Spark 3.5.0..."
wget -q https://downloads.apache.org/spark/spark-3.5.0/spark-3.5.0-bin-hadoop3.tgz
tar -xzf spark-3.5.0-bin-hadoop3.tgz
sudo mv spark-3.5.0-bin-hadoop3 /usr/local/spark
rm spark-3.5.0-bin-hadoop3.tgz

cat <<EOL >> ~/.bashrc
export SPARK_HOME=/usr/local/spark
export PATH=\$PATH:\$SPARK_HOME/bin:\$SPARK_HOME/sbin
EOL
source ~/.bashrc

# --- Install Hive ---
echo "Installing Apache Hive 3.1.3..."
wget -q https://downloads.apache.org/hive/hive-3.1.3/apache-hive-3.1.3-bin.tar.gz
tar -xzf apache-hive-3.1.3-bin.tar.gz
sudo mv apache-hive-3.1.3-bin /usr/local/hive
rm apache-hive-3.1.3-bin.tar.gz

cat <<EOL >> ~/.bashrc
export HIVE_HOME=/usr/local/hive
export PATH=\$PATH:\$HIVE_HOME/bin
EOL
source ~/.bashrc

schematool -dbType derby -initSchema

# --- Install Kafka ---
echo "Installing Apache Kafka 3.6.0..."
wget -q https://downloads.apache.org/kafka/3.6.0/kafka_2.13-3.6.0.tgz
tar -xzf kafka_2.13-3.6.0.tgz
sudo mv kafka_2.13-3.6.0 /usr/local/kafka
rm kafka_2.13-3.6.0.tgz

cat <<EOL >> ~/.bashrc
export KAFKA_HOME=/usr/local/kafka
export PATH=\$PATH:\$KAFKA_HOME/bin
EOL
source ~/.bashrc

# --- Install Python + Jupyter ---
echo "Installing Python packages..."
sudo apt install python3-pip -y
pip install jupyter findspark pyspark

# --- Start Services ---
echo "Starting Hadoop, Spark, and Kafka..."
start-dfs.sh
start-yarn.sh
$SPARK_HOME/sbin/start-all.sh
$KAFKA_HOME/bin/zookeeper-server-start.sh -daemon $KAFKA_HOME/config/zookeeper.properties
$KAFKA_HOME/bin/kafka-server-start.sh -daemon $KAFKA_HOME/config/server.properties

echo "Big Data stack installation complete!"
echo "Run 'jupyter notebook' to start your analytics environment."
