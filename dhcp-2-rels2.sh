#!/bin/bash

#
# global vars
# 

INTERFACE="eth0"

V4SERVER="91.105.16.1"
echo  "Getting the initial DHCP offer (dhclient)..."
V4CLIENT=$(dhclient -v $INTERFACE 2>&1 | grep "bound to"  | awk '{print $3}')
CLIENT_MAC=$(ifconfig $INTERFACE | grep HWaddr | awk '{print $5}')

echo "got $V4CLIENT for chaddr of $CLIENT_MAC."
SERVER_MAC="ff:ff:ff:ff:ff:ff"

#
# end of global vars
# 


#
# subroutines
#

dec2hex(){   
  echo -n $(echo "obase=16;$1" | bc):
  echo -n $(echo "obase=16;$2" | bc):
  echo -n $(echo "obase=16;$3" | bc):
  echo -n $(echo "obase=16;$4" | bc)
}


empty_str() {
  MAX=$((0+$1))
  for ((i=1;i<$MAX;i++)); do {
   echo -n "00:"
  };
  done
  echo -n "00"
}

#
# end of subroutines
#

SSERVER=$(echo $V4SERVER | sed s/\\./\ /g)
SCLIENT=$(echo $V4CLIENT | sed s/\\./\ /g)

HSERVER=$(dec2hex $SSERVER)
HCLIENT=$(dec2hex $SCLIENT)

OPCODE="01"
HTYPE="01"
HLEN="06"
HOPS="00"
XID="99:$(date +"%H:%M:%S")"
SECS="00:00"
FLAGS="00:00"
CIADDR="00:00:00:00"
YIADDR="00:00:00:00"
SIADDR="00:00:00:00"
GIADDR="00:00:00:00"
CHADDR="$CLIENT_MAC:$(empty_str 10)"
SNAME="$(empty_str 64)"
FILE="$(empty_str 128)"
COOKIE="63:82:53:63"

DH_TYPE="35:01:03" #dhcp request, option 53
DH_REQ="32:04:$HCLIENT" #req ip address, option 50
DH_SRV="36:04:$HSERVER"




#send a release
#echo "sending a RELEASE ($i) $V4CLIENT.."

#DH_TYPE="35:01:07" #dhcp release, option 53
#
#CIADDR=$HCLIENT
#DHEADER="$OPCODE:$HTYPE:$HLEN:$HOPS:$XID:$SECS:$FLAGS:$CIADDR:$YIADDR:$SIADDR:$GIADDR:$CHADDR:$SNAME:$FILE:$COOKIE"
#DH_OPTS="$DH_TYPE:$DH_REQ"
#
#mz $INTERFACE -A $V4CLIENT -B $V4SERVER -t udp  "sp=68,dp=67,p=$DHEADER:$DH_OPTS:ff" > /dev/null 2>&1





# send a discover
#echo "sending a DISCOVER ($i).."

#DH_TYPE="35:01:01" #dhcp discover, option 53
#DHEADER="$OPCODE:$HTYPE:$HLEN:$HOPS:$XID:$SECS:$FLAGS:$CIADDR:$YIADDR:$SIADDR:$GIADDR:$CHADDR:$SNAME:$FILE:$COOKIE"
#DH_OPTS="$DH_TYPE:$DH_REQ"

#mz  $INTERFACE  -A $V4CLIENT -B $V4SERVER -t udp  "sp=68,dp=67,p=$DHEADER:$DH_OPTS:ff" > /dev/null 2>&1


#sleep 2

while sleep 10; do {

echo " sleeping 10 sec.."

XID="99:$(date +"%H:%M:%S")"

for ((i=1;i<101;i++)); do {   # wrap over 10 times


#send a request
V4SRC="0.0.0.0"
#V4SRC=$V4CLIENT
CIADDR=$HCLIENT

DH_TYPE="35:01:03" #dhcp request, option 53
echo "sending a REQUEST ($i) $V4SRC (ciaddr=$CIADDR) to $V4SERVER.."



DHEADER="$OPCODE:$HTYPE:$HLEN:$HOPS:$XID:$SECS:$FLAGS:$CIADDR:$YIADDR:$SIADDR:$GIADDR:$CHADDR:$SNAME:$FILE:$COOKIE"
DH_OPTS="$DH_TYPE:$DH_REQ"

mz  $INTERFACE  -A $V4SRC -B $V4SERVER -t udp  "sp=68,dp=67,p=$DHEADER:$DH_OPTS:ff" > /dev/null 2>&1




};
done

};
done


# try to obtain the address the usual way at the end

#dhclient -v $INTERFACE


exit;

