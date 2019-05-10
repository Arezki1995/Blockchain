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
echo "               P22 NETWORK END TO END"
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
sleep 5
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
	
	#cat log.txt
	
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
sleep 5
createChannel

## Join all the peers to the channel
echo "Having all peers join the channel..."
sleep 5
joinChannel

## Set the anchor peers for each min in the channel
echo "Updating anchor peers for min1..."
sleep 5
updateAnchorPeers 0 1
echo "Updating anchor peers for min2..."
sleep 5
updateAnchorPeers 0 2


echo
echo "========= All GOOD execution completed =========== "
echo
echo
echo " _____   _   _   ____   "
echo "| ____| | \ | | |  _ \  "
echo "|  _|   |  \| | | | | | "
echo "| |___  | |\  | | |_| | "
echo "|_____| |_| \_| |____/  "
echo

exit 0
