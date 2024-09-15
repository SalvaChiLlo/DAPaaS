#!/bin/sh
echo Starting gateway configurator

cp -r /usr/src/app/init_files/conf/* $SHARED_DIR/

node /usr/src/app/index.js