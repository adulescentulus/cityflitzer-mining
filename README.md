# Cityflitzer® mining

This project downloads Cityflitzer's car positions via simple web API. The aim is to do some data mining and visualization. Because this is my first data mining/visualization project I use Elasticsearch and Kibana

## HowTo

TODO not bulletproof, needs rework

Just follow these steps:

- Build the Docker image for Datatransformation inside `docker`: `docker-compose build`
- Start Elasticsearch and Kibana inside `docker`: `docker-compose -p cf up -d`
- Create passwords for your Elastic stack: `docker exec -it cf_elasticsearch_1 bin/elasticsearch-setup-passwords interactive`
- copy `.netrc_sample` to `.netrc` and put your credentials inside
- setup a cron job for downloading the data every x minutes running `download.sh`
- after having some data run `import.sh`
- currently the approach to calculate rental durations is to transform the data with calculated begin and end, this happens by running `transform.sh`

