//SPDX-License-Identifier:MIT

pragma solidity ^0.8.9;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
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

library Counters {
    struct Counter {
        uint256 _value;
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

interface ERC721Interface {
    function ERC721Mint(
        address _to,
        uint256 _tokenId,
        string memory _tokenURI
    ) external;

    function setTokenURI(uint256 _tokenId, string memory _tokenURI) external;

    function tokenURI(uint256 tokenId) external view returns (string memory);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    function balanceOf(address owner) external view returns (uint256 balance);

    function burn(uint256 tokenId) external;
}

interface RoyaltyInterface {
    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    ) external view returns (address receiver, uint256 royaltyAmount);

    function setTokenRoyalty(
        uint256 _tokenId,
        address _receiver,
        uint96 _feeNumerator
    ) external;
}

interface ERC1155Interface {
    function ERC1155Mint(
        address _to,
        uint256 _tokenId,
        uint256 _tokenAmount,
        bytes memory _data,
        string memory _uri
    ) external;

    function setTokenURI(string memory _newTokenURI) external;

    function uri(uint256) external view returns (string memory);

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    function balanceOf(
        address account,
        uint256 id
    ) external view returns (uint256);

    function burn(address account, uint256 id, uint256 value) external;
}

interface MasterNFTInterface {
    enum membershipType {
        GENERAL,
        PROFESSIONAL,
        VIP,
        THOUGHTLEADER,
        ENTERPRISE,
        REALESTATE,
        CURRENCY
    }
    enum AccessLevel {
        PARTNER,
        SUBSCRIBER
    }
    struct accessKey {
        address Address;
        bytes32 AccessPass;
        string Api;
    }
    enum TokenType {
        ERC721,
        ERC1155
    }

    struct NFTMetadata {
        TokenType tokenType;
        membershipType typeOfMember;
        uint256 expireDate;
        accessKey acceses;
        uint256 discount;
        AccessLevel accessLevel;
        uint256 mintPrice;
        uint256 freeMint;
        uint256 tokenId;
    }
    struct MarketItem {
        uint256 tokenId;
        address seller;
        address owner;
        TokenType tokenType;
        uint256 price;
        bool sold;
        uint256 soldPrice;
        uint256 numberOfToken;
    }

    function getTokenIdToMetadata(
        uint256 _tokenId
    ) external view returns (NFTMetadata memory);

    function getAddressToTokenIdToMetadata(
        address _owner,
        uint256 _tokenId
    ) external view returns (NFTMetadata memory);

    function getTokenIdToMarketItem(
        uint256 _tokenId
    ) external view returns (MarketItem memory);

    function getTokenId() external view returns (uint256);

    function getIsOwnerOfToken(
        uint256 _id,
        address _owner
    ) external view returns (bool);

    function getEDAofToken(
        uint256 _id,
        address _owner
    ) external view returns (uint256);

    function setMetadataUpdater(address _updater) external;

    function updateMetadata(
        uint256 _tokenId,
        address _owner
    ) external returns (bool);

    function getIsListedPaymentMethod(
        address _token
    ) external view returns (bool);

    function getUserDefaultPaymentMethod(
        address _user
    ) external view returns (address);

    function getStableToLRNPrice() external view returns (uint256);
}

error Not_Token_Owner();
error Token_Not_Found();
error Membership_Expired();
error No_Free_Mint();
error Cannot_Mint_0();
error Withdraw_Failed();
error Payment_Error();
error Already_Stored();
error No_Token();
error NotListedPaymentMethod();
error NameAlreadyUsed();
error NoNFTMintingService();

contract MemberNFT is Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private tokenId;
    Counters.Counter private tokenSold;
    Counters.Counter private storeId;
    Counters.Counter private resellId;
    Counters.Counter private reSold;

    ERC721Interface private ERC721Token;
    ERC1155Interface private ERC1155Token;
    MasterNFTInterface public MasterNFT;
    IERC20 private wisdomToken;
    address private LRNToken;

    uint256 private listingFee;
    mapping(address => string) public addressToStoreDetails;
    mapping(address => uint256) public addressToStoreId;
    mapping(uint256 => StoreDetails) public storeIdToStoreDetails;
    mapping(string => address) private userNameToAddress;
    mapping(address => bool) private isStored;
    mapping(uint256 => MarketItem) private idToMarketItem;
    mapping(uint256 => MarketItem) private resellIdToMarketItem;
    mapping(uint256 => mapping(address => bool)) private isOwnerOfToken;
    mapping(uint256 => mapping(address => uint256)) private EDAofToken;
    mapping(address => address) private defaultPaymentMethod;
    mapping(uint256 => MemberMetadata) private tokenIdToMetadata;

    struct MarketItem {
        uint256 tokenId;
        address seller;
        address owner;
        TokenType tokenType;
        uint256 price;
        bool sold;
        uint256 couponPrice;
        uint256 numberOfToken;
    }

    struct accessKey {
        address Address;
        bytes32 Tag;
        string Api;
    }

    struct StoreDetails {
        address owner;
        string detailsURI;
    }

    struct MemberMetadata {
        uint256 expireDate;
        accessKey accesses;
    }

    enum TokenType {
        MemberERC721,
        MemberERC1155
    }

    event MintNFT(MemberMetadata indexed Metadata, address indexed Minter);

    event StoreCreated(string indexed URL);

    event BuyNFT(
        address indexed Buyer,
        uint256 indexed tokenId,
        uint256 indexed numberOfToken,
        bool isListed
    );

    event UserPaymentMethodUpdated(address indexed Token);

    constructor(
        address _masterNFT,
        address _wisdomToken,
        address _lrnToken,
        uint96 _lFee,
        address _721,
        address _1155
    ) {
        ERC721Token = ERC721Interface(_721);
        ERC1155Token = ERC1155Interface(_1155);
        MasterNFT = MasterNFTInterface(_masterNFT);
        MasterNFT.setMetadataUpdater(address(this));
        wisdomToken = IERC20(_wisdomToken);
        LRNToken = _lrnToken;
        listingFee = _lFee;
    }

    receive() external payable {}

    function setTokenContract(address _721, address _1155) public onlyOwner {
        ERC721Token = ERC721Interface(_721);
        ERC1155Token = ERC1155Interface(_1155);
    }

    function setMasterNFT(address _new) public onlyOwner {
        MasterNFT = MasterNFTInterface(_new);
    }

    function burnNFT(
        uint256 _tokenId,
        uint256 _numberOfToken
    ) public onlyOwner {
        MarketItem storage nft = idToMarketItem[_tokenId];
        if (nft.tokenType == TokenType.MemberERC721) {
            ERC721Token.burn(_tokenId);
        } else {
            ERC1155Token.burn(address(this), _tokenId, _numberOfToken);
        }
        delete tokenIdToMetadata[_tokenId];
        delete idToMarketItem[_tokenId];
    }

    function setTokenURI(
        TokenType _tokenType,
        uint256 _tokenId,
        string memory _newTokenURI
    ) public onlyOwner {
        if (_tokenType == TokenType.MemberERC721) {
            ERC721Token.setTokenURI(_tokenId, _newTokenURI);
        } else {
            ERC1155Token.setTokenURI(_newTokenURI);
        }
    }

    function setlistingFee(uint256 _feeP) public onlyOwner {
        listingFee = _feeP;
    }

    function withdrawAsset(
        address _ERC20token,
        address payable _to
    ) public onlyOwner {
        uint256 tokenBalance = IERC20(_ERC20token).balanceOf(address(this));
        if (tokenBalance > 0) {
            IERC20(_ERC20token).transfer(_to, tokenBalance);
        }
        (bool success, ) = _to.call{value: address(this).balance}("");
        if (!success) revert Withdraw_Failed();
    }

    function mintNFT(
        TokenType _tokenType,
        uint256 _masterNftId,
        uint96 _rAmount,
        // bool _claimFreeMint,
        MemberMetadata memory _metadata,
        uint256 _numberOfToken,
        string memory _tokenURI,
        uint256 _price,
        uint256 _couponPrice
    ) public {
        if (_numberOfToken == 0) revert Cannot_Mint_0();
        MasterNFTInterface.NFTMetadata memory data = MasterNFT
            .getAddressToTokenIdToMetadata(msg.sender, _masterNftId);
        if (!MasterNFT.getIsOwnerOfToken(_masterNftId, msg.sender))
            revert Not_Token_Owner();
        bool isClaimFreeMint;
        if (
            data.typeOfMember != MasterNFTInterface.membershipType.REALESTATE ||
            data.typeOfMember != MasterNFTInterface.membershipType.CURRENCY
        ) {
            isClaimFreeMint = MasterNFT.updateMetadata(
                _masterNftId,
                msg.sender
            );
        } else {
            revert NoNFTMintingService();
        }
        if (!isClaimFreeMint) {
            uint256 discount = data.discount;
            uint256 applyDiscount = (data.mintPrice * (100 - discount)) / 100;
            bool success;
            if (
                MasterNFT.getUserDefaultPaymentMethod(msg.sender) != address(0)
            ) {
                uint256 fee;
                if (
                    MasterNFT.getUserDefaultPaymentMethod(msg.sender) ==
                    LRNToken
                ) {
                    fee =
                        (applyDiscount * MasterNFT.getStableToLRNPrice()) /
                        10 ** 18;
                } else {
                    fee = applyDiscount;
                }
                success = IERC20(
                    MasterNFT.getUserDefaultPaymentMethod(msg.sender)
                ).transferFrom(msg.sender, address(this), fee);
            } else {
                success = wisdomToken.transferFrom(
                    msg.sender,
                    address(this),
                    applyDiscount
                );
            }
            if (!success) revert Payment_Error();
        }
        if (block.timestamp > MasterNFT.getEDAofToken(_masterNftId, msg.sender))
            revert Membership_Expired();
        tokenId.increment();
        uint256 _tokenId = tokenId.current();
        tokenIdToMetadata[_tokenId] = _metadata;
        if (_tokenType == TokenType.MemberERC721) {
            ERC721Token.ERC721Mint(address(this), _tokenId, _tokenURI);
            RoyaltyInterface(address(ERC721Token)).setTokenRoyalty(
                _tokenId,
                msg.sender,
                _rAmount
            );
        } else {
            ERC1155Token.ERC1155Mint(
                address(this),
                _tokenId,
                _numberOfToken,
                "0x00",
                _tokenURI
            );
            RoyaltyInterface(address(ERC1155Token)).setTokenRoyalty(
                _tokenId,
                msg.sender,
                _rAmount
            );
        }
        createMarketItem(
            _tokenId,
            msg.sender,
            address(this),
            _price,
            _tokenType,
            _numberOfToken,
            _couponPrice,
            false
        );
        emit MintNFT(_metadata, msg.sender);
    }

    function createMarketItem(
        uint256 _id,
        address _seller,
        address _owner,
        uint256 _price,
        TokenType _tokenType,
        uint256 _numberOfToken,
        uint256 _couponPrice,
        bool isResell
    ) private {
        if (_price <= 0) revert Payment_Error();
        if (isResell) {
            resellIdToMarketItem[resellId.current()] = MarketItem(
                _id,
                _seller,
                _owner,
                _tokenType,
                _price,
                false,
                idToMarketItem[_id].couponPrice,
                _numberOfToken
            );
        } else {
            if (_id > tokenId.current()) revert No_Token();
            idToMarketItem[_id] = MarketItem(
                _id,
                _seller,
                _owner,
                _tokenType,
                _price,
                false,
                _couponPrice,
                _numberOfToken
            );
        }
    }

    function createStore(
        string memory _userName,
        string memory _storeURI
    ) public {
        uint256 _storeId;
        StoreDetails memory _sd = StoreDetails(msg.sender, _storeURI);
        if (!isStored[msg.sender]) {
            storeId.increment();
            _storeId = storeId.current();
            isStored[msg.sender] = true;
            addressToStoreId[msg.sender] = _storeId;
        } else {
            _storeId = addressToStoreId[msg.sender];
        }
        addressToStoreDetails[msg.sender] = _storeURI;
        storeIdToStoreDetails[_storeId] = _sd;
        if (
            userNameToAddress[_userName] != address(0) &&
            userNameToAddress[_userName] != msg.sender
        ) {
            revert NameAlreadyUsed();
        }
        userNameToAddress[_userName] = msg.sender;

        emit StoreCreated(_storeURI);
    }

    function buyNft(
        uint256 _id,
        uint256 _numberOfToken,
        bool isListed
    ) public payable {
        MarketItem storage nft;
        if (isListed == true) {
            nft = resellIdToMarketItem[_id];
        } else {
            nft = idToMarketItem[_id];
        }
        bool success;
        if (defaultPaymentMethod[msg.sender] != address(0)) {
            uint256 price;
            if (defaultPaymentMethod[msg.sender] == LRNToken) {
                price =
                    (nft.price * MasterNFT.getStableToLRNPrice()) /
                    10 ** 18;
            } else {
                price = nft.price;
            }
            success = IERC20(defaultPaymentMethod[msg.sender]).transferFrom(
                msg.sender,
                address(this),
                price
            );
        } else {
            success = wisdomToken.transferFrom(
                msg.sender,
                address(this),
                nft.price
            );
        }
        if (!success) revert Payment_Error();
        MemberMetadata storage metadata = tokenIdToMetadata[_id];
        if (!isListed) {
            EDAofToken[_id][msg.sender] = block.timestamp + metadata.expireDate;
        }
        uint256 applyR = (nft.price * (100 - listingFee)) / 100;
        address _Rreceiver;
        uint256 _Ramount;

        isOwnerOfToken[_id][msg.sender] = true;
        if (nft.tokenType == TokenType.MemberERC721) {
            ERC721Token.safeTransferFrom(
                address(this),
                msg.sender,
                nft.tokenId,
                "0x00"
            );
            (_Rreceiver, _Ramount) = RoyaltyInterface(address(ERC721Token))
                .royaltyInfo(nft.tokenId, applyR);
        } else {
            ERC1155Token.safeTransferFrom(
                address(this),
                msg.sender,
                nft.tokenId,
                _numberOfToken,
                "0x00"
            );
            (_Rreceiver, _Ramount) = RoyaltyInterface(address(ERC1155Token))
                .royaltyInfo(nft.tokenId, applyR);
        }
        if (defaultPaymentMethod[msg.sender] != address(0)) {
            uint256 fee;
            if (defaultPaymentMethod[msg.sender] == LRNToken) {
                fee = (_Ramount * MasterNFT.getStableToLRNPrice()) / 10 ** 18;
            } else {
                fee = _Ramount;
            }
            if (isListed && _Rreceiver != address(this)) {
                IERC20(defaultPaymentMethod[msg.sender]).transfer(
                    _Rreceiver,
                    _Ramount
                );
                IERC20(defaultPaymentMethod[msg.sender]).transfer(
                    nft.seller,
                    applyR - _Ramount
                );
            } else {
                IERC20(defaultPaymentMethod[msg.sender]).transfer(
                    nft.seller,
                    applyR
                );
            }
        } else {
            if (isListed && _Rreceiver != address(this)) {
                wisdomToken.transfer(_Rreceiver, _Ramount);
                wisdomToken.transfer(nft.seller, applyR - _Ramount);
            } else {
                wisdomToken.transfer(nft.seller, applyR);
            }
        }

        if (nft.tokenType == TokenType.MemberERC1155) {
            nft.numberOfToken -= _numberOfToken;
            if (nft.numberOfToken == 0) {
                nft.sold = true;
                nft.price = 0;
                nft.owner = address(0);
                if (isListed) {
                    reSold.increment();
                } else {
                    tokenSold.increment();
                }
            }
        } else {
            nft.sold = true;
            nft.owner = msg.sender;
            nft.seller = address(0);
            nft.price = 0;
            if (isListed) {
                reSold.increment();
            } else {
                tokenSold.increment();
            }
        }
        emit BuyNFT(msg.sender, _id, _numberOfToken, isListed);
    }

    function resellNFT(
        uint256 _tokenId,
        uint256 _price,
        uint256 _numberOfToken
    ) public {
        isOwnerOfToken[_tokenId][msg.sender] = false;
        MarketItem memory nft = idToMarketItem[_tokenId];
        resellId.increment();
        createMarketItem(
            _tokenId,
            msg.sender,
            address(this),
            _price,
            nft.tokenType,
            nft.couponPrice,
            _numberOfToken,
            true
        );
        if (nft.tokenType == TokenType.MemberERC721) {
            ERC721Token.safeTransferFrom(
                msg.sender,
                address(this),
                _tokenId,
                "0x00"
            );
        } else {
            ERC1155Token.safeTransferFrom(
                msg.sender,
                address(this),
                _tokenId,
                _numberOfToken,
                "0x00"
            );
        }
    }

    function setUserDefaultPaymentMethod(address _token) public {
        if (!MasterNFT.getIsListedPaymentMethod(_token)) {
            revert NotListedPaymentMethod();
        }
        defaultPaymentMethod[msg.sender] = _token;
        emit UserPaymentMethodUpdated(_token);
    }

    function fetchMarketNft() public view returns (MarketItem[] memory) {
        uint256 totalItem = tokenId.current();
        uint256 unsoldItem = totalItem - tokenSold.current();
        uint256 currentIndex = 0;
        MarketItem[] memory items = new MarketItem[](unsoldItem);
        for (uint256 i = 0; i < totalItem; i++) {
            if (idToMarketItem[i + 1].owner == address(this)) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function getIsStored(address _checkAddress) public view returns (bool) {
        return isStored[_checkAddress];
    }

    function getUserNameToAddress(
        string memory _name
    ) public view returns (address) {
        return userNameToAddress[_name];
    }

    function getUserDefaultPaymentMethod(
        address _user
    ) public view returns (address) {
        return defaultPaymentMethod[_user];
    }

    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = tokenId.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (isOwnerOfToken[i + 1][msg.sender]) {
                itemCount += 1;
            }
        }
        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (isOwnerOfToken[i + 1][msg.sender]) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function fetchListedNft() public view returns (MarketItem[] memory) {
        uint256 totalItem = resellId.current();
        uint256 unsoldItem = totalItem - reSold.current();
        uint256 currentIndex = 0;
        MarketItem[] memory items = new MarketItem[](unsoldItem);
        for (uint256 i = 0; i < totalItem; i++) {
            if (resellIdToMarketItem[i + 1].owner == address(this)) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = resellIdToMarketItem[
                    currentId
                ];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function storeNFT(
        address _storeOwner
    ) public view returns (MarketItem[] memory) {
        uint256 totalItemCount = tokenId.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == _storeOwner) {
                itemCount += 1;
            }
        }
        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == _storeOwner) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function getStoreList() public view returns (StoreDetails[] memory) {
        uint256 currentStoreId = storeId.current();
        StoreDetails[] memory storeList = new StoreDetails[](currentStoreId);
        uint256 filledIndex = 0;

        for (uint256 i = 0; i < currentStoreId; i++) {
            if (storeIdToStoreDetails[i + 1].owner != address(0)) {
                StoreDetails storage currentStore = storeIdToStoreDetails[
                    i + 1
                ];
                storeList[filledIndex] = currentStore;
                filledIndex++;
            }
        }

        assembly {
            mstore(storeList, filledIndex)
        }

        return storeList;
    }

    function nftBalance(
        TokenType _tokenType,
        address _owner,
        uint256 _tokenId
    ) public view returns (uint256) {
        if (_tokenType == TokenType.MemberERC721) {
            return ERC721Token.balanceOf(_owner);
        } else {
            return ERC1155Token.balanceOf(_owner, _tokenId);
        }
    }

    function getTokenIdToMetadata(
        uint256 _tokenId
    ) external view returns (MemberMetadata memory) {
        return tokenIdToMetadata[_tokenId];
    }

    function getMasterTokenId() external view returns (uint256) {
        return MasterNFT.getTokenId();
    }

    // function getIsFreeMintAvailable(
    //     uint256 _masterNftId,
    //     address _user
    // ) public view returns (bool) {
    //     bool isClaimFreeMint = MasterNFT.updateMetadata(_masterNftId, _user);
    //     return isClaimFreeMint;
    // }

    function getTokenId() public view returns (uint256) {
        return tokenId.current();
    }

    function getTokenAddress(
        TokenType _tokenType
    ) public view returns (address) {
        if (_tokenType == TokenType.MemberERC721) {
            return address(ERC721Token);
        } else {
            return address(ERC1155Token);
        }
    }

    function getTokenURI(
        TokenType _tokenType,
        uint256 _tokenId
    ) public view returns (string memory) {
        if (_tokenType == TokenType.MemberERC721) {
            return ERC721Token.tokenURI(_tokenId);
        } else {
            return ERC1155Token.uri(_tokenId);
        }
    }

    function getMasterNFT() public view returns (address) {
        return address(MasterNFT);
    }

    function onERC1155Received(
        address _operator,
        address _from,
        uint256 _id,
        uint256 _value,
        bytes calldata _data
    ) external pure returns (bytes4) {
        return
            bytes4(
                keccak256(
                    "onERC1155Received(address,address,uint256,uint256,bytes)"
                )
            );
    }

    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes memory _data
    ) external pure returns (bytes4) {
        return
            bytes4(
                keccak256("onERC721Received(address,address,uint256,bytes)")
            );
    }
}