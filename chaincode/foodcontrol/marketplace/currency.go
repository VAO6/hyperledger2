package marketplace

// Currency specifies a currency
type Currency struct {
	Name     string `json:"name"`
	Code     string `json:"code"`
	Decimals int    `json:"decimals"`
}

// UTXO is an unspent amount of a certain currency
type UTXO struct {
	ID                string `json:"id"`
	Issuer            string `json:"issuer"`
	Owner             string `json:"owner"`
	Value             int    `json:"value"`
	RedemptionPending bool   `json:"redemptionPending"`
}

// CurrencyEventNames specifies the names of the events that should be fired after the txs
var CurrencyEventNames = map[string]string{
	"Mint":              "Minted",
	"Transfer":          "Transfered",
	"RequestRedemption": "RedemptionRequested",
	"ConfirmRedemption": "RedemptionConfirmed",
	"TrustIssuer":       "IssuerTrustChanged",
}
