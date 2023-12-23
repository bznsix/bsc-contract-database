// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "./BOBHelper.sol"; 
import "./Marketplace.sol";

contract BOBarena {

    struct Chest {
        uint256 BaseEther;
        uint256 revealBlock;
    }

    struct Items {
        uint256 itemType; //.1 Merge .2 SMerge //3. GCrystal
        uint256 mkt;
        bool exist;
        bool isBusy;  //marketiplace sellings
        address owner;
    }


    struct Hero {
        uint256 level;
        uint256 yield;
        uint256 baseEther;
        uint256 mkt;
        uint256 revealBlock;
        bool isBusy;
        bool isEvolving;
        bool isSafe;
        address owner;
    }


    struct Quest {
        uint256 heroId;
        uint256 startTime;
        uint256 checkPoint;
        uint256 revealBlock;
        bool isActive;
    }

    struct User {
        uint256 level;
        uint256 totDep;
        uint256 totEarned;
        uint256[] chestIDs;
        uint256[] itemIDs;
        uint256[] heroIDs;
        uint256 shards;

        mapping(uint256 => Chest) chests; // User's chests indexed by chestId
        mapping(uint256 => Items) items;   // User's items indexed by itemId
        mapping(uint256 => Hero) heroes;  // User's heroes indexed by heroId

    }

    mapping(address => Quest) public userQuests;
    mapping(address => User) public users;


    BOBHelper public Helper;
    Marketplace public market;

    uint256 public TOTAL_YIELD = 0;

    uint256 public nextheroID = 1;

    //itemID should never be 0 for green crystals to never cause issues
    uint256 public nextItemId = 1;

    uint256 public capRandom = 785;

    address public owner; 
    address public mkt; 
    uint256 public totDep;

    uint256 internal startDate = 1703260800; 
    uint256 internal fundslock = 250 days;

    bool public isPromoDay = false; 
    uint256 public promoPerc = 0;

    constructor(address _owner, address _mkt){
        Helper = new BOBHelper( capRandom, address(this));
        market = new Marketplace(address(this),_owner);
        owner = _owner;
        mkt = _mkt;
    }

     modifier hasStarted() {
            require(block.timestamp > startDate, "Not started yet");
            _;
        }

    event ChestPurchased(address indexed user, uint256 chestId, uint256 revealBlock);
    event ChestOpened(address indexed user, uint256 chestId, uint256 level, uint256 randomNumber);
    event HeroUpgraded(address indexed user, bool success, uint256 heroId, uint256 newLevel, uint256 newYield);
    event QuestFinished(address indexed user, uint256[] itemType, uint256 towithdraw);

    //CHESTS
    function buyChest(uint256 number, address user, address promocode) external payable hasStarted{
        require(users[msg.sender].chestIDs.length == 0, "Open your chests firsts");    

        //@dev user is used instead of msg.sender so users can gift chests
        require(number <= 10 && number > 0, "Max 10");
        require(msg.value / number >= 0.1 ether && msg.value / number <= 2 ether, "Min 0.1 max 2 BNB"); //0.05 one chest cost
        require(users[user].chestIDs.length + number <= 20, "You can own up to 20 chests only");    

        uint256 totprice = msg.value;
        if (isPromoDay && promocode != msg.sender && users[promocode].totDep >= 1 ether){
                totprice = totprice - (promoPerc * totprice / 100);
                payable(promocode).transfer(totprice * 3 / 100 );
                payable(msg.sender).transfer((promoPerc - 3) * totprice / 100);
        } 

        if (users[user].level == 0){
            users[user].level = 1;
        }

            addChest(user,number,msg.value / number);
            payable(owner).transfer(totprice * 7 / 100 );
            payable(mkt).transfer(totprice / 100 );
            users[user].totDep += totprice;
            totDep += totprice;
        }
            
    function addChest(address user, uint256 number, uint256 basePrice ) internal{
        for (uint256 i = 0; i < number; i++) {

            Chest memory newChest = Chest({
                BaseEther: basePrice,
                revealBlock: block.number + 1
            });

            users[user].chests[nextheroID] = newChest;
            users[msg.sender].chestIDs.push(nextheroID); 
            nextheroID += 1;   

            emit ChestPurchased(msg.sender, nextheroID, newChest.revealBlock);
        }
    }

   function openChest(uint256 number) external {
        uint256 lastchest = users[msg.sender].chestIDs[number - 1];
        require(block.number >= users[msg.sender].chests[lastchest].revealBlock, "Too early");
        require(users[msg.sender].heroIDs.length + number <= 20, "You can own up to 20 heroes only");    

        require(number > 0 && number <= 10 , "Too many chests selected would lead to gas failure");

        for (uint256 i = 0; i < number; i++) {
            uint256 firstChestID = users[msg.sender].chestIDs[0];
            Chest storage chest = users[msg.sender].chests[firstChestID];

            require(block.number > chest.revealBlock, "Wait for the reveal block!");
            uint256 randomNumber;
            randomNumber = uint256(keccak256(abi.encodePacked(blockhash(chest.revealBlock), msg.sender, firstChestID, i))) % (capRandom + 1);

            uint256 level = generateHero(randomNumber , firstChestID , chest.BaseEther);

            uint256 lastChestIndex = users[msg.sender].chestIDs.length - 1;
           
            users[msg.sender].chestIDs[0] = users[msg.sender].chestIDs[lastChestIndex];
            users[msg.sender].chestIDs.pop();
            delete users[msg.sender].chests[firstChestID];
            emit ChestOpened(msg.sender, firstChestID, level , randomNumber);
        }
    }

        //HEROES
        function initiateHeroUpgrade(uint256 heroId) external payable hasStarted{
            checkHeroElegible(msg.sender,heroId);
            Hero storage hero = users[msg.sender].heroes[heroId];

            if (hero.isSafe){
                require (msg.value == users[msg.sender].heroes[heroId].yield / 8,"Not the right amount");
            } else {
                require (msg.value == users[msg.sender].heroes[heroId].yield / 4,"Not the right amount");
            }
            
            hero.isEvolving = true;
            hero.revealBlock = block.number + 1;
        }


        function executeHeroUpgrade(uint256 heroId) external {
            Hero storage hero = users[msg.sender].heroes[heroId];
            require(hero.isEvolving, "Hero is not in the upgrade process.");
            require(hero.owner == msg.sender, "You do not own this hero.");

            hero.isEvolving = false;

            require(block.number > hero.revealBlock && hero.revealBlock != 0, "Invalid Block!");
            uint256 randomNumber = uint256(keccak256(abi.encodePacked(blockhash(hero.revealBlock), msg.sender, heroId))) % (capRandom + 1);

            //uint256 randomNumber = uint256(keccak256(abi.encodePacked( msg.sender, heroId))) % (capRandom + 1);
            uint256 probability = Helper.executeHeroUpgrade(hero.level, randomNumber);
            bool success = false;

            if (probability != 0){
                uint256 yield = Helper.getYield(probability,hero.baseEther);
                TOTAL_YIELD += (yield - hero.yield);
                hero.level += 1;
                hero.yield = yield;
                success = true;
            } else if (!hero.isSafe){
                TOTAL_YIELD -= hero.yield;
                users[msg.sender].shards += 1;
                removeHeroId(heroId, msg.sender);
                delete users[msg.sender].heroes[heroId];  
            } else {
                hero.isSafe = false;                
            }
            emit HeroUpgraded(msg.sender, success , heroId, hero.level, hero.yield);
        }


    function generateHero(uint256 number, uint256 firstChestID, uint256 baseEther) internal returns(uint256){
            (uint256 level, uint256 yield) = Helper.generateHero(number, baseEther);

            Hero memory newHero = Hero({
                level: level,
                yield: yield,
                baseEther: baseEther,
                mkt: 0,
                revealBlock : 0,
                isBusy: false,
                isEvolving: false,
                isSafe: false,
                owner: msg.sender
            });
        TOTAL_YIELD += yield;
        users[msg.sender].heroes[firstChestID] = newHero;
        users[msg.sender].heroIDs.push(firstChestID); 

        return level;
    }

    //QUESTS
    function startQuest(uint256 heroId) external hasStarted{
        Quest storage quest = userQuests[msg.sender];
        require(!quest.isActive, "You already have an active quest.");
        //require check yield
        checkHeroElegible(msg.sender,heroId);

        //@dev the lev system prevents users to withdraw too early in case of a big hero drop
        if (users[msg.sender].heroes[heroId].level >= 7 ){
            require(users[msg.sender].level == 4,"You level is too low to use this hero");
        } else if (users[msg.sender].heroes[heroId].level == 6 ){
            require(users[msg.sender].level >= 3,"You level is too low to use this hero");
        } else if (users[msg.sender].heroes[heroId].level == 5 ){
            require(users[msg.sender].level >= 2,"You level is too low to use this hero");
        }
        users[msg.sender].heroes[heroId].isBusy = true;
        userQuests[msg.sender] = Quest(heroId, block.timestamp,block.timestamp,block.number + 1, true);
    }

    function stopQuest() external {
        Quest storage quest = userQuests[msg.sender];

        require(quest.isActive, "You do not have any active quest");
        require(block.timestamp <= quest.startTime + 5 days, "Quest has finished."); 

        users[msg.sender].heroes[quest.heroId].isBusy = false;
        userQuests[msg.sender] = Quest(0, 0, 0, 0, false); 
    }


    function finishQuest() external returns (uint256){
        Quest memory quest = userQuests[msg.sender];
        require(quest.isActive, "You have no active quest.");
        require(block.timestamp >= quest.startTime + 5 days, "Quest is not finished yet."); 

        Hero memory hero = users[msg.sender].heroes[quest.heroId];
        uint256 towithdraw = hero.yield;

        uint256 randomNumber = uint256(keccak256(abi.encodePacked(blockhash(quest.revealBlock), msg.sender, quest.heroId))) % (101);
        uint256[] memory itemTypes = Helper.drawItem(hero.level, randomNumber , quest.revealBlock);

        userQuests[msg.sender] = Quest(0, 0, 0, 0, false); 

        if (users[msg.sender].level < 4){
            users[msg.sender].level += 1;
        }
        removeHeroId(quest.heroId, msg.sender);
        delete users[msg.sender].heroes[quest.heroId];   

        //@dev create a shard
        users[msg.sender].shards += 1;

        uint256 contractBalance = address(this).balance;
        bool isNerf;
        contractBalance <= towithdraw ? isNerf = true : isNerf = false;

        //@dev Safe dynamic to prevent an early runout of tvl
        if (isNerf){
            if (contractBalance <= towithdraw / 2){
                towithdraw = contractBalance /2;
            } else {
                towithdraw = towithdraw / 2;
                }
            }

        payable(msg.sender).transfer(towithdraw);

        if (itemTypes.length != 0){
            createItems(itemTypes);
            }
        users[msg.sender].totEarned += towithdraw;
        TOTAL_YIELD -= towithdraw;
        emit QuestFinished(msg.sender, itemTypes ,towithdraw);
        return quest.heroId;
    }


    
    //ITEMS
    //@dev 0 will return into a non super chest being created, other numbers will instead create a new item
    function createItems(uint256[] memory itemType) internal {
        for (uint256 i = 0; i < itemType.length; i++) {
            if (itemType[i] == 0){
                Chest memory newChest = Chest({
                    BaseEther: 0.2 ether,
                    revealBlock: block.number + 1
                });
                users[msg.sender].chests[nextheroID] = newChest;  
                users[msg.sender].chestIDs.push(nextheroID); 
                nextheroID += 1;
            } else {
                nextItemId++;
                users[msg.sender].items[nextItemId] = Items(itemType[i], 0,true, false, msg.sender);
                users[msg.sender].itemIDs.push(nextItemId); 
                }
            }
        }

    function useMerge( uint256 mergeID) external {
            require(users[msg.sender].shards >= 2, "Not enough shards");
            require(users[msg.sender].items[mergeID].owner == msg.sender, "You do not own this item");
            require(users[msg.sender].items[mergeID].itemType == 1, "You do not own this item");
            require(users[msg.sender].items[mergeID].isBusy == false, "item is busy");

            users[msg.sender].shards -= 2;
                    Chest memory newChest = Chest({
                                BaseEther: 0.2 ether,
                                revealBlock: block.number + 1
                            });
            users[msg.sender].chests[nextheroID] = newChest;  
            users[msg.sender].chestIDs.push(nextheroID); 
            nextheroID += 1;
            removeItemId(mergeID , msg.sender);
            delete users[msg.sender].items[mergeID];
        }

    function useSuperMerge( uint256 mergeID) external {
            require(users[msg.sender].shards >= 3, "Not enough shards");
            require(users[msg.sender].items[mergeID].owner == msg.sender, "You do not own this item");
            require(users[msg.sender].items[mergeID].itemType == 2, "You do not own this item");
            require(users[msg.sender].items[mergeID].isBusy == false, "item is busy");

            users[msg.sender].shards -= 3;
                    Chest memory newChest = Chest({
                                BaseEther: 0.4 ether,
                                revealBlock: block.number + 1
                            });
            users[msg.sender].chests[nextheroID] = newChest;  
            users[msg.sender].chestIDs.push(nextheroID); 
            nextheroID += 1;
            removeItemId(mergeID , msg.sender);
            delete users[msg.sender].items[mergeID];
        }
    
    function useGcrystal(uint256 greencrystalID, uint256 heroId) external {
            Hero storage hero = users[msg.sender].heroes[heroId];
            checkHeroElegible(msg.sender,heroId);
            require(greencrystalID > 0 , "cannot be ID 0");
            require(users[msg.sender].items[greencrystalID].owner == msg.sender, "You do not own this item");
            require(users[msg.sender].items[greencrystalID].itemType == 3, "Wrong Type");
            require(users[msg.sender].items[greencrystalID].isBusy == false, "item is busy");

            hero.isSafe = true;
            removeItemId(greencrystalID , msg.sender);
            delete users[msg.sender].items[greencrystalID];
        }



    //TRIMMERS
    function removeHeroId(uint256 _id, address user) internal {
        uint256[] storage heroArray = users[user].heroIDs;
        for (uint256 i = 0; i < heroArray.length; i++) {
            if (heroArray[i] == _id) {
                heroArray[i] = heroArray[heroArray.length - 1];
                heroArray.pop();
                break;
            }
        }
    }

    function removeItemId(uint256 _id, address user) internal {
        uint256[] storage itemArray = users[user].itemIDs;
        for (uint256 i = 0; i < itemArray.length; i++) {
            if (itemArray[i] == _id) {
                itemArray[i] = itemArray[itemArray.length - 1];
                itemArray.pop();
                break;
            }
        }
    }

    function checkHeroElegible(address user, uint256 ID) internal view{
        Hero storage hero = users[user].heroes[ID];
        require(hero.owner == msg.sender, "You are not the owner."); 
        require(!hero.isBusy, "Hero is already busy."); 
        require(hero.mkt == 0, "This hero has been used already"); 
        require(!hero.isEvolving, "Hero is evolving.");
    }

    //MARKETPLACE
    function listHero(uint256 _id, uint256 price) external hasStarted {
        checkHeroElegible(msg.sender,_id);
        users[msg.sender].heroes[_id].isBusy = true;
        uint256 mktID = market.listHero( _id, price, msg.sender);
        users[msg.sender].heroes[_id].mkt = mktID;
    }

    function listItem(uint256 _id, uint256 price) external {
        require(users[msg.sender].items[_id].isBusy == false, "You cannot sell this item");
        require(users[msg.sender].items[_id].mkt == 0, "Already Selling");
        require(users[msg.sender].items[_id].owner == msg.sender, "You do not own this");
        uint256 mktID = market.listItem( _id, price, msg.sender);
        users[msg.sender].items[_id].mkt = mktID;
        users[msg.sender].items[_id].isBusy = true;
    }

    function buyHero(uint256 _mktid) external payable {
        (address oldowner,uint256 id) = market.buyHero{value: msg.value}(_mktid);
        uint256 mktID = users[oldowner].heroes[id].mkt;
        require(mktID != 0, "item is not for sale");
        require(users[msg.sender].level > 0,"You level is too low to use the marketplace");

        users[msg.sender].heroes[id] = users[oldowner].heroes[id];
        users[msg.sender].heroes[id].isBusy = false;
        users[msg.sender].heroes[id].owner = msg.sender;
        users[msg.sender].heroes[id].mkt = 0;

        users[msg.sender].heroIDs.push(id);
        removeHeroId(id, oldowner);
        delete users[oldowner].heroes[id];
    }


    function buyItem(uint256 _mktid) external payable {
        (address oldowner,uint256 id) = market.buyItem{value: msg.value}(_mktid);
        require(users[oldowner].items[id].mkt != 0,"item is not for sale");
        require(users[oldowner].items[id].owner == oldowner,"item does not exist");
        require(users[msg.sender].level > 0,"You level is too low to use the marketplace");

        users[msg.sender].items[id] = users[oldowner].items[id];
        users[msg.sender].items[id].isBusy = false;
        users[msg.sender].items[id].owner = msg.sender;
        users[msg.sender].items[id].mkt = 0;

        users[msg.sender].itemIDs.push(id);
        removeItemId(id, oldowner);
        delete users[oldowner].items[id];  

    }

    function delistHero(uint256 _mktid) external {
        uint256 ID = market.removeHeroListing(_mktid, msg.sender);
        require(users[msg.sender].heroes[ID].owner == msg.sender,"you are not the owner");
        require(users[msg.sender].heroes[ID].mkt != 0,"not listed");

        users[msg.sender].heroes[ID].mkt = 0;
        users[msg.sender].heroes[ID].isBusy = false;
    }

    function delistItem(uint256 _itemmktid) external {
        uint256 ID = market.removeItemListing(_itemmktid, msg.sender);
        require(users[msg.sender].items[ID].owner == msg.sender,"you are not the owner");
        require(users[msg.sender].items[ID].mkt != 0,"not listed");

        users[msg.sender].items[ID].mkt = 0;
        users[msg.sender].items[ID].isBusy = false;
    }

    //PROMO CODES
    function activatePromo(bool isPromo , uint256 _perc) external {
            require(msg.sender == owner, "Only owner");
            if (isPromo){
                require(_perc > 0 && _perc <= 20, "Wrong value");
            }
            isPromoDay = isPromo;
            promoPerc = _perc;
        }

    //IMPORTANT: SAFELOCK 
    //@dev After 9 months fund are unlocked, this might be useful in case of users funds need to be moved, to migrate over a new contract, expand the game or emergency use
    function SafeLock() external {
            require(msg.sender == owner, "Only owner");
            require(block.timestamp > startDate + fundslock);
            uint256 contractBalance = address(this).balance;
            payable(owner).transfer(contractBalance);
        }
    
    //@dev owner can decide no further development will be needed and renounce
    function changeTeam(address _owner, address _mkt) external {
            require(msg.sender == owner);
            owner = _owner;
            mkt = _mkt;
        }

    //@dev lock can be extended at any time
    function Extend(uint256 newtime) external {
            require(newtime > fundslock, "Only more than initial value");
            require(msg.sender == owner, "Only owner");
            fundslock = newtime;
        }
        

    //UI CALLS

    function getPromo() external view returns (bool,uint256) {
        return (isPromoDay,promoPerc);
    }

    function getUpgradeprice(address user, uint256 heroId) external view returns (uint256,uint256) {
        return (users[user].heroes[heroId].yield / 4, users[user].heroes[heroId].yield / 8);
    }

    function getUserInfo(address userAddress) external view returns (uint256,uint256) {
        return (users[userAddress].totDep,users[userAddress].totEarned);
    }

     function getUserChestsIDs(address userAddress) external view returns (uint256[] memory) {
        return (users[userAddress].chestIDs);
    }

    function getUserHeroIDs(address userAddress) external view returns (uint256[] memory) {
        return (users[userAddress].heroIDs);
    }

    function getUserItemIDs(address userAddress) external view returns (uint256[] memory) {
        return users[userAddress].itemIDs;
    }

    function getUserChestbyID( address user, uint256 id) public view returns (Chest memory) {
            return users[user].chests[id];    
    }

    function getUserItemByID(address user, uint256 id) public view returns (Items memory) {
        return users[user].items[id];
    }


    function getUserHeroByID(address user, uint256 id) public view returns (Hero memory) {
        return users[user].heroes[id];
    }



    receive() external payable { }

}// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

