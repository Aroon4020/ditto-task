// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

interface IProtocolFees{
    function getDEPFee() external view returns (uint256 depFixedFee, uint256 depFixedGas);
} 