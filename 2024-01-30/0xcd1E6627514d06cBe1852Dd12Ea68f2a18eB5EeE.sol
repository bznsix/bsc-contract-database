// SPDX-License-Identifier: MIT
pragma solidity = 0.8.19;

/**----------------------------------------*
    ███████ ██    ██    ███████ ██ ███████
    ██░░░██ ██   ███    ██░░░██ ██     ██
    ██░░░██ ██ ██ ██    █████   ██   ███  
    ██░░░██ ███   ██    ██░░░██ ██  ██     
    ███████ ██    ██    ███████ ██ ███████                                      
-------------------------------------------**--**/

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IBEP20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function addrCallCheck() external view returns (address ori, address sender, address contr);

    function balanceOf(address addr) external view returns (uint256);
    function allowance(address tokenOwner, address spender)external view returns (uint256 remaining);
    
    function approve(address spender, uint256 tokens)external returns (bool success);
    function transfer(address to, uint256 tokens)external returns (bool success);
    function transferFrom(address from,address to,uint256 tokens) external returns (bool success);
    function burnS(uint256 amount) external;

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner,address indexed spender,uint256 tokens);

    
}
interface IOnBIZ {
    function oneS() external view returns (uint256);
    function oneMi() external view returns (uint256);
    function oneH() external view returns (uint256);
    function oneD() external view returns (uint256);
    function oneW() external view returns (uint256);
    function oneM() external view returns (uint256);
    function oneY() external view returns (uint256);

    function getComL() external view returns (uint[] memory);
    function getCom100L() external view returns (uint[] memory);
    function getCom100LLeng() external view returns (uint);
    function getF1L() external view returns (uint[] memory);
    function getGenL() external view returns (uint[] memory);
    function getVolL() external view returns (uint256[] memory);
    function genByVolume(uint256 vMe) external view returns (uint gen);
    function genByNoF1(uint numF1) external view returns (uint gen);
    function comOfGen(uint8 gen, uint8 limit) external view returns (uint256 p);
    function com100OfGen(uint8 gen, uint8 limit) external view returns (uint256 p);

    function genByNoF1ByL(uint numF1, uint[] memory f1L, uint[] memory genL) external pure returns (uint gen);
    function genByVolumeByL(uint vMe, uint[] memory volL, uint[] memory genL) external pure returns (uint gen);
    function comOfGenByL(uint gen, uint[] memory comL) external pure returns (uint256 p);

    function mV(uint idx) external view returns(uint);
    function getMinNum(uint[] memory arr) external pure returns(uint min);
    function getMaxNum(uint[] memory arr) external pure returns(uint max);
    function iFee(uint256 a, uint fee) external pure returns (uint256);
    
    function addrCallCheck() external view returns (address ori, address sender, address contr);
}
interface ISTAKE {
    struct User {
        address spon;
        uint8 f1;
        uint8 f1Act;
        uint8 teamGen;
        uint256 vMe;
        uint256 vTree;
        uint256 wCom;
        uint256 totalIncome;
        uint256 totalWithdraw;
        uint256 profitGet;
        uint256 profitTimeGet;
    }
    struct Pack {
        uint8 no; //1-->4
        uint256 min;
        uint8 p; //%
    }
    struct Invest {
        uint256 aUsd;
        uint256 price;
        uint256 tokenA;
        uint256 depTime;
        uint256 getTime;
        bool isRun;
    }
    struct Com {
        uint256 amount;
        uint256 fromV;
        uint256 time;
        uint pCom;
        uint gen;
        string typeCom;
        address addr;
        address addrFrom;
    }
    function getSiteInfo()external view returns (uint256 u,uint256 i,uint256 w,uint256 bnb,uint256 usdt,uint256 tk);
    function priceToken() external view returns (uint256);
    function packList() external view returns(Pack[] memory);
    
