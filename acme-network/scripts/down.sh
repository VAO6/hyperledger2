cd .. && docker-compose -f docker-compose-root-ca.yaml -f docker-compose-int-ca.yaml -f docker-compose-cli-couchdb.yaml down
docker rm $(docker ps -aq --filter 'exited=0')
docker rm $(docker ps -aq --filter 'exited=137')
docker rmi $(docker images -q --filter=reference='dev*:latest')
cd scripts && ./cleancerts.sh
rm -r ../channel-artifacts/*
rm -r ../fabric-ca/org1.acme.com/peers/peer0.org1.acme.com/production
rm -r ../fabric-ca/org2.acme.com/peers/peer0.org2.acme.com/production
rm -r ../fabric-ca/org3.acme.com/peers/peer0.org3.acme.com/production
rm -r ../fabric-ca/org1.acme.com/orderers/orderer.org1.acme.com/production
rm -r ../fabric-ca/org2.acme.com/orderers/orderer.org2.acme.com/production
rm -r ../fabric-ca/org3.acme.com/orderers/orderer.org3.acme.com/production

