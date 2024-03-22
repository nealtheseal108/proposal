// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import "./Transaction.sol";

contract TransactionSorter {
    Transaction[100][100] transactions;
    Transaction[10000] public transactionsOneDimensional;

    constructor(Transaction[100][100] memory _transactions) {
        transactions = _transactions;
    }

    // bubble sort
    function sortTransactions() public returns (Transaction[10000] memory) {
        uint iterator = 0;
        for (uint i = 0; i < 100; i++) {
            for (uint j = 0; j < 100; j++) {
                transactionsOneDimensional[iterator] = transactions[i][j]; 
                iterator++;
            }
        }

        uint n = transactionsOneDimensional.length;
        for (uint i = 0; i < n-1; i++) {
            for (uint j = i; j < n-1; j++) {
                if (transactionsOneDimensional[j].getHash() > transactionsOneDimensional[j+1].getHash()) {
                    // Swap transactions
                    Transaction temp = transactionsOneDimensional[j];
                    transactionsOneDimensional[j] = transactionsOneDimensional[j+1];
                    transactionsOneDimensional[j+1] = temp;
                }
            }
        }

        return transactionsOneDimensional;
    }

    function getTransactionsOneDimensional() public view returns (Transaction[10000] memory) {
        return transactionsOneDimensional;
    }
}