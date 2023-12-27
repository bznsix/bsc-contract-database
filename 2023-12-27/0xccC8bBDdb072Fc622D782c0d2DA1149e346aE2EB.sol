// SPDX-License-Identifier: GPL 3
pragma solidity >= 0.8.0 <0.9.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC1155 is IERC165 {
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);
    event URI(string value, uint256 indexed id);
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function balanceOfBatch(
        address[] calldata accounts,
        uint256[] calldata ids
    ) external view returns (uint256[] memory);
    function setApprovalForAll(address operator, bool approved) external;
    function isApprovedForAll(address account, address operator) external view returns (bool);
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}
// File: contracts/interfaces/IERC721.sol



pragma solidity >= 0.8.0 <0.9.0;


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

interface InterfaceLootbox is IERC1155 {
    function mintTo(address to, uint256 tokenId, uint256 amount) external;
}

contract PolyhedraQorpoReward {
    address public polyhedraNFT;
    address public rewardSC;
    uint256 public rewardTokenId;
    uint256 public rewardAmount;
    mapping(uint256 => bool) claimedRewards;


    constructor (address polyhedraNFT_, address rewardSC_, uint256 rewardTokenId_, uint256 rewardAmount_){
        polyhedraNFT = polyhedraNFT_;
        rewardSC = rewardSC_;
        rewardTokenId = rewardTokenId_;
        rewardAmount = rewardAmount_;
    }


    function claimReward(uint256 tokenId) public {
        require(claimedRewards[tokenId] == false, "QorpoReward: Reward already claimed for this item!");
        claimedRewards[tokenId] = true;
        require(IERC721(polyhedraNFT).ownerOf(tokenId) == msg.sender, "QorpoReward: You are not the owner of the NFT!");
        InterfaceLootbox(rewardSC).mintTo(msg.sender, rewardTokenId, rewardAmount);
    }

    function isClaimed(uint256 tokenId) public view returns(bool){
        return claimedRewards[tokenId];
    }


}