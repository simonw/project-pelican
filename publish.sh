#!/bin/bash
set -euf -o pipefail

datasette publish cloudrun schools.db \
    --install datasette-vega \
    --install datasette-rure \
    --install datasette-remote-metadata \
    --install datasette-json-html \
    --install pysqlite3-binary \
    -m metadata.yml \
    --template-dir templates \
    --service project-pelican \
    --secret $DATASETTE_PUBLISH_SECRET \
    --branch 0.59a0 \
    --extra-options "--setting trace_debug 1 --setting suggest_facets off --setting sql_time_limit_ms 10000 --setting facet_time_limit_ms 10000" \
    --memory 4Gi \
