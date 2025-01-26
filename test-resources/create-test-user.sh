#!/bin/bash
# Utilize depois de criada a infraestrutura do Cognito

if [ $# -ne 4 ]
then
	echo "Usage: $0  (USER EMAIL)  (NAME)  (PASSWORD)  (User | Admin)"
  exit 1
fi

email=$1
name="$2"
password="$3"
groupName=$4

# Assuming there is exactly 1 pool matching the query
poolId="$(aws cognito-idp list-user-pools --max-results 10 --query 'UserPools[?Name==`videoslice-logins`].Id | [0]' | tr -d '"')"

if [ "$poolId" == "" ]
then
  echo "User Pool videoslice-logins not available"
  exit 1
fi

aws cognito-idp admin-create-user --user-pool-id $poolId --username $email \
    --user-attributes Name=email,Value=$email Name=name,Value="$name" \
    --temporary-password Sl1ceTh1sV1deo2025

if [ $? -ne 0 ]
then
  echo "Error creating user"
  exit 1
fi

aws cognito-idp admin-set-user-password --user-pool-id $poolId  \
    --username $email --password "$password" --permanent

if [ $? -ne 0 ]
then
  echo "Error setting password"
  exit 1
fi

aws cognito-idp admin-add-user-to-group --user-pool-id $poolId  \
    --username $email --group-name $groupName

if [ $? -ne 0 ]
then
  echo "Error assigning to group"
  exit 1
fi

echo "User created.  [ $email ]"
