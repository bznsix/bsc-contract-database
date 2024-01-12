// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

contract GoldLama {

    struct UserInfo {
        uint256 userId;
        uint256 refId;
        uint256 profitDept;
        uint256 balanceOfCocktail;
        uint256 balanceOfCoin;
        uint256[30] timestamps;
        uint8[] purchasedIds;
    }

    uint64 private constant PRICE_OF_COCKTAIL = 30000000000000;
    uint64 private constant PRICE_OF_COIN = 300000000000;

    address public owner;
    address unusedRefWallet;

    uint256 public startTimestamp;
    uint256 public usersCount;
    uint256[30] public profits;
    uint32[30] public prices;

    mapping(uint256 => address) public idToHisAddress; 
    mapping(address => address) public addressToHisReferrer; 
    mapping(address => UserInfo) userInfo;

    //events
    event CocktailBought(address indexed buyer, uint256 indexed count, uint256 indexed timestamp);
    event CoinSold(address indexed buyer, uint256 indexed count, uint256 indexed timestamp);
    event CoinSwap(address indexed user, uint256 indexed countOfCoins, uint256 countOfReceivedCoctails, uint256 indexed timestamp);
    event PersonagePurchased(address indexed user, uint256 indexed typeOfItem, uint256 indexed timestamp);
    event Claimed(address indexed user, uint256 indexed profit, uint256 indexed timestamp);

    modifier onlyOwner(){
        require(msg.sender == owner, "GoldenLama:: This function can be called only by owner");
        _;
    }

    constructor(uint32[30] memory _prices, address _unusedRefWallet) {
        owner = msg.sender;
        unusedRefWallet = _unusedRefWallet;
        startTimestamp = block.timestamp;
        usersCount = 1;
        prices = _prices;
        _setProfits();
    }

    receive() external payable {}

    function getUserInfo(address _user) external view returns(UserInfo memory) {
        return userInfo[_user];
    }

    function addUserToMlm(address _user, uint256 _refId) external onlyOwner{
        require(_refId < usersCount, "GoldenLama:: Please provide right ID!");

        userInfo[_user].refId = _refId;
        userInfo[_user].userId = usersCount;
        idToHisAddress[usersCount] = _user;
        ++usersCount;
        address referrer = idToHisAddress[_refId];
        addressToHisReferrer[_user] = referrer;
    }

    function buyCocktail(uint256 _count) external payable {
        require(msg.value == (_count * PRICE_OF_COCKTAIL), "GoldenLama:: Insufficient funds for buying cocktails!");

        payable(owner).transfer(msg.value / 10);

        UserInfo storage user = userInfo[msg.sender];

        if(user.userId == 0) {
            user.userId = usersCount;
            idToHisAddress[usersCount] = msg.sender;
            ++usersCount;
        }

        user.balanceOfCocktail += _count;

        address referrer = addressToHisReferrer[msg.sender];
        uint256 countOfCoctails = msg.value * 7 / 100 / PRICE_OF_COCKTAIL;
        uint256 countOfCoins = msg.value * 3 / 100 / PRICE_OF_COIN;
        if(referrer != address(0)) {
            userInfo[referrer].balanceOfCocktail += countOfCoctails;
            userInfo[referrer].balanceOfCoin += countOfCoins;
        } else {
            userInfo[unusedRefWallet].balanceOfCocktail += countOfCoctails;
            userInfo[unusedRefWallet].balanceOfCoin += countOfCoins;
        }

        emit CocktailBought(msg.sender, _count, block.timestamp);
    }

    function swapCoinsWithCocktails(uint256 _count) external {
        require(_count > 0, "GoldenLama:: Coins count to exchange should be greater than 0!");
        require(userInfo[msg.sender].balanceOfCoin >= _count, "GoldenLama:: Insufficient balance of coins!");
        userInfo[msg.sender].balanceOfCoin -= _count - (_count % 100);
        uint256 receivedCocktails = (_count - (_count % 100)) / 100;
        userInfo[msg.sender].balanceOfCocktail += receivedCocktails;
        emit CoinSwap(msg.sender, _count, receivedCocktails, block.timestamp);
    }

    function sellCoins(uint256 _count) external {
        UserInfo storage user = userInfo[msg.sender];
        require(user.balanceOfCoin >= _count, "GoldenLama:: Insufficient balance of cocktails!");
        user.balanceOfCoin -= _count;
        uint256 amountToTransfer = _count * PRICE_OF_COIN;

        (bool sent,) = payable(msg.sender).call{value:amountToTransfer}("");
        require(sent , "GoldenLama:: Not sent!");
        emit CoinSold(msg.sender, _count, block.timestamp);
    }

    function purchasePersonage(uint8 _personageType) external {
        require(_personageType < 30, "GoldenLama:: Invalide type!");
        require(userInfo[msg.sender].balanceOfCocktail >= prices[_personageType], "GoldenLama:: Insufficient balance for buying personage!");

        userInfo[msg.sender].balanceOfCocktail -= prices[_personageType];
        userInfo[msg.sender].purchasedIds.push(_personageType);
        
        if(_personageType < 6) {
            _purchaselevelOneItem(_personageType);
        }
        if(_personageType > 5 && _personageType < 12) {
            _purchaselevelTwoItem(_personageType);
        }
        if(_personageType > 11 && _personageType < 18) {
            _purchaselevelThreeItem(_personageType);
        }
        if(_personageType > 17 && _personageType < 24) {
            _purchaselevelFourItem(_personageType);
        }
        if(_personageType > 23 && _personageType < 30) {
            _purchaselevelFiveItem(_personageType);
        }

        emit PersonagePurchased(msg.sender, _personageType, block.timestamp);

    }

    function claim() external {
        uint256 profit;
        UserInfo storage user = userInfo[msg.sender];
        uint256[30] memory _timestamps = user.timestamps;
        uint256 length = user.purchasedIds.length;

        for(uint8 i; i < length; ++i) {
            if(_timestamps[user.purchasedIds[i]] > 0 && block.timestamp > _timestamps[user.purchasedIds[i]] + 1 days) {
                _timestamps[user.purchasedIds[i]] = block.timestamp;
                profit += profits[user.purchasedIds[i]];
            }  
        }

        user.timestamps = _timestamps;
        user.balanceOfCoin += profit;
        user.profitDept +=profit;

        emit Claimed(msg.sender, profit, block.timestamp);

    }

    function _setProfits() private {
        require(prices.length != 0, "GoldenLama:: can not set!");
        uint256[30] memory _profits = profits;

        for(uint8 i; i < 30; ++i) {
            _profits[i] = prices[i] * 22 / 10;          
        }

        profits = _profits;
    }

    function _purchaselevelOneItem(uint8 _personageType) private {        
        uint256[30] memory _timestamps = userInfo[msg.sender].timestamps;

        require(
            (_personageType == 0 && _timestamps[0] == 0) || // Sand is always allowed
            (_personageType == 1 && _timestamps[1] == 0 && _timestamps[0] > 0) || // Sky requires Sand
            (_personageType == 2 && _timestamps[2] == 0 && _timestamps[0] > 0 && _timestamps[1] > 0) || // Sea requires Sand and Sky
            (_personageType == 3 && _timestamps[3] == 0 && _timestamps[0] > 0 && _timestamps[1] > 0 && _timestamps[2] > 0) || // Cloud requires Sand, Sky, and Sea
            (_personageType == 4 && _timestamps[4] == 0 && _timestamps[0] > 0 && _timestamps[1] > 0 && _timestamps[2] > 0 && _timestamps[3] > 0) || // Sun requires Sand, Sky, Sea, and Cloud
            (_personageType == 5 && _timestamps[5] == 0 && _timestamps[0] > 0 && _timestamps[1] > 0 && _timestamps[2] > 0 && _timestamps[3] > 0 && _timestamps[4] > 0) , // Gull requires Sand, Sky, Sea, Cloud and Sun
            "GoldenLama:: You must buy the previous items or you already purchased this item!"
        );

        // Update the corresponding timestamp       
        _timestamps[_personageType] = block.timestamp;

        userInfo[msg.sender].timestamps = _timestamps;

    }

    function _purchaselevelTwoItem(uint8 _personageType) private {        
        uint256[30] memory _timestamps = userInfo[msg.sender].timestamps;
        require(
            (_personageType == 6 && _timestamps[6] == 0) || // Palm is always allowed
            (_personageType == 7 && _timestamps[7] == 0 && _timestamps[6] > 0) || // Coconut requires Palm
            (_personageType == 8 && _timestamps[8] == 0 && _timestamps[6] > 0 && _timestamps[7] > 0) || // Fish requires Coconut and Palm
            (_personageType == 9 && _timestamps[9] == 0 && _timestamps[6] > 0 && _timestamps[7] > 0 && _timestamps[8] > 0) || // Crab requires Palm, Coconut and Fish
            (_personageType == 10 && _timestamps[10] == 0 && _timestamps[6] > 0 && _timestamps[7] > 0 && _timestamps[8] > 0 && _timestamps[9] > 0) || // Shells requires Palm, Coconut, Fish and Crab
            (_personageType == 11 && _timestamps[11] == 0 && _timestamps[6] > 0 && _timestamps[7] > 0 && _timestamps[8] > 0 && _timestamps[9] > 0 && _timestamps[10] > 0), // Stones requires Palm, Coconut, Fish, Crab and Shells
            "GoldenLama:: You must buy the previous items or you already purchased this item!"
        );

        // Update the corresponding timestamp
        _timestamps[_personageType] = block.timestamp;

        userInfo[msg.sender].timestamps = _timestamps;

    }

    function _purchaselevelThreeItem(uint8 _personageType) private {
        require(block.timestamp > startTimestamp + 11 days, "GoldenLama:: Third line items are not available yet!");
        
        uint256[30] memory _timestamps = userInfo[msg.sender].timestamps;

        require(
            (_personageType == 12 && _timestamps[12] == 0) || // Sand castel is always allowed
            (_personageType == 13 && _timestamps[13] == 0 && _timestamps[12] > 0) || // Chaise Lounge requires Sand Castel
            (_personageType == 14 && _timestamps[14] == 0 && _timestamps[12] > 0 && _timestamps[13] > 0) || // Towel requires Sand Castel and Chaise Lounge 
            (_personageType == 15 && _timestamps[15] == 0 && _timestamps[12] > 0 && _timestamps[13] > 0 && _timestamps[14] > 0) || // Sunscreen requires Sand Castel, Chaise Lounge and Towel
            (_personageType == 16 && _timestamps[16] == 0 && _timestamps[12] > 0 && _timestamps[13] > 0 && _timestamps[14] > 0 && _timestamps[15] > 0) || // Basket requires Sand Castel, Chaise Lounge, Towel and Sunscreen
            (_personageType == 17 && _timestamps[17] == 0 && _timestamps[12] > 0 && _timestamps[13] > 0 && _timestamps[14] > 0 && _timestamps[15] > 0 && _timestamps[16] > 0), // Umbrella requires Sand Castel, Chaise Lounge, Towel, Sunscreen and Basket 
            "GoldenLama:: You must buy the previous items or you already purchased this item!"
        );
        
        // Update the corresponding timestamp
        _timestamps[_personageType] = block.timestamp;

        userInfo[msg.sender].timestamps = _timestamps;
        
    }

    function _purchaselevelFourItem(uint8 _personageType) private {
        require(block.timestamp > startTimestamp + 21 days, "GoldenLama:: Fourth line items are not available yet!");

        uint256[30] memory _timestamps = userInfo[msg.sender].timestamps;

        require(
            (_personageType == 18 && _timestamps[18] == 0) || // Boa is always allowed
            (_personageType == 19 && _timestamps[19] == 0 && _timestamps[18] > 0) || // Sunglasses requires Boa
            (_personageType == 20 && _timestamps[20] == 0 && _timestamps[18] > 0 && _timestamps[19] > 0) || // Baseball Cap requires Boa and Sunglasses 
            (_personageType == 21 && _timestamps[21] == 0 && _timestamps[18] > 0 && _timestamps[19] > 0 && _timestamps[20] > 0) || // Swimsuit Top requires Boa, Sunglasses and Baseball Cap
            (_personageType == 22 && _timestamps[22] == 0 && _timestamps[18] > 0 && _timestamps[19] > 0 && _timestamps[20] > 0 && _timestamps[21] > 0) || // Swimsuit Briefs requires Boa, Sunglasses, Baseball Cap and Swimsuit Top
            (_personageType == 23 && _timestamps[23] == 0 && _timestamps[18] > 0 && _timestamps[19] > 0 && _timestamps[20] > 0 && _timestamps[21] > 0 && _timestamps[22] > 0), // Crocs requires Boa, Sunglasses, Baseball Cap, Swimsuit Top and Swimsuit Briefs 
            "GoldenLama:: You must buy the previous items or you already purchased this item!"
        );

        // Update the corresponding timestamp
        _timestamps[_personageType] = block.timestamp;

        userInfo[msg.sender].timestamps = _timestamps;

    }

    function _purchaselevelFiveItem(uint8 _personageType) private {
        require(block.timestamp > startTimestamp + 41 days, "GoldenLama:: Fifth line items are not available yet!");
       
        uint256[30] memory _timestamps = userInfo[msg.sender].timestamps;

        require(
            (_personageType == 24 && _timestamps[24] == 0) || //  Flamingo Ring is always allowed
            (_personageType == 25 && _timestamps[25] == 0 && _timestamps[24] > 0) || // Drink requires  Flamingo Ring
            (_personageType == 26 && _timestamps[26] == 0 && _timestamps[24] > 0 && _timestamps[25] > 0) || // Golden Color Cap requires  Flamingo Ring and Drink 
            (_personageType == 27 && _timestamps[27] == 0 && _timestamps[24] > 0 && _timestamps[25] > 0 && _timestamps[26] > 0) || // Swimsuit Top requires  Flamingo Ring, Drink and Golden Color Cap
            (_personageType == 28 && _timestamps[28] == 0 && _timestamps[24] > 0 && _timestamps[25] > 0 && _timestamps[26] > 0 && _timestamps[27] > 0) || // Smartphone requires  Flamingo Ring, Drink, Golden Color Cap and Swimsuit Top
            (_personageType == 29 && _timestamps[29] == 0 && _timestamps[24] > 0 && _timestamps[25] > 0 && _timestamps[26] > 0 && _timestamps[27] > 0 && _timestamps[28] > 0), // Yacht requires  Flamingo Ring, Drink, Golden Color Cap, Swimsuit Top and Smartphone 
            "GoldenLama:: You must buy the previous items or you already purchased this item!"
        );

        // Update the corresponding timestamp
        _timestamps[_personageType] = block.timestamp;

        userInfo[msg.sender].timestamps = _timestamps;

    }
}