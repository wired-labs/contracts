// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "lib/forge-std/src/Test.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import "../src/URIStorage.sol";

contract URIStorageTest is Test, IERC721Receiver {
    URIStorage public uriStorage;

    function setUp() public {
        uriStorage = new URIStorage("URIStorage", "URI");
    }

    function testMint() public {
        uriStorage.mint(address(this));
        assertEq(uriStorage.totalSupply(), 1);
        assertEq(uriStorage.ownerOf(0), address(this));
    }

    function testSetTokenURI(string memory tokenURI) public {
        uriStorage.mint(address(this));
        uriStorage.setTokenURI(0, tokenURI);
        assertEq(uriStorage.tokenURI(0), tokenURI);
    }

    function testFailSetTokenURI(string memory tokenURI) public {
        uriStorage.setTokenURI(0, tokenURI);
    }

    function testFailSetTokenURINotOwner(string memory tokenURI) public {
        uriStorage.mint(address(1));
        uriStorage.setTokenURI(0, tokenURI);
    }

    function testFailSetTokenURIInvalidTokenId(string memory tokenURI) public {
        uriStorage.mint(address(this));
        uriStorage.setTokenURI(1, tokenURI);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}