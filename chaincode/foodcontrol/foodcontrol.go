/*
Business Blockchain Training & Consulting SpA. All Rights Reserved.
www.blockchainempresarial.com
email: ricardo@blockchainempresarial.com
*/

package main

import (
	"encoding/json"
	"errors"
	"fmt"

	"github.com/hyperledger/fabric-chaincode-go/pkg/cid"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// SmartContract provides functions for control the food
type SmartContract struct {
	contractapi.Contract
}

// Error codes returned by failures with IOUStates
var (
	errMissingOU = errors.New("The identity does not belong to the OU required to execute this transaction")
)

//Food describes basic details of what makes up a food
type Food struct {
	Farmer       string `json:"farmer"`
	Organization string `json:"organization"`
	Variety      string `json:"variety"`
}

// Set stores a food item in the state
func (s *SmartContract) Set(ctx contractapi.TransactionContextInterface, foodID string, variety string) error {
	// Validaciones del remitente de la transacción
	hasOU, err := cid.HasOUValue(ctx.GetStub(), "department2")
	if err != nil {
		return err
	}
	if !hasOU {
		return errMissingOU
	}

	identity := ctx.GetClientIdentity()
	farmer, err := identity.GetID()
	if err != nil {
		return err
	}
	org, err := identity.GetMSPID()
	if err != nil {
		return err
	}

	// Validaciones de sintaxis

	// Validaciones de negocio

	food := Food{
		Farmer:       farmer,
		Organization: org,
		Variety:      variety,
	}

	foodAsBytes, err := json.Marshal(food)
	if err != nil {
		fmt.Printf("Marshal error: %s", err.Error())
		return err
	}

	return ctx.GetStub().PutState(foodID, foodAsBytes)
}

// Query obtains a food item from the state by its id
func (s *SmartContract) Query(ctx contractapi.TransactionContextInterface, foodID string) (*Food, error) {

	foodAsBytes, err := ctx.GetStub().GetState(foodID)

	if err != nil {
		return nil, fmt.Errorf("Failed to read from world state. %s", err.Error())
	}

	if foodAsBytes == nil {
		return nil, fmt.Errorf("%s does not exist", foodID)
	}

	food := new(Food)

	err = json.Unmarshal(foodAsBytes, food)
	if err != nil {
		return nil, fmt.Errorf("Unmarshal error. %s", err.Error())
	}

	return food, nil
}

func main() {

	chaincode, err := contractapi.NewChaincode(new(SmartContract))

	if err != nil {
		fmt.Printf("Error create foodcontrol chaincode: %s", err.Error())
		return
	}

	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting foodcontrol chaincode: %s", err.Error())
	}
}
