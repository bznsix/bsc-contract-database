/**
 *Submitted for verification at PolygonScan.com on 2023-08-20
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

abstract contract Context {
    function _msgSender() internal virtual view returns (address payable) {
        return payable(msg.sender);
    }
    function _msgData() internal virtual view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// import ierc20 & safemath & non-standard
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
}

contract TradecoinSale  is Ownable {
    using SafeMath for uint256;
    event ClaimableAmount(address _user, uint256 _claimableAmount);
    
    IERC20 public tradeCoin;
    uint256 public rate;
    bool public presaleOver;
    mapping(address => uint256) public claimable;
    uint256 public hardcap;
    uint256 public minAmount;
    uint256 public maxAmount;
    uint256 public decimalFactor = 100000;

    mapping(address => bool) public supportedToken;
    
    address[] public participatedUsers;

    constructor(IERC20 _tradeCoin, address[] memory _tokens, uint256 _rate, uint256 _hardcap, uint256 _minAmount, uint256 _maxAmount)  {
        tradeCoin = _tradeCoin;
        rate = _rate;
        presaleOver = true;
        hardcap = _hardcap;
        minAmount = _minAmount;
        maxAmount = _maxAmount;
        for(uint i = 0; i < _tokens.length; i++){
            supportedToken[_tokens[i]] = true;
        }
    }

    function isParticipatedUser() internal view returns(bool) {
        bool isValid;
        for(uint256 i = 0 ; i < participatedUsers.length; i++){
            if(participatedUsers[i] == msg.sender){
                isValid = true;
                return isValid;
            }
        }
        return isValid;
    }

    modifier isPresaleOver() {
        require(presaleOver == true, "Seed Sale Round 1 is not over");
        _;
    }

    function getTotalParticipatedUser() public view returns(uint256){
        return participatedUsers.length;
    }

    function supportCoinModify(address _token, bool _isSupported) external onlyOwner{
        supportedToken[_token] = _isSupported;
    }

    function endPresale() external onlyOwner returns (bool) {
        presaleOver = true;
        return presaleOver;
    }

    function startPresale() external onlyOwner returns (bool) {
        presaleOver = false;
        return presaleOver;
    }

    function setMinAmount(uint256 _amount) external onlyOwner returns (uint256) {
        minAmount = _amount;
        return _amount;
    }

    function setMaxAmount(uint256 _amount) external onlyOwner returns (uint256) {
        maxAmount = _amount;
        return _amount;
    }

    function setHardcap(uint256 _hardcap) external onlyOwner returns (uint256) {
        hardcap = _hardcap;
        return _hardcap;
    }

    function setRate(uint256 _rate) external onlyOwner returns (uint256) {
        rate = _rate;
        return _rate;
    }

    function setDecimalFactor(uint256 _decimalFactor) external onlyOwner returns (uint256) {
        decimalFactor = _decimalFactor;
        return _decimalFactor;
    }
    
    function buyToken(address _token,uint256 _amount) external payable {
        // user enter amount of ether which is then transfered into the smart contract and tokens to be given is saved in the mapping
        require(presaleOver == false, "Seed Sale Round  is over you cannot buy now");
        require(supportedToken[_token], "Not valid token");
        require(_amount >= minAmount && _amount <= maxAmount, "Please enter valid amount");
        uint256 tokensPurchased = _amount.mul(rate).div(decimalFactor);

        uint256 userUpdatedBalance = claimable[msg.sender].add(tokensPurchased);

        require( _amount.add(address(this).balance) <= hardcap, "Hardcap for the tokens reached");
        IERC20(_token).transferFrom(_msgSender(), address(this), _amount);
        tradeCoin.transfer(_msgSender(), tokensPurchased);
        claimable[msg.sender] = userUpdatedBalance;

        if(!isParticipatedUser()){
            participatedUsers.push(msg.sender);
        }
        emit ClaimableAmount(msg.sender, tokensPurchased);
    }
    
    function getUsersList(uint startIndex, uint endIndex) external view returns(address[] memory userAddress, uint[] memory amount){
        uint length = endIndex.sub(startIndex);
        address[] memory _userAddress = new address[](length);
        uint[] memory _amount = new uint[](length);

        for (uint i = startIndex; i < endIndex; i = i.add(1)) {
            address user = participatedUsers[i];
            uint listIndex = i.sub(startIndex);
            _userAddress[listIndex] = user;
            _amount[listIndex] = claimable[user];
        }

        return (_userAddress, _amount);
    }


    function transferAnyERC20Tokens(address _tokenAddress, uint256 _value) external onlyOwner{
        IERC20(_tokenAddress).transfer(_msgSender(), _value);
    }
}