// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface INFT {
    function ownerOf(uint256 tokenId) external view returns (address);
    function getCurrentCycle() external view returns (uint256);
    function UpdateCycleReward(uint256 amount) external returns (bool);
    function cycleReward(uint256 cycle) external view returns (uint256);
    function getHashForClaim(uint256 cycle) external view returns (uint256,uint256);
    function ProcessTokenRequest(address account,uint256 amount) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract SuperLandNodeClaimer is Ownable {

    address public matrixAddress = 0xde8256d1B5772102f0b470Ea1AaD698f463188C5;
    address public ticketAddress = 0xe7b03c84FD2EcA8C605097b96AFd69153886aad7;
    address public usdtAddress = 0x55d398326f99059fF775485246999027B3197955;

    bool locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    mapping(address => mapping(uint256 => mapping(uint256 => bool))) public claimed;
    mapping(address => uint256) public totalClaimed;

    constructor() {}

    function claimTicketReward(address account,uint256 cycle,uint256 list) public noReentrant returns (bool) {
        (bool isWinner,,uint256 reward) = checkWinner(account,cycle,list);
        require(isWinner,"Account Not Is Winner This Cycle");
        require(!claimed[account][cycle][list],"Account Claimed This Cycle");
        claimed[account][cycle][list] = true;
        totalClaimed[account] += reward;
        IERC20(usdtAddress).transferFrom(matrixAddress,account,reward);
        return true;
    }

    function checkWinner(address account,uint256 cycle,uint256 list) public view returns (bool isWinner_,bool isJackpot_,uint256 reward_) {
        bool isWinner;
        bool isJackpot;
        INFT ticketNFT = INFT(ticketAddress);
        uint256 currentCycle = ticketNFT.getCurrentCycle();
        uint256 reward = ticketNFT.cycleReward(cycle);
        if(cycle==0){ reward -= 100000000000000000000; }
        (uint256 hash,uint256 count) = ticketNFT.getHashForClaim(cycle);
        require(cycle<currentCycle,"This Cycle Was Not Ended!");
        uint256 winnerTicket = hashToNumber(hash,count,list);
        address winnerAddress = ticketNFT.ownerOf(winnerTicket);
        if(winnerAddress==account){
            isWinner = true;
            if(list==0){
                isJackpot = true;
                reward = reward / 2;
            }else{
                reward = reward / 20;
            }
        }
        return (isWinner,isJackpot,reward);
    }

    function getWinnerCycle(uint256 cycle) public view returns (uint256[] memory ticketNumber_,address[] memory winnerAddress_) {
        INFT ticketNFT = INFT(ticketAddress);
        uint256 currentCycle = ticketNFT.getCurrentCycle();
        (uint256 hash,uint256 count) = ticketNFT.getHashForClaim(cycle);
        require(cycle<currentCycle,"This Cycle Was Not Ended!");
        uint256[] memory result = new uint256[](11);
        address[] memory winner = new address[](11);
        for(uint256 i = 0; i < 11; i++){
            result[i] = hashToNumber(hash,count,i);
            winner[i] = ticketNFT.ownerOf(result[i]);
        }
        return (result,winner);
    }

    function hashToNumber(uint256 hash,uint256 count,uint256 index) public pure returns (uint256) {
        uint256 seed = uint256(keccak256(abi.encodePacked(hash, count, index)));
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(seed)));
        return (randomNumber % count) + 1;
    }

    function callWithData(address to,bytes memory data) public onlyOwner returns (bytes memory) {
        (bool success,bytes memory result) = to.call(data);
        require(success);
        return result;
    }

    function callWithValue(address to,bytes memory data,uint256 amount) public onlyOwner returns (bytes memory) {
        (bool success,bytes memory result) = to.call{ value: amount }(data);
        require(success);
        return result;
    }

    receive() external payable {}
}