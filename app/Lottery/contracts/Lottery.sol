// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

contract Lottery is VRFConsumerBaseV2, ConfirmedOwner {
    event Purchase(address participant, uint timestamp);
    event Deposit(address indexed sender, uint amount, uint balance);
    event WinnerSelected(address indexed winner, uint amount);

    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);

    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWords;
    }

    mapping(uint256 => RequestStatus)
        public s_requests; /* requestId --> requestStatus */

    VRFCoordinatorV2Interface COORDINATOR;

    bytes32 keyHash =
        0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;
    uint256 public fee;
    uint256 public randomResult;
    uint64 s_subscriptionId;
    uint256[] public requestIds;
    uint256 public lastRequestId;
    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 2;

    address[] private participants;
    uint public ticketPrice;

    uint public TIME_TO_END_LOTTERY = 4 days;
    uint public DEPLOY_TIME;

    constructor(
        uint _ticketPrice,
        uint64 _subscriptionId
    )
        VRFConsumerBaseV2(0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625)
        ConfirmedOwner(msg.sender)
    {
        s_subscriptionId = _subscriptionId;
        ticketPrice = _ticketPrice;
        fee = 1 ether * 0.1; // 0.1 LINK -> 10^17
        DEPLOY_TIME = block.timestamp;
    }

    modifier canPurchaseTicket(uint _price) {
        require(_price == ticketPrice, "Ticket price is not correct");
        _;
    }

    modifier canSelectWinner(uint _currentTime) {
        require(
            block.timestamp >= DEPLOY_TIME + TIME_TO_END_LOTTERY,
            "Cannot select winner before deadline"
        );
        _;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    function purchase() external payable canPurchaseTicket(msg.value) {
        participants.push(address(msg.sender));
        emit Purchase(msg.sender, block.timestamp);
    }

    function getParticipants() external view returns (uint) {
        return participants.length;
    }

    function selectWinner() external payable {
        randomResult =
            (s_requests[lastRequestId].randomWords[0] % participants.length) +
            1;
        address winner = participants[randomResult];
        uint _value = address(this).balance;
        (bool success, ) = address(payable(winner)).call{
            value: _value,
            gas: 10000
        }("0x");
        require(success, "transaction failed");
        emit WinnerSelected(winner, _value);
    }

    // Assumes the subscription is funded sufficiently.
    function requestRandomWords()
        external
        onlyOwner
        returns (uint256 requestId)
    {
        // Will revert if subscription is not set and funded.
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );

        requestIds.push(requestId);
        lastRequestId = requestId;
        return requestId;
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(s_requests[_requestId].exists, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        emit RequestFulfilled(_requestId, _randomWords);
    }

    function getRequestStatus(
        uint256 _requestId
    ) external view returns (bool fulfilled, uint256[] memory randomWords) {
        require(s_requests[_requestId].exists, "request not found");
        RequestStatus memory request = s_requests[_requestId];
        return (request.fulfilled, request.randomWords);
    }
}
