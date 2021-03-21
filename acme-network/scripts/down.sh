cd .. && docker-compose -f docker-compose-root-ca.yaml -f docker-compose-int-ca.yaml -f docker-compose-cli-couchdb.yaml down
cd scripts && ./cleancerts.sh
rm -r ../channel-artifacts/*
rm -r ../fabric-ca/org1.acme.com/production
rm -r ../fabric-ca/org2.acme.com/production
rm -r ../fabric-ca/org3.acme.com/production
