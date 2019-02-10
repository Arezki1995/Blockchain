#!/bin/bash



#FILLING USERS
      curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "org.public.User", "userId": "0000", "userName": "arezki", "userGroup": "Public Network", "signature": "passwdofarezki" }' 'http://localhost:3000/api/User'
  sleep 1s
      curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "org.public.User", "userId": "0001", "userName": "zeus", "userGroup": "Public Network", "signature": "passwdofzeus" }' 'http://localhost:3000/api/User'
  sleep 1s
      curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "org.public.User", "userId": "0002", "userName": "hades", "userGroup": "Public Network", "signature": "passwdofhades"}' 'http://localhost:3000/api/User'
  sleep 1s
      curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "org.public.User", "userId": "0003", "userName": "kira", "userGroup": "Public Network", "signature": "passwdofkira" }' 'http://localhost:3000/api/User'
  sleep 1s
 
 
 
 #DUMMY TRANSACTIONS
      curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "org.public.Broadcast", "newMsgId": "000001", "newMsgTitle": "HELLo", "newMsgContent": "The start of a new age", "ownerID": "0000", "ownerSignature": "passwdofarezki", "transactionId": "",  "timestamp": "2019-02-06T20:46:40.595Z" }' 'http://localhost:3000/api/Broadcast'
  sleep 1s
      curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "org.public.Broadcast", "newMsgId": "000002", "newMsgTitle": "Message 1", "newMsgContent": "First message on the network", "ownerID": "0001", "ownerSignature": "passwdofzeus", "transactionId": "",   "timestamp": "2019-02-06T20:46:41.595Z" }' 'http://localhost:3000/api/Broadcast'
  sleep 1s
      curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "org.public.Broadcast", "newMsgId": "000003", "newMsgTitle": "Message 2", "newMsgContent": "Second message on the network",   "ownerID": "0002",   "ownerSignature": "passwdofhades",   "transactionId": "",   "timestamp": "2019-02-06T20:46:42.595Z" }' 'http://localhost:3000/api/Broadcast'
  sleep 1s
      curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "org.public.Broadcast", "newMsgId": "000004", "newMsgTitle": "Message 3", "newMsgContent": "Third message on the network", "ownerID": "0003", "ownerSignature": "passwdofkira", "transactionId": "", "timestamp": "2019-02-06T20:46:43.595Z" }' 'http://localhost:3000/api/Broadcast' 
  sleep 1s
      curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "org.public.Broadcast", "newMsgId": "000005", "newMsgTitle": "Message 4 ", "newMsgContent": "Forth message on the network",   "ownerID": "0000",   "ownerSignature": "passwdofarezki",   "transactionId": "",   "timestamp": "2019-02-06T20:46:44.595Z" }' 'http://localhost:3000/api/Broadcast'   
  sleep 1s
      curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "org.public.Broadcast", "newMsgId": "000006", "newMsgTitle": "Message 5", "newMsgContent": "Fifth message on the network", "ownerID": "0002",   "ownerSignature": "passwdofhades",   "transactionId": "",   "timestamp": "2019-02-06T20:46:45.595Z" }' 'http://localhost:3000/api/Broadcast'
 
 
 
 
 
 
 
 
 
 
 
