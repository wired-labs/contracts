// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

/*
 * A basic ERC721 token that can be minted by anyone.
 * The owner of the token can set the tokenURI.
 */
contract URIStorage is ERC721URIStorage {
    uint256 count;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    function mint(address to) public returns (uint256) {
        _mint(to, count);
        count++;
        return count - 1;
    }

    function setTokenURI(uint256 tokenId, string memory tokenURI) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "Caller is not owner nor approved");
        _setTokenURI(tokenId, tokenURI);
    }

    function totalSupply() public view returns (uint256) {
        return count;
    }
}
