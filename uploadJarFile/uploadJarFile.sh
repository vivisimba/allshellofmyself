#!/bin/bash

timeFlag=1
while ((timeFlag<=3))
do
    echo "Try to open the web, "$timeFlag" time."
    result=`curl -m 300 -I spark-jobserver:8092 -s | grep "200 OK"`
    echo $result
    if [[ "$result" != "" ]]
    then
        echo "jobserver has been running."
        openStr="running"
        break
    fi
    timeFlag=`expr $timeFlag + 1`
done

if [[ "$openStr" == "running" ]]
then
    echo "Start to upload order-job.jar to jobserver."
    uploadOrderStr=`curl --data-binary @/home/order-job.jar spark-jobserver:8092/jars/order-job | grep "SUCCESS"`
    echo $uploadOrderStr
    if [[ "$uploadOrderStr" != "" ]]
    then
        orderStr=0
        echo "upload order-job.jar SUCCESS."
    else
        orderStr=1
        echo "upload order-job.jar FAILED."
    fi
	
    echo "Start to upload billing.jar to jobserver."
    uploadBillingStr=`curl --data-binary @/home/billing.jar spark-jobserver:8092/jars/BillingMain | grep "SUCCESS"`
    echo $uploadBillingStr
    if [[ "$uploadBillingStr" != "" ]]
    then
        billingStr=0
        echo "upload billing.jar SUCCESS."
    else
        billingStr=1
        echo "upload billing.jar FAILED."
    fi
else
	orderStr=1
	billingStr=1
fi

if [ $orderStr == 1 -o $billingStr == 1 ];
then
    exitNum=1
else
    exitNum=0
fi
echo $exitNum
exit $exitNum
