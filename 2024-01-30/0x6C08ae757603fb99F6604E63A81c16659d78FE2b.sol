pragma solidity ^0.6.12;
/***
V1.0.0 初始化版本建立    20210907
V1.0.1 增加按类型产生NFT 20210925
V1.0.1 NFT职业按类型设定 20210930
V1.0.2 增加NFT打铭文     20240108


 */
library SafeMath
{
  string constant OVERFLOW = "008001";
  string constant SUBTRAHEND_GREATER_THEN_MINUEND = "008002";
  string constant DIVISION_BY_ZERO = "008003";

  /**
   * @dev Multiplies two numbers, reverts on overflow.
   * @param _factor1 Factor number.
   * @param _factor2 Factor number.
   * @return product The product of the two factors.
   */
  function mul(
    uint256 _factor1,
    uint256 _factor2
  )
    internal
    pure
    returns (uint256 product)
  {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_factor1 == 0)
    {
      return 0;
    }

    product = _factor1 * _factor2;
    require(product / _factor1 == _factor2, OVERFLOW);
  }

  /**
   * @dev Integer division of two numbers, truncating the quotient, reverts on division by zero.
   * @param _dividend Dividend number.
   * @param _divisor Divisor number.
   * @return quotient The quotient.
   */
  function div(
    uint256 _dividend,
    uint256 _divisor
  )
    internal
    pure
    returns (uint256 quotient)
  {
    // Solidity automatically asserts when dividing by 0, using all gas.
    require(_divisor > 0, DIVISION_BY_ZERO);
    quotient = _dividend / _divisor;
    // assert(_dividend == _divisor * quotient + _dividend % _divisor); // There is no case in which this doesn't hold.
  }

  /**
   * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
   * @param _minuend Minuend number.
   * @param _subtrahend Subtrahend number.
   * @return difference Difference.
   */
  function sub(
    uint256 _minuend,
    uint256 _subtrahend
  )
    internal
    pure
    returns (uint256 difference)
  {
    require(_subtrahend <= _minuend, SUBTRAHEND_GREATER_THEN_MINUEND);
    difference = _minuend - _subtrahend;
  }

  /**
   * @dev Adds two numbers, reverts on overflow.
   * @param _addend1 Number.
   * @param _addend2 Number.
   * @return sum Sum.
   */
  function add(
    uint256 _addend1,
    uint256 _addend2
  )
    internal
    pure
    returns (uint256 sum)
  {
    sum = _addend1 + _addend2;
    require(sum >= _addend1, OVERFLOW);
  }

  /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo), reverts when
    * dividing by zero.
    * @param _dividend Number.
    * @param _divisor Number.
    * @return remainder Remainder.
    */
  function mod(
    uint256 _dividend,
    uint256 _divisor
  )
    internal
    pure
    returns (uint256 remainder)
  {
    require(_divisor != 0, DIVISION_BY_ZERO);
    remainder = _dividend % _divisor;
  }

}

library AddressUtils
{

  /**
   * @dev Returns whether the target address is a contract.
   * @param _addr Address to check.
   * @return addressCheck True if _addr is a contract, false if not.
   */
  function isContract(
    address _addr
  )
    internal
    view
    returns (bool addressCheck)
  {
    // This method relies in extcodesize, which returns 0 for contracts in
    // construction, since the code is only stored at the end of the
    // constructor execution.

    // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
    // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
    // for accounts without code, i.e. `keccak256('')`
    bytes32 codehash;
    bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
    assembly { codehash := extcodehash(_addr) } // solhint-disable-line
    addressCheck = (codehash != 0x0 && codehash != accountHash);
  }

}

interface ERC721
{
  event Transfer(
    address indexed _from,
    address indexed _to,
    uint256 indexed _tokenId
  );

  event Approval(
    address indexed _owner,
    address indexed _approved,
    uint256 indexed _tokenId
  );


