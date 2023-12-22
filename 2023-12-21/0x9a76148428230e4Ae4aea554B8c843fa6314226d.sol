// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
/*
 * 
 * ██████╗░██╗███████╗███████╗░█████╗░  ██████╗░██████╗░██╗░█████╗░██╗░░██╗
 * ██╔══██╗██║╚════██║╚════██║██╔══██╗  ██╔══██╗██╔══██╗██║██╔══██╗██║░██╔╝
 * ██████╔╝██║░░███╔═╝░░███╔═╝███████║  ██████╦╝██████╔╝██║██║░░╚═╝█████═╝░
 * ██╔═══╝░██║██╔══╝░░██╔══╝░░██╔══██║  ██╔══██╗██╔══██╗██║██║░░██╗██╔═██╗░
 * ██║░░░░░██║███████╗███████╗██║░░██║  ██████╦╝██║░░██║██║╚█████╔╝██║░╚██╗
 * ╚═╝░░░░░╚═╝╚══════╝╚══════╝╚═╝░░╚═╝  ╚═════╝░╚═╝░░╚═╝╚═╝░╚════╝░╚═╝░░╚═╝
 *
 *  ___ _ __ ___   __ _ _ __| |_    ___ ___  _ __ | |_ _ __ __ _  ___| |_
 * / __| '_ ` _ \ / _` | '__| __|  / __/ _ \| '_ \| __| '__/ _` |/ __| __|
 * \__ \ | | | | | (_| | |  | |_  | (_| (_) | | | | |_| | | (_| | (__| |_
 * |___/_| |_| |_|\__,_|_|   \__|  \___\___/|_| |_|\__|_|  \__,_|\___|\__|
 *
 *
 * Welcome to the exciting world of "Pizza Brick"!
 *
 * Here, every participant can dive into the investment excitement by purchasing bricks with BNB, the in-game currency.
 * These bricks pave the way to acquiring pizzerias that generate pizza as income.
 *
 * And then, you can exchange the pizza for BNB, increasing your profits.
 * 
 * But that's not all!
 * 
 * In "Pizza Brick," exciting gaming features are available, adding extra fun and a chance to boost your earnings.
 * Players have the opportunity to participate in a lottery and a 1 vs 1 arena, where two participants battle for victory using a random order.
 * 
 * The smart contract announces the winner, who takes the prize.
 * 
 * Lottery rooms, created by participants, allow the next players to join and share the winnings among themselves.
 * 
 * Manage your investments, engage in thrilling gambling games, and grow your pizzerias, turning bricks into prosperity!
 *
 *
 * JOIN US ON TWITTER: https://twitter.com/PizzaBrickk
 *
 *
 * Web: https://pizzabrick.io/
 *
 *
*/

abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}

