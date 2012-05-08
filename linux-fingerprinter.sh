#!/bin/bash
#
# Quick and Dirty system report facility
# 
# ahandle
#
# Tue May  8 15:14:15 CDT 2012
###################################

# set vars
HOSTNAME=$(hostname)
DATE=$(date +%Y%m%d)
FILE="/var/tmp/$HOSTNAME.$DATE-SYSRPT.txt"
HTM="/var/tmp/$HOSTNAME.$DATE-SYSRPT.htm"

#####################################
sys_version(){
# Find system release information
#
# Check for Redhat..
if [ -f /etc/redhat-release ]
then
        echo "Redhat Linux release:"
        echo "<PRE>"
        cat /etc/redhat-release
        SYS=redhat
        echo "</PRE>"
        echo ; echo
        break
else
        if [ -f /etc/debian_version ]
        then
                echo "Debian Linux version:"
                echo "<PRE>"
                cat /etc/debian_version
                SYS=debian
                echo "</PRE>"
                echo ; echo
                break
        else
                if [ -f /etc/SuSE-release]
                then
                        echo "SUSE Linux:"
                        echo "<PRE>"
                        cat /etc/SuSE-release
                        SYS=suse
                        echo "</PRE>"
                        echo ; echo
                else
                        echo "Undefined Linux release.."
                        echo "Add to sys_version() in $0"
                fi
        fi
fi
}
#######################################
 
#####################################
get_package_details(){
# Get package information
    echo "----------------------------" 
	echo "Package and software information"
    echo "----------------------------" 

case $SYS in

        redhat)

                echo "Redhat packages:"
                echo "<PRE>"
                rpm -qa | sort -u
                echo "</PRE>"
                echo "----------------------------" 
        ;;

        debian)
                echo "Debian packages:"
                echo "<PRE>"
                dpkg -l
                echo "</PRE>"
                echo "----------------------------" 
        ;;

        suse)
                echo "Suse RPM packages:"
                echo "<PRE>"
                rpm -qa | sort -u
                echo "</PRE>"
                echo "----------------------------" 
        ;;

        *)
                echo "Undefined system."
                echo "Extend the SYS case statement in get_package_details() in $0"
        ;;
esac

echo ; echo
}
#####################################





# This is where things happen
# Apologies for the haywire arrangement of this script.
# I've been kicking it down the road for a few years now.

touch $FILE

clear
echo "Output for $HOSTNAME will be in $FILE"

case $1 in
-h|--html)
    echo "** HTML version being created as $HTM"
;;
esac

sleep 2
exec 6>&1
exec > $FILE


# set header in output file
echo "----------------------------" 
echo "----------------------------" 
echo "System Configuration report for $HOSTNAME"
echo "<PRE>"
date
echo "</PRE>"
echo "----------------------------" 
echo "----------------------------" 
echo ; echo

# call the system versioning function above..
sys_version

# call the package details script from above..
get_package_details

#####################################
# Get module and kernel information
echo "----------------------------" 
echo "System and Kernel information for $HOSTNAME"
echo "Processor cores: `cat /proc/cpuinfo | grep processor | wc -l`"
echo "Processor speed: `cat /proc/cpuinfo | grep MHz | awk '{print $4}' | sort -u` MHz"
echo "Processor type: `/usr/sbin/dmidecode| grep -a1 "Central Processor" | grep Family | sort -u | awk '{print $2}'`"
echo "Total RAM: `grep MemTotal /proc/meminfo | awk '{print $2 " " $3}'`"
echo "----------------------------" 

# Kernel release
echo "----------------------------" 
echo "Linux kernel version:"
echo "----------------------------" 
echo "<PRE>"
uname -a 
echo "</PRE>"
echo "----------------------------" 
echo ; echo

