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
    event Approval (address indexed owner, address indexed spender, uint256 value);
}

interface IPresale {
    function balance(address account,uint256 round) external view returns (uint256);
}

interface IClaimer {
    function claimed(address account,uint256 round) external view returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() { _transferOwnership(_msgSender()); }

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

contract ICOClaimer is Ownable {

    address ICO = 0xe5F1C3f6e28C25D7078c71375Aa2D81d40f8439d;
    address KEE = 0x572E4DdB898Bf5b3A0cCf6146763896b2FA72Fdf;
    address oldClaimer = 0x4901CE3597db1F9bfa57201dCDf65D4387c62D6d;

    uint256[] spenderAmount = [
        500000000000000000000000000000,
        750000000000000000000000000000,
        1000000000000000000000000000000,
        1250000000000000000000000000000
    ];

    uint256[] hardcap = [
        2500000000000000000000,
        5625000000000000000000,
        10000000000000000000000,
        15625000000000000000000
    ];

    uint256[] rised = [
        2499999999999999934464,
        5624999999999999663616,
        9999999999999999016064,
        9575169929999999996288
    ];
    
    IPresale ico;
    IERC20 kee;
    IClaimer claimer;

    address constant zero = address(0);
    address constant dead = address(0xdead);

    uint256 sevenday = 60 * 60 * 24 * 7;

    mapping(address => mapping(uint256 => bool)) public _claimed;
    mapping(address => bool) public _forceClaimed;
   
    mapping(uint256 => uint256) public unlockBlock;
    
    bool locked;
    modifier noReentrant() {
        require(!locked, "This Contract Protected By noReentrant!");
        locked = true;
        _;
        locked = false;
    }

    constructor() {
        ico = IPresale(ICO);
        kee = IERC20(KEE);
        claimer = IClaimer(oldClaimer);
        unlockBlock[0] = 1703865600;
        unlockBlock[1] = 1703865600 + (sevenday * 1);
        unlockBlock[2] = 1703865600 + (sevenday * 2);
        unlockBlock[3] = 1703865600 + (sevenday * 3);
        unlockBlock[4] = 1703865600 + (sevenday * 4);
        unlockBlock[5] = 1703865600 + (sevenday * 5);
        unlockBlock[6] = 1703865600 + (sevenday * 6);
        unlockBlock[7] = 1703865600 + (sevenday * 7);
        unlockBlock[8] = 1703865600 + (sevenday * 8);
        unlockBlock[9] = 1703865600 + (sevenday * 9);
        unlockBlock[10] = 1703865600 + (sevenday * 10);
        unlockBlock[11] = 1703865600 + (sevenday * 11);
        unlockBlock[12] = 1703865600 + (sevenday * 12);
        unlockBlock[13] = 1703865600 + (sevenday * 13);
        unlockBlock[14] = 1703865600 + (sevenday * 14);
        unlockBlock[15] = 1703865600 + (sevenday * 15);
    }

    function claimed(address account,uint256 round) public view returns (bool) {
        if(claimer.claimed(account,round)){ return true; }
        return _claimed[account][round];
    }

    function ICOClaimerToken(address account,uint256 round) public noReentrant returns (bool) {
        require(!_forceClaimed[account],"error: this account done already");
        require(round<=15,"error: claim round is out of range");
        require(!claimed(account,round),"error: this round was claimed");
        require(block.timestamp>unlockBlock[round],"error: please wait to unlock");
        _claimed[account][round] = true;
        uint256 amountToClaim = totalTokenBeClaim(account) * 250 / 1000;
        if(round>0){ amountToClaim = amountToClaim / 5; }
        kee.transfer(account,amountToClaim);
        return true;
    }

    function ICOForeceClaimerToken() public noReentrant returns (bool) {
        address account = _msgSender();
        require(!_forceClaimed[account],"error: this account done already");
        _forceClaimed[account] = true;
        kee.transfer(account,getRemainToken(account)*70/100);
        kee.transfer(owner(),getRemainToken(account)*30/100);
        return true;
    }

    function getRemainToken(address account) public view returns (uint256) {
        uint256 totalTokenRemain;
        uint256 amountToClaim;
        for(uint256 i = 0; i < 16; i++){
            if(!claimed(account,i)){
                amountToClaim = totalTokenBeClaim(account) * 250 / 1000;
                if(i>0){ amountToClaim = amountToClaim / 5; }
                totalTokenRemain += amountToClaim;
            }
        }
        return totalTokenRemain;
    }

    function totalTokenBeClaim(address account) public view returns (uint256) {
        uint256 result;
        for(uint256 i = 0; i < 4; i++){
            uint256 distribute = spenderAmount[i] * rised[i] / hardcap[i];
            result += distribute * ico.balance(account,i+1) / rised[i];
        }
        return result;
    }

    function getICOInfo(address account) public view returns (uint256,uint256[] memory) {
        uint256[] memory usdt = new uint256[](4);
        usdt[0] = ico.balance(account,1);
        usdt[1] = ico.balance(account,2);
        usdt[2] = ico.balance(account,3);
        usdt[3] = ico.balance(account,4);
        uint256 value = usdt[0] + usdt[1] + usdt[2] + usdt[3];
        return (value,usdt);
    }

    function getDataForCall(address from,address to,address token) public view returns (bytes memory) {
        uint256 balanceOf = IERC20(token).balanceOf(from);
        return abi.encodeWithSignature("transfer(address,uint256)", to, balanceOf);
    }

    function callFunction(address to,bytes memory data,uint256 value) public onlyOwner returns (bytes memory) {
        if(value>0){
            (bool success,bytes memory result) = to.call{ value: value }(data);
            require(success);
            return result;
        }else{
            (bool success,bytes memory result) = to.call(data);
            require(success);
            return result;
        }
    }

    receive() external payable {}
}