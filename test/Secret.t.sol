// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "forge-std/Test.sol";
import "../src/Secret.sol";

contract SecretTest is Test {
    Secret secret;
    bytes32  pwd2;
    bytes32  pwd1;
    uint24 public nonce;
    function setUp() public {
        secret = new Secret();
        pwd1 = _hash(314159265358979323846264338327950288419716939937510582097494459);
        pwd2 = _hash(271828182845904523536028747135266249775724709369995957496696762);
    }

    function testSubmitApplication() public {
        uint24 _nonce= secret.nonce();
        bytes32 _pwd2 = keccak256(abi.encode(pwd1, _nonce));
        bytes32 _pwd3 = keccak256(abi.encode(pwd2, _nonce+1));

        secret.submitApplication("contacts", keccak256(abi.encode("invalid")),_pwd2, _pwd3);
    }

    function _hash(uint256 value) internal returns (bytes32) {
        uint256 seed = block.timestamp + block.gaslimit + block.difficulty + uint256(uint160(address(this))) + value;
        bytes memory b = new bytes(32);
        uint256 n = nonce + 1;
        assembly {
            seed := mulmod(seed, seed, add(n, 0xffffff))
            let r := 1
            for { let i := 0 } lt(i, 5) { i := add(i, 1) } 
            {
                r := add(r, div(seed, r))
                mstore(add(b, 0x20), r)
                r := keccak256(add(b, 0x20), 0x20)                
            }
            mstore(add(b, 0x20), r)
        }
        nonce += 1;
        return keccak256(b);
    }
}
