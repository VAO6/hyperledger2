function createChannelMSP() {
    org=$1

    MSP_PATH=../fabric-ca/$org/msp
    mkdir -p $MSP_PATH
    mkdir $MSP_PATH/cacerts && cp ../fabric-ca/$org/root/ca-cert.pem $MSP_PATH/cacerts/ca-cert.pem
    mkdir $MSP_PATH/intermediatecerts && cp ../fabric-ca/$org/int/ca-cert.pem $MSP_PATH/intermediatecerts/ca-cert.pem
    mkdir $MSP_PATH/tlscacerts && cp ../fabric-ca/$org/tls-root/ca-cert.pem $MSP_PATH/tlscacerts/ca-cert.pem
    mkdir $MSP_PATH/tlsintermediatecerts && cp ../fabric-ca/$org/tls-int/ca-cert.pem $MSP_PATH/tlsintermediatecerts/ca-cert.pem
}

function createLocalMSP() {
    org=$1
    name=$2
    type=$3

    LOCAL_MSP_PATH=../fabric-ca/$org/${type}s/$name/msp

    mkdir -p $LOCAL_MSP_PATH
    cp ../fabric-ca/$org/msp/config.yaml $LOCAL_MSP_PATH
    mkdir $LOCAL_MSP_PATH/cacerts && cp ../fabric-ca/$org/root/ca-cert.pem $LOCAL_MSP_PATH/cacerts/ca-cert.pem
    mkdir $LOCAL_MSP_PATH/intermediatecerts && cp ../fabric-ca/$org/int/ca-cert.pem $LOCAL_MSP_PATH/intermediatecerts/ca-cert.pem
    mkdir $LOCAL_MSP_PATH/tlscacerts && cp ../fabric-ca/$org/tls-root/ca-cert.pem $LOCAL_MSP_PATH/tlscacerts/ca-cert.pem
    mkdir $LOCAL_MSP_PATH/tlsintermediatecerts && cp ../fabric-ca/$org/tls-int/ca-cert.pem $LOCAL_MSP_PATH/tlsintermediatecerts/ca-cert.pem
    mkdir $LOCAL_MSP_PATH/signcerts && cp -r ../fabric-ca/$org/int/clients/$name/msp/signcerts $LOCAL_MSP_PATH/
    mkdir $LOCAL_MSP_PATH/keystore && cp -r ../fabric-ca/$org/int/clients/$name/msp/keystore $LOCAL_MSP_PATH/
}

function createTLSFolder(){
    org=$1
    name=$2
    type=$3

    TLS_FOLDER_PATH=../fabric-ca/$org/${type}s/$name/tls

    mkdir -p $TLS_FOLDER_PATH
    cp ../fabric-ca/$org/tls-int/ca-chain.pem $TLS_FOLDER_PATH/ca.crt
    cp ../fabric-ca/$org/tls-int/clients/$name/msp/signcerts/cert.pem $TLS_FOLDER_PATH/server.crt
    key=$(find ../fabric-ca/$org/tls-int/clients/$name/msp/keystore -name *_sk)
    cp $key $TLS_FOLDER_PATH/server.key
}

createChannelMSP org1.acme.com
createChannelMSP org2.acme.com
createChannelMSP org3.acme.com
#createChannelMSP acme.com

createLocalMSP org1.acme.com peer0.org1.acme.com peer
createTLSFolder org1.acme.com peer0.org1.acme.com peer

createLocalMSP org2.acme.com peer0.org2.acme.com peer
createTLSFolder org2.acme.com peer0.org2.acme.com peer

createLocalMSP org3.acme.com peer0.org3.acme.com peer
createTLSFolder org3.acme.com peer0.org3.acme.com peer

createLocalMSP org1.acme.com orderer.org1.acme.com orderer
createTLSFolder org1.acme.com orderer.org1.acme.com orderer

createLocalMSP org2.acme.com orderer.org2.acme.com orderer
createTLSFolder org2.acme.com orderer.org2.acme.com orderer

createLocalMSP org3.acme.com orderer.org3.acme.com orderer
createTLSFolder org3.acme.com orderer.org3.acme.com orderer
#createLocalMSP acme.com orderer.acme.com orderer
#createTLSFolder acme.com orderer.acme.com orderer

createLocalMSP org1.acme.com admin@org1.acme.com user
createTLSFolder org1.acme.com admin@org1.acme.com user

createLocalMSP org2.acme.com admin@org2.acme.com user
createTLSFolder org2.acme.com admin@org2.acme.com user

createLocalMSP org3.acme.com admin@org3.acme.com user
createTLSFolder org3.acme.com admin@org3.acme.com user

#createLocalMSP acme.com admin@acme.com user
#createTLSFolder acme.com admin@acme.com user

createLocalMSP org1.acme.com client@org1.acme.com user
createTLSFolder org1.acme.com client@org1.acme.com user

createLocalMSP org2.acme.com client@org2.acme.com user
createTLSFolder org2.acme.com client@org2.acme.com user

createLocalMSP org3.acme.com client@org3.acme.com user
createTLSFolder org3.acme.com client@org3.acme.com user
