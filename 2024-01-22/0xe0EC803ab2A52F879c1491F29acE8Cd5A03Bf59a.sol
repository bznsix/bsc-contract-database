// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract ContractProm {

    modifier onlySeller() {
        require(sellers[msg.sender] || msg.sender == owner || admins[msg.sender], "Only registered sellers, admins and owner can perform this action");
        _;
    }

    modifier onlyBuyer() {
        require(buyers[msg.sender] || msg.sender == owner || admins[msg.sender], "Only registered buyers, admins and owner can perform this action");
        _;
    }

    modifier onlyRegisteredSeller() {
        require(sellerData[msg.sender].isRegistered || msg.sender == owner || admins[msg.sender], "Seller not registered");
        _;
    }

    modifier onlyRegisteredBuyer() {
        require(buyerData[msg.sender].isRegistered || msg.sender == owner || admins[msg.sender], "Buyer not registered");
        _;
    }

    modifier onlyAdmin() {
        require(admins[msg.sender] || msg.sender == owner, "Only admins or the owner can perform this action");
        _;
    }

    mapping(address => bool) public sellers;
    mapping(address => bool) public buyers;
    mapping(uint256 => Product) public products;
    mapping(uint256 => uint256) public escrowBalances;
    mapping(uint256 => bool) public productShipped;
    mapping(uint256 => bool) public productReceived;
    mapping(address => uint256) public sellerProductCount;
    mapping(address => Seller) public sellerData;
    mapping(address => Buyer) public buyerData;
    mapping(address => bool) public admins;

    event ProductCreated(address indexed seller, uint256 indexed productIndex);
    event ProductPurchased(uint256 productIndex);
    event ProductShipped(uint256 productIndex);
    event ProductReceived(uint256 productIndex);
    event TokensDeposited(uint256 productIndex, uint256 amount);
    event TokensWithdrawn(uint256 productIndex, uint256 amount);
    event RefundRequested(uint256 indexed productIndex, address indexed buyer);
    event DeliveryNoConfirmed(uint256 indexed productIndex, address indexed seller);
    event IpfsHashSet(uint256 productIndex, string ipfsHash);
    event ProductVisible(uint256 productIndex);
    event AdminAdded(address adminAddress);
    event AdminRemoved(address adminAddress);

    uint256 public productCount;
    address public owner;
    IERC20 private _token;

    constructor(address tokenAddress) {
        _token = IERC20(tokenAddress);
        require(tokenAddress != address(0), "Invalid token address");
        owner = msg.sender;
        sellers[owner] = true;
        buyers[owner] = true;
    }

    struct Product {
        address payable seller;
        string title;
        string description;
        uint256 price;
        bool purchased;  
        bool shipped;
        bool received;
        bool noshipped;
        bool noreceived;
        bool visible;
        string ipfsHash;
    }

    struct Seller {
        string title;
        string contactInformation;
        bool isRegistered;
    }

    struct Buyer {
        string title;
        string contactInformation;
        bool isRegistered;
    }

    function addAdmin(address adminAddress) public onlyAdmin {
        admins[adminAddress] = true;
        emit AdminAdded(adminAddress);
    }

    function removeAdmin(address adminAddress) public onlyAdmin {
        require(adminAddress != owner, "Cannot remove contract owner as admin");
        admins[adminAddress] = false;
        emit AdminRemoved(adminAddress);
    }

    function registerAsSeller(string memory _title, string memory _contactInformation) public {
        require(!sellerData[msg.sender].isRegistered, "Seller already registered");
        sellerData[msg.sender] = Seller(_title, _contactInformation, true);
        sellers[msg.sender] = true;
    }

    function registerAsBuyer(string memory _title, string memory _contactInformation) public {
        require(!buyerData[msg.sender].isRegistered, "Buyer already registered");
        buyerData[msg.sender] = Buyer(_title, _contactInformation, true);
        buyers[msg.sender] = true;
    }

    function createProduct(
        string memory _title,
        string memory _description,
        uint256 _price
    ) public onlyRegisteredSeller {
        uint256 newProductIndex = productCount;
        products[newProductIndex] = Product(
            payable(msg.sender),
            _title,
            _description,
            _price,
            false,
            false,
            false,
            false,
            false,
            true,
            ""
        );
        productCount++;
        sellerProductCount[msg.sender]++;
        emit ProductCreated(msg.sender, newProductIndex);
    }

    function setIpfsHash(uint256 _productIndex, string memory ipfsHash) public onlyRegisteredSeller {
        products[_productIndex].ipfsHash = ipfsHash;
    }

    function setProductVisibility(uint256 _productIndex) public onlyRegisteredSeller {
        Product storage product = products[_productIndex];
        product.visible = !product.visible;
        emit ProductVisible(_productIndex);
    }

    function purchaseProduct(uint256 _productIndex, uint256 amount) public onlyRegisteredBuyer {
        Product storage product = products[_productIndex];
        require(!product.shipped && !product.received, "Product already shipped or received");
        require(amount <= product.price, "Amount exceeds product price");
        require(_token.allowance(msg.sender, address(this)) >= amount, "Insufficient allowance");
        require(_token.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        escrowBalances[_productIndex] += amount;
        product.purchased = true;
        emit TokensDeposited(_productIndex, amount);
        emit ProductPurchased(_productIndex);
    }

    function shipProduct(uint256 _productIndex) public onlyRegisteredSeller {
        Product storage product = products[_productIndex];
        require(product.purchased && !product.shipped && !product.received, "Product already shipped or received");
        product.shipped = true;
        emit ProductShipped(_productIndex);
    }

    function receiveProduct(uint256 _productIndex) public onlyRegisteredBuyer {
        Product storage product = products[_productIndex];
        require(product.shipped && !product.received, "Product not eligible for receiving");
        escrowBalances[_productIndex] = 0; // Release funds to the seller
        require(_token.transfer(product.seller, product.price), "Transfer failed");
        product.received = true;
        emit TokensWithdrawn(_productIndex, product.price);
        emit ProductReceived(_productIndex);
    }

    function shipNoProduct(uint256 _productIndex) public onlyRegisteredBuyer {
        Product storage product = products[_productIndex];
        require(!product.received && product.shipped, "Product not eligible for refund");
        product.noshipped = true;
        emit RefundRequested(_productIndex, msg.sender);
    }

    function receivNoProduct(uint256 _productIndex) public onlyRegisteredSeller {
        Product storage product = products[_productIndex];
        require(product.shipped && !product.received, "Product not eligible for delivery confirmation");
        escrowBalances[_productIndex] = 0; // Release funds to the seller
        require(_token.transfer(msg.sender, product.price), "Transfer failed");
        product.noreceived = true;
        emit DeliveryNoConfirmed(_productIndex, product.seller);
    }

    function shipProductAdmin(uint256 _productIndex) public onlyAdmin {
        Product storage product = products[_productIndex];
        product.shipped = !product.shipped;
        emit ProductShipped(_productIndex);
    }

    function shipNoProductAdmin(uint256 _productIndex) public onlyAdmin {
        Product storage product = products[_productIndex];
        product.noshipped = !product.noshipped;
        emit RefundRequested(_productIndex, msg.sender);
    }

    function setTitle(uint256 _productIndex, string memory _newTitle) public onlyRegisteredSeller {
        require(products[_productIndex].visible, "Product is not visible");
        products[_productIndex].title = _newTitle;
    }

    function setDescription(uint256 _productIndex, string memory _newDescription) public onlyRegisteredSeller {
        require(products[_productIndex].visible, "Product is not visible");
        products[_productIndex].description = _newDescription;
    }

    function setPrice(uint256 _productIndex, uint256 _newPrice) public onlyRegisteredSeller {
        require(products[_productIndex].visible, "Product is not visible");
        products[_productIndex].price = _newPrice;
    }

}