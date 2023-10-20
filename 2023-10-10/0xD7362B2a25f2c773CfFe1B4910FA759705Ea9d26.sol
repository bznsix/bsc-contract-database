// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

   
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }


    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}// SPDX-License-Identifier: MIT
pragma solidity >= 0.6.6;
pragma experimental ABIEncoderV2;

import './interfaces/IERC20.sol';
import './lib/SafeMath.sol';
import "./open/utils/Initializable.sol";
import "./open/utils/Ownable.sol";
import "./open/lib/EnumerableSet.sol";
import "./open/token/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;
}

contract MarketCore is Initializable,Ownable{
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
   
    struct Market{
        address nft;
        uint nftLevel;
        uint priceAmount;
        address priceToken;
        uint surplusAmount;
        address receiver;
    }

    Market[] public markets;

    struct Play{
        uint playNeedToken;
        uint playWinGain;
        uint playLoseGain;
    }

    Play[] public plays;

    EnumerableSet.AddressSet sellableNfts;

    struct Price{
        address token;
        uint amount;
    }
    mapping(address => mapping(uint => Price)) public nftLevel2Prices;

    IERC1155 public nToken;    
    IERC20 public payToken;
    mapping(address => mapping(uint => uint)) playTimesLimits;
    uint public perDayPlayLimit = 3;
    uint public playNeedToken = 1000000000e18;
    uint public playWinGain = 1800000000e18;
    uint public playLoseGain = 10000000e18;

    uint internal acce = 100;

    mapping(bytes32 => uint) public playResultMap;

    constructor() public {}

    function initialize(
         address _nftToken,
        address _payToken
    ) public initializer {
        _owner = msg.sender;
        nToken = IERC1155(_nftToken);
        payToken = IERC20(_payToken);
        perDayPlayLimit = 3;
        acce = 100;

        plays.push(Play(10000e18,30000e18,2000e18));
        plays.push(Play(15000e18,40000e18,3000e18));
        plays.push(Play(20000e18,50000e18,4000e18));
        plays.push(Play(25000e18,60000e18,5000e18));
    }

    function setPlayInfo(uint _playNeedToken,uint _playWinGain,uint _playLoseGain)external onlyOwner{
        playNeedToken = _playNeedToken;
        playWinGain = _playWinGain;
        playLoseGain = _playLoseGain;

    }

    struct PlayInfo{
        uint playNeedToken;
        uint playWinGain;
        uint playLoseGain;
        uint surplusTimes;
    }
    function getPlayInfo(address owner)external view returns(PlayInfo memory info){
        info.playNeedToken = playNeedToken;
        info.playWinGain = playWinGain;
        info.playLoseGain = playLoseGain;
        uint time = block.timestamp / 1 days * 1 days;
        info.surplusTimes = perDayPlayLimit - playTimesLimits[owner][time];
    }

    function play(uint tokenId,bytes32 flag)external {
        require(!_isContract(msg.sender),"not allow");

        require(nToken.balanceOf(address(this),tokenId) > 0 ,"not owner");

        uint time = block.timestamp / 1 days * 1 days;

        require(playTimesLimits[msg.sender][time] < perDayPlayLimit,"not times");

        playTimesLimits[msg.sender][time] += 1;

        payToken.transferFrom(msg.sender, address(this), playNeedToken);

        bool isWin = _randomWin();

        uint v = isWin ? playWinGain : playLoseGain;
        payToken.transfer(msg.sender, v);
        playResultMap[flag] = v;
    }

    function playPK(uint index ,uint tokenId,bytes32 flag)external {
        require(!_isContract(msg.sender),"not allow");

        require(nToken.balanceOf(address(this),tokenId) > 0 ,"not owner");

        uint time = block.timestamp / 1 days * 1 days;

        require(playTimesLimits[msg.sender][time] < perDayPlayLimit,"not times");

        Play storage p = plays[index];

        playTimesLimits[msg.sender][time] += 1;

        payToken.transferFrom(msg.sender, address(this), p.playNeedToken);

        bool isWin = _randomWin();

        uint v = isWin ? p.playWinGain : p.playLoseGain;
        payToken.transfer(msg.sender, v);
        playResultMap[flag] = v;
    }

    function _randomWin()internal returns(bool){
        uint256 seed = uint256(keccak256(abi.encodePacked(block.coinbase,block.timestamp,acce)));
        uint v = seed % 100;
        acce += v;
        return v > 69;
    }   


    function MSetPrice(address nft,uint level,address token,uint amount)external onlyOwner{
        Price storage price = nftLevel2Prices[nft][level];
        price.token = token;
        price.amount = amount;
        return;
    }

    function MUpdateMarket(uint index,uint price,uint amount)external onlyOwner{
        Market storage m = markets[index];
        m.priceAmount = price;
        m.surplusAmount = amount;

    }
 

    function MAddMarket(address nft,uint level,uint price,address token,uint amount,address receiver)external onlyOwner{
         markets.push( Market(nft,level,price,token,amount,receiver));
         nftLevel2Prices[nft][level] = Price(token,price);
        if( !sellableNfts.contains(nft) ){
            sellableNfts.add(nft);
        }   
    }

    function getSellPrice(address nft)external view returns(uint[] memory levels,uint[] memory prices){
        prices = new uint[](8);
        for( uint i = 0; i < 8; i++ ){
            prices[i] = nftLevel2Prices[nft][levels[i]].amount;
        }
    }

    function getMarketInfos()external view returns(Market[] memory){
        return markets;
    }

    function buy(uint index)external{
        require(!_isContract(msg.sender),"not allow");

        Market storage m = markets[index];
        require(m.nft != address(0),"not init");

        require(m.surplusAmount > 0,"value lock");
        m.surplusAmount --;

        IERC20(m.priceToken).transferFrom(msg.sender, m.receiver, m.priceAmount);

        IERC1155(m.nft).safeTransferFrom(address(this),msg.sender, m.nftLevel,1,"");
        return;
    }

    function nftSwap(address nft,uint id)external{

        require(sellableNfts.contains(nft),"not allow");

        IERC1155(nft).safeTransferFrom(msg.sender, address(this), id,1,"");

        Price storage p = nftLevel2Prices[nft][id];

        if( p.token != address(0)){
            IERC20(p.token).transfer(msg.sender, p.amount);
        }
    }

     function _isContract(address a) internal view returns(bool){
        uint256 size;
        assembly {size := extcodesize(a)}
        return size > 0;
    }

    function addNft(address nft)external onlyOwner{
        if( !sellableNfts.contains(nft) ){
            sellableNfts.add(nft);
        }
   }

   function delNft(address nft)external onlyOwner{
        if( sellableNfts.contains(nft) ){
            sellableNfts.remove(nft);
        }
   }

   function getTradeableNfts()external view returns(address[] memory rts){
         uint len = sellableNfts.length();
        rts = new address[](len);
        for( uint i = 0; i < len; i++ ){
            rts[i] = sellableNfts.at(i);
        }
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public pure returns (bytes4) {
        return this.onERC721Received.selector;
    }

    receive() external payable {}

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.5.0;


library EnumerableSet {
   
    struct Set {
        bytes32[] _values;
        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

    
            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    function _indexOf(Set storage set, bytes32 value) private view returns(uint){
        return set._indexes[value];
    }

    
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    struct Bytes32Set {
        Set _inner;
    }

    
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }


    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

   
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    struct AddressSet {
        Set _inner;
    }

    
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }


    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

   
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

   
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    struct UintSet {
        Set _inner;
    }

    
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

     function indexOf(UintSet storage set, uint256 value) internal view returns (uint) {
        return _indexOf(set._inner, bytes32(value));
    }
    
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() public {}

    function _msgSender() internal view returns (address ) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */

     //|| _isConstructor()
    modifier initializer() {
        require(_initializing  || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    function _isConstructor() private view returns (bool) {
        address self = address(this);
        uint256 cs;
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

import "./Context.sol";

contract Ownable is Context {
    
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

   
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

   
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

   
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}