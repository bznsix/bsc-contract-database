// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

interface IERC20 {
    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);
       
    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender,address recipient, uint256 amount) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract airdrop is Ownable {

    struct TransInfo {
        address account;
        uint256 amount;
    }
    event Claim(address opt,address to, uint256 amount);

    function airdrop1(address _token,address[] memory _toArr, uint256 _amount) public onlyOwner {
        for(uint i = 0; i < _toArr.length; i++){
           IERC20(_token).transfer(_toArr[i],_amount); 
        }
    }

    function airdrop2(address _token,TransInfo[] memory _toArr) public onlyOwner {
        for(uint i = 0; i < _toArr.length; i++){
           IERC20(_token).transfer(_toArr[i].account,_toArr[i].amount); 
        }
    }

    function airdrop3(address _token,address[] memory _toArr, uint256 _amount) public onlyOwner {
        for(uint i = 0; i < _toArr.length; i++){
         IERC20(_token).transferFrom(_msgSender(), _toArr[i], _amount);
        }
    }

   function airdrop4(address _token,TransInfo[] memory _toArr) public onlyOwner {
        for(uint i = 0; i < _toArr.length; i++){
           IERC20(_token).transferFrom(_msgSender(),_toArr[i].account,_toArr[i].amount);
        }
    }

    function claim(IERC20 token,uint256 amount,address to) public onlyOwner
    {
        require(amount > 0, 'Claim: Can not claim 0');
        IERC20(token).transfer(to, amount);
        emit Claim(_msgSender(),to, amount);
    }
}