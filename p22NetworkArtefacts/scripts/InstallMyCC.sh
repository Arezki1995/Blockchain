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
echo "               Install P22chaincode script"
echo
# import utils
. ./scripts/utils.sh

echo "Which version is it?"
#read VER
VER=v1.0

for MIN in 1 2 ; do 
    for PEER in 0 1 ; do
        
        echo
        echo "####################### INSTALLING chaicode on >>> peer${PEER}.min${MIN}.p22network.com"
        #sleep 5
        
        setGlobals $PEER $MIN
        
        CORE_LOGGING_PEER=debug peer chaincode install -l java -n p22CC -v $VER -p  $CC_SRC_PATH
        
        echo

    done 
done  

setGlobals 0 1
echo "####################### INSTANTIATING chaicode on >>> peer${PEER}.min${MIN}.p22network.com"
#sleep 5

# INIT FUNCTION CREATES ADMIN Expecting: newAdminId, AdminName, AdminPwd, AdminAffiliation
peer chaincode instantiate -o orderer.p22network.com:7050 --tls true --cafile $ORDERER_CA -C mychannel -n p22CC -l java -v  $VER -c '{"Args":["init","000", "Arezki", "passwdofarezki", "Min1"]}' -P "OR ('Ministry1MSP.peer','Ministry2MSP.peer')"
echo 



echo "Installation Done"
echo "Init: Admin User created"

#Endorsement policy syntax

# In the CLI, a simple language is used to express policies in terms of boolean expressions over principals.
# A principal is described in terms of the MSP that is tasked to validate the identity of the signer and of the role that the signer has within that MSP. Four roles are supported: member, admin, client, and peer.
# Principals are described as MSP.ROLE, where MSP is the MSP ID that is required, and ROLE is one of the four strings member, admin, client and peer.
# Examples of valid principals are 'Org0.admin' (any administrator of the Org0 MSP) or 'Org1.member' (any member of the Org1 MSP), 'Org1.client' (any client of the Org1 MSP), and 'Org1.peer' (any peer of the Org1 MSP).

# The syntax of the language is:
# EXPR(E[, E...])
# where EXPR is either AND or OR, representing the two boolean expressions and E is either a principal (with the syntax described above) or another nested call to EXPR.
# For example:
#         AND('Org1.member', 'Org2.member', 'Org3.member') requests 1 signature from each of the three principals
#         OR('Org1.member', 'Org2.member') requests 1 signature from either one of the two principals
#         OR('Org1.member', AND('Org2.member', 'Org3.member')) requests either one signature from a member of the Org1 MSP or 1 signature from a member of the Org2 MSP and 1 signature from a member of the Org3 MSP.

