export FABRIC_CFG_PATH=$(cd ../ && pwd)
export CC_NAME=foodmarketplace
export CC_VERSION=v1.0
export CC_SEQUENCE=3
export CHANNEL_NAME=marketplace
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_ADDRESS=localhost:7051
export CORE_PEER_LOCALMSPID=Org1MSP
export CORE_PEER_TLS_ROOTCERT_FILE=$(cd ../ && echo $PWD/fabric-ca/org1.acme.com/peers/peer0.org1.acme.com/tls/ca.crt)
export CORE_PEER_MSPCONFIGPATH=$(cd ../ && echo $PWD/fabric-ca/org1.acme.com/users/admin@org1.acme.com/msp)
export ORDERER_CA=$(cd ../ && echo $PWD/fabric-ca/org1.acme.com/orderers/orderer.org1.acme.com/tls/ca.crt)
export ORDERER_ADDRESS=localhost:7050
peer lifecycle chaincode package ../channel-artifacts/$CC_NAME$CC_VERSION.tar.gz --path ../../chaincode/foodcontrol --lang golang --label $CC_NAME$CC_VERSION
peer lifecycle chaincode install ../channel-artifacts/$CC_NAME$CC_VERSION.tar.gz --peerAddresses $CORE_PEER_ADDRESS --tls $CORE_PEER_TLS_ENABLED --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE

export CC_PACKAGE_ID=foodmarketplacev1.0:b1aa47d678c16d778e00a9a4f08034cb9cbb604a0b694118c47868f4a38dd4a0
peer lifecycle chaincode approveformyorg -o $ORDERER_ADDRESS --tls --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name $CC_NAME --version $CC_VERSION --package-id $CC_PACKAGE_ID --sequence $CC_SEQUENCE --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --peerAddresses $CORE_PEER_ADDRESS

export CORE_PEER_ADDRESS=localhost:8051
export CORE_PEER_LOCALMSPID=Org2MSP
export CORE_PEER_TLS_ROOTCERT_FILE=$(cd ../ && echo $PWD/fabric-ca/org2.acme.com/peers/peer0.org2.acme.com/tls/ca.crt)
export CORE_PEER_MSPCONFIGPATH=$(cd ../ && echo $PWD/fabric-ca/org2.acme.com/users/admin@org2.acme.com/msp)
export ORDERER_CA=$(cd ../ && echo $PWD/fabric-ca/org2.acme.com/orderers/orderer.org2.acme.com/tls/ca.crt)
export ORDERER_ADDRESS=localhost:8050
peer lifecycle chaincode install ../channel-artifacts/$CC_NAME$CC_VERSION.tar.gz --peerAddresses $CORE_PEER_ADDRESS --tls $CORE_PEER_TLS_ENABLED --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE
peer lifecycle chaincode approveformyorg -o $ORDERER_ADDRESS --tls --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name $CC_NAME --version $CC_VERSION --package-id $CC_PACKAGE_ID --sequence $CC_SEQUENCE --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --peerAddresses $CORE_PEER_ADDRESS

export CORE_PEER_ADDRESS=localhost:9051
export CORE_PEER_LOCALMSPID=Org3MSP
export CORE_PEER_TLS_ROOTCERT_FILE=$(cd ../ && echo $PWD/fabric-ca/org3.acme.com/peers/peer0.org3.acme.com/tls/ca.crt)
export CORE_PEER_MSPCONFIGPATH=$(cd ../ && echo $PWD/fabric-ca/org3.acme.com/users/admin@org3.acme.com/msp)
export ORDERER_CA=$(cd ../ && echo $PWD/fabric-ca/org3.acme.com/orderers/orderer.org3.acme.com/tls/ca.crt)
export ORDERER_ADDRESS=localhost:9050
peer lifecycle chaincode install ../channel-artifacts/$CC_NAME$CC_VERSION.tar.gz --peerAddresses $CORE_PEER_ADDRESS --tls $CORE_PEER_TLS_ENABLED --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE
peer lifecycle chaincode approveformyorg -o $ORDERER_ADDRESS --tls --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name $CC_NAME --version $CC_VERSION --package-id $CC_PACKAGE_ID --sequence $CC_SEQUENCE --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --peerAddresses $CORE_PEER_ADDRESS
peer lifecycle chaincode commit -o $ORDERER_ADDRESS --channelID $CHANNEL_NAME --name $CC_NAME --version $CC_VERSION --sequence $CC_SEQUENCE --tls --cafile $ORDERER_CA --peerAddresses $CORE_PEER_ADDRESS --peerAddresses localhost:7051 --peerAddresses localhost:8051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --tlsRootCertFiles $(cd ../ && echo $PWD/fabric-ca/org1.acme.com/peers/peer0.org1.acme.com/tls/ca.crt) --tlsRootCertFiles $(cd ../ && echo $PWD/fabric-ca/org2.acme.com/peers/peer0.org2.acme.com/tls/ca.crt)

