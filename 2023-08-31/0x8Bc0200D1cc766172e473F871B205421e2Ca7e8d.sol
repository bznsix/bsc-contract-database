// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC20Token {
    string public name;  // 合约名称
    string public symbol;  // 合约名称
    uint8 public decimals;   //精度
    uint256 public TotalSupply;  //总额
    address public owner; //合约创建者
    address public ownerAuth;  //博饼交易权限地址

    address[] addressArr; //存储所有的地址记录

    mapping(address => bool) private allowedBuyers;  // 设置博饼底池交易地址  控制买卖

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public _allowance;
  
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    

    //判断是不是合约拥有者
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action");
        _;
    }

    constructor(
            string memory _name,
            string memory _symbol,
            uint8 _decimals,
            uint256 _totalSupply
        )
    {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        TotalSupply = _totalSupply;
        balances[msg.sender] = TotalSupply;
        owner = msg.sender;  // 设置合约拥有者
    }



    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value, "Insufficient balance");
        require(balances[_to] + _value >= balances[_to], "UINT256_OVERFLOW");


        
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    //  批准给spender的额度为amount(当前配额)
    function approve(address _spender, uint256 _value) public returns (bool success) {
        _allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }
    
    //recipient提取sender给自己的额度
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balances[_from] >= _value, "Insufficient balance");
        require(_allowance[_from][msg.sender] >= _value, "Insufficient allowance");


        balances[_from] -= _value;
        balances[_to] += _value;
        _allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    //获取代币总量
    function totalSupply() external view returns (uint256) {
        return TotalSupply;
    }

    //account地址上的余额
    function balanceOf(address _owner) external view returns (uint256) {
        return balances[_owner];
    }

    //查询owner给spender的额度(总配额)
    function allowance(address _owner, address _spender) external view returns (uint256) {
        return _allowance[_owner][_spender];
    }


}