function cleanCA(){
    org=$1
    ca=$2

    CA_PATH=../fabric-ca/$org/$ca
    rm -r $CA_PATH/clients
    rm -r $CA_PATH/msp
    rm $CA_PATH/ca-cert.pem
    rm $CA_PATH/fabric-ca-server.db
    rm $CA_PATH/IssuerPublicKey
    rm $CA_PATH/IssuerRevocationPublicKey
    CA_CHAIN_FILE=$CA_PATH/ca-chain.pem
    if test -f "$CA_CHAIN_FILE"; then
        rm $CA_CHAIN_FILE
    fi
}

function cleanOrgMSP() {
    org=$1

    MSP_PATH=../fabric-ca/$org/msp
    rm -r $MSP_PATH/cacerts
    rm -r $MSP_PATH/intermediatecerts
    rm -r $MSP_PATH/tlscacerts
    rm -r $MSP_PATH/tlsintermediatecerts
}

function cleanLocalMSP() {
    org=$1
    name=$2
    type=$3

    LOCAL_MSP_PATH=../fabric-ca/$org/${type}s/$name/msp
    TLS_FOLDER_PATH=../fabric-ca/$org/${type}s/$name/tls

    rm -r $LOCAL_MSP_PATH
    rm -r $TLS_FOLDER_PATH
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

cleanLocalMSP org1.acme.com peer0.org1.acme.com peer
cleanLocalMSP org2.acme.com peer0.org2.acme.com peer
cleanLocalMSP org3.acme.com peer0.org3.acme.com peer
cleanLocalMSP acme.com orderer.acme.com orderer

cleanLocalMSP org1.acme.com admin@org1.acme.com user
cleanLocalMSP org2.acme.com admin@org2.acme.com user
cleanLocalMSP org3.acme.com admin@org3.acme.com user
cleanLocalMSP acme.com admin@acme.com user
