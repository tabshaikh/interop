// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

abstract contract CrossOwnable is Ownable {
    /**
     * @dev Address of the previous contract that has permission to call cross-chain ownership functions.
     * This is used to enable cross-chain ownership transfers between contracts.
     */
    address public previousContract;

    /**
     * @dev Indicates whether this contract is a super owner, which means it has special privileges
     * in the cross-chain ownership hierarchy. A super owner contract can initiate ownership transfers
     * across chains without requiring approval from the previous contract.
     */
    bool public isSuperOwner;

    // =============================================================
    // Errors
    // =============================================================

    /**
     * @dev The caller is not previousContract.
     */
    error OwnableInvalidCaller(address owner);

    /**
     * @dev The contract is not super owner.
     */
    error OwnableInvalidSuperOwner();

    // =============================================================
    // Events
    // =============================================================

    event SuperOwnerStatusUpdated(bool oldStatus, bool newStatus);
    event PreviousContractUpdated(address indexed oldContract, address indexed newContract);

    // =============================================================
    // Constructor
    // =============================================================

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner, address _previousContract, bool _isSuperOwner) Ownable(initialOwner) {
        _setPreviousContract(_previousContract);
        _setIsSuperOwner(_isSuperOwner);
    }

    // =============================================================
    // Modifiers
    // =============================================================

    /**
     * @dev Throws if called by any account other than previousContract.
     */
    modifier onlyPreviousContract() virtual {
        if (msg.sender != previousContract) {
            revert OwnableInvalidCaller(msg.sender);
        }
        _;
    }

    /**
     * @dev Throws if called by any account other than previousContract.
     */
    modifier onlySuperOwner() {
        if (!isSuperOwner && previousContract != address(0)) {
            revert OwnableInvalidSuperOwner();
        }
        _;
    }

    // =============================================================
    // External Functions
    // =============================================================

    /**
     * @dev sets if this contract isSuperOwner (`_isSuperOwner`).
     * Can only be called by the current owner.
     */
    function setIsSuperOwner(bool _isSuperOwner) external onlyOwner {
        _setIsSuperOwner(_isSuperOwner);
    }

    /**
     * @dev sets the previousContract to new address(`_previousContract`).
     * Can only be called by the current owner.
     */
    function setPreviousContract(address _previousContract) external onlyOwner {
        _setPreviousContract(_previousContract);
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public override onlyOwner onlySuperOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev similar to renounce ownership but this function can only be called by previous contract.
     * if the ownership has already been renounced it returns without doing anything.
     */
    function crossRenounceOwnership() public virtual onlyPreviousContract {
        if (owner() == address(0)) {
            return;
        }
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public override onlyOwner onlySuperOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * if the ownership is already transferred it returns without doing anything.
     * Can only be called by previous contract.
     */
    function crossTransferOwnership(address newOwner) public virtual onlyPreviousContract {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        if (newOwner == owner()) {
            return;
        }
        _transferOwnership(newOwner);
    }

    // =============================================================
    // Internal Functions
    // =============================================================

    /**
     * @dev sets `isSuperOwner` status of contract to new status `_isSuperOwner`
     * Internal function without access restriction.
     */
    function _setIsSuperOwner(bool _isSuperOwner) internal {
        bool oldSuperOwnerStatus = isSuperOwner;
        isSuperOwner = _isSuperOwner;

        emit SuperOwnerStatusUpdated(oldSuperOwnerStatus, _isSuperOwner);
    }

    /**
     * @dev sets previousContract to new `_previousContract`
     * Internal function without access restriction.
     */
    function _setPreviousContract(address _previousContract) internal {
        address _oldPreviousContract = previousContract;
        previousContract = _previousContract;

        emit PreviousContractUpdated(_oldPreviousContract, _previousContract);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal override {
        super._transferOwnership(newOwner);

        // Pass cross-chain message
        _sendCrossChainMessage(newOwner);
    }

    /**
     * @dev Implements cross-chain message logic here to call all `crossTransferOwnership` or `crossRenounceOwnership`.
     */
    function _sendCrossChainMessage(address newOwner) internal virtual {}
}
