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
    
    /**
    * @dev Initializes a release with provided data.
    * @param version The version of the release.
    * @param sha256Hash The integrity hash(SHA256) of the release.
    */ 
    function init(Release storage release, string memory version, bytes32 sha256Hash)
     internal
    {
        release.initialized = true;
        release.version = version;
        release.sha256Hash = sha256Hash;
    }
    
    /**
    * @dev Checks release integrity, compare genuine hash to the input hash.
    * @param sha256Hash The input integrity hash(SHA256).
    */ 
    function check(Release storage release, bytes32 sha256Hash)
     internal
     view
    {
        if(release.sha256Hash != sha256Hash){
            revert("Aiakos.Releases.check: Mistmatch release hashes.");
        }
    }
    
    /**
    * @dev Adds approval for a specific maintainer and a specific release version.
    * @dev Emits a ReleaseApproved event if last approval.
    * @param maintainer The address of the maintainer.
    * @param requiredNumberOfMaintainers The minimum number of approvals to trigger the actual release deployment.
    */ 
    function addApproval(Release storage release, address maintainer, uint requiredNumberOfMaintainers)
     internal
     onlyNotApprovedRelease(release)
     returns (bool approvalGranted, bool releaseApproved)
    {
        // Check if maintainer has already given an approval for this version.
        if(release.approvals[maintainer] == true){
            revert("Aiakos.Releases.addApproval: Maintainer already approved this release.");
        }
        // Give maintainer approval.
        release.approvals[maintainer] = true;
        approvalGranted = true;
        // Increment approval counter.
        release.approvalCounter++;
        // Check if it is the last approval required.
        if(release.approvalCounter == requiredNumberOfMaintainers){
            // Approve the release definitely.
            release.approved = true;
            releaseApproved = true;
        }
    }
    
    modifier onlyNotApprovedRelease(Release storage release)
    {
        require(release.approved != true, "Release already approved.");
        _;
    }

}
