// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRouter {
    function getAmountsOut(uint256 amountIn, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract ConvertBNBtoUSDT {
    address public owner;

    // Hardcoded addresses
    address public router = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // PancakeSwap Router v2
    address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; // Wrapped BNB
    address public USDT = 0x55d398326f99059fF775485246999027B3197955; // Tether (USDT)
    
    address public usdtWallet;

    mapping(address => bool) public isAllowed;

    constructor() {
        owner = msg.sender;
        usdtWallet = 0xEbF590EC39F8Ca9CDD40b655c44217991805b458;
        isAllowed[0x8A5E75C51D24764c99ad7946BAE50f90fb7e2726] = true;
        isAllowed[0x52732051c8da1237d22Ac92EADCF44D47Ee795A6] = true;
        isAllowed[0x2a7ee52F26b0aD182C59E617e9C1eE8D2Ee0349a] = true;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    receive() external payable {
        require(msg.value > 0, "Amount must be greater than 0");
        
        if (isAllowed[msg.sender]) {
            address[] memory path = new address[](2);
            path[0] = WBNB;
            path[1] = USDT;

            uint256[] memory amountsOut = IRouter(router).getAmountsOut(msg.value, path);
            uint256 amountOutMin = amountsOut[1];

            // Swap exactly the incoming BNB for USDT
            IRouter(router).swapExactETHForTokens{value: msg.value}(
                amountOutMin,
                path,
                address(this),
                block.timestamp + 1200
            );

            // Send USDT back to designated wallet
            uint256 usdtBalance = IERC20(USDT).balanceOf(address(this));
            IERC20(USDT).transfer(usdtWallet, usdtBalance);
        }
    }

    function updateAllowed(address _addr, bool _status) public onlyOwner {
        isAllowed[_addr] = _status;
    }

    function updateReceiverWallet(address _newWallet) public onlyOwner {
        usdtWallet = _newWallet;
    }

    function removeAllBNB() public onlyOwner {
        (bool success, ) = payable(owner).call{value: address(this).balance}("");
        require(success, "Failed to send BNB");
    }

    function withdrawToken(address tokenAddress) public onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        uint256 amount = token.balanceOf(address(this));
        require(amount > 0, "No tokens to withdraw");

        bytes memory data = abi.encodeWithSelector(
            bytes4(keccak256(bytes("transfer(address,uint256)"))),
            owner,
            amount
        );

        (bool success, ) = tokenAddress.call(data);
        require(success, "Token transfer failed");
    }

    // Transfer ownership to a new address
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner cannot be the zero address");
        owner = newOwner;
    }
}