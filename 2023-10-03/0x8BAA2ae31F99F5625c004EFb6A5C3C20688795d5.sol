/* SPDX-License-Identifier: MIT */
pragma solidity 0.8.19;
library AddressUtils
{
function isContract(
address _addr
)
internal
view
returns (bool addressCheck)
{
bytes32 codehash;
bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
assembly { codehash := extcodehash(_addr) }
addressCheck = (codehash != 0x0 && codehash != accountHash);
}
}
interface ERC165
{
function supportsInterface(
bytes4 _interfaceID
)
external
view
returns (bool);
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
interface ERC721Enumerable
{
function totalSupply()
external
view
returns (uint256);
function tokenByIndex(
uint256 _index
)
external
view
returns (uint256);
function tokenOfOwnerByIndex(
address _owner,
uint256 _index
)
external
view
returns (uint256);
}
interface ERC721Metadata
{
function name()
external
view
returns (string memory _name);
function symbol()
external
view
returns (string memory _symbol);
function tokenURI(uint256 _tokenId)
external
view
returns (string memory);
}
interface ERC721TokenReceiver
{
function onERC721Received(
address _operator,
address _from,
uint256 _tokenId,
bytes calldata _data
)
external
returns(bytes4);
}
contract SupportsInterface is
ERC165
{
mapping(bytes4 => bool) internal supportedInterfaces;
constructor()
{
supportedInterfaces[0x01ffc9a7] = true;
}
function supportsInterface(
bytes4 _interfaceID
)
external
override
view
returns (bool)
{
return supportedInterfaces[_interfaceID];
}
}
contract NFToken is
ERC721,
SupportsInterface
{
using AddressUtils for address;
string constant ZERO_ADDRESS = "003001";
string constant NOT_VALID_NFT = "003002";
string constant NOT_OWNER_OR_OPERATOR = "003003";
string constant NOT_OWNER_APPROVED_OR_OPERATOR = "003004";
string constant NOT_ABLE_TO_RECEIVE_NFT = "003005";
string constant NFT_ALREADY_EXISTS = "003006";
string constant NOT_OWNER = "003007";
string constant IS_OWNER = "003008";
bytes4 internal constant MAGIC_ON_ERC721_RECEIVED = 0x150b7a02;
mapping (uint256 => address) internal idToOwner;
mapping (uint256 => address) internal idToCreator;
mapping (uint256 => address) internal idToApproval;
mapping (address => uint256) private ownerToNFTokenCount;
mapping (address => mapping (address => bool)) internal ownerToOperators;
modifier canOperate(
uint256 _tokenId
)
{
address tokenOwner = idToOwner[_tokenId];
require(
tokenOwner == msg.sender || ownerToOperators[tokenOwner][msg.sender],
NOT_OWNER_OR_OPERATOR
);
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
NOT_OWNER_APPROVED_OR_OPERATOR
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
{
supportedInterfaces[0x80ac58cd] = true;
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
ownerToNFTokenCount[_from] -= 1;
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
ownerToNFTokenCount[_to] += 1;
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
delete idToApproval[_tokenId];
}
}
contract NFTokenEnumerable is
NFToken,
ERC721Enumerable
{
string constant INVALID_INDEX = "005007";
uint256[] internal tokens;
mapping(uint256 => uint256) internal idToIndex;
mapping(address => uint256[]) internal ownerToIds;
mapping(uint256 => uint256) internal idToOwnerIndex;
constructor()
{
supportedInterfaces[0x780e9d63] = true;
}
function totalSupply()
external
override
view
returns (uint256)
{
return tokens.length;
}
function tokenByIndex(
uint256 _index
)
external
override
view
returns (uint256)
{
require(_index < tokens.length, INVALID_INDEX);
return tokens[_index];
}
function tokenOfOwnerByIndex(
address _owner,
uint256 _index
)
external
override
view
returns (uint256)
{
require(_index < ownerToIds[_owner].length, INVALID_INDEX);
return ownerToIds[_owner][_index];
}
function _mint(
address _to,
uint256 _tokenId
)
internal
override
virtual
{
super._mint(_to, _tokenId);
tokens.push(_tokenId);
idToIndex[_tokenId] = tokens.length - 1;
}
function _burn(
uint256 _tokenId
)
internal
override
virtual
{
super._burn(_tokenId);
uint256 tokenIndex = idToIndex[_tokenId];
uint256 lastTokenIndex = tokens.length - 1;
uint256 lastToken = tokens[lastTokenIndex];
tokens[tokenIndex] = lastToken;
tokens.pop();
idToIndex[lastToken] = tokenIndex;
idToIndex[_tokenId] = 0;
}
function _removeNFToken(
address _from,
uint256 _tokenId
)
internal
override
virtual
{
require(idToOwner[_tokenId] == _from, NOT_OWNER);
delete idToOwner[_tokenId];
uint256 tokenToRemoveIndex = idToOwnerIndex[_tokenId];
uint256 lastTokenIndex = ownerToIds[_from].length - 1;
if (lastTokenIndex != tokenToRemoveIndex)
{
uint256 lastToken = ownerToIds[_from][lastTokenIndex];
ownerToIds[_from][tokenToRemoveIndex] = lastToken;
idToOwnerIndex[lastToken] = tokenToRemoveIndex;
}
ownerToIds[_from].pop();
}
function _addNFToken(
address _to,
uint256 _tokenId
)
internal
override
virtual
{
require(idToOwner[_tokenId] == address(0), NFT_ALREADY_EXISTS);
idToOwner[_tokenId] = _to;
ownerToIds[_to].push(_tokenId);
idToOwnerIndex[_tokenId] = ownerToIds[_to].length - 1;
}
function _getOwnerNFTCount(
address _owner
)
internal
override
virtual
view
returns (uint256)
{
return ownerToIds[_owner].length;
}
}
contract NFTokenMetadata is
NFToken,
ERC721Metadata
{
string internal nftName;
string internal nftSymbol;
mapping (uint256 => string) internal idToUri;
constructor()
{
supportedInterfaces[0x5b5e139f] = true;
}
function name()
external
override
view
returns (string memory _name)
{
_name = nftName;
}
function symbol()
external
override
view
returns (string memory _symbol)
{
_symbol = nftSymbol;
}
function tokenURI(
uint256 _tokenId
)
external
override
view
validNFToken(_tokenId)
returns (string memory)
{
return idToUri[_tokenId];
}
function _burn(
uint256 _tokenId
)
internal
override
virtual
{
super._burn(_tokenId);
delete idToUri[_tokenId];
}
function _setTokenUri(
uint256 _tokenId,
string memory _uri
)
internal
validNFToken(_tokenId)
{
idToUri[_tokenId] = _uri;
}
}
contract Ownable
{
string public constant NOT_CURRENT_OWNER = "018001";
string public constant CANNOT_TRANSFER_TO_ZERO_ADDRESS = "018002";
address public owner;
event OwnershipTransferred(
address indexed previousOwner,
address indexed newOwner
);
constructor()
{
owner = msg.sender;
}
modifier onlyOwner()
{
require(msg.sender == owner, NOT_CURRENT_OWNER);
_;
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
interface IBEP20 {
function getOwner() external view returns (address);
function name() external view returns (string memory);
function symbol() external view returns (string memory);
function totalSupply() external view returns (uint256);
function decimals() external view returns (uint8);
function balanceOf(address account) external view returns (uint256);
function approve(address spender, uint256 amount) external returns (bool);
function transfer(address recipient, uint256 amount) external returns (bool);
function allowance(address _owner, address spender) external view returns (uint256);
function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract ETPOSNFT is NFTokenMetadata, Ownable {event MintNFT(address indexed minter, uint price, uint nftID, string uri);address private _owner;uint256 private nftPrice;mapping (uint256 => IBEP20) private tokens;address private _storage;uint256 private _totalMinted;constructor (string memory _name, string memory _symbol, uint256 _price) {_owner = msg.sender;nftName = _name;nftSymbol = _symbol;nftPrice = _price*(10**18);tokens[1] = IBEP20(0x55d398326f99059fF775485246999027B3197955);tokens[2] = IBEP20(0x0000000000000000000000000000000000000000);tokens[3] = IBEP20(0x0000000000000000000000000000000000000000);tokens[4] = IBEP20(0x0000000000000000000000000000000000000000);tokens[5] = IBEP20(0x0000000000000000000000000000000000000000);_storage = address(0x73d45b56bd57dD89A8276298e8C77D0377a816c1);}function safeTransferFrom(IBEP20 token, address sender, address recipient, uint256 amount) private {bool sent = token.transferFrom(sender, recipient, amount);require(sent, "Token transfer failed");}function getName() external view returns (string memory) {return nftName;}function getSymbol() external view returns (string memory) {return nftSymbol;}function getPrice() external view returns (uint256) {return nftPrice;}function setPrice(uint256 _price) external returns (bool) {require(msg.sender == _owner, "Error : Sender Not Owner !");nftPrice = _price*(10**18);return true;}function getToken(uint256 _token) external view returns (address) {return address(tokens[_token]);}function setToken(uint256 _token, address _newToken) external returns (bool) {require(msg.sender == _owner, "Error : Sender Not Owner !");tokens[_token] = IBEP20(_newToken);return true;}function getTotalMinted() external view returns (uint256) {return _totalMinted;}function getStorage() external view returns (address) {return address(_storage);}function setStorage(address _newAddr) external returns (bool) {require(msg.sender == _owner, "Error : Sender Not Owner !");_storage = address(_newAddr);return true;}function getFactory() external view returns (address) {return _owner;}function setFactory(address _newOwner) external returns (bool) {require(msg.sender == _owner, "Error : Sender Not Owner !");_owner = _newOwner;return true;}function getNftOwner(uint256 _tokenId) external view returns (address) {return idToOwner[_tokenId];}function getNextID() external view returns (uint256) {return _totalMinted + 1;}function mintNFT(uint256 _tokenId, uint256 _method, string calldata _uri) external returns (bool) {require(idToOwner[_tokenId] == address(0), NOT_VALID_NFT);uint256 _nextId = _totalMinted + 1;require(_nextId == _tokenId, "Error : Invalid ID !");IBEP20 token = tokens[_method];address payable _company = payable(_storage);require(token.allowance(msg.sender, address(this)) >= nftPrice, "BEP20 : Allowance Too Low !");safeTransferFrom(token, msg.sender, address(this), nftPrice);token.transfer(_company, nftPrice);super._mint(msg.sender, _tokenId);super._setTokenUri(_tokenId, _uri);idToOwner[_tokenId] = msg.sender;_totalMinted = _totalMinted + 1;emit MintNFT(msg.sender, nftPrice, _tokenId, idToUri[_tokenId]);return true;}function sendNFT(uint256 _tokenId) external returns (bool) {require(idToOwner[_tokenId] != address(0), NOT_VALID_NFT);require(idToOwner[_tokenId] == msg.sender, "Error : Not NFT Owner !");_transfer(_storage, _tokenId);idToOwner[_tokenId] = _storage;return true;}function transfer(uint256 _tokenId, address _recipient) external returns (bool) {require(idToOwner[_tokenId] != address(0), NOT_VALID_NFT);require(idToOwner[_tokenId] == msg.sender, "Error : Not NFT Owner !");_transfer(_recipient, _tokenId);idToOwner[_tokenId] = _recipient;return true;}}