// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "./URIStorage.sol";

/*
 * Represents a user profile.
 * A profile contains a URI, which points to a JSON file containing the profile metadata.
 * A profile has an optional human-readable handle, which is a string of text followed by a number.
 * For example, "handle#201".
 * The number increments to avoid duplicate handles.
 * The handle can be changed at any time by the owner of the profile.
 */
contract Profile is URIStorage {
    // Profile id => string part of the handle
    mapping(uint256 => string) private _handles;

    // Profile id => number part of the handle
    mapping(uint256 => uint256) private _handleIds;

    // Handle string => Counter for the handle id
    mapping(string => uint256) private _handleIdCounters;

    // Maximum length of a handle string
    uint256 public constant MAX_HANDLE_LENGTH = 16;

    constructor() URIStorage("Profile", "PROFILE") {}

    function setHandle(uint256 tokenId, string memory newHandle) public returns (uint256) {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "Profile: caller is not owner nor approved");
        require(bytes(newHandle).length > 0, "Profile: handle cannot be empty");
        require(bytes(newHandle).length <= MAX_HANDLE_LENGTH, "Profile: handle is too long");

        // Increment handle counter
        uint256 handleId = _handleIdCounters[newHandle];
        _handleIdCounters[newHandle]++;

        // Set handle
        _handles[tokenId] = newHandle;
        _handleIds[tokenId] = handleId;

        return handleId;
    }

    function getHandle(uint256 tokenId) public view returns (string memory, uint256) {
        return (_handles[tokenId], _handleIds[tokenId]);
    }

    function getProfileFromHandle(string memory handle, uint256 handleId) public view returns (uint256) {
        // Loop through all profiles
        for (uint256 i = 0; i < count; i++) {
            if (_handleIds[i] == handleId && keccak256(bytes(_handles[i])) == keccak256(bytes(handle))) {
                return i;
            }
        }

        // Not found
        return 0;
    }
}
