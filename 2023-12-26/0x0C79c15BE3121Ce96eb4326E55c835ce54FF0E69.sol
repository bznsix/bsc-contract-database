// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Import ERC20 interface for token transfers
interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function mint(address to, uint256 amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 value) external;

    function transfer(address to, uint256 value) external;

    function transferFrom(address from, address to, uint256 value) external;

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);
}

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function getRoundData(
        uint80 _roundId
    )
        external
        view
        returns (
            uint80 roundId,
            uint256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            uint256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

contract PriceConsumerV3 {
    AggregatorV3Interface internal priceFeed;

    function getLatestPrice() public view returns (uint) {
        (, uint price, , , ) = priceFeed.latestRoundData();

        return uint256(price);
    }
}

contract PresaleMetaWorld is PriceConsumerV3 {
    address public owner;
    IERC20 public MTW;
    uint public totalRaisedBNB;
    uint public totalRaisedUSDT;
    uint256 public startTime;
    uint256 public endTime;
    bool public CanBuy;
    uint256 public rewardLimit;
    uint8 public rewardPercentage = 10;

    struct TokenDetails {
        IERC20 tokenAddress;
        uint256 price;
        uint256 totalSold;
    }

    TokenDetails[] public tokenList;
    mapping(address => address) public referrers;
    mapping(address => uint256) public selfBuys;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    event TokenPriceUpdated(uint256 indexed tokenIndex, uint256 newPrice);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event TokensAddedToTokenList(address indexed tokenAddress, uint256 price);
    event TokenRemovedFromTokenList(
        address indexed tokenAddress,
        uint256 tokenIndex
    );
    event TokensPurchased(
        address indexed buyer,
        uint256 tokenIndex,
        uint256 amountBought,
        uint256 priceInBNB
    );
    event EtherWithdrawn(address indexed owner, uint256 amount);
    event TokensWithdrawn(
        address indexed owner,
        address indexed tokenAddress,
        uint256 amount
    );
    event PresalePeriodUpdated(uint256 newStartTime, uint256 newEndTime);
    event CanBuyStatusChanged(bool newCanBuyStatus);

    constructor(uint256 _startTime, uint256 _endTime) {
        owner = msg.sender;
        CanBuy = true;
        rewardLimit = 100000000000;
        startTime = _startTime;
        endTime = _endTime;
        priceFeed = AggregatorV3Interface(
            0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
        );
        tokenList.push(TokenDetails(IERC20(address(0)), 66, 0));
        tokenList.push(
            TokenDetails(
                IERC20(0x55d398326f99059fF775485246999027B3197955),
                66,
                0
            )
        );
        MTW = IERC20(0xAAeB74600F79718508606a8A84E9B151d77de01C);
    }

    // Function to update the price of a token (for the owner)
    function updateTokenPrice(
        uint256 _tokenIndex,
        uint256 _price
    ) external onlyOwner {
        require(_tokenIndex < tokenList.length, "Invalid token index");
        tokenList[_tokenIndex].price = _price;
        emit TokenPriceUpdated(_tokenIndex, _price);
    }

    function updatePriceFeed(address _newPriceFeedAddress) external onlyOwner {
        priceFeed = AggregatorV3Interface(_newPriceFeedAddress);
    }

    function setTokenForSaleAddress(
        address _newTokenAddress
    ) external onlyOwner {
        MTW = IERC20(_newTokenAddress);
    }

    function setCanBuy(bool _canBuy) external onlyOwner {
        CanBuy = _canBuy;
        emit CanBuyStatusChanged(_canBuy);
    }

    function setrewardLimit(uint256 _rewardLimit) external onlyOwner {
        rewardLimit = _rewardLimit;
    }

    function setrewardPercentage(uint8 _rewardPercentage) external onlyOwner {
        rewardPercentage = _rewardPercentage;
    }

    function addTokenToTokenList(
        IERC20 _tokenAddress,
        uint256 _price
    ) public onlyOwner {
        TokenDetails memory newToken = TokenDetails({
            tokenAddress: _tokenAddress,
            price: _price,
            totalSold: 0
        });
        tokenList.push(newToken);
        emit TokensAddedToTokenList(address(_tokenAddress), _price);
    }

    function removeTokenFromTokenList(uint256 _tokenIndex) public onlyOwner {
        require(_tokenIndex < tokenList.length, "Invalid token index");
        address removedTokenAddress = address(
            tokenList[_tokenIndex].tokenAddress
        );
        for (uint256 i = _tokenIndex; i < tokenList.length - 1; i++) {
            tokenList[i] = tokenList[i + 1];
        }
        tokenList.pop();
        emit TokenRemovedFromTokenList(removedTokenAddress, _tokenIndex);
    }

    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "New owner address cannot be zero");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }

    function buyTokens(
        uint _tokenIndex,
        uint256 _amount,
        address referrer
    ) external payable {
        require(CanBuy, "MTW: Can't buy token");
        require(_tokenIndex < tokenList.length, "Invalid token index");

        uint256 tokenBought;

        if (_tokenIndex == 0) {
            tokenBought = calculateTokens(_tokenIndex, msg.value);
            totalRaisedBNB += msg.value;
        } else {
            tokenBought = calculateTokens(_tokenIndex, _amount);
            totalRaisedUSDT += _amount;
            IERC20(tokenList[_tokenIndex].tokenAddress).transferFrom(
                msg.sender,
                address(this),
                _amount
            );
        }

        selfBuys[msg.sender] += tokenBought;

        uint256 remainingAllowance = tokenForSale();
        require(
            remainingAllowance >= tokenBought,
            "MTW: Not enough allowance for token sale"
        );
        tokenList[_tokenIndex].totalSold += tokenBought;
        MTW.transferFrom(owner, msg.sender, tokenBought);

        emit TokensPurchased(
            msg.sender,
            _tokenIndex,
            tokenBought,
            tokenList[_tokenIndex].price
        );

        if (referrers[msg.sender] == address(0)) {
            referrers[msg.sender] = referrer != address(0) ? referrer : owner;
        }

        if (
            referrers[msg.sender] != address(0) &&
            referrers[msg.sender] == referrer
        ) {
            uint checkValue = selfBuys[referrer];
            if (checkValue >= rewardLimit) {
                uint256 referralReward = (tokenBought * rewardPercentage) / 100;
                MTW.transferFrom(owner, referrer, referralReward);
            }
        }
    }

    function calculateTokens(
        uint256 _tokenIndex,
        uint256 _amount
    ) public view returns (uint256) {
        require(_tokenIndex < tokenList.length, "Invalid token index");
        uint256 tokenPrice = tokenList[_tokenIndex].price;
        uint256 usdtPrice = getLatestPrice(); // Fetch USDT price from Chainlink
        uint256 decimal = 10 ** MTW.decimals();
        uint256 tokenAmount;

        if (_tokenIndex == 0) {
            uint256 bnbtousdt = _amount * usdtPrice;
            tokenAmount = (bnbtousdt * tokenPrice * decimal) / (1 ether) / 1e8;
        } else {
            tokenAmount = (_amount * tokenPrice * decimal) / (1 ether);
        }

        return tokenAmount;
    }

    function withdrawEther(uint256 amount) external onlyOwner {
        require(
            address(this).balance >= amount,
            "Insufficient balance in the contract"
        );
        payable(owner).transfer(amount);
        emit EtherWithdrawn(owner, amount);
    }

    function withdrawTokens(
        address tokenAddress,
        uint256 amount
    ) external onlyOwner {
        require(tokenAddress != address(0), "Token address cannot be zero");
        IERC20 token = IERC20(tokenAddress);
        token.transfer(owner, amount);
        emit TokensWithdrawn(owner, tokenAddress, amount);
    }

    function getTotalSoldTokens() external view returns (uint256) {
        uint256 totalTokensSold = 0;
        for (uint256 i = 0; i < tokenList.length; i++) {
            totalTokensSold += tokenList[i].totalSold;
        }
        return totalTokensSold;
    }

    function setPresaleTimePeriod(
        uint256 _newStartTime,
        uint256 _newEndTime
    ) external onlyOwner {
        require(
            _newStartTime > block.timestamp,
            "Start time must be in the future"
        );
        require(
            _newEndTime > block.timestamp,
            "End time must be in the future"
        );
        require(
            _newEndTime > _newStartTime,
            "End time must be after the start time"
        );

        startTime = _newStartTime;
        endTime = _newEndTime;
        emit PresalePeriodUpdated(startTime, endTime);
    }

    function tokenForSale() public view returns (uint256) {
        return MTW.allowance(owner, address(this));
    }

    function contractBalance(
        address tokenAddress
    ) external view returns (uint256) {
        IERC20 token = IERC20(tokenAddress);
        return token.balanceOf(address(this));
    }

    receive() external payable {}
}