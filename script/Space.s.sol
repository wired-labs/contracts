// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "lib/forge-std/src/Script.sol";

contract SpaceScript is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();
    }
}
