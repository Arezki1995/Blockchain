#!/bin/bash

echo
echo " ____    _____      _      ____    _____ "
echo "/ ___|  |_   _|    / \    |  _ \  |_   _|"
echo "\___ \    | |     / _ \   | |_) |   | |  "
echo " ___) |   | |    / ___ \  |  _ <    | |  "
echo "|____/    |_|   /_/   \_\ |_| \_\   |_|  "
echo
echo "      P22 NETWORK END TO END TEST"
echo
CHANNEL_NAME="$1"
DELAY="$2"
LANGUAGE="$3"
TIMEOUT="$4"
VERBOSE="$5"
: ${CHANNEL_NAME:="mychannel"}
: ${DELAY:="3"}
: ${LANGUAGE:="golang"}
: ${TIMEOUT:="10"}
: ${VERBOSE:="true"}
LANGUAGE=`echo "$LANGUAGE" | tr [:upper:] [:lower:]`
COUNTER=1
MAX_RETRY=10

CC_SRC_PATH="github.com/chaincode/chaincode_example02/go/"
if [ "$LANGUAGE" = "node" ]; then
	CC_SRC_PATH="/opt/gopath/src/github.com/chaincode/chaincode_example02/node/"
fi

if [ "$LANGUAGE" = "java" ]; then
	CC_SRC_PATH="/opt/gopath/src/github.com/chaincode/chaincode_example02/java/"
fi

echo "Channel name : "$CHANNEL_NAME

# import utils
. scripts/utils.sh

createChannel() {
	setGlobals 0 1

	if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
		peer channel create -o orderer.p22network.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx >&log.txt
		res=$?
                set +x
	else
				set -x
		peer channel create -o orderer.p22network.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
		res=$?
				set +x
	fi
	cat log.txt
	verifyResult $res "Channel creation failed"
	echo "===================== Channel '$CHANNEL_NAME' created ===================== "
	echo
}

joinChannel () {
	for min in 1 2; do
	    for peer in 0 1; do
		joinChannelWithRetry $peer $min
		echo "===================== peer${peer}.min${min} joined channel '$CHANNEL_NAME' ===================== "
		sleep $DELAY
		echo
	    done
	done
}

## Create channel
echo "Creating channel..."
createChannel

## Join all the peers to the channel
echo "Having all peers join the channel..."
joinChannel

## Set the anchor peers for each min in the channel
echo "Updating anchor peers for min1..."
updateAnchorPeers 0 1
echo "Updating anchor peers for min2..."
updateAnchorPeers 0 2


##############################################
###### Installing chaincode on peers	######
##############################################

## Install chaincode on peer0.min1 and peer0.min2
echo "Installing chaincode on peer0.min1..."
installChaincode 0 1

echo "Installing chaincode on peer0.min2..."
installChaincode 0 2


##############################################
## Instantiating chaincode on peer0.min2	##
##############################################

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

echo
echo "========= All GOOD, END 2 END test execution completed =========== "
echo

echo
echo " _____   _   _   ____   "
echo "| ____| | \ | | |  _ \  "
echo "|  _|   |  \| | | | | | "
echo "| |___  | |\  | | |_| | "
echo "|_____| |_| \_| |____/  "
echo

exit 0
