#!/usr/bin/env python



import os
USER = os.popen('echo $USER').read().strip('\n')
DATE = os.popen('date +%F\ %H:%M:%S').read().strip('\n')
IP = os.popen("/sbin/ifconfig  | awk -F [:\ ]++ '/inet/ {if ( $4 != \"127.0.0.1\") {print $4}}'").read().strip('\n')
INFO = "Welcome Login Beyond System,Please Enjoy it"
LENGTH = len(INFO) + 8

print '\033[1;31;40m'
print "*" * LENGTH
print "*"," " * 3 , INFO
print "*"," " * 3 , "User: " ,  USER
print "*"," " * 3 , "Date: " , DATE
print "*"," " * 3 , "IP:   " , IP
print "*" * LENGTH
print '\033[0m'

