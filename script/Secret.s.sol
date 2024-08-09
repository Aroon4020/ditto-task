// // SPDX-License-Identifier: UNLICENSED
// pragma solidity 0.8.23;

// import "forge-std/Script.sol";
// import "../src/Workflow.sol";

// contract ActivateWorkflowScript is Script {
//     function run() external {
//         // Define the workflow parameters
//         uint256 workflowKey = 1;
//         uint256 maxGasPrice = 50 gwei;
//         uint256 maxGasLimit = 500000;

//         // Address of the deployed Workflow contract on Holesky
//         Workflow workflow = Workflow(payable(0x08BbE5e9149b60cFEe9eb2726463060F0F2A897F));

//         // Start broadcasting (signing and sending transactions)
//         vm.startBroadcast();

//         // Call the activate function on the Workflow contract
//         workflow.withdraw();

//         // Stop broadcasting
//         vm.stopBroadcast();
//     }
// }
