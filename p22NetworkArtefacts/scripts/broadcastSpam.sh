#!/bin/bash

# Expecting: UserId , userPWD,  MsgTitle , MsgContent
peer chaincode invoke -o orderer.p22network.com:7050 --tls true --cafile $ORDERER_CA -C mychannel -n p22CC -c '{"Args":["broadcastMsg","001","passwdofuser1","Spam 01","Lorem epsum in dolore"]}'
sleep 5
peer chaincode invoke -o orderer.p22network.com:7050 --tls true --cafile $ORDERER_CA -C mychannel -n p22CC -c '{"Args":["broadcastMsg","001","passwdofuser1","Spam 02","Lorem epsum in dolore"]}'
sleep 5
peer chaincode invoke -o orderer.p22network.com:7050 --tls true --cafile $ORDERER_CA -C mychannel -n p22CC -c '{"Args":["broadcastMsg","001","passwdofuser1","Spam 03","Lorem epsum in dolore"]}'
sleep 5
peer chaincode invoke -o orderer.p22network.com:7050 --tls true --cafile $ORDERER_CA -C mychannel -n p22CC -c '{"Args":["broadcastMsg","001","passwdofuser1","Spam 04","Lorem epsum in dolore"]}'
