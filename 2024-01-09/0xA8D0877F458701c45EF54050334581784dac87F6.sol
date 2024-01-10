// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "./interfaces/IFactory.sol";
import "./interfaces/IIns20.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IPancakeRouter02.sol";
import "./interfaces/IPancakeFactory.sol";
import "./interfaces/IWETH.sol";
import "./library/SafeMath.sol";

contract Ins20 is IIns20 {
    using SafeMath for uint256;

    event SetRewardPoolInfo(uint256 rewardAmount, uint256 rewardMintCount);
    event SetBurnPct(uint256 pct);
    event SetSplitToken(address token);
    event SetRouter(address router);
    event ClaimSuccessMint(address indexed sender, uint256 recordIndex, bool splitToToken);
    event BatchClaimSuccessMint(address indexed sender, bool splitToToken);
    event ClaimRewardPool(address indexed sender, uint256 bonusAmount, uint256 prizeAmount);
    event Split(address indexed sender, uint256 amount, uint256 tokenAmount);
    event Merge(address indexed sender, uint256 tokenAmount, uint256 amount);

    struct MintInfo {
        bool claimed;
        uint16 mintIndex;
        uint256 blockNum;
        uint256 blockIndex;
    }

    struct BlockInfo {
        uint16 mintCount;
        bytes32 preBlockHash;
    }

    struct BonusInfo {
        uint256 shares;
        uint256 pending;
        uint256 rewardPaid;
    }

    uint256 public maxSupply;
    uint256 public amountPerMint;
    uint256 public fee;
    uint256 public totalMinted;
    address public factory;
    uint256 public holderAmount;
    uint256 public txAmount;
    uint256 public deployTime;
    address public deployer;
    address public splitToken;
    string public tick;
    address public router;
    mapping(uint256 => BlockInfo) public blockNumberToBlockInfo;
    uint256 public mintBlockCount;
    MintInfo[] public mintInfo;
    mapping(address => uint256[]) public userMintInfo;
    mapping(address => BonusInfo) public userBonusInfo;
    mapping(uint256 => address) public blockAndIndexToUser;
    mapping(uint256 => uint256) public mintCountToBlockNumber;

    // erc20 standard
    mapping(address => uint256) private _balances;
    uint256 private _totalSupply;
    uint256 public rewardAmountOfPool;
    uint256 public rewardMintCountOfPool;
    uint256 public startRewardMintCountOfPool;
    uint256 public burnPct;
    uint256 public accPerShare;
    uint256 public sharesTotal;

    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;
    bool public startMint;

    constructor(
        uint256 _maxSupply,
        uint256 _amountPerMint,
        uint256 _fee,
        address _factory,
        address _deployer,
        string memory _tick
    ) {
        maxSupply = _maxSupply;
        amountPerMint = _amountPerMint;
        fee = _fee;
        factory = _factory;
        deployer = _deployer;
        tick = _tick;

        totalMinted = 0;
        deployTime = block.timestamp;
        burnPct = 50;
    }

    function setStartMint(bool _startMint) external {
        require(msg.sender == deployer, "not deployer");
        startMint = _startMint;
    }

    function setSplitToken(address _splitToken) external {
        require(msg.sender == deployer, "not deployer");
        require(_splitToken != address(0), "invalid split token");
        splitToken = _splitToken;
        uint256 tokenAmount = maxSupply * (10 ** IERC20(splitToken).decimals());
        IERC20(splitToken).transferFrom(msg.sender, address(this), tokenAmount);
        emit SetSplitToken(_splitToken);
    }

    function setRouter(address _router) external {
        require(msg.sender == deployer, "not deployer");
        require(_router != address(0), "invalid split token");
        require(splitToken != address(0), "split token is zero address");
        address weth = IPancakeRouter02(_router).WETH();
        address tokenFactory = IPancakeRouter02(_router).factory();
        require(IPancakeFactory(tokenFactory).getPair(splitToken, weth) != address(0), "no pair");
        router = _router;
        IERC20(weth).approve(_router, type(uint256).max);
        emit SetRouter(_router);
    }

    function setRewardPoolInfo(uint256 _rewardAmount, uint256 _rewardMintCount) external {
        require(msg.sender == deployer, "not deployer");
        require(splitToken != address(0));
        rewardAmountOfPool = _rewardAmount;
        rewardMintCountOfPool = _rewardMintCount;
        startRewardMintCountOfPool = maxSupply / amountPerMint - rewardMintCountOfPool + 1;
        IERC20(splitToken).transferFrom(msg.sender, address(this), _rewardAmount);
        emit SetRewardPoolInfo(_rewardAmount, _rewardMintCount);
    }

    function setBurnPct(uint256 _pct) external {
        require(msg.sender == deployer, "not deployer");
        require(_pct <= 100);
        burnPct = _pct;
        emit SetBurnPct(_pct);
    }

    function mint(address to, uint256 amount) public payable override returns(bool){
        require(msg.sender == factory, "only factory can mint");
        require(startMint == true, "not start");
        uint256 mintAmount = amount;
        require(mintAmount == amountPerMint, "invalid amount");
        if (fee > 0) {
            require(msg.value == fee, "invalid value");
            require(mintAmount * mintBlockCount < maxSupply, "max supply exceeded");
            _recordMintInfo(to, block.number);
            return false;
        }
        require(totalMinted + mintAmount <= maxSupply, "max supply exceeded");
        totalMinted += mintAmount;
        _mint(to, mintAmount);
        return true;
    }

    function split(uint256 amount) public {
        require(splitToken != address(0), "not support split");
        require(msg.sender == tx.origin, "not EOA");
        require(amount > 0, "invalid amount");
        require(balanceOf(msg.sender) >= amount, "split amount exceeds balance");
        unchecked {
            _balances[msg.sender] -= amount;
        }
        _totalSupply -= amount;
        if(balanceOf(msg.sender) == 0) holderAmount--;
        txAmount++;

        uint256 tokenAmount = amount * (10 ** IERC20(splitToken).decimals());
        require(IERC20(splitToken).balanceOf(address(this)) >= tokenAmount);
        IERC20(splitToken).transfer(msg.sender, tokenAmount);
        _swap(50 * fee);
        emit Split(msg.sender, amount, tokenAmount);
    }

    function merge(uint256 tokenAmount) public {
        require(splitToken != address(0), "not support merge");
        require(msg.sender == tx.origin, "not EOA");
        require(tokenAmount > 0, "invalid amount");
        require(IERC20(splitToken).balanceOf(msg.sender) >= tokenAmount, "merge amount exceeds balance");
        IERC20(splitToken).transferFrom(msg.sender, address(this), tokenAmount);

        uint256 amount = tokenAmount / (10 ** IERC20(splitToken).decimals());
        _mint(msg.sender, amount);
        emit Merge(msg.sender, tokenAmount, amount);
    }

    function swap(uint256 maxBalance) external {
        require(msg.sender == deployer, "not deployer");
        _swap(maxBalance);
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        return true;
    }
    
    function decimals() public pure returns (uint8) {
        return 0;
    }

    function name() external view returns(string memory) {
        return tick;
    }

    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public override view returns(uint256) {
        return _balances[account];
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "transfer from the zero address");
        require(recipient != address(0), "transfer to the zero address");
        require(IFactory(factory).isOperator(msg.sender), "!operator");
        require(amount > 0, "transfer 0");

        if(balanceOf(recipient) == 0) holderAmount++;

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "transfer amount exceeds balance");
        
        unchecked {
            _balances[sender] = senderBalance - amount;
            _balances[recipient] += amount;
        }
        if(balanceOf(sender) == 0) holderAmount--;
        txAmount++;
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "mint to the zero address");

        if(balanceOf(account) == 0) holderAmount++;

        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
        txAmount++;
    }

    function _swap(uint256 maxBalance) internal {
        if (maxBalance == 0 || router == address(0)) {
            return;
        }

        uint256 balance = address(this).balance;
        if (balance == 0) {
            return;
        }

        if (balance > maxBalance) {
            balance = maxBalance;
        }

        address weth = IPancakeRouter02(router).WETH(); 
        IWETH(weth).deposit{value: balance}();

        address[] memory path = new address[](2);
        path[0] = weth;
        path[1] = splitToken;
        uint256 beforeOutAmount = IERC20(splitToken).balanceOf(address(this));
        IPancakeRouter02(router)
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                balance,
                0,
                path,
                address(this),
                block.timestamp + 60
            );
        uint256 afterOutAmount = IERC20(splitToken).balanceOf(address(this));
        uint256 outAmount = afterOutAmount - beforeOutAmount;
        uint256 burnAmount = outAmount * burnPct / 100;
        if (burnAmount > 0)
            IERC20(splitToken).transfer(DEAD, burnAmount);

        _distribute(outAmount - burnAmount);
    }

    function _recordMintInfo(address _to, uint256 _blockNumber) internal {
        BlockInfo memory blockInfo = blockNumberToBlockInfo[_blockNumber];
        if (blockInfo.mintCount == 0) {
            mintBlockCount++;
            blockInfo.preBlockHash = blockhash(_blockNumber - 1);
            mintCountToBlockNumber[mintBlockCount] = _blockNumber;
        }
        blockInfo.mintCount++;
        blockNumberToBlockInfo[_blockNumber] = blockInfo;

        MintInfo memory mInfo;
        mInfo.claimed = false;
        mInfo.blockNum = _blockNumber;
        mInfo.mintIndex = blockInfo.mintCount;
        mInfo.blockIndex = mintBlockCount;
        mintInfo.push(mInfo);
        userMintInfo[_to].push(mintInfo.length);

        BonusInfo memory bonus = userBonusInfo[_to];
        uint256 pending = bonus.shares.mul(accPerShare).div(1e12).sub(bonus.rewardPaid);
        bonus.pending = bonus.pending.add(pending);
        bonus.shares = bonus.shares.add(fee);
        bonus.rewardPaid = bonus.shares.mul(accPerShare).div(1e12);
        userBonusInfo[_to] = bonus;
        sharesTotal = sharesTotal.add(fee);

        if (startRewardMintCountOfPool > 0 && mintBlockCount >= startRewardMintCountOfPool) {
            blockAndIndexToUser[getIndexOf(mInfo.blockIndex, mInfo.mintIndex)] = _to;
        }
    }

    function _distribute(uint256 _rewardAmount) internal {
        if (_rewardAmount == 0) {
            return;
        }

        if (sharesTotal == 0) {
            return;
        }
        accPerShare = accPerShare.add(_rewardAmount.mul(1e12).div(sharesTotal));
    }

    function claimSuccessMint(uint256 recordIndex, bool splitToToken) public {
        require(msg.sender == tx.origin, "not EOA");
        if (splitToToken) {
            require(splitToken != address(0), "not support split");
        }
        _claimSuccessMint(msg.sender, recordIndex, splitToToken);
        if (splitToToken) {
            uint256 tokenAmount = amountPerMint * (10 ** IERC20(splitToken).decimals());
            require(IERC20(splitToken).balanceOf(address(this)) >= tokenAmount);
            IERC20(splitToken).transfer(msg.sender, tokenAmount);
        }
        _swap(50 * fee);
        emit ClaimSuccessMint(msg.sender, recordIndex, splitToToken);
    }

    function batchClaimSuccessMint(uint256[] memory recordsIndex, bool splitToToken) public {
        require(msg.sender == tx.origin, "not EOA");
        if (splitToToken) {
            require(splitToken != address(0), "not support split");
        }

        for (uint256 i = 0; i < recordsIndex.length; ++i) {
            _claimSuccessMint(msg.sender, recordsIndex[i], splitToToken);
        }

        if (splitToToken) {
            uint256 tokenAmount = recordsIndex.length * amountPerMint * (10 ** IERC20(splitToken).decimals());
            require(IERC20(splitToken).balanceOf(address(this)) >= tokenAmount);
            IERC20(splitToken).transfer(msg.sender, tokenAmount);
        }
        _swap(50 * fee);
        emit BatchClaimSuccessMint(msg.sender, splitToToken);
    }

    function _claimSuccessMint(address addr, uint256 recordIndex, bool splitToToken) internal{
        MintInfo memory info = mintInfo[userMintInfo[addr][recordIndex]-1];
        require(info.blockNum > 0, "invalid record");
        require(info.claimed == false, "already claim");
        require(info.mintIndex == getMintSuccessIndex(info.blockNum), "not success index");
        info.claimed = true;
        mintInfo[userMintInfo[addr][recordIndex]-1] = info;
        uint256 mintAmount = amountPerMint;
        require(totalMinted + mintAmount <= maxSupply, "max supply exceeded");
        totalMinted += mintAmount;
        if (!splitToToken) {
            _mint(addr, mintAmount);
        }
    }

    function totalMintInfo() public view returns(
        uint256 maxSupply_,
        uint256 amountPerMint_,
        uint256 fee_,
        uint256 totalMinted_,
        uint256 mintBlockAmount_,
        uint256 mintTxAmount_
    ) {
        maxSupply_ = maxSupply;
        amountPerMint_ = amountPerMint;
        fee_ = fee;
        totalMinted_ = totalMinted;
        mintBlockAmount_ = mintBlockCount;
        mintTxAmount_ = mintInfo.length;
    }

    function getUserMintLength(address user) public view returns(uint256) {
        return userMintInfo[user].length;
    }

    struct UserMintRecords {
        bool claimed;
        uint16 mintIndex;
        uint16 successMintIndex;
        uint256 blockNum;
        uint256 blockIndex;
    }

    function getUserMintRecords(address addr,uint256 page, uint256 pageSize) public view returns (UserMintRecords[] memory records) {
        require(page > 0, "!pNumber");
        require(pageSize > 0, "!pSize");
        uint256 start = (page - 1) * pageSize;
        uint256 end = start + pageSize;
        uint256 length = getUserMintLength(addr);
        if (end > length) {
            end = length;
        }
        if (end < start) {
            end = start;
        }

        records = new UserMintRecords[](end - start);
        for (uint256 i = start; i < end; i++) {
            MintInfo memory info = mintInfo[userMintInfo[addr][i]-1];
            records[i - start].claimed = info.claimed;
            records[i - start].mintIndex = info.mintIndex;
            records[i - start].blockNum = info.blockNum;
            records[i - start].blockIndex = info.blockIndex;
            records[i - start].successMintIndex = getMintSuccessIndex(info.blockNum);
        }
    }

    function getMintSuccessIndex(uint256 blockNumber) public view returns(uint16 index) {
        BlockInfo memory blockInfo = blockNumberToBlockInfo[blockNumber];
        if (blockInfo.mintCount == 0) {
            return 0;
        }

        bytes32 bHash = keccak256(abi.encodePacked(
            blockInfo.preBlockHash,
            blockInfo.mintCount
        ));
        uint8 firstNumber = uint8(bHash[0]) / 16;
        uint256 r = uint256(bHash) % 2;
        index = 0;
        if (r == 0) {
            if (firstNumber >= blockInfo.mintCount) {
                index = blockInfo.mintCount;
            } else {
                index = firstNumber + 1;
            }
        } else {
            if (firstNumber >= blockInfo.mintCount) {
                index = 1;
            } else {
                index = blockInfo.mintCount - firstNumber;
            }
        }
    }

    function getIndexOf(uint256 blockIndex, uint256 mintIndex) public pure returns(uint256) {
        return blockIndex * 100000 + mintIndex;
    }

    function getRewardPoolInfoOf(address _user) public view returns(uint256 bonusAmount, uint256 prizeAmount) {
        BonusInfo memory bonus = userBonusInfo[_user];
        uint256 pending = bonus.shares.mul(accPerShare).div(1e12).sub(bonus.rewardPaid);
        bonusAmount = bonus.pending.add(pending);
        if (bonus.shares > 0 && startRewardMintCountOfPool > 0 && mintBlockCount >= startRewardMintCountOfPool) {
            uint256 perPrizeAmount = rewardAmountOfPool / rewardMintCountOfPool;
            for (uint256 i = startRewardMintCountOfPool; i <= mintBlockCount; ++i) {
                uint256 blockNumber = mintCountToBlockNumber[i];
                uint256 successIndex = getMintSuccessIndex(blockNumber);
                address winner = blockAndIndexToUser[getIndexOf(i, successIndex)];
                if (winner == _user) {
                    prizeAmount += perPrizeAmount;
                }
            }
        }
    }

    function claimRewardPool() external {
        require(msg.sender == tx.origin, "not EOA");
        require(mintBlockCount * amountPerMint >= maxSupply, "mint not finished");
        _swap(address(this).balance);
        (uint256 bonusAmount, uint256 prizeAmount) = getRewardPoolInfoOf(msg.sender);
        uint256 rewardAmount = bonusAmount + prizeAmount;
        require(rewardAmount > 0, "reward amount == 0");
        delete userBonusInfo[msg.sender];

        require(IERC20(splitToken).balanceOf(address(this)) >= rewardAmount);
        IERC20(splitToken).transfer(msg.sender, rewardAmount);
        emit ClaimRewardPool(msg.sender, bonusAmount, prizeAmount);
    }

    receive() external payable {}
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the number of decimals used to get its user representation.
     */
    function decimals() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