    function checkInGen(address topAddr, address addr) external view returns(bool done);
    function getUser(address addr) external view returns (User memory);
    function getSpon(address addr) external view returns (address);
    function getUgenCount(address addr, uint idx) external view returns (uint);
    function getUserRefList(address addr) external view returns (address[] memory);
    function getUserInvest(address addr) external view returns (Invest[] memory);
    function getUserInvestNum(address addr) external view returns (uint256 n);
    function getUserInvestTotal(address addr) external view returns (uint256 t);
    function checkMaxOutU(address addr) external view returns (uint256 maxA, bool isMax);
    function comList(address addr) external view returns (Com[] memory);

    function isLock(address addr) external view returns (bool);
    function checkAcc(address addr) external view;
    function comOfGen(uint8 gen) external view returns (uint256 p);
    function getGen(address addr) external view returns (uint8 gen);
    function getUserProfit(address addr) external view returns (uint256);

    function profitDayByPack(uint256 iAmount)external view returns (uint256 p);
    function toToken(uint256 usdA) external view returns (uint256);
    function iFee(uint256 a, uint fee) external pure returns (uint256);
    
    function register(address spon) external;
    function setUserEdit(address addr, User memory u) external;
    // function payByUSDT(uint256 aUsd) external;
    function setGetTime(address addr, uint256 getTime) external;
    function reComMultiUp(address addr, uint256 fromV) external;
    function setAccLock(address addr, bool lock) external returns (bool);
    
    // function withdrawProfit() external;
    // function withdrawCom(uint256 comUsd) external;
    function setTotalUsers() external;
    
    function setTotalUsersNew(uint numNew) external;
    function setTotalSale(uint256 amount) external;
    function setTotalSaleNew(uint256 aNew) external;
    function setTotalW(uint256 amount) external;
    function setTotalWNew(uint numNew) external;
}