contract Marketplace {

    struct Mkt {
        uint256 mktid;
        uint256 id;
        uint256 price; 
        uint256 date; 
        address owner;
    }

    struct MktItem {
        uint256 mktid;
        uint256 id;
        uint256 price; 
        uint256 date; 
        address owner;
    }

    struct itemperUser {
        uint256[] allIDs;
    }

    struct heroperUser {
        uint256[] allIDs;
    }

    mapping(address => itemperUser) internal numItems;
    mapping(address => heroperUser) internal numHeroes;

    mapping(uint256 => Mkt) public marketId;
    mapping(uint256 => MktItem) public itemId;

    address public mainBOB;
    address public owner;


    //IDs 0 are reserved for not selling heroes in BOBchain contract
    uint256 public heroes_IDs = 1;
    uint256 public items_IDs = 1;
    uint256 public totVolume;
    uint256 public itemsSold;


    constructor(address _mainBOB, address _owner) {
        mainBOB = _mainBOB;
        owner = _owner;
    }

    modifier onlyContract() {
            require(msg.sender == mainBOB, "Caller is not the BOBChain contract");
            _;
        }

    

    function listHero(uint256 _id, uint256 price, address user) external onlyContract returns(uint256){
        require(numHeroes[user].allIDs.length < 5, "max 4 listings per user");
        require(price >= 0.001 ether && price <= 1000 ether, "Enter a valid price");

        uint256 currentID = heroes_IDs;
        numHeroes[user].allIDs.push(heroes_IDs);
        marketId[heroes_IDs] = Mkt(heroes_IDs, _id, price, block.timestamp ,user);
        heroes_IDs++;
        return currentID;
    }

    function listItem(uint256 _id, uint256 price, address user) external onlyContract returns(uint256){
        require(numItems[user].allIDs.length < 5, "max 4 listings per user");
        require(price >= 0.001 ether && price <= 1000 ether, "Enter a valid price");
        uint256 currentID = items_IDs;
        numItems[user].allIDs.push(items_IDs);
        itemId[items_IDs] = MktItem(items_IDs, _id, price, block.timestamp ,user);
        items_IDs++;
        return currentID;
    }


    function buyHero(uint256 mkt_id) external payable onlyContract returns(address,uint256){
        Mkt storage mkt = marketId[mkt_id];

        require(msg.value == mkt.price,"send the right amount");
        require(mkt.id != 0,"Item was possibly sold");

        totVolume += msg.value;
        itemsSold += 1;
        uint256 idretrieved = mkt.id;
        address oldowner = mkt.owner;

        payTaxes(msg.value , oldowner);
        delete marketId[mkt_id];
        removeIdFromUserArray(mkt_id, numHeroes[oldowner].allIDs);

        return (oldowner,idretrieved);
    }

     function buyItem(uint256 mkt_id) external payable onlyContract returns(address,uint256){
        MktItem storage mktI = itemId[mkt_id];
        require(msg.value == mktI.price);
        require(mktI.id != 0,"Item was possibly sold");
        
        totVolume += msg.value;
        itemsSold += 1;
        uint256 idretrieved = mktI.id;

        address oldowner = mktI.owner;

        payTaxes(msg.value , oldowner);
        delete itemId[mkt_id];
        removeIdFromUserArray(mkt_id, numItems[oldowner].allIDs);

        return (oldowner,idretrieved);
    }

    function payTaxes(uint256 _amount , address _oldowner) internal{
        
        uint256 tax = _amount* 8 / 100;
        payable(_oldowner).transfer(_amount - tax);
        //50% tax to owner and 50% back to the contract
        payable(owner).transfer(_amount* 3 / 100); 
        payable(mainBOB).transfer(_amount* 5 / 100); 
        
    }

    function removeHeroListing(uint256 heroId, address user) external onlyContract returns(uint256){
        require(marketId[heroId].owner == user, "Caller is not the owner");
        require(numHeroes[user].allIDs.length > 0);
        uint256 IDdeleted = marketId[heroId].id;

        // Delete the hero from the marketId mapping
        delete marketId[heroId];

        // Remove the hero ID from the user's array
        removeIdFromUserArray(heroId, numHeroes[user].allIDs);
        return IDdeleted;
    }

    function removeItemListing(uint256 itemID, address user) external onlyContract returns(uint256){
        require(itemId[itemID].owner == user, "Caller is not the owner");
        require(numItems[user].allIDs.length > 0, "No items to remove");
        uint256 IDdeleted = itemId[itemID].id;
        // Delete the item from the itemId mapping
        delete itemId[itemID];

        // Remove the item ID from the user's array
        removeIdFromUserArray(itemID, numItems[user].allIDs);
        return IDdeleted;
    }


    function removeIdFromUserArray(uint256 id, uint256[] storage userArray) internal {
        uint256 length = userArray.length;
        for (uint256 i = 0; i < length; i++) {
            if (userArray[i] == id) {
                userArray[i] = userArray[length - 1];
                userArray.pop();
                break;
            }
        }
    }

    function getItemsInRange(uint256 start, uint256 end) external view returns (MktItem[] memory) {
        require(start <= end, "Invalid range");
        require(end < items_IDs, "Range exceeds total items");

        uint256 rangeSize = end - start + 1;
        MktItem[] memory items = new MktItem[](rangeSize);

        for (uint256 i = 0; i < rangeSize; i++) {
            uint256 currentId = start + i;
            items[i] = itemId[currentId];
        }

        return items;
    }

    function getHeroesInRange(uint256 start, uint256 end) external view returns (Mkt[] memory) {
        require(start <= end, "Invalid range");
        require(end < heroes_IDs, "Range exceeds total heroes");

        uint256 rangeSize = end - start + 1;
        Mkt[] memory heroes = new Mkt[](rangeSize);

        for (uint256 i = 0; i < rangeSize; i++) {
            uint256 currentId = start + i;
            heroes[i] = marketId[currentId];
        }

        return heroes;
    }


    function getnumHeroes() external view returns (uint256) {
        return heroes_IDs - 1;
    }

    function getmkt() external view returns (uint256,uint256) {
        return (totVolume,itemsSold);
    }

    function getnumItems() external view returns (uint256) {
        return items_IDs - 1;
    }

    function viewAllHeroIdsOfUser(address user) external view returns (uint256[] memory) {
        return numHeroes[user].allIDs;
    }

    function viewAllitemIdsOfUser(address user) external view returns (uint256[] memory) {
        return numItems[user].allIDs;
    }








}// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract BOBHelper {

    uint256 public capRandom;
    address public mainBOB;

    constructor( uint256 _capRandom, address _mainBOB) {
        capRandom = _capRandom;
        mainBOB = _mainBOB;
    }

    modifier onlyContract() {
            require(msg.sender == mainBOB, "Caller is not the BOBChain contract");
            _;
        }

    function getYield(uint256 probability,uint256 baseYield) public view returns (uint256) {
        
        require(probability > 0, "Probability cannot be zero");
        return (baseYield * capRandom) / probability / 3;
    }

    function generateHero(uint256 number, uint256 baseYield) public view returns(uint256,uint256){
        uint256 level;
        uint256 probability;
        uint256 yield;

        if (number <= 390) {
            level = 1;
            probability = 750;
        } else if (number <= 550) { 
            level = 2;
            probability = 240;
        } else if (number <= 680) {  
            level = 3;
            probability = 140;
        } else if (number <= 720) {
            level = 4;
            probability = 90;
        } else if (number <= 770) {
            level = 5;
            probability = 60;
        } else if (number <= 785) {
            level = 6;
            probability = 40;
        } 

        yield = getYield(probability,baseYield);

        return (level,yield);
    }

    function executeHeroUpgrade(uint256 level , uint256 randomNumber) public pure returns(uint256) {
            
            uint256 probability;

             if (randomNumber <= 460 && level == 1) {
                probability = 240;
            } else if (randomNumber <= 392 && level == 2) {
                probability = 140;
            } else if (randomNumber <= 380 && level == 3) {
                probability = 90;
            } else if (randomNumber <= 360 && level == 4) {
                probability = 60;
            } else if (randomNumber <= 340 && level == 5) {
                probability = 40;
            } else if (randomNumber <= 250 && level == 6) {
                probability = 20;
            } else if (randomNumber <= 200 && level == 7) {
                probability = 12;
            } else {
                probability = 0;
            } 
            return probability;
        }

        
        function drawItem(uint256 level, uint256 randomNumber, uint256 Iblock) external view returns (uint256[] memory) {
            uint256 itemQuantity = (uint256(keccak256(abi.encodePacked(Iblock, randomNumber, msg.sender))) % (level + 1)); // 0 to level
            uint256[] memory itemTypes;
            if (itemQuantity > 0) {
                //@dev can return an array of n numbers up to the level of the hero, will return empty string in case of no items found
                itemTypes = new uint256[](itemQuantity);

                for (uint256 i = 0; i < itemQuantity; i++) {
                    uint256 itemType = (uint256(keccak256(abi.encodePacked(randomNumber, msg.sender, i))) % 4); // 0 to 3
                    itemTypes[i] = itemType;
                }
            }

            return itemTypes;
        }




}