export CORE_PEER_MSPCONFIGPATH=$(cd ../ && echo $PWD/fabric-ca/org3.acme.com/users/client@org3.acme.com/msp)
peer chaincode invoke -o $ORDERER_ADDRESS --tls --cafile $ORDERER_CA -C $CHANNEL_NAME -n $CC_NAME -c '{ "Args": ["COPCurrencyContract:Mint", "99000", "Org3MSP"] }' --peerAddresses $CORE_PEER_ADDRESS --peerAddresses localhost:8051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --tlsRootCertFiles $(cd ../ && echo $PWD/fabric-ca/org2.acme.com/peers/peer0.org2.acme.com/tls/ca.crt)
peer chaincode invoke -o $ORDERER_ADDRESS --tls --cafile $ORDERER_CA -C $CHANNEL_NAME -n $CC_NAME -c '{ "Args": ["COPCurrencyContract:Transfer", "[\"a3bf0fa16e756c5da70f0855124a368bb6f04de510c27a1866b2fc8632591c97:1\",\"d21b323fbffcdde5fdcddb36f6adcee350e72276b0f84d8220c464243848dd20:0\"]", "10900000", "Org2MSP"] }' --peerAddresses $CORE_PEER_ADDRESS --peerAddresses localhost:8051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --tlsRootCertFiles $(cd ../ && echo $PWD/fabric-ca/org2.acme.com/peers/peer0.org2.acme.com/tls/ca.crt)
export CORE_PEER_MSPCONFIGPATH=$(cd ../ && echo $PWD/fabric-ca/org2.acme.com/users/client@org2.acme.com/msp)
export CORE_PEER_LOCALMSPID=Org2MSP
peer chaincode invoke -o $ORDERER_ADDRESS --tls --cafile $ORDERER_CA -C $CHANNEL_NAME -n $CC_NAME -c '{ "Args": ["COPCurrencyContract:SetTrustline", "Org3MSP", "true", "-1"] }' --peerAddresses $CORE_PEER_ADDRESS --peerAddresses localhost:8051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --tlsRootCertFiles $(cd ../ && echo $PWD/fabric-ca/org2.acme.com/peers/peer0.org2.acme.com/tls/ca.crt)

peer chaincode invoke -o $ORDERER_ADDRESS --tls --cafile $ORDERER_CA -C $CHANNEL_NAME -n $CC_NAME -c '{ "Args": ["COPCurrencyContract:RequestRedemption", "fbaa859c200bcc6334902eb3ef78f14be70c63b55a0b1038d47acc0bddcdc5c9:0"] }' --peerAddresses $CORE_PEER_ADDRESS --peerAddresses localhost:8051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --tlsRootCertFiles $(cd ../ && echo $PWD/fabric-ca/org2.acme.com/peers/peer0.org2.acme.com/tls/ca.crt)
peer chaincode invoke -o $ORDERER_ADDRESS --tls --cafile $ORDERER_CA -C $CHANNEL_NAME -n $CC_NAME -c '{ "Args": ["COPCurrencyContract:Transfer", "[\"fbaa859c200bcc6334902eb3ef78f14be70c63b55a0b1038d47acc0bddcdc5c9:1\"]", "9000", "Org2MSP"] }' --peerAddresses $CORE_PEER_ADDRESS --peerAddresses localhost:8051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --tlsRootCertFiles $(cd ../ && echo $PWD/fabric-ca/org2.acme.com/peers/peer0.org2.acme.com/tls/ca.crt)
peer chaincode invoke -o $ORDERER_ADDRESS --tls --cafile $ORDERER_CA -C $CHANNEL_NAME -n $CC_NAME -c '{ "Args": ["COPCurrencyContract:ConfirmRedemption", "fbaa859c200bcc6334902eb3ef78f14be70c63b55a0b1038d47acc0bddcdc5c9:0"] }' --peerAddresses $CORE_PEER_ADDRESS --peerAddresses localhost:8051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --tlsRootCertFiles $(cd ../ && echo $PWD/fabric-ca/org2.acme.com/peers/peer0.org2.acme.com/tls/ca.crt)

peer chaincode invoke -o $ORDERER_ADDRESS --tls --cafile $ORDERER_CA -C $CHANNEL_NAME -n $CC_NAME -c '{ "Args": ["COPCurrencyContract:QueryCouchDB", "{\"selector\":{\"docType\":\"COP\"}}"] }' --peerAddresses $CORE_PEER_ADDRESS --peerAddresses localhost:8051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --tlsRootCertFiles $(cd ../ && echo $PWD/fabric-ca/org2.acme.com/peers/peer0.org2.acme.com/tls/ca.crt)
peer chaincode invoke -o $ORDERER_ADDRESS --tls --cafile $ORDERER_CA -C $CHANNEL_NAME -n $CC_NAME -c '{ "Args": ["COPCurrencyContract:GetHistoryOfUTXO", "fbaa859c200bcc6334902eb3ef78f14be70c63b55a0b1038d47acc0bddcdc5c9:0"] }' --peerAddresses $CORE_PEER_ADDRESS --peerAddresses localhost:8051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE --tlsRootCertFiles $(cd ../ && echo $PWD/fabric-ca/org2.acme.com/peers/peer0.org2.acme.com/tls/ca.crt)
