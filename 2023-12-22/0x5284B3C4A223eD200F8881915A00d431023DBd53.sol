// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function decimals() external view returns (uint8);
}

interface AggregatorV3Interface {
    function latestRoundData() external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );
}

contract ICO_CONTRACT {
    address public owner;
    IERC20 public token;
    AggregatorV3Interface public bnbPriceFeed;

    bool public isBuyEnabled = true;
    uint256 public minBuyAmount = 0.05 ether; // Min buy limit in BNB (0.05 BNB)
    uint256 public maxBuyAmount = 10 ether; // Max buy limit in BNB (10 BNB)

    mapping(address => address) public referrals;
    mapping(address => uint256) public referralCount;
    mapping(address => address) public initialReferrer;
    mapping(address => uint256) public referralRewards;
    
    uint256 public tokenPriceInUSD = 5; // Equivalent to 0.00005 USD, represented in cents
    uint256 public totalBNBReceived; // Total BNB received
    
    uint256 public referralPercentage = 10;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    constructor(address _token, address _bnbPriceFeed) {
        owner = msg.sender;
        token = IERC20(_token);
        bnbPriceFeed = AggregatorV3Interface(_bnbPriceFeed);
    }

    // Function for the owner to change the referral percentage
    function changeReferralPercentage(uint256 _newPercentage) external onlyOwner {
        require(_newPercentage >= 0 && _newPercentage <= 100, "Invalid percentage.");
        referralPercentage = _newPercentage;
    }


    function buyTokensWithBNB(address _referrer) external payable {
        require(isBuyEnabled, "Buying tokens is currently disabled.");
        require(msg.value >= minBuyAmount && msg.value <= maxBuyAmount, "BNB amount not within allowed range.");
        int256 latestPrice = getLatestBNBPrice();
        uint256 amountOfTokens = calculateTokenAmount(msg.value, uint256(latestPrice));
        
        require(token.balanceOf(address(this)) >= amountOfTokens, "Not enough tokens in the contract.");

        // Check if the buyer already has an initial referrer
        if (initialReferrer[msg.sender] == address(0)) {
            // This is the first time the buyer is using a referral
            if (_referrer != address(0) && _referrer != msg.sender) {
                initialReferrer[msg.sender] = _referrer;
            }
        }

        // Apply referral bonus
        address effectiveReferrer = initialReferrer[msg.sender];
            if (effectiveReferrer != address(0)) {
                uint256 referralBonus = (amountOfTokens * referralPercentage) / 100;
                require(token.balanceOf(address(this)) >= amountOfTokens + referralBonus, "Not enough tokens for referral bonus.");
                
                // Transfer bonus to the effective referrer
                token.transfer(effectiveReferrer, referralBonus);
                referralCount[effectiveReferrer] += 1; // Increment referrer's count
                referralRewards[effectiveReferrer] += referralBonus; // Update referral rewards
            }

            token.transfer(msg.sender, amountOfTokens);
            totalBNBReceived += msg.value; // Update the total BNB received
        }

    function getLatestBNBPrice() public view returns (int256) {
        (, int256 answer, , ,) = bnbPriceFeed.latestRoundData();
        return answer;
    }

    function getReferralRewards(address user) external view returns (uint256) {
    return referralRewards[user];
    }


    function calculateTokenAmount(uint256 amount, uint256 priceInUSD) public view returns (uint256) {
        uint256 amountInUSD = (amount * priceInUSD) / 1e8; // Convert amount based on price feed's 8 decimals
        uint256 basicTokenAmount = (amountInUSD * 100000) / tokenPriceInUSD; // Convert to cents and calculate basic token amount

        // Adjust for token's decimals
        return basicTokenAmount * (10 ** uint256(token.decimals())) / 1e18;
    }

    function withdrawBNB() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function YourReferrer(address user) external view returns (address) {
        return initialReferrer[user];
    }

    function withdrawTokens() external onlyOwner {
        token.transfer(owner, token.balanceOf(address(this)));
    }

    // Change Token Price Function
    function changeTokenPrice(uint256 newPriceInUSD) public onlyOwner {
        require(newPriceInUSD > 0, "Price must be greater than 0.");
        tokenPriceInUSD = newPriceInUSD;
    }

    // Setter functions for min and max buy limits
    function setMinBuyAmount(uint256 newMinBuyAmount) external onlyOwner {
        minBuyAmount = newMinBuyAmount;
    }

    function setMaxBuyAmount(uint256 newMaxBuyAmount) external onlyOwner {
        maxBuyAmount = newMaxBuyAmount;
    }

    function enableBuying() external onlyOwner {
        isBuyEnabled = true;
    }

    function disableBuying() external onlyOwner {
        isBuyEnabled = false;
    }

    // Function to transfer ownership
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner cannot be the zero address.");
        owner = newOwner;
    }

}