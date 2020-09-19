export FABRIC_CFG_PATH=$(cd ../../acme-network && pwd)
export CC_NAME=foodmarketplace
export CC_VERSION=v1.0
export CC_SEQUENCE=1
export CHANNEL_NAME=marketplace
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_ADDRESS=localhost:7051
export CORE_PEER_LOCALMSPID=Org1MSP
export CORE_PEER_TLS_ROOTCERT_FILE=$(cd ../../acme-network && echo $PWD/fabric-ca/org1.acme.com/peers/peer0.org1.acme.com/tls/ca.crt)
export CORE_PEER_MSPCONFIGPATH=$(cd ../../acme-network && echo $PWD/fabric-ca/org1.acme.com/users/admin@org1.acme.com/msp)
export ORDERER_CA=$(cd ../../acme-network && echo $PWD/fabric-ca/org1.acme.com/orderers/orderer.org1.acme.com/tls/ca.crt)
export ORDERER_ADDRESS=localhost:7050
peer lifecycle chaincode package ../../acme-network/channel-artifacts/$CC_NAME$CC_VERSION.tar.gz --path . --lang golang --label $CC_NAME$CC_VERSION
peer lifecycle chaincode install ../../acme-network/channel-artifacts/$CC_NAME$CC_VERSION.tar.gz --peerAddresses $CORE_PEER_ADDRESS --tls $CORE_PEER_TLS_ENABLED --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE

export CC_PACKAGE_ID=
peer lifecycle chaincode approveformyorg -o $ORDERER_ADDRESS --tls --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name $CC_NAME --version $CC_VERSION --package-id $CC_PACKAGE_ID --sequence $CC_SEQUENCE --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --peerAddresses $CORE_PEER_ADDRESS --collections-config collections.json --signature-policy "OUTOF(2, 'Org1MSP.peer','Org2MSP.peer','Org3MSP.peer')"

export CORE_PEER_ADDRESS=localhost:8051
export CORE_PEER_LOCALMSPID=Org2MSP
export CORE_PEER_TLS_ROOTCERT_FILE=$(cd ../../acme-network && echo $PWD/fabric-ca/org2.acme.com/peers/peer0.org2.acme.com/tls/ca.crt)
export CORE_PEER_MSPCONFIGPATH=$(cd ../../acme-network && echo $PWD/fabric-ca/org2.acme.com/users/admin@org2.acme.com/msp)
export ORDERER_CA=$(cd ../../acme-network && echo $PWD/fabric-ca/org2.acme.com/orderers/orderer.org2.acme.com/tls/ca.crt)
export ORDERER_ADDRESS=localhost:8050
peer lifecycle chaincode install ../../acme-network/channel-artifacts/$CC_NAME$CC_VERSION.tar.gz --peerAddresses $CORE_PEER_ADDRESS --tls $CORE_PEER_TLS_ENABLED --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE
peer lifecycle chaincode approveformyorg -o $ORDERER_ADDRESS --tls --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name $CC_NAME --version $CC_VERSION --package-id $CC_PACKAGE_ID --sequence $CC_SEQUENCE --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --peerAddresses $CORE_PEER_ADDRESS --collections-config collections.json --signature-policy "OUTOF(2, 'Org1MSP.peer','Org2MSP.peer','Org3MSP.peer')"

export CORE_PEER_ADDRESS=localhost:9051
export CORE_PEER_LOCALMSPID=Org3MSP
export CORE_PEER_TLS_ROOTCERT_FILE=$(cd ../../acme-network && echo $PWD/fabric-ca/org3.acme.com/peers/peer0.org3.acme.com/tls/ca.crt)
export CORE_PEER_MSPCONFIGPATH=$(cd ../../acme-network && echo $PWD/fabric-ca/org3.acme.com/users/admin@org3.acme.com/msp)
export ORDERER_CA=$(cd ../../acme-network && echo $PWD/fabric-ca/org3.acme.com/orderers/orderer.org3.acme.com/tls/ca.crt)
export ORDERER_ADDRESS=localhost:9050
peer lifecycle chaincode install ../../acme-network/channel-artifacts/$CC_NAME$CC_VERSION.tar.gz --peerAddresses $CORE_PEER_ADDRESS --tls $CORE_PEER_TLS_ENABLED --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE
peer lifecycle chaincode approveformyorg -o $ORDERER_ADDRESS --tls --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name $CC_NAME --version $CC_VERSION --package-id $CC_PACKAGE_ID --sequence $CC_SEQUENCE --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --peerAddresses $CORE_PEER_ADDRESS --collections-config collections.json --signature-policy "OUTOF(2, 'Org1MSP.peer','Org2MSP.peer','Org3MSP.peer')"
peer lifecycle chaincode commit -o $ORDERER_ADDRESS --channelID $CHANNEL_NAME --name $CC_NAME --version $CC_VERSION --sequence $CC_SEQUENCE --tls --cafile $ORDERER_CA --peerAddresses $CORE_PEER_ADDRESS --peerAddresses localhost:7051 --peerAddresses localhost:8051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --tlsRootCertFiles $(cd ../../acme-network && echo $PWD/fabric-ca/org1.acme.com/peers/peer0.org1.acme.com/tls/ca.crt) --tlsRootCertFiles $(cd ../../acme-network && echo $PWD/fabric-ca/org2.acme.com/peers/peer0.org2.acme.com/tls/ca.crt)  --collections-config collections.json --signature-policy "OUTOF(2, 'Org1MSP.peer','Org2MSP.peer','Org3MSP.peer')"

