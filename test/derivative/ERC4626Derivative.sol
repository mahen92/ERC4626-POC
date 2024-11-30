// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../../src/ERC4626.sol";

contract ERC4626Derivative is ERC4626 {
    constructor(IERC20 token) ERC4626(token) ERC20("UToken", "UT") {}
}
