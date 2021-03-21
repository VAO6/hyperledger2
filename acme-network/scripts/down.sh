cd .. && docker-compose -f docker-compose-root-ca.yaml -f docker-compose-int-ca.yaml -f docker-compose-cli-couchdb.yaml down
cd scripts && ./cleancerts.sh
rm -r ../channel-artifacts/*
