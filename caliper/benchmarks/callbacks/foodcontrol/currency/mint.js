/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

"use strict";

const logger = require("@hyperledger/caliper-core").CaliperUtils.getLogger(
  "currency-mint"
);

module.exports.info = "Mint callback";

const contractID = "foodmarketplace";
const version = "v0.1";

// save the objects during init
let bc,
  ctx,
  currencyCode,
  minterIdentity,
  receiver,
  clientIdx,
  privateData,
  amount,
  targetPeers,
  receiverIdentity,
  utxoIDs = [];

/**
 * Initializes the workload module before the start of the round.
 * @param {BlockchainInterface} blockchain The SUT adapter instance.
 * @param {object} context The SUT-specific context for the round.
 * @param {object} args The user-provided arguments for the workload module.
 */
module.exports.init = async (blockchain, context, args) => {
  bc = blockchain;
  ctx = context;
  currencyCode = args.currencyCode;
  minterIdentity = args.client;
  receiver = args.receiver;
  receiverIdentity = args.receiverClient;
  amount = args.amount;
  clientIdx = context.clientIdx.toString();
  targetPeers = Array.from(
    ctx.networkInfo.getPeersOfOrganization(args.minterOrg)
  ).concat(
    Array.from(ctx.networkInfo.getPeersOfOrganization(args.receiverOrg))
  );
  let minter = args.minter;

  // Set the trustline between minter and receiver first
  try {
    console.log(
      `Client ${clientIdx}: Setting trustline for ${receiver} to receive from ${minter}`
    );
    const trustlineArgs = {
      chaincodeFunction: currencyCode + "CurrencyContract:SetTrustline",
      invokerIdentity: receiverIdentity,
      chaincodeArguments: [minter, true, "-1"],
      targetPeers: targetPeers,
    };
    await bc.bcObj.invokeSmartContract(ctx, contractID, version, trustlineArgs);
  } catch (error) {
    console.log(
      `Client ${clientIdx}: Smart Contract threw with error: ${error}`
    );
  }

  // Create the private data required for minting
  privateData = {
    mintPrivateData: Buffer.from(
      JSON.stringify({
        depositReference: args.depositReference,
        bank: args.depositBank,
      })
    ),
  };

  logger.debug("Initialized workload module");
};

module.exports.run = async () => {
  let txArgs = {
    chaincodeFunction: currencyCode + "CurrencyContract:Mint",
    chaincodeArguments: [amount, receiver],
    transientMap: privateData,
    invokerIdentity: minterIdentity,
    targetPeers: targetPeers,
  };

  return bc.bcObj.invokeSmartContract(
    ctx,
    "foodmarketplace",
    "v1.0",
    txArgs,
    30
  );
};

module.exports.end = async () => {
  logger.debug("Disposed of workload module");
};
