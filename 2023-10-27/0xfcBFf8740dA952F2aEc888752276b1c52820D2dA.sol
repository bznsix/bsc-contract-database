// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapV2Router02 {
    function WETH() external pure returns (address);

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

contract SwapContractV2 {
    address payable public feeCollector;
    uint256 public feePercentage;
    IUniswapV2Router02 public uniswapV2Router;
    address public tokenOut;

    constructor(
        address _uniswapV2Router,
        address payable _feeCollector,
        uint256 _feePercentage,
        address _tokenOut
    ) {
        uniswapV2Router = IUniswapV2Router02(_uniswapV2Router);
        feeCollector = _feeCollector;
        feePercentage = _feePercentage;
        tokenOut = _tokenOut;
    }

    function swapEthForToken() public payable {
        require(msg.value > 0, "No ETH sent.");

        // Calculate fee and send to feeCollector
        uint256 fee = (msg.value * feePercentage) / 100;
        feeCollector.transfer(fee);

        // Remaining amount for swap
        uint256 swapAmount = msg.value - fee;

        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = tokenOut;

        uniswapV2Router.swapExactETHForTokens{value: swapAmount}(
            0, // Accept any amount of tokens out
            path,
            msg.sender, // Tokens are sent to the user
            block.timestamp + 15 minutes
        );
    }

    function setFeeCollector(address payable _feeCollector) external {
        require(msg.sender == feeCollector, "Only feeCollector can change this.");
        feeCollector = _feeCollector;
    }

    function setFeePercentage(uint256 _feePercentage) external {
        require(msg.sender == feeCollector, "Only feeCollector can change this.");
        require(_feePercentage < 100, "Fee percentage too high.");
        feePercentage = _feePercentage;
    }

    function setTokenOut(address _tokenOut) external {
        require(msg.sender == feeCollector, "Only feeCollector can change this.");
        tokenOut = _tokenOut;
    }
}