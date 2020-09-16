package shim

import (
	"bytes"
	"encoding/json"
	"errors"
	"strconv"
	"time"

	"github.com/hyperledger/fabric-chaincode-go/shim"
	"github.com/hyperledger/fabric-protos-go/ledger/queryresult"
)

var (
	// ErrStateNotFound is an error that is thrown when a value is not found for a key in the World State
	ErrStateNotFound = errors.New("State was not found")
)

// State represents an entry in the World State
type State struct {
	DocType string `json:"docType"`
	Value   interface{}
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
	state := State{
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

// DelState is a function to delete data from the World State
func DelState(stub shim.ChaincodeStubInterface, key string) (err error) {
	err = stub.DelState(key)
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

// QueryCouchDB is a function to execute rich queries with CouchDB
func QueryCouchDB(stub shim.ChaincodeStubInterface, query string) (queryResultJSONString string, err error) {
	resultsIterator, err := stub.GetQueryResult(query)
	if err != nil {
		return
	}
	defer resultsIterator.Close()

	queryResultBuffer, err := constructQueryResponseFromIterator(resultsIterator)
	if err != nil {
		return
	}
	queryResultJSONString = string(queryResultBuffer.Bytes())

	return
}

// GetHistoryForKey is a function to get the historic values of a specific key of the World State
func GetHistoryForKey(stub shim.ChaincodeStubInterface, key string) (*bytes.Buffer, error) {
	historyIterator, err := stub.GetHistoryForKey(key)
	if err != nil {
		return nil, err
	}
	defer historyIterator.Close()

	// buffer is a JSON array containing historic values for the key
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for historyIterator.HasNext() {
		var response *queryresult.KeyModification
		response, err = historyIterator.Next()
		if err != nil {
			return nil, err
		}
		// Add a comma before array members, suppress it for the first array member
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"TxId\":")
		buffer.WriteString("\"")
		buffer.WriteString(response.TxId)
		buffer.WriteString("\"")

		// If it was a delete operation on a given key, then there is no value on the key anymore.
		// So only write the response.Value as-is when it was not a delete operation.
		if !response.IsDelete {
			buffer.WriteString(", \"Value\":")
			buffer.WriteString(string(response.Value))
		}

		buffer.WriteString(", \"Timestamp\":")
		buffer.WriteString("\"")
		buffer.WriteString(time.Unix(response.Timestamp.Seconds, int64(response.Timestamp.Nanos)).String())
		buffer.WriteString("\"")

		buffer.WriteString(", \"IsDelete\":")
		buffer.WriteString("\"")
		buffer.WriteString(strconv.FormatBool(response.IsDelete))
		buffer.WriteString("\"")

		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	return &buffer, nil
}

func constructQueryResponseFromIterator(it shim.StateQueryIteratorInterface) (*bytes.Buffer, error) {
	// buffer is a JSON array containing QueryResults
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for it.HasNext() {
		queryResponse, err := it.Next()
		if err != nil {
			return nil, err
		}
		// Add a comma before array members, suppress it for the first array member
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		bArrayMemberAlreadyWritten = true

		buffer.WriteString(string(queryResponse.Value))
	}
	buffer.WriteString("]")

	return &buffer, nil
}

// Any returns true as long as any one of the query results in the iterator satisfies the predicate condition
func Any(it shim.StateQueryIteratorInterface, predicate func(*queryresult.KV) (bool, error)) (isAny bool, err error) {
	for it.HasNext() {
		var result *queryresult.KV
		result, err = it.Next()
		if err != nil {
			return
		}
		isAny, err = predicate(result)
		if err != nil || isAny {
			return
		}
	}
	return
}
