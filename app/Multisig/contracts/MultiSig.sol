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

    // uint public totalOwners;
    // uint public totalTransactions;
    address[] public owners;
    Transaction[] public transactions;
    mapping(address => bool) public isOwner;
    uint private totalConfirmationsRequired;
    mapping(uint => mapping(address => bool)) private isApproved;

    constructor(address[] memory _owners, uint _totalConfirmationsRequired) payable {
        require(_owners.length > 1, "More than 2 Owners are required");
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

    modifier canExecute(uint _txIndex) {
        require(
            transactions[_txIndex].totalConfirmations >= totalConfirmationsRequired,
            "Transaction not approved by enough owners"
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

    function getTotalTransactions() external view returns (uint) {
        return transactions.length;
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
                totalConfirmations: 1
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
        Transaction storage transaction = transactions[_txIndex];
        isApproved[_txIndex][msg.sender] = true;
        transaction.totalConfirmations += 1;

        emit Approve(msg.sender, _txIndex);
    }

    function reject(uint _txIndex) 
        public
        onlyOwner
        txExists(_txIndex) 
        notExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];
        isApproved[_txIndex][msg.sender] = false;

        if(transaction.totalConfirmations != 0) {
            transaction.totalConfirmations -= 1;
        }

        emit Reject(msg.sender, _txIndex);
    }

    function execute(uint _txIndex) 
        public 
        payable
        onlyOwner
        txExists(_txIndex) 
        canExecute(_txIndex)
        notExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];
        transaction.executed = true;
        (bool success, ) = address(payable(transaction.to)).call{value : transaction.value, gas: 10000}(transaction.data);
        
        require(success, "transaction failed");

        emit Execute(msg.sender, _txIndex);
    }

    function getBalance() external view returns (uint) {
        return address(this).balance;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }
}

// 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 -> owner1
// 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4 -> owner2

// Contract Address -> 0x7EF2e0048f5bAeDe046f6BF797943daF4ED8CB47
// ["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4", "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2"], 2 -> deploy
// "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db", 1000000000000000000, 0x00 -> submit