#!/bin/bash


while true
do
   clear
   curl -X GET --header 'Accept: application/json' 'http://localhost:3000/api/Message' | sed "s/},{/\n\n/g" | sed "s/,/\n/g"
   sleep 2s
   
done
