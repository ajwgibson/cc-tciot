#!/bin/bash

source /home/mccool/.rvm/scripts/rvm
rvm use 2.4.6

cd /home/mccool/deploy/footfall

export RAILS_ENV=production
export FOOTFALL_DATABASE=xxx
export FOOTFALL_DATABASE_USERNAME=xxx
export FOOTFALL_DATABASE_PASSWORD=xxx
export AWS_ACCESS_KEY_ID=xxx
export AWS_SECRET_ACCESS_KEY=xxx
export FOOTFALL_AWS_FOOTFALL_TABLE_NAME=xxx

rake emulator:generate_footfall_data
