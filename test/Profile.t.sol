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

        uint256 expectedHandleId = 0;
        assertEq(profile.handle(tokenId), string(abi.encodePacked(handle, "#", expectedHandleId)));
    }

    function testSetHandleTwice(string memory handle) public {
        vm.assume(bytes(handle).length > 0);
        vm.assume(bytes(handle).length < profile.MAX_HANDLE_LENGTH());

        uint256 tokenId = profile.mint(address(1));
        profile.setHandle(tokenId, handle);
        profile.setHandle(tokenId, handle);

        uint256 expectedHandleId = 1;
        assertEq(profile.handle(tokenId), string(abi.encodePacked(handle, "#", expectedHandleId)));
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

        uint256 expectedHandleId = 0;
        assertEq(profile.handle(tokenId), string(abi.encodePacked(handle2, "#", expectedHandleId)));
    }

    function testSetHandleMaxLength() public {
        string memory SIXTEEN_CHARS = "1234567890123456";
        uint256 tokenId = profile.mint(address(1));
        profile.setHandle(tokenId, SIXTEEN_CHARS);

        uint256 expectedHandleId = 0;
        assertEq(profile.handle(tokenId), string(abi.encodePacked(SIXTEEN_CHARS, "#", expectedHandleId)));
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

    function testManyHandleIds() public {
        string memory handle = "test";
        uint256 count = 100;

        uint256 tokenId = profile.mint(address(1));

        for (uint256 i = 0; i < count; i++) {
            profile.setHandle(tokenId, handle);
        }

        uint256 expectedHandleId = count - 1;
        assertEq(profile.handle(tokenId), string(abi.encodePacked(handle, "#", expectedHandleId)));
    }

    function testFailSetHandleInvalidTokenId() public {
        uint256 tokenId = profile.mint(address(1));
        profile.setHandle(tokenId + 1, "test");
    }
}
