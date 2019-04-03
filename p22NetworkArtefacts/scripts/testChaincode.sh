#!/bin/bash

echo
echo " _______  _______  _______        _        _______ _________";
echo "(  ____ )/ ___   )/ ___   )      ( (    /|(  ____ \\__   __/";
echo "| (    )|\/   )  |\/   )  |      |  \  ( || (    \/   ) (   ";
echo "| (____)|    /   )    /   )_____ |   \ | || (__       | |   ";
echo "|  _____)  _/   /   _/   /(_____)| (\ \) ||  __)      | |   ";
echo "| (       /   _/   /   _/        | | \   || (         | |   ";
echo "| )      (   (__/\(   (__/\      | )  \  || (____/\   | |   ";
echo "|/       \_______/\_______/      |/    )_)(_______/   )_(   ";
echo "                                                            ";
echo
echo "           P22 NETWORK Chaincode Testing script"
echo
CHANNEL_NAME="$1"
DELAY="$2"
LANGUAGE="$3"
TIMEOUT="$4"
VERBOSE="$5"
: ${CHANNEL_NAME:="mychannel"}
: ${DELAY:="3"}
: ${LANGUAGE:="java"}
: ${TIMEOUT:="10"}
: ${VERBOSE:="true"}
LANGUAGE=`echo "$LANGUAGE" | tr [:upper:] [:lower:]`
COUNTER=1
MAX_RETRY=10

#default chincode source path set to suit java development
CC_SRC_PATH="/opt/gopath/src/github.com/chaincode/java-dev-sources/"
if [ "$LANGUAGE" = "node" ]; then

	CC_SRC_PATH="/opt/gopath/src/github.com/chaincode/node-dev-sources/"
fi

if [ "$LANGUAGE" = "java" ]; then
	CC_SRC_PATH="/opt/gopath/src/github.com/chaincode/java-dev-sources/"
fi

echo "Channel name : "$CHANNEL_NAME

# import utils
. scripts/utils.sh

# I assume chaincode is installed on peers:  peer0.min1 and peer0.min2

# Instantiate chaincode on peer0.min2
echo "Instantiating chaincode on peer0.min2..."
instantiateChaincode 0 2



# Query chaincode on peer0.min1
echo "Querying chaincode on peer0.min1..."
chaincodeQuery 0 1 100

# Invoke chaincode on peer0.min1 and peer0.min2
echo "Sending invoke transaction on peer0.min1 peer0.min2..."
chaincodeInvoke 0 1 0 2

## Install chaincode on peer1.min2
echo "Installing chaincode on peer1.min2..."
installChaincode 1 2

# Query on chaincode on peer1.min2, check if the result is 90
echo "Querying chaincode on peer1.min2..."
chaincodeQuery 1 2 90
