// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function burn(uint256 amount) external;
    function mint(address recipient, uint256 amount) external;
    function lockCoins(address wallet, bool enabled, uint256 amount, uint256 expired, bool rewriteAmount) external;
}

interface IOracle {
    function decimals() external view returns (uint8);
    function latestRoundData() external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

contract STARDEXCore {
    enum QueueStatus {
        Close,
        Open
    }

    enum BuyType {
        System,
        Referral,
        Leader,
        Queue,
        PreSale
    }

    enum AmountType {
        Bnb,
        Usd,
        Coins
    }

    struct Wallet {
        uint id;
        address referral;
        uint bought; //USD
        uint sold; //USD
        uint limit; //USD
    }

    struct Order {
        uint id;
        address wallet;
        uint amount; //BNB
    }

    struct Queue {
        uint id;
        address wallet;
        QueueStatus status;
        uint amountCoins;
        uint amountSoldCoins;
        uint amountBnb;
        uint amountUsd;
    }

    struct Transaction {
        uint id;
        BuyType buyType;
        address buyer;
        address seller;
        uint orderId;
        uint queueId;
        uint price;
        uint amountCoins;
        uint amountBnb;
        uint amountUsd;
    }

    struct Leader {
        uint id;
        address wallet;
        bool active;
    }

    event UpdateCoinPrice(uint price, uint coins, uint sold, uint time);
    event AddUpdateQueue(uint indexed id, address indexed wallet, QueueStatus status, uint amount, uint time);
    event CloseQueue(uint indexed id,  address indexed wallet, uint activeQueueId, uint time);
    event AddOrder(uint indexed id, address indexed wallet, uint amount, uint time);
    event AddLeader(uint indexed id, address indexed wallet, uint time);
    event CloseLeader(uint indexed id, address indexed wallet, uint time);
    event AddWallet(uint indexed id, address indexed wallet, address indexed referral, uint time);
    event UpdateWallet(uint indexed id, address indexed wallet, uint bought, uint limit, uint time);
    event AddTransaction(uint indexed id, address indexed buyer, address indexed seller, BuyType buyType, uint orderId, uint queueId, uint priceAmount, uint coinAmount, uint bnbAmount, uint usdAmount, uint time);
    event TransferReferralReward(address indexed wallet, uint indexed orderId, address indexed referral, uint8 line, uint amount, uint time);
    event TransferFee(uint indexed orderId, uint feeAmount, uint liquidityAmount, uint time);
    event PreSale(address indexed wallet, uint orderId, uint transactionId, uint bnbAmount, uint coinsAmount, uint usdAmount, uint lockDays, uint time);

    mapping (address => Wallet) public wallets;
    mapping (uint => address) public walletIdAddress;
    mapping (address => uint[]) public walletQueueIds;
    mapping (address => uint[]) public walletOrderIds;
    mapping (uint => uint[]) public queueTransactionIds;
    mapping (uint => uint[]) public orderTransactionIds;

    mapping (uint8 => uint) public settingValues;

    Queue[] public queues;
    Order[] public orders;
    Transaction[] public transactions;
    Leader[] public leaders;
    
    address public ownerAddress;
    address public dappAddress = address(0xD6d6535073bdCFb1c351df4d1dC70da3Cb2F9f6A);
    address public minterAddress = address(0x793CA04d7153e986eDB9937c54e1e811Dd684980);
    address public feeAddress = address(0xA9f0cFCC2818A20f6AE6e938A0f73B8A56D1486D);
    address public liquidityAddress = address(0x934360d1557Bdd4a87b795428C6f2Aa0159d1065);
    IERC20 public coinAddress = IERC20(address(0x5872b7B0305D745AdE10b13B5Ae5Fae99c10Dcae));
    IOracle public oracleAddress = IOracle(address(0xC5A35FC58EFDC4B88DDCA51AcACd2E8F593504bE));

    uint public coinPrice;// = 10 * 1e18; //10 USD
    uint public coinPricePart;// = 1e16; //0.01 USD
    uint public coinReduction;// = 1e10; //0.00000001 Coin
    uint public usdReduction;// = 1e16; //0.01 USD
    uint public minBuyAmount;// = 25 * 1e18; //$25
    uint public minSellAmount;// = 1e15; //0.001 Coin
    uint public feePercent;// = 10; //10%
    uint public liquidityPercent;// = 10; //10%
    uint public chanceReferral;// = 50; //50%
    uint public chanceLeader;// = 25; //25%
    uint public boardPlacesLeader;// = 5; //5 last wallets
    uint public minBuyAmountLeader;// = 250 * 1e18; //$250
    uint public walletLimitFactor;// = 3; //300%
    uint public nextWalletId;// = 1;
    uint public nextQueueId;// = 1;
    uint public nextOrderId;// = 1;
    uint public nextTransactionId;// = 1;
    uint public nextPriceId;// = 1;
    uint public nextLeaderId;// = 1;
    uint public activeQueueId;// = 1;
    uint public oraclePrice;// = 0;
    uint public coinPriceUpper;// = 0;
    uint public coinPriceSold; // = 0;
    uint public activePreSaleAt; // = 0;
    uint public limitPreSale; // = 100 * 1e18; //100 USD
    uint public lockDaysPreSale;// = 45; //45 days
    uint public walletPreSaleLimitFactor; // = 1; //100%
    uint8 public oracleDecimals;// = 0;
    uint8 public activeReferralLines;// = 10; //10 lines

    uint private saltRandom;// = 1;

    modifier onlyDapp() { 
        require(msg.sender == dappAddress || msg.sender == ownerAddress, "33"); 
        _; 
    }

    modifier onlyOwner() { 
        require(msg.sender == ownerAddress, "33"); 
        _; 
    }

    constructor() {
        ownerAddress = msg.sender;

        settingValues[1] = 120; //12%
        settingValues[2] = 60; //6%
        settingValues[3] = 40; //4%
        settingValues[4] = 30; //3%
        settingValues[5] = 20; //2%
        settingValues[6] = 10; //1%
        settingValues[7] = 5; //0.5%
        settingValues[8] = 5; //0.5%
        settingValues[9] = 5; //0.5%
        settingValues[10] = 5; //0.5%
        settingValues[11] = 0; //0%
        settingValues[12] = 1000; //0.01%
        settingValues[13] = 500; //0.005%
        settingValues[14] = 100; //0.001%
        settingValues[15] = 50; //0.0005%
        settingValues[16] = 10; //0.0001%

        coinPrice = 10 * 1e18; //10 USD
        coinPricePart = 1e16; //0.01 USD
        coinReduction = 1e10; //0.00000001 Coin
        usdReduction = 1e16; //0.01 USD
        minBuyAmount = 25 * 1e18; //$25
        minSellAmount = 1e15; //0.001 Coin
        feePercent = 10; //10%
        liquidityPercent = 10; //10%
        chanceReferral = 50; //50%
        chanceLeader = 25; //25%
        boardPlacesLeader = 5; //5 last wallets
        minBuyAmountLeader = 250 * 1e18; //$250
        walletLimitFactor = 3; //300%
        nextWalletId = 1;
        nextQueueId = 1;
        nextOrderId = 1;
        nextTransactionId = 1;
        nextPriceId = 1;
        nextLeaderId = 1;
        activeQueueId = 1;
        oraclePrice = 0;
        coinPriceUpper = 0;
        coinPriceSold = 0;
        activePreSaleAt = 1705276800; //01/15/2024 UTC
        limitPreSale = 100 * 1e18; //100 USD
        lockDaysPreSale = 45; //45 days
        walletPreSaleLimitFactor = 1; //100%
        oracleDecimals = 0;
        activeReferralLines = 10; //10 line

        //admin
        Wallet memory wallet = Wallet(nextWalletId, address(0), 0, 0, 0);
        wallets[ownerAddress] = wallet;
        walletIdAddress[nextWalletId] = ownerAddress;

        emit AddWallet(wallet.id, ownerAddress, wallet.referral, block.timestamp);
        nextWalletId++;

        //minter
        Wallet memory minterWallet = Wallet(nextWalletId, ownerAddress, 0, 0, 0);
        wallets[minterAddress] = minterWallet;
        walletIdAddress[nextWalletId] = minterAddress;

        emit AddWallet(minterWallet.id, minterAddress, minterWallet.referral, block.timestamp);
        nextWalletId++;

        emit UpdateCoinPrice(coinPrice, 0, 0, block.timestamp);
    }

    function _isWallet(address wallet) private view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(wallet)
        }
        return (size == 0);
    }

    function _safeTransfer(address wallet, uint amount) internal returns (bool) {
        if (wallet == address(0) || amount == 0) {
            return false;
        }

        if (_isWallet(wallet)) {
            payable(wallet).transfer(amount);
            return true;
        } else {
            (bool sent, ) = address(wallet).call{value:amount}("");
            return sent;
        }
    }

    fallback() external payable {
        buy(address(0));
    }

    receive() external payable {
       buy(address(0));
    }

    function sell(address wallet, uint amount) public  {
        require(_isWallet(wallet), "1");//"Only wallet");
        require(wallets[wallet].id > 0, "2");//"Wallet not found");
        require(amount >= minSellAmount, "3");//"Min sell amount is less than available");
        require(msg.sender == address(coinAddress), "4");//"Sender only coin address");
        require(coinAddress.balanceOf(wallet) >= amount, "5");//"Tokens not enough");
        require(coinAddress.transferFrom(wallet, address(this), amount), "6");//"Transfer tokens error");
        require(activePreSaleAt < block.timestamp, "19");//"PreSale active");
        
        uint walletLimitUsd = wallets[wallet].limit - wallets[wallet].sold;
        require(walletLimitUsd >= usdReduction, "7");//"Wallet sales limit reached");

        uint amountCoins = amount;
        (, uint amountUsd) = calcAmount(amountCoins, AmountType.Coins);

        uint queueId = (walletQueueIds[wallet].length > 0) ? walletQueueIds[wallet][walletQueueIds[wallet].length - 1] : 0;
        if (walletQueueIds[wallet].length == 0 || queueId < activeQueueId || queues[queueId - 1].status == QueueStatus.Close || queues[queueId - 1].amountCoins <= queues[queueId - 1].amountSoldCoins + coinReduction) {
            if (walletLimitUsd < amountUsd) {
                (,amountCoins) = calcAmount(walletLimitUsd, AmountType.Usd);
                uint amountCoinsReturned = amount - amountCoins;
                if (amountCoinsReturned > 0 && amountCoinsReturned < amount) {
                    coinAddress.transfer(wallet, amountCoinsReturned);
                }
            }

            Queue memory queue = Queue(nextQueueId, wallet, QueueStatus.Open, amountCoins, 0, 0, 0);
            queues.push(queue);
            walletQueueIds[wallet].push(nextQueueId);
            emit AddUpdateQueue(queue.id, queue.wallet, queue.status, queue.amountCoins, block.timestamp);
            nextQueueId++;
        } else {
            Queue storage queue = queues[queueId - 1];
            require(queue.wallet == wallet, "8");//"Wallet queue is different");
            uint amountCoinsLeft = queue.amountCoins - queue.amountSoldCoins;
            (, uint amountUsdLeft) = calcAmount(amountCoinsLeft, AmountType.Coins);
                
            require(walletLimitUsd > amountUsdLeft, "9");//"Wallet sales limit reached");
            if (walletLimitUsd - amountUsdLeft < amountUsd) {
                (,amountCoins) = calcAmount(walletLimitUsd - amountUsdLeft, AmountType.Usd);
                uint amountCoinsReturned = amount - amountCoins;
                if (amountCoinsReturned > 0 && amountCoinsReturned < amount) {
                    coinAddress.transfer(wallet, amountCoinsReturned);
                }
            }

            queue.amountCoins += amountCoins;
            emit AddUpdateQueue(queue.id, queue.wallet, queue.status, queue.amountCoins, block.timestamp);
        }
    }

    function cancel(uint id) public {
        require(_isWallet(msg.sender), "10");//"Only wallet");
        require(wallets[msg.sender].id > 0, "11");//"Wallet not found");

        require(queues.length >= id, "12");//"Id out of range");
        Queue storage queue = queues[id - 1];
        require(queue.wallet == msg.sender, "13");//"Queue wallet owner is different");
        require(queue.status == QueueStatus.Open, "14");//"Queue status is wrong");
            
        queue.status = QueueStatus.Close;
        _queueReturnCoins(id);

        emit CloseQueue(queue.id, queue.wallet, activeQueueId, block.timestamp); 
    }

    function _queueReturnCoins(uint queueId) private {
        if (queues[queueId - 1].amountCoins > queues[queueId - 1].amountSoldCoins + coinReduction) {
            coinAddress.transfer(queues[queueId - 1].wallet, queues[queueId - 1].amountCoins - queues[queueId - 1].amountSoldCoins);
        }
    }

    function registration(address wallet, address referral) public {
        require(_isWallet(wallet), "16");//"Only wallet");

        if (wallet != msg.sender) {
            require(msg.sender == dappAddress || msg.sender == ownerAddress, "only owner or dapp"); 
        }

        if (wallets[wallet].id == 0) {
            if (wallets[referral].id == 0) {
                referral = address(ownerAddress);
            }

            Wallet memory walletOwner = Wallet(nextWalletId, referral, 0, 0, 0);
            wallets[wallet] = walletOwner;
            walletIdAddress[nextWalletId] = wallet;

            emit AddWallet(walletOwner.id, wallet, walletOwner.referral, block.timestamp);
            nextWalletId++;
        } else {
            revert();
        }
    }     

    function preSale() public payable {
        require(msg.value >= 1e16, "18");//"BNB required");
        require(_isWallet(msg.sender), "16");//"Only wallet");
        require(activePreSaleAt >= block.timestamp, "19");//"PreSale closed");
        require(wallets[msg.sender].id > 0, "20");//"Registration first");
        require(wallets[msg.sender].bought < limitPreSale, "21");//"PreSale limit");

        (, int answer,,,) = oracleAddress.latestRoundData();
        oracleDecimals = oracleAddress.decimals();
        oraclePrice = uint(answer);

        uint amountCoins;
        uint amountBnb = msg.value;
        uint amountUsd = ((msg.value * uint256(oraclePrice)) / 10**oracleDecimals);
        (, amountCoins) = calcAmount(amountUsd, AmountType.Usd);

        if (amountUsd + wallets[msg.sender].bought > limitPreSale + usdReduction) {
            amountUsd = limitPreSale - wallets[msg.sender].bought;
            (amountBnb, amountCoins) = calcAmount(amountUsd, AmountType.Usd);
        }

        Order memory order = Order(nextOrderId, msg.sender, amountBnb);
        orders.push(order);
        walletOrderIds[msg.sender].push(nextOrderId);
        emit AddOrder(order.id, order.wallet, order.amount, block.timestamp);
        nextOrderId++;

        _transferReferrals(order.id);
        uint amountFee = (amountBnb / 100) * feePercent;
        uint amountLiquidity = (amountBnb / 100) * liquidityPercent;

        Transaction memory transaction = Transaction(nextTransactionId, BuyType.PreSale, msg.sender, minterAddress, order.id, 0, coinPrice, amountCoins, amountBnb, amountUsd);
        transactions.push(transaction);
        orderTransactionIds[order.id].push(transaction.id);
        emit AddTransaction(nextTransactionId, transaction.buyer, transaction.seller, transaction.buyType, transaction.orderId, transaction.queueId, transaction.price, transaction.amountCoins, transaction.amountBnb, transaction.amountUsd, block.timestamp);
        nextTransactionId++;

        coinAddress.mint(msg.sender, amountCoins);
        if (lockDaysPreSale > 0) {
            coinAddress.lockCoins(msg.sender, true, amountCoins, block.timestamp + (lockDaysPreSale * 1 days), false);
        }

        emit PreSale(msg.sender, order.id, transaction.id, amountBnb, amountCoins, amountUsd, lockDaysPreSale, block.timestamp);
        
        wallets[msg.sender].bought += amountUsd; 
        wallets[msg.sender].limit = (walletPreSaleLimitFactor > 0) ? wallets[msg.sender].bought * walletPreSaleLimitFactor : 0;
        emit UpdateWallet(wallets[msg.sender].id, msg.sender, wallets[msg.sender].bought, wallets[msg.sender].limit, block.timestamp);

        _safeTransfer(feeAddress, (address(this).balance < amountFee) ? address(this).balance : amountFee);
        _safeTransfer(liquidityAddress, (address(this).balance < amountLiquidity) ? address(this).balance : amountLiquidity);
        emit TransferFee(order.id, amountFee, amountLiquidity, block.timestamp);

        if (amountBnb > amountFee + amountLiquidity) {
            _safeTransfer(minterAddress, (address(this).balance < amountBnb - (amountFee + amountLiquidity)) ? address(this).balance : amountBnb - (amountFee + amountLiquidity));
        }

        if (amountBnb < msg.value) {
            _safeTransfer(msg.sender, (address(this).balance < msg.value - amountBnb) ? address(this).balance : msg.value - amountBnb);
        }

        emit UpdateCoinPrice(coinPrice, amountCoins, 0, block.timestamp);
    }

    function buy(address referral) public payable {
        require(msg.value > 0, "15");//"BNB required");
        require(_isWallet(msg.sender), "16");//"Only wallet");
        require(activePreSaleAt < block.timestamp, "19");//"PreSale active");

        (, int answer,,,) = oracleAddress.latestRoundData();
        oracleDecimals = oracleAddress.decimals();
        oraclePrice = uint(answer);

        uint amountUsd = ((msg.value * uint256(oraclePrice)) / 10**oracleDecimals);
        require(amountUsd >= minBuyAmount, "17");//"Min buy amount is less than available");
        
        if (wallets[msg.sender].id == 0) {
            if (wallets[referral].id == 0) {
                referral = address(ownerAddress);
            }

            Wallet memory wallet = Wallet(nextWalletId, referral, 0, 0, 0);
            wallets[msg.sender] = wallet;
            walletIdAddress[nextWalletId] = msg.sender;

            emit AddWallet(wallet.id, msg.sender, wallet.referral, block.timestamp);
            nextWalletId++;
        }

        Order memory order = Order(nextOrderId, msg.sender, msg.value);
        orders.push(order);
        walletOrderIds[msg.sender].push(nextOrderId);
        emit AddOrder(order.id, order.wallet, order.amount, block.timestamp);
        nextOrderId++;

        uint amountLeft = msg.value;
        uint amountFee = (msg.value / 100) * feePercent;
        uint amountLiquidity = (msg.value / 100) * liquidityPercent;
        amountLeft -= amountFee + amountLiquidity;
        
        uint referralsAmount = _transferReferrals(order.id);
        amountLeft -= referralsAmount;

        if (amountLeft > 0 && chanceReferral > 0 && _random(1, 100, amountLeft) <= chanceReferral) {
            saltRandom++;
            amountLeft -= _buyCoins(amountLeft, BuyType.Referral, order.id);
        } else if (amountLeft > 0 && chanceLeader > 0 && _random(1, 100, amountLeft) <= chanceLeader) {
            saltRandom++;
            amountLeft -= _buyCoins(amountLeft, BuyType.Leader, order.id);
        }

        if (amountLeft > 0) {
            amountLeft -= _buyCoins(amountLeft, BuyType.Queue, order.id);
        }

        _safeTransfer(feeAddress, (address(this).balance < amountFee) ? address(this).balance : amountFee);
        _safeTransfer(liquidityAddress, (address(this).balance < amountLiquidity) ? address(this).balance : amountLiquidity);
        emit TransferFee(order.id, amountFee, amountLiquidity, block.timestamp);
        
        _buyCoins(amountLeft + referralsAmount + amountFee + amountLiquidity, BuyType.System, order.id);
        if (amountLeft > 0) {
            _safeTransfer(minterAddress, (address(this).balance < amountLeft) ? address(this).balance : amountLeft);
        }
        
        wallets[msg.sender].bought += amountUsd; 
        wallets[msg.sender].limit = wallets[msg.sender].bought * walletLimitFactor; //300%
        emit UpdateWallet(wallets[msg.sender].id, msg.sender, wallets[msg.sender].bought, wallets[msg.sender].limit, block.timestamp);
        
        if (chanceLeader > 0 && minBuyAmountLeader <= amountUsd) {
            bool found = false;
            for (uint i = 1; i <= boardPlacesLeader; i++) {
                if (leaders.length < i) {
                    break;
                }

                if (leaders[leaders.length - i].wallet == msg.sender && leaders[leaders.length - i].active) {
                    found = true;
                    break;
                }
            }

            if (!found && walletQueueIds[msg.sender].length > 0) {
                uint leaderQueueId = walletQueueIds[msg.sender][walletQueueIds[msg.sender].length - 1];

                if (activeQueueId <= leaderQueueId && queues[leaderQueueId - 1].status != QueueStatus.Close && queues[leaderQueueId - 1].amountCoins > queues[leaderQueueId - 1].amountSoldCoins + coinReduction) {
                    Leader memory leader = Leader(nextLeaderId, msg.sender, true);
                    leaders.push(leader);
                    emit AddLeader(nextLeaderId, msg.sender, block.timestamp);
                    nextLeaderId++;
                }
            }
        }

        _updateCoinPrice(msg.value);
    }

    function _transferReferrals(uint orderId) private returns (uint) {
        address referral = wallets[msg.sender].referral;
        uint amountSend = 0;

        for (uint8 line = 1; line <= activeReferralLines; line++) {
            if (referral == address(0)) {
                break;
            }
            
            if (referral != ownerAddress && wallets[referral].sold >= wallets[referral].limit) {
                continue;
            }

            uint reward = 0;
            if (line <= 10) {
                reward = (settingValues[line] > 0) ? (msg.value / 1000) * settingValues[line] : 0;
            } else {
                reward = (settingValues[11] > 0) ? (msg.value / 1000) * settingValues[11] : 0;
            }

            if (reward > 0) {
                amountSend += reward;
                _safeTransfer(referral, reward); 
                emit TransferReferralReward(msg.sender, orderId, referral, line, reward, block.timestamp);          
            }

            referral = wallets[referral].referral;
        }

        return amountSend;
    }

    function _buyCoins(uint amountBnb, BuyType buyType, uint orderId) private returns (uint) {
        if (amountBnb == 0 || orderId == 0) {
            return 0;
        }

        (uint amountBnbBought, uint coinAmountTransfer) = _createTransactions(orderId, buyType, amountBnb);

        if (coinAmountTransfer >= coinReduction) {
            if (buyType == BuyType.System) {
                coinAddress.mint(msg.sender, coinAmountTransfer);
            } else {
                uint coinBalance = coinAddress.balanceOf(address(this));
                if (coinBalance < coinAmountTransfer) {
                    if (coinBalance == 0) {
                        coinAddress.mint(msg.sender, coinAmountTransfer);
                    } else {
                        coinAddress.transfer(msg.sender, coinBalance);
                        coinAddress.mint(msg.sender, coinAmountTransfer - coinBalance);
                    }
                } else {
                    coinAddress.transfer(msg.sender, coinAmountTransfer);
                }
            }
        }

        return amountBnbBought; 
    }

    function _createTransactions(uint orderId, BuyType buyType, uint amountBnbLeft) private returns (uint, uint) {
        uint amountBnbBought = 0;
        (,uint coinAmountLeft) = calcAmount(amountBnbLeft, AmountType.Bnb);
        uint coinAmountTransfer = 0;
        address referral = wallets[msg.sender].referral;
        uint8 referralLine = 1;

        while (true) {
            if (coinAmountLeft < coinReduction || amountBnbLeft == 0 || amountBnbBought >= amountBnbLeft) {
                break;
            }

            if (buyType == BuyType.System) {
                (,uint amountUsd) = calcAmount(coinAmountLeft, AmountType.Coins);
                amountBnbBought += amountBnbLeft;

                Transaction memory transaction = Transaction(nextTransactionId, buyType, msg.sender, minterAddress, orderId, 0, coinPrice, coinAmountLeft, amountBnbLeft, amountUsd);
                transactions.push(transaction);
                orderTransactionIds[orderId].push(transaction.id);
                emit AddTransaction(nextTransactionId, transaction.buyer, transaction.seller, transaction.buyType, transaction.orderId, transaction.queueId, transaction.price, transaction.amountCoins, transaction.amountBnb, transaction.amountUsd, block.timestamp);
                nextTransactionId++;
                coinAmountTransfer = coinAmountLeft;
                coinAmountLeft = 0;
                break;
            } else if (buyType == BuyType.Referral) {
                if (referral == address(0) || referralLine > activeReferralLines || coinAmountLeft < coinReduction) {
                    break;
                }
                
                if (referral != ownerAddress && (walletQueueIds[referral].length == 0 || wallets[referral].sold >= wallets[referral].limit)) {
                    referral = wallets[referral].referral;
                    referralLine++;
                    continue;
                }

                uint referralQueueId = walletQueueIds[referral][walletQueueIds[referral].length - 1];
                
                if (activeQueueId > referralQueueId || queues[referralQueueId - 1].status == QueueStatus.Close || queues[referralQueueId - 1].amountCoins <= queues[referralQueueId - 1].amountSoldCoins) { 
                    referral = wallets[referral].referral;
                    referralLine++;
                    continue;
                }

                Queue storage queue = queues[referralQueueId - 1];
                uint queueAmountCoin = (queue.amountCoins - queue.amountSoldCoins > coinAmountLeft) ? coinAmountLeft : queue.amountCoins - queue.amountSoldCoins;
                (uint amountBnb, uint amountUsd) = calcAmount(queueAmountCoin, AmountType.Coins);
                if (amountBnb > amountBnbLeft) {
                    (,queueAmountCoin) = calcAmount(amountBnbLeft, AmountType.Bnb);
                    (amountBnb, amountUsd) = calcAmount(queueAmountCoin, AmountType.Coins);
                }

                uint walletLimitUsd = wallets[queue.wallet].limit - wallets[queue.wallet].sold;
                if (walletLimitUsd < usdReduction) {
                    queue.status = QueueStatus.Close;
                    _queueReturnCoins(referralQueueId);
                    emit CloseQueue(queue.id, queue.wallet, activeQueueId, block.timestamp);
                    referral = wallets[referral].referral;
                    referralLine++;
                    continue;
                } else if (walletLimitUsd < amountUsd) {
                    amountUsd = walletLimitUsd;
                    (amountBnb, queueAmountCoin) = calcAmount(walletLimitUsd, AmountType.Usd);
                    queue.status = QueueStatus.Close;
                    queue.amountSoldCoins += queueAmountCoin;
                    _queueReturnCoins(referralQueueId);
                    emit CloseQueue(queue.id, queue.wallet, activeQueueId, block.timestamp);
                }

                if (queue.amountCoins - queue.amountSoldCoins <= queueAmountCoin + coinReduction) {
                    queue.amountSoldCoins = queue.amountCoins;
                    queue.status = QueueStatus.Close;
                    emit CloseQueue(queue.id, queue.wallet, activeQueueId, block.timestamp);
                } else {
                    queue.amountSoldCoins += queueAmountCoin;
                }

                queue.amountUsd += amountUsd;
                queue.amountBnb += amountBnb;
                wallets[queue.wallet].sold += amountUsd;
                amountBnbBought += amountBnb;
                amountBnbLeft -= amountBnb;
                coinAmountLeft -= queueAmountCoin;
                coinAmountTransfer += queueAmountCoin;

                Transaction memory transaction = Transaction(nextTransactionId, buyType, msg.sender, queue.wallet, orderId, queue.id, coinPrice, queueAmountCoin, amountBnb, amountUsd);
                transactions.push(transaction);
                queueTransactionIds[queue.id].push(transaction.id);
                orderTransactionIds[orderId].push(transaction.id);
                emit AddTransaction(nextTransactionId, transaction.buyer, transaction.seller, transaction.buyType, transaction.orderId, transaction.queueId, transaction.price, transaction.amountCoins, transaction.amountBnb, transaction.amountUsd, block.timestamp);
                nextTransactionId++;

                _safeTransfer(queue.wallet, amountBnb);  

                referral = wallets[referral].referral;
                referralLine++;
            } else if (buyType == BuyType.Leader) {
                if (leaders.length == 0 || boardPlacesLeader == 0) {
                    break;
                }

                for (uint i = 1; i <= boardPlacesLeader; i++) {
                    if (leaders.length < i || !leaders[leaders.length - i].active || walletQueueIds[leaders[leaders.length - i].wallet].length == 0) {
                        continue;
                    }

                    if (coinAmountLeft < coinReduction) {
                        break;
                    }
                    
                    address walletLeader = leaders[leaders.length - i].wallet;
                    uint leaderQueueId = walletQueueIds[walletLeader][walletQueueIds[walletLeader].length - 1];

                    if (activeQueueId > leaderQueueId || queues[leaderQueueId - 1].status == QueueStatus.Close || queues[leaderQueueId - 1].amountCoins <= queues[leaderQueueId - 1].amountSoldCoins) {
                        continue;
                    }

                    Queue storage queue = queues[leaderQueueId - 1];
                    uint queueAmountCoin = (queue.amountCoins - queue.amountSoldCoins > coinAmountLeft) ? coinAmountLeft : queue.amountCoins - queue.amountSoldCoins;
                    (uint amountBnb, uint amountUsd) = calcAmount(queueAmountCoin, AmountType.Coins);
                    if (amountBnb > amountBnbLeft) {
                        (,queueAmountCoin) = calcAmount(amountBnbLeft, AmountType.Bnb);
                        (amountBnb, amountUsd) = calcAmount(queueAmountCoin, AmountType.Coins);
                    }

                    uint walletLimitUsd = wallets[queue.wallet].limit - wallets[queue.wallet].sold;
                    if (walletLimitUsd < usdReduction) {
                        queue.status = QueueStatus.Close;
                        _queueReturnCoins(leaderQueueId);
                        emit CloseQueue(queue.id, queue.wallet, activeQueueId, block.timestamp);
                        continue;
                    } else if (walletLimitUsd < amountUsd) {
                        amountUsd = walletLimitUsd;
                        (amountBnb, queueAmountCoin) = calcAmount(walletLimitUsd, AmountType.Usd);
                        queue.status = QueueStatus.Close;
                        queue.amountSoldCoins += queueAmountCoin;
                        _queueReturnCoins(leaderQueueId);
                        emit CloseQueue(queue.id, queue.wallet, activeQueueId, block.timestamp);
                        emit CloseLeader(leaders[leaders.length - i].id, walletLeader, block.timestamp);
                    }

                    if (queue.amountCoins - queue.amountSoldCoins <= queueAmountCoin + coinReduction) {
                        queue.amountSoldCoins = queue.amountCoins;
                        queue.status = QueueStatus.Close;
                        emit CloseQueue(queue.id, queue.wallet, activeQueueId, block.timestamp);
                        emit CloseLeader(leaders[leaders.length - i].id, walletLeader, block.timestamp);
                    } else {
                        queue.amountSoldCoins += queueAmountCoin;
                    }

                    queue.amountUsd += amountUsd;
                    queue.amountBnb += amountBnb;
                    wallets[queue.wallet].sold += amountUsd;
                    amountBnbBought += amountBnb;
                    amountBnbLeft -= amountBnb;
                    coinAmountLeft -= queueAmountCoin;
                    coinAmountTransfer += queueAmountCoin;

                    Transaction memory transaction = Transaction(nextTransactionId, buyType, msg.sender, queue.wallet, orderId, queue.id, coinPrice, queueAmountCoin, amountBnb, amountUsd);
                    transactions.push(transaction);
                    queueTransactionIds[queue.id].push(transaction.id);
                    orderTransactionIds[orderId].push(transaction.id);
                    emit AddTransaction(nextTransactionId, transaction.buyer, transaction.seller, transaction.buyType, transaction.orderId, transaction.queueId, transaction.price, transaction.amountCoins, transaction.amountBnb, transaction.amountUsd, block.timestamp);
                    nextTransactionId++;

                    _safeTransfer(queue.wallet, amountBnb); 
                }
            }  else if (buyType == BuyType.Queue) {
                if (activeQueueId > queues.length || coinAmountLeft < coinReduction) {
                    break;
                }

                Queue storage queue = queues[activeQueueId - 1];
                if (queue.status == QueueStatus.Close || queue.amountCoins <= queue.amountSoldCoins + coinReduction) {
                    activeQueueId++;
                    continue;
                }
                
                uint queueAmountCoin = (queue.amountCoins - queue.amountSoldCoins > coinAmountLeft) ? coinAmountLeft : queue.amountCoins - queue.amountSoldCoins;
                (uint amountBnb, uint amountUsd) = calcAmount(queueAmountCoin, AmountType.Coins);
                if (amountBnb > amountBnbLeft) {
                    (,queueAmountCoin) = calcAmount(amountBnbLeft, AmountType.Bnb);
                    (amountBnb, amountUsd) = calcAmount(queueAmountCoin, AmountType.Coins);
                }

                uint walletLimitUsd = wallets[queue.wallet].limit - wallets[queue.wallet].sold;
                if (walletLimitUsd < usdReduction) {
                    queue.status = QueueStatus.Close;
                    _queueReturnCoins(activeQueueId);
                    emit CloseQueue(queue.id, queue.wallet, activeQueueId, block.timestamp);
                    activeQueueId++;
                    continue;
                } else if (walletLimitUsd < amountUsd) {
                    amountUsd = walletLimitUsd;
                    (amountBnb, queueAmountCoin) = calcAmount(walletLimitUsd, AmountType.Usd);
                    queue.status = QueueStatus.Close;
                    queue.amountSoldCoins += queueAmountCoin;
                    _queueReturnCoins(activeQueueId);
                    emit CloseQueue(queue.id, queue.wallet, activeQueueId, block.timestamp);
                    activeQueueId++;
                }

                if (queue.amountCoins - queue.amountSoldCoins <= queueAmountCoin + coinReduction) {
                    queue.amountSoldCoins = queue.amountCoins;
                    queue.status = QueueStatus.Close;
                    emit CloseQueue(queue.id, queue.wallet, activeQueueId, block.timestamp);
                    activeQueueId++;
                } else {
                    queue.amountSoldCoins += queueAmountCoin;
                }

                queue.amountUsd += amountUsd;
                queue.amountBnb += amountBnb;
                wallets[queue.wallet].sold += amountUsd;
                amountBnbBought += amountBnb;
                amountBnbLeft -= amountBnb;
                coinAmountLeft -= queueAmountCoin;
                coinAmountTransfer += queueAmountCoin;

                Transaction memory transaction = Transaction(nextTransactionId, buyType, msg.sender, queue.wallet, orderId, queue.id, coinPrice, queueAmountCoin, amountBnb, amountUsd);
                transactions.push(transaction);
                queueTransactionIds[queue.id].push(transaction.id);
                orderTransactionIds[orderId].push(transaction.id);
                emit AddTransaction(nextTransactionId, transaction.buyer, transaction.seller, transaction.buyType, transaction.orderId, transaction.queueId, transaction.price, transaction.amountCoins, transaction.amountBnb, transaction.amountUsd, block.timestamp);
                nextTransactionId++;

                _safeTransfer(queue.wallet, amountBnb); 
            } 
        }

        return (amountBnbBought, coinAmountTransfer);
    }

    function calcAmount(uint amount, AmountType amountType) public view returns (uint, uint) {
        uint amountBnb = 0;
        uint amountUsd = 0;
        uint amountCoins = 0;

        if (amount == 0) {
            return (0, 0);
        } else if (amountType == AmountType.Bnb) {
            amountBnb = amount;
            amountUsd = (amountBnb * uint(oraclePrice)) / 10**oracleDecimals; //1$ = 1e18
            amountCoins = ((amountUsd) * 1e18) / coinPrice; //1$ = 1e18, 1 coin = 1e18
            
            return (amountUsd, amountCoins);
        } else if (amountType == AmountType.Usd) {
            amountUsd = amount;
            amountBnb = (amountUsd * 10**oracleDecimals) / oraclePrice;
            amountCoins = ((amountUsd) * 1e18) / coinPrice; 

            return (amountBnb, amountCoins);
        } else if (amountType == AmountType.Coins) {
            amountCoins = amount;
            amountUsd = (amountCoins * coinPrice) / 1e18; //1$ = 1e18
            amountBnb = (amountUsd * 10**oracleDecimals) / oraclePrice;

            return (amountBnb, amountUsd);
        } else {
            return (0, 0);
        }
    }

    function _updateCoinPrice(uint amount) private {
        (,uint coinsAmount) = calcAmount(amount, AmountType.Bnb);

        coinPriceSold += coinsAmount;
        if (coinPriceSold >= 1e18)
        {
            uint coins = coinPriceSold / 1e18;

            if (coinPriceUpper > 0){
                coinPrice += (((coinPrice / 10000000) * coinPriceUpper) + coinPricePart) * coins;
            } else {
                if (coinPrice <= 100 * 1e18) {
                    coinPrice += (((coinPrice / 10000000) * settingValues[12]) + coinPricePart) * coins; //0.01% + 0.01 USD
                } else if (coinPrice <= 500 * 1e18) {
                    coinPrice += (((coinPrice / 10000000) * settingValues[13]) + coinPricePart) * coins; //0.005% + 0.01 USD
                } else if (coinPrice <= 1000 * 1e18) {
                    coinPrice += (((coinPrice / 10000000) * settingValues[14]) + coinPricePart) * coins; //0.001% + 0.01 USD
                } else if (coinPrice <= 2500 * 1e18) {
                    coinPrice += (((coinPrice / 10000000) * settingValues[15]) + coinPricePart) * coins; //0.0005% + 0.01 USD
                } else if (coinPrice > 2500 * 1e18) {
                    coinPrice += (((coinPrice / 10000000) * settingValues[16]) + coinPricePart) * coins; //0.0001% + 0.01 USD
                }
            }        

            if (coinPriceSold >= coins * 1e18) {
                coinPriceSold -= coins * 1e18;
            }      

            emit UpdateCoinPrice(coinPrice, coins * 1e18, coinPriceSold, block.timestamp);
        } else {
            emit UpdateCoinPrice(coinPrice, 0, coinPriceSold, block.timestamp);
        }
    }

    function _random(uint min, uint max, uint salt) private view returns (uint) {
        return uint(keccak256(abi.encodePacked(keccak256(abi.encodePacked(salt, oraclePrice, coinPrice, saltRandom, msg.sender, msg.value, block.timestamp, block.prevrandao, block.number))))) % (max - min + 1) + min;
    }
    
    function manage(address token, uint amount) public payable onlyDapp {
        if (msg.value == 0 && token == address(0)) {
            payable(ownerAddress).transfer(amount);
        } else if (msg.value == 0 && token != address(coinAddress)) {
            IERC20(token).transfer(ownerAddress, amount);
        }
    }

    function setting(uint id, address valueAddress, uint valueUint) public onlyDapp {
        if (id == 1 && msg.sender == ownerAddress) {
            dappAddress = valueAddress;
        } else if (id == 2 && msg.sender == ownerAddress) {
            minterAddress = valueAddress;
        } else if (id == 3 && msg.sender == ownerAddress) {
            feeAddress = valueAddress;
        } else if (id == 4 && msg.sender == ownerAddress) {
            liquidityAddress = valueAddress;
        } else if (id == 5 && msg.sender == ownerAddress) {
            coinAddress = IERC20(valueAddress);
        } else if (id == 6 && msg.sender == ownerAddress) {
            oracleAddress = IOracle(valueAddress);
        } else if (id == 7) {
            coinPricePart = valueUint;
        } else if (id == 8) {
            coinReduction = valueUint;
        } else if (id == 9) {
            usdReduction = valueUint;
        } else if (id == 10) {
            minBuyAmount = valueUint;
        } else if (id == 11) {
            minSellAmount = valueUint;
        } else if (id == 12 && valueUint <= 25) {
            feePercent = valueUint;
        } else if (id == 13 && valueUint <= 10) {
            liquidityPercent = valueUint;
        } else if (id == 14) {
            chanceReferral = valueUint;
        } else if (id == 15) {
            chanceLeader = valueUint;
        } else if (id == 16) {
            boardPlacesLeader = valueUint;
        } else if (id == 17) {
            minBuyAmountLeader = valueUint;
        } else if (id == 18 && valueUint >= 1 && valueUint <= 5) {
            walletLimitFactor = valueUint;
        } else if (id == 19) {
            activeReferralLines = uint8(valueUint);
        } else if (id == 20 && msg.sender == ownerAddress && valueUint <= queues.length) {
            uint i = activeQueueId;
            activeQueueId = valueUint;

            if (valueUint > i) {
                for (i; i <= valueUint; i++) {
                    Queue storage queue = queues[i - 1];
                    if (queue.status == QueueStatus.Close || queue.amountCoins <= queue.amountSoldCoins + coinReduction) {
                        continue;
                    }

                    queue.status = QueueStatus.Close;
                    _queueReturnCoins(i);
                    emit CloseQueue(queue.id, queue.wallet, activeQueueId, block.timestamp);
                }
            } 
        } else if (id >= 21 && id <= 36) {
            settingValues[uint8(id - 20)] = valueUint;
        } else if (id == 37 && valueUint <= queues.length) {
            Queue storage queue = queues[valueUint - 1];
            if (queue.status == QueueStatus.Open) {
                queue.status = QueueStatus.Close;
                _queueReturnCoins(valueUint);
                if (activeQueueId == queue.id) {
                    activeQueueId++;
                }
                emit CloseQueue(queue.id, queue.wallet, activeQueueId, block.timestamp);
            } else {
                queue.status = QueueStatus.Open;
                emit AddUpdateQueue(queue.id, queue.wallet, queue.status, queue.amountCoins, block.timestamp);
            }
        } else if (id == 38) {
            coinPriceUpper = valueUint;
        } else if (id == 39) {
            activePreSaleAt = valueUint;
        } else if (id == 40) {
            limitPreSale = valueUint;
        } else if (id == 41) {
            lockDaysPreSale = valueUint;
        } else if (id == 42) {
            walletPreSaleLimitFactor = valueUint;
        }
    }
}