contract PizzaBrick is ReentrancyGuard{
    struct OvenConfig {
        uint8 stage;
        uint256 maxHours;
        uint256 price;
    }

    struct CookingSpeedConfig{
        uint8 stage;
        uint8 bonusPercent;
        uint256 price;
    }

    struct PizzeriaConfig{
        uint8 stage;
        uint256 pizzaPerHour;
        uint256 price;
    }

    struct User {
        uint256 pizza;
        uint256 bricks;
        uint256 fridgePizza;
        address partner;
        uint256 refsDeps;
        uint256 refsTotal;
        CookingSpeedConfig cookingSpeed;
        PizzeriaConfig[8] pizzerias;
        OvenConfig oven;
        uint256 hrsFarm;
        uint256 lastOvenSync;
    }
    
    struct Duels {
        uint256 totalGames;
        uint256 wins;
        uint256 loses;
    }

    struct CulinaryDuel {
        address player1;
        address player2;
        uint256 bricks;
        uint256 timestamp;
        address winner;
        uint256 roll;
    }

    struct Lotteries {
        uint256 totalGames;
        uint256 wins;
        uint256 loses;
    }

    struct ActiveLottery {
        uint256 ticketPrice;
        uint256 participantsCount;
        address[] participants;
    }

    uint256 constant FEE_PERCENT = 6;
    uint256 constant REFERRAL_BRICKS_PERCENT = 7;
    uint256 constant REFERRAL_PIZZA_PERCENT = 3;
    uint256 constant BRICKS_PER_PIZZA = 100;
    uint256 constant MAX_ACTIVE_LOTTERIES = 10;

    address public owner = 0x8c23B6FF39A8C33c2725b540403AC3768E95FD79;
    address public manager =0x6B53F45F9c0D71ca054AcC2bdDEB48AFfAaC7462;
    address public manager2 = 0x7300b977659B20C51d0082D5370771A829a64628;
    uint256 public totalInvested;
    uint256 public totalInvestors;
    uint256 public activeLotteryCount;
    uint256 private pizzeriasSold;
    uint256 private lastPeriodStart;

    mapping(uint256 => mapping(uint256 => PizzeriaConfig)) public pizzeriasConfig;
    CookingSpeedConfig[5] public cookingSpeedConfig;
    OvenConfig[8] public ovensConfig;

    mapping(address => User) public users;
    mapping(address => Duels) public duels;
    mapping(address => Lotteries) public lotteries;
    
    mapping(uint256 => address) public waitingDuels;
    mapping(address => mapping(uint256 => CulinaryDuel)) public culinaryDuels;
    mapping(uint256 => mapping(uint256 => address[])) public waitingLottery;

    uint256[7] ticketsPrice = [100, 300, 500, 1000, 2000, 5000, 10000];
    uint256[6] maxParticipants = [10, 20, 30, 40, 50];

    constructor() {
        lastPeriodStart = block.timestamp;

        cookingSpeedConfig[0] = CookingSpeedConfig(1, 10, 5000);
        cookingSpeedConfig[1] = CookingSpeedConfig(2, 20, 7500);
        cookingSpeedConfig[2] = CookingSpeedConfig(3, 30, 10000);
        cookingSpeedConfig[3] = CookingSpeedConfig(4, 40, 12500);
        cookingSpeedConfig[4] = CookingSpeedConfig(5, 50, 15000);

        ovensConfig[0] = OvenConfig(1, 24, 0);
        ovensConfig[1] = OvenConfig(2, 30, 1000);
        ovensConfig[2] = OvenConfig(3, 36, 3000);
        ovensConfig[3] = OvenConfig(4, 42, 5000);
        ovensConfig[4] = OvenConfig(5, 48, 6000);

        pizzeriasConfig[0][0] = PizzeriaConfig(1, 20, 250);
        pizzeriasConfig[0][1] = PizzeriaConfig(2, 45, 315);
        pizzeriasConfig[0][2] = PizzeriaConfig(3, 80, 390);
        pizzeriasConfig[0][3] = PizzeriaConfig(4, 120, 485);
        pizzeriasConfig[0][4] = PizzeriaConfig(5, 175, 600);

        pizzeriasConfig[1][0] = PizzeriaConfig(1, 65, 750);
        pizzeriasConfig[1][1] = PizzeriaConfig(2, 145, 900);
        pizzeriasConfig[1][2] = PizzeriaConfig(3, 245, 1150);
        pizzeriasConfig[1][3] = PizzeriaConfig(4, 375, 1500);
        pizzeriasConfig[1][4] = PizzeriaConfig(5, 535, 1800);

        pizzeriasConfig[2][0] = PizzeriaConfig(1, 200, 2250);
        pizzeriasConfig[2][1] = PizzeriaConfig(2, 450, 2800);
        pizzeriasConfig[2][2] = PizzeriaConfig(3, 760, 3500);
        pizzeriasConfig[2][3] = PizzeriaConfig(4, 1150, 4350);
        pizzeriasConfig[2][4] = PizzeriaConfig(5, 1650, 5500);

        pizzeriasConfig[3][0] = PizzeriaConfig(1, 610, 6750);
        pizzeriasConfig[3][1] = PizzeriaConfig(2, 1375, 8400);
        pizzeriasConfig[3][2] = PizzeriaConfig(3, 2335, 10500);
        pizzeriasConfig[3][3] = PizzeriaConfig(4, 3525, 13000);
        pizzeriasConfig[3][4] = PizzeriaConfig(5, 5050, 16500);

        pizzeriasConfig[4][0] = PizzeriaConfig(1, 1875, 20250);
        pizzeriasConfig[4][1] = PizzeriaConfig(2, 4225, 25300);
        pizzeriasConfig[4][2] = PizzeriaConfig(3, 7175, 31500);
        pizzeriasConfig[4][3] = PizzeriaConfig(4, 10875, 39500);
        pizzeriasConfig[4][4] = PizzeriaConfig(5, 15525, 49000);

        pizzeriasConfig[5][0] = PizzeriaConfig(1, 5700, 60000);
        pizzeriasConfig[5][1] = PizzeriaConfig(2, 12850, 75000);
        pizzeriasConfig[5][2] = PizzeriaConfig(3, 21800, 93500);
        pizzeriasConfig[5][3] = PizzeriaConfig(4, 33150, 117500);
        pizzeriasConfig[5][4] = PizzeriaConfig(5, 47500, 146500);

        pizzeriasConfig[6][0] = PizzeriaConfig(1, 18100, 182500);
        pizzeriasConfig[6][1] = PizzeriaConfig(2, 40850, 228000);
        pizzeriasConfig[6][2] = PizzeriaConfig(3, 69450, 285000);
        pizzeriasConfig[6][3] = PizzeriaConfig(4, 90700, 356500);
        pizzeriasConfig[6][4] = PizzeriaConfig(5, 136450, 445000);

        pizzeriasConfig[7][0] = PizzeriaConfig(1, 52000, 500000);
        pizzeriasConfig[7][1] = PizzeriaConfig(2, 115250, 600000);
        pizzeriasConfig[7][2] = PizzeriaConfig(3, 198750, 780000);
        pizzeriasConfig[7][3] = PizzeriaConfig(4, 307000, 1000000);
        pizzeriasConfig[7][4] = PizzeriaConfig(5, 444500, 1250000);
    }

    function buyBricks(address partner) external payable nonReentrant{
        uint256 bricks = msg.value / 4e13;
        require(bricks >= 1, "Zero bricks");

        totalInvested += msg.value;

        if (users[msg.sender].lastOvenSync == 0){
            totalInvestors += 1;
            partner = users[partner].lastOvenSync == 0 ? address(0) : partner;
            users[partner].refsTotal++;
            users[msg.sender].partner = partner;
            users[msg.sender].oven = ovensConfig[0];
            users[msg.sender].hrsFarm = 0;
            users[msg.sender].lastOvenSync = block.timestamp;
        }

        partner = users[msg.sender].partner;
        uint256 referralBricks = (bricks * REFERRAL_BRICKS_PERCENT) / 100;
        uint256 referralPizza = (bricks * BRICKS_PER_PIZZA * REFERRAL_PIZZA_PERCENT) / 100;

        if (partner != address(0)){
            users[partner].bricks += referralBricks; 
            users[partner].pizza += referralPizza;
            users[partner].refsDeps += referralBricks; 
        }
        else{
            // FEE
            users[owner].bricks += referralBricks / 2;
            users[owner].pizza += referralPizza / 2;
            users[owner].refsDeps += referralBricks / 2;

            users[manager].bricks += referralBricks / 4;
            users[manager].pizza += referralPizza / 4;
            users[manager].refsDeps += referralBricks / 4;

            users[manager2].bricks += referralBricks / 4;
            users[manager2].pizza += referralPizza / 4;
            users[manager2].refsDeps += referralBricks / 4;
        }

        // FEE
        uint256 moneyFee = (msg.value * FEE_PERCENT) / 100;
        payable(owner).transfer(moneyFee / 2);
        payable(manager).transfer(moneyFee / 4); 
        payable(manager2).transfer(moneyFee / 4); 
        users[msg.sender].bricks += bricks;
    }

    function withdrawMoney(uint256 amount) external nonReentrant{
        require(amount >= 100, "Invalid amount"); 
        
        uint256 real = amount * 4e11;
        users[msg.sender].pizza -= amount;

        (bool success, ) = payable(msg.sender).call{value: real}("");
        require(success, "Transfer failed.");
    }

    function getTotalPizzaPerHour(address user) public view returns (uint256) {
        uint256 totalPizzaPerHour = 0;

        for (uint i = 0; i < users[user].pizzerias.length; i++) {            
            totalPizzaPerHour += users[user].pizzerias[i].pizzaPerHour;
        }
        
        return totalPizzaPerHour;
    }

    function _syncOven(address user) internal{
        require(users[user].lastOvenSync > 0, "User is not registered");
        uint256 yield = getTotalPizzaPerHour(user);

        if (yield > 0){
            uint256 hrs = (block.timestamp - users[msg.sender].lastOvenSync) / 3600;

            if (hrs + users[msg.sender].hrsFarm > users[msg.sender].oven.maxHours){
                hrs = users[msg.sender].oven.maxHours - users[msg.sender].hrsFarm;
            }

            uint256 pizza = hrs * yield;
            uint256 bonusPercent = 0;

            if (users[user].cookingSpeed.stage > 0) {
                bonusPercent += users[user].cookingSpeed.bonusPercent;
            }

            pizza += (pizza * bonusPercent) / 100 / 100;
            users[user].pizza += pizza;
            users[user].hrsFarm += hrs;
        }
        users[user].lastOvenSync = block.timestamp;
    }

    function collectPizza() external {
        _syncOven(msg.sender);
        users[msg.sender].pizza += users[msg.sender].fridgePizza;
        users[msg.sender].fridgePizza = 0;
        users[msg.sender].hrsFarm = 0;
    }
    
    function swapPizzaToBricks(uint256 amount) external {
        require(amount >= BRICKS_PER_PIZZA, "Invalid amount");

        users[msg.sender].pizza -= amount;
        users[msg.sender].bricks += amount / BRICKS_PER_PIZZA;
    }

    function upgradePizzeria(uint8 level) external {
        require(level < 8, "Max pizzeria level");

        _syncOven(msg.sender);
        uint8 stage = users[msg.sender].pizzerias[level].stage;

        if (stage >= 5) {
            revert("Max stage for upgrade");
        }

        PizzeriaConfig memory pizzeria = pizzeriasConfig[level][stage];
        users[msg.sender].bricks -= pizzeria.price;
        users[msg.sender].pizzerias[level] = pizzeria;
    }

    function sellPizzerias() external {
        uint256 totalPrice;
        for (uint256 level = 0; level < users[msg.sender].pizzerias.length; level++){
            uint256 stage = users[msg.sender].pizzerias[level].stage;

            for (uint256 i = 0; i < stage; i++) {
                totalPrice += pizzeriasConfig[level][i].price;
            }
        }
        uint256 pizza = (totalPrice * 30) / 100 * BRICKS_PER_PIZZA;

        if (pizza > 0){
            _syncOven(msg.sender);
            users[msg.sender].pizza += pizza;
            delete users[msg.sender].pizzerias;
            pizzeriasSold += 1;
        }
    }

    function upgradeOven() external {
        _syncOven(msg.sender);
        uint8 stage = users[msg.sender].oven.stage;

        if (stage >= 8) {
            revert("Max stage for upgrade");
        }

        OvenConfig memory nextOven = ovensConfig[stage];
        users[msg.sender].bricks -= nextOven.price;
        users[msg.sender].oven = nextOven;
    }

    function getPizzerias(address user) external view returns (PizzeriaConfig[8] memory) {
        return users[user].pizzerias;
    }
    
    function upgradeCookingSpeed() external {
        _syncOven(msg.sender);
        uint8 stage = users[msg.sender].cookingSpeed.stage;

        if (stage >= 5) {
            revert("Max stage for upgrade");
        }

        CookingSpeedConfig memory cookingSpeed = cookingSpeedConfig[stage];
        users[msg.sender].bricks -= cookingSpeed.price;
        users[msg.sender].cookingSpeed = cookingSpeed;
    }

    //Arena
    function createDuel(uint256 duelType) external{
        require(users[msg.sender].lastOvenSync > 0, "User is not registered");
        require(duelType < 18, "Incorrect type");
        address duelCreator = waitingDuels[duelType];
        require(msg.sender != duelCreator, "You are already in duel");
        require(users[msg.sender].bricks >= getDuelType(duelType), "Insufficient bricks");

        users[msg.sender].bricks -= getDuelType(duelType);
        duels[msg.sender].totalGames += 1;

        if (duelCreator == address(0)) {
            _createDuel(duelType);
        } else {
            _joinDuel(duelType, duelCreator);
            _fightDuel(duelType, duelCreator);
        }
    }

    function _randomNumber() internal view returns (uint256) {
        uint256 randomnumber = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp +
                        block.difficulty +
                        ((
                            uint256(keccak256(abi.encodePacked(block.coinbase)))
                        ) / (block.timestamp)) +
                        block.gaslimit +
                        ((uint256(keccak256(abi.encodePacked(msg.sender)))) /
                            (block.timestamp)) +
                        block.number
                )
            )
        );

        return randomnumber % 100;
    }

    function getDuelType(uint256 duelType) internal pure returns (uint256) {
        return [10, 15, 20, 30, 50, 
                100, 500, 1000, 1500, 2000, 
                4000, 6000, 8000, 10000, 15000,
                20000, 30000, 50000][duelType];
    }

    function _createDuel(uint256 duelType) internal {
        culinaryDuels[msg.sender][duelType].timestamp = block.timestamp;
        culinaryDuels[msg.sender][duelType].player1 = msg.sender;
        culinaryDuels[msg.sender][duelType].player2 = address(0);
        culinaryDuels[msg.sender][duelType].winner = address(0);
        culinaryDuels[msg.sender][duelType].bricks = getDuelType(duelType);
        culinaryDuels[msg.sender][duelType].roll = 0;
        waitingDuels[duelType] = msg.sender;
    }

    function _joinDuel(uint256 duelType, address duelCreator) internal {
        culinaryDuels[duelCreator][duelType].timestamp = block.timestamp;
        culinaryDuels[duelCreator][duelType].player2 = msg.sender;
        waitingDuels[duelType] = address(0);
    }

    function _fightDuel(uint256 duelType, address duelCreator) internal {
        uint256 random = _randomNumber();
        uint256 wAmount = culinaryDuels[duelCreator][duelType].bricks * 2;
        uint256 fee = (wAmount * FEE_PERCENT) / 100;

        address winner = random < 50
            ? culinaryDuels[duelCreator][duelType].player1
            : culinaryDuels[duelCreator][duelType].player2;
        address loser = random >= 50
            ? culinaryDuels[duelCreator][duelType].player1
            : culinaryDuels[duelCreator][duelType].player2;

        users[winner].bricks += wAmount - fee;
        culinaryDuels[duelCreator][duelType].winner = winner;
        culinaryDuels[duelCreator][duelType].roll = random;

        duels[winner].wins++;
        duels[loser].loses++;

        // FEE
        users[owner].bricks += fee / 2;
        users[manager].bricks += fee / 4;
        users[manager2].bricks += fee / 4; 
    }

    //Lottery
    function isValidPrice(uint256 ticketPrice) public view returns (bool) {
        for (uint256 i = 0; i < ticketsPrice.length; i++){
            if (ticketsPrice[i] == ticketPrice){
                return true;
            }
        }
        return false;
    }

     function isValidParticipantsCount(uint256 count) public view returns (bool) {
        for (uint256 i = 0; i < maxParticipants.length; i++) {
            if (maxParticipants[i] == count) {
                return true;
            }
        }
        return false;
    }

    function hasJoinedLottery(address participant, uint256 ticketPrice, uint256 participantsCount) public view returns (bool) {
        address[] storage participants = waitingLottery[ticketPrice][participantsCount];
        for (uint256 i = 0; i < participants.length; i++) {
            if (participants[i] == participant) {
                return true;
            }
        }
        return false;
    }

    function getLotteryParticipantsCount(uint256 ticketPrice, uint256 participantsCount) public view returns (uint256){
        return waitingLottery[ticketPrice][participantsCount].length;
    }

    function createLottery(uint256 ticketPrice, uint256 participantsCount) external{
        require(users[msg.sender].lastOvenSync > 0, "User is not registered");
        require(isValidPrice(ticketPrice), "Invalid ticket price");
        require(isValidParticipantsCount(participantsCount), "Invalid participants count");
        require(!hasJoinedLottery(msg.sender, ticketPrice, participantsCount), "You are already in lottery");
        require(users[msg.sender].bricks >= ticketPrice, "Insufficient bricks");

        address[] storage participants = waitingLottery[ticketPrice][participantsCount];
        if (participants.length == 0) {
            require(activeLotteryCount < MAX_ACTIVE_LOTTERIES, "Max. active lotteries reached");
            activeLotteryCount++;
        }

        users[msg.sender].bricks -= ticketPrice;
        lotteries[msg.sender].totalGames += 1;
        participants.push(msg.sender);

        if (participants.length == participantsCount) {
            uint256 randomNumber = _randomNumber();
            address winner = participants[randomNumber % participantsCount];

            uint256 wAmount = participantsCount * ticketPrice * BRICKS_PER_PIZZA;
            uint256 fee = (wAmount * FEE_PERCENT) / 100;
            users[winner].pizza += wAmount - fee;

            // FEE
            users[owner].pizza += fee / 2;
            users[manager].pizza += fee / 4;  
            users[manager2].pizza += fee / 4;

            lotteries[winner].wins++;
            for (uint256 i = 0; i < participants.length; i++){
                if (participants[i] != winner){
                    lotteries[participants[i]].loses++;
                }
            }

            // Reset the lottery
            delete waitingLottery[ticketPrice][participantsCount];
            activeLotteryCount--;
        }
    }

    function getActiveLotteries() external view returns (ActiveLottery[] memory) {
        ActiveLottery[] memory activeLotteries = new ActiveLottery[](activeLotteryCount);
        uint256 index = 0;
        
        for (uint256 i = 0; i < ticketsPrice.length; i++) {
            for (uint256 j = 0; j < maxParticipants.length; j++) {
                address[] memory participants = waitingLottery[ticketsPrice[i]][maxParticipants[j]];
                if (participants.length != 0){
                    activeLotteries[index] = ActiveLottery({
                        ticketPrice: ticketsPrice[i],
                        participantsCount: maxParticipants[j],
                        participants: participants
                    });
                    index++;
                }                
            }
        }
        
        return activeLotteries;
    }
}