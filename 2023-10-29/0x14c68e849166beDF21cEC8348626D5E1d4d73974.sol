// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {size := extcodesize(account)}
        return size > 0;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor() {
        _status = _NOT_ENTERED;
    }
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

contract BoredApeExchangeCoin is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    string private _name = "BoredApeExchangeCoin";
    string private _symbol = "BoredApeExchangeCoin";

    IERC20 public coinToken;
    address public fundAddress;
    struct sBuyPropertys {
        uint256 id;
        address addr;
        uint256 buyAmount;
        uint256 time;
    }

    mapping(uint256 => sBuyPropertys) private _buyPropertys;
    mapping(address => uint256[]) private _buyIds;
    uint256 private _sumCount;
    
    mapping (address => uint256) private _balances;
    uint256 private _totalSupply;

    mapping (address => bool) private _Is_WhiteContractArr;
    address[] private _WhiteContractArr;

    event BuyCoins(address indexed user, uint256 amount,uint256 id);

    bytes32 private constant DOMAIN_NAME = keccak256(bytes('BoredApeExchangeCoin'));
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 public constant CLAIM_TYPEHASH = keccak256("Claim(address to,uint256 value,uint256 rewardId,uint256 rewardType,uint256 endTime)");
    bytes32 public immutable DOMAIN_SEPARATOR;

    address[] public signers;
    mapping (address => bool) public authorized;
    mapping (address => uint256) public indexes;
    event SignerAdded(address indexed sender, address indexed account);
    event SignerRemoved(address indexed sender, address indexed account);
    event Claimed(address indexed to, uint256 indexed value, uint256 rewardId, uint256 rewardType,uint256 endTime);

    mapping (bytes32 => bool) public isClaimed;

    struct sClaimPropertys {
        uint256 id;
        address to;
        uint256 value;
        uint256 rewardId;
        uint256 rewardType;
        uint256 endTime;
        uint256 time;
    }
    mapping(uint256 => sClaimPropertys) private _claimPropertys;
    mapping(address => uint256[]) private _claimIds;
    uint256 private _sumClaimCount;
    mapping (address => uint256) private _balancesClaim;
    uint256 private _totalSupplyClaim;

    constructor() {
        coinToken = IERC20(0x2636313c0955e21895cb44Fe309755e283ce3d73);
        fundAddress = 0xD16Da11f79007B84C865e9F69341224599656285;
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(abi.encode(DOMAIN_TYPEHASH, DOMAIN_NAME, keccak256(bytes('1')), chainId, address(this)));
    }

    /* ========== VIEWS ========== */
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    //read info
   function balanceOf(address account) external view  returns (uint256) {
        return _balances[account];
    }
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }
    function sumCount() external view returns(uint256){
        return _sumCount;
    }
    function buyInfo(uint256 iD) external view returns (
        uint256 id,
        address addr,
        uint256 buyAmount,
        uint256 time
        ) {
        require(iD <= _sumCount, "BoredApeExchangeCoin: exist num!");
        id = _buyPropertys[iD].id;
        addr = _buyPropertys[iD].addr;
        buyAmount = _buyPropertys[iD].buyAmount;
        time = _buyPropertys[iD].time;
        return (id,addr,buyAmount,time);
    }
    function buyNum(address addr) external view returns (uint256) {
        return _buyIds[addr].length;
    }
    function buyIthId(address addr,uint256 ith) external view returns (uint256) {
        require(ith < _buyIds[addr].length, "BoredApeExchangeCoin: not exist!");
        return _buyIds[addr][ith];
    }

    function buyInfos(uint256 fromId,uint256 toId) external view returns (
        uint256[] memory idArr,
        address[] memory addrArr,
        uint256[] memory buyAmountArr,
        uint256[] memory timeArr
        ) {
        require(toId <= _sumCount, "BoredApeExchangeCoin: exist num!");
        require(fromId <= toId, "BoredApeExchangeCoin: exist num!");
        idArr = new uint256[](toId-fromId+1);
        addrArr = new address[](toId-fromId+1);
        buyAmountArr = new uint256[](toId-fromId+1);
        timeArr = new uint256[](toId-fromId+1);
        uint256 i=0;
        for(uint256 ith=fromId; ith<=toId; ith++) {
            idArr[i] = _buyPropertys[ith].id;
            addrArr[i] = _buyPropertys[ith].addr;
            buyAmountArr[i] = _buyPropertys[ith].buyAmount;
            timeArr[i] = _buyPropertys[ith].time;
            i = i+1;
        }
        return (idArr,addrArr,buyAmountArr,timeArr);
    }
    
    
   function balanceOfClaim(address account) external view  returns (uint256) {
        return _balancesClaim[account];
    }
    function totalSupplyClaim() external view returns (uint256) {
        return _totalSupplyClaim;
    }
    function sumclaimCount() external view returns(uint256){
        return _sumClaimCount;
    }
    function claimInfo(uint256 iD) external view returns (
        uint256 id,
        address to,
        uint256 value,
        uint256 rewardId,
        uint256 rewardType,
        uint256 endTime,
        uint256 time
        ) {
        require(iD <= _sumClaimCount, "BoredApeExchangeERC1155: exist num!");

        id = _claimPropertys[iD].id;
        to = _claimPropertys[iD].to;
        value = _claimPropertys[iD].value;
        rewardId = _claimPropertys[iD].rewardId;
        rewardType = _claimPropertys[iD].rewardType;
        endTime = _claimPropertys[iD].endTime;
        time = _claimPropertys[iD].time;

        return (id,to,value,rewardId,rewardType,endTime,time);
    }
    function claimNum(address addr) external view returns (uint256) {
        return _claimIds[addr].length;
    }
    function claimIthId(address addr,uint256 ith) external view returns (uint256) {
        require(ith < _claimIds[addr].length, "BoredApeExchangeERC1155: not exist!");
        return _claimIds[addr][ith];
    }

    function claimInfos(uint256 fromId,uint256 toId) external view returns (
        uint256[] memory idArr,
        address[] memory toArr,
        uint256[] memory valueArr,
        uint256[] memory rewardIdArr,
        uint256[] memory rewardTypeArr,
        uint256[] memory endTimeArr,
        uint256[] memory timeArr
        ) {
        require(toId <= _sumClaimCount, "BoredApeExchangeERC1155: exist num!");
        require(fromId <= toId, "BoredApeExchangeERC1155: exist num!");
        idArr = new uint256[](toId-fromId+1);
        toArr = new address[](toId-fromId+1);
        rewardIdArr = new uint256[](toId-fromId+1);
        rewardTypeArr = new uint256[](toId-fromId+1);
        endTimeArr = new uint256[](toId-fromId+1);
        timeArr = new uint256[](toId-fromId+1);
        uint256 i=0;
        for(uint256 ith=fromId; ith<=toId; ith++) {
            idArr[i] = _claimPropertys[ith].id;
            toArr[i] = _claimPropertys[ith].to;
            valueArr[i] = _claimPropertys[ith].value;
            rewardIdArr[i] = _claimPropertys[ith].rewardId;
            rewardTypeArr[i] = _claimPropertys[ith].rewardType;
            endTimeArr[i] = _claimPropertys[ith].endTime;
            timeArr[i] = _claimPropertys[ith].time;
            i = i+1;
        }
        return (idArr,toArr,valueArr,rewardIdArr,rewardTypeArr,endTimeArr,timeArr);
    }
    
    function isWhiteContract(address account) public view returns (bool) {
        if(!account.isContract()) return true;
        return _Is_WhiteContractArr[account];
    }
    function getWhiteAccountNum() public view returns (uint256){
        return _WhiteContractArr.length;
    }
    function getWhiteAccountIth(uint256 ith) public view returns (address WhiteAddress){
        require(ith <_WhiteContractArr.length, "BoredApeExchangeCoin: not in White Adress");
        return _WhiteContractArr[ith];
    }
    //---write---//
    function buyCoin(uint256 amount,uint256 time) external nonReentrant{
        require(isWhiteContract(_msgSender()), "BoredApeExchangeCoin: Contract not in white list!");
        coinToken.safeTransferFrom(_msgSender(), fundAddress, amount);

        _sumCount = _sumCount.add(1);
        _buyIds[_msgSender()].push(_sumCount);

        _buyPropertys[_sumCount].id = _sumCount;
        _buyPropertys[_sumCount].addr = _msgSender();
        _buyPropertys[_sumCount].buyAmount = amount;
        _buyPropertys[_sumCount].time = time;

        _balances[msg.sender] = _balances[msg.sender].add(amount);
        _totalSupply = _totalSupply.add(amount);
        emit BuyCoins(msg.sender, amount, _sumCount);
    }
    mapping (address => mapping (uint256 => bool)) private bUseTimes;
    function claim(address to, uint256 value,uint256 rewardId,uint256 rewardType,uint256 endTime,
        uint8[] calldata v,bytes32[] calldata r, bytes32[] calldata s) 
        external nonReentrant 
    {
        require(
            signers.length > 0 &&
            signers.length == v.length &&
            signers.length == r.length &&
            signers.length == s.length,
            "BoredApeExchangeCoin:invalid signatures"
        );

        require(block.timestamp <= endTime, "BoredApeExchangeCoin:out of time");
        require(coinToken.balanceOf(fundAddress) >= value, "BoredApeExchangeCoin:insufficient balance");
        require(_msgSender() == to, "BoredApeExchangeCoin:address not sender");
        require(value <= 1000000*10**18, "BoredApeExchangeCoin:Single exchange limit within 1 million");

        require(!bUseTimes[to][endTime] , "BoredApeExchangeCoin:Too frequent requests.");
        bUseTimes[to][endTime] = true;
        bUseTimes[to][endTime+1] = true;

        bytes32 digest = buildSeparator(to, value, rewardId, rewardType,endTime);
        require(!isClaimed[digest], "reuse");
        isClaimed[digest] = true;

        address[] memory signatures = new address[](signers.length);
        for (uint256 i = 0; i < signers.length; i++) {
            address signer = ecrecover(digest, v[i], r[i], s[i]);
            require(authorized[signer], "BoredApeExchangeCoin:invalid signer");
            for (uint256 j = 0; j < i; j++) {
                require(signatures[j] != signer, "BoredApeExchangeCoin:duplicated");
            }
            signatures[i] = signer;
        }
        coinToken.safeTransferFrom(fundAddress,to, value);


        _sumClaimCount = _sumClaimCount.add(1);
        _claimIds[to].push(_sumClaimCount);

        _claimPropertys[_sumClaimCount].id = _sumClaimCount;
        _claimPropertys[_sumClaimCount].to = to;
        _claimPropertys[_sumClaimCount].value = value;
        _claimPropertys[_sumClaimCount].rewardId = rewardId;
        _claimPropertys[_sumClaimCount].rewardType = rewardType;
        _claimPropertys[_sumClaimCount].endTime = endTime;
        _claimPropertys[_sumClaimCount].time = block.timestamp;
        _balancesClaim[msg.sender] = _balancesClaim[msg.sender].add(value);
        _totalSupplyClaim = _totalSupplyClaim.add(value);

        emit Claimed(to, value, rewardId, rewardType,endTime);
    }
    function buildSeparator(address to,uint256 value,uint256 rewardId,uint256 rewardType,uint256 endTime) view public returns (bytes32) {
        return keccak256(abi.encodePacked(
            '\x19\x01',
            DOMAIN_SEPARATOR,
            keccak256(abi.encode(CLAIM_TYPEHASH, to, value, rewardId, rewardType,endTime))
        ));
    }

    //---write onlyOwner---//
   function setParameters(address coinAddr,address fundAddr) external onlyOwner {
        coinToken = IERC20(coinAddr);
        fundAddress = fundAddr;
    }

    function addWhiteAccount(address account) external onlyOwner{
        require(!_Is_WhiteContractArr[account], "BoredApeExchangeCoin:Account is already White list");
        require(account.isContract(), "BoredApeExchangeCoin: not Contract Adress");
        _Is_WhiteContractArr[account] = true;
        _WhiteContractArr.push(account);
    }
    function removeWhiteAccount(address account) external onlyOwner{
        require(_Is_WhiteContractArr[account], "BoredApeExchangeCoin:Account is already out White list");
        for (uint256 i = 0; i < _WhiteContractArr.length; i++){
            if (_WhiteContractArr[i] == account){
                _WhiteContractArr[i] = _WhiteContractArr[_WhiteContractArr.length - 1];
                _WhiteContractArr.pop();
                _Is_WhiteContractArr[account] = false;
                break;
            }
        }
    }
    function addSigner(address account) external onlyOwner {
        require(!authorized[account], "BoredApeExchangeCoin:already exists");

        indexes[account] = signers.length;
        authorized[account] = true;
        signers.push(account);

        emit SignerAdded(msg.sender, account);
    }

    function removeSigner(address account) external onlyOwner {
        require(signers.length > 1, "BoredApeExchangeCoin:illogical");
        require(authorized[account], "BoredApeExchangeCoin:non-existent");

        uint256 index = indexes[account];
        uint256 lastIndex = signers.length - 1;

        if (index != lastIndex) {
            address lastAddr = signers[lastIndex];
            signers[index] = lastAddr;
            indexes[lastAddr] = index;
        }

        delete authorized[account];
        delete indexes[account];
        signers.pop();

        emit SignerRemoved(msg.sender, account);
    }



}