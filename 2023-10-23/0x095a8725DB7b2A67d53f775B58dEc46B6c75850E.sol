// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.6.12;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
contract Ownable {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnship(address newowner) public onlyOwner returns (bool) {
        owner = newowner;
        return true;
    }
}
abstract contract Context{
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal pure virtual returns (bytes calldata) {
        return msg.data;
    }
}
contract AUCCToken is Ownable {

    string public name = "UCC";
    string public symbol = "UCC";
    uint8 public decimals = 18;
    uint256 public totalSupply = 31000000 * 10 ** 18;

    address public rateAddr = address(0x0); 
    uint256 public Rate = 500;  

    mapping(address => bool) public _swapPairList;  

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    constructor () public {
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    function setRate(uint256 _value) public onlyOwner returns (bool) {
        Rate = _value;
    }
    function setRateAddr(address _addr) public onlyOwner returns (bool) {
        rateAddr = _addr;  
    }
    //增加swap地址
    function addSwapPair(address _addr)public onlyOwner returns(bool){
        _swapPairList[_addr] = true;
    }
    //移除swap地址
    function delSwapPair(address _addr)public onlyOwner returns(bool){
        _swapPairList[_addr] = false;
    }
    function callfee(uint256 _value)public view returns(uint256){
        return _value * Rate / 10000;
    }
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");

        balanceOf[msg.sender] -= _value;

        if(_swapPairList[msg.sender]){         

            balanceOf[_to] += _value - callfee(_value);
            balanceOf[rateAddr] += callfee(_value);
            emit Transfer(msg.sender, _to, _value - callfee(_value));
            emit Transfer(msg.sender, rateAddr, callfee(_value));

        }else{

            balanceOf[_to] += _value;
            emit Transfer(msg.sender, _to, _value);
            
        }

        return true;   
        
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Not enough allowance");

        balanceOf[_from] -= _value;

        if(_swapPairList[_to]){            
            balanceOf[_to] += _value - callfee(_value);
            balanceOf[rateAddr] += callfee(_value);
            emit Transfer(msg.sender, _to, _value - callfee(_value));
            emit Transfer(msg.sender, rateAddr, callfee(_value));

        }else{
            balanceOf[_to] += _value;
            allowance[_from][msg.sender] -= _value;
            emit Transfer(_from, _to, _value);

        }               
        
        return true; 
    }

    function withdraw(address token,address _to,uint256 amount) public onlyOwner returns(bool) {
        return IERC20(token).transfer(_to,amount);
    }
    
}