#!/bin/bash

# Expecting: Id
peer chaincode query -o orderer.p22network.com:7050 --tls true --cafile $ORDERER_CA -C mychannel -n p22CC -c '{"Args":["queryUserMsgs", "001"]}'