# Set user with permissions to interact with the chaincode
export CORE_PEER_MSPCONFIGPATH=$(cd ../../acme-network && echo $PWD/fabric-ca/org3.acme.com/users/client@org3.acme.com/msp)
# MINT
export DATA=$(echo -n "{\"depositReference\":\"ABC1234567\",\"bank\":\"Bancolombia\"}" | base64 | tr -d \\n)
peer chaincode invoke -o $ORDERER_ADDRESS --tls --cafile $ORDERER_CA -C $CHANNEL_NAME -n $CC_NAME -c '{ "Args": ["USDCurrencyContract:Mint", "5000", "Org3MSP"] }' --peerAddresses $CORE_PEER_ADDRESS --peerAddresses localhost:8051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --tlsRootCertFiles $(cd ../../acme-network && echo $PWD/fabric-ca/org2.acme.com/peers/peer0.org2.acme.com/tls/ca.crt) --transient "{\"mintPrivateData\":\"$DATA\"}"
# TRANSFER
peer chaincode invoke -o $ORDERER_ADDRESS --tls --cafile $ORDERER_CA -C $CHANNEL_NAME -n $CC_NAME -c '{ "Args": ["USDCurrencyContract:Transfer", "[\"094f64efff9d3788c91807fa9f3ccbd10f4779242c5103e3ce1748f6d07413de:0\"]", "1000", "Org3MSP"] }' --peerAddresses $CORE_PEER_ADDRESS --peerAddresses localhost:8051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --tlsRootCertFiles $(cd ../../acme-network && echo $PWD/fabric-ca/org2.acme.com/peers/peer0.org2.acme.com/tls/ca.crt)
# Change org and user
export CORE_PEER_MSPCONFIGPATH=$(cd ../../acme-network && echo $PWD/fabric-ca/org2.acme.com/users/client@org2.acme.com/msp)
export CORE_PEER_LOCALMSPID=Org2MSP
# SET TRUSTLINE
peer chaincode invoke -o $ORDERER_ADDRESS --tls --cafile $ORDERER_CA -C $CHANNEL_NAME -n $CC_NAME -c '{ "Args": ["COPCurrencyContract:SetTrustline", "Org3MSP", "true", "-1"] }' --peerAddresses $CORE_PEER_ADDRESS --peerAddresses localhost:8051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --tlsRootCertFiles $(cd ../../acme-network && echo $PWD/fabric-ca/org2.acme.com/peers/peer0.org2.acme.com/tls/ca.crt)
# REDEEM
export ACCOUNTNUMBER=$(echo -n "\"123-45678-90TszpOwQUjK?9K=Tk3z#jQQ4VV:SA=P26\"" | base64 | tr -d \\n)
export BANK=$(echo -n "\"BancolombiaTszpOwQUjK?9K=Tk3z#jQQ4VV:SA=P26\"" | base64 | tr -d \\n)
export SALT=$(echo -n "\"TszpOwQUjK?9K=Tk3z#jQQ4VV:SA=P26\"" | base64 | tr -d \\n)
peer chaincode invoke -o $ORDERER_ADDRESS --tls --cafile $ORDERER_CA -C $CHANNEL_NAME -n $CC_NAME -c '{ "Args": ["USDCurrencyContract:Redeem", "63fd3dd5ba2a9f0fd5d70d895cb9f89420db2e923460488325eab911c71e9c69:0"] }' --peerAddresses $CORE_PEER_ADDRESS --peerAddresses localhost:8051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --tlsRootCertFiles $(cd ../../acme-network && echo $PWD/fabric-ca/org2.acme.com/peers/peer0.org2.acme.com/tls/ca.crt) --transient "{\"accountNumber\":\"$ACCOUNTNUMBER\",\"bank\":\"$BANK\",\"salt\":\"$SALT\"}"
# QUERY COUCHDB
peer chaincode invoke -o $ORDERER_ADDRESS --tls --cafile $ORDERER_CA -C $CHANNEL_NAME -n $CC_NAME -c '{ "Args": ["COPCurrencyContract:QueryCouchDB", "{\"selector\":{\"docType\":\"COP\"}}"] }' --peerAddresses $CORE_PEER_ADDRESS --peerAddresses localhost:8051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --tlsRootCertFiles $(cd ../../acme-network && echo $PWD/fabric-ca/org2.acme.com/peers/peer0.org2.acme.com/tls/ca.crt)
# GET HISTORY OF UTXO
peer chaincode invoke -o $ORDERER_ADDRESS --tls --cafile $ORDERER_CA -C $CHANNEL_NAME -n $CC_NAME -c '{ "Args": ["COPCurrencyContract:GetHistoryOfUTXO", "2e30eca2dc3af671980f617aae974ed5ad9d2820efd7da47343773944088689b:0"] }' --peerAddresses $CORE_PEER_ADDRESS --peerAddresses localhost:8051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --tlsRootCertFiles $(cd ../../acme-network && echo $PWD/fabric-ca/org2.acme.com/peers/peer0.org2.acme.com/tls/ca.crt)
