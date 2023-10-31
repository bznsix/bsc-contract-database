// SPDX-License-Identifier: UNLISCENSED
pragma solidity ^0.8.4;

contract Ownable {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    function setOwner(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "invalid address");
        owner = _newOwner;
    }

    function onlyOwnerCanCallThisFunc() external onlyOwner {
        //code
    }

    function anyOneCanCall() external {
        // code
    }
}

contract LoraxToken is Ownable {
    string public name = "Thicc";
    string public symbol = "THICC";
    uint256 public totalSupply = 69000000 * 1e18;
    uint8 public decimals = 18;

    // Addresses
    address constant DevAddress = 0x4aA95be8674202cc4034a605A1E13a215FB3CB60;
    address constant MarketingAddress = 0x8E3e4CAbF28E6CCF6E0042154CF416531815E13C;
    address constant BurnAddress = 0x000000000000000000000000000000000000dEaD;
    address constant LiquidityAddress = 0xF79C2bD7CC931C22E826eAe59F5eCA0E4FC64FC2;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value); 

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    uint256 private constant MAX_UINT = ~uint256(0);
    uint256 private _rTotal = (MAX_UINT - (MAX_UINT % totalSupply));

    constructor() {
        _rOwned[msg.sender] = _rTotal;
        balanceOf[msg.sender] = totalSupply;
    }

    function reflectionFromToken(uint256 tAmount) private view returns(uint256) {
        require(tAmount <= totalSupply, "Amount must be less than supply");
        return tAmount * _getRate();
    }

    function tokenFromReflection(uint256 rAmount) private view returns(uint256) {
        return rAmount / _getRate();
    }

    function _getRate() private view returns(uint256) {
        return _rTotal / totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        _tokenTransfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender], "Transfer amount exceeds allowance");
        allowance[_from][msg.sender] -= _value;
        _tokenTransfer(_from, _to, _value);
        return true;
    }

    function _tokenTransfer(address _from, address _to, uint256 _value) private {
        uint256 rValue = reflectionFromToken(_value);
        bool isSell = _to == address(this);

        if (isSell) {
            uint256 rDevValue = reflectionFromToken(_value * 2 / 1000); 
            uint256 rMarketingValue = reflectionFromToken(_value / 100); 
            uint256 rBurnValue = reflectionFromToken(_value / 100);
            uint256 rLiquidityValue = reflectionFromToken(_value * 1 / 100); 
            uint256 rReflectionFee = reflectionFromToken(_value / 100); 

            uint256 totalDeduction = tokenFromReflection(rDevValue + rMarketingValue + rBurnValue + rLiquidityValue + rReflectionFee);
            uint256 toRecipientValue = _value - totalDeduction;

            _rOwned[_from] -= rValue;
            _rOwned[_to] += reflectionFromToken(toRecipientValue);
            _rOwned[DevAddress] += rDevValue;
            _rOwned[MarketingAddress] += rMarketingValue;
            _rOwned[BurnAddress] += rBurnValue;
            _rOwned[LiquidityAddress] += rLiquidityValue;

            balanceOf[_from] -= _value;
            balanceOf[_to] += toRecipientValue;
            balanceOf[DevAddress] += tokenFromReflection(rDevValue);
            balanceOf[MarketingAddress] += tokenFromReflection(rMarketingValue);
            balanceOf[BurnAddress] += tokenFromReflection(rBurnValue);
            balanceOf[LiquidityAddress] += tokenFromReflection(rLiquidityValue);

            _rTotal -= rReflectionFee;

            emit Transfer(_from, _to, toRecipientValue);
            emit Transfer(_from, DevAddress, tokenFromReflection(rDevValue));
            emit Transfer(_from, MarketingAddress, tokenFromReflection(rMarketingValue));
            emit Transfer(_from, BurnAddress, tokenFromReflection(rBurnValue));
            emit Transfer(_from, LiquidityAddress, tokenFromReflection(rLiquidityValue));
        } else {
            _rOwned[_from] -= rValue;
            _rOwned[_to] += rValue;
            balanceOf[_from] -= _value;
            balanceOf[_to] += _value;
            emit Transfer(_from, _to, _value);
        }
    }
}