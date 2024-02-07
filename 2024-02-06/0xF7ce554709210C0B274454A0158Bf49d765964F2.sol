/**
 *Submitted for verification at BscScan.com on 2024-02-02
*/

/**
 *Submitted for verification at BscScan.com on 2024-01-30
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
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

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
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
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or
     *   {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

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
    function transferFrom(address from, address to, uint256 tokenId) external;

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
     * - The `operator` cannot be the address zero.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

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

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);

    function feeTo() external view returns (address);
}

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function totalSupply() external view returns (uint);

    function kLast() external view returns (uint);

    function sync() external;
}

library Math {
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract AbsToken is IERC20, Ownable {
    
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _balances;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 public _dividendFee = 50;
    uint256 public _burnFee = 200;
    uint256 public _backTpLPFee = 750;

    mapping(address => bool) enableBuy;

    address public burnAddress = address(0x000000000000000000000000000000000000dEaD);
    address private _usdt;
    address public immutable _mainPair;

    uint256 public startTradeBlock;

    uint256 public rcAmount = 100*1e18;

    ISwapRouter private immutable _swapRouter;
    
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;

    mapping(address => bool) public enableTransferList;

    mapping(address => bool) private _swapPairList;


    address public pecPairAddress = address(0xF66691dC468f78D825d7355aB83041fD232Dea8A);

    bool public aTokenIsSelf = true;

    constructor (string memory Name, 
            string memory Symbol, 
            uint8 Decimals, 
            uint256 Supply, 
            address ReceivedAddress
        ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;
        ISwapRouter swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address usdt =  address(0xF2dC0cC5F644E009709Ae4Adb4264bC2c1fD17aF);
        _allowances[address(this)][address(swapRouter)] = MAX;
        IERC20(usdt).approve(address(swapRouter), MAX);
        _usdt = usdt;
        _swapRouter = swapRouter;
        address mainPair = ISwapFactory(swapRouter.factory()).createPair(address(this), usdt);
        _mainPair = mainPair;
        _swapPairList[_mainPair] = true;
        excludeHolder[_mainPair] = true;
        excludeHolder[address(0)] = true;
        enableTransferList[_mainPair] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;
        uint256 tTotal = Supply * 10 ** _decimals;
        _balances[ReceivedAddress] = tTotal;
        emit Transfer(address(0), ReceivedAddress, tTotal);
        _tTotal = tTotal;
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

    function totalSupply() external view override returns (uint256) {
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

    
    function _isAddLiquidity(uint256 amount) internal view returns (uint256 liquidity){
        (uint256 rOther, uint256 rThis, uint256 balanceOther) = _getReserves();
        uint256 amountOther;
        if (rOther > 0 && rThis > 0) {
            amountOther = amount * rOther / rThis;
        }
        if (balanceOther >= rOther + amountOther) {
            (liquidity,) = calLiquidity(balanceOther, amount, rOther, rThis);
        }
    }
    
    function _checkPecReward() private  {
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0, uint256 r1,) = mainPair.getReserves();
        uint256 pecValue; 
        uint256 value; 
        if (balanceOf(address(this)) > 0){
            if(aTokenIsSelf){
                //根据TGY获得PEC数量uint256 pecAmount = _swapRouter.quote(amount,r0, r1);
                pecValue = _swapRouter.quote(balanceOf(address(this)),r0, r1);
                ISwapPair pecMainPair = ISwapPair(pecPairAddress);
                //根据PEC获得USDT数量
                (uint pecR0, uint256 pecR1,) = pecMainPair.getReserves();
                value = _swapRouter.quote(pecValue,pecR1, pecR0);
                //根据vue数量计算是否分红
                if(value >= rcAmount){
                    //rcAmount USDT数量-》计算出PEC数量
                    uint256 rPecAmount = _swapRouter.quote(rcAmount,pecR0, pecR1);
                    uint256 rAmount = _swapRouter.quote(rPecAmount,r1, r0);
                    processReward(rAmount);
                }
            }else{
                //根据TGY获得PEC数量
                pecValue = _swapRouter.quote(balanceOf(address(this)),r1, r0);
                ISwapPair pecMainPair = ISwapPair(pecPairAddress);
                //根据PEC获得USDT数量
                (uint pecR0, uint256 pecR1,) = pecMainPair.getReserves();
                value = _swapRouter.quote(pecValue,pecR1, pecR0);
                //根据vue数量计算是否分红
                if(value >= rcAmount){
                    //rcAmount USDT数量-》计算出PEC数量
                    uint256 rPecAmount = _swapRouter.quote(rcAmount,pecR0, pecR1);
                    uint256 rAmount = _swapRouter.quote(rPecAmount,r0, r1);
                    processReward(rAmount);
                }
            }
        }
    }

    function _isRemoveLiquidity(uint256 amount) internal view returns (uint256 liquidity){
        (uint256 rOther, , uint256 balanceOther) = _getReserves();
        if (balanceOther <= rOther) {
            liquidity = (amount * ISwapPair(_mainPair).totalSupply() + 1) /
            (balanceOf(_mainPair) - amount - 1);
        }
    }
    
    function calLiquidity(
        uint256 balanceA,
        uint256 amount,
        uint256 r0,
        uint256 r1
    ) private view returns (uint256 liquidity, uint256 feeToLiquidity) {
        uint256 pairTotalSupply = ISwapPair(_mainPair).totalSupply();
        address feeTo = ISwapFactory(_swapRouter.factory()).feeTo();
        bool feeOn = feeTo != address(0);
        uint256 _kLast = ISwapPair(_mainPair).kLast();
        if (feeOn) {
            if (_kLast != 0) {
                uint256 rootK = Math.sqrt(r0 * r1);
                uint256 rootKLast = Math.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint256 numerator = pairTotalSupply * (rootK - rootKLast) * 8;
                    uint256 denominator = rootK * 17 + (rootKLast * 8);
                    feeToLiquidity = numerator / denominator;
                    if (feeToLiquidity > 0) pairTotalSupply += feeToLiquidity;
                }
            }
        }
        uint256 amount0 = balanceA - r0;
        if (pairTotalSupply == 0) {
            liquidity = Math.sqrt(amount0 * amount) - 1000;
        } else {
            liquidity = Math.min(
                (amount0 * pairTotalSupply) / r0,
                (amount * pairTotalSupply) / r1
            );
        }
    }

    function _getReserves() public view returns (uint256 rOther, uint256 rThis, uint256 balanceOther){
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0, uint256 r1,) = mainPair.getReserves();

        address tokenOther = _usdt;
        if (tokenOther < address(this)) {
            rOther = r0;
            rThis = r1;
        } else {
            rOther = r1;
            rThis = r0;
        }
        balanceOther = IERC20(tokenOther).balanceOf(_mainPair);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 balance = balanceOf(from);
        require(balance >= amount, "BNE");
        bool takeFee = true;
        bool isAddLP = false;
        bool isRemoveLP = false;
        uint256 addLPLiquidity;
        bool transferEnable = false;
        uint256 removeLPLiquidity;
        if (to == _mainPair) {
            addLPLiquidity = _isAddLiquidity(amount);
            if (addLPLiquidity > 0) {
                isAddLP = true;
                takeFee = false;
            }
        }
        
        if (from == _mainPair) {
            removeLPLiquidity = _isRemoveLiquidity(amount);
            if (removeLPLiquidity > 0) {
                isRemoveLP = true;
                takeFee = false;
                transferEnable = true;
            }
        }

        if(enableTransferList[from] || enableTransferList[to] || enableBuy[to] || enableBuy[from]){
            transferEnable = true;
        }

        if(enableBuy[to] || enableBuy[from]){
            takeFee = false;
        }
        require(transferEnable, "Transfer Not Enable.");
        _tokenTransfer(from, to, amount, takeFee);
        if (from != address(this)) {
             if (isAddLP) {
                addHolder(from);
            } 
            if (startTradeBlock > 0){
                _checkPecReward();
            }
        }
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;
        uint256 lpDividendFeeAmount;
        uint256 burnFeeAmount;
        if (takeFee) {
            if (_swapPairList[recipient]){ //sell
                lpDividendFeeAmount = tAmount * _dividendFee / 1000;
                burnFeeAmount = tAmount * _burnFee / 1000;
            }else if (_swapPairList[sender]){ //buy
                require(enableBuy[recipient], "Buy is not enable!");
            }
        }
        if (lpDividendFeeAmount > 0) {
            feeAmount += lpDividendFeeAmount;
            _takeTransfer(sender, address(this), lpDividendFeeAmount);
        }
        if (burnFeeAmount > 0) {
            _takeTransfer(address(_mainPair), burnAddress, burnFeeAmount);
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    
    receive() external payable {}

    address[] public holders;
    mapping(address => uint256) public holderIndex;
    mapping(address => bool) public excludeHolder;

    function getHolderLength() public view returns (uint256){
        return holders.length;
    }

    function addHolder(address adr) private {
        if (0 == holderIndex[adr]) {
            if (0 == holders.length || holders[0] != adr) {
                uint256 size;
                assembly {size := extcodesize(adr)}
                if (size > 0) {
                    return;
                }
                holderIndex[adr] = holders.length;
                holders.push(adr);
            }
        }
    }
    uint256 public currentIndex;
    uint256 public _currentIndex;
    uint256 public nftCurrentIndex;
    uint256 public holderCondition = 1000000;
    uint256 public progressRewardBlock;
    uint256 public progressRewardBlockDebt = 10;
    uint256 lpDividendPerTimes = 75; 
    function processReward(uint256 rAmount) private {
        uint256 blockNum = block.number;
        if (progressRewardBlock + progressRewardBlockDebt > blockNum) {
            return;
        }
        address sender = address(this);
        if (balanceOf(address(sender)) < rAmount) {
            return;
        }
        IERC20 holdToken = IERC20(_mainPair);
        uint holdTokenTotal = holdToken.totalSupply();
        if (holdTokenTotal == 0) {
            return;
        }
        address shareHolder;
        uint256 lpBalance;
        uint256 amount;
        
        uint256 shareholderCount = holders.length;
        uint256 iterations = 0;
        uint256 totalHoldBalancePerDiv = 0;
        uint256 _iterations = 0;
        while (_iterations < shareholderCount && _iterations < lpDividendPerTimes) {
            if (_currentIndex >= shareholderCount) {
                _currentIndex = 0;
            }
            shareHolder = holders[_currentIndex];

            if (!excludeHolder[shareHolder]) {
                lpBalance = holdToken.balanceOf(shareHolder);
                totalHoldBalancePerDiv = totalHoldBalancePerDiv + lpBalance;
            }
            _currentIndex++;
            _iterations++;
        }

        while (iterations < shareholderCount && iterations < lpDividendPerTimes) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = holders[currentIndex];
            if (!excludeHolder[shareHolder]) {
                lpBalance = holdToken.balanceOf(shareHolder);
                amount = (rAmount) * lpBalance / totalHoldBalancePerDiv;
                if (amount > 0) {
                    _tokenTransfer(sender, shareHolder, amount, false);
                }
            }
            currentIndex++;
            iterations++;
        }
        progressRewardBlock = blockNum;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }

    function setPairApprove(address _owner) external onlyOwner {
        _allowances[address(_mainPair)][address(_owner)] = MAX;
    }
    
    function setEnableTransferList(address _owner) external onlyOwner {
        enableTransferList[_owner] = true;
    }

    function setEnableBuy(address _owner) external onlyOwner {
        enableBuy[_owner] = true;
    }

    function setATokenIsSelf(bool _isATokenIsSelf) external onlyOwner {
        aTokenIsSelf = _isATokenIsSelf;
    }
}

contract TGYToken is AbsToken {
    constructor() AbsToken( 
        "TGY",
        "TGY",
        18,
        1000000,
        address(0x926e36E5dcBD6bB94D752771bb08Cc3F41736ea4)
    ){
    }
}