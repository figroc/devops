#!/bin/bash
C=(${1})
curl -s -G http://play:9200/sxs/resume4w/_search ${C[@]/#/--data-urlencode }
echo
