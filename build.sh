#!/bin/bash
set -euf -o pipefail

pushd ~/data
sqlite3 schools.db <<EOS
.mode csv
.import school.csv enrollments
.import district.csv districts
.import data/state.csv states
EOS
popd
mv ~/data/schools.db .
sqlite-utils transform schools.db enrollments \
    --type county_state_id integer \
    --type district_nces_id integer \
    --type district_state_id integer \
    --type school_nces_id integer \
    --type school_state_id integer \
    --type year integer
sqlite-utils enable-fts schools.db enrollments school
sqlite-utils vacuum schools.db
