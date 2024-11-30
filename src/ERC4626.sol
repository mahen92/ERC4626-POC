// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "./IERC4626.sol";
import {Math} from "../lib/openzeppelin-contracts/contracts/utils/math/Math.sol";
import {SafeERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {Test, console} from "forge-std/Test.sol";

abstract contract ERC4626 is ERC20, IERC4626 {
    using Math for uint256;

    IERC20 private immutable _asset;
    uint256 private immutable _underlyingDecimals;

    error ERC4626ExceededMaxDeposit(address receiver, uint256 assets, uint256 max);

    error ERC4626ExceededMaxMint(address receiver, uint256 shares, uint256 max);

    error ERC4626ExceededMaxWithdraw(address receiver, uint256 shares, uint256 max);

    error ERC4626ExceededMaxRedeem(address owner, uint256 shares, uint256 max);
    constructor(IERC20 asset_) {
        //(bool success, uint8 assetDecimals) = _tryGetAssetDecimals(asset_);
        //_underlyingDecimals = success ? assetDecimals : 18;
        _asset = asset_;
        _mint(_msgSender(), 100);
    }

    function asset() external view returns (address) {
        return address(_asset);
    }

    function totalAssets() public view virtual returns (uint256) {
        return _asset.balanceOf(address(this));
    }

    function maxDeposit(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    function maxMint(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    function maxWithdraw(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    function maxRedeem(address owner) public view virtual returns (uint256) {
        return balanceOf(owner);
    }

    function previewDeposit(uint256 assets) public view virtual returns (uint256) {
        return convertToShares(assets, Math.Rounding.Floor);
    }

    function previewMint(uint256 assets) public view virtual returns (uint256) {
        return _convertToAssets(assets, Math.Rounding.Ceil);
    }

    function previewWithdraw(uint256 assets) public view virtual returns (uint256) {
        return convertToShares(assets, Math.Rounding.Ceil);
        
    }

    function previewRedeem(uint256 shares) public view virtual returns (uint256) {
        return _convertToAssets(shares, Math.Rounding.Floor);
    }

    function _convertToAssets(uint256 shares, Math.Rounding rounding) internal view virtual returns (uint256) {
        return shares.mulDiv(totalAssets() + 1, totalSupply() + 10 ** _decimalsOffset(), rounding);
    }

    function convertToShares(uint256 assets, Math.Rounding rounding) internal view returns (uint256) {
        return assets.mulDiv(totalSupply() + 10 ** _decimalsOffset(), totalAssets() + 1, rounding);
    }

    function _decimalsOffset() internal view virtual returns (uint8) {
        return 0;
    }

    function deposit(uint256 assets, address receiver) public virtual returns (uint256) {
        uint256 maxAssets = maxDeposit(receiver);
        if (assets > maxAssets) {
            revert ERC4626ExceededMaxDeposit(receiver, assets, maxAssets);
        }
        uint256 shares = previewDeposit(assets);
        _deposit(_msgSender(), receiver, assets, shares);
        emit Deposit(_msgSender(), receiver, assets, shares);
        return shares;
    }

    function mint(uint256 shares, address receiver) public virtual returns (uint256) {
        uint256 maxAssets = maxMint(receiver);
        if (maxAssets > maxAssets) {
            revert ERC4626ExceededMaxMint(receiver,shares, maxAssets);
        }
        uint256 assets = previewMint(shares);
        _deposit(_msgSender(), receiver, assets, shares);
        emit Deposit(_msgSender(), receiver, assets, shares);
        return assets;
    }

    function withdraw(uint256 shares, address receiver,address owner) public virtual returns (uint256) {
        uint256 maxAssets = maxWithdraw(receiver);
        if (maxAssets > maxAssets) {
            revert ERC4626ExceededMaxWithdraw(receiver,shares, maxAssets);
        }
        uint256 assets = previewWithdraw(shares);
        _withdraw(_msgSender(), receiver, owner, assets, shares);
        emit Deposit(_msgSender(), receiver, assets, shares);
        return assets;
    }

    function redeem(uint256 shares, address receiver, address owner) public virtual returns (uint256) {
        uint256 maxShares = maxRedeem(owner);
        if (shares > maxShares) {
            revert ERC4626ExceededMaxRedeem(owner, shares, maxShares);
        }

        uint256 assets = previewRedeem(shares);
        _withdraw(_msgSender(), receiver, owner, assets, shares);

        return assets;
    }

    function _withdraw(address caller,address receiver,address owner,uint256 assets,uint256 shares)  internal virtual{
          if(caller!=owner){
             _spendAllowance(owner, caller, shares);
          }
          _burn(owner,shares);
          SafeERC20.safeTransfer(_asset,receiver,assets);
          emit Withdraw(caller, receiver, owner, assets, shares);
    }
    

    function _deposit(address caller, address receiver, uint256 assets, uint256 shares)
        internal
        virtual
        returns (uint256)
    {
        SafeERC20.safeTransferFrom(_asset, caller, address(this), assets);
        _mint(receiver, shares);
    }
}