  event ApprovalForAll(
    address indexed _owner,
    address indexed _operator,
    bool _approved
  );

  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes calldata _data
  )
    external;
    
  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    external;
    
  function transferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    external;

  function approve(
    address _approved,
    uint256 _tokenId
  )
    external;
    
  function setApprovalForAll(
    address _operator,
    bool _approved
  )
    external;

  function balanceOf(
    address _owner
  )
    external
    view
    returns (uint256);

  function ownerOf(
    uint256 _tokenId
  )
    external
    view
    returns (address);

  function getApproved(
    uint256 _tokenId
  )
    external
    view
    returns (address);

  function isApprovedForAll(
    address _owner,
    address _operator
  )
    external
    view
    returns (bool);

}

interface ERC721TokenReceiver{
  function onERC721Received(
    address _operator,
    address _from,
    uint256 _tokenId,
    bytes calldata _data
  )
    external
    returns(bytes4);
}

contract Ownable
{

  /**
   * @dev Error constants.
   */
  string public constant NOT_CURRENT_OWNER = "018001";
  string public constant CANNOT_TRANSFER_TO_ZERO_ADDRESS = "018002";
  string public constant NOT_CURRENT_MANAGER = "018003";

  address public owner;
  mapping(address=>bool) public Manager;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  constructor()
    public
  {
    owner = msg.sender;
  }
  modifier onlyOwner()
  {
    require(msg.sender == owner, NOT_CURRENT_OWNER);
    _;
  }
  
  modifier onlyManager()
  {
    require(Manager[msg.sender], NOT_CURRENT_MANAGER);
    _;
  }

  function addManager(address _maddr) public onlyOwner{
      Manager[_maddr] = true;
  }
  
  function delManager(address _maddr) public onlyOwner{
      Manager[_maddr] = false;
  }
  function transferOwnership(
    address _newOwner
  )
    public
    onlyOwner
  {
    require(_newOwner != address(0), CANNOT_TRANSFER_TO_ZERO_ADDRESS);
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }

}

