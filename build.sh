#!/bin/bash
set -euf -o pipefail

ls ~/data

pushd ~/data
sqlite3 schools.db <<EOS
.mode csv
.import school.csv enrollments
.import district.csv districts
.import state.csv states
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
# create extra _int columns for known almost-numeric columns
for column in white black hispanic native_american native_american_alaskan_native asian native_hawaiian asian_pacific_islander native_hawaiian_pacific_islander pacific_islander multiracial unknown_race male female non_binary unknown_gender ell homeless low_income free_and_reduced disability section_504 total
do
  sqlite-transform lambda schools.db enrollments $column \
    --code '
if value.isdigit() or value.replace(",", "").isdigit() or value.endswith(".0") or value.endswith(".5") or value.startswith("<"):
    return int(float(value.replace(",", "").replace("<", "")))
' --output "${column}_int" --output-type integer > /dev/null
done
# Create some indexes
sqlite-utils create-index schools.db enrollments state
sqlite-utils create-index schools.db enrollments school_nces_id
sqlite-utils create-index schools.db enrollments district_nces_id
# Enable full-text search
sqlite-utils enable-fts schools.db enrollments school
sqlite-utils vacuum schools.db
