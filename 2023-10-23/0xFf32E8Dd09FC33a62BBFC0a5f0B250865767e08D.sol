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
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
interface IERC1155 {
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)external view returns (uint256[] memory);
    function setApprovalForAll(address operator, bool approved) external;
    function isApprovedForAll(address account, address operator) external view returns (bool);
    function safeTransferFrom(address from,address to,uint256 id,uint256 amount,bytes calldata data) external;
    function safeBatchTransferFrom(address from,address to,uint256[] calldata ids,uint256[] calldata amounts,bytes calldata data) external;
    function burn(uint256 id, uint256 amount) external returns (bool);
    function mintTo(uint256 id,address to,uint256 num) external;
}
interface IERC721Receiver {
    function onERC721Received(address operator,address from,uint256 tokenId,bytes calldata data) view external returns (bytes4);
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

contract BoredApeExchangeERC1155 is Ownable, ReentrancyGuard ,IERC721Receiver{
    using SafeMath for uint256;
    using Address for address;

    string private _name = "BoredApeExchangeERC1155";
    string private _symbol = "BoredApeExchangeERC1155";

    IERC1155 public Erc1155Token;
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

    bytes32 private constant DOMAIN_NAME = keccak256(bytes('BoredApeExchangeERC1155'));
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 public constant CLAIM_TYPEHASH = keccak256("Claim(address to,uint256 value,uint256 rewardId,uint256 rewardType,uint256 endTime)");
    bytes32 public immutable DOMAIN_SEPARATOR;

    mapping (bytes32 => bool) public isClaimed;

    address[] public signers;
    mapping (address => bool) public authorized;
    mapping (address => uint256) public indexes;
    event SignerAdded(address indexed sender, address indexed account);
    event SignerRemoved(address indexed sender, address indexed account);
    event Claimed(address indexed to, uint256 indexed value, uint256 rewardId, uint256 rewardType,uint256 endTime);

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
        Erc1155Token = IERC1155(0xD32FfF0E98da7aC88bDb0E9A84d4E9BAa6A19936);
        fundAddress = 0x0ff1A9FB9712DaD271dE16C2fCFD82AC89b7BE57;

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
    function onERC721Received(address,address,uint256,bytes memory) public pure returns (bytes4) {
        return this.onERC721Received.selector;
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
        require(iD <= _sumCount, "BoredApeExchangeERC1155: exist num!");
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
        require(ith < _buyIds[addr].length, "BoredApeExchangeERC1155: not exist!");
        return _buyIds[addr][ith];
    }

    function buyInfos(uint256 fromId,uint256 toId) external view returns (
        uint256[] memory idArr,
        address[] memory addrArr,
        uint256[] memory buyAmountArr,
        uint256[] memory timeArr
        ) {
        require(toId <= _sumCount, "BoredApeExchangeERC1155: exist num!");
        require(fromId <= toId, "BoredApeExchangeERC1155: exist num!");
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
        require(ith <_WhiteContractArr.length, "BoredApeExchangeERC1155: not in White Adress");
        return _WhiteContractArr[ith];
    }
    
    //---write---//
    uint256 private erc1155TokenId = 1;
    function buyCoin(uint256 amount,uint256 time) external nonReentrant{
        require(isWhiteContract(_msgSender()), "BoredApeExchangeERC1155: Contract not in white list!");

        Erc1155Token.safeTransferFrom(_msgSender(), fundAddress,erc1155TokenId, amount,"");

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

    mapping (address => bool) private bUseSigners;
    mapping (address => mapping (uint256 => bool)) private bUseTimes;

    function claim(address to, uint256 value,uint256 rewardId,uint256 rewardType,uint256 endTime,
        uint8[] calldata v,bytes32[] calldata r, bytes32[] calldata s) 
        external nonReentrant {
        require(
            signers.length > 0 &&
            signers.length == v.length &&
            signers.length == r.length &&
            signers.length == s.length,
            "BoredApeExchangeERC1155:invalid signatures"
        );
        require(block.timestamp <= endTime, "BoredApeExchangeERC1155:out of time");
        require(_msgSender() == to, "BoredApeExchangeERC1155:address not sender");
        require(value <= 1000, "BoredApeExchangeCoin:Single exchange limit within 1000");
        require(!bUseTimes[to][endTime] , "BoredApeExchangeCoin:Too frequent requests");
        bUseTimes[to][endTime] = true;
        bUseTimes[to][endTime+1] = true;

        bytes32 digest = buildSeparator(to, value, rewardId, rewardType,endTime);
        require(!isClaimed[digest], "reuse");
        isClaimed[digest] = true;

        // address[] memory signatures = new address[](signers.length);
        // for (uint256 i = 0; i < signers.length; i++) {
        //     address signer = ecrecover(digest, v[i], r[i], s[i]);
        //     require(authorized[signer], "BoredApeExchangeERC1155:invalid signer");
        //     for (uint256 j = 0; j < i; j++) {
        //         require(signatures[j] != signer, "BoredApeExchangeERC1155:duplicated");
        //     }
        //     signatures[i] = signer;
        // }

        for (uint256 i = 0; i < signers.length; i++){
            bUseSigners[signers[i]] = false;
        }

        for (uint256 i = 0; i < signers.length; i++) {
            address signer = ecrecover(digest, v[i], r[i], s[i]);
            require(authorized[signer], "BoredApeExchangeERC1155:invalid signer");
            require(!bUseSigners[signer], "BoredApeExchangeERC1155:duplicated");
            bUseSigners[signer] = true;
        }

        for (uint256 i = 0; i < signers.length; i++){
            bUseSigners[signers[i]] = false;
        }

        if(Erc1155Token.balanceOf(fundAddress,erc1155TokenId)>value){
            Erc1155Token.safeTransferFrom(fundAddress,to,erc1155TokenId, value,"");
        }
        else{
            Erc1155Token.mintTo(erc1155TokenId,to, value);
        }
        
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
   function setParameters(address contractddr,address fundAddr) external onlyOwner {
        Erc1155Token = IERC1155(contractddr);
        fundAddress = fundAddr;
    }

    function addWhiteAccount(address account) external onlyOwner{
        require(!_Is_WhiteContractArr[account], "BoredApeExchangeERC1155:Account is already White list");
        require(account.isContract(), "BoredApeExchangeERC1155: not Contract Adress");
        _Is_WhiteContractArr[account] = true;
        _WhiteContractArr.push(account);
    }
    function removeWhiteAccount(address account) external onlyOwner{
        require(_Is_WhiteContractArr[account], "BoredApeExchangeERC1155:Account is already out White list");
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
        require(!authorized[account], "BoredApeExchangeERC1155:already exists");

        indexes[account] = signers.length;
        authorized[account] = true;
        signers.push(account);

        emit SignerAdded(msg.sender, account);
    }

    function removeSigner(address account) external onlyOwner {
        require(signers.length > 1, "BoredApeExchangeERC1155:illogical");
        require(authorized[account], "BoredApeExchangeERC1155:non-existent");

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