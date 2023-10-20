// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

contract RulePIPIgame {
    address public owner;
    address public tokenAddress = 0xf86E639Ff387b6064607201A7a98F2c2B2FEB05f;
    mapping(address => uint256) public bank;
    uint256 public jackpot;
    uint256 public support;
    uint256 public cantgame;
    bool public isGamePaused;
    IERC20 token;

    event OnPause(address);
    event OnResume(address);
    event OnGameResult(bool);
    event OnViewJackpot(uint256);

    constructor() {
        owner = msg.sender;
        bank[msg.sender] = 500000;
        cantgame = 1000;
        isGamePaused = false;
        token = IERC20(tokenAddress);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function pauseGame() public onlyOwner {
        emit OnPause(msg.sender);
        isGamePaused = true;
    }

    function resumeGame() public onlyOwner {
        emit OnResume(msg.sender);
        isGamePaused = false;
    }

    function balance() public view returns (uint256) {
        return bank[msg.sender];
    }

    function getfullJackpot() public returns (uint256) {
        emit OnViewJackpot(jackpot);
        return jackpot;
    }

    function setCantGame(uint256 newCantGame) public onlyOwner {
        cantgame = newCantGame;
    }

    function play(uint256 number) public returns (bool)
    {
        require(!isGamePaused, "El juego esta en pause");
        require(bank[msg.sender] >= cantgame, "No tienes saldo duficiente");
        
        uint256 rnd = uint256(keccak256(abi.encodePacked(block.number, msg.sender, number))) % 100 + 1;
       
        if (number != rnd){
            jackpot += (cantgame * 80) / 100;
            support += (cantgame * 20) / 100;
            bank[msg.sender] -= cantgame;
            emit OnGameResult(false);
            return false;
        }else{
            bank[msg.sender]+=jackpot;
            jackpot=0;
             emit OnGameResult(true);
            return true;
        }        
    }

    function deposit(address addr, uint256 cant) public onlyOwner {
        bank[addr] += cant;
    }

    function setBalance(uint256 amount) public {
        IERC20 t = IERC20(tokenAddress);
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= amount, "allowance!!");
        t.transferFrom(msg.sender, address(this), amount);
    }
}