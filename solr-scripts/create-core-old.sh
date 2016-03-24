#!/bin/sh
cp -R /opt/solr/example/solr/collection1 /opt/solr/example/solr/$CKAN_SOLR_CORE
cp /media/solr_conf/schema.xml /opt/solr/example/solr/$CKAN_SOLR_CORE/conf/
echo "name=$CKAN_SOLR_CORE" > /opt/solr/example/solr/$CKAN_SOLR_CORE/core.properties
