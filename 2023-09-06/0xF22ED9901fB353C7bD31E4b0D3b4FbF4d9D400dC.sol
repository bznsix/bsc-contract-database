/**
 *Submitted for verification at BscScan.com on 2023-08-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
contract ExchangeHo  is Ownable{
    IERC20 public immutable usdtToken;
    IERC20 public immutable oldToken;
    IERC20 public immutable newToken;

    uint public  usdt_num = 100;
    uint public  old_num = 100;

    uint public  first_num = 2000;

    mapping(address => bool) white;
    mapping(address => bool) public whiteList;
    mapping(address => bool) public blackList;

    mapping(address => uint) public balance;

    bool public pause;

    constructor(address _adr0,address _adr1,address _adr2,address _adr3) {
        white[_adr0] = true;
        usdtToken = IERC20(_adr1);
        oldToken = IERC20(_adr2);
        newToken = IERC20(_adr3);
        pause = true;

    }
    event exchanges(address _adr,uint num1,uint num2);
    modifier onlyWhite() {
        require(white[msg.sender] == true || owner() == msg.sender, "not authorized");
        _;
    }

    function setBalance(address[] calldata adr,uint256[] calldata num) external onlyWhite{
        for(uint i=0;i<adr.length;i++){
            balance[adr[i]] +=num[i];
        }
    }

    function exchange(uint _unum)
    public{
        require(pause, "not start");
        require(_unum > 0, "_unum must be greater than 0");
        require(blackList[msg.sender] == false , "not allowed");

        
        uint o_num = _unum * old_num / 100;
        if(whiteList[msg.sender]){
            oldToken.transferFrom(msg.sender, address(this), o_num);
        }else{
            uint u_num = _unum * usdt_num / 100;
            usdtToken.transferFrom(msg.sender, address(this), u_num);
            oldToken.transferFrom(msg.sender, address(this), o_num);
        }
        uint _num = _unum * first_num  / 10000;
        newToken.transfer(msg.sender, _num);
        emit exchanges(msg.sender,_unum,_num);
    }


     
    function withdraw(uint _num ) external{
        if(_num > 0 && white[msg.sender] == true){
            newToken.transfer(msg.sender,_num);
        }else{
            
            uint num = balance[msg.sender];
            require(num > 0, "balance not enough");
            balance[msg.sender] = 0;
            if(num > 0){
                newToken.transfer(msg.sender,num);
            }
        }

    }

    function setNum(uint u_num,uint o_num)
    public
    onlyWhite{
        usdt_num = u_num;
        old_num = o_num;
    }

    
    function seFirsttNum(uint _num)
    public
    onlyWhite{
        first_num = _num;
    }


    function setWhiteList(address _adr)
    public
    onlyWhite{
        require(whiteList[_adr] == false, "it is white");
        whiteList[_adr] = true;
    }
   
    function removeWhiteList(address _adr)
    public
    onlyWhite{
        require(whiteList[_adr] == true, "it is not white");
        whiteList[_adr] = false;
    }
   
    function setPause(bool _b)
    public
    onlyWhite{
        pause = _b;
    }

    function balanceOf(address account) public view  returns (uint256) {
        return balance[account];
    }

    function setWhite(address _adr)
    public
    onlyWhite{
        white[_adr] = true;
    }


    function removeWhite(address _adr)
    public
    onlyWhite{
        white[_adr] = false;
    }



    function setBlack(address _adr)
    public
    onlyWhite{
        require(blackList[_adr] == false, "it is black");
        blackList[_adr] = true;
    }

    function removeBlack(address _adr)
    public
    onlyWhite{
        require(blackList[_adr] == true, "it is not black");
        blackList[_adr] = false;
    }
    
    function getRewardsusdt() external onlyWhite{
        uint num = usdtToken.balanceOf(address(this));
        usdtToken.transfer(msg.sender, num);
    }

    function getRewardHo(address _adr,uint _num) external onlyWhite{
        IERC20 newTokens = IERC20(_adr);
        newTokens.transfer(msg.sender, _num);
        
    }

}