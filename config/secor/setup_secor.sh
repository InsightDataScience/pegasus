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

args=( "$@" )
s3_bucket=${args[-1]}
length=$(($#-1))
DNS=${@:1:$length}
DNS=(${DNS})

. ~/.profile

sudo sed -i 's@aws.access.key=@aws.access.key='"$AWS_ACCESS_KEY_ID"'@g' $SECOR_HOME/bin/secor.common.properties
sudo sed -i 's@aws.secret.key=@aws.secret.key='"$AWS_SECRET_ACCESS_KEY"'@g' $SECOR_HOME/bin/secor.common.properties
sudo sed -i 's@secor.compression.codec=@secor.compression.codec=org.apache.hadoop.io.compress.GzipCodec@g' $SECOR_HOME/bin/secor.common.properties
sudo sed -i 's@secor.file.extension=@secor.file.extension='".gz"'@g' $SECOR_HOME/bin/secor.common.properties
sudo sed -i 's@secor.file.reader.writer.factory=com.pinterest.secor.io.impl.SequenceFileReaderWriterFactory@secor.file.reader.writer.factory=com.pinterest.secor.io.impl.DelimitedTextFileReaderWriterFactory@g' $SECOR_HOME/bin/secor.common.properties

sudo sed -i 's@kafka.seed.broker.host=@kafka.seed.broker.host='"${DNS[0]}"'@g' $SECOR_HOME/bin/secor.prod.properties

ZK_SERVERS=""
for dns in ${DNS[@]}
do
    ZK_SERVERS=$ZK_SERVERS$dns:2181,
done

sudo sed -i 's@zookeeper.quorum=@zookeeper.quorum='"${ZK_SERVERS:0:-1}"'@g' $SECOR_HOME/bin/secor.prod.properties
sudo sed -i 's@secor.s3.bucket=@secor.s3.bucket='"${s3_bucket}"'@g' $SECOR_HOME/bin/secor.prod.properties
sudo sed -i 's@ostrich.port=9999@ostrich.port=9997@g' $SECOR_HOME/bin/secor.prod.backup.properties
