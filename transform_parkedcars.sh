#!/bin/bash

curl -X DELETE --netrc-file .netrc localhost:9200/cityflitzer-parkedcars
for id in $(curl --netrc-file .netrc localhost:9200/cityflitzer/_search -d '{"aggs" : {"cars" : {"terms" : { "field" : "vehicle.vehicle.vehicleUID", "size": 300}}}}' -H 'Content-Type: application/json' | jq '.aggregations.cars.buckets[].key'); do docker run --rm --network dev_default grolland/elasticpy:2 python transform-parked.py $(cat  .netrc | cut -d ' ' -f 4) $(cat  .netrc | cut -d ' ' -f 6) $id; done
