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

var (
	// TrustlineDocType is the Document type a trustline will be stored under in the World State
	TrustlineDocType = "TL"
	// RedeemPrivateDataDocType is the Document type the private data of a redeem transaction will be stored under in the World State
	RedeemPrivateDataDocType = "REDEEM"
	// MintPrivateDataDocType is the Document type the private data of a minting transaction will be stored under in the World State
	MintPrivateDataDocType = "MINT"
)

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
	err = PutState(stub, TrustlineDocType, key, tl)
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

// CheckCurrencyTrustline is a function that will return an error if a trustline doesn't exist or if it is set to false, meaning the receiver doesn't trust the issuer
func CheckCurrencyTrustline(stub shim.ChaincodeStubInterface, currencyCode string, receiver string, issuer string) (err error) {
	tl, err := GetCurrencyTrustline(stub, currencyCode, receiver, issuer)
	if err == ErrStateNotFound {
		err = marketplace.ErrTransferTrustline
		return
	}
	if err != nil {
		return
	}
	if !tl.Trust {
		err = marketplace.ErrTransferTrustline
		return
	}
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

// PutRedeemPrivateData is a function to store private data linked to a redeem request
func PutRedeemPrivateData(stub shim.ChaincodeStubInterface, transient map[string][]byte, dataReceiver string, utxoID string) (err error) {
	var accountNumber, bank, salt string
	err = GetTransientDataValue(stub, transient, "accountNumber", &accountNumber)
	if err != nil {
		return
	}
	err = GetTransientDataValue(stub, transient, "bank", &bank)
	if err != nil {
		return
	}
	err = GetTransientDataValue(stub, transient, "salt", &salt)
	if err != nil {
		return
	}

	key, err := stub.CreateCompositeKey(RedeemPrivateDataDocType, []string{stub.GetTxID(), salt})
	if err != nil {
		return
	}
	err = PutPrivateData(stub, ImplicitCollectionPrefix+dataReceiver, RedeemPrivateDataDocType, key, marketplace.RedeemPrivateData{
		UtxoID:        utxoID,
		AccountNumber: accountNumber,
		Bank:          bank,
	})

	return
}

// PutMintPrivateData is a function to store private data linked to a minting transaction
func PutMintPrivateData(stub shim.ChaincodeStubInterface, transient map[string][]byte, currencyCode string) (err error) {
	var mintPrivateData interface{}
	err = GetTransientDataValue(stub, transient, "mintPrivateData", &mintPrivateData)
	if err != nil {
		return
	}
	key, err := stub.CreateCompositeKey(MintPrivateDataDocType, []string{stub.GetTxID()})
	if err != nil {
		return
	}
	err = PutPrivateData(stub, currencyCode+"Auditors", MintPrivateDataDocType, key, transient)
	return
}
