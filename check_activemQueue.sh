#!/bin/sh
# ===============
# check_activemQueue - plugin to check the size of a given queue on Activemq
# ===============
# Written by Etienne Delsy, EDRANS 
# Specifically for esb04; It might apply for other servers with the same configuration.

# Plugin return codes:
# 0	OK
# 1	Warning
# 2	Critical
# 3	Unknown

#Variables
queue=$1    # The queue to be verified
user=$2     # User for monitoring purpose  
pass=$3     # JMX password
jmxurl=$4   # jmxurl
warning=$5  # Threshold for Warning
critical=$6 # Threshold for Critical

if [[ -z "$1" ]] || [[ -z "$2" ]] || [[ -z "$3" ]] || [[ -z "$4" ]] || [[ -z "$5" ]] || [[ -z "$6" ]]
then
      echo "Missing parameters! Syntax: $0 queueName userName jmxpassword jmxurl warningThreshold criticalThreshold"
      exit 3
fi

if (( "$warning" >= "$critical" ))
then
        echo "Ups, Critical supposes to be greater than Warning"
        exit 3
fi

queueSize=$(/opt/progress/fuse-message-broker-5.3.0.5/bin/activemq-admin query -QQueue=$queue --jmxuser $user --jmxpassword $pass --jmxurl $jmxurl |grep QueueSize| sed 's/\|/ /' | awk '{print $3}')

if (( "$queueSize" < "$warning" ))
then
        echo "OK - The queue size of $queue is $queueSize"
        exit 0
elif (( $queueSize >= $warning && $queueSize < $critical ))
then
                echo "Warning - The queue size of $queue is $queueSize"
                exit 1
elif (( $queueSize >= $critical ))
then
        echo "Critical - The queue size of $queue is $queueSize"
        exit 2
else
        echo "Check you configuration, something seems to be wrong"
        echo "Syntax: $0 queueName userName jmxpassword jmxurl warningThreshold criticalThreshold"
        exit 3
fi
