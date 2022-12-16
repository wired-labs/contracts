// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "./URIStorage.sol";

contract Avatar is URIStorage {
    constructor() URIStorage("Avatar", "AVATAR") {}
}