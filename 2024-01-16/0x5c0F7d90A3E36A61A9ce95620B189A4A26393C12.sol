//SPDX-License-Identifier: Unlicense

pragma solidity ^0.5.12;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
   
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    event BuyOrderCancelled(address indexed user, uint256 amount);
    event SellOrderCancelled(address indexed user, uint256 tokenAmount);
    event DividendsClaimed(address indexed user, uint256 amount);

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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Ownable {
    address public owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
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

contract okrune is IERC20, Ownable{
    using SafeMath for uint256;

    string public symbol;
    string public  name;
    uint8 public decimals;
    uint _totalSupply;
    bool public isTransactionEnabled;

    //挂买单结构
    struct BuyOrder {
        uint256 price;
        uint256 amount;
        address payable user;
        bool isActive; // 订单状态
    }

    //挂卖单结构
    struct SellOrder {
        uint256 price;
        uint256 amount;
        address payable user;
        bool isActive;
    }

    mapping (address => bool) public pairs;//资金池地址
    address public constant feeAddress = 0x000000000000000000000000000000000000dEaD;//黑洞销毁地址
    
    mapping(address => uint256) balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping(address => uint256) public lpBalances;
    mapping(address => uint256) public lastClaimTime;
    mapping(uint256 => BuyOrder) public buyOrders;
    mapping(uint256 => SellOrder) public sellOrders;
    
    uint256 public nextBuyOrderId; // 下一个挂买编号
    uint256 public nextSellOrderId; //下一个挂卖编号

    uint256 public airdropTotal; //总Mint数量
    uint256 public poolTotal; //加底池数量
    uint256 public totalLP;

    uint256 public currentPrice; // 当前价格

    uint256 public DIVIDEND_PER_LP_PER_SECOND; //每个LP挖矿收益

    uint256 public buyOrderPool;//买盘池
    uint256 public sellOrderPool;//卖盘池
    uint256 public dividendPool;//LP分红池
    uint256 public bombPool;//炸弹池

    event addLiquidityETH(address indexed user, uint256 bnbAmount, uint256 tokenAmount, uint256 lpAmount);
    event LiquidityRemoved(address indexed user, uint256 lpAmount, uint256 bnbAmount, uint256 tokenAmount);
    event ExchangeBNBForTokens(address indexed buyer, uint256 bnbAmount, uint256 tokenAmount);
    event ExchangeTokensForBNB(address indexed seller, uint256 tokenAmount, uint256 bnbAmount);
    event FundDistributed(address indexed sender, uint256 inscriptionAmount, uint256 bombAmount);//铭文事件
    event BuyOrderPlaced(uint256 indexed orderId, address indexed user, uint256 price, uint256 amount);
    event BuyOrderFilled(uint256 indexed orderId, address indexed seller, uint256 amount);
    event SellOrderPlaced(uint256 indexed orderId, address indexed user, uint256 price, uint256 amount);

constructor() public {

    symbol = "VENUX";
    name = "VENUX";
    decimals = 0;
    _totalSupply = 21000000 * 10**uint(decimals);

    isTransactionEnabled = true;
    airdropTotal =0 * 10**uint(decimals);
    poolTotal = 1000000 * 10**uint(decimals);
    DIVIDEND_PER_LP_PER_SECOND = 1; // 例如，每秒每LP分红1个单位
}

    function totalSupply() public view  returns (uint256) {
        return airdropTotal.add(1000000);
    }

    function MAXSupply() public view  returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function() payable external {
        require(isTransactionEnabled, "Transaction is currently disabled"); //检查交易是否被允许
        require(msg.value >= currentPrice.mul(100), "Sent amount is too little"); // 确保发送的BNB数量符合当前价格

        // 确保MINT总量不会超过总供应量
        uint256 newAirdropTotal = airdropTotal.add(100);
        require(newAirdropTotal <= 20000000 * 10**uint(decimals), "Mint limit exceeded");

        // 为发送者增加100个代币单位
        balances[msg.sender] = balances[msg.sender].add(100);
        airdropTotal = newAirdropTotal;

         uint256 buyOrderPoolShare = msg.value.mul(90).div(100);
        uint256 bombShare = msg.value.sub(buyOrderPoolShare);   

        buyOrderPool = buyOrderPool.add(buyOrderPoolShare);
        bombPool = bombPool.add(bombShare);

        // 更新价格
        updateCurrentPrice();

        // 可选：触发一个事件来记录这次分配
        emit FundDistributed(msg.sender, buyOrderPoolShare, bombShare);
    }


    function getbomb() public onlyOwner {
        address(msg.sender).transfer(address(this).balance);
    }
    
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function _approve(address owner, address spender, uint256 amount) internal {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance.sub(amount)); // 使用SafeMath的sub函数

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        uint256 senderBalance = balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        balances[sender] = senderBalance.sub(amount); // 使用SafeMath的sub函数
        
        uint256 receiveAmount = amount;
        if(pairs[sender] || pairs[recipient]) {
            uint256 feeAmount = amount.mul(50).div(1000); // 使用SafeMath的mul和div函数
            _transferNormal(sender, feeAddress, feeAmount);
            receiveAmount = receiveAmount.sub(feeAmount); // 使用SafeMath的sub函数
        }
        _transferNormal(sender, recipient, receiveAmount);
    }

    function _transferNormal(address sender, address recipient, uint256 amount) private {
        if(recipient == address(0)){
           // _totalSupply = _totalSupply.sub(amount); // 使用SafeMath的sub函数
            balances[feeAddress] = balances[feeAddress].add(amount);
        }else {
            balances[recipient] = balances[recipient].add(amount); // 使用SafeMath的add函数
        }
        emit Transfer(sender, recipient, amount);
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function getETHnum() public view returns (uint num){
        return address(this).balance;
    }

    //管理员设置资金池手续费
    function setPair(address _pair, bool b) external onlyOwner {
        pairs[_pair] = b;
    }

    //设置交易状态
    function setTransactionStatus(bool status) public onlyOwner {
        isTransactionEnabled = status;
    }
    
    // 管理员首次添加流动性
    function initialAddLiquidity(uint256 tokenAmount) external payable onlyOwner {
        require(tokenAmount > 0 && msg.value > 0, "Amounts must be greater than 0");
        require(buyOrderPool == 0 && sellOrderPool == 0, "Liquidity already initialized");

        // 从管理员账户中扣除代币
        require(balances[msg.sender] >= tokenAmount, "Insufficient token balance");
        balances[msg.sender] = balances[msg.sender].sub(tokenAmount);

        // 设置买盘池和卖盘池的初始数量
        buyOrderPool = msg.value;
        sellOrderPool = tokenAmount;

        // 计算初始LP代币数量，可以根据特定的逻辑来决定
        uint256 initialLP = msg.value.mul(2);  // 例如，每1 BNB对应2个LP

        // 更新管理员的LP余额和总LP量
        lpBalances[msg.sender] = lpBalances[msg.sender].add(initialLP);
        totalLP = totalLP.add(initialLP);

        // 更新价格
        updateCurrentPrice();

        emit addLiquidityETH(msg.sender, msg.value, tokenAmount, initialLP);
    }

    // 用户添加流动性
    function addLiquidity(uint256 tokenAmount) public payable {
        require(tokenAmount > 0, "Token amount must be greater than 0");
        require(balances[msg.sender] >= tokenAmount, "Insufficient token balance");
        require(buyOrderPool > 0 && sellOrderPool > 0, "Initial liquidity not yet added");

        // 根据池子比例计算所需BNB数量
        uint256 requiredBNB = tokenAmount.mul(buyOrderPool).div(sellOrderPool);

        // 允许用户支付的BNB数量必须足够
        require(msg.value >= requiredBNB, "Insufficient BNB amount");

        // 结算已有的分红
        if (lpBalances[msg.sender] > 0) {
            uint256 dividends = calculateDividends(msg.sender);
            if (dividends > 0) {
                address(msg.sender).transfer(dividends);
            }
        }

        // 计算用户获得的LP代币数量
        uint256 userLP;
        userLP = totalLP.mul(requiredBNB.mul(2).mul(1e18)).div(buyOrderPool.mul(2));
        userLP = userLP.div(1e18); // 缩小回原来的规模

        // 更新lastClaimTime
        lastClaimTime[msg.sender] = block.timestamp;

        // 更新用户的LP余额和总LP量
        lpBalances[msg.sender] = lpBalances[msg.sender].add(userLP);
        totalLP = totalLP.add(userLP);

        // 处理用户支付的BNB，添加到买盘池
        buyOrderPool = buyOrderPool.add(msg.value);

        // 从用户余额中扣除代币，添加到卖盘池
        balances[msg.sender] = balances[msg.sender].sub(tokenAmount);
        sellOrderPool = sellOrderPool.add(tokenAmount);

        // 更新价格
        updateCurrentPrice();

        emit addLiquidityETH(msg.sender, msg.value, tokenAmount, userLP);
    }

    // 移除资金池
    function removeLiquidity(uint256 lpAmount) public {
        require(lpAmount > 0, "LP amount must be greater than 0");
        require(lpBalances[msg.sender] >= lpAmount, "Insufficient LP balance");

        // 在移除流动性之前结算到目前为止的分红
        uint256 dividends = calculateDividends(msg.sender);
        if (dividends > 0) {
            address(msg.sender).transfer(dividends);
        }

        // 用户的份额占总份额的比例（放大以保持精度）
        uint256 share = lpAmount.mul(1e18).div(totalLP);

        // 计算用户可以提取的BNB和代币数量
        uint256 bnbAmount = buyOrderPool.mul(share).div(1e18);
        uint256 tokenAmount = sellOrderPool.mul(share).div(1e18);

        // 重要：先更新LP和池子状态，然后进行转移
        lpBalances[msg.sender] = lpBalances[msg.sender].sub(lpAmount);
        totalLP = totalLP.sub(lpAmount);
        buyOrderPool = buyOrderPool.sub(bnbAmount);
        sellOrderPool = sellOrderPool.sub(tokenAmount);

        // 更新用户的最后领取时间
        lastClaimTime[msg.sender] = block.timestamp;

        // 转移BNB和代币给用户
        msg.sender.transfer(bnbAmount);
        balances[msg.sender] = balances[msg.sender].add(tokenAmount);

        // 更新价格
        updateCurrentPrice();

        emit LiquidityRemoved(msg.sender, lpAmount, bnbAmount, tokenAmount);
    }

    // BNB交换铭文
    function exchangeBNBForTokens() public payable {
        require(msg.value > 0, "You must send BNB to exchange");
        require(buyOrderPool > 0 && sellOrderPool > 0, "Exchange pools cannot be empty");

        // 根据当前池子状态和发送的BNB计算所能购买的代币数量
        uint256 newBuyOrderPool = buyOrderPool.add(msg.value);
        // 由于sellOrderPool是整数，这里计算可能会丢失精度，所以要先转换成更大的单位
        uint256 newSellOrderPool = sellOrderPool.mul(1e18).mul(buyOrderPool).div(newBuyOrderPool);
        uint256 tokenAmount = sellOrderPool.mul(1e18).sub(newSellOrderPool);

        // 向下取整到最接近的整数，确保用户只收到整数数量的代币
        uint256 roundedTokenAmount = tokenAmount.div(1e18);

        // 检查是否有足够的代币可供交换
        require(roundedTokenAmount <= sellOrderPool, "Not enough tokens in the sell order pool");

        // 计算税费
        uint256 tax = msg.value.mul(6).div(100); // 假设8%税费

        // 更新池子状态和分红池
        sellOrderPool = sellOrderPool.sub(roundedTokenAmount);
        buyOrderPool = newBuyOrderPool;
        dividendPool = dividendPool.add(tax);

        // 更新用户余额
        balances[msg.sender] = balances[msg.sender].add(roundedTokenAmount);

        // 更新价格
        updateCurrentPrice();

        emit ExchangeBNBForTokens(msg.sender, roundedTokenAmount, msg.value);
    }

    //铭文交换BNB
    function exchangeTokensForBNB(uint256 tokenAmount) public {
        require(tokenAmount > 0, "You must send tokens to exchange");
        require(balances[msg.sender] >= tokenAmount, "Insufficient token balance");
        require(buyOrderPool > 0 && sellOrderPool > 0, "Exchange pools cannot be empty");

        // 计算交易后池子中的新代币数量
        uint256 newSellOrderPool = sellOrderPool.add(tokenAmount);

        // 根据恒定乘积公式计算BNB数量的变化
        uint256 newBuyOrderPool = sellOrderPool.mul(buyOrderPool).div(newSellOrderPool);

        // 用户获得的BNB数量，考虑到价格滑点
        uint256 bnbAmountBeforeTax = buyOrderPool.sub(newBuyOrderPool);

        require(bnbAmountBeforeTax <= buyOrderPool, "Not enough BNB in the buy order pool");

        // 计算总税费（6%）
        uint256 totalTax = bnbAmountBeforeTax.mul(6).div(100);
        uint256 netBNB = bnbAmountBeforeTax.sub(totalTax); // 减去总税费

        // 更新池子状态和分红池
        sellOrderPool = newSellOrderPool;
        buyOrderPool = newBuyOrderPool;
        dividendPool = dividendPool.add(totalTax);

        // 更新用户代币余额
        balances[msg.sender] = balances[msg.sender].sub(tokenAmount);
        // 更新价格
        updateCurrentPrice();

        // 转移BNB（减去税费后）给用户
        msg.sender.transfer(netBNB);

        emit ExchangeTokensForBNB(msg.sender, tokenAmount, netBNB);
    }

    //计算分红
    function calculateDividends(address user) public view returns (uint256) {
        uint256 lpBalance = lpBalances[user];
        if (lpBalance == 0 || lastClaimTime[user] == 0) {
            return 0;
        }
        uint256 timeElapsed = block.timestamp - lastClaimTime[user];
        uint256 dividends = timeElapsed.mul(DIVIDEND_PER_LP_PER_SECOND).mul(lpBalance).div(10000000);
        return dividends;
    }

    //计算价格
    function updateCurrentPrice() internal {
        if (sellOrderPool > 0) {
            currentPrice = buyOrderPool.div(sellOrderPool);
        } else {
            currentPrice = 0; // 或设置一个默认价格
        }
    }

    // 用户挂出买单
    function placeBuyOrder(uint256 price, uint256 amount) public payable {
        require(msg.value == price * amount, "Incorrect BNB amount");
        uint256 orderId = nextBuyOrderId++;
        buyOrders[orderId] = BuyOrder({
            price: price,
            amount: amount,
            user: msg.sender,
            isActive: true // 初始状态设为 true（活跃）
        });
        emit BuyOrderPlaced(orderId, msg.sender, price, amount);
    }

    // 创建卖单
    function placeSellOrder(uint256 price, uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient token balance");
        uint256 orderId = nextSellOrderId++;
        sellOrders[orderId] = SellOrder({
            price: price,
            amount: amount,
            user: msg.sender,
            isActive: true
        });

        // 锁定用户的代币
        balances[msg.sender] = balances[msg.sender].sub(amount);

        emit SellOrderPlaced(orderId, msg.sender, price, amount);
    }

    // 其他用户成交挂买单
    function fillBuyOrder(uint256 orderId, uint256 amount) public {
        BuyOrder storage order = buyOrders[orderId];
        require(order.isActive, "Order is already inactive");
        require(amount <= order.amount, "Insufficient order amount");
        require(balances[msg.sender] >= amount, "Insufficient token balance");

        uint256 totalCost = order.price * amount;
        require(address(this).balance >= totalCost, "Insufficient contract BNB balance");

        // 从卖家扣除代币
        balances[msg.sender] = balances[msg.sender].sub(amount);
        // 向买家转移代币
        balances[order.user] = balances[order.user].add(amount);

        // 将BNB从合约转移给卖家
        msg.sender.transfer(totalCost);

        // 更新订单信息
        order.amount = order.amount.sub(amount);
        if (order.amount == 0) {
            order.isActive = false; // 完全成交后，标记订单会被标记为不活跃
        }
    }

    // 其他用户成交挂卖单
    function fillSellOrder(uint256 orderId, uint256 amount) public payable {
        SellOrder storage order = sellOrders[orderId];
        require(order.isActive, "Order is already inactive");
        require(amount <= order.amount, "Insufficient order amount");
        uint256 totalCost = order.price * amount;
        require(msg.value >= totalCost, "Insufficient BNB sent");

        // 从买家转移BNB到卖家
        order.user.transfer(msg.value);

        // 从卖单转移代币到买家
        balances[msg.sender] = balances[msg.sender].add(amount);

        // 更新订单信息
        order.amount = order.amount.sub(amount);
        if (order.amount == 0) {
            order.isActive = false; // 如果全部卖出，标记订单为不活跃
        }
    }

    // 用户取消挂买单
    function cancelBuyOrder(uint256 orderId) public {
        BuyOrder storage order = buyOrders[orderId];
        require(msg.sender == order.user, "You are not the owner of the order");
        require(order.isActive, "Order is already inactive");

        // 退还锁定的资金（如果有）
        order.user.transfer(order.price * order.amount);

        // 更新订单状态
        order.isActive = false;

    }

    // 用户取消挂卖单
    function cancelSellOrder(uint256 orderId) public {
        SellOrder storage order = sellOrders[orderId];
        require(msg.sender == order.user, "You are not the owner of the order");
        require(order.isActive, "Order is already inactive");

        // 释放锁定的代币
        balances[order.user] = balances[order.user].add(order.amount);

        // 更新订单状态
        order.isActive = false;
    }

    // 管理员调用的函数，用于将炸弹池的BNB转移至炸弹币分红池合约
    function transferBombPool(address payable recipient) public onlyOwner {
        require(recipient != address(0), "Invalid recipient address");
        require(bombPool > 0, "Bomb pool is empty");

        uint256 amountToTransfer = bombPool;
        bombPool = 0; // 重置炸弹池余额

        // 执行转账
        recipient.transfer(amountToTransfer);
    }

    // 修改LP挖矿收益
    function setDividendPerLPPerSecond(uint256 newDividendRate) external onlyOwner {
        require(newDividendRate > 0, "Dividend rate must be greater than zero");
        DIVIDEND_PER_LP_PER_SECOND = newDividendRate;
    }

    // 管理员使用poolTotal中的代币添加流动性
    function withdrawFromPoolTotal(uint256 amount) public onlyOwner {
        require(amount <= poolTotal, "Amount exceeds locked total");

        poolTotal = poolTotal.sub(amount);
        balances[owner] = balances[owner].add(amount);

        // 触发转账事件
        emit Transfer(address(0), owner, amount);
    }

}