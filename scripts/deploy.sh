#!/bin/bash

# Make sure we've got the repo root directory
cd "${0%/*}"
ROOT=$(git rev-parse --show-toplevel)

# Delete Bootstrap from public folder
rm $ROOT/public/css/bootstrap-3.4.1.css

# Replace Boostrap refs in layout to CDN version
DEV='<link rel="stylesheet" href="/css/bootstrap-3.4.1.css">'
DEPLOY='<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@3.4.1/dist/css/bootstrap.min.css" integrity="sha384-HSMxcRTRxnN+Bdg0JdbxYKrThecOKuH5zCYotlSAcp1+c8xmyTe9GYg1l9a69psu" crossorigin="anonymous">'
sed -i "s;$DEV;$DEPLOY;g" $ROOT/src/views/layout.erb
