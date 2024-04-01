pragma solidity ^0.8.0;

import "./InvestmentFund.sol";

contract DAF {
    mapping(address => uint256) public totalFunds;
    mapping(address => mapping(address => bool)) public isParticipant;
    address[] public investmentFunds;

    function createInvestmentFund(uint256 votingThreshold, address uniswapRouter, address pancakeSwapRouter, address storjContract) external returns (address) {
        InvestmentFund newFund = new InvestmentFund(votingThreshold, uniswapRouter, pancakeSwapRouter, storjContract);
        investmentFunds.push(address(newFund));
        isParticipant[msg.sender][address(newFund)] = true;
        return address(newFund);
    }

    function depositToFund(address fund, uint256 amount) external payable {
        require(isParticipant[msg.sender][fund], "Not a participant in this fund");
        totalFunds[msg.sender] += amount;
        InvestmentFund(fund).deposit{value: msg.value}(amount);
    }

    function withdrawFromFund(address fund, uint256 amount) external {
        require(isParticipant[msg.sender][fund], "Not a participant in this fund");
        totalFunds[msg.sender] -= amount;
        InvestmentFund(fund).withdraw(amount);
    }

    function submitProposal(address fund, string memory description) external {
        require(isParticipant[msg.sender][fund], "Not a participant in this fund");
        InvestmentFund(fund).submitProposal(description);
    }

    function voteOnProposal(address fund, uint256 proposalIndex) external {
        require(isParticipant[msg.sender][fund], "Not a participant in this fund");
        InvestmentFund(fund).vote(proposalIndex);
    }
}