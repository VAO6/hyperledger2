package shim

import (
	"github.com/braduf/curso-hyperledger-fabric/chaincode/foodcontrol/marketplace"
	"github.com/hyperledger/fabric-chaincode-go/shim"
)

// SetCurrencyEvent sets an event for the Currency Contract transactions
func SetCurrencyEvent(stub shim.ChaincodeStubInterface, payload interface{}) (err error) {
	funcName, _ := stub.GetFunctionAndParameters()

	event, ok := marketplace.CurrencyEventNames[funcName]
	if !ok {
		// No event should be set for this function
		return
	}
	err = SetEvent(stub, event, payload)
	return
}
