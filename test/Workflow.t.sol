// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Workflow.sol";
import {IProtocolFees} from "../src/interfaces/IProtocolFees.sol";
import {IDittoEntryPoint} from "../src/interfaces/IDEP.sol";

contract WorkflowTest is Test {
    Workflow public workflow;
    IDittoEntryPoint constant DEP =
        IDittoEntryPoint(0x5FD0026a449eeA51Bd1471E4ee8df8607aaECC24);
    IProtocolFees constant protocolFees =
        IProtocolFees(0xCFE38b65b0cCDD6b78e578d8E07891EFEE51a655);

    function setUp() public {
        workflow = new Workflow();
        vm.deal(address(workflow), 100 ether);
    }

    receive() external payable {}

    function testActivate() public {
        uint256 workflowKey = 1;
        uint256 maxGasPrice = 50 gwei;
        uint256 maxGasLimit = 500000;
        workflow.activate(workflowKey, maxGasPrice, maxGasLimit);
        (
            uint256 storedGasPrice,
            uint256 storedGasLimit,
            bool isExecuted
        ) = workflow.txData(workflowKey);

        assertEq(storedGasPrice, maxGasPrice, "Max gas price mismatch");
        assertEq(storedGasLimit, maxGasLimit, "Max gas limit mismatch");
        assertEq(isExecuted, false);
    }

    function testPayPrefund() public {
        uint256 workflowKey = 1;
        uint256 maxGasPrice = 50 gwei;
        uint256 maxGasLimit = 500000;
        workflow.activate(workflowKey, maxGasPrice, maxGasLimit);
        vm.startPrank(address(DEP));
        vm.txGasPrice(45 gwei);
        uint256 gasLimit = workflow.payPrefund(workflowKey);
        assertEq(gasLimit, maxGasLimit, "Gas limit mismatch");
    }

    function testRunFromDep() public {
        uint256 workflowKey = 1;
        uint256 maxGasPrice = 50 gwei;
        uint256 maxGasLimit = 100000;
        workflow.activate(workflowKey, maxGasPrice, maxGasLimit);

        vm.roll(100);
        vm.warp(1000);

        vm.startPrank(address(DEP));
        assertTrue(workflow.isActiveWorkflow(workflowKey));
        workflow.payPrefund(workflowKey);
        workflow.runFromDEP(workflowKey);
        assertEq(workflow.blockDetails(100), 1000);
    }
    
}
