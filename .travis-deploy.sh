#!/bin/sh
set -e

echo "#### Running Deploy Script ####"

# This was moved from .travis.yml before_install section, because it breaks on PRs, because PRs dont support encrypted variables
openssl aes-256-cbc -K $encrypted_7d0a84ef0065_key -iv $encrypted_7d0a84ef0065_iv -in deploy_rsa.enc -out deploy_rsa -d

# setup ssh-agent and provide the GitHub deploy key
eval "$(ssh-agent -s)"
chmod 600 deploy_rsa
ssh-add deploy_rsa

ssh -oStrictHostKeyChecking=no -p$PORT $SERVER "cd smartcitizen-api; ./scripts/deploy.sh"
