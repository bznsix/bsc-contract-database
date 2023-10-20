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


interface IAccountRegistry {
    event AccountCreated(
        address account,
        address implementation,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId,
        uint256 salt
    );

    function createAccount(
        address implementation,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId,
        uint256 salt,
        bytes calldata initData
    ) external returns (address);

    function account(
        address implementation,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId,
        uint256 salt
    ) external view returns (address);
}

interface ERC721Interface {
    function ERC721Mint(
        address _to,
        uint256 _tokenId,
        string memory _tokenURI
    ) external;

    function transferFrom(address from, address to, uint256 tokenId) external;

    function balanceOf(address owner) external view returns (uint256 balance);

    function tokenURI(uint256 tokenId) external view returns (string memory);

    function burn(uint256 tokenId) external;
}

interface ERC1155Interface {
    function ERC1155Mint(
        address _to,
        uint256 _tokenId,
        uint256 _tokenAmount,
        bytes memory _data,
        string memory _uri
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external;

    function balanceOf(
        address account,
        uint256 id
    ) external view returns (uint256);

    function uri(uint256 tokenId) external view returns (string memory);

    function burn(address account, uint256 id, uint256 value) external;
}

error Already_Sold();
error Payment_Error();
error ERC721_Token_Should_1();
error Atleast_One_Token();
error Empty_URI();
error Price_Mustbe_greater();
error No_Token();
error Not_Enough_Token();
error Type_Error();
error Withdraw_Failed();
error Not_Updater();
error FreeMint_Execeds();
error Not_Owner();
error Upkeep_Not_Needed();
error One_Token();
error Not_NFT_Owner();
error Only_NFT_Contract();
error NotListedReseller();
error Address_Zero();
error Length_Error();
error NotListedPaymentMethod();
error OnlyAdminCanCall();

contract MasterNFT is Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private tokenId;
    Counters.Counter private tokenSold;
    Counters.Counter private resellId;
    Counters.Counter private reSold;
    uint256 private listingFee;
    address private metadataUpdater;
    address private ERC1155Address;
    address private ERC721Address;
    address private accountAddress;

    IAccountRegistry private TBARegistry;
    ERC1155Interface private ERC1155Token;
    ERC721Interface private ERC721Token;
    IERC20 private wisdomToken;
    IERC20 private LRNToken;

    uint256 private stableToLRNPrice;

    mapping(uint256 => mapping(address => bool)) private isOwnerOfToken;
    mapping(uint256 => mapping(address => uint256)) private EDAofToken;
    mapping(address => bool) private isListedReseller;
    mapping(address => bool) private isListedPaymentMethod;
    mapping(address => address) private defaultPaymentMethod;
    mapping(address => bool) private isAdmin;

    enum AccessLevel {
        PARTNER,
        SUBSCRIBER
    }
    struct accessKey {
        address Address;
        bytes32 AccessPass;
        string Api;
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
        string REAddress;
    }

    enum membershipType {
        GENERAL,
        PROFESSIONAL,
        VIP,
        THOUGHTLEADER,
        ENTERPRISE,
        REALESTATE,
        CURRENCY
    }
    enum TokenType {
        ERC721,
        ERC1155
    }
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

    struct Subscription {
        uint256 tokenId;
        address subscriber;
    }
    Subscription[] private subscriptionList;
    address[] private adminList;

    mapping(uint256 => MarketItem) private tokenIdToMarketItem;
    mapping(uint256 => MarketItem) private resellIdToMarketItem;
    mapping(uint256 => NFTMetadata) private tokenIdToNFTMetadata;
    mapping(address => mapping(uint256 => NFTMetadata))
        private addressToIDToNFTMetadata;
    mapping(uint256 => mapping(address => uint256))
        private tokenIdToUserClaimedAt;
    mapping(address => bool) private isMember;
    mapping(uint256 => mapping(address => bool)) private subscriptionStatus;

    event SubscriptionStatusUpdated(
        uint256 indexed tokenId,
        bool indexed status,
        address indexed updater
    );

    event MembershipNFTMinted(NFTMetadata indexed metadata, uint256 price);

    event BuyNFT(
        address indexed buyer,
        uint256 indexed tokenId,
        uint256 indexed numberOfToken
    );

