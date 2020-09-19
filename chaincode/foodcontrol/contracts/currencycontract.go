package contracts

import (
	"github.com/braduf/curso-hyperledger-fabric/chaincode/foodcontrol/marketplace"
	"github.com/braduf/curso-hyperledger-fabric/chaincode/foodcontrol/shim"
	"github.com/hyperledger/fabric-chaincode-go/pkg/cid"
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
	stub := ctx.GetStub()
	// Check that the sender has permissions to transact on this channel
	hasChannelOU, err := cid.HasOUValue(stub, stub.GetChannelID())
	if err != nil {
		return
	}
	if !hasChannelOU {
		err = marketplace.ErrNoChannelPermissions
		return
	}
	// GetMSPID and set it to tx context
	msp, err := ctx.GetClientIdentity().GetMSPID()
	if err != nil {
		return
	}
	ctx.SetMSPID(msp)
	// Get possible transient data and store it
	transient, err := stub.GetTransient()
	if err != nil {
		return
	}
	ctx.SetTransient(transient)
	return
}

// AfterTransaction will be executed after every transaction of this contract
func AfterTransaction(ctx CustomTransactionContextInterface, txReturnValue interface{}) (err error) {
	// After most transactions an event should be fired
	shim.SetCurrencyEvent(ctx.GetStub(), txReturnValue)
	return
}

// GetEvaluateTransactions returns functions of CurrencyContract not to be tagged as submit
func (cc *CurrencyContract) GetEvaluateTransactions() []string {
	return []string{"GetHistoryOfUTXO", "QueryCouchDB"}
}

// Mint issues new coins for a specified amount to a specified receiver
func (cc *CurrencyContract) Mint(ctx CustomTransactionContextInterface, amount int, receiver string) (payload marketplace.MintedPayload, err error) {
	// Validate parameters
	if amount <= 0 {
		err = marketplace.ErrNegativeMintAmount
		return
	}
	// Check decimals of amount
	if receiver == "" {
		err = marketplace.ErrMintReceiverRequiered
		return
	}

	// Mint a new UTXO
	utxo := marketplace.CurrencyUTXO{
		ID:     ctx.GetStub().GetTxID() + ":" + "0",
		Issuer: ctx.GetMSPID(),
		Owner:  receiver,
		Value:  amount,
	}

	err = shim.PutCurrencyUTXO(ctx.GetStub(), cc.Currency.Code, utxo)
	if err != nil {
		return
	}

	err = shim.PutMintPrivateData(ctx.GetStub(), ctx.GetTransient(), cc.Currency.Code)
	if err != nil {
		return
	}
	// Return the event payload
	payload = marketplace.MintedPayload{
		Minter:       ctx.GetMSPID(),
		UTXOID:       utxo.ID,
		Receiver:     receiver,
		CurrencyCode: cc.Currency.Code,
	}
	//ctx.SetEventPayload(payload)
	return
}

// Transfer transfers a specified amount of the utxo set to a specified receiver
func (cc *CurrencyContract) Transfer(ctx CustomTransactionContextInterface, utxoIDSet []string, amount int, receiver string) (payload marketplace.TransferedPayload, err error) {
	// Validate parameters
	if len(utxoIDSet) == 0 {
		err = marketplace.ErrTransferEmptyUTXOSet
		return
	}
	if amount <= 0 {
		err = marketplace.ErrNegativeMintAmount
		return
	}
	// TODO: Check decimals of amount
	if receiver == "" {
		err = marketplace.ErrMintReceiverRequiered
		return
	}

	// Validate and spend the UTXO set
	totalInputAmount := 0
	spentUTXO := make(map[string]bool)
	var issuer string
	for i, utxoID := range utxoIDSet {
		// Check duplicate ID in utxo set
		if spentUTXO[utxoID] {
			err = marketplace.ErrDoubleSpentTransfer
			return
		}
		// Obtain UTXO from state
		var utxo marketplace.CurrencyUTXO
		utxo, err = shim.GetCurrencyUTXOByID(ctx.GetStub(), cc.Currency.Code, utxoID)
		if err != nil {
			return
		}
		// Set issuer of the first utxo in the set
		if i == 0 {
			issuer = utxo.Issuer
			// Check if the receiver accepts coins from this issuer
			err = shim.CheckCurrencyTrustline(ctx.GetStub(), cc.Currency.Code, receiver, issuer)
			if err != nil {
				return
			}
		}
		// Check issuer
		if utxo.Issuer != issuer {
			err = marketplace.ErrOnlySameIssuerTransfer
			return
		}
		// Check owner
		if utxo.Owner != ctx.GetMSPID() {
			err = marketplace.ErrOnlyOwnerTransfer
			return
		}
		// Add value to input amount
		totalInputAmount += utxo.Value

		err = shim.DeleteCurrencyUTXO(ctx.GetStub(), cc.Currency.Code, utxoID)
		if err != nil {
			return
		}
		spentUTXO[utxoID] = true
	}

	// Create new outputs
	var transferUTXO, changeUTXO marketplace.CurrencyUTXO
	if totalInputAmount < amount {
		err = marketplace.ErrInsufficientTransferFunds
		return
	}
	transferUTXO = marketplace.CurrencyUTXO{
		ID:     ctx.GetStub().GetTxID() + ":" + "0",
		Issuer: issuer,
		Owner:  receiver,
		Value:  amount,
	}
	err = shim.PutCurrencyUTXO(ctx.GetStub(), cc.Currency.Code, transferUTXO)
	if err != nil {
		return
	}

	changeAmount := totalInputAmount - amount
	if changeAmount > 0 {
		changeUTXO = marketplace.CurrencyUTXO{
			ID:     ctx.GetStub().GetTxID() + ":" + "1",
			Issuer: issuer,
			Owner:  ctx.GetMSPID(),
			Value:  changeAmount,
		}
		err = shim.PutCurrencyUTXO(ctx.GetStub(), cc.Currency.Code, changeUTXO)
		if err != nil {
			return
		}
	}

	// Set the event payload
	payload = marketplace.TransferedPayload{
		TransferedBy: ctx.GetMSPID(),
		//SpentUTXOIDSet:   utxoIDSet,
		ChangeUTXOID:     changeUTXO.ID,
		TransferedUTXOID: transferUTXO.ID,
		Receiver:         receiver,
		CurrencyCode:     cc.Currency.Code,
	}
	//ctx.SetEventPayload(payload)
	return
}

