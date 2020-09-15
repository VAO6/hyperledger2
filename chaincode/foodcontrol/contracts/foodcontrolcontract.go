package contracts

import (
	"encoding/json"
	"fmt"

	"github.com/braduf/curso-hyperledger-fabric/chaincode/foodcontrol/marketplace"
	"github.com/hyperledger/fabric-chaincode-go/pkg/cid"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// FoodControlContract provides functions to control the food
type FoodControlContract struct {
	contractapi.Contract
}

// Set stores a food item in the state
func (fcc *FoodControlContract) Set(ctx contractapi.TransactionContextInterface, foodID string, variety string) error {
	// Validaciones del remitente de la transacción
	hasOU, err := cid.HasOUValue(ctx.GetStub(), "department2")
	if err != nil {
		return err
	}
	if !hasOU {
		return marketplace.ErrNoFarmer
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

	food := marketplace.Food{
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
func (fcc *FoodControlContract) Query(ctx contractapi.TransactionContextInterface, foodID string) (*marketplace.Food, error) {

	foodAsBytes, err := ctx.GetStub().GetState(foodID)

	if err != nil {
		return nil, fmt.Errorf("Failed to read from world state. %s", err.Error())
	}

	if foodAsBytes == nil {
		return nil, fmt.Errorf("%s does not exist", foodID)
	}

	food := new(marketplace.Food)

	err = json.Unmarshal(foodAsBytes, food)
	if err != nil {
		return nil, fmt.Errorf("Unmarshal error. %s", err.Error())
	}

	return food, nil
}
