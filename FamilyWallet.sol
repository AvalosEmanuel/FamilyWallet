// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title FamilyWallet..
 * @dev Family wallet with adherents and specific amounts for each of them, 
 * access restricted only to the owner in certain functions..
 */
contract FamilyWallet is Ownable {
    uint private familyAmount;
    
    mapping(address => uint) public membersBalance;
    
    event NewAutorized(address indexed _owner, address indexed _family, uint _membersBalance);
    event PaymentMade(address indexed _from, address _to, uint _amount);
    event ModifiedFamilyAmount(address indexed _owner, uint _newFamilyAmount);
    event ModifiedDelegatedAmount(address indexed _owner, uint _newDelegatedAmount);
    
    
    constructor(uint _familyAmount) {
        familyAmount = _familyAmount;
    }
    
    /**
     * @dev Function that authorizes a new family member..
     * @param _family address of the new adherent..
     * @param _memberBalance amount available to the new adherent..
     */
    function addFamily(address _family, uint _memberBalance) external payable onlyOwner {
        membersBalance[_family] = _memberBalance;
        setReduceFamilyAmount(_memberBalance);
        emit NewAutorized(msg.sender, _family, _memberBalance);
    }
    
    /**
     * @dev Function to make payments by the owner..
     * @param _to address to whom the payment is directed..
     * @param _amount payment amount..
     */
    function ownerPayment(address _to, uint _amount) external payable onlyOwner {
        familyAmount -= _amount;
        emit PaymentMade(msg.sender, _to, _amount);
    }
    
    /**
     * @dev Function to make payments for members..
     * @param _from address of who makes the payment..
     * @param _to address to whom the payment is directed..
     * @param _amount payment amount..
     */
    function memberPayment(address _from, address _to, uint _amount) external payable {
        require(membersBalance[_from] >= _amount);
        membersBalance[_from] -= _amount;
        emit PaymentMade(_from, _to, _amount);
    }
      
    function getFamilyAmount() public view returns(uint) {
        return familyAmount;
    }
    
    /**
     * @dev Function that increases family funds..
     * @param _amount value entered into the fund..
     */
    function setFamilyAmount(uint _amount) public payable onlyOwner {
        familyAmount += _amount;
        emit ModifiedFamilyAmount(msg.sender, _amount);
    }
    
    /**
     * @dev Function that reduces family funds, necessary in internal operations within other functions..
     * @param _amount reduced fund amount..
     */
    function setReduceFamilyAmount(uint _amount) internal onlyOwner {
        familyAmount -= _amount;
        emit ModifiedFamilyAmount(msg.sender, _amount);
    }
    
    /**
     * @dev Function that increases members balance..
     * @param _family address to whom the funds increase..
     * @param _amount value entered into the fund..
     */
    function setDelegateBalance(address _family, uint _newDelegatedBalance) external payable onlyOwner {
        membersBalance[_family] += _newDelegatedBalance;
        setReduceFamilyAmount(_newDelegatedBalance);
        emit ModifiedDelegatedAmount(msg.sender, _newDelegatedBalance);
    }
 }