contract StringConcat{
       function getStr(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}

contract NFToken is ERC721
{
  using SafeMath for uint256;
  using AddressUtils for address;
 
  string constant ZERO_ADDRESS = "003001";
  string constant NOT_VALID_NFT = "003002";
  string constant NOT_OWNER_OR_OPERATOR = "003003";
  string constant NOT_OWNER_APPROWED_OR_OPERATOR = "003004";
  string constant NOT_ABLE_TO_RECEIVE_NFT = "003005";
  string constant NFT_ALREADY_EXISTS = "003006";
  string constant NOT_OWNER = "003007";
  string constant IS_OWNER = "003008";

  bytes4 internal constant MAGIC_ON_ERC721_RECEIVED = 0x150b7a02;  
  mapping (uint256 => address) public idToOwner;
  uint256 internal tokenID;
  mapping (uint256 => address) internal idToApproval;   
  mapping (address => uint256) private ownerToNFTokenCount;  
  mapping (address => mapping (address => bool)) internal ownerToOperators;

  
  event Transfer(
    address indexed _from,
    address indexed _to,
    uint256 indexed _tokenId
  );

 
  event Approval(
    address indexed _owner,
    address indexed _approved,
    uint256 indexed _tokenId
  );

 
  event ApprovalForAll(
    address indexed _owner,
    address indexed _operator,
    bool _approved
  );


  modifier canOperate(
    uint256 _tokenId
  )
  {
    address tokenOwner = idToOwner[_tokenId];
    require(tokenOwner == msg.sender || ownerToOperators[tokenOwner][msg.sender], NOT_OWNER_OR_OPERATOR);
    _;
  }


  modifier canTransfer(
    uint256 _tokenId
  )
  {
    address tokenOwner = idToOwner[_tokenId];
    require(
      tokenOwner == msg.sender
      || idToApproval[_tokenId] == msg.sender
      || ownerToOperators[tokenOwner][msg.sender],
      NOT_OWNER_APPROWED_OR_OPERATOR
    );
    _;
  }


  modifier validNFToken(
    uint256 _tokenId
  )
  {
    require(idToOwner[_tokenId] != address(0), NOT_VALID_NFT);
    _;
  }


  constructor()
    public
  {
    //supportedInterfaces[0x80ac58cd] = true; // ERC721
  }
  
  function viewTokenID() view public returns(uint256 ){
      return tokenID;
  }
  
  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes calldata _data
  )
    external
    override
  {
    _safeTransferFrom(_from, _to, _tokenId, _data);
  }
  


  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    external
    override
  {
    _safeTransferFrom(_from, _to, _tokenId, "");
  }

 
  function transferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    external
    override
    canTransfer(_tokenId)
    validNFToken(_tokenId)
  {
    address tokenOwner = idToOwner[_tokenId];
    require(tokenOwner == _from, NOT_OWNER);
    require(_to != address(0), ZERO_ADDRESS);

    _transfer(_to, _tokenId);
  }
  
  function transferList(address _to,uint256[] calldata _tokenIdList) external{
        uint256 len = _tokenIdList.length;
        address tokenOwner;
        uint256 _tokenId;
         require(_to != address(0), ZERO_ADDRESS);
        for(uint256 i=0;i<len;i++){
            _tokenId = _tokenIdList[i];
            tokenOwner = idToOwner[_tokenId];
            require(tokenOwner != address(0), NOT_VALID_NFT);
            require(
                tokenOwner == msg.sender
                || idToApproval[_tokenId] == msg.sender
                || ownerToOperators[tokenOwner][msg.sender],
                NOT_OWNER_APPROWED_OR_OPERATOR
            );
            _transfer(_to, _tokenId);
        }
  }    
 
  function approve(
    address _approved,
    uint256 _tokenId
  )
    external
    override
    canOperate(_tokenId)
    validNFToken(_tokenId)
  {
    address tokenOwner = idToOwner[_tokenId];
    require(_approved != tokenOwner, IS_OWNER);

    idToApproval[_tokenId] = _approved;
    emit Approval(tokenOwner, _approved, _tokenId);
  }
 
  function setApprovalForAll(
    address _operator,
    bool _approved
  )
    external
    override
  {
    ownerToOperators[msg.sender][_operator] = _approved;
    emit ApprovalForAll(msg.sender, _operator, _approved);
  }
 
  function balanceOf(
    address _owner
  )
    external
    override
    view
    returns (uint256)
  {
    require(_owner != address(0), ZERO_ADDRESS);
    return _getOwnerNFTCount(_owner);
  }
 
  function ownerOf(
    uint256 _tokenId
  )
    external
    override
    view
    returns (address _owner)
  {
    _owner = idToOwner[_tokenId];
    require(_owner != address(0), NOT_VALID_NFT);
  }

  function getApproved(
    uint256 _tokenId
  )
    external
    override
    view
    validNFToken(_tokenId)
    returns (address)
  {
    return idToApproval[_tokenId];
  }


  function isApprovedForAll(
    address _owner,
    address _operator
  )
    external
    override
    view
    returns (bool)
  {
    return ownerToOperators[_owner][_operator];
  }

  function _transfer(
    address _to,
    uint256 _tokenId
  )
    internal
  {
    address from = idToOwner[_tokenId];
    _clearApproval(_tokenId);

    _removeNFToken(from, _tokenId);
    _addNFToken(_to, _tokenId);

    emit Transfer(from, _to, _tokenId);
  }


  function _mint(
    address _to,
    uint256 _tokenId
  )
    internal
    virtual
  {
    require(_to != address(0), ZERO_ADDRESS);
    require(idToOwner[_tokenId] == address(0), NFT_ALREADY_EXISTS);
    //require(_tokenId == tokenID+1,NFT_ALREADY_EXISTS);
    tokenID++;
    _addNFToken(_to, _tokenId);

    emit Transfer(address(0), _to, _tokenId);
  }

  function _burn(
    uint256 _tokenId
  )
    internal
    virtual
    validNFToken(_tokenId)
  {
    address tokenOwner = idToOwner[_tokenId];
    _clearApproval(_tokenId);
    _removeNFToken(tokenOwner, _tokenId);
    emit Transfer(tokenOwner, address(0), _tokenId);
  }

  function _removeNFToken(
    address _from,
    uint256 _tokenId
  )
    internal
    virtual
  {
    require(idToOwner[_tokenId] == _from, NOT_OWNER);
    ownerToNFTokenCount[_from] = ownerToNFTokenCount[_from] - 1;
    delete idToOwner[_tokenId];
  }

  
  function _addNFToken(
    address _to,
    uint256 _tokenId
  )
    internal
    virtual
  {
    require(idToOwner[_tokenId] == address(0), NFT_ALREADY_EXISTS);

    idToOwner[_tokenId] = _to;
    ownerToNFTokenCount[_to] = ownerToNFTokenCount[_to].add(1);
  }


  function _getOwnerNFTCount(
    address _owner
  )
    internal
    virtual
    view
    returns (uint256)
  {
    return ownerToNFTokenCount[_owner];
  }

  function _safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes memory _data
  )
    private
    canTransfer(_tokenId)
    validNFToken(_tokenId)
  {
    address tokenOwner = idToOwner[_tokenId];
    require(tokenOwner == _from, NOT_OWNER);
    require(_to != address(0), ZERO_ADDRESS);

    _transfer(_to, _tokenId);

    if (_to.isContract())
    {
      bytes4 retval = ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data);
      require(retval == MAGIC_ON_ERC721_RECEIVED, NOT_ABLE_TO_RECEIVE_NFT);
    }
  }

  function _clearApproval(
    uint256 _tokenId
  )
    private
  {
    if (idToApproval[_tokenId] != address(0))
    {
      delete idToApproval[_tokenId];
    }
  }

}

