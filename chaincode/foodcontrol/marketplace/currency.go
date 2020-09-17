package marketplace

import "errors"

// Currency specifies a currency
type Currency struct {
	Name     string `json:"name"`
	Code     string `json:"code"`
	Decimals int    `json:"decimals"`
}

// CurrencyUTXO is an unspent amount of a certain currency
type CurrencyUTXO struct {
	ID                string `json:"id"`
	Issuer            string `json:"issuer"`
	Owner             string `json:"owner"`
	Value             int    `json:"value"`
	RedemptionPending bool   `json:"redemptionPending"`
}

// CurrencyTrustline sets if an organization trusts an issuer to receive coins from
type CurrencyTrustline struct {
	Receiver string `json:"receiver"`
	Issuer   string `json:"issuer"`
	Trust    bool   `json:"trust"`
	MaxLimit int    `json:"maxLimit"`
}

// CurrencyEventNames specifies the names of the events that should be fired after the txs
var CurrencyEventNames = map[string]string{
	"Mint":              "Minted",
	"Transfer":          "Transfered",
	"RequestRedemption": "RedemptionRequested",
	"ConfirmRedemption": "RedemptionConfirmed",
	"SetTrustline":      "TrustlineSet",
}

// MintedPayload is the payload of the Minted Events
type MintedPayload struct {
	Minter       string `json:"minter"`
	UTXOID       string `json:"UtxoId"`
	Receiver     string `json:"receiver"`
	CurrencyCode string `json:"currencyCode"`
}

// TransferedPayload is the payload of the Transfered Events
type TransferedPayload struct {
	TransferedBy string `json:"transferedBy"`
	//SpentUTXOIDSet   []string `json:"spentUtxoIdSet"`
	ChangeUTXOID     string `json:"changeUtxoId"`
	TransferedUTXOID string `json:"transferedUtxoId"`
	Receiver         string `json:"receiver"`
	CurrencyCode     string `json:"currencyCode"`
}

// RedemptionRequestedPayload is the payload of the RedemptionRequested Events
type RedemptionRequestedPayload struct {
	Requestor    string `json:"requestor"`
	Redeemer     string `json:"redeemer"`
	UTXOID       string `json:"utxoID"`
	CurrencyCode string `json:"currencyCode"`
}

// RedemptionConfirmedPayload is the payload of the RedemptionConfirmed Events
type RedemptionConfirmedPayload struct {
	ConfirmedBy  string `json:"confirmedBy"`
	Redeemer     string `json:"redeemer"`
	UTXOID       string `json:"utxoID"`
	CurrencyCode string `json:"currencyCode"`
}

// TrustlineSetPayload is the payload of the TrustlineSet Events
type TrustlineSetPayload struct {
	Receiver     string `json:"receiver"`
	Issuer       string `json:"issuer"`
	Trust        bool   `json:"trust"`
	MaxLimit     int    `json:"maxLimit"`
	CurrencyCode string `json:"currencyCode"`
}

// Business errors
var (
	ErrNegativeMintAmount           = errors.New("The amount to mint a currency should be a positive value")
	ErrMintReceiverRequiered        = errors.New("The receiving MSP should be specified to mint currency to")
	ErrTransferEmptyUTXOSet         = errors.New("The set of UTXO should contain at least one UTXO to transfer")
	ErrDoubleSpentTransfer          = errors.New("The same UTXO can not be spent twice")
	ErrPendingRedemptionTransfer    = errors.New("A UTXO that is already requested to be redeemed can not be transfered")
	ErrOnlyOwnerTransfer            = errors.New("Only the owner of a UTXO can transfer it")
	ErrInsufficientTransferFunds    = errors.New("The total input value of the UTXO set to transfer should be sufficient to cover the specified amount")
	ErrOnlySameIssuerTransfer       = errors.New("The UTXO's in the input set should all have the same issuer")
	ErrNoChannelPermissions         = errors.New("The transaction sender does not have permissions on this channel")
	ErrTrustlineIssuerRequiered     = errors.New("The issuer MSP should specified to set a trustline")
	ErrTransferTrustline            = errors.New("The receiver of a transfer should trust the issuer of the transfered coins")
	ErrRedemptionRequestPending     = errors.New("The redemption of the UTXO has already been requested")
	ErrOnlyOwnerRequestRedemption   = errors.New("Only the owner of a UTXO con request its redemption")
	ErrNoRedemptionRequestToConfirm = errors.New("The UTXO should have a pending redemption request to be able to confirm the redemption")
	ErrOnlyOwnerConfirmRedemption   = errors.New("Only the owner of a UTXO can confirm its redemption")
)
