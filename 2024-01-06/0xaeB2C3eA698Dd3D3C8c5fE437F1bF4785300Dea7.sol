pragma solidity 0.8.18;

/*
 SPDX-License-Identifier: MIT
------------------------------------
 Jonny Blockchain (R) JbCakeTrain smart contract v. 1
 Website :  https://jonnyblockchain.com
------------------------------------
*/
contract JbCakeTrain1 {
    using SafeBEP20 for IBEP20;
    address payable owner;

    /**
     * owner only access
     */
    modifier onlyOwner() {
        if (msg.sender == owner) {
            _;
        }
    }

    constructor() {
        owner = payable(msg.sender);
    }

    /**
     * train call
     */
    function train(uint amountIn, uint amountOutMin, address[] calldata path, address recipient, uint deadline) external onlyOwner {
        require(amountIn > 0, "Zero amount in");

        IBEP20 token = IBEP20(path[0]);
        token.safeTransferFrom(recipient, address(this), amountIn);
        require(token.balanceOf(address(this)) >= amountIn, "Not enough funds");

        uint[] memory result = IPancakeRouter01(0x10ED43C718714eb63d5aA57B78B54704E256024E)
        .swapExactTokensForTokens(amountIn, amountOutMin, path, recipient, deadline);

        require(result[0] > 0 && result[1] > 0, "Exchange finished with a zero result");
    }

    /**
     * approves the token spending cap
     */
    function approve(address spender, address tokenAddress, uint256 amount) external onlyOwner {
        IBEP20 token = IBEP20(tokenAddress);
        token.approve(spender, amount);
    }

    /**
     * this prevents the contract from freezing
     */
    function retrieveToken(address tokenAddress) external onlyOwner {
        IBEP20 token = IBEP20(tokenAddress);
        uint frozen = token.balanceOf(address(this));
        token.safeTransfer(owner, frozen);
    }

    /**
     * this prevents the contract from freezing
     */
    function retrieveBnb() external onlyOwner {
        uint frozen = address(this).balance;
        owner.transfer(frozen);
    }
}

interface IPancakeRouter01 {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;
    function safeTransfer(IBEP20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom(IBEP20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function callOptionalReturn(IBEP20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeBEP20: call to non-contract");
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeBEP20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}