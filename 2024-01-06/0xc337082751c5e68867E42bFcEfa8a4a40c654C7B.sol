// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function decimals() external view returns (uint8);
}

interface ISwapRouter {
    function getAmountsOut(uint256 amountIn, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IOwnable {
    function owner() external view returns (address);

    function _checkOwner(address sender) external view returns (bool);
}

contract ContractToken {
    struct Sell {
        uint256 fundFee;
        uint256 wardFee;
    }
    struct ForSale {
        uint256 start;
        uint256 end;
    }
    struct UserCard {
        uint256 amount;
        uint256 cardNumber;
        uint256 splitTimestamp;
        uint256 picId;
        uint256 mark;
        uint256 transferIndex;
    }
    struct ReckonDetail {
        uint256 total;
        uint256 residue;
        uint256 obtainTimestamp;
        uint256 timestamp;
    }
    struct Reckon {
        uint256 total;
        uint256 released;
        ReckonDetail[] reckonDetail;
    }
    struct UserInfo {
        address senior;
        UserCard[] userCardList;
        Reckon reckon;
        uint256 minion;
        address team;
        Kickback[] kickback;
        uint256 kickbackTotal;
    }
    struct TransferMarket {
        address owner;
        uint256 amount;
        uint256 cardNumber;
        uint256 timestamp;
        uint256 picId;
        uint256 ownerIndex;
    }
    struct Kickback {
        address owner;
        uint256 amount;
        uint256 timestamp;
    }
    struct BlindBox {
        uint256 amount;
        uint256 multiple;
        uint256 computing;
        uint256 timestamp;
    }
    struct NowSell {
        uint256 cardNumber;
        uint256 amount;
        uint256 timestamp;
        uint256 fee;
        uint256 funFee;
        uint256 ownerFee;
    }
    struct NowSellTotal {
        uint256 size;
        uint256 amount;
    }
    modifier onlyOwner() {
        require(
            Owner == msg.sender || ownable._checkOwner(msg.sender),
            "Ownable: caller is not the owner"
        );
        _;
    }
    IOwnable ownable;
    address private Owner;
    IERC20 feeToken;
    address private  fundAddress;
    Sell public sell;
    uint256 public fixRise;
    uint256 private  constant baseTimestamp = 1703865600;
    uint256 private constant secondsInDay = 24 * 60 * 60;
    ForSale public forSale;
    uint256 public constant nftTotal = 1000;
    uint256 public issuedTotal;
    uint256 public issuedNoPuy;
    uint256 public issuePrice;
    uint256 public issueUsdtTotal;
    IERC20 usdtToken;
    uint256[] private nftPicId;
    ISwapRouter private router;
    uint256 public cardNumber;
    mapping(address => UserInfo) userInfoList;
    bool public lock;
    TransferMarket[] public transferMarketList;
    uint256 public size = 5;
    mapping(uint256 => bool) transferMarketListMap;
    bool private marketLock;
    uint256 public factorPrice;
    uint256 private fraction = 5;
    uint256 public boxPrice;
    address[] private blindBoxAddress;
    mapping(address => bool) blindBoxMap;
    BlindBox[] private blindBoxList;
    mapping(uint256 => NowSell[]) NowSellMap;
    mapping(uint256 => NowSellTotal) NowSellTotalMap;
    modifier MarketLock() {
        marketLock = true;
        _;
        marketLock = false;
    }

    constructor() {
        ownable = IOwnable(0x3012AD0d396e3cA7c4518684F8e6e1b19761cE54);
        Owner = msg.sender;
        feeToken = IERC20(0x08801120Ab610F42Eaa5c573112EEc68C19cbD9c);
        fundAddress = 0x1EA677cA58eEaC6C1A9bfDa82f8270FD34D32Cd8;
        sell = Sell(200, 100);
        fixRise = 500;
        forSale = ForSale(17, 14);
        IERC20 IUsdt = IERC20(0x55d398326f99059fF775485246999027B3197955);
        usdtToken = IUsdt;
        issuePrice = 100 * 10**IUsdt.decimals();
        nftPicId.push(1);
        nftPicId.push(2);
        nftPicId.push(3);
        nftPicId.push(4);
        nftPicId.push(5);
        router = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        factorPrice = 1000 * 10**IUsdt.decimals();
        boxPrice = 500 * 10**IUsdt.decimals();
    }

    function snapshotSenior(
        address[] memory adrList,
        address[] memory seniorList
    ) external virtual onlyOwner {
        require(adrList.length == seniorList.length, "lnconsistent length");
        for (uint256 i = 0; i < adrList.length; i++) {
            UserInfo storage userinfo = userInfoList[adrList[i]];
            userinfo.team = userInfoList[seniorList[i]].team;
            userInfoList[seniorList[i]].minion =
                userInfoList[seniorList[i]].minion +
                1;
            userinfo.senior = seniorList[i];
        }
    }

    function snapshotCard(address[] memory adrList) external virtual onlyOwner {
        uint256 length = adrList.length;
        for (uint256 i = 0; i < length; i++) {
            UserCard[] storage userCardList = userInfoList[adrList[i]]
                .userCardList;
            userCardList.push(
                UserCard(
                    issuePrice,
                    cardNumber + 1 + i,
                    0,
                    getRandomString(i),
                    0,
                    0
                )
            );
        }
        cardNumber = cardNumber + length;
    }

    function snapshotSell(
        address[] memory adrList,
        uint256[] memory indexList,
        uint256[] memory boolList
    ) external virtual onlyOwner {
        require(
            adrList.length == indexList.length &&
                adrList.length == boolList.length,
            "lnconsistent length"
        );
        uint256 count = 0;
        for (uint256 i = 0; i < adrList.length; i++) {
            UserCard[] storage userCardList = userInfoList[adrList[i]]
                .userCardList;
            UserCard storage userCard = userCardList[indexList[i]];
            userCard.mark = 1;
            uint256 marketLength = transferMarketList.length;
            userCard.transferIndex = marketLength;
            uint256 amount = userCard.amount +
                ((userCard.amount * fixRise) / 10000);
            uint256 cardNumber_ = userCard.cardNumber;
            if (boolList[i] == 1) {
                cardNumber_ = cardNumber + count + 1;
                count++;
            }
            transferMarketList.push(
                TransferMarket(
                    adrList[i],
                    amount,
                    cardNumber_,
                    getCurrentBlockTimestamp(),
                    userCard.picId,
                    indexList[i]
                )
            );
        }
        cardNumber = cardNumber + count;
        issuedTotal = cardNumber;
        issueUsdtTotal = cardNumber * issuePrice;
    }

    function snapshotPuy(address[] memory adrList, uint256[] memory indexList)
        external
        virtual
        onlyOwner
    {
        require(adrList.length == indexList.length, "lnconsistent length");
        for (uint256 i = 0; i < adrList.length; i++) {
            TransferMarket storage transferMarket = transferMarketList[
                indexList[i]
            ];
            userInfoList[adrList[i]].userCardList.push(
                UserCard(
                    transferMarket.amount,
                    transferMarket.cardNumber,
                    0,
                    transferMarket.picId,
                    0,
                    0
                )
            );
            transferMarketListMap[transferMarket.cardNumber] = true;
            UserCard storage ownerUserCard = userInfoList[transferMarket.owner]
                .userCardList[transferMarket.ownerIndex];
            ownerUserCard.mark = 2;
            ownerUserCard.transferIndex = 0;
            delete transferMarketList[indexList[i]];
        }
    }

    function getTeam(address adr)
        public
        view
        returns (
            address team,
            address senior,
            uint256 minion
        )
    {
        UserInfo memory userInfo = userInfoList[adr];
        team = userInfo.team;
        senior = userInfo.senior;
        minion = userInfo.minion;
        return (team, senior, minion);
    }

    function getUserInfo(address adr)
        public
        view
        onlyOwner
        returns (
            uint256 minion,
            address team,
            uint256 kickbackTotal
        )
    {
        UserInfo memory userInfo = userInfoList[adr];
        minion = userInfo.minion;
        team = userInfo.team;
        kickbackTotal = userInfo.kickbackTotal;
    }

    function getNowSellMap(uint256 page, uint256 size_)
        public
        view
        onlyOwner
        returns (NowSell[] memory nowSellList,uint256 amount, uint256 _size)
    {
        require(page > 0, "Page number must be greater than zero.");
        NowSell[] memory NowSellList_ = NowSellMap[getMidnightTimestamp()];
        uint256 length = NowSellList_.length;
        NowSellTotal memory nowSellTotal = NowSellTotalMap[
            getMidnightTimestamp()
        ];
        amount = nowSellTotal.amount;
        _size = nowSellTotal.size;
        uint256 max = (page - 1) * size_;
        if (length == 0 || length <= max) {
            return (new NowSell[](0),amount, _size);
        }
        (uint256 start, uint256 end, uint256 itemCount) = pageData(length, max);
        nowSellList = new NowSell[](itemCount);
        for (uint256 i = start; i >= end; i--) {
            nowSellList[start - i] = NowSellList_[i];
            if (i == 0) {
                break;
            }
        }
        
        return (nowSellList,amount, _size);
        // return nowSellList;
    }

    function getBlindBox(uint256 page, uint256 size_)
        public
        view
        onlyOwner
        returns (uint256 total, BlindBox[] memory blindBoxList_)
    {
        require(page > 0, "Page number must be greater than zero.");
        total = blindBoxAddress.length;
        uint256 length = blindBoxList.length;
        uint256 max = (page - 1) * size_;
        if (length == 0 || length <= max) {
            return (total, new BlindBox[](0));
        }
        (uint256 start, uint256 end, uint256 itemCount) = pageData(length, max);
        blindBoxList_ = new BlindBox[](itemCount);
        for (uint256 i = start; i >= end; i--) {
            blindBoxList_[start - i] = blindBoxList[i];
            if (i == 0) {
                break;
            }
        }
        return (total, blindBoxList_);
    }

    function pageData(uint256 length, uint256 max)
        public
        view
        returns (
            uint256 start,
            uint256 end,
            uint256 itemCount
        )
    {
        start = length - max - 1;
        end = start >= size ? start - size + 1 : 0;
        itemCount = start - end + 1;
        return (start, end, itemCount);
    }

    function getReckon(address adr)
        public
        view
        returns (
            uint256 total,
            uint256 released,
            uint256 residue,
            uint256 NoClaim
        )
    {
        Reckon memory reckon = userInfoList[adr].reckon;
        total = reckon.total;
        ReckonDetail[] memory reckonDetailList = reckon.reckonDetail;
        for (uint256 i = 0; i < reckonDetailList.length; i++) {
            ReckonDetail memory reckonDetail = reckonDetailList[i];
            uint256 thatTime = getMidnightTimestamp();
            uint256 timestamp = reckonDetail.timestamp;
            if ((reckonDetail.total == 0 && reckonDetail.residue == 0) || thatTime - timestamp == 0) {
                continue;
            }
            uint256 reAmount = ((reckonDetail.total * 100) *
                ((thatTime - timestamp) / secondsInDay)) / 10000;
            NoClaim += reAmount;
        }
        released = reckon.released + NoClaim;
        residue = reckon.total - released;

        return (total, released, residue, NoClaim);
    }

    function getKickback(address adr, uint256 size_)
        public
        view
        returns (uint256 kickbackTotal, Kickback[] memory kickbackList)
    {
        UserInfo memory userInfo = userInfoList[adr];
        kickbackTotal = userInfo.kickbackTotal;
        Kickback[] memory kickback = userInfo.kickback;
        if (kickback.length == 0) {
            return (kickbackTotal, new Kickback[](0));
        }
        uint256 itemCount = kickback.length > size_ ? size_ : kickback.length;
        kickbackList = new Kickback[](itemCount);
        uint256 count = 0;
        for (uint256 i = kickback.length - 1; 0 <= i; i--) {
            if (count >= itemCount) {
                break;
            }
            kickbackList[count] = kickback[i];
            count++;
            if (i == 0) {
                break;
            }
        }
        return (kickbackTotal, kickbackList);
    }

    function getMyNFT(address adr, uint256 page)
        public
        view
        returns (
            UserCard[] memory userCardListResult,
            uint256[] memory userCardListIndex,
            bool
        )
    {
        require(page > 0, "Page number must be greater than zero.");
        UserCard[] memory userCardList = userInfoList[adr].userCardList;
        uint256 max = (page - 1) * size;
        if (userCardList.length == 0 || userCardList.length <= max) {
            return (new UserCard[](0), new uint256[](0), false);
        }
        (uint256 start, uint256 end, uint256 itemCount) = pageData(
            userCardList.length,
            max
        );
        userCardListResult = new UserCard[](itemCount);
        userCardListIndex = new uint256[](itemCount);
        for (uint256 i = start; i >= end; i--) {
            userCardListResult[start - i] = userCardList[i];
            userCardListIndex[start - i] = i;
            if (i == 0) {
                break;
            }
        }
        return (userCardListResult, userCardListIndex, true);
    }

    function getTransferMarket(uint256 page)
        public
        view
        returns (
            TransferMarket[] memory transferMarketResult,
            uint256[] memory transferMarketIndex,
            bool
        )
    {
        uint256 max = (page - 1) * size;
        if (
            transferMarketList.length == 0 || transferMarketList.length <= max
        ) {
            return (new TransferMarket[](0), new uint256[](0), false);
        }
        (uint256 start, uint256 end, uint256 itemCount) = pageData(
            transferMarketList.length,
            max
        );
        transferMarketResult = new TransferMarket[](itemCount);
        transferMarketIndex = new uint256[](itemCount);
        for (uint256 i = start; i >= end; i--) {
            transferMarketResult[start - i] = transferMarketList[i];
            transferMarketIndex[start - i] = i;
            if (i == 0) {
                break;
            }
        }
        return (transferMarketResult, transferMarketIndex, true);
    }

    function claimBoxBalance() external virtual {
        Reckon storage reckon = userInfoList[msgSender()].reckon;
        ReckonDetail[] storage reckonDetailList = reckon.reckonDetail;
        uint256 amount;
        for (uint256 i = 0; i < reckonDetailList.length; i++) {
            ReckonDetail storage reckonDetail = reckonDetailList[i];
            if (reckonDetail.total == 0 && reckonDetail.residue == 0) {
                continue;
            }
            uint256 thatTime = getMidnightTimestamp();
            uint256 timestamp = reckonDetail.timestamp;
            if (thatTime - timestamp == 0) {
                continue;
            }
            uint256 reAmount = (reckonDetail.total *
                100 *
                ((thatTime - timestamp) / secondsInDay)) / 10000;
            amount += reAmount;
            if (reckonDetail.residue - reAmount <= 0) {
                delete reckonDetailList[i];
            } else {
                reckonDetail.residue = reckonDetail.residue - reAmount;
                reckonDetail.timestamp = getMidnightTimestamp();
            }
        }
        reckon.released = reckon.released + amount;
        require(amount > 0, "no claimed amount");
        uint256 tokenAmount = getUsdtToTokenSwapOutput(amount);
        require(
            feeToken.balanceOf(address(this)) >= tokenAmount,
            "transfer amount exceeds balance"
        );
        feeToken.transfer(msgSender(), tokenAmount);
    }

    function blindBox(uint256 index) external virtual{
        UserInfo storage userInfo = userInfoList[msgSender()];
        UserCard[] storage userCardList = userInfo.userCardList;
        require(
            userCardList.length > 0,
            "there are no cards available for splitting"
        );
        require(userCardList.length > index, "index too large");
        UserCard storage userCard = userCardList[index];
        require(userCard.mark == 0, "card has been manipulated");
        require(
            userCard.amount >= boxPrice,
            "the card value has not reached 500u"
        );
        uint256 multiple = getRandomNumber(index);
        uint256 computing = userCard.amount * multiple;
        Reckon storage reckon = userInfo.reckon;
        reckon.total = reckon.total + computing;
        reckon.reckonDetail.push(
            ReckonDetail(
                computing,
                computing,
                getCurrentBlockTimestamp(),
                getMidnightTimestamp()
            )
        );
        userInfoList[fundAddress].userCardList.push(
            UserCard(
                userCard.amount,
                userCard.cardNumber,
                0,
                userCard.picId,
                0,
                0
            )
        );
        userCard.mark = 4;
        if (!blindBoxMap[msgSender()]) {
            blindBoxAddress.push(msgSender());
            blindBoxMap[msgSender()] = true;
        }
        blindBoxList.push(
            BlindBox(
                userCard.amount,
                multiple,
                computing,
                getCurrentBlockTimestamp()
            )
        );
    }

    function splitCard(uint256 index) external virtual {
        UserCard[] storage userCardList = userInfoList[msgSender()]
            .userCardList;
        require(
            userCardList.length > 0,
            "there are no cards available for splitting"
        );
        require(userCardList.length > index, "index too large");
        UserCard storage userCard = userCardList[index];
        require(userCard.mark == 0, "card has been manipulated");
        require(
            userCard.amount >= factorPrice,
            "not meeting the splitting criteria"
        );
        require(
            getCurrentBlockTimestamp() >=
                (userCard.splitTimestamp + secondsInDay),
            "less than 24 hours since the last split"
        );
        uint256 onePrice = userCard.amount / fraction;
        for (uint256 i = 0; i < fraction; i++) {
            userCardList.push(
                UserCard(
                    onePrice,
                    cardNumber + i + 1,
                    getCurrentBlockTimestamp(),
                    getRandomString(i),
                    0,
                    0
                )
            );
        }
        userCard.mark = 3;
        cardNumber = cardNumber + fraction;
    }

    function userPuy(uint256 index) external virtual MarketLock {
        require(!inForSale(), "not during trading hours");
        require(lock, "the platform has not opened transactions");
        require(transferMarketList.length > index, "index too large");
        TransferMarket storage transferMarket = transferMarketList[index];
        require(
            (transferMarket.amount != 0 && transferMarket.cardNumber != 0) ||
                !transferMarketListMap[transferMarket.cardNumber],
            "the current card has been snapped up"
        ); //已被购买
        uint256 userAmount = usdtToken.balanceOf(msgSender());
        require(
            userAmount >= transferMarket.amount,
            "transfer amount exceeds balance"
        );
        usdtToken.transferFrom(
            msgSender(),
            address(this),
            transferMarket.amount
        );
        require(
            usdtToken.balanceOf(address(this)) >= transferMarket.amount,
            "contract transfer amount exceeds balance"
        );
        usdtToken.transfer(transferMarket.owner, transferMarket.amount);
        userInfoList[msgSender()].userCardList.push(
            UserCard(
                transferMarket.amount,
                transferMarket.cardNumber,
                0,
                transferMarket.picId,
                0,
                0
            )
        );
        transferMarketListMap[transferMarket.cardNumber] = true;
        UserCard storage ownerUserCard = userInfoList[transferMarket.owner]
            .userCardList[transferMarket.ownerIndex];
        ownerUserCard.mark = 2;
        ownerUserCard.transferIndex = 0;
        delete transferMarketList[index];
    }

    function userSell(uint256 index) external virtual MarketLock {
        require(inForSale(), "not during trading hours");
        require(lock, "the platform has not opened transactions");
        UserCard[] storage userCardList = userInfoList[msgSender()]
            .userCardList;
        require(userCardList.length > 0, "no cards available for sale");
        UserCard storage userCard = userCardList[index];
        uint256 amount = userCard.amount +
            ((userCard.amount * fixRise) / 10000);
        uint256 sellFee = calculateFee(amount);
        uint256 userAmount = feeToken.balanceOf(msgSender());
        require(userAmount >= sellFee, "transfer amount exceeds balance");
        require(userCard.mark == 0, "the current card has been snapped up");
        transferFee(sellFee);
        transferMarketListMap[userCard.cardNumber] = false;
        userCard.mark = 1;
        uint256 marketLength = transferMarketList.length;
        userCard.transferIndex = marketLength;
        transferMarketList.push(
            TransferMarket(
                msgSender(),
                amount,
                userCard.cardNumber,
                getCurrentBlockTimestamp(),
                userCard.picId,
                index
            )
        );
        uint256 totalFee = sell.fundFee + sell.wardFee;
        uint256 fundFee = (amount * sell.fundFee) / totalFee;
        NowSellMap[getMidnightTimestamp()].push(
            NowSell(
                userCard.cardNumber,
                amount,
                getCurrentBlockTimestamp(),
                sellFee,
                fundFee,
                amount - fundFee
            )
        );
        NowSellTotal storage nowSellTotal = NowSellTotalMap[
            getMidnightTimestamp()
        ];
        NowSellTotalMap[getMidnightTimestamp()] = NowSellTotal(
            nowSellTotal.size + 1,
            nowSellTotal.amount + amount
        );
    }

    function cast() external virtual MarketLock {
        require(issuedNoPuy > 0, "has been snatched empty");
        uint256 userAmount = usdtToken.balanceOf(msgSender());
        require(userAmount >= issuePrice, "transfer amount exceeds balance");
        UserInfo storage userInfo = userInfoList[msgSender()];
        userInfo.userCardList.push(
            UserCard(
                issuePrice,
                cardNumber + 1,
                0,
                getRandomString(cardNumber + 1),
                0,
                0
            )
        );
        usdtToken.transferFrom(msgSender(), fundAddress, issuePrice);
        issuedNoPuy = issuedNoPuy - 1;
        cardNumber = cardNumber + 1;
        issueUsdtTotal = issueUsdtTotal + issuePrice;
    }

    function Mint(
        address adr,
        uint256 price,
        uint256 count
    ) external virtual onlyOwner {
        UserCard[] storage userCardList = userInfoList[adr].userCardList;
        uint256 amount = price * 10**usdtToken.decimals();
        for (uint256 i = 0; i < count; i++) {
            uint256 str = getRandomString(i);
            userCardList.push(
                UserCard(
                    amount,
                    cardNumber + i + 1,
                    0,
                    str,
                    0,
                    0
                )
            );
        }
        cardNumber = cardNumber + count;
    }

    function issueNFT(uint256 amount) external virtual onlyOwner {
        require(issuedTotal + amount <= nftTotal, "excessive circulation");
        issuedTotal = issuedTotal + amount;
        issuedNoPuy = issuedNoPuy + amount;
    }

    function setSenior(address adr) external virtual {
        UserInfo storage userinfo = userInfoList[msgSender()];
        require(msgSender() != adr, "cannot be set as oneself");
        require(adr != address(0), "superior does not allow 0 addresses");
        require(userinfo.senior == address(0), "bound to superior");
        userinfo.team = userInfoList[adr].team;
        userInfoList[adr].minion = userInfoList[adr].minion + 1;
        userinfo.senior = adr;
    }

    function inSenior(address adr) public view returns (bool) {
        UserInfo memory userinfo = userInfoList[adr];
        return userinfo.senior != address(0);
    }

    function getRandomNumber(uint256 seed) private view returns (uint256) {
        uint256 random = generateHash(seed);
        uint256 chance = random % 100;
        if (chance < 80) {
            return 2;
        } else if (chance < 96) {
            return 3;
        } else if (chance < 98) {
            return 4;
        } else {
            return 5;
        }
    }

    function generateHash(uint256 input) private view returns (uint256) {
        uint256 blockNumber = block.number;
        bytes32 hash = keccak256(
            abi.encodePacked(
                blockNumber - 2,
                input,
                blockNumber,
                blockNumber - 1,
                getCurrentBlockTimestamp()
            )
        );
        return uint256(hash);
    }

    function getRandomString(uint256 seed) private view returns (uint256) {
        uint256 index = generateHash(seed) % nftPicId.length;
        return nftPicId[index];
    }

    function transferFee(uint256 amount) private {
        feeToken.transferFrom(msgSender(), address(this), amount);
        uint256 totalFee = sell.fundFee + sell.wardFee;
        if (totalFee <= 0) {
            return;
        }
        uint256 fundFee = (amount * sell.fundFee) / totalFee;
        uint256 feeAmount = feeToken.balanceOf(address(this));
        require(
            feeAmount >= amount,
            "ERC20: contract transfer amount exceeds balance"
        );
        feeToken.transfer(fundAddress, fundFee);
        UserInfo memory userInfo = userInfoList[msgSender()];
        address senior = userInfo.senior;
        if (senior == address(0)) {
            return;
        }
        feeToken.transfer(senior, amount - fundFee);
        UserInfo storage seniorInfo = userInfoList[
            userInfoList[msgSender()].senior
        ];
        seniorInfo.kickbackTotal =
            seniorInfo.kickbackTotal +
            (amount - fundFee);
        seniorInfo.kickback.push(
            Kickback(msgSender(), amount - fundFee, getCurrentBlockTimestamp())
        );
    }

    function setSize(uint256 size_) external virtual onlyOwner {
        size = size_;
    }

    function setLock(bool bl) external virtual onlyOwner {
        lock = bl;
    }

    function setForSale(uint256 start, uint256 end) external virtual onlyOwner {
        forSale.start = start;
        forSale.end = end;
    }

    function setSell(uint256 fundFee, uint256 wardFee)
        external
        virtual
        onlyOwner
    {
        sell = Sell(fundFee, wardFee);
    }

    function setFund(address adr) external virtual onlyOwner {
        fundAddress = adr;
    }

    function calculateFee(uint256 cardPrice) public view returns (uint256) {
        uint256 amount = getUsdtToTokenSwapOutput(cardPrice);
        uint256 fee = (amount * (sell.fundFee + sell.wardFee)) / 10000;
        return fee;
    }

    function getUsdtToTokenSwapOutput(uint256 usdtAmount)
        public
        view
        returns (uint256)
    {
        address[] memory path = new address[](2);
        path[0] = address(usdtToken);
        path[1] = address(feeToken);
        uint256[] memory amounts = router.getAmountsOut(usdtAmount, path);
        return amounts[amounts.length - 1];
    }

    function getCurrentBlockTimestamp() public view returns (uint256) {
        return block.timestamp;
    }

    function getMidnightTimestamp() public view returns (uint256) {
        return baseMidnightTimestamp(getCurrentBlockTimestamp());
    }

    function baseMidnightTimestamp(uint256 currentTimestamp)
        public
        pure
        returns (uint256)
    {
        uint256 daysSinceReference = (currentTimestamp - baseTimestamp) /
            secondsInDay;
        uint256 midnightTimestamp = baseTimestamp +
            (daysSinceReference * secondsInDay);
        return midnightTimestamp;
    }

    function inForSale() public view returns (bool) {
        uint256 blockTimestamp = getCurrentBlockTimestamp();
        uint256 midnightTimestamp = getMidnightTimestamp();
        uint256 sameDayAfternoonFive = midnightTimestamp +
            (forSale.start * 60 * 60);
        if (sameDayAfternoonFive <= blockTimestamp) {
            return true;
        } else {
            uint256 nextDayAfternoonTwo = midnightTimestamp +
                (forSale.end * 60 * 60);
            if (nextDayAfternoonTwo < blockTimestamp) {
                return false;
            }
            return true;
        }
    }

    function msgSender() private view returns (address) {
        return msg.sender;
    }

    function claimBalance(uint256 amount, address to) external onlyOwner {
        payable(to).transfer(amount);
    }

    function claimToken(
        address token_,
        uint256 amount_,
        address to_
    ) external onlyOwner {
        IERC20(token_).transfer(to_, amount_);
    }

    receive() external payable {}
}