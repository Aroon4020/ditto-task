//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {IProtocolFees} from "./IProtocolFees.sol";
import {IDittoEntryPoint} from "./IDEP.sol";

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
    mapping(uint256 => TxData) public txData;
    mapping(uint256 => uint256) public blockDetails;

    receive() external payable {}

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

    function runFromDEP(uint256 workflowKey) external {
        _run(workflowKey);
    }

    function _run(uint256 workflowKey) internal {
        require(txData[workflowKey].isExecuted == false, "Already executed");
        blockDetails[block.number] = block.timestamp;
        txData[workflowKey].isExecuted = true;
    }
}
