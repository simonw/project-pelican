#!/bin/bash
set -euf -o pipefail

datasette publish cloudrun schools.db \
    --install datasette-auth-passwords \
    -m metadata.yml \
    --template-dir templates \
    --service project-pelican \
    --secret $DATASETTE_PUBLISH_SECRET \
    --extra-options "--setting trace_debug 1 --setting suggest_facets off --setting sql_time_limit_ms 10000 --setting facet_time_limit_ms 10000" \
    --memory 4Gi
