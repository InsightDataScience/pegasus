#!/bin/bash

# Copyright 2015 Insight Data Science
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ELASTICSEARCH_DNS=$1

. ~/.profile

sudo $KIBANA_HOME/bin/kibana plugin --install elasticsearch/marvel/2.3.3

sed -i 's@elasticsearch_url: "localhost:9200"@elasticsearch_url: "'"$ELASTICSEARCH_DNS"':9200"@g' $KIBANA_HOME/config/kibana.yml
