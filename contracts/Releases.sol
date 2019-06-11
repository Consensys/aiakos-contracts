pragma solidity ^0.5.0;

/**
 * @title Releases
 * @dev Library for managing Releases.
 */
library Releases {
    struct Release {
        string version;
        bytes32 sha256Hash;
        mapping(address => bool) approvals;
        uint approvalCounter;
        bool initialized;
        bool approved;
    }
    
    function init(Release storage release, string memory version, bytes32 sha256Hash)
     internal
    {
        release.initialized = true;
        release.version = version;
        release.sha256Hash = sha256Hash;
    }
    
    function check(Release storage release, bytes32 sha256Hash)
     internal
     view
    {
        if(release.sha256Hash != sha256Hash){
            revert("Aiakos.Releases.check: Mistmatch release hashes.");
        }
    }
    
    function addApproval(Release storage release, address maintainer, uint requiredNumberOfMaintainers)
     internal
     onlyNotApprovedRelease(release)
    {
        if(release.approvals[maintainer] == true){
            revert("Aiakos.Releases.addApproval: Maintainer already approved this release.");
        }
        release.approvals[maintainer] = true;
        release.approvalCounter++;
        if(release.approvalCounter == requiredNumberOfMaintainers){
            release.approved = true;
            emit ReleaseApproved(release.version);
        }
    }
    
    event ReleaseApproved(string version);
    
    modifier onlyNotApprovedRelease(Release storage release)
    {
        require(release.approved != true, "Release already approved.");
        _;
    }

}
