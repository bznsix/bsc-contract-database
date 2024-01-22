// SPDX-License-Identifier: MIT
//Contrato criado por Murilo Fernandes, CEO do projeto Alion Network da empresa Alion NETWORK LTDA
// https://aliontechfood.com

pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract AlionTechFoodTechFoodBonusLocker {
    address public owner;
    IERC20 public usdc; // 0x8e4745F24C837B8a546543196A2747e734B1bA65
    IERC20 public AlionTechFood; // 0xC9537D2F6E04eE518ba4f32d64639cb93ab482C8
    uint256 public constant MINIMO = 3850 * (10**18); 
    uint256 public constant MAX_HOLDERS = 200;
    uint256 public constant TEMPO_DE_TRAVA = 2592000; // 3 meses - 90 dias.
    //uint256 public constant TEMPO_DE_TRAVA = 1200; // 1 hora

    struct Holder {
        uint256 balance;
        bool exists;
        uint256 blockNumber;
    }

    mapping(address => Holder) public holders;
    address[] public holderAddresses;
    uint256 public totalLocked;

    event TokensLocked(address indexed holder, uint256 amount, uint256 blockNumber);
    event TokensUnlocked(address indexed holder, uint256 amount);
    event TokensReturned(address indexed holder, uint256 amount);
    event Distribution(uint256 totalAmount);

    modifier onlyHolder() {
        require(holders[msg.sender].exists, "You are not a holder");
        _;
    }

    constructor(address _usdc, address _AlionTechFood) {
        owner = msg.sender;
        usdc = IERC20(_usdc);
        AlionTechFood = IERC20(_AlionTechFood);
    }

    function trancarTokens(uint256 amount) external {
        uint256 convertedAmount = amount;

        require(convertedAmount >= MINIMO, "Amount sent is less than the minimum required");
        
        if (!holders[msg.sender].exists) {
            require(holderAddresses.length < MAX_HOLDERS, "Maximum number of holders reached");
            holderAddresses.push(msg.sender);
            holders[msg.sender] = Holder({
                balance: convertedAmount,
                exists: true,
                blockNumber: block.number
            });
        } else {
            holders[msg.sender].balance += convertedAmount;
        }

        require(AlionTechFood.transferFrom(msg.sender, address(this), convertedAmount), "AlionTechFood transfer failed");
        totalLocked += convertedAmount;

        emit TokensLocked(msg.sender, convertedAmount, block.number);
    }

    

    function distributeUSDC() external {
            uint256 totalUSDC = usdc.balanceOf(address(this));
            if (totalUSDC > 0) {
                for (uint256 i = 0; i < holderAddresses.length; i++) {
                    address holderAddress = holderAddresses[i];
                    uint256 holderBalance = holders[holderAddress].balance;
                    uint256 holderShare = (totalUSDC * holderBalance) / totalLocked;

                    require(usdc.transfer(holderAddress, holderShare), "Distribution failed");
                }
                emit Distribution(totalUSDC);
            }
    }


    function destrancar() external onlyHolder {
        require(block.number >= holders[msg.sender].blockNumber + TEMPO_DE_TRAVA, "The tokens are still locked");
        
        uint256 amountToUnlock = holders[msg.sender].balance;
        require(AlionTechFood.transfer(msg.sender, amountToUnlock), "Falha ao desbloquear AlionTechFood");
        
        totalLocked -= amountToUnlock;
        emit TokensUnlocked(msg.sender, amountToUnlock);

        // Remover holder
        for (uint256 i = 0; i < holderAddresses.length; i++) {
            if (holderAddresses[i] == msg.sender) {
                holderAddresses[i] = holderAddresses[holderAddresses.length - 1];
                holderAddresses.pop();
                break;
            }
        }
        delete holders[msg.sender];
    }

    function devolver() external {
        require(msg.sender == owner, "Only the owner can call this function");

        for (uint256 i = 0; i < holderAddresses.length; i++) {
            uint256 amountToReturn = holders[holderAddresses[i]].balance;
            require(AlionTechFood.transfer(holderAddresses[i], amountToReturn), "Falha ao devolver AlionTechFood");
            emit TokensReturned(holderAddresses[i], amountToReturn);
            delete holders[holderAddresses[i]];
        }
        delete holderAddresses;
        totalLocked = 0;
    }

    function getHoldersList() external view returns (address[] memory) {
        return holderAddresses;
    }

    function getHolderData(address holderAddress) external view returns (uint256 balance, uint256 blockNumber) {
        return (holders[holderAddress].balance, holders[holderAddress].blockNumber);
    }

    function getRemainingBlocks(address holderAddress) external view returns (uint256) {
        uint256 blockDifference = block.number - holders[holderAddress].blockNumber;
        if (blockDifference >= TEMPO_DE_TRAVA) {
            return 0;
        }
        return TEMPO_DE_TRAVA - blockDifference;
    }

    function getUSDCForDistribution() external view returns (uint256) {
        return usdc.balanceOf(address(this));
    }

    function getTotalLockedTokens() external view returns (uint256) {
        return totalLocked;
    }

    function getNumberOfHolders() external view returns (uint256) {
        return holderAddresses.length;
    }


}