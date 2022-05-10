// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 < 0.9.0;

/// @title Voting with delegation.
contract Ballot {

    // It will represent a single voter.
    struct Voter {
        uint weight; // weight is accumulated by delegation
        bool voted;  // if true, that person already voted
        address delegate; // person delegated to
        uint vote; // index of the voted proposal
    }

    struct Proposal {
        bytes32 name; // short name (up to 32 bytes)
        uint voteCount; // accumulated votes
    }

    // the creator of the contract who serves as chairperson will give the right to vote to each address individually.
    address public chairperson;

    // This declares a state variable that
    // stores a `Voter` struct for each possible address.
    mapping(address => Voter) public voters;

    // A dynamically-sized array of `Proposal` structs.
    Proposal[] public proposals;

    constructor(bytes32[] memory proposalNames) {
        chairperson = msg.sender;
        
        for (uint256 index = 0; index < proposalNames.length; index++) {
            proposals.push(Proposal({
                name: proposalNames[index],
                voteCount: 0
            }));
        }
    }

    modifier isChairperson() {
        require(chairperson == msg.sender, "Error! Only chairperson is allowed to access.");
        _;
    }

    // calling this function gives right to vote to an address
    // can only be called by chairperson
    function giveRightToVote(address voter) external {
        // It is often a good idea to use `require` to check if
        // functions are called correctly.
        // As a second argument, you can also provide an
        // explanation about what went wrong.

        // 1. Only chairperson can call the function
        // 2. Voter should not have voted already.
        // 3. Voter should not have voting rights already.
        require(chairperson == msg.sender, "Error! Only chairperson is allowed to access.");
        require(!voters[voter].voted, "The voter already voted");
        require(voters[voter].weight == 0);

        // Give the voting rights to the "voter"
        voters[voter].weight = 1;
    }

    /// Delegate your vote to the voter `to`.
    function delegate(address to) external {
        // assigns references
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "You already voted");

        require(to != msg.sender, "You cannot vote yourself");

        // Forward the references as long as "to" is also delegated
        while(sender.delegate != address(0)) {
            to = voters[to].delegate;

            // Loop in delegation not allowed
            require(to != msg.sender, "Found a loop in delegation");
        }

        Voter storage delegate_ = voters[to];
        
        // Voters cannot delegate to voters who cannot vote.
        require(delegate_.weight >= 1);

        sender.voted = true;
        sender.delegate = to;

        if(delegate_.voted) {
            // If the delegate has already voted
            // directly add the number of votes
            proposals[delegate_.vote].voteCount += sender.weight;
        } else {
            // If the delegate did not vote yet,
            // add to her weight.
            delegate_.weight += sender.weight;
        }
    }

    /// Give your vote (including votes delegated to you)
    /// to proposal `proposals[proposal].name`.
    function vote(uint proposal) external {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "Already voted");
        sender.voted = true;
        sender.vote = proposal;

        proposals[proposal].voteCount += sender.weight;
    }

    /// @dev Computes the winning proposal taking all
    /// previous votes into account.
    function winningProposal() public view 
        returns (uint winningProposal_)
    {  
        uint maxVotes;

        for(uint i = 0; i < proposals.length; i++) {
            uint currProposal = proposals[i].voteCount;
            if(currProposal > maxVotes) {
                maxVotes = currProposal;
                winningProposal_ = i;
            }
        }
    }

    // Calls winningProposal() function to get the index
    // of the winner contained in the proposals array and then
    // returns the name of the winner
    function winnerName() external view
            returns (bytes32 winnerName_)
    {
        winnerName_ = proposals[winningProposal()].name;
    }
}