contract BASEToken is NFToken {

    string internal nftName;
    string internal nftSymbol;
    mapping(uint16 => uint256) public nftTypesTokenAddCount;//不同类型NFT发行数量
    mapping(uint16 => uint256) public nftTypesTokenBurnCount;//不同类型NFT销毁数量
    
    string webUrl="";

    string constant INVALID_INDEX = "005007";

    uint256[] public tokens;
    mapping(uint256 => uint256) public idToIndex;
    mapping(address => uint256[]) public ownerToIds;
    mapping(uint256 => uint256) public idToOwnerIndex;
    mapping(uint256 => string) public typeName;    
    mapping(uint256 => string) internal idToUri;
    mapping(uint256 =>  nftAttrStruct) public  nftAttributes;   
    

   struct  nftAttrStruct{
      uint16 nftType;//名称:龙印禅者\电戟魁翔龙\龙财青剑
      uint16 hp;//生命值
      uint16 atk;//攻击力
      uint16 def;//防御力
      uint16 spd;//速度
    }

    //nft 添加数量
    function getAddCountSupply(uint8 _typeId) external view returns (uint256) {
        return nftTypesTokenAddCount[_typeId];
    }
    
    function totalSupply() external view returns (uint256) {
        return tokens.length;
    }

    function tokenByIndex(uint256 _index) external view returns (uint256){
        require(_index < tokens.length, INVALID_INDEX);
        return tokens[_index];
    }

    function tokenOfOwnerByIndex(address _owner,uint256 _index) external view returns (uint256){
        require(_index < ownerToIds[_owner].length, INVALID_INDEX);
        return ownerToIds[_owner][_index];
    }
    
    function _mint(address _to,uint256 _tokenId) override internal {
        super._mint(_to, _tokenId);
        tokens.push(_tokenId);
        idToIndex[_tokenId] = tokens.length - 1;
    }

    //function multiApprove(address )

    function _burn(uint256 _tokenId) override internal {
        _removeNFToken(msg.sender,_tokenId);

        uint256 tokenIndex = idToIndex[_tokenId];
        uint256 lastTokenIndex = tokens.length - 1;
        uint256 lastToken = tokens[lastTokenIndex];
        tokens[tokenIndex] = lastToken;
        tokens.pop();
        // This wastes gas if you are burning the last token but saves a little gas if you are not.
        idToIndex[lastToken] = tokenIndex;
        idToIndex[_tokenId] = 0;
    }

    function _removeNFToken(address _from,uint256 _tokenId) override internal {
        require(idToOwner[_tokenId] == _from, NOT_OWNER);
        delete idToOwner[_tokenId];

        uint256 tokenToRemoveIndex = idToOwnerIndex[_tokenId];
        uint256 lastTokenIndex = ownerToIds[_from].length - 1;

        if (lastTokenIndex != tokenToRemoveIndex){
            uint256 lastToken = ownerToIds[_from][lastTokenIndex];
            ownerToIds[_from][tokenToRemoveIndex] = lastToken;
            idToOwnerIndex[lastToken] = tokenToRemoveIndex;
        }
        ownerToIds[_from].pop();
    }

    function _addNFToken(address _to,uint256 _tokenId) override internal {
        require(idToOwner[_tokenId] == address(0), NFT_ALREADY_EXISTS);
        idToOwner[_tokenId] = _to;

        ownerToIds[_to].push(_tokenId);
        idToOwnerIndex[_tokenId] = ownerToIds[_to].length - 1;
    }
    
    function _getOwnerNFTCount(address _owner) internal override view returns (uint256){
        return ownerToIds[_owner].length;
    }
    
    function _setTokenUri(uint256 _tokenId, string memory _uri) internal validNFToken(_tokenId) {
        idToUri[_tokenId] = _uri;
    }
    
    function _setTokenAttributes(uint256 _tokenId,uint16 _nftType,uint16 _hp,uint16 _atk, uint16 _def,uint16 _spd) 
    internal validNFToken(_tokenId) {        
        nftAttributes[_tokenId] =   nftAttrStruct(_nftType,_hp,_atk,_def,_spd);
    }
}

