// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// File: contracts-src\MultyOwner.sol




contract MultyOwner {
    mapping(address => bool) public owners;

    event OwnerAdded(address);
    event OwnerRemoved(address);

    function appendOwner(address _owner) virtual public onlyOwner{
        owners[_owner] = true;
        emit OwnerAdded(_owner);
    }

    function removeOwner(address _owner) virtual public onlyOwner{
        owners[_owner] = false;
        emit OwnerRemoved(_owner);
    }

    constructor() {
        owners[msg.sender] = true;
        emit OwnerAdded(msg.sender);
    }

    modifier onlyOwner() {
        require(owners[msg.sender], "Only the owner can call this function.");
        _;
    }
}

// File: contracts-src\TarifDataLib.sol




uint16 constant REGISTRATION_KEY = 65535;

library TarifDataLib {
    // // Static tarif data (not changable)
    function tarifKey(uint256 _tarif) public pure returns (uint16) {
        return (uint16)(_tarif);
    }

    function getPrice(uint256 _tarif) public pure returns (uint16) {
        return (uint16)(_tarif >> (16 * 1));
    }

    function getNumSlots(uint256 _tarif) public pure returns (uint16) {
        return (uint16)(_tarif >> (16 * 2));
    }

    function getComsa(uint256 _tarif) public pure returns (uint16) {
        return (uint16)(_tarif >> (16 * 3));
    }

    function hasCompress(uint256 _tarif) public pure returns (bool) {
        return (uint16)(_tarif >> (16 * 4)) > 0;
    }

    function getNumLVSlots(uint256 _tarif) public pure returns (uint16) {
        return (uint16)(_tarif >> (16 * 5));
    }

    function getLV(uint256 _tarif) public pure returns (uint16) {
        return (uint16)(_tarif >> (16 * 6));
    }

    function getFullNum(uint256 _tarif) public pure returns (uint16) {
        return (uint16)(_tarif >> (16 * 7));
    }

    // ---
    function isRegister(uint256 _tarif) public pure returns (bool) {
        return tarifKey(_tarif) == REGISTRATION_KEY;
    }

    function isPartner(uint256 _tarif) public pure returns (bool) {
        return getNumSlots(_tarif) > 0;
    }    
}

// File: contracts-src\Tarif.sol





contract TarifsStoreBase is MultyOwner {
    uint256[] public tarifs;

    function getAll() public view returns (uint256[] memory) {
        return tarifs;
    }

    function setAll(uint256[] calldata _tarifs) public onlyOwner {
        tarifs = new uint256[](0);
        for (uint8 i = 0; i < _tarifs.length; i++) {
            tarifs.push(_tarifs[i]); // if (TarifDataLib.tarifKey(tarifs[i]) == key) return true;
        }
    }

    // // Static tarif data (not changable)
    function tarifsCount() public view returns (uint256) {
        return tarifs.length;
    }

    function exists(uint16 _tarifKey) public view returns (bool) {
        for (uint8 i = 0; i < tarifs.length; i++) {
            if (TarifDataLib.tarifKey(tarifs[i]) == _tarifKey) return true;
        }
        return false;
    }

    // // Static tarif data (not changable)
    function tarif(uint16 _tarifKey) public view returns (uint256) {
        for (uint8 i = 0; i < tarifs.length; i++) {
            if (TarifDataLib.tarifKey(tarifs[i]) == _tarifKey) return tarifs[i];
        }
        return 0;
    }

    function isLast(uint16 _tarifKey) public view returns (bool) {
        if (tarifs.length == 0) return false;
        return _tarifKey == TarifDataLib.tarifKey(tarifs[tarifs.length - 1]);
    }
}

contract TarifsStore {
    TarifsStoreBase public clientTarifs;
    TarifsStoreBase public partnerTarifs;

    constructor() {
        clientTarifs = new TarifsStoreBase();
        partnerTarifs = new TarifsStoreBase();

        clientTarifs.appendOwner(msg.sender);
        partnerTarifs.appendOwner(msg.sender);
    }

    function isT1BetterOrSameT2(
        uint16 _tarifKey1,
        uint16 _tarifKey2
    ) public view returns (bool) {
        bool t2Found = false;
        // uint16 k1 = TarifDataLib.tarifKey(_tarif1);
        // uint16 k2 = TarifDataLib.tarifKey(_tarif2);

        if (_tarifKey2 == 0) return true; // Any model better then none.
        // if (k1 == k2) return true;

        for (uint8 i = 0; i < partnerTarifs.tarifsCount(); i++) {
            if (TarifDataLib.tarifKey(partnerTarifs.tarifs(i)) == _tarifKey2)
                t2Found = true;
            if (TarifDataLib.tarifKey(partnerTarifs.tarifs(i)) == _tarifKey1)
                return t2Found;
        }

        return false;
    }
}

