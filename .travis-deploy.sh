#!/bin/sh
set -e

echo "#### Running Deploy Script ####"

# setup ssh-agent and provide the GitHub deploy key
eval "$(ssh-agent -s)"
chmod 600 deploy_rsa
ssh-add deploy_rsa

#ssh -p $PORT $STAGING  "cd smartcitizen-api; ./scripts/deploy.sh"
ssh-keyscan -p$PORT $SERVER
ssh -oStrictHostKeyChecking=no -p$PORT $SERVER touch file.txt
