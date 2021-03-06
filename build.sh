#!/bin/bash
set -euf -o pipefail

ls ~/data

pushd ~/data
sqlite3 schools.db <<EOS
.mode csv
.import school.csv enrollments
.import district.csv districts
EOS
popd
mv ~/data/schools.db .
sqlite-utils transform schools.db enrollments \
    --type county_state_id integer \
    --type district_nces_id integer \
    --type school_nces_id integer \
    --type school_state_id integer \
    --type year integer
# create extra _int columns for known almost-numeric columns
for column in white black hispanic native_american native_american_alaskan_native asian native_hawaiian asian_pacific_islander native_hawaiian_pacific_islander pacific_islander multiracial unknown_race male female non_binary unknown_gender ell homeless low_income free_and_reduced disability section_504 total
do
  sqlite-utils convert schools.db enrollments $column '
if value.isdigit() or value.replace(",", "").isdigit() or value.endswith(".0") or value.endswith(".5") or value.startswith("<"):
    return int(float(value.replace(",", "").replace("<", "")))
' --output "${column}_int" --output-type integer --silent
done
# Same for districts
sqlite-utils transform schools.db districts \
    --type county_state_id integer \
    --type district_nces_id integer \
    --type district_state_id integer \
    --type ccd_district_type integer \
    --type year integer
for column in white black hispanic native_american native_american_alaskan_native asian native_hawaiian asian_pacific_islander native_hawaiian_pacific_islander pacific_islander multiracial unknown_race male female non_binary unknown_gender ell homeless low_income free_and_reduced disability section_504 total
do
  sqlite-utils convert schools.db districts $column '
if value.isdigit() or value.replace(",", "").isdigit() or value.endswith(".0") or value.endswith(".5") or value.startswith("<"):
    return int(float(value.replace(",", "").replace("<", "")))
' --output "${column}_int" --output-type integer --silent
done
# Create some indexes
sqlite-utils create-index schools.db enrollments state grade
sqlite-utils create-index schools.db enrollments grade
sqlite-utils create-index schools.db enrollments year
sqlite-utils create-index schools.db enrollments state year
sqlite-utils create-index schools.db enrollments school_nces_id
sqlite-utils create-index schools.db enrollments district_nces_id
sqlite-utils create-index schools.db districts state
# Enable full-text search
sqlite-utils enable-fts schools.db enrollments school
sqlite-utils enable-fts schools.db districts district
sqlite-utils optimize schools.db

