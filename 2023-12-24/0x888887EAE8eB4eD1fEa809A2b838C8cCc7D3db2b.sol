// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IEVMS {
    function balanceOf(address account) external view returns (uint);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function mint(address account, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint amount
    ) external returns (bool);
}

interface IPancakeRouter01 {
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);
}

contract EVMSMinter {
    address public owner;
    address public EVMS;
    address public constant panckeRouterAddress =
        0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 public threshold;
    uint256 private constant _value = 0.01 * 10 ** 18;

    uint256[] private mintAmounts = [
        3000 * 10 ** 18, 
        2000 * 10 ** 18,
        1500 * 10 ** 18,
        1100 * 10 ** 18
    ];

    uint256 private constant deployAmount = 1000 * 10 ** 18;

    uint256 public constant maxMint = 1000000;
    uint256 public currMint;

    IEVMS private evmsContractInst;

    constructor(address _evms) {
        owner = msg.sender;
        evmsContractInst = IEVMS(_evms);
        currMint = 0;
        EVMS = _evms;
    }

    function getCurrentPhase() internal view returns (uint256) {
        uint256 phaseLimit1 = maxMint / 4;
        uint256 phaseLimit2 = maxMint / 2;
        uint256 phaseLimit3 = (maxMint * 3) / 4;

        if (currMint <= phaseLimit1) {
            return 0; // first stage
        } else if (currMint <= phaseLimit2) {
            return 1; // second stage
        } else if (currMint <= phaseLimit3) {
            return 2; // third stage
        } else {
            return 3; // fourth stage
        }
    }

    function approvePancake() external {
        require(msg.sender == owner, "non-administrator");
        evmsContractInst.approve(panckeRouterAddress, type(uint256).max);
    }

    function _deployLiquidity(uint256 _amount) internal {
        uint256 deadLine = block.timestamp + 180;
        uint256 balance = address(this).balance;
        // Add liquidity and
        // set the LP receiving address to Black Hole to ensure fairness
        require(evmsContractInst.mint(address(this), _amount), "mint failed");
        IPancakeRouter01(panckeRouterAddress).addLiquidityETH{value: balance}(
            EVMS,
            _amount,
            _amount,
            balance,
            address(0),
            deadLine
        );
        threshold = 0;
    }

    function evmsMinter() internal {
        address _msgSender = msg.sender;
        // For the sake of fairness, contract batches cannot be used.
        require(_msgSender == tx.origin, "Only EOA");

        require(currMint < maxMint, "Already shutdown");
        require(msg.value == _value, "Incorrect value");
        ++threshold;
        ++currMint;
        if (currMint == 1 || currMint % 500 == 0) {
            _deployLiquidity(deployAmount * threshold);
        }

        uint256 stage = getCurrentPhase();
        require(evmsContractInst.mint(_msgSender, mintAmounts[stage]), "mint failed");
    }

    receive() external payable {
        evmsMinter();
    }
}