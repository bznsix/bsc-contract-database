// SPDX-License-Identifier: MIT
/**
Death Cat Lotto
https://www.deathcat.info
https://t.me/DeathCatGlobal
https://x.com/DeathCatGlobal
 */
 
pragma solidity ^0.8.7;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    error OwnableUnauthorizedAccount(address account);

    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }

    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}


contract DeathCatLotto is ReentrancyGuard, Ownable {
constructor(address initialOwner) Ownable(initialOwner) {
}

function generateRandomNumber() internal view returns (uint256) {
    return uint256(keccak256(abi.encodePacked(block.timestamp, blockhash(block.number - 1))));
}

    uint256 public currentLotteryId;
    uint256 public currentTicketId;
    uint256 public ticketPrice = 0.05 ether;
    uint256 public serviceFee = 5000;
    uint256 public numberWinner;

    enum Status {
        Close,
        Open,
        Claimable
    }

    struct Lottery {
        Status status;
        uint256 startTime;
        uint256 endTime;
        uint256 firstTicketId;
        uint256 transferJackpot;
        uint256 lastTicketId;
        uint256[3] winningNumbers;
        uint256 totalPayout;
        uint256 commision;
        uint256 winnerCount;
    }

    struct Ticket {
        uint256 ticketId;
        address owner;
        uint256[3] chooseNumbers;
    }

    mapping(uint256 => Lottery) private _lotteries;
    mapping(uint256 => Ticket) private _tickets;
    mapping(uint256 => mapping(uint32 => uint256)) private _numberTicketsPerLotteryId;
    mapping(address => mapping(uint256 => uint256[])) private _userTicketIdsPerLotteryId;
    mapping(address => mapping(uint256 => uint256)) public _winnersPerLotteryId;

    event LotteryWinnerNumber(uint256 indexed lotteryId, uint256[3] finalNumber);
    event LotteryClose(uint256 indexed lotteryId, uint256 lastTicketId);
    event LotteryOpen(uint256 indexed lotteryId, uint256 startTime, uint256 endTime, uint256 ticketPrice, uint256 firstTicketId, uint256 transferJackpot, uint256 lastTicketId, uint256 totalPayout);
    event TicketsPurchase(address indexed buyer, uint256 indexed lotteryId, uint256[3] chooseNumbers);

    function openLottery() external onlyOwner nonReentrant {
        currentLotteryId++;
        currentTicketId++;
        uint256 fundJackpot;
        if (currentLotteryId > 1) {
            if (_lotteries[currentLotteryId - 1].winnerCount > 0) {
                fundJackpot = 1 ether;
            } else {
                fundJackpot = _lotteries[currentLotteryId - 1].transferJackpot;
            }
        } else {
            fundJackpot = 1 ether;
        }
        uint256 endTime = block.timestamp + 1 minutes;
        _lotteries[currentLotteryId] = Lottery({
            status: Status.Open,
            startTime: block.timestamp,
            endTime: endTime,
            firstTicketId: currentTicketId,
            transferJackpot: fundJackpot,
            winningNumbers: [uint256(0), uint256(0), uint256(0)],
            lastTicketId: currentTicketId,
            totalPayout: 0,
            commision: 0,
            winnerCount: 0
        });
        emit LotteryOpen(currentLotteryId, block.timestamp, endTime, ticketPrice, currentTicketId, fundJackpot, currentTicketId, 0);
    }

    function buyTickets(uint256[3] calldata numbers) public payable nonReentrant {
        require(msg.value >= ticketPrice, "Funds not available to complete transaction");
        uint256 commisionFee = (ticketPrice * serviceFee) / 10000;
        _lotteries[currentLotteryId].commision += commisionFee;
        uint256 netEarn = ticketPrice - commisionFee;
        _lotteries[currentLotteryId].transferJackpot += netEarn;
        _userTicketIdsPerLotteryId[msg.sender][currentLotteryId].push(currentTicketId);
        _tickets[currentTicketId] = Ticket({
            ticketId: currentTicketId,
            owner: msg.sender,
            chooseNumbers: numbers
        });
        currentTicketId++;
        _lotteries[currentLotteryId].lastTicketId = currentTicketId;
        emit TicketsPurchase(msg.sender, currentLotteryId, numbers);
    }

    function closeLottery() external onlyOwner {
        require(_lotteries[currentLotteryId].status == Status.Open, "Lottery not open");
        require(block.timestamp > _lotteries[currentLotteryId].endTime, "Lottery not over");
        _lotteries[currentLotteryId].lastTicketId = currentTicketId;
        _lotteries[currentLotteryId].status = Status.Close;
    }

    function drawNumbers() external onlyOwner nonReentrant {
        require(_lotteries[currentLotteryId].status == Status.Close, "Lottery not close");
        uint256 randomNumber = generateRandomNumber();
        uint256[3] memory finalNumbers;

        for (uint256 i = 0; i < 3; i++) {
            uint256 num;
            num = (randomNumber % 20) + 1;
            randomNumber = uint256(keccak256(abi.encodePacked(randomNumber)));
            finalNumbers[i] = num;
        }
        _lotteries[currentLotteryId].winningNumbers = finalNumbers;
        _lotteries[currentLotteryId].totalPayout = _lotteries[currentLotteryId].transferJackpot;
    }

    function countWinners() external onlyOwner {
        require(_lotteries[currentLotteryId].status == Status.Close, "Lottery not close");
        require(_lotteries[currentLotteryId].status != Status.Claimable, "Lottery Already Counted");
        delete numberWinner;
        uint256 firstTicketId = _lotteries[currentLotteryId].firstTicketId;
        uint256 lastTicketId = _lotteries[currentLotteryId].lastTicketId;
        uint256[3] memory winOrder;
        winOrder = _lotteries[currentLotteryId].winningNumbers;
        bytes32 encodeWin = keccak256(abi.encodePacked(winOrder));
        for (uint256 i = firstTicketId; i < lastTicketId; i++) {
            address buyer = _tickets[i].owner;
            uint256[3] memory userNum = _tickets[i].chooseNumbers;
            bytes32 encodeUser = keccak256(abi.encodePacked(userNum));
            if (encodeUser == encodeWin) {
                numberWinner++;
                _lotteries[currentLotteryId].winnerCount = numberWinner;
                _winnersPerLotteryId[buyer][currentLotteryId] = 1;
            }
        }
        if (numberWinner > 0) {
            _lotteries[currentLotteryId].totalPayout = _lotteries[currentLotteryId].transferJackpot;
        } else {
            _lotteries[currentLotteryId].totalPayout = 0;
            uint256 nextLottoId = currentLotteryId + 1;
            _lotteries[nextLottoId].transferJackpot = _lotteries[currentLotteryId].transferJackpot + 0.001 ether;
        }
        _lotteries[currentLotteryId].status = Status.Claimable;
    }

    function claimPrize(uint256 _lottoId) external nonReentrant {
        require(_lotteries[_lottoId].status == Status.Claimable, "Not Payable");
        require(_lotteries[_lottoId].winnerCount > 0, "Not Payable");
        require(_winnersPerLotteryId[msg.sender][_lottoId] == 1, "Not Payable");
        uint256 winners = _lotteries[_lottoId].winnerCount;
        uint256 payout = _lotteries[_lottoId].totalPayout / winners;
        payable(msg.sender).transfer(payout);
        _winnersPerLotteryId[msg.sender][_lottoId] = 0;
    }

    function viewTickets(uint256 ticketId) external view returns (address, uint256[3] memory) {
        address buyer;
        buyer = _tickets[ticketId].owner;
        uint256[3] memory numbers;
        numbers = _tickets[ticketId].chooseNumbers;
        return (buyer, numbers);
    }

    function viewLottery(uint256 _lotteryId) external view returns (Lottery memory) {
        return _lotteries[_lotteryId];
    }

    function getBalance() external view onlyOwner returns (uint256) {
        return address(this).balance;
    }

    function fundContract() external payable onlyOwner {}

    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function getCurrentJackpot() public view returns (uint256) {
        return _lotteries[currentLotteryId].transferJackpot;
    }

    
    function setTicketPrice(uint256 _ticketPrice) external onlyOwner {
        ticketPrice = _ticketPrice;
    }

    function setServiceFee(uint256 _serviceFee) external onlyOwner {
        require(_serviceFee <= 10000, "Service fee should be between 0 and 10000");
        serviceFee = _serviceFee;
    }

    function getJackpotPercentage() public view returns (uint256) {
        return 10000 - serviceFee;
    }


}