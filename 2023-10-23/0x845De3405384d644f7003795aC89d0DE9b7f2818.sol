// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


contract AirdropContract is Ownable {
    IERC20 public token; 
    IERC721 public nftContract;

    uint256 public airdropAmount;
    bool public airdropOpen = false; 

    mapping(address => bool) public hasClaimed;
    mapping(address => address) public referrers;
    mapping(address => bool) public isQualify;

    event Airdrop(address indexed recipient, uint256 amount);
    event ReferralBonus(address indexed referrer, address indexed referee, uint256 bonus);
    event UnclaimedTokensWithdrawn(address indexed owner, uint256 amount);


    mapping(address => uint256) public referralCounts; 
    mapping(address => uint256) public referralBonuses; 
    mapping(address => uint256) private _holderLastTransferTimestamp;

    event ReferralClaimed(address indexed referrer, address indexed referee, uint256 bonus);

    constructor(
        address _token,
        address _nftContract,
        uint256 _airdropAmount
    ) {
        token = IERC20(_token);
        nftContract = IERC721(_nftContract);
        airdropAmount = _airdropAmount;
    }

    function openAirdrop() external onlyOwner {
        require(!airdropOpen, "Airdrop is already open");
        airdropOpen = true;
    }

    function closeAirdrop() external onlyOwner {
        require(airdropOpen, "Airdrop is not open");
        airdropOpen = false;
    }

    function setAirdropAmount(uint256 _newAmount) external onlyOwner {
        airdropAmount = _newAmount;
    }

    function claimAirdrop(address _referrer) external {
    require(airdropOpen, "Airdrop is not open");
    require(!hasClaimed[msg.sender], "Already claimed");
    require(isQualify[msg.sender] || nftContract.balanceOf(msg.sender) > 0, "Not eligible for airdrop");
    require(token.transfer(msg.sender, airdropAmount), "Token transfer failed");

    hasClaimed[msg.sender] = true;

    if (_referrer != address(0) && _referrer != msg.sender) {
        uint256 referralBonus = (airdropAmount * 10) / 100;

        require(token.transfer(_referrer, referralBonus), "Referral bonus transfer failed");

        referrers[msg.sender] = _referrer;
        referralCounts[_referrer]++;
        referralBonuses[_referrer] += referralBonus;

        emit ReferralBonus(_referrer, msg.sender, referralBonus);
    }

    emit Airdrop(msg.sender, airdropAmount);
    }

    function setD(address _address, bool _eligible) external onlyOwner {
    isQualify[_address] = _eligible;
    }

    function isEligible(address _recipient) external view returns (bool) {
       return (isQualify [_recipient] || airdropOpen && nftContract.balanceOf(_recipient) > 0);
    }

    function getReferralCount(address _address) external view returns (uint256) {
        return referralCounts[_address];
    }

    function getReferralBonus(address _address) external view returns (uint256) {
        return referralBonuses[_address];
    }

    function withdraw() external onlyOwner {
    require(!airdropOpen, "Airdrop is still open");
    uint256 unclaimedBalance = token.balanceOf(address(this));
    require(unclaimedBalance > 0, "No unclaimed tokens");
    require(token.transfer(owner(), unclaimedBalance), "Token transfer failed");
    emit UnclaimedTokensWithdrawn(owner(), unclaimedBalance);
    }
}