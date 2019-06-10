pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/access/Roles.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

/**
 * @title Aiakos
 * @dev Decentralized Release Management System
 */
contract Aiakos is Ownable  {

  using SafeMath for uint256;
  using Roles for Roles.Role;
  
  Roles.Role private maintainers;

  uint private requiredNumberOfMaintainers;

  constructor (uint _requiredNumberOfMaintainers) public{
    Ownable._transferOwnership(msg.sender);
    require(_requiredNumberOfMaintainers > 0);
    requiredNumberOfMaintainers = _requiredNumberOfMaintainers;
  }
  
  function addMaintainer(address _maintainerAddress)
   public
   onlyOwner
   payable
   nonEmptyAddress(_maintainerAddress)
  {
      maintainers.add(_maintainerAddress);
  }
  
  function amIMaintainer() 
   public
   view
   returns (bool)
  {
      return maintainers.has(msg.sender);
  } 
  
  function isMaintainer(address _maintainerAddress) 
   public
   view
   returns (bool)
  {
      return maintainers.has(_maintainerAddress);
  }  
  
  function getRequiredNumberOfMaintainers() 
   public
   view
   returns (uint)
  {
      return requiredNumberOfMaintainers;
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
