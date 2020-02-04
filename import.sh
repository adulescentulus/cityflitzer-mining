#!/bin/bash -eu

FILES=2*.json
COUNTER=1
for f in $FILES
do
  if [ $COUNTER -eq 1 ]; then
    echo "" > bulk.json
  fi
  COUNTER=$((COUNTER+1))
  echo "Processing file $f"
  TIMECODE=$(echo $f | sed -e 's/\([[:digit:]]\{4\}-[[:digit:]]\{2\}-[[:digit:]]\{2\}\)_\([[:digit:]]\{2\}\)-\([[:digit:]]\{2\}\)-\([[:digit:]]\{2\}+[[:digit:]]\{4\}\).*/\1T\2:\3:\4/')
  echo "...extracting hubs"
  cat $f | jq -c --arg dat "${TIMECODE}" 'foreach .listGeoBookingProposals.data.hubs[] as $hub (. + {timestamp: $dat} ; .hub = $hub | del(.listGeoBookingProposals) ; { "index":{ } }, .)'  >> bulk.json
  echo "...extracting vehicles"
  cat $f | jq -c --arg dat "${TIMECODE}" 'foreach .listGeoBookingProposals.data.vehicles[] as $vehicle (. + {timestamp: $dat} ; .vehicle = $vehicle | del(.listGeoBookingProposals) | del(.vehicle.vehicle.geoPos.name) | del(.vehicle.vehicle.geoPos.showMap); { "index":{ } }, .)'  >> bulk.json
  mv $f processed/
  if [ $COUNTER -eq 100 ]; then
    COUNTER=1
    echo "Uploading now"
    #echo "" >> bulk.json
    curl -X POST --netrc-file .netrc "localhost:9200/cityflitzer/_bulk/" -H 'Content-Type: application/x-ndjson' --data-binary @bulk.json
  fi
done
echo "Uploading now"
#echo "" >> bulk.json
curl -X POST --netrc-file .netrc "localhost:9200/cityflitzer/_bulk/" -H 'Content-Type: application/x-ndjson' --data-binary @bulk.json