    event ManualTransfer(
        address indexed recepiant,
        uint256 tokenId,
        uint256 indexed numberOfToken,
        bool indexed isReseller
    );

    event TransferHelper(
        address[] indexed addresses,
        uint256[] indexed tokenIds,
        address indexed from
    );

    event UpdateTokenContract(
        address indexed address721,
        address indexed address1155
    );

    event ListingFeeUpdated(uint256 indexed newFee);

    event ListedPaymentMethod(address[] indexed Tokens, bool[] indexed modes);

    event UserDefaultPaymentMethod(address indexed Token);

    modifier updater() {
        if (msg.sender != metadataUpdater) revert Not_Updater();
        _;
    }

    modifier onlyAdmin() {
        if (!isAdmin[msg.sender]) revert OnlyAdminCanCall();
        _;
    }

    constructor(
        address _wisdomToken,
        address _lrnToken,
        address[] memory _paymentTokens,
        uint256 _stlPrice,
        uint256 _lFee,
        address _erc1155,
        address _erc721
    ) {
        ERC1155Address = _erc1155;
        ERC721Address = _erc721;
        ERC1155Token = ERC1155Interface(ERC1155Address);
        ERC721Token = ERC721Interface(ERC721Address);
        wisdomToken = IERC20(_wisdomToken);
        LRNToken = IERC20(_lrnToken);
        stableToLRNPrice = _stlPrice;
        isListedPaymentMethod[_wisdomToken] = true;
        isListedPaymentMethod[_lrnToken] = true;
        listingFee = _lFee;
        isAdmin[msg.sender] = true;
        adminList.push(msg.sender);
        for (uint256 i = 0; i < _paymentTokens.length; i++) {
            isListedPaymentMethod[_paymentTokens[i]] = true;
        }
    }

    function addAdminAddress(address[] memory _admins) public onlyOwner {
        for (uint256 i = 0; i < _admins.length; i++) {
            isAdmin[_admins[i]] = true;
            adminList.push(_admins[i]);
        }
    }

    function removeAdminAddress(address _admin) public onlyOwner {
        isAdmin[_admin] = false;

        for (uint256 i = 0; i < adminList.length; i++) {
            if (adminList[i] == _admin) {
                adminList[i] = adminList[adminList.length - 1];

                adminList.pop();
                break;
            }
        }
    }

    function updateSubscriptionStatus(uint256 _tokenId, bool _status) public {
        if (!isOwnerOfToken[_tokenId][msg.sender]) revert Not_Owner();
        subscriptionStatus[_tokenId][msg.sender] = _status;
        if (_status == true) {
            subscriptionList.push(Subscription(_tokenId, msg.sender));
        }
        emit SubscriptionStatusUpdated(_tokenId, _status, msg.sender);
    }

