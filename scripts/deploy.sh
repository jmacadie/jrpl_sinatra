#!/bin/bash

# Make sure we've got the repo root directory
cd "${0%/*}"
ROOT=$(git rev-parse --show-toplevel)

# Delete Bootstrap from public folder
rm $ROOT/public/css/bootstrap-5.3.8.min.css
rm $ROOT/public/js/bootstrap-5.3.8.bundle.min.js

# Replace Bootstrap refs in layout to CDN version
DEV='<link rel="stylesheet" href="/css/bootstrap-5.3.8.min.css">'
DEPLOY='<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" integrity="sha384-sRIl4kxILFvY47J16cr9ZwB07vP4J8+LH7qKQnuqkuIAvNWLzeN8tE5YBujZqJLB" crossorigin="anonymous">'
sed -i "s;$DEV;$DEPLOY;g" $ROOT/src/views/layout.erb

DEV='<script src="/js/bootstrap-5.3.8.bundle.min.js" defer></script>'
DEPLOY='<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js" integrity="sha384-FKyoEForCGlyvwx9Hj09JcYn3nv7wiPVlz7YYwJrWVcXK/BmnVDxM+D2scQbITxI" crossorigin="anonymous" defer></script>'
sed -i "s;$DEV;$DEPLOY;g" $ROOT/src/views/layout.erb
