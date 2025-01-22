#!/bin/bash

tmp_info=/tmp/architect-burgers-auth-svc.deploy-temp.txt
port_pagamento=8090
port_pedido=8091
port_catalogo=8092

if [ "$1" == "reuse_info" ]
then
  if [ ! -f $tmp_info ]
  then
    echo "Requested to reuse info but data file does not exist"
    exit 1
  fi

else

  ./find-load-balancer.sh $port_pagamento | sed 's/LISTENER_ARN=/LISTENER_ARN_PAG=/' > $tmp_info
  if [ $? -ne 0 ]
  then
    echo "Error getting service info"
    exit 1
  fi

  ./find-load-balancer.sh $port_pedido | sed 's/LISTENER_ARN=/LISTENER_ARN_PED=/' >> $tmp_info
  if [ $? -ne 0 ]
  then
    echo "Error getting service info"
    exit 1
  fi

  ./find-load-balancer.sh $port_catalogo | sed 's/LISTENER_ARN=/LISTENER_ARN_CAT=/' >> $tmp_info
  if [ $? -ne 0 ]
  then
    echo "Error getting service info"
    exit 1
  fi

  ./get-external-api-info.sh http-api >> $tmp_info
  if [ $? -ne 0 ]
  then
    echo "Error getting service info"
    exit 1
  fi

  ./get-user-pool-info.sh customer-logins >> $tmp_info
  if [ $? -ne 0 ]
  then
    echo "Error getting service info"
    exit 1
  fi

fi

source $tmp_info

cd ../terraform || exit 1

terraform apply -var http_api_id=$API_ID -var cognito_user_pool_client_id="$USER_POOL_CLIENT_ID" \
	        -var cognito_user_pool_client_secret="$USER_POOL_CLIENT_SECRET" \
		      -var load_balancer_pagamento_arn="$LISTENER_ARN_PAG" \
		      -var load_balancer_pedidos_arn="$LISTENER_ARN_PED" \
		      -var load_balancer_catalogo_arn="$LISTENER_ARN_CAT"

if [ $? -eq 0 ]
then
	echo "Complete! API URL = $API_URL"
fi

