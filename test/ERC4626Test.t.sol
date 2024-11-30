// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "../src/ERC4626.sol";
import "./mocks/ERC20Mock.sol";
import "./derivative/ERC4626Derivative.sol";

contract ERC4626Test is Test {
    ERC4626 public vault;
    IERC20 public token;
    address depositer = makeAddr("depositer");
    address alice = makeAddr("alice");
    address attacker = makeAddr("attacker");


    function setUp() public {
        token = new ERC20Mock();
        vault = new ERC4626Derivative(token);
        vm.startPrank(depositer);
        ERC20Mock(address(token)).mint(10);
        vm.stopPrank();
        vm.startPrank(address(vault));
        ERC20Mock(address(token)).mint(100);
        vm.stopPrank();
        console.log(token.balanceOf(depositer));
        console.log(token.balanceOf(address(vault)));
    }

    function test_deposit() external {
        vm.startPrank(depositer);
        token.approve(address(vault), 10);
        vault.deposit(10, depositer);
        vm.stopPrank();
        assertEq(vault.balanceOf(depositer), 10);
        assertEq(token.balanceOf(address(vault)), 110);
    }

    function test_mint() external {
        vm.startPrank(depositer);
        token.approve(address(vault), 10);
        vault.mint(10, depositer);
        vm.stopPrank();
        console.log(vault.balanceOf(depositer));
        console.log(token.balanceOf(address(vault)));
        assertEq(vault.balanceOf(depositer), 10);
        assertEq(token.balanceOf(address(vault)), 110);
    }

    function test_withdraw() external {
        vm.startPrank(depositer);
        token.approve(address(vault), 10);
        vault.deposit(10, depositer);
        vm.stopPrank();
        console.log("before:",vault.balanceOf(depositer));
        console.log("before:",token.balanceOf(address(vault)));
        vm.startPrank(depositer);
        vault.withdraw(10, depositer,depositer);
        vm.stopPrank();
        console.log("after:",vault.balanceOf(depositer));
        console.log("after:",token.balanceOf(address(vault)));
    }

}
