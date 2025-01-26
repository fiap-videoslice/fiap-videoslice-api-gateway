#!/bin/bash

tmp_info=/tmp/videoslice-auth-svc.deploy-temp.txt
port_webapi=8090

if [ "$1" == "reuse_info" ]
then
  if [ ! -f $tmp_info ]
  then
    echo "Requested to reuse info but data file does not exist"
    exit 1
  fi
else

  ./find-load-balancer.sh $port_webapi | sed 's/LISTENER_ARN=/LISTENER_ARN_WEBAPI=/' > $tmp_info
  if [ $? -ne 0 ]
  then
    echo "Error getting service info"
    exit 1
  fi

  ./get-user-pool-info.sh videoslice-logins >> $tmp_info
  if [ $? -ne 0 ]
  then
    echo "Error getting service info"
    exit 1
  fi

fi

source $tmp_info

cd ../terraform || exit 1

set -x

terraform apply -var cognito_user_pool_client_id="$USER_POOL_CLIENT_ID" \
	        -var cognito_user_pool_client_secret="$USER_POOL_CLIENT_SECRET" \
		      -var load_balancer_web_api_arn="$LISTENER_ARN_WEBAPI"

if [ $? -eq 0 ]
then
	echo "Complete!"
	terraform output
fi

