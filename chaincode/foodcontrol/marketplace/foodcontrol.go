package marketplace

import (
	"errors"
)

// Business errors
var (
	ErrNoFarmer = errors.New("The identity should be a farmer to execute the transaction")
)

//Food describes basic details of what makes up a food
type Food struct {
	Farmer       string `json:"farmer"`
	Organization string `json:"organization"`
	Variety      string `json:"variety"`
}
