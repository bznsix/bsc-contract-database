// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

abstract contract SafeMath {
    /*Addition*/
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    /*Subtraction*/
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    /*Multiplication*/
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    /*Divison*/
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    /* Modulus */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20 { 
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint amount ) external returns (bool);
    function decimals() external returns (uint8);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract GSVSwappingContract is SafeMath {

    address payable private primaryAdmin;
    IERC20 private SwapToken;
    IERC20 private NativeToken;
    uint private SwapTokenDecimals;
    uint private NativeTokenDecimals;

    constructor() {
        address payable msgSender = payable(msg.sender);
        primaryAdmin = msgSender;
        SwapToken = IERC20(0xbB071C120Bb5eca705f5fC574f4d774d2f639e92);
        SwapTokenDecimals=18;
        NativeToken = IERC20(0xD4EaE71cA3C67bbac87962b0a90D81984285997f);
        NativeTokenDecimals=18;
	}

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return primaryAdmin;
    }

    /**
     * @dev Returns the swap token contract address.
     */
    function swapTokenContractAddress() public view returns (IERC20) {
        return SwapToken;
    }

    /**
     * @dev Returns the native token contract address.
     */
    function nativeTokenContractAddress() public view returns (IERC20) {
        return NativeToken;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(primaryAdmin == payable(msg.sender), "Ownable: caller is not the owner");
        _;
    }

     /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(primaryAdmin, address(0));
        primaryAdmin = payable(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address payable newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(primaryAdmin, newOwner);
        primaryAdmin = newOwner;
    }


    struct UserSwapDetails {
        uint256 amountSwapToken;
        uint256 amountNativeToken;
        uint lastUpdatedUTCDateTime;
	}

    mapping (address => UserSwapDetails) public UserSwapdetails;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function updateNativeTokenContractAddress(IERC20 _NativeTokenContract,uint _NativeTokenDecimals) public onlyOwner() {
        require(primaryAdmin==msg.sender, 'Admin what?');
        NativeToken=_NativeTokenContract;
        NativeTokenDecimals=_NativeTokenDecimals;
    }

    function updateSwapTokenContractAddress(IERC20 _SwapTokenContract,uint _SwapTokenDecimals) public onlyOwner() {
        require(primaryAdmin==msg.sender, 'Admin what?');   
        SwapToken=_SwapTokenContract;
        SwapTokenDecimals=_SwapTokenDecimals;
    }

    function Swap(uint256 _SwapToken) public returns (bool) {
        UserSwapDetails storage userswapdetail = UserSwapdetails[msg.sender];
        uint256 ActualToken=_SwapToken/5;
        userswapdetail.amountSwapToken += _SwapToken;
        userswapdetail.amountNativeToken += ActualToken;
        userswapdetail.lastUpdatedUTCDateTime = view_GetCurrentTimeStamp();
        SwapToken.transferFrom(msg.sender, address(this), _SwapToken);
        NativeToken.transfer(msg.sender, ActualToken);
        return true;
    }

    //Reverse Token That Admin Puten on Smart Contract
    function _reverseSwapToken(uint256 _SwapToken) public onlyOwner() {
        require(primaryAdmin==msg.sender, 'Admin what?');
        SwapToken.transfer(primaryAdmin, _SwapToken);
    }

    //Revese Token That Admin Puten on Smart Contract
    function _reverseNativeToken(uint256 _NativeToken) public onlyOwner() {
        require(primaryAdmin==msg.sender, 'Admin what?');
        NativeToken.transfer(primaryAdmin, _NativeToken);
    }

    //View Get Current Time Stamp
    function view_GetCurrentTimeStamp() public view returns(uint _timestamp){
       return (block.timestamp);
    }
    
}