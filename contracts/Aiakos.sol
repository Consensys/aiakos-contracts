pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/access/Roles.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./Releases.sol";

/**
 * @title Aiakos
 * @dev Decentralized Release Management System
 */
contract Aiakos is Ownable  {

  using Roles for Roles.Role;
  using Releases for Releases.Release;

  // Whitelist of maintainers allowed to give approval for a release version.
  Roles.Role private maintainers;

  // Minimum number of maintainers before approving a release and consider it as valid.
  uint private requiredNumberOfMaintainers;
  // Record of all releases.
  mapping(string => Releases.Release) releases;
  // Triggered when a new maintainer is added to the whitelist.
  event MaintainerAdded(address indexed maintainer);
  // Triggered when a maintainer grants approval.
  event ApprovalGranted(address maintainer, string version);
  // Triggered when a new release has been approved.
  event ReleaseApproved(string version);


  /**
  * @dev Deploys a new Aiakos contract.
  * @param _requiredNumberOfMaintainers The required number of maintainers to deploy a release.
  */
  constructor (uint _requiredNumberOfMaintainers) public{
      Ownable._transferOwnership(msg.sender);
      require(_requiredNumberOfMaintainers > 0);
      requiredNumberOfMaintainers = _requiredNumberOfMaintainers;
  }

  /**
  * @dev Adds a maintainer to the whitelist.
  * @dev Only owner of the contract can call this function.
  * @param _maintainerAddress The address of the maintainer account to add.
  */
  function addMaintainer(address _maintainerAddress)
   public
   onlyOwner
   payable
   nonEmptyAddress(_maintainerAddress)
  {
      maintainers.add(_maintainerAddress);
      emit MaintainerAdded(_maintainerAddress);
  }

  /**
  * @dev Deploys a release. A maintainer add its approval for a specific version of the release.
  * @dev If maintainer is the last to approve, the release is approved definitely and a ReleaseApproved event is emitted.
  * @dev Only whitelisted maintainers can call this function.
  * @param _version The version code of the release.
  * @param _sha256Hash The integrity hash(SHA256) of the release.
  */
  function deployRelease(string memory _version, bytes32 _sha256Hash)
   public
   onlyMaintainer
   payable
  {
      // Get release from storage
      Releases.Release storage release = releases[_version];
      // Check if release was already approved.
      if(release.approved){
        revert("Aiakos.deployRelease: Release already approved.");
      }
      // Initialize release if first approval.
      if(!release.initialized){
        release.init(_version, _sha256Hash);
      }
      // Check if hash matches previously stored hash.
      else{
        release.check(_sha256Hash);
      }
      // Add approval for the current maintainer.
      (bool approvalGranted, bool releaseApproved) = release.addApproval(msg.sender, requiredNumberOfMaintainers);
      if(approvalGranted){
        // Emit an event to notify a new approval has been granted.
        emit ApprovalGranted(msg.sender, _version);
      }
      if(releaseApproved){
        // Emit an event to notify a new version has been approved.
        emit ReleaseApproved(release.version);
      }
  }

  /**
  * @dev Checks the release integrity given the input hash.
  * @param _version The version of the release to check.
  * @param _sha256Hash The integrity hash to compare to valid hash.
  */
  function checkRelease(string memory _version, bytes32 _sha256Hash)
   public
   view
   returns(bool)
  {
      // Revert if invalid hash is provided.
      if(_sha256Hash == 0x0){
        revert("Aiakos.checkRelease: Invalid input hash.");
      }
      // Get release from storage.
      Releases.Release storage release = releases[_version];
      // Revert if release does not exist.
      if(!release.initialized){
        revert("Aiakos.checkRelease: Release does not exist.");
      }
      // Revert is release not yet approved.
      if(!release.approved){
        revert("Aiakos.checkRelease: Release not approved.");
      }
      // Compare the input hash to the one stored for the approved release.
      release.check(_sha256Hash);
      return true;
  }

  /**
  * @dev Gets release informations.
  * @param _version The version of the release.
  */
  function getReleaseInfo(string memory _version)
   public
   view
   returns (string memory, bytes32, bool, bool)
  {
      // Get release from storage.
      Releases.Release storage release = releases[_version];
      // Revert if release does not exist.
      if(release.initialized == false){
        revert("Aiakos.getReleaseInfo: Release does not exist.");
      }
      return (release.version, release.sha256Hash, release.initialized, release.approved);
  }

  /**
  * @dev Checks if msg.sender is a whitelisted maintainer.
  */
  function amIMaintainer()
   public
   view
   returns (bool)
  {
      return maintainers.has(msg.sender);
  }

  /**
  * @dev Checks if an address belongs to a whitelisted maintainers.
  * @param _maintainerAddress The maintainer address.
  */
  function isMaintainer(address _maintainerAddress)
   public
   view
   returns (bool)
  {
      return maintainers.has(_maintainerAddress);
  }

  /**
  * @dev Returns the required number of maintainers.
  */
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
  modifier nonEmptyAddress(address value)
  {
    require(value != address(0));
    _;
  }

  modifier onlyMaintainer()
  {
    require(maintainers.has(msg.sender), "Aiakos: caller is not a maintainer.");
    _;
  }

}
