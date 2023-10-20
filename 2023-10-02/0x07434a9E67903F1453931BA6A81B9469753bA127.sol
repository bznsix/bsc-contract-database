// SPDX-License-Identifier: MIT
//Contrato criado por Murilo Fernandes, CEO do projeto Alion Network da empresa ALION NETWORK LTDA
// https://alion.network
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract AlionBonusLocker {
    address public owner;
    IERC20 public usdc; // 0x8e4745F24C837B8a546543196A2747e734B1bA65
    IERC20 public alion; // 0xC9537D2F6E04eE518ba4f32d64639cb93ab482C8
    uint256 public constant MINIMO = 10000 * (10**18); 
    uint256 public constant MAX_HOLDERS = 200;
    //uint256 public constant TEMPO_DE_TRAVA = 2592000; // 3 meses - 90 dias.
    uint256 public constant TEMPO_DE_TRAVA = 1200; // 1 hora

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

    constructor(address _usdc, address _alion) {
        owner = msg.sender;
        usdc = IERC20(_usdc);
        alion = IERC20(_alion);
    }

    function trancarTokens(uint256 amount) external {
        uint256 convertedAmount = amount * (10**18);

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

        if(holderAddresses.length>0 && usdc.balanceOf(address(this))>1000000000000000000){
            distributeUSDC();
        }
        

        require(alion.transferFrom(msg.sender, address(this), convertedAmount), "ALION transfer failed");
        totalLocked += convertedAmount;

        emit TokensLocked(msg.sender, convertedAmount, block.number);
    }

    

    function distributeUSDC() internal {
        uint256 totalUSDC = usdc.balanceOf(address(this));
        for (uint256 i = 0; i < holderAddresses.length; i++) {
            uint256 holderShare = totalUSDC * holders[holderAddresses[i]].balance / totalLocked;
            require(usdc.transfer(holderAddresses[i], holderShare), "Distribution failed");
        }
        emit Distribution(totalUSDC);
    }

    function destrancar() external onlyHolder {
        require(block.number >= holders[msg.sender].blockNumber + TEMPO_DE_TRAVA, "The tokens are still locked");
        
        uint256 amountToUnlock = holders[msg.sender].balance;
        require(alion.transfer(msg.sender, amountToUnlock), "Falha ao desbloquear ALION");
        
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
            require(alion.transfer(holderAddresses[i], amountToReturn), "Falha ao devolver ALION");
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