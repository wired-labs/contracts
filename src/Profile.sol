// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "./URIStorage.sol";

/*
 * Represents a user profile.
 * A profile contains a URI, which points to a JSON file containing the profile metadata.
 * A profile has an optional human-readable handle, which is a string of text followed by a number.
 * For example, "alice#4072".
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

    // Address => Default profile id
    mapping(address => uint256) private _defaultProfiles;

    // Maximum length of a handle string
    uint256 public constant MAX_HANDLE_LENGTH = 16;

    constructor() URIStorage("Profile", "PROFILE") {}

    // Mint and set handle in one transaction
    function mintWithHandle(string memory handle) public returns (uint256, uint256) {
        uint256 tokenId = super.mint();

        uint256 handleId = setHandle(tokenId, handle);

        // If no default profile is set, set this one as default
        if (_defaultProfiles[_msgSender()] == 0) {
            _defaultProfiles[_msgSender()] = tokenId;
        }

        return (tokenId, handleId);
    }

    function setHandle(uint256 tokenId, string memory newHandle) public returns (uint256) {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "Profile: caller is not owner nor approved");
        require(bytes(newHandle).length > 0, "Profile: handle cannot be empty");
        require(bytes(newHandle).length <= MAX_HANDLE_LENGTH, "Profile: handle is too long");

        // Increment handle counter
        _handleIdCounters[newHandle]++;
        uint256 handleId = _handleIdCounters[newHandle];

        // Set handle
        _handles[tokenId] = newHandle;
        _handleIds[tokenId] = handleId;

        return handleId;
    }

    function setDefaultProfile(uint256 tokenId) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "Profile: caller is not owner nor approved");

        _defaultProfiles[_msgSender()] = tokenId;
    }

    function getDefaultProfile(address owner) public view returns (uint256) {
        return _defaultProfiles[owner];
    }

    function getHandle(uint256 tokenId) public view returns (string memory, uint256) {
        return (_handles[tokenId], _handleIds[tokenId]);
    }

    function getProfileFromHandle(string memory handle, uint256 handleId) public view returns (uint256) {
        // Loop through all profiles
        for (uint256 i = 0; i <= count; i++) {
            if (_handleIds[i] == handleId && keccak256(bytes(_handles[i])) == keccak256(bytes(handle))) {
                return i;
            }
        }

        revert("Profile: profile not found");
    }

    function burn(uint256 tokenId) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "Profile: caller is not owner nor approved");

        super._burn(tokenId);

        // Delete handle
        delete _handles[tokenId];
        delete _handleIds[tokenId];

        // If the default profile is being burned, set the default profile to 0
        if (_defaultProfiles[_msgSender()] == tokenId) {
            _defaultProfiles[_msgSender()] = 0;
        }
    }
}
