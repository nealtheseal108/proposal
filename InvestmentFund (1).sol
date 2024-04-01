pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/IPancakeSwapRouter02.sol";
import "./interfaces/IStorJ.sol";
import "./interfaces/ILido.sol";

contract InvestmentFund {
    using SafeMath for uint256;

    struct Proposal {
        address proposer;
        string description;
        uint256 votes;
        bool executed;
    }

    mapping(address => uint256) public balances;
    mapping(address => uint256) public votingRights;
    mapping(address => mapping(uint256 => bool)) public hasVoted;
    mapping(address => mapping(uint256 => bool)) public submittedProposals;
    mapping(address => mapping(uint256 => bool)) public proposalExecuted;

    Proposal[] public proposals;

    uint256 public totalFunds;
    uint256 public votingThreshold;
    uint256 public constant MINIMUM_DEPOSIT = 10 * 10**18; 

    address public uniswapRouterAddress;
    address public pancakeSwapRouterAddress;
    address public constant USDC_ADDRESS = 0x1Bv567aAABebB0087C4F9186dA8A1b2d4fF3eD3B; 
    address public constant LIDO_ADDRESS = 0xae7ab96520de3a18e5e111b5eaab095312d7fe84; 
    address public storjContractAddress; 

    event FundsInvested(address indexed user, address indexed security, uint256 amount);
    event ProposalSubmitted(address indexed proposer, uint256 indexed proposalIndex, string description);
    event Voted(address indexed voter, uint256 indexed proposalIndex);
    event SecuritiesSold(address indexed seller, address indexed buyer, uint256 amount);

    constructor(uint256 _votingThreshold, address _uniswapRouter, address _pancakeSwapRouter, address _storjContract) {
        votingThreshold = _votingThreshold;
        uniswapRouterAddress = _uniswapRouter;
        pancakeSwapRouterAddress = _pancakeSwapRouter;
        storjContractAddress = _storjContract;
    }

    function deposit() external payable {
        require(msg.value >= MINIMUM_DEPOSIT, "Insufficient deposit amount");
        balances[msg.sender] = balances[msg.sender].add(msg.value);
        totalFunds = totalFunds.add(msg.value);
        updateVotingRights(msg.sender);
    }

    function submitProposal(string memory _description) external {
        require(balances[msg.sender] >= MINIMUM_DEPOSIT, "Insufficient funds to submit proposal");
        require(!submittedProposals[msg.sender][proposals.length], "Proposal already submitted");

        submittedProposals[msg.sender][proposals.length] = true;
        proposals.push(Proposal(msg.sender, _description, 0, false));

        IStorJ(storjContractAddress).submitProposal(msg.sender, _description);

        emit ProposalSubmitted(msg.sender, proposals.length - 1, _description);
    }

    function vote(uint256 _proposalIndex) external {
        require(_proposalIndex < proposals.length, "Invalid proposal index");
        require(!hasVoted[msg.sender][_proposalIndex], "Already voted");

        proposals[_proposalIndex].votes = proposals[_proposalIndex].votes.add(votingRights[msg.sender]);
        hasVoted[msg.sender][_proposalIndex] = true;

        emit Voted(msg.sender, _proposalIndex);

        if (proposals[_proposalIndex].votes.mul(100).div(totalFunds) >= votingThreshold) {
            executeProposal(_proposalIndex);
        }
    }

    function executeProposal(uint256 _proposalIndex, address _security) internal {
        require(!proposals[_proposalIndex].executed, "Proposal already executed");
        require(!proposalExecuted[msg.sender][_proposalIndex], "Proposal already executed by this user");

        Proposal storage proposal = proposals[_proposalIndex];

        require(proposal.votes.mul(100).div(totalFunds) >= votingThreshold, "Proposal has not reached the required votes");

        investFunds(_security, 100 * 10**18); 

        proposal.executed = true;
        proposalExecuted[msg.sender][_proposalIndex] = true;
    }

    function sellSecurities(address _buyer, uint256 _amount) external {
        require(balances[msg.sender] >= _amount, "Insufficient securities to sell");
        require(_buyer != address(0), "Invalid buyer address");

        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_buyer] = balances[_buyer].add(_amount);

        emit SecuritiesSold(msg.sender, _buyer, _amount);
    }

    function withdraw(uint256 _amount) external {
        require(_amount > 0 && _amount <= balances[msg.sender], "Invalid withdrawal amount");
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        totalFunds = totalFunds.sub(_amount);
        payable(msg.sender).transfer(_amount);
        updateVotingRights(msg.sender);
    }

    function swapTokens(address _tokenIn, address _tokenOut, uint256 _amount) external {
        require(_tokenIn != address(0) && _tokenOut != address(0), "Invalid token address");
        require(_amount > 0, "Invalid amount");

        IUniswapV2Router02 uniswapRouter = IUniswapV2Router02(uniswapRouterAddress);
        IPancakeSwapRouter02 pancakeSwapRouter = IPancakeSwapRouter02(pancakeSwapRouterAddress);

        address[] memory path;
        if (_tokenIn == uniswapRouter.WETH() || _tokenOut == uniswapRouter.WETH()) {
            path = new address ;
            path[0] = _tokenIn;
            path[1] = _tokenOut;
        } else if (_tokenIn == pancakeSwapRouter.WETH() || _tokenOut == pancakeSwapRouter.WETH()) {
            path = new address ;
            path[0] = _tokenIn;
            path[1] = _tokenOut;
        } else {
            revert("Invalid token pair");
        }

        IERC20(_tokenIn).approve(address(uniswapRouter), _amount);
        uniswapRouter.swapExactTokensForTokens(_amount, 0, path, address(this), block.timestamp);

        emit SecuritiesSold(address(this), msg.sender, _amount);
    }

    function investFunds(address _token, uint256 _amount) internal {
        require(_amount > 0, "Invalid investment amount");

        IERC20 token = IERC20(_token);
        
        require(token.approve(address(this), _amount), "Approval failed");
       
        require(token.transferFrom(msg.sender, address(this), _amount), "Token transfer failed");

        emit FundsInvested(msg.sender, _token, _amount);
    }

    function updateVotingRights(address _user) internal {
        votingRights[_user] = balances[_user].mul(100).div(totalFunds);
    }

    receive() external payable {}
}