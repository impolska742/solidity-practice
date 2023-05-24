// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

contract MultiSig {
    event Deposit(address indexed sender, uint amount, uint balance);
    event Submit(
        address indexed owner,
        uint indexed txIndex,
        address indexed to,
        uint value,
        bytes data
    );
    event Approve(address indexed owner, uint indexed txIndex);
    event Reject(address indexed owner, uint indexed txIndex);
    event Execute(address indexed owner, uint indexed txIndex);

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        uint totalConfirmations;
    }

    address[] public owners;
    Transaction[] public transactions;
    mapping(address => bool) public isOwner;
    uint private totalConfirmationsRequired;
    mapping(uint => mapping(address => bool)) isApproved;

    constructor(address[] memory _owners, uint _totalConfirmationsRequired) {
        require(_owners.length > 0, "Owners are required");
        require(
            _totalConfirmationsRequired > 0 &&
                _totalConfirmationsRequired <= _owners.length,
            "Invalid total confirmations provided"
        );

        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];

            require(owner != address(0), "Invalid owner address");
            require(!isOwner[owner], "Not an owner");

            isOwner[owner] = true;
            owners.push(owner);
        }

        totalConfirmationsRequired = _totalConfirmationsRequired;
    }

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not Owner!");
        _;
    }

    modifier txExists(uint _txIndex) {
        require(
            _txIndex >= 0 && _txIndex < transactions.length,
            "Transaction does not exist"
        );
        _;
    }

    modifier notExecuted(uint _txIndex) {
        require(
            !transactions[_txIndex].executed,
            "Transaction has been executed"
        );
        _;
    }

    modifier notApproved(uint _txIndex) {
        require(
            !isApproved[_txIndex][msg.sender], 
            "Transaction already approved"
        );
        _;
    }

    function getTotalConfirmationsRequired()
        external
        view
        onlyOwner
        returns (uint)
    {
        return totalConfirmationsRequired;
    }

    function submit(
        address _to,
        uint _value,
        bytes memory _data
    ) public onlyOwner {
        uint txIndex = transactions.length;

        transactions.push(
            Transaction({
                to: _to,
                value: _value,
                data: _data,
                executed: false,
                totalConfirmations: 0
            })
        );

        isApproved[txIndex][msg.sender] = true;

        emit Submit(msg.sender, txIndex, _to, _value, _data);
    }

    function approve(
        uint _txIndex
    ) 
        public 
        onlyOwner 
        txExists(_txIndex) 
        notExecuted(_txIndex)
        notApproved(_txIndex)
    {
        // Transaction memory tx = transactions[_txIndex];
        isApproved[_txIndex][msg.sender] = true;
    }

    function reject() external {}

    function execute() external {}

    receive() external payable {}
}
