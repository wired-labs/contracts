// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "lib/flamingo/src/URIStorage.sol";

contract Space is URIStorage {
    constructor() URIStorage("Space", "SPACE") {}
}
