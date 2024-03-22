// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import "./Transaction.sol";
import "./TransactionSorter.sol";

pragma solidity ^0.8.0;

contract TransactionFinder {
    Transaction[100][100] public transactions;
    TransactionSorter transactionSorter;

    constructor(Transaction[100][100] memory _transactions) {
        transactions = _transactions;
        transactionSorter = new TransactionSorter(_transactions);
    }

    function sortTransactions() public returns (Transaction[10000] memory) {
        return transactionSorter.sortTransactions();
    }

    // Binary search tree + recursion
    struct TreeNode {
        bytes32 hash; // hash
        uint index; // index in 'transactionsOneDimensional'
        bytes left; // abi-encoded left node
        bytes right; // abi-encoded right node
    }

    TreeNode rootNode;

    function buildBSTByHash() public {
        Transaction[10000] memory transactionsOneDimensional = sortTransactions();
        uint midIndex = transactionsOneDimensional.length / 2;
        TreeNode memory midNode = TreeNode(transactionsOneDimensional[midIndex].getHash(), midIndex, bytes(""), bytes(""));
        rootNode = midNode;
        
        for (uint i = 0; i < transactionsOneDimensional.length; i++) {
            if (i != midIndex) {
                insertNode(rootNode, TreeNode(transactionsOneDimensional[i].getHash(), i, bytes(""), bytes("")));
            }
        }
    }

    function insertNode(TreeNode memory currentNode, TreeNode memory newNode) internal {
        if (newNode.hash < currentNode.hash) {
            if (currentNode.left.length == 0) {
                currentNode.left = abi.encode(newNode);
            } else {
                TreeNode memory leftNode = decodeNode(currentNode.left);
                insertNode(leftNode, newNode);
                currentNode.left = abi.encode(leftNode);
            }
        } else {
            if (currentNode.right.length == 0) {
                currentNode.right = abi.encode(newNode);
            } else {
                TreeNode memory rightNode = decodeNode(currentNode.right);
                insertNode(rightNode, newNode);
                currentNode.right = abi.encode(rightNode);
            }
        }
    }

    function decodeNode(bytes memory encodedNode) internal pure returns (TreeNode memory) {
        (bytes32 hash, uint index, bytes memory left, bytes memory right) = abi.decode(encodedNode, (bytes32, uint, bytes, bytes));
        return TreeNode(hash, index, left, right);
    }

    function getTransactionsOneDimensional() public view returns (Transaction[10000] memory) {
        return transactionSorter.getTransactionsOneDimensional();
    }

    function searchTransactionByHash(bytes32 hash) public view returns (Transaction) {
        Transaction[10000] memory transactionsOneDimensional = getTransactionsOneDimensional();
        for (uint i = 0; i < transactionsOneDimensional.length; i++) {
            if (transactionsOneDimensional[i].getHash() == hash) {
                return transactionsOneDimensional[i];
            }
        }
        revert("Transaction not found");
    }
}