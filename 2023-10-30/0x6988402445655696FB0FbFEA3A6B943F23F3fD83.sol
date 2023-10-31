//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

interface IERC20 {
	function balanceOf(address account) external view returns (uint);
	function transfer(address recipient, uint amount) external returns (bool);
	function approve(address spender, uint amount) external returns (bool);
}

interface IUniswapV2Router {
    function getAmountsOut(uint256 amountIn, address[] memory path) external view returns (uint256[] memory amounts);
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
}
contract Arb {
    address _owner;
    constructor(){
        _owner = msg.sender;
    }

    modifier onlyOwner (){
        require(msg.sender == _owner, "Ownable: caller is not the owner");
        _;
    }
	 function getAmountOutMin(address router, address _tokenIn, address _tokenOut, uint256 _amount) public view returns (uint256) {
		address[] memory path;
		path = new address[](2);
		path[0] = _tokenIn;
		path[1] = _tokenOut;
		uint256[] memory amountOutMins = IUniswapV2Router(router).getAmountsOut(_amount, path);
		return amountOutMins[path.length -1];
	}
    function estimateDualDexTrade(address _router1, address _router2, address _token1, address _token2, uint256 _amount) external view returns (uint256) {
		uint256 amtBack1 = getAmountOutMin(_router1, _token1, _token2, _amount);
		uint256 amtBack2 = getAmountOutMin(_router2, _token2, _token1, amtBack1);
		return amtBack2;
	}

    function getOutsMins(address _router1, address _router2, address base_token, address[] memory _tokens, uint256 _amount) public view returns (uint256[] memory) {
        uint256[] memory OutsMins = new uint256[](2 *_tokens.length);
		// Прямой обмен
        for (uint256 i = 0; i < _tokens.length; i++) {
			uint256 amtBack1 = getAmountOutMin(_router1, base_token, _tokens[i], _amount);
			uint256 amtBack2 = getAmountOutMin(_router2, _tokens[i], base_token, amtBack1);
			OutsMins[i] = amtBack2;
        }
		// Обратный обмен
		for (uint256 i = 0; i < _tokens.length; i++) {  
			uint256 amtBack1 = getAmountOutMin(_router2, base_token, _tokens[i], _amount);
			uint256 amtBack2 = getAmountOutMin(_router1, _tokens[i], base_token, amtBack1);
			OutsMins[i + _tokens.length] = amtBack2;
        }
        return OutsMins;
    }
	function getBalance (address _tokenContractAddress) external view  returns (uint256) {
		uint balance = IERC20(_tokenContractAddress).balanceOf(address(this));
		return balance;
	}	
	function recoverEth() external onlyOwner {
		payable(msg.sender).transfer(address(this).balance);
	}
	function recoverTokens(address tokenAddress) external onlyOwner {
		IERC20 token = IERC20(tokenAddress);
		token.transfer(msg.sender, token.balanceOf(address(this)));
	}
	
	receive() external payable {}

    function swap(address router, address _tokenIn, address _tokenOut, uint256 _amount) private {
		IERC20(_tokenIn).approve(router, _amount);
		address[] memory path;
		path = new address[](2);
		path[0] = _tokenIn;
		path[1] = _tokenOut;
		uint deadline = block.timestamp + 300;
		IUniswapV2Router(router).swapExactTokensForTokens(_amount, 1, path, address(this), deadline);
	}
    function dualDexTrade(address _router1, address _router2, address _token1, address _token2, uint256 _amount) external {
        uint startBalance = IERC20(_token1).balanceOf(address(this));
        uint token2InitialBalance = IERC20(_token2).balanceOf(address(this));

            swap(_router1,_token1, _token2,_amount);

        uint token2Balance = IERC20(_token2).balanceOf(address(this));
        uint tradeableAmount = token2Balance - token2InitialBalance;

            swap(_router2,_token2, _token1,tradeableAmount);

        uint endBalance = IERC20(_token1).balanceOf(address(this));
        require(endBalance > startBalance, "Trade Reverted, No Profit Made");
    }
}