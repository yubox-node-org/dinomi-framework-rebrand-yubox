#!/bin/sh

# Check for existence of /etc/init.d/wanrouter
if [ ! -e /etc/init.d/wanrouter ] ; then
        if [ -e /usr/sbin/wanrouter ] ; then
                ln -s /usr/sbin/wanrouter /etc/init.d/wanrouter
		service asterisk stop > /dev/null 2>&1
		service dahdi stop > /dev/null 2>&1
		service wanrouter stop > /dev/null 2>&1
		service wanrouter start > /dev/null 2>&1
		service dahdi start > /dev/null 2>&1
		service asterisk start > /dev/null 2>&1
        fi
fi

MSJ_NO_IP_DHCP="If you could not get a DHCP IP address please type setup and select \"Network configuration\" to set up a static IP."
INTFCNET=`ls -A /sys/class/net/`

echo ""
echo "Welcome to Elastix "
echo "----------------------------------------------------"
echo ""
#echo "For access to the Elastix web GUI use this URL"
echo "Elastix is a product meant to be configured through a web browser."
echo "Any changes made from within the command line may corrupt the system"
echo "configuration and produce unexpected behavior; in addition, changes"
echo "made to system files through here may be lost when doing an update."
echo ""
echo "To access your Elastix System, using a separate workstation (PC/MAC/Linux)"
echo "Open the Internet Browser using the following URL:"

cont=0
for x in $INTFCNET
do
	case $x in
		lo*)
		;;

		sit*)
		;;
				
		# Since CentOS 7 the way of naming network interfaces change to "Consistent Network Device Naming"
		# wich implements a change in the usual name 'ethN' to others network names of the form:
		# en* for ethernet interfaces
		# wl* for wireless lan interfaces
		# ww* for wireless wan interfaces
		# sl* for lineal serial interfaces
		eth*|en*|ww*|wl*|sl*)
			IPADDR[$cont]=`LANG=C /sbin/ip addr show dev $x | perl -ne 'print $1 if /inet (\d+\.\d+.\d+.\d+)/;'`
		;;
	esac
	let "cont++"
done
if [ "$IPADDR[@]" = "" ]; then
   echo "http://<YOUR-IP(s)-HERE>"
   echo "$MSJ_NO_IP_DHCP"
else
   arr=$(echo ${IPADDR[@]} | tr " " "\n")
   for IPs in $arr
   do
	  echo "http://$IPs"
   done
fi

echo ""
