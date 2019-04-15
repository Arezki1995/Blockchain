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
. utils.sh

echo "Which version is it?"
read VER

for MIN in 1 2 ; do 
    for PEER in 0 1 ; do
        
        echo
        echo "####################### INSTALLING chaicode on >>> peer${PEER}.min${MIN}.p22network.com"
        sleep 5
        
        setGlobals $PEER $MIN
        
        CORE_LOGGING_PEER=debug peer chaincode install -l java -n publicAnnouncementCC -v $VER -p  $CC_SRC_PATH
        
        echo

    done 
done  


echo "####################### INSTANTIATING chaicode on >>> peer${PEER}.min${MIN}.p22network.com"
sleep 5

peer chaincode instantiate -o orderer.p22network.com:7050 --tls true --cafile $ORDERER_CA -C mychannel -n publicAnnouncementCC -l java -v  $VER -c '{"Args":["init","a","100","b","200"]}' -P "AND ('Ministry1MSP.peer','Ministry2MSP.peer')"
echo 


echo "THE END"