contract DetailToken  is BASEToken,StringConcat,Ownable {

    function GetNFTDetail(uint256 _tokenId) external   view returns (
      uint16 nftType,//（NFT）类型:龙印禅者\电戟魁翔龙\龙财青剑
      uint16 hp,//生命值
      uint16 atk,//攻击力
      uint16 def,//防御力
      uint16 spd,//速度
      string memory imgUrl,
      string memory userName
    ){
        nftAttrStruct storage attr =  nftAttributes[_tokenId];
        nftType = attr.nftType;
        hp = attr.hp;
        atk=attr.atk;    
        def=attr.def;    
        spd=attr.spd;            
        imgUrl=string(abi.encodePacked(webUrl,"/nft/img/", getStr(nftType), ".png"));
        userName = idToUri[_tokenId];
    }
   
   //取得指定类型的NFT信息
    function GetTokenList(address _userAddress,uint256 _startIndex,uint256 _length,uint16 _nftType) external  view returns (
      uint256[] memory tokenIds,
      uint256 maxIndex
    ){
      tokenIds = new uint256[](_length);
      uint256 balanceNum =  _getOwnerNFTCount(_userAddress);
      uint256 foundNum = 0;
      for(uint256 i = _startIndex;i<balanceNum;i++){
         uint tokenId = ownerToIds[_userAddress][i];
         if(nftAttributes[tokenId].nftType == _nftType){
             tokenIds[foundNum]=(tokenId);
            foundNum++;
         }
         maxIndex = i+1;
        if(foundNum>=_length){
          break;
        }
      }
    }
    
    //取得自动NFT类型的token数量
     function GetTokenCount(address _userAddress,uint16 _nftType,uint16 _pageSize) external  view returns (
      uint32 recCount,uint32[] memory allPageIndex
    ){
     uint32[] memory pallPageIndex =new uint32[](1000);
      uint256 balanceNum =  _getOwnerNFTCount(_userAddress);
       recCount = 0;
       uint32 pnowPage =0;
   //    pallPageIndex[0] = 0;
      for(uint32 i = 0;i<balanceNum;i++){
         uint tokenId = ownerToIds[_userAddress][i];
         if(nftAttributes[tokenId].nftType == _nftType){
            pnowPage =uint32((recCount- recCount%_pageSize)/_pageSize)+1; 
            if(recCount%_pageSize==0){
                pallPageIndex[pnowPage-1] = i;
            }
            recCount = recCount + 1;
         }
      }

      allPageIndex  = new uint32[](pnowPage);
      for(uint32 i=0;i<pnowPage;i++){
          allPageIndex[i] = pallPageIndex[i];
      }
    }
    
    //取得自动NFT类型的token数量
    function GetTokenType(uint256 _tokenId) external  view returns (
      uint256 nftType
    ){
       nftType =  nftAttributes[_tokenId].nftType;
    }
    
    function GetTokenTypeByIndex(address _userAddress,uint16 _index) external  view returns (
      uint256 nftType
    ){
         uint tokenId = ownerToIds[_userAddress][_index];
          nftType =  nftAttributes[tokenId].nftType;
    }

}

