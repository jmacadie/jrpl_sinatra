#!/bin/bash

# Make sure we're in the repo root directory
ROOT=$(git rev-parse --show-toplevel)
cd "$ROOT"

# Delete Bootstrap and jQuery from public folder
sudo rm public/css/bootstrap-3.4.1.css
sudo rm public/js/bootstrap-3.4.1.js
sudo rm public/js/jquery-2.1.4.js

# Replace Boostrap and jquery refs in layout to CDN version
DEV='<link rel="stylesheet" href="/css/bootstrap-3.4.1.css">'
DEPLOY='<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@3.4.1/dist/css/bootstrap.min.css" integrity="sha384-HSMxcRTRxnN+Bdg0JdbxYKrThecOKuH5zCYotlSAcp1+c8xmyTe9GYg1l9a69psu" crossorigin="anonymous">'
sudo sed -i "s;$DEV;$DEPLOY;g" src/views/layout.erb

DEV='<script src="/js/bootstrap-3.4.1.js"></script>'
DEPLOY='<script src="https://cdn.jsdelivr.net/npm/bootstrap@3.4.1/dist/js/bootstrap.min.js" integrity="sha384-aJ21OjlMXNL5UyIl/XNwTMqvzeRMZH2w8c5cRVpzpU8Y5bApTppSuUkhZXN0VxHd" crossorigin="anonymous"></script>'
sudo sed -i "s;$DEV;$DEPLOY;g" src/views/layout.erb

DEV='<script src="/js/jquery-2.1.4.js"></script>'
DEPLOY='<script src="https://cdn.jsdelivr.net/npm/jquery@2.1.4/dist/jquery.min.js" integrity="sha256-ImQvICV38LovIsvla2zykaCTdEh1Z801Y+DSop91wMU=" crossorigin="anonymous"></script>'
sudo sed -i "s;$DEV;$DEPLOY;g" src/views/layout.erb
