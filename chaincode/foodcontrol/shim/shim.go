package shim

import (
	"encoding/json"
	"errors"

	"github.com/hyperledger/fabric-chaincode-go/shim"
	"github.com/hyperledger/fabric-protos-go/ledger/queryresult"
)

var (
	// ErrStateNotFound is an error that is thrown when a value is not found for a key in the World State
	ErrStateNotFound = errors.New("State was not found")
)

type state struct {
	DocType string `json:"docType"`
	Object  interface{}
}

// GetState is a function to get data from the World State
func GetState(stub shim.ChaincodeStubInterface, key string, v interface{}) (err error) {
	bytes, err := stub.GetState(key)
	if err != nil {
		return
	}
	if bytes == nil {
		err = ErrStateNotFound
		return
	}

	err = json.Unmarshal(bytes, v)
	return
}

// PutState is a function to store data in the World State
func PutState(stub shim.ChaincodeStubInterface, docType string, key string, v interface{}) (err error) {
	state := state{
		docType,
		v,
	}

	value, err := json.Marshal(&state)
	if err != nil {
		return
	}

	err = stub.PutState(key, value)
	return
}

// SetEvent is a function to add an event emission at the time of the transaction commit
func SetEvent(stub shim.ChaincodeStubInterface, event string, payload interface{}) (err error) {
	payloadBytes, err := json.Marshal(payload)
	if err != nil {
		return
	}

	err = stub.SetEvent(event, payloadBytes)
	return
}

// Any returns true as long as any one of the query results in the iterator satisfies the predicate condition
func Any(it shim.StateQueryIteratorInterface, predicate func([]byte) (bool, error)) (isAny bool, err error) {
	for it.HasNext() {
		var result *queryresult.KV
		result, err = it.Next()
		if err != nil {
			return
		}
		isAny, err = predicate(result.GetValue())
		if err != nil || isAny {
			return
		}
	}
	return
}
