// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingPollFactory {
    // Array to store addresses of all deployed VotingPoll contracts
    address[] public deployedPolls;

    // Event to emit when a new VotingPoll contract is deployed
    event PollDeployed(address indexed pollAddress, address indexed creator);

    // Function to create a new instance of VotingPoll contract
    function createPoll(string memory _question, string[] memory _options) public {
        address newPoll = address(new VotingPoll(_question, _options, msg.sender));
        deployedPolls.push(newPoll);
        
        emit PollDeployed(newPoll, msg.sender);
    }

    // Function to get all deployed VotingPoll contracts
    function getDeployedPolls() public view returns (address[] memory) {
        return deployedPolls;
    }
}

contract VotingPoll {
    struct Poll {
        address creator;
        string question;
        string[] options;
        mapping(string => uint256) votes;
        mapping(address => bool) hasVoted;
        bool isOpen;
    }

    mapping(uint256 => Poll) public polls;
    uint256 public pollCount;

    event PollCreated(
        uint256 pollId,
        address creator,
        string question,
        string[] options
    );
    event Voted(uint256 pollId, address voter, string option);

    constructor(string memory _question, string[] memory _options, address _creator) {
        require(_options.length > 1, "Must have at least 2 options");

        pollCount++;
        polls[pollCount] = Poll(_creator, _question, _options, false);

        emit PollCreated(pollCount, _creator, _question, _options);
    }

    function vote(uint256 _pollId, string memory _option) external {
        Poll storage poll = polls[_pollId];

        require(poll.isOpen, "Poll is not open for voting");
        require(
            !poll.hasVoted[msg.sender],
            "You have already voted in this poll"
        );
        require(bytes(_option).length > 0, "Option must not be empty");

        poll.votes[_option]++;
        poll.hasVoted[msg.sender] = true;

        emit Voted(_pollId, msg.sender, _option);
    }

    function openPoll(uint256 _pollId) external {
        require(
            msg.sender == polls[_pollId].creator,
            "Only the creator can open the poll"
        );
        polls[_pollId].isOpen = true;
    }

    function closePoll(uint256 _pollId) external {
        require(
            msg.sender == polls[_pollId].creator,
            "Only the creator can close the poll"
        );
        polls[_pollId].isOpen = false;
    }

    function getPollOptions(uint256 _pollId) external view returns (string[] memory) {
        return polls[_pollId].options;
    }

    function getPollVotes(uint256 _pollId, string memory _option) external view returns (uint256) {
        return polls[_pollId].votes[_option];
    }

    function hasVoted(uint256 _pollId, address _voter) external view returns (bool) {
        return polls[_pollId].hasVoted[_voter];
    }
}
