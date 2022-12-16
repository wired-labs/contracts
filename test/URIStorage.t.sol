// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "lib/forge-std/src/Test.sol";
import "../src/URIStorage.sol";

contract URIStorageTest is Test {
    URIStorage public uriStorage;

    function setUp() public {
        uriStorage = new URIStorage("URIStorage", "URI");
        startHoax(address(1));
    }

    function testMint() public {
        uint256 tokenId = uriStorage.mint(address(1));

        assertEq(uriStorage.totalSupply(), 1);
        assertEq(uriStorage.ownerOf(tokenId), address(1));
    }

    function testSetTokenURI(string memory tokenURI) public {
        uint256 tokenId = uriStorage.mint(address(1));
        uriStorage.setTokenURI(tokenId, tokenURI);

        assertEq(uriStorage.tokenURI(tokenId), tokenURI);
    }

    function testFailSetTokenURI(string memory tokenURI) public {
        uriStorage.setTokenURI(0, tokenURI);
    }

    function testFailSetTokenURINotOwner(string memory tokenURI) public {
        uint256 tokenId = uriStorage.mint(address(2));
        uriStorage.setTokenURI(tokenId, tokenURI);
    }

    function testFailSetTokenURIInvalidTokenId(string memory tokenURI) public {
        uint256 tokenId = uriStorage.mint(address(1));
        uriStorage.setTokenURI(tokenId + 1, tokenURI);
    }
}
