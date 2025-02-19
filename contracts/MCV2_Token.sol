// SPDX-License-Identifier: BSD-3-Clause

pragma solidity ^0.8.20;

import {ERC20Initializable} from "./lib/ERC20Initializable.sol";

contract MCV2_Token is ERC20Initializable {
    error MCV2_Token__PermissionDenied();

    bool private _initialized; // false by default
    address public bond; // Bonding curve contract should have its minting permission

    function init(string calldata name_, string calldata symbol_) external {
        require(_initialized == false, "CONTRACT_ALREADY_INITIALIZED");
        _initialized = true;

        _name = name_;
        _symbol = symbol_;
        bond = _msgSender();
    }

    modifier onlyBond() {
        if (bond != _msgSender()) revert MCV2_Token__PermissionDenied();
        _;
    }

    /* @dev Mint tokens by bonding curve contract
     * Minting should also provide liquidity to the bonding curve contract
     */
    function mintByBond(address to, uint256 amount) external onlyBond {
        _mint(to, amount);
    }

    /* @dev Direct burn function call is disabled because it affects the bonding curve.
     * Users can simply send tokens to the token contract address for the same burning effect without changing the totalSupply.
     */
    function burnByBond(address account, uint256 amount) external onlyBond {
        _spendAllowance(account, bond, amount); // `msg.sender` is always be `bond`
        _burn(account, amount);
    }
}