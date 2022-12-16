// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "lib/forge-std/src/Test.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import "../src/Space.sol";

contract SpaceTest is Test, IERC721Receiver {
    Space public space;

    function setUp() public {
        space = new Space();
    }

    function testMint() public {
        space.mint(address(this));
        assertEq(space.totalSupply(), 1);
        assertEq(space.ownerOf(0), address(this));
    }

    function testSetTokenURI(string memory tokenURI) public {
        space.mint(address(this));
        space.setTokenURI(0, tokenURI);
        assertEq(space.tokenURI(0), tokenURI);
    }

    function testFailSetTokenURI(string memory tokenURI) public {
        space.setTokenURI(0, tokenURI);
    }

    function testFailSetTokenURINotOwner(string memory tokenURI) public {
        space.mint(address(1));
        space.setTokenURI(0, tokenURI);
    }

    function testFailSetTokenURIInvalidTokenId(string memory tokenURI) public {
        space.mint(address(this));
        space.setTokenURI(1, tokenURI);
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