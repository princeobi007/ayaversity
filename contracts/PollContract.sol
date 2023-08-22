// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PollContract {

    address private ownerAddress;
    mapping(address => bool) internal pollCreators;
    mapping(address => mapping(string => Poll)) internal pollMapping;

    struct Poll {
        string description;
        address[] canidates;
        uint256[] candidatesVote;
    }

    // Custom data structure to hold poll information
    struct PollInfo {
        string name;
        string description;
        address[] canidates;
        uint256[] votes;
    }

    constructor() {
        ownerAddress = msg.sender;
    }

    /*
     onlyOwner : used to decorate functions that only the owner of the contract can access
    */

    modifier onlyOwner {
        require(
            msg.sender == ownerAddress,
            "Only contract owner can perfom this action"
        );
        _;
    }
    /*
     authorisedPollCrerator : used to decorate functions that only the authorisedPollCrerators can access
    */
    modifier authorisedPollCreator{
        require(
            pollCreators[msg.sender],
            "Only authorised Poll Creators can perfom this action"
        );
        _;
    }

    /*
     modifier to limit vote cast per address per poll to 1
     */

    modifier hasCastedVote(address pollOwner, string memory pollName){
        Poll storage poll = pollMapping[pollOwner][pollName];

        bool voteCasted = false;

        for (uint256 count = 0; count < poll.canidates.length; count++){
            if(poll.canidates[count] == msg.sender){
                voteCasted = true;
            }
        }
        require(!voteCasted,"You can only cast one vote");

        _;
    }

    function authrisePollCreator(address pollCreator, bool authorisation)
        external
        onlyOwner
    {
        pollCreators[pollCreator] = authorisation;
    }

    function getPollByCreator(address pollCreator, string memory pollName)
        public
        view
        returns (PollInfo memory)
    {
        Poll storage poll = pollMapping[pollCreator][pollName];
        return
            PollInfo(
                pollName,
                poll.description,
                poll.canidates,
                poll.candidatesVote
            );
    }

    function createPoll(
        string memory pollName,
        string memory description,
        address[] memory candidates
    ) external authorisedPollCreator {
        Poll memory poll;
        poll.description = description;
        poll.canidates = candidates;
        poll.candidatesVote = new uint256[](candidates.length);
        pollMapping[msg.sender][pollName] = poll;
    }

    function listCandidatesInAPoll(string memory pollName)
        public
        view
        authorisedPollCreator
        returns (address[] memory)
    {
        Poll storage poll = pollMapping[msg.sender][pollName];
        return poll.canidates;
    }

    function voteCandidateInPoll(address candidate, address pollOwner,string memory pollName) public  hasCastedVote( pollOwner, pollName) {
       Poll storage poll = pollMapping[pollOwner][pollName];
       uint256 candidateIndex = 0;

       for(uint256 count = 0; count < poll.canidates.length; count++){
           if(poll.canidates[count] == candidate){
               candidateIndex = count;
           }
       }
       poll.candidatesVote[candidateIndex] = poll.candidatesVote[candidateIndex] + 1;
    }
}
