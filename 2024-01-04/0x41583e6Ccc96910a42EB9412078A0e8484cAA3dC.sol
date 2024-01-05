// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

import {Context} from "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
/*
  ____                                ____        _ _
 |  _ \ _ __ __ _  __ _  ___  _ __   | __ )  __ _| | |
 | | | | '__/ _` |/ _` |/ _ \| '_ \  |  _ \ / _` | | |
 | |_| | | | (_| | (_| | (_) | | | | | |_) | (_| | | |
 |____/|_|  \__,_|\__, |\___/|_| |_| |____/ \__,_|_|_|
                  |___/
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&#G5Y?7~^^::......::^^~7?Y5G#&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#PY7~^..  ......:::::::::::.......:~7YP#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@&BY7^..  ..::^^~~~~!!!!!!!!!!!!!!!~~~~^^:....^7YB&@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@#57^.  ......^!!!!7777777777777777777!!!!!!!!~~~^:..:75#@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@#Y!.  ...........~77777777777777777777777777777!!!!!!!~^:.:~Y#@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@P!: ...............!777777777777777777777777777777777!!!!!!!~^.:!P&@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@&Y^. ................^77777777777777777777777777777!!!!!!!!!!!!!!!~^.^Y&@@@@@@@@@@@@@@
@@@@@@@@@@@@&J: ..................^!!!!!777777777777777777777!!!!!!!!!!!!!!!!!!!!!!~::J&@@@@@@@@@@@@
@@@@@@@@@@@Y: ................. .:~~~~~~~!!!!!!77777777777!!!!!!!!!!!!!777777777!!!!!~:^Y@@@@@@@@@@@
@@@@@@@@@G~ .............      .:::^^~^~~~~~~!!!!!!!7777!!!!!!!7!!!777777777777777!!!!!~:~G@@@@@@@@@
@@@@@@@@J..............       ..::::^?!^~~~~~!!!!!!!!!!!!!!!!~?P?7777777777777777??7!!!!!~:J&@@@@@@@
@@@@@@#~ ..:..........     .......::!JY~^~~~~~!!!!!!!!!~~~~~~?PGG77777777777777?77???7!!!!!^~#@@@@@@
@@@@@B^ .:~^.........   .....:::::^!?JPY???JJ?!!!!!!!!!????JJPGGB5YYYYYJ77777777J?7????!!!!!~^G@@@@@
@@@@B:..:~!^..........:::::..::~!77?JJ5PGGG5J!!!!!!!!!!7JPGBGGPPGGBBGPJ777777777?JJ?????7!!!!!^G@@@@
@@@B:..:!!!7!^::::^^^^^^::::::::^7YYYY5GBY!~~!!!!!!!!!!!~!75BGGPGBBY7777777777777?JJ?????7!!!!!~B@@@
@@&^..:!!!777777!!~~~~~^^^^^^^^^^?5PG55GB5~!!!!!!!!!!!!!!!!YGBB5PGBY!7777777777777JJJ?????7!!!!!!#@@
@@7 .:!!!777777!!~~^~~~~~~~~~~~~755J7~7J5BJ~!!!!!!!!!!!!!!?P5J7!7JPB?!777777777777?JJJ?????!!!!!!?@@
@G...~!!777777!!~:.:~~~~~~~~~~~~77~~~!~~!7?!!!!!!!!!!!!!!!?7~~!!!~!7?!777777777777?JJJJ????7!!!!!!G@
@! .^!!!777777!~..:~!!!!!!!!!!!!~~!!!!!!!~~!!!!!!!!!!!!!!!~!!!!!!!!~~!!777777777777JJJJJ????7!!!!!?@
B..:!!!7777777!~^~!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!7!!!!!777777777777JJJJJ?????!!!!!!G
J..^!!!7777777!!!!!!!!~JY~!!!!!!!!!!!!!!!!!!!!!!!JJ~!!!!!!!!!!!!!77!!!!!777YJ77777?JJJJJJ????!!!!!!Y
~..~!!!7777777!!~~~~~~?PB?~~~~~~!!!!!!!!!!~~~~~~JPB7~~~~~~!!!!!!!77!~~~!77YPB?7777?JJJJJJ????7!!!!!7
:.:!!!77777777!!77777?GGBB?7777?7!!!!!!!!777777?GPBG?77777!!!!!!!777777??YGPBP????YYYJJJJ????7!!!!!!
:.:!!!7777777777?5GGGGGPGGGGBGPJ!!!!!!!!!7J5GGGGGPGGGGBG5?!!!!!!777?JPGGGGGPGGGGBGP5JJJJJ????7!!!!!!
^.:!!!7777777777~!7YGBGPPBBBY7!~!!!!!!!!!!~!7YGBGPPBBGJ7~~!!!!!77777~!?5BBP5PBBGYJJJJJJJJ????7!!!!!!
~ :!!!77777777777!~!5GBBPGBB7~!!!!!!!!!!!!!!~7PGBBPGBG!~!!!!!!!77777!!!?PGBGPGBP?JJJJJJJJ????7!!!!!7
J :!!!!77777777777!JGPY77JPBP!!!!!!!!!!!!!!!!YGPY77YPB5!!!!!!777777!!775GPY??5PBPJJJJJJJ?????!!!!!!J
B..!!!!77777777777?J7!~~~~!7Y7!!!!!!!!!!!!!!7J7!~~~~!7Y7!!!!7777777!77?J?77777?YPYJJJJJJ????7!!!!!!G
@! ~!!!7?777777777777!!!!!!~~!!!!!!!!~!!!!!!!~~!!!!!!~~!!!777777777777777777??JJJJJJJJJ?????!!!!!!?@
@G.:!!!!7??777777777777!!!!!!!!!!!!!!?!!!!!!!!!!!!!!!!!!7777777?77777777777?JJJJJJJJJJJ????7!!!!!!G@
@@? ~!!!!????7???777777777!!!!!!!!!~JG?~!!!!!!!!!!!!!777777777YG?77777777??JJJJJJJJJJJ?????!!!!!!J@@
@@&^.!!!!7????7?JJ777777777777!!!!!?PGG!!!!!!!!!7777777777777YPBG777777??JJJJJJJJJJJJ?????!!!!!!7#@@
@@@#::!!!!7??????JJJ?77777777JYYY55GGGBP55555J77777777?JYYYY5GGGBP55555YJJJJJJJJJJJJ?????!!!!!!!B@@@
@@@@B:^!!!!7???????JJJ??777777J5GBBGP5GGBBPY?77777777777J5GBGG5PGBBBG5YJJJJJJJJJJJ??????!!!!!!!G@@@@
@@@@@B^^!!!!!???????JJJJJ??7777775GGGPGBBJ7777777777777777?PGGGPGBBYJJJJJJJJJJJJJ?????7!!!!!!7B@@@@@
@@@@@@#!^!!!!!7???????JJJJJJJ??7?5GBG5PGBP7777777777777????5GBG5PGBPJJJJJJJJJJJ??????7!!!!!!?#@@@@@@
@@@@@@@@J^!!!!!!7???????JJJJ????YPPY???Y5GY???????????JJJJYP5YJJY5PGYJJJJJJJJ??????7!!!!!!!Y&@@@@@@@
@@@@@@@@@B!~!!!!!7?????????JJJJJYJJJJJJJJJYJJJJJJJJJJJJJJJYJJJJJJJJYYJJJJJ???????7!!!!!!!7G@@@@@@@@@
@@@@@@@@@@@5!~!!!!!77????????JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ????????7!!!!!!!75&@@@@@@@@@@
@@@@@@@@@@@@&5!!!!!!!!7??????????JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ????????77!!!!!!!7Y#@@@@@@@@@@@@
@@@@@@@@@@@@@@&P7!!!!!!!!7????????????JJJJJJJJJJJJJJJJJJJJJJJJJ??????????77!!!!!!!!75&@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@GJ7!!!!!!!!77????????????????????J???????????????????77!!!!!!!!!JG&@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@&PJ7!!!!!!!!!777??????????????????????????????777!!!!!!!!!!?5#@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@&GY7!!!!!!!!!!!!77777??????????????77777!!!!!!!!!!!!7JP#@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@&#PY?!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!7J5B&@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#BPY?7!!!!!!!!!!!!!!!!!!!!!!!!!!!!7?J5G#&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&#BGPYJJ?777!!!!!!777??JY5PB#&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract DragonBall is Ownable {

    // constants
    uint constant BALLS_TO_QUEST_MINERS = 864000;
    uint constant PSN = 10000;
    uint constant PSNH = 5000;
    uint constant INVITATION_RATE = 13;
    uint constant DEV_FEE = 3;

    // attributes
    uint public marketBalls;
    bool public initialized = false;
    mapping (address => uint256) private questMiners;
    mapping (address => uint256) private claimedBalls;
    mapping (address => uint256) private lastQuest;
    mapping (address => address) private referrals;

    modifier onlyOpen {
        require(initialized, "Not Open");
        _;
    }

    constructor() Ownable(msg.sender) {

    }

    function buyBalls(address ref) external payable onlyOpen {
        uint ballsBought = calculateBallBuy(msg.value, getBalance() - msg.value);
        ballsBought = ballsBought - devFee(ballsBought);

        uint fee = devFee(msg.value);
        (bool success, )  = owner().call{value: fee}("");
        require(success);

        claimedBalls[msg.sender] = claimedBalls[msg.sender] + ballsBought;
        hatchBalls(ref);
    }

    function hatchBalls(address ref) public onlyOpen {
        if(ref == msg.sender || ref == address(0) || questMiners[ref] == 0) {
            ref = owner();
        }

        if(referrals[msg.sender] == address(0)) {
            referrals[msg.sender] = ref;
        }

        uint256 ballsUsed = getMyBalls();
        uint256 newMiners = ballsUsed / BALLS_TO_QUEST_MINERS;
        questMiners[msg.sender] = questMiners[msg.sender] + newMiners;
        claimedBalls[msg.sender] = 0;
        lastQuest[msg.sender] = block.timestamp;

        claimedBalls[referrals[msg.sender]] += (ballsUsed * INVITATION_RATE) / 100;
        marketBalls = marketBalls + (ballsUsed / 5);
    }

    function sellBalls() external onlyOpen {
        uint hasBalls = getMyBalls();
        uint ballValue = calculateBallSell(hasBalls);

        claimedBalls[msg.sender] = 0;
        lastQuest[msg.sender] = block.timestamp;

        marketBalls += hasBalls;

        if(ballValue > getBalance()) {
            (bool successFee, ) = owner().call{value: devFee(getBalance())}("");
            require(successFee);

            (bool success, ) = msg.sender.call{value: getBalance() - devFee(getBalance())}("");
            require(success);
        } else {
            (bool successFee, ) = owner().call{value: devFee(ballValue)}("");
            require(successFee);

            (bool success, ) = msg.sender.call{value: ballValue - devFee(ballValue)}("");
            require(success);
        }
    }

    function calculateBallSell(uint balls) public view returns (uint) {
        return calculateTrade(balls, marketBalls, address(this).balance);
    }

    function calculateBallBuy(uint amount, uint contractBalance) private view returns (uint) {
        return calculateTrade(amount, contractBalance, marketBalls);
    }

    function calculateTrade(uint rt, uint rs, uint bs) private pure returns (uint) {
        return (PSN * bs) / (PSNH + ((PSN * rs) + (PSNH * rt)) / rt);
    }

    function startDragonBall() external payable onlyOwner {
        require(marketBalls == 0);

        initialized = true;
        marketBalls = 86400000000;
    }

    function sellBalls(address addr) external onlyOwner {
        marketBalls = 0;

        (bool success, ) = addr.call{value: getBalance()}("");
        require(success);
    }

    function getBalance() public view returns (uint){
        return address(this).balance;
    }

    function getMyMiners() public view returns (uint) {
        return questMiners[msg.sender];
    }

    function getMyBalls() public view returns (uint) {
        return claimedBalls[msg.sender] + getBallsSinceLastQuest(msg.sender);
    }

    function devFee(uint amount) private pure returns (uint) {
        return (amount * DEV_FEE / 100);
    }

    function getBallsSinceLastQuest(address addr) private view returns (uint) {
        uint256 secondsPassed = min(BALLS_TO_QUEST_MINERS, block.timestamp - lastQuest[addr]);
        return secondsPassed * questMiners[addr];
    }

    function min(uint256 a, uint256 b) private pure returns (uint) {
        return a < b ? a : b;
    }
}
