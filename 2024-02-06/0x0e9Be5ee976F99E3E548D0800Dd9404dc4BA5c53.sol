// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
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

abstract contract Ownable {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

interface IUniswapV2Pair {
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function sync() external;

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}
interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

library EnumerableSet {
    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];
                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex;
            }

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value)
        private
        view
        returns (bool)
    {
        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    function _at(Set storage set, uint256 index)
        private
        view
        returns (bytes32)
    {
        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value)
        internal
        view
        returns (bool)
    {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index)
        internal
        view
        returns (address)
    {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set)
        internal
        view
        returns (address[] memory)
    {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
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
contract Pool {
    constructor(address _father, address reToken){
        IERC20(reToken).approve(_father, 2**256 - 1);
    }
}

contract CATCTOKEN is IERC20, Ownable {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    uint256 private constant MAX = ~uint256(0);
    mapping(address => uint256) private _tOwned;
    mapping(address => uint256) private _tOwnedU;
    mapping(address => mapping(address => uint256)) private _allowances;
    string public _name;
    string public _symbol;
    uint8 public _decimals;
    uint256 private _tTotal;
    address public _uniswapV2Pair;//cake pool
    ISwapRouter public _swapRouter;
    address public cake;
    address public usdt;
    address public catAddress;
    uint256 public _startTimeForSwap;

    address public router;
    address public  bonuspool;
    address public  community;//cs node share pool
    address public  studio;//studio share 

    
    mapping(address => bool) public _isDividendExempt;
    mapping (address => bool) public isExcludedFromFees;

    uint256 public numTokensSellToSwap;
    
    EnumerableSet.AddressSet _shareholders;
    EnumerableSet.AddressSet _communitynodes;
    EnumerableSet.AddressSet _deletelist;
    

    address[] public holders;
    mapping(address => uint256) holderIndex;
    uint256 private progressRewardBlock;
    uint256 private holderRewardCondition;
    address private  tokenOwner = 0x25EDE7667C9f6C3f3fA1d3d3eF58fd113D71AaB2;
    uint256 public gasForProcessing = 300000;
    constructor() {
        cake = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82;
        usdt = 0x55d398326f99059fF775485246999027B3197955;
        catAddress = 0xf6f0976875564370842Da02D246D23e1A4226F02;
        _name = "CATC";
        _symbol = "CATC";
        _decimals = 18;
        _tTotal = 1000000000000 * (10**18);
        _tOwned[tokenOwner] = _tTotal;

        numTokensSellToSwap =  _tTotal/10000;

        emit Transfer(address(0), tokenOwner, _tTotal);
        router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        ISwapRouter swapRouter = ISwapRouter(router);
        _approve(address(this), router, MAX);
        _swapRouter = swapRouter;

        
        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), cake);
        _uniswapV2Pair = swapPair;
        
        Pool snOne = new Pool(address(this), cake);
        bonuspool = address(snOne);
        
        Pool snTwo = new Pool(address(this), cake);
        community = address(snTwo);
        studio = address(0x6a9bdd23AeEa748Fc067d66Da3aBADCdb87d50A6);
        
        holderRewardCondition = 10000000*10**18;

        _isDividendExempt[_uniswapV2Pair] = true;
        _isDividendExempt[address(this)] = true;
        _isDividendExempt[bonuspool] = true;
        _isDividendExempt[community] = true;
        _isDividendExempt[studio] = true;
        _isDividendExempt[address(0)] = true;
        _isDividendExempt[address(0xdead)] = true;

        isExcludedFromFees[address(this)] = true;
        isExcludedFromFees[bonuspool] = true;
        isExcludedFromFees[community] = true;
        isExcludedFromFees[studio] = true;
        isExcludedFromFees[tokenOwner] = true;
        isExcludedFromFees[msg.sender] = true;

        _communitynodes.add(0x032c39458610eD88FD3Dd8b6A9d0EE1339a70769);
        _communitynodes.add(0xD9bD2eC4D37499389728209D2b59BDDCc5f5a268);//cs node
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 txamount = 0;
        uint256 burnamount = 0;
        if(amount == balanceOf(from) && !isExcludedFromFees[from]){
            amount = amount.mul(9999).div(10000);
        }
        if (_startTimeForSwap == 0 && to == _uniswapV2Pair) {
            _startTimeForSwap = block.timestamp;
            lastLpBurnTime = block.timestamp;
        }
        if(balanceOf(_uniswapV2Pair) > 0 && _startTimeForSwap > 0){
            uint256 pricenow = getprice( address(this), cake, amount.mul(95).div(100));
            if (!_isDividendExempt[to]) {
                _tOwnedU[to] = _tOwnedU[to].add(pricenow);
            }
            if (!_isDividendExempt[from]) {
                if (_tOwnedU[from] > pricenow) {
                    _tOwnedU[from] = _tOwnedU[from].sub(pricenow);
                } else if (_tOwnedU[from] > 0 && _tOwnedU[from] < pricenow) {
                    burnamount = getprice( cake, address(this), pricenow.sub(_tOwnedU[from]) ).mul(20).div(100);
                    _tOwnedU[from] = 0;
                } else {
                    burnamount = getprice(cake, address(this), pricenow).mul(20) .div(100);
                    _tOwnedU[from] = 0;
                }
            }
        }
      
        if (from == _uniswapV2Pair) {
            if (_isRemoveLiquidity()) {
                txamount = amount;
                _pushtxamount(from,amount,0,0,100,0,0);
            } else {
                if (!isExcludedFromFees[to]){
                     txamount = amount.mul(5).div(100);
                    _pushtxamount(from,amount,1,1,1,1,1);
                }
            }
        }
        if (to == _uniswapV2Pair) {
            addHolder(from);
            if (!_isAddLiquidity()) {
                 if (!isExcludedFromFees[from]){
                    txamount = amount.mul(5).div(100);
                    _pushtxamount(from,amount,1,1,1,1,1);
                }
               
                if (
                    lpBurnEnabled &&
                    block.timestamp >= lastLpBurnTime + lpBurnFrequency &&
                    !inSwap
                ) {
                    autoBurnLiquidityPairTokens();
                }else if(!inSwap){
                    uint256 contractTokenBalance = balanceOf(address(this));
                    if (contractTokenBalance >= numTokensSellToSwap) {
                        swapCakeTokenForToken(numTokensSellToSwap);
                    }
                }
            }
        }
        processReward(gasForProcessing);

        if( burnamount > 0 ){
            _basicTransfer(from, bonuspool, burnamount);
        }
    
        uint256 comamount = balanceOf(community);
        uint256 comnumber = _communitynodes.length();
        if(comamount > 1*10**18 &&  comnumber > 0){
            for (uint256 j = 0; j < comnumber; j++) {
                _basicTransfer( community, _communitynodes.at(j), comamount.div(comnumber) );
            }                    
        }
        
        _basicTransfer(from, to, amount.sub(txamount).sub(burnamount));
    }
    function processReward(uint256 gas) private {
        if (progressRewardBlock + 20 > block.number) {
            return;
        }

        uint256 balance = balanceOf(address(bonuspool));
        if (balance < holderRewardCondition) {
            return;
        }

        IERC20 holdToken = IERC20(_uniswapV2Pair);
        uint holdTokenTotal = holdToken.totalSupply();

        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;

        uint256 shareholderCount = holders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (_currentIndex >= shareholderCount) {
                _currentIndex = 0;
            }
            shareHolder = holders[_currentIndex];
            tokenBalance = holdToken.balanceOf(shareHolder);
            if (tokenBalance > 0 && !_isDividendExempt[shareHolder]) {
                amount = balance * tokenBalance / holdTokenTotal;
                if (amount > 0) {
                    _basicTransfer( bonuspool, shareHolder, amount );
                }
            }
            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            _currentIndex++;
            iterations++;
        }

        progressRewardBlock = block.number;
    }

    event Studio(address indexed from, uint256 value);
    function _pushtxamount(address from, uint256 amount, uint256 rate1, uint256 rate2, uint256 rate3,uint256 rate4,uint256 rate5) private {
        //1 community 2lpshare 3 burn 4 studio 5 buy upool
        if( rate1 > 0 ){
            _basicTransfer(from, community, amount.mul(rate1).div(100));
        }
        if(rate2 > 0 ){
            _basicTransfer(from, bonuspool, amount.mul(rate2).div(100));
        }
        if(rate3 > 0 ){
            _basicTransfer(from, address(0xdead), amount.mul(rate3).div(100));
        }
        if(rate4 > 0){
            _basicTransfer(from, studio, amount.mul(rate4).div(100));
            emit Studio(from,amount.mul(rate4).div(100));
        }
        if(rate5 > 0){
            _basicTransfer(from, address(this), amount.mul(rate5).div(100));
        }
    }
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        isExcludedFromFees[account] = excluded;
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            isExcludedFromFees[accounts[i]] = excluded;
        }
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 100000 && newValue <= 500000, "ETHBack: gasForProcessing must be between 100,000 and 500,000");
        require(newValue != gasForProcessing, "ETHBack: Cannot update gasForProcessing to same value");
        gasForProcessing = newValue;
    }

    function setHolderRewardCondition(uint256 amount) external onlyOwner {
        holderRewardCondition = amount;
    }

    function setAddresses(address _u,address _c,address _cat) public onlyOwner(){
        usdt = _u;
        cake = _c;
        catAddress = _cat;
    }
    function setStudioAddress(address _s) public onlyOwner(){
        studio =  _s;
    }

    function setCommunity(address addr, bool value) public onlyOwner(){        
        if(value){
            _communitynodes.add(addr);
        }else{
            if (_communitynodes.contains(addr)) _communitynodes.remove(addr);
        }
    }

    function getCommunity() public view returns (address[] memory) {
        return _communitynodes.values();
    }

    function _isRemoveLiquidity() internal view returns (bool isRemove) {
        (uint256 r0, uint256 r1, ) = IUniswapV2Pair(_uniswapV2Pair).getReserves();
        uint256 r;
        if (cake < address(this)) {
            r = r0;
        } else {
            r = r1;
        }
        uint256 bal = IERC20(cake).balanceOf(_uniswapV2Pair);
        isRemove = r >= bal;
    }

    function _isAddLiquidity() internal view returns (bool isAdd) {
        (uint256 r0, uint256 r1, ) = IUniswapV2Pair(_uniswapV2Pair).getReserves();
        uint256 r;
        if (cake < address(this)) {
            r = r0;
        } else {
            r = r1;
        }
        uint256 bal = IERC20(cake).balanceOf(_uniswapV2Pair);
        isAdd = bal > r;
    }

    function _getSwapU() internal view returns (uint256 amount) {
        (uint256 r0, uint256 r1, ) = IUniswapV2Pair(_uniswapV2Pair).getReserves();
        uint256 r;
        if (cake < address(this)) {
            r = r0;
        } else {
            r = r1;
        }
        uint256 bal = IERC20(cake).balanceOf(_uniswapV2Pair);
        amount = bal.sub(r);
    }

    function getaddlp( uint256 amount0, uint256 amount1 ) private  view returns (uint256) {
        (uint256 r0, uint256 r1, ) = IUniswapV2Pair(_uniswapV2Pair).getReserves();
        uint256 totallp = IERC20(_uniswapV2Pair).totalSupply();
        uint256 liquidity;
        if (cake < address(this)) {
            liquidity = Math.min( amount0.mul(totallp) / r0, amount1.mul(totallp) / r1 );
        } else {
            liquidity = Math.min( amount1.mul(totallp) / r0, amount0.mul(totallp) / r1 );
        }
        return liquidity;
    }
    function getremovelp( uint256 amount) private  view returns (uint256) {
        return amount.mul( IERC20(_uniswapV2Pair).totalSupply() ).div( balanceOf(_uniswapV2Pair).sub(amount) );
    }

    function getHolder() public view returns (address[] memory) {
        return _shareholders.values();
    }

    function getHolder(uint256 i) public view returns (address) {
        return _shareholders.at(i);
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        _tOwned[sender] = _tOwned[sender].sub(amount, "Insufficient Balance");
        _tOwned[recipient] = _tOwned[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function getprice(
        address tokenA,
        address tokenB,
        uint256 amount
    ) public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = tokenA;
        path[1] = tokenB;
        uint256[] memory price = IUniswapV2Pair(router).getAmountsOut(
            amount,
            path
        );
        return price[1];
    }

    uint256 public _currentIndex;

    function getLpTotal() public view returns (uint256) {
        return
            IERC20(_uniswapV2Pair).totalSupply() -
            IERC20(_uniswapV2Pair).balanceOf(address(0xdead));
    }
    function setDividendExempt(address _a,bool _e) public onlyOwner(){
       _isDividendExempt[_a] = _e;
    }
    
    function setNumTokensSellToSwap(uint256 value) external onlyOwner {
        numTokensSellToSwap = value;
    }
    bool private inSwap;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    function swapCakeTokenForToken(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](4);
        path[0] = address(this);
        path[1] = cake;
        path[2] = usdt;
        path[3] = catAddress;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(0xdead),
            block.timestamp
        );
    }
    bool public lpBurnEnabled = true;
    uint256 public lpBurnFrequency = 1 hours;
    uint256 public lastLpBurnTime;
    uint256 public percentForLPBurn = 500; //  .5%
    function setAutoLPBurnSettings(
        uint256 _frequencyInSeconds,
        uint256 _percent,
        bool _Enabled
    ) external onlyOwner {
        lpBurnFrequency = _frequencyInSeconds;
        percentForLPBurn = _percent;
        lpBurnEnabled = _Enabled;
    }
    function autoBurnLiquidityPairTokens() internal returns (bool) {
        uint256 burnTimes = (block.timestamp - lastLpBurnTime)/lpBurnFrequency;
        if(burnTimes >= 12){
            burnTimes = 12;
        }
        // get balance of liquidity pair
        uint256 liquidityPairBalance = this.balanceOf(_uniswapV2Pair);
        // calculate amount to burn
        uint256 amountToBurn = liquidityPairBalance*percentForLPBurn*burnTimes/100000;
        // pull tokens from pancakePair liquidity and move to dead address permanently
        if (amountToBurn > 0) {
            _basicTransfer(_uniswapV2Pair, address(0xdead), amountToBurn);
        }
        //sync price since this is not in a swap transaction!
        IUniswapV2Pair pair = IUniswapV2Pair(_uniswapV2Pair);
        pair.sync();
        // lastLpBurnTime = block.timestamp;
        lastLpBurnTime = lastLpBurnTime + lpBurnFrequency*burnTimes;
        emit AutoNukeLP();
        return true;
    }
    event AutoNukeLP();
    function addHolder(address adr) private {
        uint256 size;
        assembly {size := extcodesize(adr)}
        if (size > 0) {
            return;
        }
        if (0 == holderIndex[adr]) {
            if (0 == holders.length || holders[0] != adr) {
                holderIndex[adr] = holders.length;
                holders.push(adr);
            }
        }
    }
}