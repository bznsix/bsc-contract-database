pragma solidity =0.6.6;

import '../libraries/SafeMath.sol';

contract ERC20 {
    using SafeMath for uint;
    address public owner;
    string public constant name = 'Test DD';
    string public constant symbol = 'DD';
    uint public constant decimals = 18;
    uint  public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    uint256 public buyFee;
    address public buyFeeAddress;

    uint256 public sellFee_xh;
    uint256 public sellFee_xm;
    address public sellFeeAddress_xh;
    address public sellFeeAddress_xm;

    mapping (address => bool) public whitelist;
    mapping (address => bool) public feelist;

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    constructor() public {
        uint _totalSupply =210000000*10**decimals;
        _mint(msg.sender, _totalSupply);
        owner = msg.sender;
        buyFee=20;
        buyFeeAddress=0x0000000000000000000000000000000000000001;
        sellFee_xh=5;
        sellFee_xm=5;
        sellFeeAddress_xh=0x0000000000000000000000000000000000000001;
        sellFeeAddress_xm=msg.sender;
    }

    function _mint(address to, uint value) internal {
        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint value) internal {
        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function _approve(address _owner, address spender, uint value) private {
        allowance[_owner][spender] = value;
        emit Approval(_owner, spender, value);
    }
    function _tran_sfer(address from, address to, uint value) private {
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }
    function _transfer(address from, address to, uint value) private {
        if (whitelist[from]==false && whitelist[to]==false) {
            if(buyFee>0 && feelist[from]){
                uint256 buyFeeAmount =value.mul(buyFee)/100;
                if(buyFeeAmount>0){
                    _tran_sfer(from, buyFeeAddress, buyFeeAmount);
                    value-=buyFeeAmount;
                }
            }else if(feelist[to]){
                if(sellFee_xh>0){
                    uint256 sellFee_xhAmount =value.mul(sellFee_xh)/100;
                    if(sellFee_xhAmount>0){
                        _tran_sfer(from, sellFeeAddress_xh, sellFee_xhAmount);
                        value-=sellFee_xhAmount;
                    }

                }
                if(sellFee_xm>0){
                    uint256 sellFee_xmAmount =value.mul(sellFee_xm)/100;
                    if(sellFee_xmAmount>0){
                        _tran_sfer(from, sellFeeAddress_xm, sellFee_xmAmount);
                        value-=sellFee_xmAmount;
                    }
                }
            }

        }
        _tran_sfer(from, to, value);
    }

    function approve(address spender, uint value) external returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) external returns (bool) {
        if (allowance[from][msg.sender] != uint(-1)) {
            allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        }
        _transfer(from, to, value);
        return true;
    }
    modifier onlyOwner() {
        require(msg.sender == owner, 'onlyOwner() Error:10000');
        _;
    }
    function TransferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), 'TransferOwnership() Error:10000');
        owner = newOwner;
    }
    function setBuyFee(uint256 _buyFee) public onlyOwner {
        require(_buyFee>0&&_buyFee<100, 'setBuyFee() Error:10000');
        buyFee=_buyFee;
    }
    function setBuyAddress(address _buyFeeAddress) public onlyOwner {
        buyFeeAddress=_buyFeeAddress;
    }
    function setSellFee(uint256  _sellFee_xh,uint256  _sellFee_xm) public onlyOwner {
        require(_sellFee_xh>0&&_sellFee_xh<100, 'setBuyFee() Error:10000');
        require(_sellFee_xm>0&&_sellFee_xm<100, 'setBuyFee() Error:10000');
        uint z=_sellFee_xh+_sellFee_xm;
        require(z>0&&z<100, 'setBuyFee() Error:10000');
        sellFee_xh=_sellFee_xh;
        sellFee_xm=_sellFee_xm;
    }
    function setSellAddress(address _sellFeeAddress_xh,address _sellFeeAddress_xm) public onlyOwner {
        sellFeeAddress_xh=_sellFeeAddress_xh;
        sellFeeAddress_xm=_sellFeeAddress_xm;
    }
    function setWhitelist(address account,bool status) public onlyOwner {
        whitelist[account]=status;
    }
    function setFeelist(address account,bool status) public onlyOwner {
        feelist[account]=status;
    }
}
pragma solidity =0.6.6;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}
