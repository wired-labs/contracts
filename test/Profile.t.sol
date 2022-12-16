// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "lib/forge-std/src/Test.sol";
import "lib/forge-std/src/console.sol";
import "../src/Profile.sol";

contract ProfileTest is Test {
    Profile public profile;

    function setUp() public {
        profile = new Profile();
        startHoax(address(1));
    }

    function testSetHandle(string memory handle) public {
        vm.assume(bytes(handle).length > 0);
        vm.assume(bytes(handle).length < profile.MAX_HANDLE_LENGTH());

        uint256 tokenId = profile.mint(address(1));
        profile.setHandle(tokenId, handle);

        (string memory foundHandle, uint256 foundHandleId) = profile.getHandle(tokenId);
        assertEq(foundHandle, handle);
        assertEq(foundHandleId, 0);
    }

    function testSetHandleTwice(string memory handle) public {
        vm.assume(bytes(handle).length > 0);
        vm.assume(bytes(handle).length < profile.MAX_HANDLE_LENGTH());

        uint256 tokenId = profile.mint(address(1));
        profile.setHandle(tokenId, handle);
        profile.setHandle(tokenId, handle);

        (string memory foundHandle, uint256 foundHandleId) = profile.getHandle(tokenId);
        assertEq(foundHandle, handle);
        assertEq(foundHandleId, 1);
    }

    function testSetHandleTwiceDifferent(string memory handle1, string memory handle2) public {
        vm.assume(bytes(handle1).length > 0);
        vm.assume(bytes(handle2).length > 0);
        vm.assume(bytes(handle1).length < profile.MAX_HANDLE_LENGTH());
        vm.assume(bytes(handle2).length < profile.MAX_HANDLE_LENGTH());
        vm.assume(keccak256(abi.encodePacked(handle1)) != keccak256(abi.encodePacked(handle2)));

        uint256 tokenId = profile.mint(address(1));
        profile.setHandle(tokenId, handle1);
        profile.setHandle(tokenId, handle2);

        (string memory foundHandle, uint256 foundHandleId) = profile.getHandle(tokenId);
        assertEq(foundHandle, handle2);
        assertEq(foundHandleId, 0);
    }

    function testSetHandleMaxLength() public {
        string memory SIXTEEN_CHARS = "1234567890123456";
        uint256 tokenId = profile.mint(address(1));
        profile.setHandle(tokenId, SIXTEEN_CHARS);

        (string memory foundHandle, uint256 foundHandleId) = profile.getHandle(tokenId);
        assertEq(foundHandle, SIXTEEN_CHARS);
        assertEq(foundHandleId, 0);
    }

    function testFailEmptyHandle() public {
        uint256 tokenId = profile.mint(address(1));
        profile.setHandle(tokenId, "");
    }

    function testFailTooLongHandle() public {
        uint256 tokenId = profile.mint(address(1));
        string memory SEVENTEEN_CHARS = "12345678901234567";
        profile.setHandle(tokenId, SEVENTEEN_CHARS);
    }

    function testFailSetHandleNotOwner() public {
        uint256 tokenId = profile.mint(address(1));

        startHoax(address(2));
        profile.setHandle(tokenId, "test");
    }

    function testManyMints() public {
        string memory handle = "test";
        uint256 count = 100;

        for (uint256 i = 0; i < count; i++) {
            uint256 tokenId = profile.mint(address(1));
            profile.setHandle(tokenId, handle);
        }

        uint256 finalTokenId = profile.mint(address(1));
        profile.setHandle(finalTokenId, handle);

        (string memory foundHandle, uint256 foundHandleId) = profile.getHandle(finalTokenId);
        assertEq(foundHandle, handle);
        assertEq(foundHandleId, count);
    }

    function testFailSetHandleInvalidTokenId() public {
        uint256 tokenId = profile.mint(address(1));
        profile.setHandle(tokenId + 1, "test");
    }

    function testGetProfileFromHandle() public {
        string memory handle = "test";

        uint256 tokenId = profile.mint(address(1));
        uint256 handleId = profile.setHandle(tokenId, handle);

        assertEq(profile.getProfileFromHandle(handle, handleId), tokenId);
    }

    function testGetProfileFromHandleInvalidHandle() public {
        string memory handle = "test";
        uint256 handleId = 0;

        uint256 tokenId = profile.getProfileFromHandle(handle, handleId);

        // Assert not found
        assertEq(tokenId, 0);
    }

    function testGetProfileFromHandleInvalidHandleId() public {
        string memory handle = "test";

        uint256 tokenId = profile.mint(address(1));
        uint256 handleId = profile.setHandle(tokenId, handle);

        uint256 foundTokenId = profile.getProfileFromHandle(handle, handleId + 1);

        // Assert not found
        assertEq(foundTokenId, 0);
    }
}
