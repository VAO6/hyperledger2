package contracts

import (
	"github.com/braduf/curso-hyperledger-fabric/chaincode/foodcontrol/marketplace"
	"github.com/braduf/curso-hyperledger-fabric/chaincode/foodcontrol/shim"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// CurrencyContract is the smart contract structure that will meet the contractapi.ContractInterface
// and implement transactions that with currencies
type CurrencyContract struct {
	contractapi.Contract
	Currency marketplace.Currency
}

// BeforeTransaction will be executed before every transaction of this contract
func BeforeTransaction(ctx CustomTransactionContextInterface) (err error) {
	// GetMSPID and set it to tx context
	return
}

// AfterTransaction will be executed after every transaction of this contract
func AfterTransaction(ctx CustomTransactionContextInterface, txReturnValue interface{}) (err error) {
	// After most transactions an event should be fired
	shim.SetCurrencyEvent(ctx.GetStub(), ctx.GetEventPayload())
	return
}

// Mint issues new coins for a specified amount to a specified receiver
func (cc *CurrencyContract) Mint(ctx CustomTransactionContextInterface, amount int, receiver string) (err error) {

	return
}

// Transfer transfers a specified amount of the utxo set to a specified receiver
func (cc *CurrencyContract) Transfer(ctx CustomTransactionContextInterface, utxoSet marketplace.UTXO, amount int, receiver string) (err error) {
	return
}

// RequestRedemption requests to receive the off-chain currency that is guarded by the issuer of the specified UTXO
func (cc *CurrencyContract) RequestRedemption(ctx CustomTransactionContextInterface, utxo marketplace.UTXO) (err error) {
	return
}

// ConfirmRedemption confirms the off-chain reception of the currency represented by the utxo and destroys the utxo on-chain
func (cc *CurrencyContract) ConfirmRedemption(ctx CustomTransactionContextInterface, utxo marketplace.UTXO) (err error) {
	return
}

// TrustIssuer can be used to enable or disable receptions of this currency from a specific issuer
func (cc *CurrencyContract) TrustIssuer(ctx CustomTransactionContextInterface, issuer string, trust bool) (err error) {
	// createCompositeKey with sender,issuer and value of bool trust
	return
}