    function mintMembershipNFT(
        NFTMetadata memory _metadata,
        uint256 _numberOfToken,
        string memory _tokenURI,
        uint256 _nftPrice,
        uint256 _couponPrice,
        bytes memory _data
    ) public onlyAdmin {
        if (_numberOfToken == 0) revert Atleast_One_Token();
        if (_metadata.tokenType == TokenType.ERC721 && _numberOfToken > 1)
            revert ERC721_Token_Should_1();
        if (_metadata.typeOfMember != membershipType.CURRENCY && _nftPrice == 0)
            revert Price_Mustbe_greater();
        tokenId.increment();
        uint256 _tokenId = tokenId.current();
        NFTMetadata memory metadata = _metadata;
        metadata.tokenId = _tokenId;
        tokenIdToNFTMetadata[_tokenId] = metadata;
        if (metadata.tokenType == TokenType.ERC721) {
            ERC721Token.ERC721Mint(address(this), _tokenId, _tokenURI);
        } else {
            ERC1155Token.ERC1155Mint(
                address(this),
                _tokenId,
                _numberOfToken,
                _data,
                _tokenURI
            );
        }
        createMarketItem(
            _tokenId,
            msg.sender,
            address(this),
            _nftPrice,
            _metadata.tokenType,
            _numberOfToken,
            _couponPrice,
            false
        );
        emit MembershipNFTMinted(_metadata, _nftPrice);
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
        if (_owner == address(0)) revert Address_Zero();
        if (_price <= 0) revert Payment_Error();
        if (isResell) {
            resellIdToMarketItem[resellId.current()] = MarketItem(
                _id,
                _seller,
                _owner,
                _tokenType,
                _price,
                false,
                _couponPrice,
                _numberOfToken
            );
        } else {
            if (_id > tokenId.current()) revert No_Token();
            tokenIdToMarketItem[_id] = MarketItem(
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

    receive() external payable {}

    function buyNFT(
        uint256 _id,
        uint256 _numberOfToken,
        bool isListed
    ) external {
        MarketItem storage nft;
        if (isListed == true) {
            nft = resellIdToMarketItem[_id];
        } else {
            nft = tokenIdToMarketItem[_id];
        }
        uint256 _tokenId = nft.tokenId;
        if (nft.sold == true) revert Already_Sold();
        if (_numberOfToken != 1) revert One_Token();
        if (nft.price > 0) {
            bool success;
            if (defaultPaymentMethod[msg.sender] != address(0)) {
                uint256 price;
                if (defaultPaymentMethod[msg.sender] == address(LRNToken)) {
                    price = (nft.price * stableToLRNPrice) / 10 ** 18;
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
        }
        NFTMetadata storage metadata = tokenIdToNFTMetadata[_tokenId];
        if (!isListed) {
            EDAofToken[_tokenId][msg.sender] =
                block.timestamp +
                metadata.expireDate;
        }
        if (defaultPaymentMethod[msg.sender] != address(0)) {
            uint256 price;
            if (defaultPaymentMethod[msg.sender] == address(LRNToken)) {
                price = (nft.price * stableToLRNPrice) / 10 ** 18;
            } else {
                price = nft.price;
            }
            if (isListed) {
                uint256 applyR = (price * (100 - listingFee)) / 100;
                IERC20(defaultPaymentMethod[msg.sender]).transfer(
                    nft.seller,
                    applyR
                );
            } else {
                IERC20(defaultPaymentMethod[msg.sender]).transfer(
                    nft.seller,
                    price
                );
            }
        } else {
            if (isListed) {
                uint256 applyR = (nft.price * (100 - listingFee)) / 100;
                wisdomToken.transfer(nft.seller, applyR);
            } else {
                wisdomToken.transfer(nft.seller, nft.price);
            }
        }
        if (nft.tokenType == TokenType.ERC1155) {
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
        isOwnerOfToken[_tokenId][msg.sender] = true;

        isMember[msg.sender] = true;
        addressToIDToNFTMetadata[msg.sender][_tokenId] = metadata;
        tokenIdToUserClaimedAt[_tokenId][msg.sender] = block.timestamp;
        if (nft.tokenType == TokenType.ERC721) {
            ERC721Token.transferFrom(address(this), msg.sender, _tokenId);
        } else {
            ERC1155Token.safeTransferFrom(
                address(this),
                msg.sender,
                _tokenId,
                _numberOfToken,
                "0x00"
            );
        }
        emit BuyNFT(msg.sender, _tokenId, _numberOfToken);
    }

    function manualTransfer(
        uint256 _tokenId,
        uint256 _numberOfToken,
        address _to,
        bool isReseller
    ) public onlyAdmin {
        MarketItem storage nft = tokenIdToMarketItem[_tokenId];
        if (nft.sold == true) revert Already_Sold();
        if (isReseller) {
            isListedReseller[_to] = true;
        }
        if (nft.tokenType == TokenType.ERC1155) {
            nft.numberOfToken -= _numberOfToken;
            if (nft.numberOfToken == 0) {
                nft.sold = true;
                nft.price = 0;
                tokenSold.increment();
                nft.owner = address(0);
            }
        } else {
            nft.sold = true;
            nft.owner = _to;
            nft.seller = address(0);
            nft.price = 0;
            tokenSold.increment();
        }
        isOwnerOfToken[_tokenId][_to] = true;
        NFTMetadata storage metadata = tokenIdToNFTMetadata[_tokenId];
        EDAofToken[_tokenId][_to] = block.timestamp + metadata.expireDate;

        isMember[_to] = true;
        addressToIDToNFTMetadata[_to][_tokenId] = metadata;
        if (nft.tokenType == TokenType.ERC721) {
            ERC721Token.transferFrom(address(this), _to, _tokenId);
        } else {
            ERC1155Token.safeTransferFrom(
                address(this),
                _to,
                _tokenId,
                _numberOfToken,
                "0x00"
            );
        }
        emit ManualTransfer(_to, _tokenId, _numberOfToken, isReseller);
    }

    function transferHelper(
        address[] memory _addresses,
        uint256[] memory _tokenIds
    ) public {
        if (!isListedReseller[msg.sender]) {
            revert NotListedReseller();
        }
        require(_addresses.length == _tokenIds.length, "length error");
        for (uint256 i = 0; i < _addresses.length; i++) {
            address to = _addresses[i];
            uint256 tId = _tokenIds[i];
            uint256 numOfToken = 1;
            MarketItem storage nft = tokenIdToMarketItem[tId];
            if (nft.tokenType == TokenType.ERC1155) {
                if (ERC1155Token.balanceOf(msg.sender, tId) == 1) {
                    isOwnerOfToken[tId][msg.sender] = false;
                }
                if (ERC1155Token.balanceOf(msg.sender, tId) < numOfToken) {
                    revert Not_Enough_Token();
                }
            } else if (nft.tokenType == TokenType.ERC721) {
                isOwnerOfToken[tId][msg.sender] = false;
                if (nft.owner != msg.sender) revert Not_Owner();
            }
            isOwnerOfToken[tId][to] = true;
            NFTMetadata storage metadata = tokenIdToNFTMetadata[tId];
            EDAofToken[tId][to] = block.timestamp + metadata.expireDate;
            isMember[to] = true;
            addressToIDToNFTMetadata[to][tId] = metadata;
            if (nft.tokenType == TokenType.ERC721) {
                ERC721Token.transferFrom(msg.sender, to, tId);
            } else {
                ERC1155Token.safeTransferFrom(
                    msg.sender,
                    to,
                    tId,
                    numOfToken,
                    "0x00"
                );
            }
        }

        emit TransferHelper(_addresses, _tokenIds, msg.sender);
    }

    function resellNFT(
        uint256 _tokenId,
        uint256 _price,
        uint256 _numberOfToken
    ) public {
        isOwnerOfToken[_tokenId][msg.sender] = false;
        MarketItem memory nft = tokenIdToMarketItem[_tokenId];
        resellId.increment();
        createMarketItem(
            _tokenId,
            msg.sender,
            address(this),
            _price,
            nft.tokenType,
            _numberOfToken,
            nft.couponPrice,
            true
        );
        if (nft.tokenType == TokenType.ERC721) {
            ERC721Token.transferFrom(msg.sender, address(this), _tokenId);
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

    function burnNFT(
        uint256 _tokenId,
        uint256 _numberOfToken
    ) public onlyAdmin {
        NFTMetadata storage nft = tokenIdToNFTMetadata[_tokenId];
        if (nft.tokenType == TokenType.ERC721) {
            ERC721Token.burn(_tokenId);
        } else {
            ERC1155Token.burn(address(this), _tokenId, _numberOfToken);
        }
        delete tokenIdToNFTMetadata[_tokenId];
        delete tokenIdToMarketItem[_tokenId];
    }

    function updateTokenContract(address _721, address _1155) public onlyOwner {
        ERC721Address = _721;
        ERC721Token = ERC721Interface(ERC721Address);
        ERC1155Address = _1155;
        ERC1155Token = ERC1155Interface(ERC1155Address);
        emit UpdateTokenContract(_721, _1155);
    }

    function setlistingFee(uint256 _feeP) public onlyOwner {
        listingFee = _feeP;
        emit ListingFeeUpdated(_feeP);
    }

    function setWisdom(address _wisdom) public onlyOwner {
        wisdomToken = IERC20(_wisdom);
    }

    function setLRNTokenCPrice(uint256 _price) public onlyOwner {
        stableToLRNPrice = _price;
    }

    function setListedPaymentMethod(
        address[] memory _tokens,
        bool[] memory _modes
    ) public onlyOwner {
        if (_tokens.length != _modes.length) {
            revert Length_Error();
        }
        for (uint256 i = 0; i < _tokens.length; i++) {
            isListedPaymentMethod[_tokens[i]] = _modes[i];
        }
        emit ListedPaymentMethod(_tokens, _modes);
    }

    function setUserDefaultPaymentMethod(address _token) public {
        if (!isListedPaymentMethod[_token]) {
            revert NotListedPaymentMethod();
        }
        defaultPaymentMethod[msg.sender] = _token;

        emit UserDefaultPaymentMethod(_token);
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
                MarketItem storage currentItem = tokenIdToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function fetchMWNFTs()
        public
        view
        returns (uint256[] memory, uint256[] memory, address[] memory)
    {
        uint256 total = tokenId.current();
        uint256 iCount = 0;
        uint256 currentIndex = 0;
        for (uint256 i = 0; i < total; i++) {
            if (isOwnerOfToken[i + 1][msg.sender]) {
                iCount += 1;
            }
        }
        uint256[] memory tokenIds = new uint256[](iCount);
        uint256[] memory numberOfTokens = new uint256[](iCount);
        address[] memory tokenAddress = new address[](iCount);
        for (uint256 i = 0; i < total; i++) {
            if (isOwnerOfToken[i + 1][msg.sender]) {
                uint256 currentId = i + 1;
                tokenIds[currentIndex] = currentId;
                MarketItem storage currentItem = tokenIdToMarketItem[currentId];
                if (currentItem.tokenType == TokenType.ERC1155) {
                    numberOfTokens[currentIndex] = ERC1155Token.balanceOf(
                        msg.sender,
                        currentId
                    );
                    tokenAddress[currentIndex] = ERC1155Address;
                } else {
                    numberOfTokens[currentIndex] = 1;
                    tokenAddress[currentIndex] = ERC721Address;
                }
                currentIndex += 1;
            }
        }
        return (tokenIds, numberOfTokens, tokenAddress);
    }

    function setMetadataUpdater(address _updater) external {
        if (metadataUpdater == address(0)) {
            metadataUpdater = _updater;
        } else {
            if (msg.sender != owner()) revert Not_Owner();
            metadataUpdater = _updater;
        }
    }

    function updateMI(
        uint256 _tokenId,
        address _nOwner,
        address _seller
    ) public {
        if (msg.sender != ERC721Address || msg.sender != ERC1155Address)
            revert Only_NFT_Contract();
        MarketItem storage item = tokenIdToMarketItem[_tokenId];
        item.owner = _nOwner;
        item.seller = _seller;
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

    function updateMetadata(
        uint256 _tokenId,
        address _owner
    ) external updater returns (bool) {
        NFTMetadata storage newMetadata = addressToIDToNFTMetadata[_owner][
            _tokenId
        ];
        if (
            (tokenIdToUserClaimedAt[_tokenId][_owner] + 30 days) <
            block.timestamp
        ) {
            uint256 expireTime = EDAofToken[_tokenId][_owner];
            if (expireTime > block.timestamp + 30 days) {
                tokenIdToUserClaimedAt[_tokenId][_owner] = block.timestamp;
                newMetadata.freeMint = tokenIdToNFTMetadata[_tokenId].freeMint;
            }
        }
        if (newMetadata.freeMint < 1) {
            // revert FreeMint_Execeds();
            return false;
        } else {
            newMetadata.freeMint = newMetadata.freeMint - 1;
            return true;
        }
    }

    function fetchMarketNft() public view returns (MarketItem[] memory) {
        uint256 totalItem = tokenId.current();
        uint256 unsoldItem = totalItem - tokenSold.current();
        uint256 currentIndex = 0;
        MarketItem[] memory items = new MarketItem[](unsoldItem);
        for (uint256 i = 0; i < totalItem; i++) {
            if (tokenIdToMarketItem[i + 1].owner == address(this)) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = tokenIdToMarketItem[currentId];
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

    function getIsAdmin(address _wallet) public view returns (bool) {
        return isAdmin[_wallet];
    }

    function getAdminList() public view returns (address[] memory) {
        return adminList;
    }

    function getTokenIdToMetadata(
        uint256 _tokenId
    ) external view returns (NFTMetadata memory) {
        return tokenIdToNFTMetadata[_tokenId];
    }

    function getUserOwnedNFTId(
        address _user
    ) public view returns (uint256[] memory) {
        uint256[] memory ids = new uint256[](tokenId.current());
        uint256 count = 0;

        for (uint256 i = 1; i <= tokenId.current(); i++) {
            if (isOwnerOfToken[i][_user]) {
                NFTMetadata memory item = tokenIdToNFTMetadata[i];
                if (
                    item.typeOfMember != membershipType.REALESTATE &&
                    item.typeOfMember != membershipType.CURRENCY
                ) {
                    ids[count] = i;
                    count++;
                }
            }
        }
        assembly {
            mstore(ids, count)
        }

        for (uint256 i = 0; i < count - 1; i++) {
            for (uint256 j = i + 1; j < count; j++) {
                if (ids[i] < ids[j]) {
                    uint256 temp = ids[i];
                    ids[i] = ids[j];
                    ids[j] = temp;
                }
            }
        }

        return ids;
    }

    function getAddressToTokenIdToMetadata(
        address _owner,
        uint256 _tokenId
    ) external view returns (NFTMetadata memory) {
        return addressToIDToNFTMetadata[_owner][_tokenId];
    }

    function getTokenIdToMarketItem(
        uint256 _tokenId
    ) external view returns (MarketItem memory) {
        return tokenIdToMarketItem[_tokenId];
    }

    function getTokenId() external view returns (uint256) {
        return tokenId.current();
    }

    function getTokenContract(TokenType _type) public view returns (address) {
        if (_type == TokenType.ERC721) {
            return ERC721Address;
        } else {
            return ERC1155Address;
        }
    }

    function getTokenURI(
        TokenType _tokenType,
        uint256 _tokenId
    ) public view returns (string memory) {
        if (_tokenType == TokenType.ERC721) {
            return ERC721Token.tokenURI(_tokenId);
        } else {
            return ERC1155Token.uri(_tokenId);
        }
    }

    function getIsMember(address _isMember) public view returns (bool) {
        return isMember[_isMember];
    }

    function getIsOwnerOfToken(
        uint256 _id,
        address _owner
    ) public view returns (bool) {
        return isOwnerOfToken[_id][_owner];
    }

    function getEDAofToken(
        uint256 _id,
        address _owner
    ) public view returns (uint256) {
        return EDAofToken[_id][_owner];
    }

    function increaseValidity(uint256 _id) public {
        NFTMetadata storage metadata = tokenIdToNFTMetadata[_id];
        MarketItem storage nft = tokenIdToMarketItem[_id];
        bool success;
        if (defaultPaymentMethod[msg.sender] != address(0)) {
            success = IERC20(defaultPaymentMethod[msg.sender]).transfer(
                owner(),
                nft.price
            );
        } else {
            success = wisdomToken.transfer(owner(), nft.price);
        }
        if (success) {
            EDAofToken[_id][msg.sender] = block.timestamp + metadata.expireDate;
        } else {
            revert Payment_Error();
        }
    }

    function balanceOf(
        TokenType _tokenType,
        address _owner,
        uint256 _tokenId
    ) public view returns (uint256) {
        if (_tokenType == TokenType.ERC721) {
            return ERC721Token.balanceOf(_owner);
        } else {
            return ERC1155Token.balanceOf(_owner, _tokenId);
        }
    }

    function getStableToLRNPrice() public view returns (uint256) {
        return stableToLRNPrice;
    }

    function getPreTBA(
        address _implementation,
        uint256 _chainId,
        address _tokenContract,
        uint256 _tokenId,
        uint256 _salt
    ) public view returns (address) {
        return
            TBARegistry.account(
                _implementation,
                _chainId,
                _tokenContract,
                _tokenId,
                _salt
            );
    }

    function createTBA(
        address _implementation,
        uint256 _chainId,
        address _tokenContract,
        uint256 _tokenId,
        uint256 _salt,
        bytes calldata _initData
    ) public returns (address) {
        return
            TBARegistry.createAccount(
                _implementation,
                _chainId,
                _tokenContract,
                _tokenId,
                _salt,
                _initData
            );
    }

    function getIsListedPaymentMethod(
        address _token
    ) public view returns (bool) {
        return isListedPaymentMethod[_token];
    }

    function getUserDefaultPaymentMethod(
        address _user
    ) public view returns (address) {
        return defaultPaymentMethod[_user];
    }

    function getSubscriptionList() public view returns (Subscription[] memory) {
        return subscriptionList;
    }
}