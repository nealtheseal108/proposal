// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract Transaction {
    
    address sender;
    address recipient;
    uint value;
    bytes32 hash;

    constructor(address _sender, address _recipient, uint _value) {
        sender = _sender;
        recipient = _recipient;
        value = _value;
        // cryptographic hashes
        hash = keccak256(abi.encode(sender, recipient, value));
    }

    function getHash() public view returns (bytes32) {
        return hash;
    }
}