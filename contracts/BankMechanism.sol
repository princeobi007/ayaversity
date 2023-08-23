// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BankMechanism{

    address internal ownerAddress;
    mapping(address => uint256) internal bankAccounts;
    mapping(address => bool) internal authorisedAccountOwners;
    uint256 private minimumAccountOpeningBalance;

    constructor(){
        ownerAddress = msg.sender;
        minimumAccountOpeningBalance = 2 * 1e15 wei;
    }

    /* onlyOwner modifer to decorate functions that only the owner can call*/
    modifier onlyOwner{
        require(msg.sender == ownerAddress,"Only the owner can call this function");
        _;
    }

    modifier authroisedAddresses{
        require(authorisedAccountOwners[msg.sender]);
        _;
    }

    modifier minimumAmountToOpenAccount{
        require(msg.value >= minimumAccountOpeningBalance);
        _;
    }

    modifier balanceLessThanTransactionAmount{
        require(bankAccounts[msg.sender] > msg.value, "You do not have sufficent balance to perform this transaction");
        _;
    }

    function openAccount () public payable  minimumAmountToOpenAccount{
        bankAccounts[msg.sender] = msg.value;
        authorisedAccountOwners[msg.sender] = true;
    }

    function deposit () public payable  authroisedAddresses returns (uint256){
        bankAccounts[msg.sender] += msg.value;
        return bankAccounts[msg.sender];
    }

    function checkBalanceByContractOwner(address accountOwner) public view onlyOwner returns(uint){
        return bankAccounts[accountOwner];
    }

    function checkBalanceByAccountOwner() public view authroisedAddresses returns (uint256){
        return bankAccounts[msg.sender];
    }

    function transfer(address payable recipient) public payable authroisedAddresses balanceLessThanTransactionAmount returns (bool){

        if(msg.value < bankAccounts[msg.sender]){
            recipient.transfer(msg.value);
            bankAccounts[msg.sender] -= msg.value;
            return true;
        }
        return false;
    }  
}