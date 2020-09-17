package main

import (
	"fmt"

	"github.com/braduf/curso-hyperledger-fabric/chaincode/foodcontrol/contracts"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

func main() {
	fmt.Printf("Start main")
	foodControlContract := new(contracts.FoodControlContract)
	USDContract := new(contracts.CurrencyContract)
	USDContract.TransactionContextHandler = new(contracts.CustomTransactionContext)
	USDContract.BeforeTransaction = contracts.BeforeTransaction
	USDContract.AfterTransaction = contracts.AfterTransaction
	USDContract.Currency.Name = "US Dollar"
	USDContract.Currency.Code = "USD"
	USDContract.Currency.Decimals = 2
	USDContract.Name = "USDCurrencyContract"
	COPContract := new(contracts.CurrencyContract)
	COPContract.TransactionContextHandler = new(contracts.CustomTransactionContext)
	COPContract.BeforeTransaction = contracts.BeforeTransaction
	COPContract.AfterTransaction = contracts.AfterTransaction
	COPContract.Currency.Name = "Colombian Peso"
	COPContract.Currency.Code = "COP"
	COPContract.Currency.Decimals = 2
	COPContract.Name = "COPCurrencyContract"

	fmt.Printf("Create chaincode from smart contracts")
	chaincode, err := contractapi.NewChaincode(foodControlContract, USDContract, COPContract)
	if err != nil {
		panic(err.Error())
	}

	fmt.Printf("Start chaincode")
	err = chaincode.Start()
	if err != nil {
		panic(err.Error())
	}
}
