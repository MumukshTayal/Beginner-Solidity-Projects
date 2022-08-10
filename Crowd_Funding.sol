// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

contract CrowdFunding {
    address public owner;
    uint256 public minimumContribution;
    uint256 public deadline;
    uint256 public target;
    uint256 public raisedAmount;
    uint256 public totalContributors;
    uint256 public numRequests;

    struct Request {
        string description;
        address payable recipient;
        uint256 value;
        bool completed;
        uint256 noOfVoters;
        mapping(address => bool) voters;
    }

    mapping(uint256 => Request) public allRequests;
    mapping(address => uint256) public contributors;

    constructor(uint256 _target, uint256 _deadline) {
        owner = msg.sender;
        deadline = block.timestamp + _deadline;
        target = _target;
        minimumContribution = 0.01 ether;
    }

    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can access this function.");
        _;
    }

    modifier isDeadlinePassed() {
        require(
            block.timestamp < deadline,
            "Crowd Funding deadline has passed. Please try again later."
        );
        _;
    }

    modifier isContributor() {
        require(contributors[msg.sender] > 0, "Sorry, you are not a contributor. Try to contribute to crowd funding then try again. Thanks.");
        _;
    }

  
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // Contribute
    function contribute() public payable isDeadlinePassed {
        require(
            msg.value >= minimumContribution,
            "Minimum 0.01 ether is required to contribute."
        );

        if (contributors[msg.sender] == 0) {
            totalContributors++;
        }

        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;
    }

    function refund() public isDeadlinePassed isContributor {
        require(raisedAmount < target, "You are not eligible for refund");
        require(contributors[msg.sender] > 0);

        address payable user = payable(msg.sender);
        user.transfer(contributors[msg.sender]);
    }

    function createRequest(
        string memory _description, address payable _recipient, uint256 _value) public onlyOwner {
        Request storage newRequest = allRequests[numRequests];
        numRequests++;

        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.noOfVoters = 0;
    }

    function voteRequest(uint256 _requestNo) public isContributor {
        Request storage currentRequest = allRequests[_requestNo];
        require(currentRequest.voters[msg.sender] == false, "you have already voted");
        currentRequest.voters[msg.sender] = true;
        currentRequest.noOfVoters++;
    }

    function makePayment(uint _requestNo) public onlyOwner{
        require(raisedAmount >= target);
        Request storage currentRequest = allRequests[_requestNo];
        require(currentRequest.completed == false, "This request has already completed");
        require(currentRequest.noOfVoters > totalContributors/2, "Contributor does not support. Votes are low.");
        currentRequest.recipient.transfer(currentRequest.value);

    }
}