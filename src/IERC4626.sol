// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IERC4626 {
    event Deposit(address, address, uint256, uint256);
    event Withdraw(address,address, address, uint256, uint256);

}
