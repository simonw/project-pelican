#!/bin/bash
set -euf -o pipefail

download_dir="${DOWNLOAD_DIR:-.}"
mkdir -p $download_dir
for filename in state.csv district.csv school.csv;
do
  signed_url=$(curl -s 'https://api.biglocalnews.org/graphql' \
    -H "authorization: JWT $JWT" \
    -H 'content-type: application/json' \
    --data-raw $'{"operationName":"CreateFileDownloadURI","variables":{"input":{"fileName":"'$filename$'","projectId":"UHJvamVjdDowMTFjZDQ5YS1iZDFkLTQ2NjEtYTU1OS1kODZkZDI1NTMyMWU="}},"query":"mutation CreateFileDownloadURI($input: FileURIInput\u0021) {\\n  createFileDownloadUri(input: $input) {\\n    ok {\\n      name\\n      uri\\n      __typename\\n    }\\n    err\\n    __typename\\n  }\\n}\\n"}' \
    --compressed | jq -r .data.createFileDownloadUri.ok.uri)
  conditional-get --etags $download_dir/etags.json --key $filename -v $signed_url -o $download_dir/$filename
done
