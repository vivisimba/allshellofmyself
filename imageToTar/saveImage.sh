#!/bin/bash
imagetag=$1
toTarFilesDir=$2
echo "cp moduleArray.config to temp_moduleArray.config"
\cp moduleArray.config temp_moduleArray.config
echo "Change imageTag in temp_moduleArray.config"
sed -i "s/{imagetag}/$imagetag/g" temp_moduleArray.config


source temp_moduleArray.config

platformFlag=0
moduleFlag=0
for imagename in ${platformArray[@]}
do
    platformFlag=`expr $platformFlag + 1`
    echo "===================image of platform:$platformFlag=================="
    wholeImageName="10.0.251.196/platform/"$imagename
    echo "pull $wholeImageName"
    docker pull $wholeImageName
    tempTarName=$imagename".tar"
    tarName=${tempTarName//:/-}
    echo "Save $wholeImageName as $tarName"
    docker save $wholeImageName > $tarName
    echo "scp ./$tarName buildftp@10.0.250.250:$toTarFilesDir"
    #scp ./$tarName root@10.0.251.209:/home/newtarFiles/
    scp ./$tarName buildftp@10.0.250.250:$toTarFilesDir
done

for moduleName in ${moduleArray[@]}
do
    moduleFlag=`expr $moduleFlag + 1`
    echo "===================image of bossModule $moduleFlag=================="
    wholeModuleName="10.0.251.196/boss/"$moduleName
    echo "pull $wholeModuleName"
    docker pull $wholeModuleName
    tempTarName=$moduleName".tar"
    tarName=${tempTarName//:/-}
    echo "Save $wholeModuleName as $tarName"
    docker save $wholeModuleName > $tarName
    echo "scp ./$tarName root@10.0.251.209:/home/tarFiles/"
    #scp ./$tarName root@10.0.251.209:/home/newtarFiles/
    scp ./$tarName buildftp@10.0.250.250:$toTarFilesDir
done
