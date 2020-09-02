function createChannelMSP() {
    org=$1

    MSP_PATH=../fabric-ca/$org/msp
    mkdir -p $MSP_PATH
    mkdir $MSP_PATH/cacerts && sudo cp ../fabric-ca/$org/root/ca-cert.pem $MSP_PATH/cacerts/ca-cert.pem
    mkdir $MSP_PATH/intermediatecerts && sudo cp ../fabric-ca/$org/int/ca-cert.pem $MSP_PATH/intermediatecerts/ca-cert.pem
    mkdir $MSP_PATH/tlscacerts && sudo cp ../fabric-ca/$org/tls-root/ca-cert.pem $MSP_PATH/tlscacerts/ca-cert.pem
    mkdir $MSP_PATH/tlsintermediatecerts && sudo cp ../fabric-ca/$org/tls-int/ca-cert.pem $MSP_PATH/tlsintermediatecerts/ca-cert.pem
}

function createLocalMSP() {
    org=$1
    node=$2
    type=$3

    NODE_MSP_PATH=../fabric-ca/$org/peers/$node/msp
    if test "$type" = "orderer"
    then
        NODE_MSP_PATH=../fabric-ca/$org/orderers/$node/msp
    fi
    mkdir -p $NODE_MSP_PATH
    sudo cp ../fabric-ca/$org/msp/config.yaml $NODE_MSP_PATH
    mkdir $NODE_MSP_PATH/cacerts && sudo cp -r ../fabric-ca/$org/int/clients/$node/msp/cacerts/ $NODE_MSP_PATH/cacerts/
    mkdir $NODE_MSP_PATH/intermediatecerts && sudo cp -r ../fabric-ca/$org/int/clients/$node/msp/intermediatecerts/ $NODE_MSP_PATH/intermediatecerts/
    mkdir $NODE_MSP_PATH/tlscacerts && sudo cp -r ../fabric-ca/$org/tls-int/clients/$node/msp/cacerts/ $NODE_MSP_PATH/tlscacerts/
    mkdir $NODE_MSP_PATH/tlsintermediatecerts && sudo cp -r ../fabric-ca/$org/tls-int/clients/$node/msp/intermediatecerts/ $NODE_MSP_PATH/tlsintermediatecerts/
    mkdir $NODE_MSP_PATH/signcerts && sudo cp -r ../fabric-ca/$org/int/clients/$node/msp/signcerts/ $NODE_MSP_PATH/signcerts/
    mkdir $NODE_MSP_PATH/keystore && sudo cp -r ../fabric-ca/$org/int/clients/$node/msp/keystore/ $NODE_MSP_PATH/keystore/
}

function createTLSFolder(){
    org=$1
    node=$2
    type=$3

    NODE_TLS_PATH=../fabric-ca/$org/peers/$node/tls
    if test "$type" = "orderer"
    then
        NODE_TLS_PATH=../fabric-ca/$org/orderers/$node/tls
    fi
    mkdir -p $NODE_TLS_PATH
    sudo cp ../fabric-ca/$org/tls-root/ca-cert.pem $NODE_TLS_PATH/ca.crt
    sudo cp ../fabric-ca/$org/tls-int/clients/$node/msp/signcerts/cert.pem $NODE_TLS_PATH/server.crt
    key=$(sudo find ../fabric-ca/$org/tls-int/clients/$node/msp/keystore -name *_sk)
    sudo cp $key $NODE_TLS_PATH/server.key
}

createChannelMSP org1.acme.org
createChannelMSP org2.acme.org
createChannelMSP org3.acme.org
createChannelMSP acme.org

createLocalMSP org1.acme.org peer0.org1.acme.org peer
createLocalMSP org2.acme.org peer0.org2.acme.org peer
createLocalMSP org3.acme.org peer0.org3.acme.org peer
createLocalMSP acme.org orderer.acme.org orderer

createTLSFolder org1.acme.org peer0.org1.acme.org peer
createTLSFolder org2.acme.org peer0.org2.acme.org peer
createTLSFolder org3.acme.org peer0.org3.acme.org peer
createTLSFolder acme.org orderer.acme.org orderer
