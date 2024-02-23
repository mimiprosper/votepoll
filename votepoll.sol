// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingPoll {
    //  struct to represent each poll, with details like the creator's address, the question, options, vote count for each option, and whether it's open for voting.
    struct Poll {
        address creator;
        string question;
        string[] options;
        mapping(string => uint256) votes;
        mapping(address => bool) hasVoted;
        bool isOpen;
    }

    // mapping to store each poll
    mapping(uint256 => Poll) public polls;
    uint256 public pollCount;

    // event to emit when a poll is created
    event PollCreated(
        uint256 pollId,
        address creator,
        string question,
        string[] options
    );
    event Voted(uint256 pollId, address voter, string option);

    // to create a new poll
    function createPoll(
        string memory _question,
        string[] memory _options
    ) external {
        require(_options.length > 1, "Must have at least 2 options");

        pollCount++;
        polls[pollCount] = Poll(msg.sender, _question, _options, false);

        emit PollCreated(pollCount, msg.sender, _question, _options);
    }

    // to vote in a poll
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

    // to open a poll
    function openPoll(uint256 _pollId) external {
        require(
            msg.sender == polls[_pollId].creator,
            "Only the creator can open the poll"
        );
        polls[_pollId].isOpen = true;
    }

    // to close a poll
    function closePoll(uint256 _pollId) external {
        require(
            msg.sender == polls[_pollId].creator,
            "Only the creator can close the poll"
        );
        polls[_pollId].isOpen = false;
    }

    // to get the details of a poll
    function getPollOptions(
        uint256 _pollId
    ) external view returns (string[] memory) {
        return polls[_pollId].options;
    }

    // to get the details of a poll
    function getPollVotes(
        uint256 _pollId,
        string memory _option
    ) external view returns (uint256) {
        return polls[_pollId].votes[_option];
    }

    // to check if a voter has voted in a poll
    function hasVoted(
        uint256 _pollId,
        address _voter
    ) external view returns (bool) {
        return polls[_pollId].hasVoted[_voter];
    }
}
