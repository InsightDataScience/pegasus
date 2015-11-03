#!/bin/bash

while read line
do
    curl -XPOST http://localhost:9200/sanfrancisco/citylots/ -d "$line"
done < citylots_rev.json
