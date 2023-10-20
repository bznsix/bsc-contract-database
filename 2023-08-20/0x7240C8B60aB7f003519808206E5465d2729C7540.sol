// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPancakeRouter02 {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);
}

contract BSCSandwichMEVBot {
    address private owner;
    IPancakeRouter02 public pancakeRouter;

    // Lista negra de direcciones de contratos antibot
    mapping(address => bool) private blacklist;

    constructor(address _router) {
        owner = msg.sender;
        pancakeRouter = IPancakeRouter02(_router);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function addToBlacklist(address contractAddress) external onlyOwner {
        blacklist[contractAddress] = true;
    }

    function removeFromBlacklist(address contractAddress) external onlyOwner {
        blacklist[contractAddress] = false;
    }

    function isBlacklisted(address contractAddress) public view returns (bool) {
        return blacklist[contractAddress];
    }

    function performSandwichAttack(
        address tokenIn,
        address tokenOut,
        uint amountIn,
        uint deadline,
        uint maxGasPrice,
        uint desiredProfitPercentage
    ) external onlyOwner {
        require(!isBlacklisted(tokenIn) && !isBlacklisted(tokenOut), "Tokens are in blacklist");
        require(getTokenTax(tokenIn) <= 2, "Token tax is too high");

        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;

        uint gasEstimated = tx.gasprice * 100000;
        require(gasEstimated <= maxGasPrice, "Gas price too high");

        uint[] memory amountsBefore = pancakeRouter.getAmountsOut(amountIn, path);

        // Perform the first swap to decrease tokenIn price
        uint[] memory amountsAfterFirstSwap = pancakeRouter.swapExactTokensForTokens(
            amountIn - gasEstimated,
            amountsBefore[1] - calculateMinProfit(amountsBefore[1], desiredProfitPercentage),
            path,
            address(this),
            deadline
        );

        uint gasEstimatedSecondSwap = tx.gasprice * 100000;

        // Calculate how much we need to spend to outbid the previous user's transaction
        uint gasSpent = gasEstimated + gasEstimatedSecondSwap;
        uint gasPriceToOutbid = calculateGasPriceToOutbid(gasSpent, deadline);

        // Perform the second swap to take advantage of the changed price
        pancakeRouter.swapExactTokensForTokens(
            amountsAfterFirstSwap[1],
            amountsBefore[1] - calculateMinProfit(amountsBefore[1], desiredProfitPercentage),
            path,
            address(this),
            deadline
        );

        // Perform the third swap with an increased gas price to outbid other transactions
        pancakeRouter.swapExactTokensForTokens(
            amountIn - gasEstimated - gasEstimatedSecondSwap,
            amountsAfterFirstSwap[1],
            path,
            owner,
            deadline
        );

        // Transfer swapped tokens to the owner
        uint tokenBalance = ERC20(tokenOut).balanceOf(address(this));
        require(tokenBalance > 0, "No tokens swapped");
        ERC20(tokenOut).transfer(owner, tokenBalance);
    }

    function calculateGasPriceToOutbid(uint gasSpent, uint deadline) internal view returns (uint) {
        uint blocksUntilDeadline = (deadline - block.timestamp) / 15; // Assuming 15 seconds per block
        uint requiredGasPrice = gasSpent / blocksUntilDeadline;
        return requiredGasPrice;
    }

    function calculateMinProfit(uint amount, uint desiredProfitPercentage) internal pure returns (uint) {
        return (amount * desiredProfitPercentage) / 100;
    }

    function getTokenTax(address tokenAddress) internal view returns (uint) {
        // Implementar la lógica para obtener el impuesto (tax) del token
        // Puede requerir interactuar con el contrato del token
        // y obtener información sobre el impuesto (tax)
    }

    function withdrawTokens(address tokenAddress) external onlyOwner {
        ERC20 token = ERC20(tokenAddress);
        uint balance = token.balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");
        token.transfer(owner, balance);
    }
}

interface ERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}