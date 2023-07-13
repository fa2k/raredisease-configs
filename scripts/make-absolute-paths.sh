#!/bin/bash

# This is designed to be run from scripts/ dir. First get path of parent dir:
repo_root=$(dirname $PWD)

# Add correct paths to text files that require absolute paths
sed -e "s#^#$repo_root/refData/#" ../refData/vcfanno_resources_template.txt > ../refData/vcfanno_resources.txt
sed -e "s#^PATH/#$repo_root/refData/#" ../refData/svdb_query_dbs_template.csv > ../refData/svdb_query_dbs.csv

