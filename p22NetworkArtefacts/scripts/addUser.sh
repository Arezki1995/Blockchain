#!/bin/bash


# Expecting: Id, UserName, UserMinistry, UserPWD, adminID, adminPWD 
peer chaincode invoke -o orderer.p22network.com:7050 --tls true --cafile $ORDERER_CA -C mychannel -n p22CC -c '{"Args":["addUser","001","user1","Min1","passwdofuser1","000","passwdofarezki"]}'

