function generateAnchorConfigurationTx() {
    msp=$1
    configtxgen -outputAnchorPeersUpdate ../channel-artifacts/${msp}anchors.tx -profile ThreeOrgsChannel -asOrg $msp -channelID marketplace
}

which configtxgen
if [ "$?" -ne 0 ]; then
    echo "configtxgen tool not found. exiting"
    exit 1
fi
export FABRIC_CFG_PATH=$(cd ../ && pwd)
configtxgen -profile ThreeOrgsOrdererGenesis -channelID system-channel -outputBlock ../channel-artifacts/genesis.block
configtxgen -profile ThreeOrgsChannel -outputCreateChannelTx ../channel-artifacts/channel.tx -channelID marketplace
generateAnchorConfigurationTx Org1MSP
generateAnchorConfigurationTx Org2MSP
generateAnchorConfigurationTx Org3MSP