#####################################
# Get hardware information
echo "----------------------------" 
echo "System hardware information"
echo "Processor cores: `cat /proc/cpuinfo | grep processor | wc -l`"
echo "Processor speed: `cat /proc/cpuinfo | grep MHz | awk '{print $4}' | sort -u` MHz"
echo "Total RAM: `grep MemTotal /proc/meminfo | awk '{print $2 " " $3}'`"
echo "----------------------------" 
echo "'/usr/sbin/dmidecode' output:"
echo "----------------------------" 
echo "<PRE>"
/usr/sbin/dmidecode
echo "</PRE>"
echo "----------------------------" 
echo "/proc/cpuinfo"
echo "----------------------------" 
echo "<PRE>"
cat /proc/cpuinfo
echo "</PRE>"
echo "----------------------------" 
echo "----------------------------" 
echo ; echo
######################################

echo "System Configuration report for $HOSTNAME"
echo "----------------------------" 

# Restore stdout
exec 1>&6 6>&-

cp $FILE $HTM

# remove the HTML tags from the script output - preserves it for the HTML version.
# Gnarly backwards hack..
sed -i 's/<PRE>//g' $FILE
sed -i 's/<\/PRE>//g' $FILE

# if the -h option is enabled, dump an HTML version of the report
case $1 in
 -h | --html)
    sed -i 's/\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-/<hr>/g' $HTM
    sed -i "s/IFOX System Configuration report for $HOSTNAME/\<h1\>IFOX System Configuration report for $HOSTNAME\<\/h1\>/g" $HTM
    sed -i "s/System and Kernel information for $HOSTNAME/<h2\>System and Kernel information for $HOSTNAME\<\/h2\>/g" $HTM
    sed -i "s/Linux kernel version:/\<h3\>Linux kernel version:\<\/h3\>/g" $HTM
    sed -i 's/Timezone information:/\<h3\>Timezone information:\<\/h3\>/g' $HTM
    sed -i 's/Kernel module information:/\<h3\>Kernel module information:\<\/h3\>/g' $HTM
    sed -i 's/Running and available services:/\<h3\>Running and available services:\<\/h3\>/g' $HTM
    sed -i 's/System account info:/\<h3\>System account info:\<\/h3\>/g' $HTM
    sed -i "s/OS-level NFS Filesystem information for $HOSTNAME/\<h3\>OS-level NFS Filesystem information for $HOSTNAME\<\/h3\>/g" $HTM
    sed -i "s/OS-level Filesystem information for $HOSTNAME/\<h3\>OS-level Filesystem information for $HOSTNAME\<\/h3\>/g" $HTM
    sed -i "s/Network and interface information for $BONDZERO/\<h3\>Network and interface information for $BONDZERO\<\/h3\>/g" $HTM
    sed -i "s/nslookup information for $HOSTNAME/\<h3\>nslookup information for $HOSTNAME\<\/h3\>/g" $HTM
    sed -i "s/nslookup information for $BONDZERO/\<h3\>nslookup information for $BONDZERO\<\/h3\>/g" $HTM
    sed -i "s/Other network interfaces:/\<h3\>Other network interfaces:\<\/h3\>/g" $HTM
    sed -i "s/Package and software information/\<h3\>Package and software information\<\/h3\>/g" $HTM
    sed -i "s/Java version/\<h3\>Java version\<\/h3\>/g" $HTM
    sed -i "s/System hardware information/\<h3\>System hardware information\<\/h3\>/g" $HTM
    # kludge to fix some of the dash nonsense
    #sed -i 's/\<hr\>\<hr\>\-\-\-\-\-\-\-/\<hr\>/g'
    # if additional sections are added above, a sed command must go here to change the contents of the TXT file heading
    # to make it HTML.
    # Look at the output of the text file and run an (example) ':s/foo/System hardware information' for each 'foo'
    #sed -i 's/foo/\<h3\>foo\<\/h3\>/g' $HTM
    #sed -i 's/foo/\<h3\>foo\<\/h3\>/g' $HTM
    #sed -i 's/foo/\<h3\>foo\<\/h3\>/g' $HTM
;;

esac

