// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {IProtocolFees} from "./interfaces/IProtocolFees.sol";
import {IDittoEntryPoint} from "./interfaces/IDEP.sol";

/**
 * @title Workflow
 * @dev This contract manages workflow registrations and associated gas limits and prices.
 * It integrates with Ditto Entry Point (DEP) and a protocol fees contract.
 */
contract Workflow {
    IDittoEntryPoint constant DEP =
        IDittoEntryPoint(0x5FD0026a449eeA51Bd1471E4ee8df8607aaECC24);
    IProtocolFees constant protocolFees =
        IProtocolFees(0xCFE38b65b0cCDD6b78e578d8E07891EFEE51a655);

    struct TxData {
        uint256 maxGasPrice;
        uint256 maxGasLimit;
        bool isExecuted;
    }

    /// @notice Mapping to store transaction data by workflow key
    mapping(uint256 => TxData) public txData;

    /// @notice Mapping to store block details by block number
    mapping(uint256 => uint256) public blockDetails;

    /**
     * @notice Fallback function to receive Ether.
     */
    receive() external payable {}

    /**
     * @notice Activates a workflow by registering it with the DEP and setting its gas data.
     * @param workflowKey The unique key for the workflow.
     * @param maxGasPrice The maximum gas price that can be used for transactions.
     * @param maxGasLimit The maximum gas limit that can be used for transactions.
     * @dev Reverts if the workflow key has already been registered.
     */
    function activate(
        uint256 workflowKey,
        uint256 maxGasPrice,
        uint256 maxGasLimit
    ) external {
        require(maxGasPrice != 0 && maxGasLimit != 0, "zero address");
        require(txData[workflowKey].maxGasPrice == 0, "key already registered");
        DEP.registerWorkflow(workflowKey);
        txData[workflowKey] = TxData(maxGasPrice, maxGasLimit, false);
    }

    /**
     * @notice Pays the prefund for a workflow, which is calculated based on gas price and limits.
     * @param workflowKey The unique key for the workflow.
     * @return The maximum gas limit for the workflow.
     * @dev Reverts if the caller is not the DEP or if the transaction fails.
     */
    function payPrefund(
        uint256 workflowKey
    ) external virtual returns (uint256) {
        require(msg.sender == address(DEP), "Invalid caller");
        uint256 maxGasLimit = txData[workflowKey].maxGasLimit;
        if (tx.gasprice <= txData[workflowKey].maxGasPrice) {
            (uint256 depFixedFee, uint256 depFixedGas) = protocolFees
                .getDEPFee();
            uint256 _fee = (tx.gasprice * (maxGasLimit + depFixedGas)) +
                depFixedFee;
            (bool success, ) = msg.sender.call{value: _fee}("");
            require(success, "Transfer failed.");
        }
        return maxGasLimit;
    }

    /**
     * @notice Runs the workflow using the DEP.
     * @param workflowKey The unique key for the workflow.
     * @dev Calls the internal `_run` function to execute the workflow.
     */
    function runFromDEP(uint256 workflowKey) external {
        _run(workflowKey);
    }

    /**
     * @notice Checks if a workflow is active.
     * @param workflowKey The unique key for the workflow.
     * @return Returns true if the workflow is active (i.e., not executed).
     */
    function isActiveWorkflow(
        uint256 workflowKey
    ) external view returns (bool) {
        return !txData[workflowKey].isExecuted;
    }

    /**
     * @notice Internal function to execute a workflow.
     * @param workflowKey The unique key for the workflow.
     * @dev Records the block timestamp and marks the workflow as executed.
     */
    function _run(uint256 workflowKey) internal {
        blockDetails[block.number] = block.timestamp;
        txData[workflowKey].isExecuted = true;
    }
}
