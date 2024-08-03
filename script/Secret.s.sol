// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11;

import {Script, console} from "forge-std/Script.sol";
import {Secret} from "../src/Secret.sol";

contract SecretScript is Script {
    Secret public secret;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        secret = new Secret();

        vm.stopBroadcast();
    }
}