contract DragonForge_NFT is DetailToken{ 
     constructor() public {
        nftName = "Dragon Forge";
        nftSymbol = "Dragon Forge";
    }

    uint16 maxNftType = 4;
    uint16 oneDayMaxNftNum = 100;
    uint16 invitedUpgradeNum = 5;
    uint maxNftCount = 20000;//最大Nft数量
    mapping(address => uint) public userLevel;//用户级别
    mapping(address => address) public myInviteUserAddr;//自己--邀请人
    mapping(address => address[]) public InviteListAddr;//我推荐的用户地址列表
    mapping(uint256 => uint256) public nftCastOneDayMaxNum;//nft铸造每日数量
    struct AddressData {
        uint256 mintedCount;
        uint256 lastMintDay;
    }
    mapping(address => AddressData) public addressData;
    uint256 public baseGasFee=5000000000000000;
    //正式
    address public feeRecipient = 0xa0EC28DA48df514ABd858279EC0C841cB91df927;
     /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual  returns (string memory) {
        return nftName;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual  returns (string memory) {
        return nftSymbol;
    }
    
   function tokenURI(uint256 tokenId) public view virtual  returns (string memory) {
        return string(abi.encodePacked(webUrl,"/nft/data/",getStr(tokenId),".json"));
    }
  
    function SetWebUrl(string memory _webUrl)external
        onlyManager{
        webUrl = _webUrl;
    }

  function getNowCreateNftCount(address _addr) public view virtual  returns (uint256) {
      AddressData storage data = addressData[msg.sender];
      return  oneDayMaxNftNum+userLevel[msg.sender]/1>data.mintedCount?oneDayMaxNftNum+userLevel[msg.sender]/1-data.mintedCount:0;
    }
     
  function _mintAll(
        address _to,
        uint256 _tokenId,
        uint16 _nftType,
        uint16 _hp,
        uint16 _atk,
        uint16 _def,
        uint16 _spd,
        address _inviteAdd,
        string calldata _userName
  )
    internal
    virtual 
  {
        nftTypesTokenAddCount[_nftType]++;
         AddressData storage data = addressData[msg.sender];
        require(_tokenId == tokenID+1,"The current NFT ID has been occupied");
        require(_tokenId <=maxNftCount,"NFT exceeds maximum quantity");
        require(_tokenId >0,"The current NFT must be greater than 0");
        require(getNowCreateNftCount(msg.sender)>0 || data.lastMintDay < getCurrentDay(), "Can only mint up to  NFTs per day");
        if (data.lastMintDay < getCurrentDay()) {
            data.mintedCount = 0;
            data.lastMintDay = getCurrentDay();
        }
        data.mintedCount = data.mintedCount +1;        

        address[] memory visitedAddresses = new address[](100);
        uint visitedIndex = 0;
        super._mint(_to, _tokenId);
        super._setTokenUri(_tokenId, _userName);
        super._setTokenAttributes(_tokenId,_nftType,_hp,_atk,_def,_spd);
        //如果_inviteAdd不为空，表示邀请 && myInviteUserAddr 不存在邀请人
        if(_inviteAdd != address(0)&&myInviteUserAddr[msg.sender]== address(0)){
          myInviteUserAddr[msg.sender] = _inviteAdd;
          InviteListAddr[_inviteAdd].push(msg.sender);
        } else  if(myInviteUserAddr[msg.sender]!= address(0)){
          _inviteAdd = myInviteUserAddr[msg.sender];
        }

        if(_inviteAdd != address(0)){
            //计算用户级别
            address inviteAdd = _inviteAdd;
            while(inviteAdd!= address(0)){
               
                uint j=0;
                for(j=0;j<visitedIndex;j++){
                  if(visitedAddresses[j]==inviteAdd){
                    j=9999;
                    break;
                  }
                }
                if(j==9999 || j==99){
                   //inviteAdd = myInviteUserAddr[inviteAdd];
                   break;
                } 

                visitedAddresses[visitedIndex]=inviteAdd;
                visitedIndex++;
                (uint256 rUserLevelInt, address invitedAddress) = caluUserLevel(inviteAdd);
                if(userLevel[inviteAdd]<rUserLevelInt) {
                  userLevel[inviteAdd] = rUserLevelInt;
                  inviteAdd = invitedAddress;
                }
            }
        }
  }

  function caluUserLevel(address inviteAdd) public view  returns (uint256  rUserLevelInt,address rInviteAddr){
      rUserLevelInt=0;
      rInviteAddr= address(0);
      uint256[] memory levelsUserCount = new uint256[](10);
      //计算用户级别 循环InviteAddr[_inviteAdd]
      for(uint i=0;i<InviteListAddr[inviteAdd].length;i++){
          //我邀请人的等级
          uint childUserLevelInt = userLevel[InviteListAddr[inviteAdd][i]];
          levelsUserCount[childUserLevelInt] = levelsUserCount[childUserLevelInt]+1;
          if(levelsUserCount[childUserLevelInt]>=invitedUpgradeNum && childUserLevelInt>=userLevel[inviteAdd]){
            rUserLevelInt= childUserLevelInt+1;
            rInviteAddr = myInviteUserAddr[inviteAdd];
            break;
          }
      }
      if(rUserLevelInt>4){
        rUserLevelInt=4;
      }
      return (rUserLevelInt, rInviteAddr);
  }

  function mintManager(
        address _to,
        uint256 _tokenId,
        uint16 _nftType,
         uint16 _hp,
        uint16 _atk,
        uint16 _def,
        uint16 _spd,
        address _inviteAdd,
        string calldata _userName
    )
        public
        onlyManager payable
    { 
        require(msg.value >= baseGasFee, "Insufficient gas fee");
         _mintAll(_to,_tokenId,_nftType,_hp,_atk,_def,_spd,_inviteAdd,_userName);
         if(baseGasFee>0){
            payable(feeRecipient).transfer(baseGasFee);
         }
    }
 
     function mint(
        address _to,
        uint256 _tokenId,
        address _inviteAdd,
        string calldata _userName
    )
        public
        payable
    { 
        require(msg.value >= baseGasFee, "Insufficient gas fee");
        require(tokenID+1==_tokenId);
        uint16 _nftType = roundAvg(1,4);
        uint16 _hp = roundAvg(1000,1200);
        uint16 _atk = roundAvg(200,250);
        uint16 _def = roundAvg(200,230);
        uint16 _spd = roundAvg(400,450);
        if(_nftType==2){
          _hp = roundAvg(1000,1600);
          _atk = roundAvg(300,400);
          _def = roundAvg(150,200);
          _spd = roundAvg(300,350);
        } else if(_nftType==3){
          _hp = roundAvg(1000,1400);
          _atk = roundAvg(250,300);
          _def = roundAvg(200,250);
          _spd = roundAvg(400,500);
        } else if(_nftType==4){
          _hp = roundAvg(1000,1600);
          _atk = roundAvg(200,280);
          _def = roundAvg(300,400);
          _spd = roundAvg(300,380);
        }
         _mintAll(_to,_tokenId,_nftType,_hp,_atk,_def,_spd,_inviteAdd,_userName);
         if(baseGasFee>0){
            payable(feeRecipient).transfer(baseGasFee);
         }
    }

 function modifynftType(
        uint256 _tokenId,
        uint _nftType
    )
        public
        onlyManager
    { 
       require(_nftType < 5, "The nftType index must be less than 4");
       require(_nftType > 0, "The nftType index must be less than 4");
        nftAttributes[_tokenId].nftType = uint16(_nftType);
    }
    function modifyAttr(
        uint256 _tokenId,
        uint _attrIndex,
        uint16 _attrValue
    )
        public
        onlyManager
    { 
        require(_attrIndex < 4, "The attribute index must be less than 4");
        uint16 maxArrValue = 0;
        uint16[][] memory maxArrValues = new uint16[][](4);
        maxArrValues[0] = new uint16[](4);
        maxArrValues[0][0] = 1200;
        maxArrValues[0][1] = 250;
        maxArrValues[0][2] = 300;
        maxArrValues[0][3] = 450;

        maxArrValues[1] = new uint16[](4);
        maxArrValues[1][0] = 1800;
        maxArrValues[1][1] = 400;
        maxArrValues[1][2] = 200;
        maxArrValues[1][3] = 350;

        maxArrValues[2] = new uint16[](4);
        maxArrValues[2][0] = 1400;
        maxArrValues[2][1] = 300;
        maxArrValues[2][2] = 250;
        maxArrValues[2][3] = 500;

        maxArrValues[3] = new uint16[](4);
        maxArrValues[3][0] = 1600;
        maxArrValues[3][1] = 280;
        maxArrValues[3][2] = 400;
        maxArrValues[3][3] = 300;
        maxArrValue = maxArrValues[nftAttributes[_tokenId].nftType-1][_attrIndex];
        if(_attrValue>maxArrValue) _attrValue = maxArrValue;
        if(_attrIndex == 0){
            nftAttributes[_tokenId].hp = uint16(_attrValue);
        } else if(_attrIndex == 1){
            nftAttributes[_tokenId].atk = uint16(_attrValue);
        } else if(_attrIndex == 2){
            nftAttributes[_tokenId].def = uint16(_attrValue);
        } else if(_attrIndex == 3){
            nftAttributes[_tokenId].spd = uint16(_attrValue);
        }
    }

    function roundAvg(uint256 _minValue,uint256 _maxValue) public view  returns(uint16 rnNum){
        uint256 result2 = uint256(keccak256(abi.encodePacked(blockhash(block.number),msg.sender,now,tokenID,block.difficulty,blockhash(_minValue+now),blockhash(_maxValue+now))));
        //uint lenNum = _maxValue-_minValue;
       // rnNum =uint16( result2 - (result2/lenNum)*lenNum+_minValue);
        uint256 randomNum = (result2 % (_maxValue - _minValue + 1));
        return uint16(randomNum + _minValue);
    }
    function inviterNum(address _inviteAdd) public view  returns(uint256 rnNum){
        return InviteListAddr[_inviteAdd].length;
    }

     //取得推荐用户列表
    function GetInviterList(address _inviteAdd) external  view returns (
      address[] memory tokenIds
    ){
       uint balanceNum =  InviteListAddr[_inviteAdd].length;
      tokenIds = new address[](balanceNum);
      for(uint256 i = 0; i < balanceNum;i++){
         address tokenId = InviteListAddr[_inviteAdd][i];
         tokenIds[i]=(tokenId);
      }
    }

    function getCurrentDay() public view returns (uint256) {
        return block.timestamp / 1 days;
    }

   function getTokenUser(uint256 _tokenId) public view validNFToken(_tokenId)   returns (string memory) {
        return idToUri[_tokenId];
   }

   function getTokenUri(uint256 _tokenId) public view validNFToken(_tokenId)   returns (string memory) {
        uint tokenId = nftAttributes[_tokenId].nftType;
        return string(abi.encodePacked(webUrl,"/nft/img/", getStr(tokenId), ".png"));
   }
  
  function getBlockTime() public view returns(uint256){
    return block.timestamp;
  }

  function modify(
          uint256 _tokenId,
          uint16 _nftType,
          uint16 _hp,
          uint16 _atk,
          uint16 _def,
          uint16 _spd,
          string calldata _uri
   )
          external
          onlyOwner
   {        
          super._setTokenUri(_tokenId, _uri);
          super._setTokenAttributes(_tokenId,_nftType,_hp,_atk,_def,_spd);
   }

function setBaseGasFee(uint256 _baseGasFee)  public onlyOwner
   {        
      baseGasFee = _baseGasFee;
   }
     
}