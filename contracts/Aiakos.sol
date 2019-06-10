pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

/**
 * @title Aiakos
 * @dev Decentralized Release Management System
 */
contract Aiakos is Ownable  {

  using SafeMath for uint256;

  constructor () public{
      
  }
  
  /**
  * @dev Allows the current owner to transfer control of the contract to a newOwner.
  * @param _newOwner address of the new owner
  */
  function transferOwnership(address _newOwner)
   public
   nonEmptyAddress(_newOwner)
   onlyOwner
  {
    Ownable.transferOwnership(_newOwner);
  }

  /**
  * @dev Throws if address is empty
  */
  modifier nonEmptyAddress(address value){
    require(value != address(0));
    _;
  }

}
