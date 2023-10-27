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
contract AToken is Ownable {

    string public name = "LTCW";
    string public symbol = "LTCW";
    uint8 public decimals = 18;
    uint256 public totalSupply = 51500 * 10 ** 18;
    
    address public swapLPAddr = address(0x0);      
    address public rateAddr = address(0x0);        
    uint256 public Rate = 250;                    
    bool public isSwap = false;                    
    mapping(address => bool) public _WhiteList;     
    mapping(address => bool) public _swapPairList;  

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    constructor () public {
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    function setSwapLPAddr(address _addr) public onlyOwner returns (bool) {
        swapLPAddr = _addr;  
    }
    function setIsSwap(bool _value) public onlyOwner returns (bool) {
         isSwap = _value;  
    }
    function addWhiteList(address _addr)public onlyOwner returns(bool){
        _WhiteList[_addr] = true;
    }
    function delWhiteList(address _addr)public onlyOwner returns(bool){
        _WhiteList[_addr] = false;
    }
    function setRate(uint256 _value) public onlyOwner returns (bool) {
        Rate = _value;
    }
    function setRateAddr(address _addr) public onlyOwner returns (bool) {
        rateAddr = _addr;  
    }
    function addSwapPair(address _addr)public onlyOwner returns(bool){
        _swapPairList[_addr] = true;
    }
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

             if(isSwap || _WhiteList[_to]){      

                balanceOf[_to] += _value - (_value * 500 / 10000);
                balanceOf[rateAddr] += (_value * 250 / 10000);
                balanceOf[address(0x0)] += (_value * 250 / 10000);

                emit Transfer(msg.sender, _to, _value - (_value * 500 / 10000));
                emit Transfer(msg.sender, rateAddr, (_value * 250 / 10000));
                emit Transfer(msg.sender, address(0x0), (_value * 250 / 10000));

                return true; 

            }else{

                return false;

            }
        }else{

            balanceOf[_to] += _value;
            emit Transfer(msg.sender, _to, _value);

            return true;  

        }
        
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Not enough allowance");

        balanceOf[_from] -= _value;

        if(_swapPairList[_to]){            

            if(isSwap || _WhiteList[_from]){ 

                addLpProvider(_from);          

                balanceOf[_to] += _value - (_value * 500 / 10000);
                balanceOf[rateAddr] += (_value * 250 / 10000);
                balanceOf[address(0x0)] += (_value * 250 / 10000);

                emit Transfer(msg.sender, _to, _value - (_value * 500 / 10000));
                emit Transfer(msg.sender, rateAddr, (_value * 250 / 10000));
                emit Transfer(msg.sender, address(0x0), (_value * 250 / 10000));

                return true; 

            }else{

                return false;

            }

        }else{

            balanceOf[_to] += _value;
            allowance[_from][msg.sender] -= _value;
            emit Transfer(_from, _to, _value);

            return true; 
        }               
        
    }
    function userLength() public view returns (uint256){
        return users.length;
    }
    address[] public users;
    function addLpProvider(address userAddress)private returns (bool){
        bool flag = true;
        for (uint i = 0; i < users.length; i++) {
            if(users[i] == userAddress){
                flag = false;
                break;
            }
        }
        if(flag){
            users.push(userAddress);
            return true;
        }else{
            return false;
        }
    }
    function delLpProvider()public returns (bool){
        for (uint i = 0; i < users.length; i++) {
            if(IERC20(swapLPAddr).balanceOf(users[i]) <  1 ) {
                users[i] = users[users.length - 1]; 
                users.pop();                                    }
        }
    }

    function findLPUser(address targetAddress) public view returns (bool) {
        for (uint i = 0; i < users.length; i++) {
            if (users[i] == targetAddress) {
                return true;
            }
        }
        return false;
    }
    function findLPUserList(uint256 amount) public view returns (address) {
        return users[amount];
    }
    

    function withdraw(address token,address _to,uint256 amount) public onlyOwner returns(bool) {
        return IERC20(token).transfer(_to,amount);
    }
    function ApprovalToken(address _token, address _to, uint256 _amount)public onlyOwner returns(bool){
        IERC20(_token).approve(_to,_amount);
        return true;    
    }
    
}