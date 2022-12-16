// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "./URIStorage.sol";

/*
 * Represents a user profile.
 * A profile contains a URI, which points to a JSON file containing the profile metadata.
 * A profile has an optional human-readable handle, which is a string of text followed by a number.
 * For example, "handle#201".
 * The number increments to avoid duplicate handles.
 * The handle can be changed any time by the owner of the profile.
 */
contract Profile is URIStorage {
    // String part of the handle
    mapping(uint256 => string) private _handles;

    // Number part of the handle
    mapping(uint256 => uint256) private _handleIds;

    // Counter for the number part of the handle
    mapping(string => uint256) private _handleIdCounters;

    constructor() URIStorage("Profile", "PROFILE") {}

    function setHandle(uint256 tokenId, string memory newHandle) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "Profile: caller is not owner nor approved");
        require(bytes(newHandle).length > 0, "Profile: handle cannot be empty");

        // Increment the handle counter
        uint256 handleId = _handleIdCounters[newHandle];
        _handleIdCounters[newHandle]++;

        // Set the handle
        _handles[tokenId] = newHandle;
        _handleIds[tokenId] = handleId;
    }

    function handle(uint256 tokenId) public view returns (string memory) {
        return string(abi.encodePacked(_handles[tokenId], "#", _handleIds[tokenId]));
    }
}
