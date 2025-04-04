#!/bin/bash

for TEAM in a b; do
  for APP in product sale; do
    POD_NAME=$(vcluster connect vcteam-$TEAM -- kubectl -n app-$APP get pod -o jsonpath='{.items[].metadata.name}')
    POD_IP=$(vcluster connect vcteam-$TEAM -- kubectl -n app-$APP get pod -o jsonpath='{.items[].status.podIP}')
    
    TEAM_UPPER=$(echo $TEAM | tr '[:lower:]' '[:upper:]')
    APP_UPPER=$(echo $APP | tr '[:lower:]' '[:upper:]')
    
    export TEAM${TEAM_UPPER}_${APP_UPPER}_POD=$POD_NAME
    export TEAM${TEAM_UPPER}_${APP_UPPER}_IP=$POD_IP
  done
done