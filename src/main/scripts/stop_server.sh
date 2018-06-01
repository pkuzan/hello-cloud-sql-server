#!/bin/bash
pricer_running=`pgrep -f pricer-core`
if [[ -n $pricer_running ]]; then
   pkill -f pricer-core
fi