// Redeem requests to receive the off-chain currency that is guarded by the issuer of the specified UTXO
func (cc *CurrencyContract) Redeem(ctx CustomTransactionContextInterface, utxoID string) (payload marketplace.RedeemPayload, err error) {
	utxo, err := shim.GetCurrencyUTXOByID(ctx.GetStub(), cc.Currency.Code, utxoID)
	if err != nil {
		return
	}
	if utxo.Owner != ctx.GetMSPID() {
		err = marketplace.ErrOnlyOwnerRedeem
		return
	}
	err = shim.DeleteCurrencyUTXO(ctx.GetStub(), cc.Currency.Code, utxoID)
	if err != nil {
		return
	}

	err = shim.PutRedeemPrivateData(ctx.GetStub(), ctx.GetTransient(), utxo.Issuer, utxo.ID)
	if err != nil {
		return
	}

	payload = marketplace.RedeemPayload{
		Requestor:    ctx.GetMSPID(),
		Redeemer:     utxo.Issuer,
		UTXOID:       utxo.ID,
		CurrencyCode: cc.Currency.Code,
	}
	//ctx.SetEventPayload(payload)
	return
}

// SetTrustline can be used to enable or disable receptions of this currency from a specific issuer
func (cc *CurrencyContract) SetTrustline(ctx CustomTransactionContextInterface, issuer string, trust bool, limit int) (payload marketplace.TrustlineSetPayload, err error) {
	// createCompositeKey with currency code, sender,issuer and value of bool trust
	// Validate parameters
	if issuer == "" {
		err = marketplace.ErrTrustlineIssuerRequiered
		return
	}

	// Set trustline
	err = shim.PutCurrencyTrustline(ctx.GetStub(), cc.Currency.Code, marketplace.CurrencyTrustline{
		Receiver: ctx.GetMSPID(),
		Issuer:   issuer,
		Trust:    trust,
		MaxLimit: limit,
	})
	if err != nil {
		return
	}

	payload = marketplace.TrustlineSetPayload{
		Receiver:     ctx.GetMSPID(),
		Issuer:       issuer,
		Trust:        trust,
		MaxLimit:     limit,
		CurrencyCode: cc.Currency.Code,
	}
	//ctx.SetEventPayload(payload)
	return
}

// QueryCouchDB can be used to execute rich queries against the CouchDB
func (cc *CurrencyContract) QueryCouchDB(ctx CustomTransactionContextInterface, query string) (queryResultInJSONString string, err error) {
	queryResultInJSONString, err = shim.QueryCouchDB(ctx.GetStub(), query)
	return
}

// GetHistoryOfUTXO can be used to search through the history of a UTXO
func (cc *CurrencyContract) GetHistoryOfUTXO(ctx CustomTransactionContextInterface, id string) (historyInJSONString string, err error) {
	historyInJSONString, err = shim.GetHistoryForCurrencyUTXOID(ctx.GetStub(), cc.Currency.Code, id)
	return
}
