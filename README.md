# 🧠 Big Data Installation & Setup Guide

A complete guide to setting up a **Big Data development environment** on Linux or macOS — including **Hadoop, Spark, Hive, Kafka**, and **Jupyter integration** for analytics and visualization.

---

## 📦 Table of Contents

1. [Overview](#overview)
2. [System Requirements](#system-requirements)
3. [Installation Steps](#installation-steps)
   - [1. Install Java](#1-install-java)
   - [2. Install Hadoop](#2-install-hadoop)
   - [3. Configure Hadoop](#3-configure-hadoop)
   - [4. Install Spark](#4-install-spark)
   - [5. Install Hive](#5-install-hive)
   - [6. Install Kafka](#6-install-kafka)
   - [7. Integrate Jupyter Notebook](#7-integrate-jupyter-notebook)
4. [Run the Big Data Stack](#run-the-big-data-stack)
5. [Sample Scripts](#sample-scripts)
6. [Troubleshooting](#troubleshooting)
7. [License](#license)

---

## 🧩 Overview

This repository provides **automation scripts and configurations** for setting up a local or cloud-based Big Data environment.  
The stack includes:

- **Apache Hadoop** — Distributed storage (HDFS)
- **Apache Spark** — In-memory computation
- **Apache Hive** — Data warehouse on HDFS
- **Apache Kafka** — Streaming message platform
- **Jupyter Notebook** — Interactive analytics interface

---

## ⚙️ System Requirements

| Component | Minimum | Recommended |
|------------|----------|--------------|
| OS | Ubuntu 20.04+ / macOS / WSL | Ubuntu Server / Cloud VM |
| RAM | 8 GB | 16 GB+ |
| Disk | 50 GB | 100 GB+ |
| Java | 8 or 11 | 11 |
| Python | 3.8+ | 3.10+ |

---

## 🚀 Installation Steps

### 1. Install Java

```bash
sudo apt update
sudo apt install openjdk-11-jdk -y
java -version


Set environment variables:
```bash
echo "export JAVA_HOME=$(readlink -f /usr/bin/java | sed 's:/bin/java::')" >> ~/.bashrc
echo "export PATH=$PATH:$JAVA_HOME/bin" >> ~/.bashrc
source ~/.bashrc
```

2. Install Hadoop
```bash
wget https://downloads.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz
tar -xzf hadoop-3.3.6.tar.gz
sudo mv hadoop-3.3.6 /usr/local/hadoop
```

Configure Hadoop in ~/.bashrc:
```bash
export HADOOP_HOME=/usr/local/hadoop
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
```

3. Configure Hadoop

Edit core configuration:
```bash
nano $HADOOP_CONF_DIR/core-site.xml
```

```xml
<configuration>
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://localhost:9000</value>
  </property>
</configuration>
```

Edit HDFS configuration:
```bash
nano $HADOOP_CONF_DIR/hdfs-site.xml
```

```xml
<configuration>
  <property>
    <name>dfs.replication</name>
    <value>1</value>
  </property>
</configuration>
```

Format NameNode:
```bash
hdfs namenode -format
start-dfs.sh
```

4. Install Spark
```bash
wget https://downloads.apache.org/spark/spark-3.5.0/spark-3.5.0-bin-hadoop3.tgz
tar -xzf spark-3.5.0-bin-hadoop3.tgz
sudo mv spark-3.5.0-bin-hadoop3 /usr/local/spark
```

Set environment variables:
```bash
echo "export SPARK_HOME=/usr/local/spark" >> ~/.bashrc
echo "export PATH=$PATH:$SPARK_HOME/bin" >> ~/.bashrc
source ~/.bashrc
```

Run Spark shell:
```bash
spark-shell
```

5. Install Hive
```bash
wget https://downloads.apache.org/hive/hive-3.1.3/apache-hive-3.1.3-bin.tar.gz
tar -xzf apache-hive-3.1.3-bin.tar.gz
sudo mv apache-hive-3.1.3-bin /usr/local/hive
```

Add environment variables:
```bash
echo "export HIVE_HOME=/usr/local/hive" >> ~/.bashrc
echo "export PATH=$PATH:$HIVE_HOME/bin" >> ~/.bashrc
source ~/.bashrc
```

Initialize Hive Metastore:
```bash
schematool -dbType derby -initSchema
```

Run Hive CLI:
```bash
hive
```

6. Install Kafka
```bash
wget https://downloads.apache.org/kafka/3.6.0/kafka_2.13-3.6.0.tgz
tar -xzf kafka_2.13-3.6.0.tgz
sudo mv kafka_2.13-3.6.0 /usr/local/kafka
```

Start Zookeeper and Kafka:
```bash
cd /usr/local/kafka
bin/zookeeper-server-start.sh config/zookeeper.properties &
bin/kafka-server-start.sh config/server.properties &
```

Test Kafka:
```bash
bin/kafka-topics.sh --create --topic test --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1
bin/kafka-console-producer.sh --topic test --bootstrap-server localhost:9092
bin/kafka-console-consumer.sh --topic test --from-beginning --bootstrap-server localhost:9092
```

7. Integrate Jupyter Notebook (with PySpark)

Install Jupyter and findspark:
```bash
pip install jupyter findspark
```


Create a new Python notebook and add:
```bash
import findspark
findspark.init("/usr/local/spark")

from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("BigData_Test") \
    .getOrCreate()

df = spark.createDataFrame([(1, "AI"), (2, "Big Data")], ["ID", "Topic"])
df.show()
```

Run Jupyter:
```bash
jupyter notebook
```

▶️ Run the Big Data Stack

Start all services manually:
```bash
start-dfs.sh
start-yarn.sh
$SPARK_HOME/sbin/start-all.sh
$HIVE_HOME/bin/hive --service metastore &
$KAFKA_HOME/bin/zookeeper-server-start.sh $KAFKA_HOME/config/zookeeper.properties &
$KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties &
```

🧠 Sample Spark Job
```bash
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("WordCount").getOrCreate()

text_file = spark.read.text("hdfs://localhost:9000/user/input/sample.txt")
word_counts = text_file.selectExpr("explode(split(value, ' ')) as word") \
                      .groupBy("word").count()
word_counts.show()
```

🧰 Troubleshooting
Issue	Solution
Hadoop not starting	Check Java path and format HDFS
Hive schema init error	Delete metastore_db and rerun schematool
Spark not recognizing Hadoop	Verify $HADOOP_HOME and $SPARK_HOME paths
Jupyter PySpark import error	Reinstall findspark and set correct Spark path

📜 License

This project is licensed under the MIT License — you’re free to modify and use it for educational or enterprise setup purposes.

🌐 Author

@ganeshprasadbhandari
@aiinovatehub

🌍 LinkedIn
 | Medium
 | GitHub







