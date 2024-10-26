// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

import {Context} from "./utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;
    address public previousContract;
    bool public isSuperOwner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`).
     */
    error OwnableInvalidOwner(address owner);

    /**
     * @dev The caller is not previousContract.
     */
    error OwnableInvalidCaller(address owner);

    /**
     * @dev contract is not super owner.
     */
    error OwnableInvalidSuperOwner();

    event SuperOwnerStatusUpdated(bool oldStatus, bool newStatus);

    event PreviousContractUpdated(address indexed oldContract, address indexed newContract);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner, address _previousContract, bool _isSuperOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
        _setPreviousContract(_previousContract);
        _setIsSuperOwner(_isSuperOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

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
        if(!isSuperOwner && previousContract != address(0)) {
            revert OwnableInvalidSuperOwner();
        }
        _;
    }

    /**
     * @dev sets if this contract isSuperOwner (`_isSuperOwner`).
     * Can only be called by the current owner.
     */
    function setIsSuperOwner(bool _isSuperOwner) external onlyOwner {
        _setIsSuperOwner(_isSuperOwner);
    }

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
     * @dev sets the previousContract to new address(`_previousContract`).
     * Can only be called by the current owner.
     */
    function setPreviousContract(address _previousContract) external onlyOwner {
        _setPreviousContract(_previousContract);
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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner onlySuperOwner {
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
    function transferOwnership(address newOwner) public virtual onlyOwner onlySuperOwner {
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

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);

        // Pass cross-chain message
        _sendCrossChainMessage(newOwner);
    }

    /**
     * @dev Implements cross-chain message logic here to call all `crossTransferOwnership` or `crossRenounceOwnership`.
     */
    function _sendCrossChainMessage(address newOwner) internal virtual {}
}
