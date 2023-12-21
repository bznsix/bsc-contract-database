/*
SniperDAO (sDAO) - t.me/SniperDAO_official
*/

// SPDX-License-Identifier: none
pragma solidity ^0.8.19;

library SafeTransferLib {
    function safeTransferETH(address to, uint256 amount) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }

    function safeTransfer(address token, address to, uint256 amount) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            success := and(
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "TRANSFER_FAILED");
    }

    function balanceOf(address token, address wallet) internal view returns (uint256 result) {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            let freeMemoryPointer := mload(0x40)

            // keccak256('balanceOf(address)') bitmasked to 4 bytes
            mstore(freeMemoryPointer, 0x70a0823100000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(wallet, 0xffffffffffffffffffffffffffffffffffffffff))

            success := staticcall(gas(), token, freeMemoryPointer, 36, freeMemoryPointer, 32)
            if eq(success, 1) {
                result := mload(freeMemoryPointer)
            }
        }

        require(success, "balanceOf_failed");
    }
}

abstract contract Auth {
    event OwnershipTransferred(address owner);
    mapping (address => bool) internal authorizations;

    address public owner;
    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "!OWNER");
        _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED");
        _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }
}

interface IDexFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface V2Pair {
    function token0() external view returns (address);
    function token1() external view returns (address);
}

contract DEPLOY_WITH_LIQUIDITY {
    constructor() payable {
        require(msg.value >= 1000, "minimum is 1000 wei");

        address router;
        if (block.chainid == 56) {
            router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;  // PancakeSwap
        } else if (block.chainid == 1) {
            router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;  // UniswapV2
        } else revert();

        // bytes memory bytecode = type(TEMPLATE_NAME).creationCode;
        sDAO _contract = new sDAO();
        uint256 liquidityAmount = SafeTransferLib.balanceOf(address(_contract), address(this));

        (bool success,) = router.call{gas : gasleft(), value: msg.value}(
            // addLiquidityETH(address,uint256,uint256,uint256,address,uint256)
            abi.encodeWithSelector(
                0xf305d719,
                address(_contract),
                liquidityAmount,
                0,
                0,
                tx.origin,
                block.timestamp
            )
        );

        require(success, "ADD_LIQUIDITY_ETH_FAILED");
    }
}

