#!/bin/sh
rm -Rf ../../5\ docs/BizFlowCommon
node ../../node_modules/jsdoc/jsdoc.js -c ./jsdoc.conf.json -r -d ../../5\ docs/BizFlowCommon -R ./README.md .
