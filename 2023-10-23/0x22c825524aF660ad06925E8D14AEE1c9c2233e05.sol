// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
interface IERC721 is IERC165 {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;

    function setApprovalForAll(address operator, bool _approved) external;

    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);
}
library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
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
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
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
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
abstract contract Pausable is Context, Ownable {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    function pause() public virtual onlyOwner {
        _pause();
    }

    function unPause() public virtual onlyOwner {
        _unpause();
    }
}
contract FexRaceStaking is Ownable,Pausable {
    using SafeMath for uint256;

    uint256 public stakingDurationTime;

    struct StakedNFT {
        address nftContract;
        uint256 tokenId;
        uint256 startTime;
        uint256 endTime;
    }

    mapping(address => StakedNFT[]) private userStakedNFTs;
    mapping(address => bool) private allowedNFTContracts;
    
    event Staked(address indexed user, address indexed nftContract, uint256 indexed tokenId, uint256 startTime);
    event Unstaked(address indexed user, address indexed nftContract, uint256 indexed tokenId);

    constructor(address[] memory _nftContracts)  {
        stakingDurationTime = 1 days;
        for (uint256 i = 0; i < _nftContracts.length; i++) {
            allowedNFTContracts[_nftContracts[i]] = true;
        }
    }

    modifier onlyNFTContract(address nftContractAddress) {
        require(allowedNFTContracts[nftContractAddress] == true, "Only calls by an allowed NFT Contract are accepted");
        _;
    }

    function allowNFTContract(address _nftContract) 
    external
    onlyOwner 
    {
        require(allowedNFTContracts[_nftContract] != true, "Contract already allowed!");
        allowedNFTContracts[_nftContract] = true;
    }

    function disallowNFTContract(address _nftContract) 
    external 
    onlyOwner 
    {
        require(allowedNFTContracts[_nftContract] != false, "Contract already Disallowed!");
        allowedNFTContracts[_nftContract] = false;
    }

    function stake(address nftContractAddress, uint256 tokenId) 
    external 
    whenNotPaused()
    onlyNFTContract(nftContractAddress) 
    {
        require(msg.sender == IERC721(nftContractAddress).ownerOf(tokenId), "You don't own this NFT");

        IERC721(nftContractAddress).transferFrom(msg.sender, address(this), tokenId);
        uint256 startTime = block.timestamp; 
        StakedNFT memory newStake = StakedNFT({
            nftContract: nftContractAddress,
            tokenId: tokenId,
            startTime: startTime,
            endTime: startTime.add(stakingDurationTime)
        });
        userStakedNFTs[msg.sender].push(newStake);
    }

    function unstake(address nftContractAddress, uint256 tokenId) 
    external 
    whenNotPaused()
    onlyNFTContract(nftContractAddress) 
    {
        uint256 indexToRemove = findStakedNFTIndexByTokenId(msg.sender,nftContractAddress, tokenId);
        require(indexToRemove < userStakedNFTs[msg.sender].length, "NFT not found in staked list");
        StakedNFT storage stakedNFT = userStakedNFTs[msg.sender][indexToRemove];
        require(canUnstake(stakedNFT), "Staking duration not met");
        IERC721 nftContract = IERC721(stakedNFT.nftContract);
        nftContract.transferFrom(address(this), msg.sender, tokenId);
        
        if (indexToRemove < userStakedNFTs[msg.sender].length - 1) {
            userStakedNFTs[msg.sender][indexToRemove] = userStakedNFTs[msg.sender][userStakedNFTs[msg.sender].length - 1];
        }
        userStakedNFTs[msg.sender].pop();

        emit Unstaked(msg.sender, nftContractAddress, tokenId);
    }

    function findStakedNFTIndexByTokenId(address user, address nftContractAddress, uint256 tokenId) 
    internal 
    view 
    returns (uint256) 
    {
        StakedNFT[] storage stakedNFTs = userStakedNFTs[user];
        for (uint256 i = 0; i < stakedNFTs.length; i++) {
            if (stakedNFTs[i].nftContract == nftContractAddress && stakedNFTs[i].tokenId == tokenId) {
                return i;
            }
        }
        return stakedNFTs.length;
    }

    function canUnstake(StakedNFT memory userStake) 
    internal 
    view 
    returns (bool) 
    {
        require(userStake.startTime + stakingDurationTime <= block.timestamp, "Staking duration not met");
        return true;
    }

    function setStakingDurationTime(uint256 _duration) 
    external 
    onlyOwner 
    { stakingDurationTime = _duration.mul(1 days); }

    function isNFTContractAllowed(address _nftContract) 
    external 
    view 
    returns (bool) 
    {  return allowedNFTContracts[_nftContract]; }

    function getStakedNFTs(address user) 
    external 
    view 
    returns (StakedNFT[] memory) 
    { return userStakedNFTs[user]; }
}