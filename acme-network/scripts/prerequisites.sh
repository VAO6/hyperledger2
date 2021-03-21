# You should have Docker, Docker-compose and Golang installed to be able to run the other scripts.
# Also the following Fabric tools are needed since the scripts do not use the cli container
sudo apt install gcc
go get -u github.com/hyperledger/fabric/cmd/configtxgen
go get -u github.com/hyperledger/fabric/cmd/configtxlator
go get -u github.com/hyperledger/fabric/cmd/peer
go get -u github.com/hyperledger/fabric-ca/cmd/fabric-ca-client
# You can execute the following export and also add it to your $HOME/.profile (you should have your GOPATH set)
export PATH=$PATH:$GOPATH/bin
