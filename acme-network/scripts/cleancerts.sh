function cleanCA(){
    org=$1
    ca=$2

    CA_PATH=../fabric-ca/$org/$ca
    sudo rm -r $CA_PATH/clients
    sudo rm -r $CA_PATH/msp
    sudo rm $CA_PATH/ca-cert.pem
    sudo rm $CA_PATH/fabric-ca-server.db
    sudo rm $CA_PATH/IssuerPublicKey
    sudo rm $CA_PATH/IssuerRevocationPublicKey
    CA_CHAIN_FILE=$CA_PATH/ca-chain.pem
    if test -f "$CA_CHAIN_FILE"; then
        sudo rm $CA_CHAIN_FILE
    fi
}

function cleanOrgMSP() {
    org=$1

    MSP_PATH=../fabric-ca/$org/msp
    sudo rm -r $MSP_PATH/cacerts
    sudo rm -r $MSP_PATH/intermediatecerts
    sudo rm -r $MSP_PATH/tlscacerts
    sudo rm -r $MSP_PATH/tlsintermediatecerts
}

function cleanNode() {
    org=$1
    node=$2
    type=$3

    NODE_MSP_PATH=../fabric-ca/$org/${type}s/$node/msp
    #if test "$type" = "orderer"
    #then
    #    NODE_MSP_PATH=../fabric-ca/$org/orderers/$node/msp
    #fi
    NODE_TLS_PATH=../fabric-ca/$org/${type}s/$node/tls
    #if test "$type" = "orderer"
    #then
    #    NODE_TLS_PATH=../fabric-ca/$org/orderers/$node/tls
    #fi
    sudo rm -r $NODE_MSP_PATH
    sudo rm -r $NODE_TLS_PATH
}

cleanCA acme.com root
cleanCA acme.com int
cleanCA acme.com tls-root
cleanCA acme.com tls-int
cleanCA org1.acme.com root
cleanCA org1.acme.com int
cleanCA org1.acme.com tls-root
cleanCA org1.acme.com tls-int
cleanCA org2.acme.com root
cleanCA org2.acme.com int
cleanCA org2.acme.com tls-root
cleanCA org2.acme.com tls-int
cleanCA org3.acme.com root
cleanCA org3.acme.com int
cleanCA org3.acme.com tls-root
cleanCA org3.acme.com tls-int

cleanOrgMSP org1.acme.com
cleanOrgMSP org2.acme.com
cleanOrgMSP org3.acme.com
cleanOrgMSP acme.com

cleanNode org1.acme.com peer0.org1.acme.com peer
cleanNode org2.acme.com peer0.org2.acme.com peer
cleanNode org3.acme.com peer0.org3.acme.com peer
cleanNode acme.com orderer.acme.com orderer
