pragma solidity ^0.8.19;

// SPDX-License-Identifier: MIT
interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

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

contract SGDToken is IERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    address private _rewardAddress =
        address(0x16d3ad19E119bDB9eba5cA3e0254aB564e54cE8D);
    address private _ceoAddress =
        address(0x741FcFEcD725c229e8314C1426f6Dd9721cd75d5);
    address private _cooAddress =
        address(0x117267fD2010F0522c0DB7F3Ecd412B0A0BF03ED);
    address private _ctoAddress =
        address(0x3687B8bEe037189D6949B49a49B08f6234528BBb);

    address private _mainPair;
    address private _eth = address(0x2170Ed0880ac9A755fd29B2688956BD959F933F8);
    uint256 public _totalSupply; // 代币总供给
    string public _name; // 代币名称
    string public _symbol; // 代币代号
    uint8 public _decimals = 18; // 小数位数
    address private _router =
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    // 构造函数
    constructor() {
        _name = "Sun God Token";
        _symbol = "SGD";
        _totalSupply = 10000000000000000000000000;
        _balances[msg.sender] = _totalSupply;
        ISwapRouter swapRouter = ISwapRouter(_router);
        ISwapFactory pancakeFactory = ISwapFactory(swapRouter.factory());
        address pair = pancakeFactory.createPair(address(this), _eth);

        _mainPair = pair;
    }

    function batchTransfer(
        address[] memory _recipients,
        uint256[] memory _values
    ) public returns (bool) {
        require(_recipients.length > 0);

        for (uint256 i = 0; i < _recipients.length; i++) {
            transferFrom(msg.sender, _recipients[i], _values[i]);
        }

        return true;
    }

    // 转账
    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    // 授权转账
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        uint256 currentAllowance = _allowances[sender][msg.sender];
        if (currentAllowance != ~uint256(0)) {
            require(
                currentAllowance >= amount,
                "ERC20: transfer amount exceeds allowances"
            ); // 是否超过授权额度
            _approve(sender, msg.sender, currentAllowance - amount);
        }
        _transfer(sender, recipient, amount);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        uint256 senderBalance = _balances[sender];
        uint256 addMount = amount;

        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        if (sender == _mainPair && !_isRemoveLiquidity()) {
            addMount = _rewardTransfer(sender, amount, 4, 3, 1);
        } else if (recipient == _mainPair && !_isAddLiquidity(amount)) {
            addMount = _rewardTransfer(sender, amount, 2, 2, 1);
        }

        _balances[sender] = senderBalance - amount;
        _balances[recipient] += addMount;

        emit Transfer(sender, recipient, addMount);
    }

    function _rewardTransfer(
        address sender,
        uint256 amount,
        uint8 propor1,
        uint8 propor2,
        uint8 propor3
    ) private returns (uint256 addMount) {
        uint256 rewardFee = (amount * propor1) / 100;
        uint256 cFee = (amount * propor2) / 100;
        uint256 ceoFee = (cFee * 5) / 10;
        uint256 cooFee = (cFee * 3) / 10;
        uint256 ctoFee = (cFee * 2) / 10;
        uint256 addr0Fee = (amount * propor3) / 100;
        _balances[_rewardAddress] += rewardFee;
        emit Transfer(sender, _rewardAddress, rewardFee);
        _balances[_ceoAddress] += ceoFee;
        emit Transfer(sender, _ceoAddress, ceoFee);
        _balances[_cooAddress] += cooFee;
        emit Transfer(sender, _cooAddress, cooFee);
        _balances[_ctoAddress] += ctoFee;
        emit Transfer(sender, _ctoAddress, ctoFee);
        _balances[address(0)] += addr0Fee;
        emit Transfer(sender, address(0), addr0Fee);
        addMount = amount - rewardFee - cooFee - addr0Fee - ceoFee - ctoFee;
    }

    function _isRemoveLiquidity() internal view returns (bool) {
        (uint256 rOther, , uint256 balanceOther) = _getReserves();
        //isRemoveLP
        return balanceOther < rOther;
    }

    function _isAddLiquidity(uint256 amount) internal view returns (bool) {
        (uint256 rOther, uint256 rThis, uint256 balanceOther) = _getReserves();
        uint256 amountOther;
        if (rOther > 0 && rThis > 0) {
            amountOther = (amount * rOther) / rThis;
        }
        //isAddLP
        return balanceOther >= rOther + amountOther;
    }

    function _getReserves()
        public
        view
        returns (
            uint256 rOther,
            uint256 rThis,
            uint256 balanceOther
        )
    {
        (rOther, rThis) = __getReserves();
        balanceOther = IERC20(_eth).balanceOf(_mainPair);
    }

    function __getReserves()
        public
        view
        returns (uint256 rOther, uint256 rThis)
    {
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint256 r0, uint256 r1, ) = mainPair.getReserves();

        address tokenOther = _eth;
        if (tokenOther < address(this)) {
            rOther = r0;
            rThis = r1;
        } else {
            rOther = r1;
            rThis = r0;
        }
    }

    // 授权
    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function setRewardAddress(address addr) external returns (bool) {
        require(msg.sender == _rewardAddress);
        _rewardAddress = addr;
        return true;
    }

    function ctoAddress() external view returns (address) {
        return _ctoAddress;
    }

    function ceoAddress() external view returns (address) {
        return _ceoAddress;
    }

    function cooAddress() external view returns (address) {
        return _cooAddress;
    }

    function updateCooAddress(address addr) external returns (bool) {
        require(msg.sender == _cooAddress, "address error!");
        _cooAddress = addr;
        return true;
    }

    function updateCtoAddress(address addr) external returns (bool) {
        require(msg.sender == _ctoAddress, "address error!");
        _ctoAddress = addr;
        return true;
    }

    function updateCeoAddress(address addr) external returns (bool) {
        require(msg.sender == _ceoAddress, "address error!");
        _ceoAddress = addr;
        return true;
    }
}

library Math {
    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function feeTo() external view returns (address);
}

interface ISwapPair {
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function totalSupply() external view returns (uint256);

    function kLast() external view returns (uint256);

    function sync() external;
}

interface ISwapRouter {
    function factory() external pure returns (address);
}