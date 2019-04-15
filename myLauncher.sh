#!/bin/bash

export PROJECT_PATH=~/Blockchain
export DIR=$PROJECT_PATH/fabric-dev-servers/fabric-scripts/hlfv12
export DOCKER_FILE=$DIR/composer/docker-compose.yml
export FABRIC_START_TIMEOUT=10
export OUTPUT_CONFIG=arezki@p22-config.yaml
export CFG_PATH=$DIR/composer
 

GENESIS_BLK=newGenesis.block
CHANNEL=newChannel.tx

cd $DIR
echo "---------Launching fabric cluster for P22 IMA4 Prototype0..."
echo "press ENTER:"
read stop
./startFabric.sh

echo "---------Network configuration from crypto-config.yaml..."
echo "press ENTER:"
read stop

#clean network cards
rm -rf ~/.composer

cd $CFG_PATH
cryptogen generate --config=crypto-config.yaml --output OUTPUT_CONFIG

echo "---------Initializing blockchain..."
echo "press ENTER:"
read stop
cd $CFG_PATH
FABRIC_CFG_PATH=. configtxgen -profile ComposerOrdererGenesis -outputBlock $GENESIS_BLK

echo "---------Creating channel..."
echo "press ENTER:"
read stop
FABRIC_CFG_PATH=. configtxgen -profile ComposerChannel -channelID composerchannel -outputCreateChannelTx $CHANNEL


echo "---------Creating PeerAdmin card..."
echo "press ENTER:"
read stop
cd $DIR
./createPeerAdminCard.sh

echo "---------Deploying business Network Archive..."
echo "press ENTER:"
read stop
composer network install --card PeerAdmin@hlfv1 --archiveFile $PROJECT_PATH/p22_network/p22_network@0.0.1.bna

echo "---------Starting network with PeerAdmin card..."
echo "press ENTER:"
read stop
composer network start --card PeerAdmin@hlfv1 --networkName p22_network --networkVersion 0.0.1 --networkAdmin admin --networkAdminEnrollSecret adminpw

echo "---------Importing network card..."
echo "press ENTER:"
read stop
composer card import --file ./admin@p22_network.card

echo "---------Pinging the network..."
echo "press ENTER:"
read stop
composer network ping --card admin@p22_network

echo "---------Generating rest API..."
echo "press ENTER:"
read stop
composer-rest-server -c admin@p22_network -n never -u true -d n -w true


