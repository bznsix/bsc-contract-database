//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }
    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }
    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
contract brandsfever is Ownable{
  
    IERC20 public token;

    event TokensSent(address indexed contributor, uint256 amount);

    constructor(IERC20 _token) 
    { token = _token; }

    function sell(uint256 _amount)  
    external 
    { 
        require(_amount > 0,"invalid amount");
        require(token.transferFrom(msg.sender,address(this),_amount),"Transfer Failed!"); 
    }

    function multisendToken(address[] calldata contributors, uint256[] calldata balances) 
    external 
    onlyOwner
    {
        uint256 i = 0;        
        for (i; i < contributors.length; i++) 
        { token.transfer(contributors[i], balances[i]);
        emit TokensSent(contributors[i], balances[i]); }
    }

    function setTokenAddress(address _token) 
    external 
    onlyOwner
    { token = IERC20(_token); }

    function getToken() 
    external 
    onlyOwner
    { require(token.transfer(msg.sender,token.balanceOf(address(this))),"transfer failed!"); }

    function WithdrawToken(address _tokenAddress)
    external
    onlyOwner
    {   IERC20(_tokenAddress).transfer(owner(),(IERC20(_tokenAddress).balanceOf(address(this))));   }

}