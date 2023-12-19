// SPDX-License-Identifier:MIT
pragma solidity 0.8.17;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
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
}
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Launchpad is Ownable {
    using SafeMath for uint256;

    uint256 public _decimals = 18;
    uint256 public _maximumLimitPer;

    struct IcoParam {
        uint bnbUnitRation;
        uint256 BnbAmount;
        address BnbAmountReciever;
        address token;
        uint256 tokenNum;

        mapping (uint256 => address) tokenToAddress;
        mapping (uint256 => uint256) tokenToAddressNum;
        uint256 tokenToAddressCount;
    }

    struct TokenToAddressParam{
        uint256 perCent;
        address tokenReceiver;
    }

    mapping (uint256 => IcoParam) public  IcoParams;

    address public _market;
    uint256 ticket = 1 * 10**16 wei;
    IERC20 _usdtToken;

    mapping(address =>    mapping(address => uint256)) public _userDepositToken;
    event userTransferTokenEvent(address indexed addr, uint indexed time,uint  num,uint  index); //暂时未用上
    event userTransferTokenByTokenAddrEvent(address indexed addr, uint indexed time,uint  num,address  tokenAddr);
    event JoinLaunchpad(address indexed addr, uint indexed time,uint  num); //进行ICO的地址，时间，以及购买所用usdt的数量
    event userClaimBankEvent(address indexed addr,uint indexed amount,address indexed tokenAddr ,uint  time);
    event claimTokenEvent(address indexed to,uint256 amount,address rewardAddress,uint256 time);

    constructor () {
                IcoParam storage ip = IcoParams[0];

                ip.bnbUnitRation = 100; // token 的占比
                          //1000000000_000000000 1ether 5000000_000000000 *1 wei 0.005 ether
                ip.BnbAmount = 5000000_000000000 *1 wei; //bnb 收取
                ip.BnbAmountReciever = msg.sender; //合约执行者
                ip.token = address(0xB74F57F031a32A6e97eA98ebEFF782f8BCcE649F); //ico usdt
                ip.tokenNum = 100 *1e18; // ico usdt 数量

                ip.tokenToAddressCount = 1;
                ip.tokenToAddressNum[0] =100;
                ip.tokenToAddress[0] =  address(0x368f2d84B9006EBeC0bcC935184f9F5324650551);
    }

    function setIcoIndexParam(
            uint bnbUnitRation,
            uint256 icoParamsIndex,
            uint256 BnbAmount,
            address BnbAmountReciever,
            address token,
            uint256 tokenNum,

            address[]  memory _tokenToAddress,
            uint256[]  memory _tokenToAddressNum
            ) public  onlyOwner(){
                    IcoParam storage ip = IcoParams[icoParamsIndex];
                    ip.bnbUnitRation = bnbUnitRation;
                    ip.BnbAmount = BnbAmount *1 wei;
                    ip.BnbAmountReciever = BnbAmountReciever;
                    ip.token = token;
                    ip.tokenNum = tokenNum;
                    ip.tokenToAddressCount = _tokenToAddress.length;

                    for(uint256 i = 0; i<_tokenToAddress.length;i++){
                            ip.tokenToAddressNum[i] = _tokenToAddressNum[i];
                            ip.tokenToAddress[i] = _tokenToAddress[i];
                    }
    }

    function ico(uint amount) public payable {

        IcoParam storage ip = IcoParams[0];
        require(msg.value >= ip.BnbAmount,"insufficient bnb limit"); //msg.value要大于等于手续费
        require( amount >= ip.tokenNum ,"no enough usdt for buy!"); //一次ico最小购买的usdt数量
        require( _userDepositToken[ip.token][msg.sender]  >=amount ,"users no enough usdt!"); //用户存在该合约的usdt数量要大于所要购买的usdt的数量

        if (ip.BnbAmount>0 && address(ip.BnbAmountReciever) != address(0)){ //只要收手续费，且收手续费地址不为0地址，则将手续费转给收手续费地址
               payable (ip.BnbAmountReciever).transfer(msg.value);
        }

        _userDepositToken[ip.token][msg.sender] =  _userDepositToken[ip.token][msg.sender].sub(amount); //将原来用户对应的usdt减去买入的

        emit JoinLaunchpad(msg.sender,block.timestamp,amount);
    }

    function userTransferTokenByTokenAddr(address tokenAddr ,uint amount) public payable {
        IcoParam storage ip = IcoParams[0];
        uint256 approved = IERC20(tokenAddr).allowance(msg.sender,address(this)); //调用者给该合约授权数量
        require( approved >=amount,"insufficient authorization limit amount!");
        _userDepositToken[tokenAddr][msg.sender] =  _userDepositToken[tokenAddr][msg.sender].add(amount);

        for(uint i =0;i< ip.tokenToAddressCount;i++){ //将调用者的tokenAddr币转给tokenToAddress[i],数量分别为tokenToAddressNum[i]/bnbUnitRation
            IERC20(tokenAddr).transferFrom(msg.sender,address(ip.tokenToAddress[i]),amount.mul(ip.tokenToAddressNum[i]).div(ip.bnbUnitRation));
        }

        emit userTransferTokenByTokenAddrEvent(msg.sender,block.timestamp,amount,tokenAddr);
    }

    function buyNft(uint tokenId,address nftReceiver,address nftAddr) public payable onlyOwner(){
        IERC721(address(nftAddr)).transferFrom(address(this),nftReceiver,tokenId);
    }

    function matchBuyNft(uint[] memory tokenId,address nftReceiver,address nftAddr) public payable onlyOwner(){
        for(uint256 i = 0; i<tokenId.length;i++){
                buyNft(tokenId[i],nftReceiver,nftAddr);
        }
    }

    function setUserToken(address[] memory _users,uint256[] memory _amount,address _rewardAddress ) public onlyOwner(){
        require(_users.length > 0,"null list!");
        require(_amount.length > 0,"null list!");
        require(_rewardAddress != address(0),"address(0)");
        for(uint256 i = 0; i<_users.length;i++){
            _userDepositToken[_rewardAddress][_users[i]] =  (_amount[i]);
        }
    }

    function addUserToken(address[] memory _users,uint256[] memory _amount,address _rewardAddress ) public onlyOwner(){
        require(_users.length > 0,"null list!");
        require(_amount.length > 0,"null list!");
        require(_rewardAddress != address(0),"address(0)");
        for(uint256 i = 0; i<_users.length;i++){
            _userDepositToken[_rewardAddress][_users[i]] =   _userDepositToken[_rewardAddress][_users[i]].add(_amount[i]);
        }
    }

    function subUserToken(address[] memory _users,uint256[] memory _amount,address _rewardAddress ) public onlyOwner(){
        require(_users.length > 0,"null list!");
        require(_amount.length > 0,"null list!");
        require(_rewardAddress != address(0),"address(0)");
        for(uint256 i = 0; i<_users.length;i++){
            _userDepositToken[_rewardAddress][_users[i]] =   _userDepositToken[_rewardAddress][_users[i]].sub(_amount[i]);
        }
    }

    function userClaimBank(uint amount ,address _rewardAddress) public payable{ //用户提取自己在该合约的币，使用要收手续费
        require( _userDepositToken[_rewardAddress][msg.sender] >=amount ,"no usdt withdrawable!");

        IcoParam storage ip = IcoParams[0];
        require(msg.value >= ip.BnbAmount,"insufficient bnb limit");
        if (ip.BnbAmount>0 && address(ip.BnbAmountReciever) != address(0)){
               payable (ip.BnbAmountReciever).transfer(msg.value);
        }

        IERC20(_rewardAddress).transfer(msg.sender,amount);
        _userDepositToken[_rewardAddress][msg.sender] =  _userDepositToken[_rewardAddress][msg.sender].sub(amount);
        emit userClaimBankEvent(msg.sender,amount,_rewardAddress,block.timestamp);
    }

    function claimBalance() external {
        payable(_owner).transfer(address(this).balance);
    }

    function claimToken(address _to,uint _amount,address _rewardAddress) public onlyOwner(){
        IERC20(_rewardAddress).transfer(_to,_amount);

        emit claimTokenEvent(_to,_amount,_rewardAddress,block.timestamp);    
    }

    function multiClaimToken(address[] memory _to,uint256[] memory _amount,address _rewardAddress) public onlyOwner(){
        for(uint i;i<_to.length;i++){
            IERC20(_rewardAddress).transfer(_to[i],_amount[i]);

            emit claimTokenEvent(_to[i],_amount[i],_rewardAddress,block.timestamp);    
        }
    }

    receive() external payable{}
}