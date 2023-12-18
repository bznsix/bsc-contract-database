// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IERC20 {
	function decimals() external view returns (uint8);

	function symbol() external view returns (string memory);

	function name() external view returns (string memory);

	function totalSupply() external view returns (uint256);

	function balanceOf(address account) external view returns (uint256);

	function transfer(address recipient, uint256 amount) external returns (bool);

	function allowance(address owner, address spender) external view returns (uint256);

	function approve(address spender, uint256 amount) external returns (bool);

	function transferFrom(
		address sender,
		address recipient,
		uint256 amount
	) external returns (bool);

	event Transfer(address indexed from, address indexed to, uint256 value);

	event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ISwapRouter {
	function addLiquidityETH(
		address token,
		uint256 amountTokenDesired,
		uint256 amountTokenMin,
		uint256 amountETHMin,
		address to,
		uint256 deadline
	) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

}

abstract contract Ownable {
	address private _owner;

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	constructor() {
		address msgSender = msg.sender;
		_owner = msgSender;
		emit OwnershipTransferred(address(0), msgSender);
	}

	function owner() public view returns (address) {
		return _owner;
	}

	modifier onlyOwner() {
		require(_owner == msg.sender, "Ownable: caller is not the owner");
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

contract SellBot is Ownable {
    IERC20 TOKEN = IERC20(0x2C38652C9e01Be52c29c803F743E599FB74DdD08);
    ISwapRouter Router = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    // sell
    uint256 public sellingPrice = 0.002 ether;
    uint256 public sellAmount = 100 ether;

    // lp
    uint256 public BatchEth = 5 ether;
    uint256 public liqEth = 2 ether;
    uint256 public liqAmount = 100000 ether;


	uint256 private constant MAX = ~uint256(0);
	constructor(){
		TOKEN.approve(address(Router), MAX);
	}

    uint256 public CumAmount;

    function buy() payable public {
        require(msg.value>=sellingPrice,"PN");
        require(TOKEN.balanceOf(address(this)) >= sellAmount,"AN");
        TOKEN.transfer(msg.sender, sellAmount);
        CumAmount += msg.value;
        if (CumAmount >= BatchEth){
            addLiq();
            CumAmount = 0;
        }
    }

	receive() external payable { 
		buy();
	}

    function addLiq()private {
        require(address(this).balance >= liqEth,"LN");
        require(TOKEN.balanceOf(address(this)) >= liqAmount,"TN");
        Router.addLiquidityETH{value:liqEth}(address(TOKEN), liqAmount, 0, 0, owner(), block.timestamp);
    }

    function withDraw(uint256 amount)public onlyOwner {
        payable (msg.sender).transfer(amount);
    }

    function setSellParams(uint256 _sellingPrice,uint256 _sellAmount)public onlyOwner{
        sellingPrice = _sellingPrice;
        sellAmount = _sellAmount;
    }

    function setLiqParams(uint256 _BatchEth,uint256 _liqEth,uint256 _liqAmount)public onlyOwner{
        BatchEth = _BatchEth;
        liqEth = _liqEth;
		require(BatchEth >= liqEth,"nnnn");
        liqAmount = _liqAmount;
    }

    function setToken(address _token)public onlyOwner{
        TOKEN = IERC20(_token);
		TOKEN.approve(address(Router), MAX);
    }

}