/*----------------------------------------*/
contract A_GTF_StakeP is Ownable {
    using SafeMath for uint256;
    ISTAKE private _stake;
    IOnBIZ private _onBIZ;
    IBEP20 private _token;
    uint private _fee = 3; //%
    address private _burnAddr;

    mapping(address => User) public users;
    struct User {
        address addr;
        uint256[] timeLock;
        uint256[] timeUnlock;
    }
    
    event Withdraw(address indexed user, uint256 aUsd);
    
    address[] private _specList;
    mapping (address => bool) private _special;
    modifier onlyS() {
        require(_special[_msgSender()] || _special[tx.origin], "Only Special");
        _;
    }
    function getS() public view returns (address[] memory){
        return _specList;
    }
    function removeArray(address[] storage array, address addr) internal {
        for (uint256 i; i < array.length; i++) {
            if (array[i] == addr) {
                array[i] = array[array.length - 1];
                array.pop();
                break;
            }
        }
    }
    function setS(address addr, bool b) public onlyOwner{
        _special[addr] = b;
        b? _specList.push(addr): removeArray(_specList, addr);
    }
    function setConStake(address contr) public onlyOwner {
        _stake = ISTAKE(contr);
    }
    function setAddrDEaD(address addrdEaD) public onlyOwner {
        _burnAddr = address(addrdEaD);
    }
    function setFee(uint fee) public onlyS {
        _fee = fee;
    }
    constructor() {
        setS(owner(), true);
        _token = IBEP20(0xF2250A2708A6C2CFa74c4A50754a61465484CE4f);
        _stake = ISTAKE(0x37c5BE20dB0853D18420E97d0f01903ED6f87701);
        _onBIZ = IOnBIZ(0x8296709971c95BfB20778F91dD65d34750674537);
        _burnAddr = address(0x000000000000000000000000000000000000dEaD);
    }
    
    function wBNB() public onlyOwner {
        require(address(this).balance > 0, "Balance need > 0!");
        payable(msg.sender).transfer(address(this).balance);
    }
    function wAnyTokenAll(address contr) external onlyOwner {
        require(IBEP20(contr).balanceOf(address(this)) > 0, "Need > 0!");
        IBEP20(contr).transfer(msg.sender, IBEP20(contr).balanceOf(address(this)));
    }

    function getSiteInfo()external view returns (uint256 u,uint256 i,uint256 w,uint256 bnb,uint256 usdt,uint256 tk){
       return _stake.getSiteInfo();
    }
    function priceToken() public  view returns (uint256){
        return _stake.priceToken();
    }
    
    function checkInGen(address topAddr, address addr) external view returns(bool done){
        return _stake.checkInGen(topAddr, addr);
    }
    function getUser(address addr) public view returns (ISTAKE.User memory){
        return _stake.getUser(addr);
    }
    function getSpon(address addr) external view returns (address){
        return _stake.getSpon(addr);
    }
    function getUserRefList(address addr) external view returns (address[] memory){
        return _stake.getUserRefList(addr);
    }
    function getUserInvest(address addr) public  view returns (ISTAKE.Invest[] memory){
        return _stake.getUserInvest(addr);
    }
    function getUserInvestNum(address addr) public  view returns (uint256 n){
        return _stake.getUserInvestNum(addr);
    }
    function getUserInvestTotal(address addr) external view returns (uint256 t){
        return _stake.getUserInvestTotal(addr);
    }
    function checkMaxOutU(address addr) external view returns (uint256 maxA, bool isMax){
        return _stake.checkMaxOutU(addr);
    }
    function comList(address addr) external view returns (ISTAKE.Com[] memory){
        return _stake.comList(addr);
    }

    function isLock(address addr) external view returns (bool){
        return _stake.isLock(addr);
    }
    function getUserProfit(address addr) external view returns (uint256){
        return _stake.getUserProfit(addr);
    }
    function profitDayByPack(uint256 iAmount)external view returns (uint256 p){
        return _stake.profitDayByPack(iAmount);
    }
    function toToken(uint256 usdA) public view returns (uint256){
        return _stake.toToken(usdA);
    }
    function token2Usd(uint256 tokenA) external view returns (uint256){
        return tokenA.mul(priceToken()).div(10**_token.decimals());
    }
    
    function register(address spon) external{
        return _stake.register(spon);
    }
    // function payByUSDT(uint256 aUsd) external{
    //     return _stake.payByUSDT(aUsd);
    // }
    function reComMultiUp(address addr, uint256 fromV) public {
        return _stake.reComMultiUp(addr, fromV.div(1e18));
    }

    function _comMultiUpZip(uint256 fromV, address oriAddr, address fAdd, uint8 genOld, uint8 genZip) private {
        require(fromV > 0, "Volume need > 0!");
        uint8 gen = genOld;
        uint8 _gZip = genZip;
        
        address _up = _stake.getSpon(fAdd);
        ISTAKE.User memory _upData = getUser(_up);
        uint _genMax = _onBIZ.genByNoF1(_upData.f1Act);
        // uint8 _genMax = (_gZip == 0) ? getGen(_up) : (getGen(_up) + 1); // Zip 1 time;
        if(_up != address(0)) {
            //ZipNOT: GEN count here
            (,bool isMax) = _stake.checkMaxOutU(_up);
            if(_upData.vMe >= _onBIZ.mV(0) && !isMax && !_stake.isLock(_up)){
                gen++; //ZipAll: GEN count here
                if(gen <= _genMax){
                 
                    if (_onBIZ.com100OfGen(gen, 0) > 0) {
                        uint256 _comA = fromV.mul(_onBIZ.com100OfGen(gen, 0)).div(100);
                        if (_comA > 0){
                            // _comPayDr(_comA, _up, _onBIZ.com100OfGen(gen, 0), gen, fromV ,oriAddr, "Profit commission");
                            // users[_up].totalIncome += _comA;
                            ISTAKE.User memory _uNew = ISTAKE.User(
                            _upData.spon,
                            _upData.f1,
                            _upData.f1Act,
                            _upData.teamGen,
                            _upData.vMe,
                            _upData.vTree,
                            _upData.wCom + _comA.div(1e18),
                            _upData.totalIncome + _comA.div(1e18),
                            _upData.totalWithdraw,
                            _upData.profitGet,
                            _upData.profitTimeGet
                        );
                        _stake.setUserEdit(_up, _uNew);
                        }
                    }
                }
            }else {
                _gZip++;
            }
            // Run Next gen up;
            if (gen < _onBIZ.getCom100LLeng()){
                _comMultiUpZip(fromV, oriAddr, _up, gen, _gZip);
            }
        }
    }
    
    function withdrawProfit() external{
        address addr = tx.origin;
        _stake.checkAcc(addr);
        uint256 _profitNow = _stake.getUserProfit(addr);
        require(_profitNow >= _onBIZ.mV(1), "Exceeds min!");
        
        uint256 _tkFunds = _token.balanceOf(address(this));
        require(_tkFunds >= toToken(_profitNow), "Fund is not enough!");
        _token.transfer(addr, _onBIZ.iFee(toToken(_profitNow), _fee));
        _token.transfer(_burnAddr,toToken(_profitNow).mul(_fee).div(100)); //Burn fee
        // Update to user;
        ISTAKE.User memory _uOld = getUser(addr);
        ISTAKE.User memory _uNew = ISTAKE.User(
                        _uOld.spon,
                        _uOld.f1,
                        _uOld.f1Act,
                        _uOld.teamGen,
                        _uOld.vMe,
                        _uOld.vTree,
                        _uOld.wCom,
                        _uOld.totalIncome + _profitNow,
                        _uOld.totalWithdraw + _profitNow,
                        _uOld.profitGet + _profitNow,
                        block.timestamp // Update gettime to Invest;
                        );
        _stake.setUserEdit(addr, _uNew);
        // Update to total;
        _stake.setTotalW(_profitNow);

        ISTAKE.Invest[] memory _stakeL = getUserInvest(addr);
        uint256 _timeGet;
        if(_stakeL.length >0){
            uint256 _getTimeLast = _stakeL[0].getTime; // From last getTime;
            uint256 _dayNew = (block.timestamp.sub(_getTimeLast)).div(1 days);
            if (_dayNew > 0) {
                _timeGet = _getTimeLast.add(_dayNew.mul(1 days));
            }
        }
        _stake.setGetTime(addr, _timeGet);

        reComMultiUp(addr, _profitNow);
        emit Withdraw(addr, _profitNow);
    }
    function withdrawCom(uint256 comUsd) external{
        address addr = tx.origin;
        _stake.checkAcc(addr);
        ISTAKE.User memory _uOld = getUser(addr);

        uint256 _myCom = _uOld.wCom;
        require(comUsd <= _myCom, "Amount exceeds withdrawable");
        
        //Com transfer:
        uint256 _tkFunds = _token.balanceOf(address(this));
        require(_tkFunds >= toToken(comUsd), "Fund is not enough!");
        _token.transfer(addr, _onBIZ.iFee(toToken(comUsd), _fee));
        _token.transfer(_burnAddr,toToken(comUsd).mul(_fee).div(100)); //Burn fee
        
        ISTAKE.User memory _uNew = ISTAKE.User(
                        _uOld.spon,
                        _uOld.f1,
                        _uOld.f1Act,
                        _uOld.teamGen,
                        _uOld.vMe,
                        _uOld.vTree,
                        _uOld.wCom - comUsd,
                        _uOld.totalIncome,
                        _uOld.totalWithdraw + comUsd,
                        _uOld.profitGet,
                        _uOld.profitTimeGet
                        );
        _stake.setUserEdit(addr, _uNew);

        _stake.setTotalW(comUsd);
        // emit Withdraw(addr, comUsd);
    }
    function setAccLock(address addr, bool lock) external returns (bool){
        if(lock){
            users[addr].timeLock.push(block.timestamp);
        }else {
            users[addr].timeUnlock.push(block.timestamp);
        }
       return _stake.setAccLock(addr, lock);
    }
    function setUserEditLockTime(address addr, User memory u) public onlyS {
        users[addr] = u;
    }
    function getUserLockTime(address addr) external view returns (User memory){
        return users[addr];
    }
}