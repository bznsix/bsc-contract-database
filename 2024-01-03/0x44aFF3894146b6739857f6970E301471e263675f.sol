//SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma abicoder v2;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IPORTAL {
    function getListingPrice() external view returns (uint256);
    function tokenWhitelist(address _tokenAddress) external view returns (bool);
    function pricingEnabled() external view returns (bool);
    function feeCollector() external view returns (address);
    function dailyBountyMAX() external view returns (address);
    function listingCost() external view returns (address);
    function MSFY() external view returns (address);
    function userTokenManifest(address _address, address _token) external view returns (bool);
}

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract Ownable is Context {
    address payable public owner;
    bool _enabled;
    bool _disabled;
    event TransferredOwnership(address _previous, address _next, uint256 _time);
    event AddedPlatformAddress(address _platformAddress, uint256 _time);
    event RemovedPlatformAddress(address _platformAddress, uint256 _time);
    modifier onlyOwner() {
        require(_msgSender() == owner, "Owner only");
        _;
    }
    modifier onlyPlatform() {
        require(platformAddress[_msgSender()] == true, "Only Platform");
        _;
    }
    modifier enabled() {
        require(_enabled == true, "Currently Disabled");
        _;
    }
    modifier disable() {
        require(_disabled == false, "Currently Disabled");
        _;
    }
    mapping(address => bool) platformAddress;
    constructor() {
        owner = _msgSender();
    }
    function transferOwnership(address payable _owner) public onlyOwner() {
        address previousOwner = owner;
        owner = _owner;
        emit TransferredOwnership(previousOwner, owner, block.timestamp);
    }
    function addPlatformAddress(address _platformAddress) public onlyOwner() {
        require(platformAddress[_platformAddress] == false, "already platform address");
        platformAddress[_platformAddress] = true;

        emit AddedPlatformAddress(_platformAddress, block.timestamp);
    }
    function removePlatformAddress(address _platformAddress) public onlyOwner() {
        require(platformAddress[_platformAddress] == true, "not platform address");
        platformAddress[_platformAddress] = false;

        emit RemovedPlatformAddress(_platformAddress, block.timestamp);
    }
}
library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
library Strings {
    function toString(uint256 value) internal pure returns (string memory) {
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
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = bytes1(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}

library EnumerableSet {

    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    // Bytes32Set

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

    // AddressSet

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

    // UintSet

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

    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

abstract contract ReentrancyGuard {
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

contract MasterKeyStaking is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;
    IERC20 public MSFY;
    IPORTAL public Portal;
    address public BBB; //Change this to the BBB Wallet

    uint256 public listingCost = 10 * (10 ** 18); //Listing cost for the market and to access is 10M Master Tokens

    struct stakeListing {
        address listingAddress;
        address tokenAddress;
        uint256 tokenAmount;
        uint256 bountyRate; 
        uint256 dateListed;
        bool enabled;
    }
    mapping(address => uint256) public userTotalStakes;   

    mapping(address => mapping(address => bool)) public userTokenManifest; //Mapping from user address to token address to make sure they have one listing    
    mapping(uint256 => stakeListing) public stakeId; //Public Stakign ID information for all Stake Listings.
    mapping(address => EnumerableSet.UintSet) userStakingManifest; //Listing manifest for User ID Stakings
    mapping(address => mapping(address => uint256)) public userCurrentStakeID; //Mapping from useraddress to token address gives ID of current listing
    address public feeCollector; //listing fees are sent here

    uint256 public stakeIdCounter; //Count alltime individual stake
    uint256 public activeStakes; //Count individual active stake listings
    uint256 public dailyBountyMAX =  10 * (10 ** 18); //Max reward for staking per pay period
    
    //uint256 public listingRewardTimeframe =  86400; //Timeframe for earning listing rewards
    uint256 public stakingRewardTimeframe =  86400; //Timeframe/payperiod for earning staking rewards
    uint256 public BNBListingFee = 25000000000000;
    bool public pricingEnabled = true;

    constructor() {
        MSFY = IERC20(address(0xa10E3590c4373C3Cc5d871776EF90ca1F1DD12D2)); //Token Contract
        BBB = address(0xFCF2549976D112cd29b6A52c735A3E2FD15f0367);
        Portal = IPORTAL(address(0x91413988633f071975e103C6F492C4823f660C66)); //Marketplace Address
        addPlatformAddress(msg.sender);
        feeCollector = address(0xFCF2549976D112cd29b6A52c735A3E2FD15f0367);
    }

    receive() external payable{}
    fallback() external payable {}

    modifier isHoldingXMSFY(uint256 _value) {
        require(MSFY.balanceOf(msg.sender) >= _value, "Must be holding MSFY Tokens.");
        _;
    }

    modifier BNBFeeEnabled() {
        if (pricingEnabled == true)   {
            uint256 requiredBNBBalance = Portal.getListingPrice();
            require(msg.value >= requiredBNBBalance, "Insufficient BNB Balance"); 
            _;
        } else {
            _;
        }
    }

    function setBNBFeeEnabled(bool _value) public onlyPlatform() {
        pricingEnabled = _value;
    }

    function setBBBAddress(address _value) public onlyPlatform() {
        BBB = address(_value);
    }

    function setBNBListingFee(uint256 _value) public onlyPlatform() {
        BNBListingFee = _value;
    }
    
    function setMSFYAddress(address _value) public onlyPlatform() {
        MSFY = IERC20(_value);
    }
    function setPortalAddress(address _value) public onlyPlatform() {
        Portal = IPORTAL(_value);
    }
    
    function setStakingRewardTimeframe(uint256 _value) public onlyPlatform() {
        stakingRewardTimeframe = _value;
    }

    function setFeeCollectorAddress(address _value) public onlyPlatform() {
        feeCollector = address(_value);
    }

    function getListingPrice() public view returns (uint256)  {
        return Portal.getListingPrice();
    }

    function stakeTokens(address _tokenAddress, uint256 _amount) public payable nonReentrant() isHoldingXMSFY(listingCost) BNBFeeEnabled() {
        require(userTokenManifest[msg.sender][_tokenAddress] == false, "!IsListed");
        
        IERC20 tokenContract;
        tokenContract = IERC20(_tokenAddress);
        require(Portal.tokenWhitelist(_tokenAddress) == true, "!=Whitelisted");
        require(_amount > 0, ">0");

        MSFY.transferFrom(msg.sender, BBB, listingCost);
        tokenContract.transferFrom(msg.sender, address(this), _amount);
        stakeIdCounter = stakeIdCounter.add(1);
        stakeListing memory Stake;
        uint256 bountyRate = convertDecimals(_tokenAddress, address(MSFY), _amount);
        if (bountyRate > dailyBountyMAX)   {
            bountyRate = dailyBountyMAX;
        }
        Stake = stakeListing( msg.sender, _tokenAddress, _amount, bountyRate, block.timestamp, true);
        stakeId[stakeIdCounter] = Stake;
        activeStakes = activeStakes + 1;
        userStakingManifest[msg.sender].add(stakeIdCounter);
        userCurrentStakeID[msg.sender][_tokenAddress] = stakeIdCounter;
        userTotalStakes[msg.sender] = userTotalStakes[msg.sender].add(1);
        userTokenManifest[msg.sender][_tokenAddress] = true;
        if (pricingEnabled == true)   {
            (bool success, ) = feeCollector.call{value: address(this).balance}("");
        }
    }

    function unstakeTokens(uint256 _stakeId) public payable nonReentrant() isHoldingXMSFY(listingCost) BNBFeeEnabled() {
        require(stakeId[_stakeId].listingAddress == msg.sender, "!Ownership");
        require(stakeId[_stakeId].enabled == true, "!Enabled");

        uint256 stakeReward = getStakeRewards(_stakeId);
        IERC20 tokenContract;
        tokenContract = IERC20(stakeId[_stakeId].tokenAddress);

        stakeListing memory Stake = stakeId[_stakeId];
        Stake.enabled = false;

        stakeId[_stakeId].enabled = false;

        //tokenContract.transferFrom(address(this), msg.sender, stakeId[_stakeId].tokenAmount);
        tokenContract.transfer(msg.sender, stakeId[_stakeId].tokenAmount);
        MSFY.transfer(msg.sender, stakeReward);
        MSFY.transferFrom(msg.sender, address(this), listingCost);  
		
        activeStakes = activeStakes - 1;    
        userStakingManifest[msg.sender].remove(_stakeId);  
        userTotalStakes[msg.sender] = userTotalStakes[msg.sender].sub(1);
        userTokenManifest[msg.sender][stakeId[_stakeId].tokenAddress] = false;
        if (pricingEnabled == true)   {
            (bool success , ) = feeCollector.call{value: address(this).balance}("");
        }
        stakeId[_stakeId] = Stake;
    }

    function getStakeRewards(uint256 _tokenId) public view returns (uint256) {

        uint256 datelisted = stakeId[_tokenId].dateListed;
        uint256 currenttime = block.timestamp;
        uint256 dayselapsed = ((currenttime - datelisted) / stakingRewardTimeframe);
        
        uint256 stakeReward = stakeId[_tokenId].bountyRate * dayselapsed;

        return stakeReward;
    }
    function getUserStakingManifest(address _address, uint256 cursor, uint256 size) public view returns (uint256[] memory stakeIds, uint256) {
        uint256 length = size;
        if (length > userStakingManifest[_address].length() - cursor) {
            length = userStakingManifest[_address].length() - cursor;
        }
        stakeIds = new uint[](length);
        for (uint256 i = 0; i < length; i++) {
            stakeIds[i] = userStakingManifest[_address].at(cursor + i);
        }
        return (stakeIds, cursor + length);
    }

    function convertDecimals(address _fromToken, address _toToken, uint256 _amount) public view returns (uint256) {
        return convertDecimal(_amount, getDecimals(_fromToken), getDecimals(_toToken));
    }

    function getDecimals(address _token) internal view returns (uint256) {
        return IERC20(_token).decimals();
    }

    function convertDecimal(uint256 _tokenAmount, uint256 _token1decimals, uint256 _token2decimals) internal pure returns (uint256) {
        if (_token1decimals > _token2decimals)
            return _tokenAmount / (10**(_token1decimals - _token2decimals));
        else
            return _tokenAmount * (10**(_token2decimals - _token1decimals));
    }

    function emergencyWithdrawNative(uint256 _value) public onlyPlatform() nonReentrant() {
        (bool success, ) = owner.call{value: _value}("");
        require(success, "Failed to send");
    }

    function emergencyWithdrawERC20(uint256 _value, address tokenAddress) public onlyPlatform() nonReentrant()  {
        IERC20 tokenContract;
        tokenContract = IERC20(tokenAddress);
        tokenContract.transfer(msg.sender, _value);
    }

}