// File: contracts-src\ERC20Token.sol




contract ERC20Token {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public _allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _initialSupply * (10**uint256(decimals));
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(to != address(0), "Invalid recipient address");
        require(balanceOf[msg.sender] >= value, "Insufficient balance");

        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(to != address(0), "Invalid recipient address");
        require(balanceOf[from] >= value, "Insufficient balance");
        require(_allowances[from][msg.sender] >= value, "Allowance exceeded");

        balanceOf[from] -= value;
        balanceOf[to] += value;
        _allowances[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    // Function to set initial balance for specific accounts
    function setInitialBalance(address account, uint256 balance) public {
        require(msg.sender == address(this), "Only the contract itself can call this function");
        balanceOf[account] = balance;
    }
}

// File: contracts-src\UsersFinanceStore.sol



uint8 constant PAY_CODE_INVITE_CLI = 1;
uint8 constant PAY_CODE_INVITE_PAR = 2;
uint8 constant PAY_CODE_COMPANY = 3;
uint8 constant PAY_CODE_QUART_CLI = 4;
uint8 constant PAY_CODE_QUART_PAR = 5;
uint8 constant PAY_CODE_MAGIC = 6;
uint8 constant PAY_CODE_REGISTER = 7;

uint8 constant PAY_CODE_CLI_MATRIX = 8;
uint8 constant PAY_CODE_CLI_LV = 9;
uint8 constant PAY_CODE_PAR_RANK = 10;

// uint8 constant PAY_CODE_LV = 4;
// uint8 constant PAY_CODE_TEAM = 5;

uint8 constant BUY_STATE_NEW = 0;
uint8 constant BUY_STATE_REJECTED = 1;
uint8 constant BUY_STATE_ACCEPTED = 2;

struct PayHistoryRec {
    address from;
    uint256 timestamp;
    uint64 cents;
    uint8 payCode;
}

struct BuyHistoryRec {
    uint256 timestamp;
    uint256 tarif;
    uint16 count; // How many tarifs was bought
    uint8 state;
}

struct UserFinanceRec {
    BuyHistoryRec[] buyHistory;
    PayHistoryRec[] payHistory;
    uint8 _dummy;
}

contract UsersFinanceStore is MultyOwner {
    ERC20Token public erc20;

    mapping(address => UserFinanceRec) public users;
    mapping(address => bool) public comsaExists;

    constructor(address _erc20) {
        erc20 = ERC20Token(_erc20);
    }

    function setComsaExists(address _acc, bool _exists) public onlyOwner {
        comsaExists[_acc] = _exists;
    }

    function setComsaTaken(address _acc) public onlyOwner {
        comsaExists[_acc] = false;
    }

    function getLastBuy(address _acc) public view returns (BuyHistoryRec memory) {
        if (users[_acc].buyHistory.length == 0) return BuyHistoryRec(0, 0, 0, 0);
        return users[_acc].buyHistory[users[_acc].buyHistory.length - 1];
    }

    function getBuyHistory(address user) public view returns (BuyHistoryRec[] memory) {
        return users[user].buyHistory;
    }

    function getBuyHistoryCount(address user) public view returns (uint256) {
        return users[user].buyHistory.length;
    }

    function getPayHistory(address user) public view returns (PayHistoryRec[] memory) {
        return users[user].payHistory;
    }

    function getPayTarif(address _acc, uint256 _buyIndex) public view returns (uint256) {
        return users[_acc].buyHistory[_buyIndex].tarif;
    }

    function getBuy(address _acc, uint256 _buyIndex) public view returns (BuyHistoryRec memory) {
        return users[_acc].buyHistory[_buyIndex];
    }

    function addUserPay(address _acc, PayHistoryRec memory rec) public onlyOwner {
        users[_acc].payHistory.push(rec);
    }

    function addUserBuy(address _acc, BuyHistoryRec memory rec) public onlyOwner {
        users[_acc].buyHistory.push(rec);
    }

    function rejectBuy(address _acc) public onlyOwner {        
        BuyHistoryRec storage buy = users[_acc].buyHistory[users[_acc].buyHistory.length - 1];
        buy.state = BUY_STATE_REJECTED;
        
        uint32 price = TarifDataLib.getPrice(buy.tarif);
        uint32 count = buy.count;
        erc20.transfer(_acc, centToErc20(count * price * 100));
        comsaExists[_acc] = false;
    }

    function centToErc20(uint256 _cents) public view returns (uint256){
        return _cents * (10 ** (erc20.decimals() - 2));
    }

    function freezeMoney(uint32 dollar, address _from) public {
        erc20.transferFrom(_from, address(this), centToErc20(dollar * 100));
    }

    function makePayment(address _from, address _to, uint64 _cent, uint8 _payCode) public onlyOwner {
        erc20.transfer(_to, centToErc20(_cent));
        addUserPay(_to, PayHistoryRec({timestamp: block.timestamp, cents: _cent, from: _from, payCode: _payCode}));

        if (users[_to].buyHistory.length == 0) return;
        BuyHistoryRec storage buy = users[_to].buyHistory[users[_to].buyHistory.length - 1];
        if (buy.state == 0)
        buy.state = BUY_STATE_ACCEPTED;
    }
}

// File: contracts-src\UsersTarifsStore.sol



uint256 constant YEAR = 360 * 86400;

// If reject rollback to this
struct RollbackStruct {
    uint256 tarif; 
    uint256 date;
    uint256 endsAt;
    UsageRec usage;
}

struct UserTarifStruct {
    uint256 tarif;
    uint256 boughtAt;
    uint256 endsAt;
    bool gotInviteBonus;
}

struct UsageRec {
    uint16 freeSlots;
    uint16 freeLVSlots;
    uint16 level;
    uint16 filled;
}

// Manage users info here
contract UsersTarifsStore is TarifsStore, MultyOwner {
    // mapping(address => UserStruct) public users;
    mapping(address => UserTarifStruct) public cTarifs;
    mapping(address => UserTarifStruct) public pTarifs;
    mapping(address => RollbackStruct) public rollbacks;
    mapping(address => bool) public registered;
    mapping(address => UsageRec) public usage;
    mapping(address => uint8) public ranks;

    bool public actionEnabled;
    function setActionEnabled(bool _actionEnabled) public onlyOwner {
        actionEnabled = _actionEnabled;
    }

    uint256 public clientTarifLength;
    function setClientTarifLength(uint256 _clientTarifLength) public onlyOwner {
        clientTarifLength = _clientTarifLength;
    }    

    UsersFinanceStore public usersFinance;

    constructor(address _usersFinanceAddress) {
        usersFinance = UsersFinanceStore(_usersFinanceAddress);
        setClientTarifLength(30 * 86400);
    }    

    // --- Admin section ---
    function adminSetCTarif(address _acc, uint256 _cTarif) public onlyOwner {
        cTarifs[_acc] = UserTarifStruct(_cTarif, block.timestamp, block.timestamp + clientTarifLength, true);
    }

    function adminSetPTarif(address _acc, uint256 _pTarif, uint8 level) public onlyOwner {
        registered[_acc] = true;
        pTarifs[_acc] = UserTarifStruct(_pTarif, block.timestamp, block.timestamp + YEAR, true);
        usage[_acc] = UsageRec(
            level * TarifDataLib.getNumSlots(_pTarif),
            level * TarifDataLib.getNumLVSlots(_pTarif),
            level, 0);
    }

    function adminSetRegistered(address _acc) public onlyOwner {
        registered[_acc] = true;
    }

    function setUsage(address _acc, uint16 _freeSlots, uint16 _freeLVSlots, uint16 _filled) public onlyOwner {
        usage[_acc].freeSlots = _freeSlots;
        usage[_acc].freeLVSlots = _freeLVSlots;
        usage[_acc].filled = _filled;
    }

    function adminSetRank(address _acc, uint8 _rank) public onlyOwner {        
        ranks[_acc] = _rank;
    }

    // === Admin section ===

    // --- is/has section
    function hasActiveMaxClientTarif(address user) public view returns (bool) {
        return
            isClientTarifActive(user) &&
            clientTarifs.isLast(TarifDataLib.tarifKey(cTarifs[user].tarif));
    }

    function isPartnerActive(address _partner) public view returns (bool) {
        return
            hasActiveMaxClientTarif(_partner) && isPartnerTarifActive(_partner);
    }

    function isPartnerFullfilled(address _partner) public view returns (bool) {
        return usage[_partner].filled >= TarifDataLib.getFullNum(pTarifs[_partner].tarif);
    }

    // --- User space

    function isClientTarifActive(address _client) public view returns (bool) {
        return block.timestamp < cTarifs[_client].endsAt;
    }

    function isPartnerTarifActive(address _partner) public view returns (bool) {
        return block.timestamp - pTarifs[_partner].boughtAt <= YEAR;
    }

    function newClientTarif(address _acc, uint256 _tarif) public onlyOwner {
        cTarifs[_acc].tarif = _tarif;
        cTarifs[_acc].boughtAt = block.timestamp;
        cTarifs[_acc].endsAt = block.timestamp + clientTarifLength;

        usersFinance.addUserBuy(_acc, BuyHistoryRec({
            tarif: _tarif,
            timestamp: block.timestamp,
            count: 1,
            state: 0
        }));
    }

    function getNextBuyCount(address _acc, uint16 _tarifKey) public view returns(uint16) {
        if (isPartnerTarifActive(_acc)){            
            if (!isT1BetterOrSameT2(_tarifKey, TarifDataLib.tarifKey(pTarifs[_acc].tarif))) return 0;

            if (TarifDataLib.tarifKey(pTarifs[_acc].tarif) == _tarifKey)
                return 1;            
            else
                return usage[_acc].level;
        }
        return 1;
    }

    function getNextLevel(address _acc, uint16 _tarifKey) public view returns(uint16) {
        if (isPartnerTarifActive(_acc)){            
            if (!isT1BetterOrSameT2(_tarifKey, TarifDataLib.tarifKey(pTarifs[_acc].tarif))) return 0;

            if (TarifDataLib.tarifKey(pTarifs[_acc].tarif) == _tarifKey)
                return usage[_acc].level + 1;            
            else
                return usage[_acc].level;
        }
        return 1;
    }

    function newPartnerTarif(address _acc, uint256 _tarif, uint16 _count, uint16 _level) public onlyOwner {
        rollbacks[_acc].tarif = pTarifs[_acc].tarif;
        rollbacks[_acc].date = pTarifs[_acc].boughtAt;
        rollbacks[_acc].endsAt = pTarifs[_acc].endsAt;
        rollbacks[_acc].usage = usage[_acc];

        pTarifs[_acc].tarif = _tarif;
        pTarifs[_acc].boughtAt = block.timestamp;
        pTarifs[_acc].endsAt = block.timestamp + clientTarifLength;
        if (isPartnerTarifActive(_acc)){
            usage[_acc].freeSlots += TarifDataLib.getNumSlots(_tarif) * _count;
            usage[_acc].freeLVSlots += TarifDataLib.getNumLVSlots(_tarif) * _count;
        }
        else{
            usage[_acc].freeSlots = TarifDataLib.getNumSlots(_tarif);
            usage[_acc].freeLVSlots = TarifDataLib.getNumLVSlots(_tarif);
        }

        usersFinance.addUserBuy(_acc,
            BuyHistoryRec({
                tarif: _tarif,
                timestamp: block.timestamp,
                count: _count,
                state: 0
            })
        );

        usage[_acc].level = _level;
        usage[_acc].filled = 0;
        usersFinance.setComsaExists(_acc, true);

        if (actionEnabled && partnerTarifs.isLast(TarifDataLib.tarifKey(_tarif))){
            adminSetRank(_acc, 3);
            cTarifs[_acc].endsAt += 60 * 86400;
        }        
    }

    function canReject(address _acc) public view returns (bool) {
        if (usersFinance.getBuyHistoryCount(_acc) == 0) return false;
        
        BuyHistoryRec memory buy = usersFinance.getLastBuy(_acc);

        return TarifDataLib.isPartner(buy.tarif) 
            && buy.state == 0
            && block.timestamp - buy.timestamp < 48 * 3600;
    }

    function reject() public {
        require(canReject(msg.sender));

        if (actionEnabled && partnerTarifs.isLast(TarifDataLib.tarifKey(pTarifs[msg.sender].tarif))){
            cTarifs[msg.sender].endsAt -= 60 * 86400;
        }

        pTarifs[msg.sender].tarif = rollbacks[msg.sender].tarif;
        pTarifs[msg.sender].boughtAt = rollbacks[msg.sender].date;
        pTarifs[msg.sender].endsAt = rollbacks[msg.sender].endsAt;
        usage[msg.sender] = rollbacks[msg.sender].usage;

        usersFinance.rejectBuy(msg.sender);
    }

    function useFill(address _acc) public onlyOwner {
        usage[_acc].filled++;
    }

    function getLevel(address _acc) public view returns(uint16) {
        return usage[_acc].level;
    }

    function hasCInviteBonus(address _acc) public view returns (bool) {
        return cTarifs[_acc].gotInviteBonus;
    }

    function giveCInviteBonus(address _acc) public onlyOwner {
        cTarifs[_acc].gotInviteBonus = true;
    }

    function hasPInviteBonus(address _acc) public view returns (bool) {
        return pTarifs[_acc].gotInviteBonus;
    }

    function givePInviteBonus(address _acc) public onlyOwner {
        pTarifs[_acc].gotInviteBonus = true;
    }

    function cTarif(address _acc) public view returns (uint256) {
        return cTarifs[_acc].tarif;
    }

    function pTarif(address _acc) public view returns (uint256) {
        return pTarifs[_acc].tarif;
    }

    function hasCompress(address _acc) public view returns (bool) {
        return TarifDataLib.hasCompress(pTarifs[_acc].tarif);
    }

    function hasSlot(address _acc) public view returns (bool) {
        return usage[_acc].freeSlots > 0;
    }

    function useSlot(address _acc) public onlyOwner {
        require(usage[_acc].freeSlots > 0);
        usage[_acc].freeSlots--;
    }

    function hasLVSlot(address _acc) public view returns (bool) {
        return usage[_acc].freeLVSlots > 0;
    }

    function useLVSlot(address _acc) public onlyOwner {
        require(usage[_acc].freeLVSlots > 0);
        usage[_acc].freeLVSlots--;
    }

    function canRegister(address _acc) public view returns (bool) {
        return hasActiveMaxClientTarif(_acc) && !registered[_acc];
    }

    function register(address _acc) public onlyOwner {
        registered[_acc] = true;
        usage[_acc].level = 1;        
        cTarifs[_acc].endsAt += 30 * 86400;
    }

    function cTarifExists(uint16 _tarifKey) public view returns (bool) {
        return clientTarifs.exists(_tarifKey);
    }

    function pTarifExists(uint16 _tarifKey) public view returns (bool) {
        return partnerTarifs.exists(_tarifKey);
    }

    function canBuyPTarif(address _acc) public view returns (bool) {
        return
            registered[_acc] &&
            hasActiveMaxClientTarif(_acc) &&
            isPartnerFullfilled(_acc);
    }
}

// File: contracts-src\UsersTreeStore.sol



struct UserStructRec {
    address mentor;
    address[] referals;
}

contract UsersTreeStore is MultyOwner {
    mapping(address => UserStructRec) public users;
    mapping(address => bool) public blockedUsers;

    address[] public registeredUsers;
   
    function registeredUsersCount() public view returns (uint256) {
        return registeredUsers.length;
    }

    function getRegisteredUsers() public view returns (address[] memory) {
        return registeredUsers;
    }

    function getUserInfo(address _acc) public view returns (UserStructRec memory) {
        return users[_acc];
    }

    function adminSetUserBlocked(address _acc, bool _blocked) public onlyOwner{
        blockedUsers[_acc] = _blocked;
    }

    function getMentor(address _acc) public view returns (address) {
        return users[_acc].mentor;
    }

    function setMentor(address _mentor) public {
        require(_mentor != address(0) && msg.sender != _mentor);
        require(users[msg.sender].mentor == address(0));
        require(users[_mentor].mentor != address(0) || _mentor == address(1));

        registeredUsers.push(msg.sender);
        users[msg.sender].mentor = _mentor;
        users[_mentor].referals.push(msg.sender);
    }   

    function adminSetMentor(address _user, address _mentor) public onlyOwner {
        bool found = false;
        for (uint256 i = 0; i < registeredUsers.length; i++){
            if (registeredUsers[i] == _user){
                found = true;
                break;
            }
        }
        if (!found) registeredUsers.push(_user);

        users[_user].mentor = _mentor;

        found = false;
        for (uint256 i = 0; i < users[_mentor].referals.length; i++){
            if (users[_mentor].referals[i] == _user){
                found = true;
                break;
            }
        }
        if (!found) users[_mentor].referals.push(_user);
    }   


    function getReferals(address _acc) public view returns (address[] memory) {
        return users[_acc].referals;
    }
}

// File: contracts-src\RankMatrix.sol



contract RankMatrix is MultyOwner {
    constructor() {}

    uint8 public maxRank;
    uint8 public maxLevel;
    mapping(uint16 => uint8) public matrix;
    
    function toKey(uint16 _rank, uint16 _level) pure public returns (uint16) {
        return (_rank << 8 ) | _level;
    }

    function fromKey(uint16 key) pure public returns (uint8 _rank, uint8 _level) {
        return (uint8((key >> 8) & 0xFF), uint8(key & 0xFF));
    }

    function setMatrix(uint16[] calldata _keys, uint8[] calldata _values) public onlyOwner{
        uint8 maxRank_ = 0;
        uint8 maxLevel_ = 0;

        for (uint16 i = 0; i < _keys.length; i++){
            (uint8 rank, uint8 level) = fromKey(_keys[i]);
            if (rank > maxRank_) maxRank_ = rank;
            if (level > maxLevel_) maxLevel_ = level;
            matrix[_keys[i]] = _values[i];
        }

        maxRank = maxRank_;
        maxLevel = maxLevel_;
    }
}

// File: contracts-src\Referal.sol









contract Referal is MultyOwner {
    UsersTarifsStore public usersTarifsStore;
    UsersFinanceStore public usersFinance;
    
    function setUsersTarifsStore(address _usersTarifsStoreAddress) public onlyOwner {
        require(_usersTarifsStoreAddress != address(0));
        usersTarifsStore = UsersTarifsStore(_usersTarifsStoreAddress);
        usersFinance = UsersFinanceStore(usersTarifsStore.usersFinance());
    }

    UsersTreeStore public usersTree;
    function setUsersTreeStore(address _usersTreeAddress) public onlyOwner {
        require(_usersTreeAddress != address(0));
        usersTree = UsersTreeStore(_usersTreeAddress);
    }

    RankMatrix public rankMatrix;
    function setRankMatrix(address _rankMatrix) public onlyOwner {
        require(_rankMatrix != address(0));
        rankMatrix = RankMatrix(_rankMatrix);
    }

    mapping(address => uint256) public passwords;

    function setPassword(uint256 _password) public{
        passwords[msg.sender] = _password;
    }    

    address public cWallet;
    function setCWallet(address _cWallet) public onlyOwner {
        require(_cWallet != address(0));
        cWallet = _cWallet;
    }

    address public qcWallet;
    function setQCWallet(address _qcWallet) public onlyOwner {
        require(_qcWallet != address(0));
        qcWallet = _qcWallet;
    }

    address public qpWallet;
    function setQPWallet(address _qpWallet) public onlyOwner {
        require(_qpWallet != address(0));
        qpWallet = _qpWallet;
    }

    address public mWallet;
    function setMWallet(address _mWallet) public onlyOwner {
        require(_mWallet != address(0));
        mWallet = _mWallet;
    }

    uint16 public qBonus;
    function setQBonus(uint8 _qBonus) public onlyOwner {
        require(_qBonus < 101);
        qBonus = _qBonus;
    }

    mapping(uint32 => uint8) public inviteMatix;

    function getInvitePercent(uint16 _pTarifKey, uint16 _cTarifKey) public view returns(uint8) {
        uint32 key = (uint32(_pTarifKey) << 16) | _cTarifKey;
        return inviteMatix[key];
    }

    function setInviteMatrix(uint32[] memory keys, uint8[] memory percs) public onlyOwner {
        require(keys.length == percs.length);
        for (uint8 i = 0; i < keys.length; i++){
            inviteMatix[keys[i]] = percs[i];
        }
    }

    uint16 public registerPrice;
    /**
        @param _registerPrice in dollars
     */
    function setRegisterPrice(uint16 _registerPrice) public onlyOwner {
        registerPrice = _registerPrice;
    }

    function canTakeComsa(address _client) public view returns(bool){        
        BuyHistoryRec memory buy = usersFinance.getLastBuy(_client);
        if (buy.tarif == 0 || buy.state == BUY_STATE_REJECTED) return false;

        return usersFinance.comsaExists(_client);
    }

    function takeComsa(address _client) public {
        require(canTakeComsa(_client));
        processComsa(_client);
    }

    function clientScheme(address _client, address mentor, uint32 curPriceCent) internal returns(uint32){
        // --- Matrix bonus get first available person
        {
            address mbMen = mentor;
            while (mbMen != address(0) && mbMen != address(1) && !(usersTarifsStore.isPartnerActive(mbMen) && (mbMen == mentor  || usersTarifsStore.hasCompress(mbMen)) && usersTarifsStore.hasSlot(mbMen))){
                mbMen = usersTree.getMentor(mbMen);
            }

            if (mbMen != address(0) && mbMen != address(1)) {
                uint32 matrixCent = TarifDataLib.getComsa(usersTarifsStore.pTarif(mbMen)) * 100;
                usersFinance.makePayment(_client, mbMen, matrixCent, PAY_CODE_CLI_MATRIX);                
                usersTarifsStore.useSlot(mbMen);
                curPriceCent -= matrixCent;
            }
        }

        // --- LV bonus logic
        uint32 lvCent = curPriceCent / 4;
        for (uint8 i = 0; i < 4; i++){
            // MC logic
            uint256 pt = usersTarifsStore.pTarif(mentor);

            while (mentor != address(0) && mentor != address(1) && !(TarifDataLib.getLV(pt) > i && usersTarifsStore.isPartnerActive(mentor) && usersTarifsStore.hasLVSlot(mentor) )){
                mentor = usersTree.getMentor(mentor);
                pt = usersTarifsStore.pTarif(mentor);
            }

            if (mentor == address(1) || mentor == address(0)){
                break;
            }
            else{
                usersFinance.makePayment(_client, mentor, lvCent, PAY_CODE_CLI_LV);
                usersTarifsStore.useLVSlot(mentor);
                curPriceCent -= lvCent;
                mentor = usersTree.getMentor(mentor);
            }
        }

        return curPriceCent;
    }

    function partnerScheme(address _client, address mentor, uint32 curPriceCent) internal returns(uint32){
        uint8 maxLevel = rankMatrix.maxLevel();

        uint32 basePriceCent = curPriceCent;
        uint8 level = 1;

        while (true){
            if (mentor == address(0) || mentor == address(1) || basePriceCent == 0 || level > maxLevel){
                break;
            }

            if (usersTarifsStore.isPartnerActive(mentor)){
                uint8 mentorRank = usersTarifsStore.ranks(mentor);
                uint8 perc = rankMatrix.matrix(rankMatrix.toKey(mentorRank, level));

                uint32 lvCent = basePriceCent * perc / 100;
                usersFinance.makePayment(_client, mentor, lvCent, PAY_CODE_PAR_RANK);
                curPriceCent -= lvCent;
                level++;
            }

            mentor = usersTree.getMentor(mentor);
        }       

        return curPriceCent;        
    }

    // --- Payment schemes section
    function processComsa(address _client) internal {
        // require(canTakeComsa(_client), "Cant process");
        address mentor = usersTree.getMentor(_client);
        if (mentor == address(1)) mentor = cWallet;        
        
        BuyHistoryRec memory buy = usersFinance.getLastBuy(_client);

        uint256 _tarif = buy.tarif;
        uint32 basePriceCent = uint32(buy.count) * TarifDataLib.getPrice(_tarif) * 100;        

        uint32 curPriceCent = basePriceCent;
        usersTarifsStore.useFill(mentor);
        bool isPartner = TarifDataLib.isPartner(_tarif);

        // Invite bonus processing
        if (usersTarifsStore.isPartnerActive(mentor)){
            uint32 invitePercent;
            bool takeInviteBonus = false;
            if (isPartner){
                if (!usersTarifsStore.hasPInviteBonus(_client)){
                    usersTarifsStore.givePInviteBonus(_client);
                    takeInviteBonus = true;
                }
            }
            else {
                if (!usersTarifsStore.hasCInviteBonus(_client)){
                    usersTarifsStore.giveCInviteBonus(_client);
                    takeInviteBonus = true;
                }                 
            }
            if (takeInviteBonus){
                invitePercent = getInvitePercent(TarifDataLib.tarifKey(usersTarifsStore.pTarif(mentor)), TarifDataLib.tarifKey(_tarif));
                require(invitePercent > 0, "IP is 0");
                usersFinance.makePayment(_client, mentor, invitePercent * basePriceCent / 100, isPartner ? PAY_CODE_INVITE_PAR : PAY_CODE_INVITE_CLI);
                curPriceCent -= invitePercent * basePriceCent / 100;
            }            
        }

        // CWallet comission (30%)
        usersFinance.makePayment(_client, cWallet, basePriceCent * 30 / 100, PAY_CODE_COMPANY);
        curPriceCent -= basePriceCent * 30 / 100;

        if (isPartner){
            // Quarterly bonus (5%) 
            usersFinance.makePayment(_client, qpWallet, basePriceCent * 5 / 100, PAY_CODE_QUART_PAR);
            curPriceCent -= basePriceCent * 5 / 100;

            curPriceCent = partnerScheme(_client, mentor, curPriceCent);
        }
        else {
            // Quarterly bonus (5%) 
            usersFinance.makePayment(_client, qcWallet, basePriceCent * 5 / 100, PAY_CODE_QUART_CLI);
            curPriceCent -= basePriceCent * 5 / 100;

            curPriceCent = clientScheme(_client, mentor, curPriceCent);
        }

        usersFinance.makePayment(_client, mWallet, curPriceCent, PAY_CODE_MAGIC);
        usersFinance.setComsaExists(_client, false);
    }

    // --- Shop section (buy this, buy that)

    function regitsterPartner() public {
        require(usersTarifsStore.canRegister(msg.sender));      
        usersFinance.freezeMoney(registerPrice, msg.sender);  
        usersFinance.makePayment(msg.sender, cWallet, registerPrice * 100, PAY_CODE_REGISTER);

        usersFinance.addUserBuy(msg.sender,
            BuyHistoryRec({
                tarif: 65535,
                timestamp: block.timestamp,
                count: 1,
                state: BUY_STATE_ACCEPTED
            })
        );
        // usersTarifsStore.newPartnerTarif(msg.sender, REGISTRATION_KEY, 1, 1);
        usersTarifsStore.register(msg.sender);
    }

    function canBuy(address _acc) public view returns (bool) {
        if (usersTree.blockedUsers(_acc) || usersTree.getMentor(_acc) == address(0)) return false;
        BuyHistoryRec memory buy = usersFinance.getLastBuy(_acc);
        return !TarifDataLib.isPartner(buy.tarif) || buy.state != BUY_STATE_NEW || (block.timestamp - buy.timestamp > 48 * 3600);
    }

    function buyClientTarif(uint16 _tarifKey) public {
        require(!usersTree.blockedUsers(msg.sender), "User blocked");

        TarifsStoreBase clientTarifs = usersTarifsStore.clientTarifs();
        uint256 tarif = clientTarifs.tarif(_tarifKey);
        require(tarif != 0 && canBuy(msg.sender), "E117");

        // A;8 ?@54K4CICN :><AC =5 701@0;8, 7015@5< 55.
        if (usersFinance.comsaExists(msg.sender)) processComsa(msg.sender);

        usersFinance.freezeMoney(TarifDataLib.getPrice(tarif), msg.sender);
        usersTarifsStore.newClientTarif(msg.sender, tarif);        
        processComsa(msg.sender);
    }

    function buyPartnerTarif(uint16 _tarifKey) public {
        TarifsStoreBase partnerTarifs = usersTarifsStore.partnerTarifs();
        uint256 tarif = partnerTarifs.tarif(_tarifKey);

        require(
            usersTarifsStore.registered(msg.sender)
            && usersTarifsStore.hasActiveMaxClientTarif(msg.sender)
            && usersTarifsStore.isPartnerFullfilled(msg.sender)
            && canBuy(msg.sender), "E118");

        // A;8 ?@54K4CICN :><AC =5 701@0;8, 7015@5< 55.
        if (usersFinance.comsaExists(msg.sender)) processComsa(msg.sender);

        uint16 buyCount = usersTarifsStore.getNextBuyCount(msg.sender, _tarifKey);
        uint16 level = usersTarifsStore.getNextLevel(msg.sender, _tarifKey);

        require(buyCount > 0);

        usersFinance.freezeMoney(TarifDataLib.getPrice(tarif) * buyCount, msg.sender);

        // A;8 5ABL =527OB0O :><8AA8O, B> 701@0BL 55. =0G5 ?@>AB> 70?><=8BL B5:CI89 ?;0B56.
        usersTarifsStore.newPartnerTarif(msg.sender, tarif, buyCount, level);
    }
}