datasette publish cloudrun schools.db \
    --install datasette-auth-passwords \
    -m metadata.yml \
    --template-dir templates \
    --service project-pelican \
    --extra-options "--setting sql_time_limit_ms 10000 --setting facet_time_limit_ms 10000" \
    --memory 4Gi

