package contracts

import (
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// CustomTransactionContextInterface interface to define interaction with custom transaction context
type CustomTransactionContextInterface interface {
	contractapi.TransactionContextInterface
	GetMSPID() string
	SetMSPID(string)
	//GetEventPayload() interface{}
	//SetEventPayload(interface{})
}

// CustomTransactionContext adds methods of storing and retrieving additional data for use
// with before and after transaction hooks
type CustomTransactionContext struct {
	contractapi.TransactionContext
	mspID string
	//eventPayload interface{}
}

// GetMSPID returns set MSP ID
func (ctc *CustomTransactionContext) GetMSPID() string {
	return ctc.mspID
}

// SetMSPID provides a value for MSP ID
func (ctc *CustomTransactionContext) SetMSPID(mspID string) {
	ctc.mspID = mspID
}

/* // GetEventPayload returns set payload for the transaction event
func (ctc *CustomTransactionContext) GetEventPayload() interface{} {
	return ctc.eventPayload
}

// SetEventPayload provides the payload for the transaction event
func (ctc *CustomTransactionContext) SetEventPayload(eventPayload interface{}) {
	ctc.eventPayload = eventPayload
} */
