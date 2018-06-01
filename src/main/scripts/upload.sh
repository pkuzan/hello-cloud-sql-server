#!/bin/bash
key=VY4rdQxjyoLXPVOWIEGO3skR9LjYouP30As4/ggz9HNd+3q/hziSNtasUd2EUq04tVZ+mSvhkYhuI2LT2GjdlA==
export key

az storage blob upload \
    --container-name hello-cloud-storage-container \
    --name hello-cloud-bin \
    --account-name azurehellocloud007 \
    --account-key VY4rdQxjyoLXPVOWIEGO3skR9LjYouP30As4/ggz9HNd+3q/hziSNtasUd2EUq04tVZ+mSvhkYhuI2LT2GjdlA== \
    --file /Users/pkuzan/dev/azure/hello-cloud/target/pricer-core-0.0.3-SNAPSHOT.jar

az storage blob upload \
    --container-name hello-cloud-storage-container \
    --name start_server.sh \
    --account-name azurehellocloud007 \
    --account-key $key \
    --file /Users/pkuzan/dev/azure/hello-cloud/src/main/scripts/start_server.sh
