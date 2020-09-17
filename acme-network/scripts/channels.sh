function joinChannel() {
  org=$1
  mspID=$2
  peerName=$3
  peerAddress=$4

  export CORE_PEER_ADDRESS=$peerAddress
  export CORE_PEER_LOCALMSPID=$mspID
  export CORE_PEER_TLS_ENABLED=true
  export CORE_PEER_TLS_ROOTCERT_FILE=$(cd ../ && echo $PWD/fabric-ca/$org/peers/$peerName/tls/ca.crt)
  export CORE_PEER_MSPCONFIGPATH=$(cd ../ && echo $PWD/fabric-ca/$org/users/admin@$org/msp)
  peer channel join -b ../channel-artifacts/marketplace.genesis.block
}

function updateChannelWithAnchorTx() {
    org=$1
    msp=$2
    peerAddress=$3
    ordererAddress=$4

    export CORE_PEER_ADDRESS=$peerAddress
    export CORE_PEER_LOCALMSPID=$msp
    export CORE_PEER_MSPCONFIGPATH=$(cd ../ && echo $PWD/fabric-ca/$org/users/admin@$org/msp)
    export ORDERER_CA=$(cd ../ && echo $PWD/fabric-ca/$org/orderers/orderer.$org/tls/ca.crt)

    peer channel update -c marketplace -f ../channel-artifacts/${msp}anchors.tx -o $ordererAddress --tls --cafile $ORDERER_CA
}

which peer
if [ "$?" -ne 0 ]; then
    echo "peer tool not found. exiting"
    exit 1
fi

export FABRIC_CFG_PATH=$(cd ../ && pwd)
export CORE_PEER_MSPCONFIGPATH=$(cd ../ && echo $PWD/fabric-ca/org1.acme.com/users/admin@org1.acme.com/msp)
export CLIENTAUTH_CERTFILE=$(cd ../ && echo $PWD/fabric-ca/org1.acme.com/users/admin@org1.acme.com/tls/server.crt)
export CLIENTAUTH_KEYFILE=$(cd ../ && echo $PWD/fabric-ca/org1.acme.com/users/admin@org1.acme.com/tls/server.key)
export CORE_PEER_LOCALMSPID=Org1MSP
export ORDERER_CA=$(cd ../ && echo $PWD/fabric-ca/org1.acme.com/orderers/orderer.org1.acme.com/tls/ca.crt)
# Create the application channel
peer channel create -o localhost:7050 -c marketplace -f ../channel-artifacts/channel.tx --outputBlock ../channel-artifacts/marketplace.genesis.block --tls --cafile $ORDERER_CA --clientauth --certfile $CLIENTAUTH_CERTFILE --keyfile $CLIENTAUTH_KEYFILE
sleep 1
# Let the peers join the channel
joinChannel org1.acme.com Org1MSP peer0.org1.acme.com localhost:7051
joinChannel org2.acme.com Org2MSP peer0.org2.acme.com localhost:8051
joinChannel org3.acme.com Org3MSP peer0.org3.acme.com localhost:9051
# Set the anchor peers in the network
updateChannelWithAnchorTx org1.acme.com Org1MSP localhost:7051 localhost:7050
updateChannelWithAnchorTx org2.acme.com Org2MSP localhost:8051 localhost:8050
updateChannelWithAnchorTx org3.acme.com Org3MSP localhost:9051 localhost:9050
