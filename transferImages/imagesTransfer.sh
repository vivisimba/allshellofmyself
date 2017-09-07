#!/bin/bash
imagetag=$1

echo "cp moduleArray.config to temp_moduleArray.config."
\cp moduleArray.config temp_moduleArray.config

echo "Change imageTag in temp_moduleArray.config"
sed -i "s/{imagetag}/$imagetag/g" temp_moduleArray.config

source temp_moduleArray.config

platformFlag=0
platformLength=${#platformArray[@]}

moduleFlag=0
moduleLength=${#bossArray[@]}

billingFlag=0
billingLength=${#billingArray[@]}

echo "login the new image repository!"
docker login -u admin -p asdf1234 -e bizh@startimes.com.cn 10.0.251.190

for imagename in ${platformArray[@]}
do
    platformFlag=`expr $platformFlag + 1`
	echo "===================pull image of platform:$platformFlag/$platformLength=================="
	
	wholeImageName="10.0.251.196/platform/"$imagename
	echo "pull $wholeImageName"
	docker pull $wholeImageName
	newWholeImageName="10.0.251.190/platform/"$imagename
	
	echo "rename image "$wholeImageName" to "$newWholeImageName
	docker tag $wholeImageName $newWholeImageName
	
	echo "push "$newWholeImageName" to the new repository 10.0.251.190."
	docker push  $newWholeImageName
        echo "delete $newWholeImageName "
        docker rmi $newWholeImageName
        echo "delete $wholeImageName "
        docker rmi $wholeImageName
done

for imagename in ${bossArray[@]}
do
    moduleFlag=`expr $moduleFlag + 1`
	echo "===================pull image of boss:$moduleFlag/$moduleLength=================="
	
	wholeImageName="10.0.251.196/boss/"$imagename
	echo "pull $wholeImageName"
	docker pull $wholeImageName
	newWholeImageName="10.0.251.190/boss/"$imagename
	
	echo "rename image "$wholeImageName" to "$newWholeImageName
	docker tag $wholeImageName $newWholeImageName
	
	echo "push "$newWholeImageName" to the new repository 10.0.251.190."
	docker push  $newWholeImageName
#        echo "delete $newWholeImageName "
#        docker rmi $newWholeImageName
#        echo "delete $wholeImageName "
#        docker rmi $wholeImageName
done

for imagename in ${billingArray[@]}
do
    billingFlag=`expr $billingFlag + 1`
	echo "===================pull image of billing:$billingFlag/$billingLength=================="
	
	wholeImageName="10.0.251.196/billing/"$imagename
	echo "pull $wholeImageName"
	docker pull $wholeImageName
	newWholeImageName="10.0.251.190/billing/"$imagename
	
	echo "rename image "$wholeImageName" to "$newWholeImageName
	docker tag $wholeImageName $newWholeImageName
	
	echo "push "$newWholeImageName" to the new repository 10.0.251.190."
	docker push  $newWholeImageName
        echo "delete $newWholeImageName "
        docker rmi $newWholeImageName
        echo "delete $wholeImageName "
        docker rmi $wholeImageName
done

docker images -q|xargs docker rmi -f