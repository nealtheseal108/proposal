// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import "./Transaction.sol";

contract GridStorage {
    uint currentRow;
    uint currentColumn;
    // encapsulation + 2D array
    Transaction[100][100] transactions;

    constructor() {
        currentRow = 0;
        currentColumn = 0;
        transactions = transactions;
    }

    function addTransaction(Transaction transaction) public returns (bool) {
        transactions[currentRow][currentColumn] = transaction;
        if (currentRow == 999) {
            currentRow = 0;
            currentColumn += 1;
        } else {
            currentRow++;
        }
        return true;
    }

    function getTransactions() public view returns (Transaction[100][100] memory) {
        return transactions;
    }
}