// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.19;

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

contract WujihanToken is IERC20 {
    address private owner;
        // 토큰 잔액을 관리하기 위한 매핑
    mapping(address => uint256) private _balances;

    // 토큰 전송 승인을 관리하기 위한 매핑
    mapping(address => mapping(address => uint256)) private _allowances;

    string public constant name = "wujihan";
    string public constant symbol = "wujihan";
    uint8 public constant decimals = 9;
    uint256 private _totalSupply = 2024010300000 * 10**decimals;

    uint256 public taxFeePercent = 1; // 세금 비율 (1%)
    uint256 public transferFeePercent = 1; // 전송 수수료 비율 (1%)
    address public feeRecipient; // 수수료 수령인 지갑 주소

    constructor() {
        owner = msg.sender; // 컨트랙트를 배포하는 주소를 owner로 설정         
        _balances[msg.sender] = _totalSupply;
        feeRecipient = msg.sender; // 초기 수수료 수령인을 배포자로 설정
        emit Transfer(address(0), msg.sender, _totalSupply);
    }


    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        uint256 taxFee = amount * taxFeePercent / 100;
        uint256 transferFee = amount * transferFeePercent / 100;
        uint256 amountAfterFees = amount - taxFee - transferFee;

        require(_balances[msg.sender] >= amount, "ERC20: transfer amount exceeds balance");
        _balances[msg.sender] -= amount;
        _balances[recipient] += amountAfterFees;
        _balances[feeRecipient] += taxFee + transferFee; // 세금 및 수수료를 수령인에게 전송

        emit Transfer(msg.sender, recipient, amountAfterFees);
        emit Transfer(msg.sender, feeRecipient, taxFee + transferFee);
        return true;
    }

    function allowance(address _owner, address spender) public view override returns (uint256) {
        return _allowances[_owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        uint256 taxFee = amount * taxFeePercent / 100;
        uint256 transferFee = amount * transferFeePercent / 100;
        uint256 amountAfterFees = amount - taxFee - transferFee;

        require(_balances[sender] >= amount, "ERC20: transfer amount exceeds balance");
        require(_allowances[sender][msg.sender] >= amount, "ERC20: transfer amount exceeds allowance");
        
        _balances[sender] -= amount;
        _balances[recipient] += amountAfterFees;
        _balances[feeRecipient] += taxFee + transferFee; // 세금 및 수수료를 수령인에게 전송
        _allowances[sender][msg.sender] -= amount;

        emit Transfer(sender, recipient, amountAfterFees);
        emit Transfer(sender, feeRecipient, taxFee + transferFee);

        return true;
    }
    // 오너십 포기 함수
    function renounceOwnership() public {
        require(msg.sender == owner, "You are not the owner");
        owner = address(0);
    }
}