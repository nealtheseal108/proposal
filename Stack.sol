// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import "./Transaction.sol";
contract Stack {
    uint256 constant stackSize = 100; 
    uint256 public top; 

    constructor() {
        top = 0; 
    }

    // stack + array
    Transaction[stackSize] stack;

    function push(Transaction transaction) public {
        require(top <= stackSize, "Stack is full"); 
        stack[top] = transaction;
        top++;
    }

    function pop() public returns (Transaction) {
        require(top > 0, "Stack is empty"); 
        top--;
        return stack[top];
    }

    function peek() public view returns (Transaction) {
        require(top > 0, "Stack is empty");
        return stack[top - 1];
    }

    function isEmpty() public view returns (bool) {
        return top == 0;
    }

    function isFull() public view returns (bool) {
        return top == stackSize;
    }

    function size() public view returns (uint256) {
        return top + 1;
    }

    function flush() public returns (bool) {
        while (!(this.isEmpty())) {
            this.pop();
        }
        return true;
    }
}