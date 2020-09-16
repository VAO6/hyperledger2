package shim

import (
	"github.com/braduf/curso-hyperledger-fabric/chaincode/foodcontrol/marketplace"
	"github.com/hyperledger/fabric-chaincode-go/shim"
)

// CurrencyUTXOState represents a CurrencyUTXO on the World State
type CurrencyUTXOState struct {
	DocType string `json:"docType"`
	Value   marketplace.CurrencyUTXO
}

// CurrencyTrustlineState represents a Trustline on the World State
type CurrencyTrustlineState struct {
	DocType string `json:"docType"`
	Value   marketplace.CurrencyTrustline
}

// TrustlineDocType is the Document type a trustline will be stored under in the World State
var TrustlineDocType = "TL"

// PutCurrencyUTXO stores a UTXO as a state in the World State
func PutCurrencyUTXO(stub shim.ChaincodeStubInterface, currencyCode string, utxo marketplace.CurrencyUTXO) (err error) {
	key, err := stub.CreateCompositeKey(currencyCode, []string{utxo.ID})
	if err != nil {
		return
	}
	err = PutState(stub, currencyCode, key, utxo)
	return
}

// PutCurrencyTrustline stores a trustline as a state in the World State
func PutCurrencyTrustline(stub shim.ChaincodeStubInterface, currencyCode string, tl marketplace.CurrencyTrustline) (err error) {
	key, err := stub.CreateCompositeKey(TrustlineDocType, []string{currencyCode, tl.Receiver, tl.Issuer})
	if err != nil {
		return
	}
	err = PutState(stub, currencyCode, key, tl)
	return
}

// DeleteCurrencyUTXO deletes a UTXO from the World State
func DeleteCurrencyUTXO(stub shim.ChaincodeStubInterface, currencyCode string, id string) (err error) {
	key, err := stub.CreateCompositeKey(currencyCode, []string{id})
	if err != nil {
		return
	}
	err = DelState(stub, key)
	return
}

// GetCurrencyUTXOByID retrieves the UTXO with id from the World State
func GetCurrencyUTXOByID(stub shim.ChaincodeStubInterface, currencyCode string, id string) (utxo marketplace.CurrencyUTXO, err error) {
	key, err := stub.CreateCompositeKey(currencyCode, []string{id})
	if err != nil {
		return
	}

	var utxoState CurrencyUTXOState
	err = GetState(stub, key, &utxoState)
	if err != nil {
		return
	}
	utxo = utxoState.Value
	return
}

// GetCurrencyTrustline retrieves a trustline from the World State
func GetCurrencyTrustline(stub shim.ChaincodeStubInterface, currencyCode string, receiver string, issuer string) (tl marketplace.CurrencyTrustline, err error) {
	key, err := stub.CreateCompositeKey(TrustlineDocType, []string{currencyCode, receiver, issuer})
	if err != nil {
		return
	}

	var tlState CurrencyTrustlineState
	err = GetState(stub, key, &tlState)
	if err != nil {
		return
	}
	tl = tlState.Value
	return
}

// GetHistoryForCurrencyUTXOID retrieves all state changes a UTXO with the specified ID has gone through
func GetHistoryForCurrencyUTXOID(stub shim.ChaincodeStubInterface, currencyCode string, id string) (historyJSONString string, err error) {
	key, err := stub.CreateCompositeKey(currencyCode, []string{id})
	if err != nil {
		return
	}

	historyBuffer, err := GetHistoryForKey(stub, key)
	if err != nil {
		return
	}
	historyJSONString = string(historyBuffer.Bytes())

	return
}

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
