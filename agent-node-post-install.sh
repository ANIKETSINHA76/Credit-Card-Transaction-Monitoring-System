#!/bin/bash

waitForServiceToStart () {
       	# Ensure that Service is not in a transitional state
       	SERVICE=$1
       	SERVICE_STATUS=$(curl -u admin:admin -X GET http://$AMBARI_HOST:8080/api/v1/clusters/$CLUSTER_NAME/services/$SERVICE | grep '"state" :' | grep -Po '([A-Z]+)')
       	sleep 2
       	echo "$SERVICE STATUS: $SERVICE_STATUS"
       	LOOPESCAPE="false"
       	if ! [[ "$SERVICE_STATUS" == STARTED ]]; then
        	until [ "$LOOPESCAPE" == true ]; do
                SERVICE_STATUS=$(curl -u admin:admin -X GET http://$AMBARI_HOST:8080/api/v1/clusters/$CLUSTER_NAME/services/$SERVICE | grep '"state" :' | grep -Po '([A-Z]+)')
            if [[ "$SERVICE_STATUS" == STARTED ]]; then
                LOOPESCAPE="true"
            fi
            echo "*********************************$SERVICE Status: $SERVICE_STATUS"
            sleep 2
        done
       	fi
}

getNameNodeHost () {
       	NAMENODE_HOST=$(curl -u admin:admin -X GET http://$AMBARI_HOST:8080/api/v1/clusters/$CLUSTER_NAME/services/HDFS/components/NAMENODE|grep "host_name"|grep -Po ': "([a-zA-Z0-9\-_!?.]+)'|grep -Po '([a-zA-Z0-9\-_!?.]+)')

       	echo $NAMENODE_HOST
}

getHiveServerHost () {
        HIVESERVER_HOST=$(curl -u admin:admin -X GET http://$AMBARI_HOST:8080/api/v1/clusters/$CLUSTER_NAME/services/HIVE/components/HIVE_SERVER|grep "host_name"|grep -Po ': "([a-zA-Z0-9\-_!?.]+)'|grep -Po '([a-zA-Z0-9\-_!?.]+)')

        echo $HIVESERVER_HOST
}

getHiveInteractiveServerHost () {
        HIVESERVER_INTERACTIVE_HOST=$(curl -u admin:admin -X GET http://$AMBARI_HOST:8080/api/v1/clusters/$CLUSTER_NAME/services/HIVE/components/HIVE_SERVER_INTERACTIVE|grep "host_name"|grep -Po ': "([a-zA-Z0-9\-_!?.]+)'|grep -Po '([a-zA-Z0-9\-_!?.]+)')

        echo $HIVESERVER_INTERACTIVE_HOST
}

getHiveMetaStoreHost () {
        HIVE_METASTORE_HOST=$(curl -u admin:admin -X GET http://$AMBARI_HOST:8080/api/v1/clusters/$CLUSTER_NAME/services/HIVE/components/HIVE_METASTORE|grep "host_name"|grep -Po ': "([a-zA-Z0-9\-_!?.]+)'|grep -Po '([a-zA-Z0-9\-_!?.]+)')

        echo $HIVE_METASTORE_HOST
}

getKafkaBroker () {
       	KAFKA_BROKER=$(curl -u admin:admin -X GET http://$AMBARI_HOST:8080/api/v1/clusters/$CLUSTER_NAME/services/KAFKA/components/KAFKA_BROKER |grep "host_name"|grep -Po ': "([a-zA-Z0-9\-_!?.]+)'|grep -Po '([a-zA-Z0-9\-_!?.]+)')

       	echo $KAFKA_BROKER
}

getAtlasHost () {
       	ATLAS_HOST=$(curl -u admin:admin -X GET http://$AMBARI_HOST:8080/api/v1/clusters/$CLUSTER_NAME/services/ATLAS/components/ATLAS_SERVER |grep "host_name"|grep -Po ': "([a-zA-Z0-9\-_!?.]+)'|grep -Po '([a-zA-Z0-9\-_!?.]+)')

       	echo $ATLAS_HOST
}

getNifiHost () {
       	NIFI_HOST=$(curl -u admin:admin -X GET http://$AMBARI_HOST:8080/api/v1/clusters/$CLUSTER_NAME/services/NIFI/components/NIFI_MASTER|grep "host_name"|grep -Po ': "([a-zA-Z0-9\-_!?.]+)'|grep -Po '([a-zA-Z0-9\-_!?.]+)')

       	echo $NIFI_HOST
}

AMBARI_HOST=$(cat /etc/ambari-agent/conf/ambari-agent.ini| grep hostname= |grep -Po '([0-9.]+)')


export CLUSTER_NAME=$(curl -u admin:admin -X GET http://$AMBARI_HOST:8080/api/v1/clusters |grep cluster_name|grep -Po ': "(.+)'|grep -Po '[a-zA-Z0-9\-_!?.]+')

if [[ -z $CLUSTER_NAME ]]; then
        echo "Could not get Cluster Name since Ambari Server Host could not be identified from amabri-agent.ini file.."
        exit 1
else
       	echo "*********************************CLUSTER NAME IS: $CLUSTER_NAME"
fi

echo "*********************************Waiting for cluster install to complete..."
waitForServiceToStart YARN

waitForServiceToStart HDFS

waitForServiceToStart HIVE

waitForServiceToStart ZOOKEEPER

waitForServiceToStart NIFI

sleep 10

#AMBARI_HOST=$(nslookup $(cat /etc/ambari-agent/conf/ambari-agent.ini| grep hostname= |grep -Po '([0-9.]+)')| grep -Po ' = (.*)'| grep -Po '([0-9a-zA-Z\-_.,?!@#$%^&*]+)'| rev | cut -c 2- | rev)

export JAVA_HOME=/usr/jdk64
NAMENODE_HOST=$(getNameNodeHost)
export NAMENODE_HOST=$NAMENODE_HOST
HIVESERVER_HOST=$(getHiveServerHost)
export HIVESERVER_HOST=$HIVESERVER_HOST
HIVESERVER_INTERACTIVE_HOST=$(getHiveInteractiveServerHost)
export HIVESERVER_INTERACTIVE_HOST=$HIVESERVER_INTERACTIVE_HOST
HIVE_METASTORE_HOST=$(getHiveMetaStoreHost)
export HIVE_METASTORE_HOST=$HIVE_METASTORE_HOST
HIVE_METASTORE_URI=thrift://$HIVE_METASTORE_HOST:9083
export HIVE_METASTORE_URI=$HIVE_METASTORE_URI
ZK_HOST=$AMBARI_HOST
export ZK_HOST=$ZK_HOST
KAFKA_BROKER=$(getKafkaBroker)
export KAFKA_BROKER=$KAFKA_BROKER
ATLAS_HOST=$(getAtlasHost)
export ATLAS_HOST=$ATLAS_HOST
COMETD_HOST=$AMBARI_HOST
export COMETD_HOST=$COMETD_HOST
NIFI_HOST=$(getNifiHost)
export NIFI_HOST=$NIFI_HOST
env

echo "export NAMENODE_HOST=$NAMENODE_HOST" >> /etc/bashrc
echo "export ZK_HOST=$ZK_HOST" >> /etc/bashrc
echo "export KAFKA_BROKER=$KAFKA_BROKER" >> /etc/bashrc
echo "export ATLAS_HOST=$ATLAS_HOST" >> /etc/bashrc
echo "export HIVE_METASTORE_HOST=$HIVE_METASTORE_HOST" >> /etc/bashrc
echo "export HIVE_METASTORE_URI=$HIVE_METASTORE_URI" >> /etc/bashrc
echo "export COMETD_HOST=$COMETD_HOST" >> /etc/bashrc
echo "export NIFI_HOST=$NIFI_HOST" >> /etc/bashrc

echo "export NAMENODE_HOST=$NAMENODE_HOST" >> ~/.bash_profile
echo "export ZK_HOST=$ZK_HOST" >> ~/.bash_profile
echo "export KAFKA_BROKER=$KAFKA_BROKER" >> ~/.bash_profile
echo "export ATLAS_HOST=$ATLAS_HOST" >> ~/.bash_profile
echo "export HIVE_METASTORE_HOST=$HIVE_METASTORE_HOST" >> ~/.bash_profile
echo "export HIVE_METASTORE_URI=$HIVE_METASTORE_URI" >> ~/.bash_profile
echo "export COMETD_HOST=$COMETD_HOST" >> ~/.bash_profile
echo "export NIFI_HOST=$NIFI_HOST" >> ~/.bash_profile
. ~/.bash_profile

env

#yum install -y phoenix
echo "*********************************Installing Spark-LLAP Binaries..."
	wget -P /usr/hdp/current/spark-client/lib/ http://repo.hortonworks.com/content/repositories/releases/com/hortonworks/spark-llap/1.0.0.2.5.3.0-37/spark-llap-1.0.0.2.5.3.0-37-assembly.jar

echo "*********************************Set Hive Scratch Folder..."
mkdir /tmp/hive
chmod 777 /tmp
chmod 777 /tmp/hive

exit 0