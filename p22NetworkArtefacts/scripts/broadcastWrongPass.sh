#!/bin/bash

# Expecting: UserId , userPWD,  MsgTitle , MsgContent
peer chaincode invoke -o orderer.p22network.com:7050 --tls true --cafile $ORDERER_CA -C mychannel -n p22CC -c '{"Args":["broadcastMsg","001","wrongpasswd","Hackeur du dimanche","Spending some time making examples for demo"]}'
