#/bin/bash

if [ $# -eq 0 ]; then
  echo "Username or password missing"
  echo "Usage: get_token.sh USER PASSWORD localhost:3000"
  exit
fi

curl -XPOST 'http://'$3'/v0/sessions?username='$1'&password='$2 -d ''
