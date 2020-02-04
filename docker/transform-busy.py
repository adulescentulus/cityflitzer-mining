from datetime import datetime
from elasticsearch import helpers
from elasticsearch import Elasticsearch
import json
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("user", help="elastic user")
parser.add_argument("pass", help="elastic pass")
parser.add_argument("carId", help="Id of the car", type=int)
args=parser.parse_args()

es = Elasticsearch(['elasticsearch'],http_auth=(args.user,args.pass),
            scheme="http",
                port=9200)

#res = es.index(index="test-index", id=1, body=doc)
#print(res['result'])

#res = es.get(index="test-index", id=1)
#print(res['_source'])

#es.indices.refresh(index="test-index")

#res = es.search(index="cityflitzer", body={"query": {"match_all": {}}})
#print("Got %d Hits:" % res['hits']['total']['value'])
#for hit in res['hits']['hits']:
#        print("%(timestamp)s %(author)s: %(text)s" % hit["_source"])

newIndexName = "cityflitzer-busycars"
#es.indices.delete(index=newIndexName, ignore=[400, 404])

carQuery={
  "sort" : [
          { "timestamp": {"order" : "asc"}}
              ],
                "query": {
                            "match": {
                                      "vehicle.vehicle.vehicleUID": 192397
                                          }
                              }
                }

carQuery['query']['match']['vehicle.vehicle.vehicleUID']=args.carId
carDoc = ""
for doc in helpers.scan(es,
            query=carQuery,
                index="cityflitzer",
                    doc_type="_doc",
                    preserve_order=True,
                    size=200
                    ):
    if carDoc == "":
        carDoc = doc['_source']
        carDoc['dateFrom']=carDoc['timestamp']
        carDoc['dateUntil']=carDoc['timestamp']

    if carDoc['vehicle']['vehicle']['geoPos'] != doc['_source']['vehicle']['vehicle']['geoPos']:
        print("Found new location at %s" % doc['_source']['timestamp'])
        carDoc['dateUntil']=doc['_source']['timestamp']
        es.index(index=newIndexName, body=carDoc)
        carDoc = doc['_source']
        carDoc['dateFrom']=carDoc['timestamp']
        carDoc['dateUntil']=carDoc['timestamp']

    carDoc['dateFrom']=doc['_source']['timestamp']
    #print(doc['_source']['timestamp'])

print("done")

