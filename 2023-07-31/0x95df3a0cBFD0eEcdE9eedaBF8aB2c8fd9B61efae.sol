/**
 *Submitted for verification at BscScan.com on 2023-07-25
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IBEP20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IBEP20Metadata is IBEP20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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
    }
}
error Packages_InvalidPackage();
error Packages_InvalidAmount(uint256 amount);

contract Whalesaicom is Ownable {
    IBEP20 private bep20_helper;
    uint256 private packageOnePrice;
    uint256 private packageTwoPrice;
    uint256 private packageThreePrice;

    event PackageBought(
        address indexed user,
        uint256 indexed packageNo,
        uint256 indexed timeStamp
    );
    event PackagePriceChanged(
        uint256 indexed packageNo,
        uint256 indexed newPrice
    );

    // packageOnePrice = 5000  DS
    // packageTwoPrice = 80000   DS
    // packageThreePrice = 600000  DS
    
    constructor(
        address _bep20Helper,
        uint256 _packageOnePrice,
        uint256 _packageTwoPrice,
        uint256 _packagethreePrice
    ) {
        bep20_helper = IBEP20(_bep20Helper);
        packageOnePrice = _packageOnePrice;
        packageTwoPrice = _packageTwoPrice;
        packageThreePrice = _packagethreePrice;
    }

    function buyPackage(uint256 _packageNo) external {
        if (_packageNo == 0 || _packageNo > 3) revert Packages_InvalidPackage();
        if (_packageNo == 1) {
            if (bep20_helper.balanceOf(_msgSender()) < getFirstPackagePrice())
                revert Packages_InvalidAmount(getFirstPackagePrice());
            bep20_helper.transferFrom(
                _msgSender(),
                address(this),
                getFirstPackagePrice()
            );
        } else if (_packageNo == 2) {
            if (bep20_helper.balanceOf(_msgSender()) < getSecondPackagePrice())
                revert Packages_InvalidAmount(getSecondPackagePrice());
            bep20_helper.transferFrom(
                _msgSender(),
                address(this),
                getSecondPackagePrice()
            );
        } else {
            if (bep20_helper.balanceOf(_msgSender()) < getThirdPacakgePrice())
                revert Packages_InvalidAmount(getThirdPacakgePrice());
            bep20_helper.transferFrom(
                _msgSender(),
                address(this),
                getThirdPacakgePrice()
            );
        }
        emit PackageBought(_msgSender(), _packageNo, block.timestamp);
    }

    function withdrawTokens() external onlyOwner {
        uint256 balance = bep20_helper.balanceOf(address(this));
        require(balance > 0, "No Tokens to Withdraw");
        bep20_helper.transfer(_msgSender(), balance);
    }

    function changePrice(uint256 _packageNo, uint256 _newPrice)
        external
        onlyOwner
    {
        if (_packageNo == 0 || _packageNo > 3) revert Packages_InvalidPackage();
        if (_packageNo == 1) {
            require(
                _newPrice != 0 || _newPrice != getFirstPackagePrice(),
                "Invalid Price"
            );
            packageOnePrice = _newPrice;
        } else if (_packageNo == 2) {
            require(
                _newPrice != 0 || _newPrice != getSecondPackagePrice(),
                "Invalid Price"
            );
            packageTwoPrice = _newPrice;
        } else {
            require(
                _newPrice != 0 || _newPrice != getThirdPacakgePrice(),
                "Invalid Price"
            );
            packageThreePrice = _newPrice;
        }
        emit PackagePriceChanged(_packageNo, _newPrice);
    }

    function getFirstPackagePrice() public view returns (uint256) {
        return packageOnePrice;
    }

    function getSecondPackagePrice() public view returns (uint256) {
        return packageTwoPrice;
    }

    function getThirdPacakgePrice() public view returns (uint256) {
        return packageThreePrice;
    }
}