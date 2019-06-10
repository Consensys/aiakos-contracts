pragma solidity ^0.5.0;

/**
 * @title Releases
 * @dev Library for managing Releases.
 */
library Releases {
    struct Release {
        string version;
        bytes32 sha256Hash;
        bool initialized;
        bool approved;
    }

}
