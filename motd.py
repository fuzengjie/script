#!/usr/bin/env python



import os
USER = os.popen('echo $USER').read().strip('\n')
DATE = os.popen('date +%F\ %H:%M:%S').read().strip('\n')
IP = os.popen("/sbin/ifconfig  | awk -F [:\ ]++ '/inet/ {if ( $4 != \"127.0.0.1\") {print $4}}'").read().strip('\n')
INFO = "Welcome Login Beyond System,Please Enjoy it"
text_width = len(INFO)
screen_width = 50
box_width = text_width + 6
left_margin = (screen_width - box_width)//2




print '\033[1;31;40m'
print (' '*left_margin+'+'+'-'*(text_width+2)+ '+')
print (' '*left_margin+'|'+' '*(text_width+2)+  '|')
print (' '*left_margin+'| '+  INFO +' '*(box_width-text_width-5)+'|')
print (' '*left_margin+'|'+' '*(text_width+2)+  '|')
print (' '*left_margin+'|'+  " USER: " + USER +' '*(box_width-len(USER)-4-len(' USER: '))+'|')
print (' '*left_margin+'|'+  " DATE: " + DATE +' '*(box_width-len(DATE)-4-len(' DATE: '))+'|')
print (' '*left_margin+'|'+  " IP: " + IP +' '*(box_width-len(IP)-4-len(' IP: '))+'|')
#print (' '*left_margin+'|'+' '*(text_width+2)+  '|')
print (' '*left_margin+'+'+'-'*(text_width+2)+ '+')
print '\033[0m'
