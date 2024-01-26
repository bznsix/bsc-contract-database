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
    function factory() external pure returns (address);
}


interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

// Интерфейс для взаимодействия с парным контрактом Uniswap
interface IUniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
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

	function getOutsMinsArr(address[] memory  _router1, address[] memory _router2, address[] memory base_token, address[] memory _tokens, uint256 _amount) 
		public view returns (uint256[] memory)
	{   uint256 _tokens_length = _tokens.length;
        uint256[] memory OutsMins = new uint256[](2 *_tokens_length);
		// Прямой обмен
        for (uint256 i = 0; i < _tokens_length; i++) {
			uint256 amtBack1 = getAmountOutMin(_router1[i], base_token[i], _tokens[i], _amount);
			uint256 amtBack2 = getAmountOutMin(_router2[i], _tokens[i], base_token[i], amtBack1);
			OutsMins[i] = amtBack2;
        }
		// Обратный обмен
		for (uint256 i = 0; i < _tokens_length; i++) {  
			uint256 amtBack1 = getAmountOutMin(_router2[i], base_token[i], _tokens[i], _amount);
			uint256 amtBack2 = getAmountOutMin(_router1[i], _tokens[i], base_token[i], amtBack1);
			OutsMins[i + _tokens_length] = amtBack2;
        }
        return OutsMins;
    }

// Функция для получения резервов и минимальных выходных значений
function getOutsMinsArrWithReserv(
    address[] memory _router1,
    address[] memory _router2,
    address[] memory base_token,
    address[] memory _tokens,
    uint256 _amount)
    public
    view
    returns (uint256[] memory OutsMins)
{
    uint256 _tokens_length = _tokens.length;
    OutsMins = new uint256[](2 * _tokens_length);
    // Прямой обмен и получение резервов
    for (uint256 i = 0; i < _tokens_length; i++) {
        // Получаем минимальные выходные заначения
        uint256 amtBack1 = getAmountOutMin(_router1[i], base_token[i], _tokens[i], _amount);
        uint256 amtBack2 = getAmountOutMin(_router2[i], _tokens[i], base_token[i], amtBack1);
        OutsMins[i] = amtBack2;
    }
    // Обратный обмен и получение резервов
    for (uint256 i = 0; i < _tokens_length; i++) {
        uint256 amtBack1 = getAmountOutMin(_router2[i], base_token[i], _tokens[i], _amount);
        uint256 amtBack2 = getAmountOutMin(_router1[i], _tokens[i], base_token[i], amtBack1);
        OutsMins[i + _tokens_length] = amtBack2;  
    }
    return OutsMins;
}
// Функция для получения резервов для пары токенов
function getReserves(address tokenA, address tokenB, address pair) public view returns (uint256 reserveA, uint256 reserveB) {    
        IUniswapV2Pair uniswapPair = IUniswapV2Pair(pair);
        (uint256 reserve0, uint256 reserve1,) = uniswapPair.getReserves();
        // Учитываем порядок токенов, чтобы вернуть резервы в правильном порядке
        (reserveA, reserveB) = tokenA < tokenB ? (reserve0, reserve1) : (reserve1, reserve0);
        return (reserveA, reserveB);
}
function getPairsReserves(
    address[] memory base_token,
    address[] memory _tokens,
    address[] memory _pairs1,
    address[] memory _pairs2)
    public
    view
    returns (uint256[] memory ReservesA1, uint256[] memory ReservesB1, uint256[] memory ReservesA2, uint256[] memory ReservesB2)
{
    uint256 _tokens_length = _tokens.length;
    // Для резервов нужно создать два отдельных массива для token A и B
    ReservesA1 = new uint256[](_tokens_length);
    ReservesB1 = new uint256[](_tokens_length);
    ReservesA2 = new uint256[](_tokens_length);
    ReservesB2 = new uint256[](_tokens_length);

    // Прямой обмен и получение резервов
    for (uint256 i = 0; i < _tokens_length; i++) {
        // Получаем минимальные выходные заначения
            (uint256 reserveA1, uint256 reserveB1) = getReserves(base_token[i], _tokens[i], _pairs1[i]);
            ReservesA1[i] = reserveA1;
            ReservesB1[i] = reserveB1;
    }
    for (uint256 i = 0; i < _tokens_length; i++) {
        // Получаем минимальные выходные заначения
            (uint256 reserveA2, uint256 reserveB2) = getReserves(base_token[i], _tokens[i], _pairs2[i]);
            ReservesA2[i] = reserveA2;
            ReservesB2[i] = reserveB2;
    }
    return (ReservesA1, ReservesB1, ReservesA2, ReservesB2);
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