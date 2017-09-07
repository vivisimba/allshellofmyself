#!/bin/sh
echo "------------------------------------------------------------------"
DATESTR=$(date +%y%m%d)
echo "Log of $DATESTR."
rm -rf /sync-s3-aws-newboss/*
aws s3 sync s3://aws-newboss /sync-s3-aws-newboss
newSize=`du -s /sync-s3-aws-newboss/ | awk '{print $1}'`
echo "Now size of Dir:/sync-s3-aws-newboss/ is "$newSize
if [ 1000000 -lt $((newSize)) ]
then
    echo "Start to redeploy boss service."
    echo "============================"
	
    # stop	
	
    echo "Stop /home/centos/dev-deploy/compose/boss-ui/docker-compose.yml."
    docker-compose -f /home/centos/dev-deploy/compose/boss-ui/docker-compose.yml stop
    echo "============================"
	
    echo "Stop /home/centos/dev-deploy/compose/boss-services/docker-compose.yml."
    docker-compose -f /home/centos/dev-deploy/compose/boss-services/docker-compose.yml stop
    echo "============================"
	
	echo "Stop /home/centos/dev-deploy/compose/billing/billingandorder-job.yml."
	docker-compose -f /home/centos/dev-deploy/compose/billing/billingandorder-job.yml stop
	
	echo "Stop /home/centos/dev-deploy/compose/other/platform-cache-config.yml."
	docker-compose -f /home/centos/dev-deploy/compose/other/platform-cache-config.yml stop
	
	echo "Stop /home/centos/dev-deploy/compose/other/platform-config.yml."
	docker-compose -f /home/centos/dev-deploy/compose/other/platform-config.yml stop
	
	# delete old bak
	
    echo "delete old bak files"
    rm -rf /newboss_backup/*
	
	# backup files of yesterday
	
    echo "Backup boss-service to /newboss_backup/$DATESTR/"
    toDir="/newboss_backup/$DATESTR/"
    mkdir -p $toDir
	
    mv /home/centos/deploy-mount/boss-services $toDir
	mv /home/centos/deploy-mount/platform-cache-config $toDir
	mv /home/centos/deploy-mount/platform-config $toDir
    echo "============================"
	
	# unzip zip files
	
	cd /sync-s3-aws-newboss/
	unzip billing.zip
	unzip order-job.zip
	unzip platform-cache-config.zip
	unzip platform-config.zip
	
	# get config from git
	
	git clone -b temp_10.4.0 https://sysconfig-at-394587406188:3vnb5DaNASbvFsIzHLvzJJ72VCcKsmS9J3QJVlPD92c=@git-codecommit.eu-west-1.amazonaws.com/v1/repos/bossconfig /git-store/b
	cd /git-store/b/config
	\cp /sync-s3-aws-newboss/platform-config/configScripts/TEMPLATE.groovy ./
	echo '#!/bin/bash' > current-version.info
	echo "aws-rrt-build-$DATESTR" >> current-version.info
	cd /git-store/b
	git commit -a -m "aws-rrt-build-$DATESTR"
	git push https://sysconfig-at-394587406188:3vnb5DaNASbvFsIzHLvzJJ72VCcKsmS9J3QJVlPD92c=@git-codecommit.eu-west-1.amazonaws.com/v1/repos/bossconfig temp_10.4.0
	
	git tag -a aws-rrt-build-$DATESTR -m "aws-rrt-build-$DATESTR"
	git push -f origin aws-rrt-build-$DATESTR
	
	cd /git-store
	rm -rf ./b
	
	# mv 

	echo "Get new boss-services"
	cd /sync-s3-aws-newboss
	mv ./platform-config /home/centos/deploy-mount/
	mv ./platform-cache-config /home/centos/deploy-mount/
	mv ./order-job ./boss-services/
	mv ./billing ./boss-services/
	
	mv ./boss-services/ /home/centos/deploy-mount/
    echo "============================"
	
	# start
	
	echo "Start /home/centos/dev-deploy/compose/other/platform-config.yml."
	docker-compose -f /home/centos/dev-deploy/compose/other/platform-config.yml start
	
	echo "Start /home/centos/dev-deploy/compose/other/platform-cache-config.yml."
	docker-compose -f /home/centos/dev-deploy/compose/other/platform-cache-config.yml start
	
	echo "Start /home/centos/dev-deploy/compose/billing/billingandorder-job.yml."
	docker-compose -f /home/centos/dev-deploy/compose/billing/billingandorder-job.yml start
	
    echo "Start /home/centos/dev-deploy/compose/boss-services/docker-compose.yml"
    docker-compose -f /home/centos/dev-deploy/compose/boss-services/docker-compose.yml start
    echo "Start /home/centos/dev-deploy/compose/boss-ui/docker-compose.yml"
    echo "============================"
    docker-compose -f /home/centos/dev-deploy/compose/boss-ui/docker-compose.yml start
fi