contract sDAO is Auth {
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    address wrapped;
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;

    uint8 constant public decimals = 4;
    string public name = "SniperDAO";
    string public symbol = "sDAO";

    uint256 public totalSupply = 10_000_000 * (10 ** decimals);
    uint256 public max_tx = totalSupply / 1000 * 10;     // 1% of total supply initially
    uint256 public max_wallet = totalSupply / 1000 * 20; // 2% of total supply initially
    
    mapping (address => mapping(address => uint256)) public allowance;
    mapping (address => uint256) public balanceOf;
    mapping (address => bool) public isPair;
    mapping (address => bool) public isFeeExempt;
    mapping (address => bool) public isLimitExempt;

    uint256 constant public feeDenominator = 1000;  // 100%
    uint256 public projectFee = 60;                 // 6% fee
    address public feeReceiver;
    uint256 clown = 1001;

    bool private antiBot = true;
	uint256 private antiFeeBlocks = 1;
    mapping (address => uint) private blockTime;

    uint256 launchedAt = 0;
    address public router;
    address public factory;
    address public mainPair;
    address[] public pairs;

    modifier swapping() { inContractSwap = true; _; inContractSwap = false; }
    uint256 public smallSwapThreshold = totalSupply / 1000; // 0,1% of total supply
    uint256 public largeSwapThreshold = totalSupply / 500;  // 0,2% of total supply
    uint256 public swapThreshold = smallSwapThreshold;
    bool public swapEnabled = true;
    bool inContractSwap;

    constructor() Auth(tx.origin) {
        if (block.chainid == 56) {
            // BSC Mainnet
            wrapped = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; // WBNB
            factory = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73; // PancakeSwap
            router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;  // PancakeSwap
        } else if (block.chainid == 1) {
            // Ethereum Mainnet
            wrapped = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // WETH
            factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f; // UniswapV2
            router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;  // UniswapV2
        } else revert();

        address deployer = tx.origin;
        address liquidityDeployer = msg.sender;
        allowance[address(this)][address(router)] = type(uint256).max;
        allowance[liquidityDeployer][address(router)] = type(uint256).max;

        mainPair = IDexFactory(factory).createPair(wrapped, address(this));
        isPair[mainPair] = true;
        pairs.push(mainPair);
        
        feeReceiver = deployer;
        isFeeExempt[router] = true;
        isFeeExempt[deployer] = true;
        isFeeExempt[address(this)] = true;
        isLimitExempt[router] = true;
        isLimitExempt[deployer] = true;
        isLimitExempt[address(this)] = true;
        isLimitExempt[DEAD] = true;
        isLimitExempt[ZERO] = true;

        if (liquidityDeployer != deployer) {
            isFeeExempt[liquidityDeployer] = true;
            isLimitExempt[liquidityDeployer] = true;
            authorizations[liquidityDeployer] = true;

            uint256 liquidityAmount = totalSupply / 100 * 95; // 95% of totalSupply in liquidity
            uint256 deployerTokens = totalSupply - liquidityAmount;

            unchecked {
                balanceOf[deployer] += deployerTokens;
                balanceOf[liquidityDeployer] += liquidityAmount;
                emit Transfer(address(0), deployer, deployerTokens);
                emit Transfer(address(0), liquidityDeployer, liquidityAmount);
            }
        } else {
            unchecked {
                balanceOf[deployer] += totalSupply;
                emit Transfer(address(0), deployer, totalSupply);
            }
        }
    }

    receive() external payable {}

    function getCirculatingSupply() public view returns (uint256) {
        return totalSupply - balanceOf[DEAD] - balanceOf[ZERO];
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() internal {
        launchedAt = block.number;
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////// TRANSFER //////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address recipient, uint256 amount) public virtual returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool) {
        uint256 allowed = allowance[sender][msg.sender];
        if (allowed != type(uint256).max) allowance[sender][msg.sender] = allowed - amount;

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (!launched() && isPair[recipient]) {
            require(isAuthorized(sender), "!OWNER");
            launch();
        }
        if (inContractSwap) return _basicTransfer(sender, recipient, amount);

        checkTxLimit(sender, recipient, amount);
        if (shouldSwapBack(recipient)) swapBack(recipient);

        balanceOf[sender] -= amount;
        uint256 amountReceived = amount;
        
        if (isPair[sender] || isPair[recipient]) {
            amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, amount) : amount;
        }

        unchecked {
            balanceOf[recipient] += amountReceived;
            emit Transfer(sender, recipient, amountReceived);
        }
        
        return true;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        balanceOf[sender] -= amount;

        unchecked {
            balanceOf[recipient] += amount;
            emit Transfer(msg.sender, recipient, amount);
        }

        return true;
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////// LIMITS //////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function checkTxLimit(address sender, address recipient, uint256 amount) internal view {
        // verify sender max_tx
        require(amount <= max_tx || isPair[sender] && isLimitExempt[recipient] || isLimitExempt[sender], "TRANSACTION_LIMIT_EXCEEDED");

        // verify recipient max_wallet
        if (recipient != owner && !isLimitExempt[recipient] && !isPair[recipient]) {
            uint256 newBalance = balanceOf[recipient] + amount;
            require(newBalance <= max_wallet, "WALLET_LIMIT_EXCEEDED");
        }
    }

    function changeMaxTx(uint256 percent, uint256 denominator) external authorized { 
        max_tx = totalSupply * percent / denominator;
        require(max_tx >= totalSupply * 10 / 1000, "Max tx must be greater than 1%");
    }
    
    function changeMaxWallet(uint256 percent, uint256 denominator) external authorized {
        max_wallet = totalSupply * percent / denominator;
        require(max_wallet >= totalSupply * 10 / 1000, "Max wallet must be greater than 1%");
    }

    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function setIsLimitExempt(address holder, bool exempt) external authorized {
        isLimitExempt[holder] = exempt;
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////// FEE ///////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        return !isFeeExempt[sender] && !isFeeExempt[recipient] && projectFee > 0;
    }

    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = 0;

        if (antiBot && isPair[sender] && !isLimitExempt[tx.origin] && amount >= totalSupply / 10000 * 11) {
            if (blockTime[tx.origin] == block.timestamp || block.number - launchedAt <= antiFeeBlocks) {
                // high fee to clowns
                feeAmount = amount * feeDenominator / clown;
            } else {
                // normal fee
                feeAmount = amount / feeDenominator * projectFee;
            }
            blockTime[tx.origin] = block.timestamp;
        } else {
            // normal fee
            feeAmount = amount / feeDenominator * projectFee;
        }
        
        unchecked {
            balanceOf[address(this)] += feeAmount;
            emit Transfer(sender, address(this), feeAmount);
        }

        return amount - feeAmount;
    }

    function adjustFees(uint256 _projectFee) external authorized {
        require(_projectFee <= feeDenominator / 10); // projectFee must be less or equal 10%
        projectFee = _projectFee;
    }

    function setFeeReceivers(address _feeReceiver) external authorized {
        feeReceiver = _feeReceiver;
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////// CONTRCT SWAP ////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function shouldSwapBack(address recipient) internal view returns (bool) {
        return (
            swapEnabled &&
            projectFee > 0 &&
            isPair[recipient] &&
            balanceOf[address(this)] >= swapThreshold &&

            // This is to avoid having a large impact if there is little token in liquidity
            SafeTransferLib.balanceOf(address(this), recipient) > swapThreshold * 10
        );
    }

    function swapBack(address pairSwap) internal swapping {
        address[] memory path;
        uint256 amountToSwap = swapThreshold;

        if (pairSwap == mainPair) {
            // THIS_TOKEN -> WRAPPED
            path = new address[](2);
            path[0] = address(this);
            path[1] = wrapped;
        } else {
            V2Pair pair = V2Pair(pairSwap);
            address token0 = pair.token0();
            address token1 = pair.token1();
            
            // THIS_TOKEN -> UNKNOWN_TOKEN -> WRAPPED
            path = new address[](3);
            path[0] = address(this);
            // path[1] = UNKNOWN_TOKEN;
            path[2] = wrapped;

            if (token0 != address(this)) {
                path[1] = token0;
            } else {
                path[1] = token1;
            }
        }

        (bool success,) = router.call{gas : gasleft()}(
            //swapExactTokensForETHSupportingFeeOnTransferTokens(uint256,uint256,address[],address,uint256)
            abi.encodeWithSelector(
                0x791ac947,
                amountToSwap,
                0,
                path,
                address(this),
                block.timestamp
            )
        );
        
        if (pairSwap == mainPair) require(success, "SWAPBACK_FAILED");
        SafeTransferLib.safeTransferETH(feeReceiver, address(this).balance);
        swapThreshold = swapThreshold == smallSwapThreshold ? largeSwapThreshold : smallSwapThreshold;
    }

    function setSwapBackSettings(bool _enabled, uint256 _smallAmount, uint256 _largeAmount) external authorized {
        require(_smallAmount <= totalSupply * 25 / 10000, "Small swap threshold must be lower"); // smallSwapThreshold  <= 0,25% of total supply
        require(_largeAmount <= totalSupply * 5 / 1000, "Large swap threshold must be lower");   // largeSwapThreshold  <= 0,5% of total supply

        swapEnabled = _enabled;
        smallSwapThreshold = _smallAmount;
        largeSwapThreshold = _largeAmount;
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////// OTHERS /////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function updateTokenDetails(string calldata newName, string calldata newSymbol) external authorized {
        name = newName;
        symbol = newSymbol;
    }

	function rescue() external authorized {
        SafeTransferLib.safeTransferETH(feeReceiver, address(this).balance);
    }

    function rescueToken(address _token, uint256 amount) external authorized {
        require(_token != address(this), "STOP");
        SafeTransferLib.safeTransfer(_token, feeReceiver, amount);
    }

    function burnContractTokens(uint256 amount) external authorized {
        SafeTransferLib.safeTransfer(address(this), DEAD, amount);
    }

    function createNewPair(address token) external authorized {
        address new_pair = IDexFactory(factory).createPair(token, address(this));
        isPair[new_pair] = true;
        pairs.push(new_pair);
    }

    function setNewPair(address pair) external authorized {
        isPair[pair] = true;
        pairs.push(pair);
    }

    function showPairList() public view returns(address[] memory){
        return pairs;
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////// ANTI-BOT /////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function disableAntiBot() external authorized {
        antiBot = false;
    }
}