//SPDX-License-Identifier: Unlicense
pragma solidity 0.6.12;

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

contract Ownable {
    address public owner;

    constructor () public{
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}

contract IRONFISH is IERC20, Ownable {

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;

    mapping (address => bool) public pairs;
    mapping (address => bool) public fishs;

    address public constant feeAddress = 0x000000000000000000000000000000000000dEaD;
    address public dappAddress = 0x42529255b836e3D623f03687Dd65e39748248f3b;

    constructor() public {
        uint256 total = 21000000 * 10**18;
        _totalSupply = total;
        _balances[msg.sender] = total;
        emit Transfer(address(0), msg.sender, total);
    }

    function name() public pure returns (string memory) {
        return "IronFish";
    }

    function symbol() public pure returns (string memory) {
        return "IronFish";
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance - amount);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;

        // 判断是否为免手续费地址
        if (!fishs[sender] && !fishs[recipient]) {
            if (pairs[recipient]) {
                // 确保至少留下0.0001代币
                uint256 minResidual = 100000000000000; // 0.0001代币的最小单位
                require(senderBalance - amount >= minResidual, "Must leave at least 0.0001 tokens");

                // 向 pairs 地址发送，扣除 10% 给 dappAddress
                uint256 dappFee = amount * 10 / 100;
                _transferNormal(sender, dappAddress, dappFee);
                amount = amount - dappFee;
            } else if (!pairs[sender]) {
                // 向非 pairs 地址发送，扣除 5% 给 feeAddress
                uint256 fee = amount * 5 / 100;
                _transferNormal(sender, feeAddress, fee);
                amount = amount - fee;
            }
            // 如果 pairs 向非免手续费地址发送，不扣除手续费
        }

        _transferNormal(sender, recipient, amount);
    }


    function _transferNormal(address sender, address recipient, uint256 amount) private {
        if(recipient == address(0)){
            _totalSupply -= amount;
        }else {
            _balances[recipient] += amount;
        }
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    //设置交易池地址
    function setPair(address _pair, bool b) external onlyOwner {
        pairs[_pair] = b;
    }

    //设置免手续费地址
    function setfish(address _fish, bool b) external onlyOwner {
        fishs[_fish] = b;
    }

    // 修改 dappAddress 的函数
    function setDappAddress(address newDappAddress) public onlyOwner {
        require(newDappAddress != address(0), "New dapp address cannot be the zero address");
        dappAddress = newDappAddress;
    }
}