#!/bin/bash
###############################################################
# Tenta obter o ARN do load balancer listener a partir da Porta
# A forma trivial de referenciar um load balancer específico seria através de seu nome, mas a criação utilizando
# k8s service (type LoadBalancer) não permite termos controle sobre o nome. Assim, a partir da porta que
# sabemos corresponder a cada serviço tentamos obter a referência ao load balancer correto
##############################################################################################

if [ $# -ne 1 ]
  then
  echo "Usage: $0  (expected listener port)"
  exit 1
fi

expected_port="$1"

all_nlb_arns=$(aws elbv2 describe-load-balancers --query 'LoadBalancers[?Type==`network`].LoadBalancerArn' --output text)

if [ "$all_nlb_arns" == "" -o "$all_nlb_arns" == "null" -o "$all_nlb_arns" == "None" ]
then
  echo "Error - Could not get any Network Load Balancer. Is the K8s Service deployed?"  >&2
  exit 1
fi

for lbarn in $all_nlb_arns
do
  lisArn=$(aws elbv2 describe-listeners --load-balancer-arn ${lbarn} --query "Listeners[?Port==\`${expected_port}\`].ListenerArn | [0]" --output text)

  if [ "$lisArn" != "" -a "$lisArn" != "null" -a "$lisArn" != "None" ]
  then
    echo "LISTENER_ARN=$lisArn"
    exit 0
  fi
done

echo "Error - Could not get the Network Load Balancer Listener (${expected_port}). Is the K8s Service deployed?"  >&2
exit 1