interface IFactory {
    struct INS20Token {
        address tokenAddress;
        string tick;
        uint256 maxSupply;
        uint256 amountPerMint;
        uint256 fee;
        uint256 deployId;
        address deployer;
        uint256 timestamp;
    }

    struct ListTick {
        string tick;
        uint256 listId;
        address listOwner;
        uint256 amt;
        uint256 price;
        uint256 perPrice;
        uint256 timestamp;
    }

    function isOperator(address) external view returns (bool);
    function getTokenCount() external view returns (uint256);
    function ins20TokensOf(uint256 index) external view returns(INS20Token memory);
    function ins20Contracts(string memory) external view returns(address);
    function ins20TokenIndex(address) external view returns(uint256);
    function getTickListsCount(string memory tick) external view returns(uint256);
    function tickListOf(string memory tick, uint256 index) external view returns(ListTick memory);
    function getOwnerListCount(address account) external view returns(uint256);
    function ownerListOf(address account, uint256 index) external view returns(ListTick memory);
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IIns20 {
    function mint(address to, uint256 amount) external payable returns(bool);
    function name() external view returns(string memory);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint256) external view returns (address pair);
    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "./IPancakeRouter01.sol";

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function sqrrt(uint256 a) internal pure returns (uint c) {
        if (a > 3) {
            c = a;
            uint b = add( div( a, 2), 1 );
            while (b < c) {
                c = b;
                b = div( add( div( a, b ), b), 2 );
            }
        } else if (a != 0) {
            c = 1;
        }
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    function max(uint x, uint y) internal pure returns (uint z) {
        z = x > y ? x : y;
    }
}