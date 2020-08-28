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

cleanCA acme.org root
cleanCA acme.org int
cleanCA acme.org tls-root
cleanCA acme.org tls-int
cleanCA org1.acme.org root
cleanCA org1.acme.org int
cleanCA org1.acme.org tls-root
cleanCA org1.acme.org tls-int
cleanCA org2.acme.org root
cleanCA org2.acme.org int
cleanCA org2.acme.org tls-root
cleanCA org2.acme.org tls-int
cleanCA org3.acme.org root
cleanCA org3.acme.org int
cleanCA org3.acme.org tls-root
cleanCA org3.acme.org tls-int
