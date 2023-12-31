// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11;
import "./Nft.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";


interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IPancakeRouter01 {
    function WETH() external pure returns (address);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
   
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    
}


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
        return c;
    }
        
}

contract CoreFeesRountingContract is IERC721Receiver,Context,Ownable,ReentrancyGuard{
   
    using SafeMath for uint256;

    // pancakeswap
    IPancakeRouter01 private pancakeV2Router;
    address public routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public targetToken; 
    

    uint public platformFee = 15; 
    uint public carbonPlatformFee = 10;
    uint public  resale_platfromFee = 3; // the fee percentage on sales 
    uint256 public resale_royaltyFee = 5; // Percentage of sale price to be taken as royalty by the original creator of the NFT
    uint public itemCount;


    uint public totalPlatformFee; 
    bool public platformFeeFlag = true;
    
    address public platformFeeWallet;
    address public cccWallet;

    address public carbonAddress;


    mapping (address => bool) public Tokens;

    BCCarbonCredit CarbonCredit;

    
    mapping(address => bool) private _isBlacklisted;

    mapping (address => bool) public whitelistedNftContracts; 



    bool public _directTransferFlag = true ;
    bool public _orderPaymentFlag = true;


    // transaction details 
    struct OrderDetails { 
            uint product_id;
            address from_address;
            address to_address;
            uint amount;
            uint plantform_fee;
    }

    struct OrderCarbonDetails { 
            uint project_id;
            address cpo_address;
            address buyer_address;
            uint total_amount;
            uint platform_fee;
            uint platfrom_fee_amount;
            uint tonnes;
            uint no_of_nft;
            uint price;
            bool new_item;
            uint item_id;
            bool mintDelayFlag;
    }

    

    mapping(string => OrderCarbonDetails[]) private mintLaterOrderDetails;
    
    
    struct WithoutWalletOrderCarbonDetails { 
            uint project_id;
            address cpo_address;
            uint buyer_id;
            address buyer_address;
            uint total_tonnes;
            uint no_of_nft;
            uint tonnes_for_specified_nft;
            uint no_of_nft_for_specified_tonnes;
            uint total_specified_tonnes;
            uint remaining_tonnes;
            bool is_minted;
    }
    mapping(string => WithoutWalletOrderCarbonDetails[]) private withoutWalletMintLaterOrderDetails;

    // mint without wallet 

    mapping(uint256 => address)  private userWallet ;

     // Function to set a user's wallet address
    event setUserWalletEvent(uint256 userId, address walletAddress);

    function setUserWallet(uint256 userId, address walletAddress) public onlyOwner{
        userWallet[userId] = walletAddress;
        emit setUserWalletEvent(userId,walletAddress);
    }

    // Function to get a user's wallet address
    function getUserWallet(uint256 userId) public view returns (address) {
        return userWallet[userId];
    }

    mapping(uint256 => uint256) private nftUser;

    // Function to associate a user with an NFT token ID
    event setUserNftEvent(uint256 tokenId, uint256 userId);

    function setUserOfNFT(uint256 tokenId, uint256 userId) public onlyOwner {
        nftUser[tokenId] = userId;
        emit setUserNftEvent(tokenId,userId);
    }

    // Function to retrieve the user associated with an NFT token ID
    function getUserOfNFT(uint256 tokenId) public view returns (uint256) {
        return nftUser[tokenId];
    }


    // #########################################



    struct Item {
        uint itemId;
        IERC721 nft;
        uint tokenId;
        uint price;
        address payable seller;
        address payable owner;
        address payable cpo;
        bool sold;
    }

    // itemId -> Item
    mapping(uint => Item) public items;

    event Offered(uint itemId,address indexed nft,uint tokenId,uint price,address indexed seller);

    event RevokeOffered(uint itemId,address indexed nft,uint tokenId,uint price,address indexed seller);
 
    event Bought(uint itemId,address indexed nft,uint tokenId,uint price,address indexed seller,address indexed buyer);

    event OrderDetailsToWalletEvent(address indexed token,address indexed from,address indexed to,string order_id,uint256 value_after_convertion,uint256 platformfee_value,uint256 value_after_platformfee,OrderDetails order_details);
    event OrderDetailsToBagEvent(address indexed token,address indexed from,address indexed to,string order_id,uint256 value_after_convertion,uint256 platformfee_value,uint256 value_after_platformfee,OrderDetails order_details);

    event OrderCarbonDetailsToWalletEvent(address indexed token,address indexed from,address indexed to,string order_id,uint256 value_after_convertion,uint256 royalty_value,uint256 platformfee_value,uint256 value_after_platformfee,OrderCarbonDetails order_details);
    event OrderCarbonDetailsToBagEvent(address indexed token,address indexed from,address indexed to,string order_id,uint256 value_after_convertion,uint256 royalty_value,uint256 platformfee_value,uint256 value_after_platformfee,OrderCarbonDetails order_details);
    event RetairCarbonNftEvent(address indexed nft,uint tokenId,address indexed owner);

    event NftRecevied(address operator,address from,uint256 tokenId);


    // ################
    address public treasury = 0xd3163724D1AB51468c1917CCf8B66E6C4d3c580A;


    
    
    
    
    event TransferAllTokenToTreasuryEvent(address indexed token,address indexed treasury, uint256 value,uint256 timestamp);

    event DirectTransferEvent(address indexed token,address indexed from, address indexed to,uint256 actual_value ,uint256 value_after_deduction,uint256 value_after_platformfee,uint256 platformfee_value);
    event DirectTransferEvent2(address indexed token,address indexed from, address indexed to,uint256 actual_value ,uint256 value_after_platformfee,uint256 platformfee_value);

    event MintNowEvent(string order_id,uint project_id);

    event addMintLaterEvent(string order_id,OrderCarbonDetails order);
    event MintNftEvent(uint256[] nftId);


  
    constructor(address token,address _platformFeeWallet, address _cccWallet,address _carbonAddress){
        targetToken = token;
        platformFeeWallet = _platformFeeWallet;
        cccWallet = _cccWallet;
        carbonAddress = _carbonAddress;
        whitelistedNftContracts[carbonAddress] = true;
        CarbonCredit = BCCarbonCredit(_carbonAddress);
        Tokens[targetToken] = true;
        pancakeV2Router = IPancakeRouter01(routerAddress);

    }


      // whitlist nft contract address 
    function whitelistNftContract(address _contractAddress,bool _flag) public onlyOwner {
        whitelistedNftContracts[_contractAddress] = _flag;
    }

    function setRoyaltyFee(uint256 _fee) public onlyOwner {
        require(_fee < 100, "Royalty fee cannot be greater than 100%.");
        resale_royaltyFee = _fee;
    }

     function setResalePlatformFeePercentage(uint _platfromFee) external onlyOwner{
        require(_platfromFee < 100, "platform fee cannot be greater than 100%.");
        resale_platfromFee = _platfromFee;

    }


    function setPlatformFeeWalletAddress(address _platformFeeWallet) external onlyOwner {
        platformFeeWallet = _platformFeeWallet;
    }

    function setCccWalletAddress(address _cccWallet) external onlyOwner {
        cccWallet = _cccWallet;
    }


    function setCarbonAddress(address _carbonAddress) external onlyOwner {
        carbonAddress = _carbonAddress;
        CarbonCredit = BCCarbonCredit(_carbonAddress);

    }



    function setTargetAddress(address target_adr) external onlyOwner {
        targetToken = target_adr;
        Tokens[targetToken] = true;

    }

    

    modifier AllowedTokenCheck(IBEP20 _token){
        require(Tokens[address(_token)],'This Token is not allowed to deposit and withdraw.');
        _;
    }


    function setPlatformFee(uint _platformFee) external onlyOwner {
        platformFee = _platformFee;
    }



    function setPlatformFeeFlag(bool _platformFeeFlag) external onlyOwner {
        platformFeeFlag = _platformFeeFlag;
    }
    
    function setDirectTransferFlag(bool _bool) external onlyOwner {
        _directTransferFlag = _bool;
    }


    function setOrderPaymentFlagFlag(bool _bool) external onlyOwner {
        _orderPaymentFlag = _bool;
    }

    function setAddressIsBlackListed(address _address, bool _bool) external onlyOwner {
        _isBlacklisted[_address] = _bool;
    }

    function viewIsBlackListed(address _address) public view returns(bool) {
        return _isBlacklisted[_address];
    }

    function allowedTokens(address _token,bool _flag) public onlyOwner{
        Tokens[_token] = _flag;
    }
    
    function TransferAllTokenToTreasury(IBEP20 _token) public onlyOwner AllowedTokenCheck(_token){

        uint _contract_balance = _token.balanceOf(address(this));
        require(_contract_balance > 0, "Contract not have any token balance to transfer.");
        
        _token.transfer(treasury, _contract_balance);
        emit TransferAllTokenToTreasuryEvent(address(_token),treasury, _contract_balance,block.timestamp);
    
    }


    function swapTokenForTargetToken(IBEP20 from_token,uint amountIn) private {
     
        address[] memory path;


        if (address(from_token) == pancakeV2Router.WETH()) {
            path = new address[](2);
            path[0] = address(from_token);
            path[1] = address(targetToken);
        
        pancakeV2Router.swapExactETHForTokens{value: amountIn}(0,path,address(this),block.timestamp);
        } else {
            path = new address[](3); 
            path[0] = address(from_token);
            path[1] = pancakeV2Router.WETH();
            path[2] = address(targetToken);

        from_token.transferFrom(msg.sender,address(this), amountIn);
        from_token.approve(address(pancakeV2Router), amountIn);
        pancakeV2Router.swapExactTokensForTokens(amountIn,1,path,address(this),block.timestamp);
        }
   
    }

    function PaymentTransfer(IBEP20 _token,address _address,uint _amount) public payable AllowedTokenCheck(_token){
        require(_amount > 0, "You need at least some tokens");
        require(_directTransferFlag,"Direct Transfer is not allowed");
        require(!_isBlacklisted[msg.sender],"Your Address is blacklisted");
        require(!_isBlacklisted[_address],"Receiver Address is blacklisted");

        IBEP20 _target_token = IBEP20(targetToken);
        
        uint _before_token_balance = _target_token.balanceOf(address(this));

        if(targetToken != address(_token)){
            swapTokenForTargetToken(_token,_amount);
           
        }else{
        _token.transferFrom(msg.sender,address(this), _amount);
        }
   

        uint _after_token_balance = _target_token.balanceOf(address(this));

        uint _new_amount = _after_token_balance.sub(_before_token_balance);
        uint _platformfee_value =0;

        if(platformFeeFlag){
        _platformfee_value = _new_amount.mul(platformFee).div(1000);
        totalPlatformFee.add(_platformfee_value);
        _target_token.transfer(platformFeeWallet, _platformfee_value);
        }
        
        uint _transfer_value = _new_amount.sub(_platformfee_value);


        _target_token.transfer(_address, _transfer_value);  
        emit DirectTransferEvent(address(_token),msg.sender,_address,_amount,_new_amount,_transfer_value,_platformfee_value);
    }
    

    receive() external payable {}


       // Make item to offer on the marketplace
    function makeItem(IERC721 _nft, uint _tokenId, uint _price,address _cpo) external nonReentrant {
        require(whitelistedNftContracts[address(_nft)], "This nft contract is not allowed.");
        require(_cpo != address(0), "Cpo address cont be empty");
        require(_price > 0, "Price must be greater than zero");
        // increment itemCount
        itemCount ++;
        // transfer nft
        _nft.transferFrom(msg.sender, address(this), _tokenId);
        // add new item to items mapping
        items[itemCount] = Item (
            itemCount,
            _nft,
            _tokenId,
            _price,
            payable(msg.sender),
            payable(address(this)),
            payable(_cpo),
            false
        );
        // emit Offered event
        emit Offered(
            itemCount,
            address(_nft),
            _tokenId,
            _price,
            msg.sender
        );
    }
    
    function revokeItem(uint256 _itemId, uint256 price) public payable nonReentrant {
        require(_itemId > 0 && _itemId <= itemCount, "item doesn't exist");
        require(
            items[_itemId].seller == msg.sender,
            "Only item owner can perform this operation"
        );
        items[_itemId].sold = true;
        items[_itemId].price = price;
        items[_itemId].seller = payable(msg.sender);
        items[_itemId].owner = payable(msg.sender);

        // transfer nft
        items[_itemId].nft.transferFrom(address(this), msg.sender, items[_itemId].tokenId);

        emit RevokeOffered(
            _itemId,
            address(items[_itemId].nft),
            items[_itemId].tokenId,
            price,
            msg.sender
        );
    }



function OrderPaymentToWallet(IBEP20 _token, string memory order_id, OrderDetails[] memory orders) public payable AllowedTokenCheck(_token) {
    processOrder(_token, order_id, orders, true);
}

function OrderPaymentToBag(IBEP20 _token, string memory order_id, OrderDetails[] memory orders) public payable AllowedTokenCheck(_token) {
    processOrder(_token, order_id, orders, false);
}

function calculateTokenTransferToContract(IBEP20 _target_token,IBEP20 _input_token,uint256 amount) internal returns(uint256){
     uint _before_token_balance = _target_token.balanceOf(address(this));

        if (targetToken != address(_input_token)) {
            swapTokenForTargetToken(_input_token, amount);
        } else {
            _input_token.transferFrom(msg.sender, address(this), amount);
        }

        uint _after_token_balance = _target_token.balanceOf(address(this));

        uint _new_amount = _after_token_balance.sub(_before_token_balance);

        return _new_amount;

}

function processOrder(IBEP20 _token, string memory order_id, OrderDetails[] memory orders, bool toWallet) internal {
    require(_orderPaymentFlag, "order payment is not allowed");
    require(!_isBlacklisted[msg.sender], "Your Address is blacklisted");

    IBEP20 _target_token = IBEP20(targetToken);

    for (uint i = 0; i < orders.length; i++) {
        

        uint _new_amount = calculateTokenTransferToContract(_target_token,_token,orders[i].amount);

        uint total_share = 100 + orders[i].plantform_fee;
        uint originalPrice = (_new_amount * 100) / total_share;
        uint platformFeeAmount = _new_amount - originalPrice;

        totalPlatformFee.add(platformFeeAmount);
        if (toWallet) {
            _target_token.transfer(platformFeeWallet, platformFeeAmount);
        } else {
            _target_token.transfer(cccWallet, originalPrice);
        }

        OrderDetails memory order = orders[i];

        if (toWallet) {
            emit OrderDetailsToWalletEvent(address(_token), msg.sender, orders[i].to_address, order_id, _new_amount, platformFeeAmount, originalPrice, order);
        } else {
            emit OrderDetailsToBagEvent(address(_token), msg.sender, orders[i].to_address, order_id, _new_amount, platformFeeAmount, originalPrice, order);
        }
    }
}

function processCarbonOrder(IBEP20 _token,string memory order_id,OrderCarbonDetails[] memory orders,address _target_token,address _platformFeeWallet,bool isBagCarbon) internal {
    require(_orderPaymentFlag, "Order payment is not allowed");
    require(!_isBlacklisted[msg.sender], "Your Address is blacklisted");

    address input_token = address(_token);
    string memory _order_id = order_id;

    for (uint i = 0; i < orders.length; i++) {

        uint _new_amount = calculateTokenTransferToContract(IBEP20(_target_token),_token,orders[i].total_amount);


        OrderCarbonDetails memory order = orders[i];

        if (order.new_item) {
            uint total_share = 100 + carbonPlatformFee;
            uint originalPrice = (_new_amount * 100) / total_share;
            uint platformFeeAmount = _new_amount - originalPrice;
            totalPlatformFee.add(platformFeeAmount);

            if (isBagCarbon) {
                IBEP20(_target_token).transfer(cccWallet, originalPrice);
            } else {
                IBEP20(_target_token).transfer(_platformFeeWallet, platformFeeAmount);
                IBEP20(_target_token).transfer(order.cpo_address, originalPrice);
                if (order.mintDelayFlag) {
                    mintLaterOrderDetails[order_id].push(order);
                } else {
                    CarbonCredit.ContractMint(
                        _order_id,
                        order.buyer_address,
                        order.cpo_address,
                        order.project_id,
                        order.tonnes,
                        order.no_of_nft,
                        order.price
                    );
                }
            }

            emit OrderCarbonDetailsToWalletEvent(
                input_token,
                msg.sender,
                order.cpo_address,
                _order_id,
                _new_amount,
                0,
                platformFeeAmount,
                originalPrice,
                order
            );
        } else {
            Item storage item = items[order.item_id];
            require(order.item_id > 0 && order.item_id <= itemCount, "Item doesn't exist");
            require(!item.sold, "Item already sold");
            uint total_share = 100 + resale_royaltyFee + resale_platfromFee;
            uint originalPrice = (_new_amount * 100) / total_share;
            uint royaltyAmount = (_new_amount * resale_royaltyFee) / total_share;
            uint platformFeeAmount = _new_amount - originalPrice - royaltyAmount;
            IBEP20(_target_token).transfer(address(item.seller), originalPrice);

            if (!isBagCarbon && resale_platfromFee > 0) {
                IBEP20(_target_token).transfer(_platformFeeWallet, platformFeeAmount);
            }

            if (!isBagCarbon && resale_royaltyFee > 0) {
                IBEP20(_target_token).transfer(item.cpo, royaltyAmount);
            }

            item.sold = true;
            item.owner = payable(msg.sender);
            item.nft.transferFrom(address(this), msg.sender, item.tokenId);
            emit Bought(
                item.itemId,
                address(item.nft),
                item.tokenId,
                item.price,
                item.seller,
                msg.sender
            );

            emit OrderCarbonDetailsToWalletEvent(
                input_token,
                msg.sender,
                item.seller,
                _order_id,
                _new_amount,
                royaltyAmount,
                platformFeeAmount,
                originalPrice,
                order
            );
        }
    }
}

function OrderPaymentToWalletCarbon(IBEP20 _token, string memory order_id, OrderCarbonDetails[] memory orders) public payable AllowedTokenCheck(_token) {
    processCarbonOrder(_token, order_id, orders, address(targetToken), platformFeeWallet, false);
}

function OrderPaymentToBagCarbon(IBEP20 _token, string memory order_id, OrderCarbonDetails[] memory orders) public payable AllowedTokenCheck(_token) {
    processCarbonOrder(_token, order_id, orders, cccWallet, cccWallet, true);
}


function RetireCarbonNft(uint tokenId) public{
    CarbonCredit.retire(tokenId);
    emit RetairCarbonNftEvent(carbonAddress,tokenId,msg.sender);


    }


    function BagOrderPaymentNftTransfer(uint itemId,address _to ) external onlyOwner {
        Item storage item = items[itemId];
        require(item.itemId > 0 && item.itemId <= itemCount, "item doesn't exist");
        require(!item.sold, "item already sold");

        // update item to sold
        item.sold = true;
        // update new owner 
        item.owner = payable(_to);
        // transfer nft to buyer
        item.nft.transferFrom(address(this), _to, item.tokenId);
        // emit Bought event
        emit Bought(
            item.itemId,
            address(item.nft),
            item.tokenId,
            item.price,
            item.seller,
            _to);
    }


    // Function to get OrderCarbonDetails matching the product_id
    function getOrderCarbonDetails(string memory order_id, uint project_id)
        public
        view
        returns (OrderCarbonDetails memory)
    {
        OrderCarbonDetails[] memory orderDetailsList = mintLaterOrderDetails[order_id];
        for (uint i = 0; i < orderDetailsList.length; i++) {
            if (orderDetailsList[i].project_id == project_id) {
                return orderDetailsList[i];
            }
        }
        revert("Product ID not found in the order");
    }

    
    function addMintLater(string memory order_id,OrderCarbonDetails memory order) external onlyOwner {
            mintLaterOrderDetails[order_id].push(order);
            emit addMintLaterEvent(order_id,order);
    }

    event withoutWalletOrderEvent(uint256 user_id,string order_id,uint256 project_id,address to,address cpo_address , uint256 tonnes,uint256 no_of_nft,uint256[] nftList);

    function withoutWalletOrder(uint256 user_id,string memory order_id,uint256 project_id,address to,address cpo_address , uint256 tonnes,uint256 no_of_nft)  external onlyOwner{

        uint256[] memory nftlist = CarbonCredit.withoutWalletMint(order_id,user_id,to,cpo_address, project_id, tonnes, no_of_nft);
        
        userWallet[user_id];
        for (uint i = 0; i < nftlist.length; i++) {
             nftUser[nftlist[i]] = user_id;            
        }
        emit withoutWalletOrderEvent(user_id,order_id,project_id,to,cpo_address,tonnes,no_of_nft,nftlist);

    }

    function withoutWalletPostMintingOrder(string memory order_id,WithoutWalletOrderCarbonDetails[] memory orders) external onlyOwner{
        for (uint i=0; i<orders.length; i++) {
            WithoutWalletOrderCarbonDetails memory order = orders[i];
            withoutWalletMintLaterOrderDetails[order_id].push(order);
        }
    }

    function getWithoutWalletOrderCarbonDetails(string memory order_id, uint project_id) public view returns (uint ,WithoutWalletOrderCarbonDetails memory)
    {
        WithoutWalletOrderCarbonDetails[] memory orderDetailsList = withoutWalletMintLaterOrderDetails[order_id];
        for (uint i = 0; i < orderDetailsList.length; i++) {
            if (orderDetailsList[i].project_id == project_id) {
            return (i, orderDetailsList[i]);
            }
        }
        revert("Product ID not found in the order");
    }
    
    function withoutWalletMintNow(string memory order_id,uint project_id,uint specific_tonnes_per_nft ,uint no_of_nfts_for_specific,uint remaining_tonnes) public{
        require(bytes(order_id).length > 0, "Order ID cannot be empty");
        (uint index, WithoutWalletOrderCarbonDetails memory order) = getWithoutWalletOrderCarbonDetails(order_id, project_id);
        require(userWallet[order.buyer_id] == msg.sender, "You are not owner of this order");
        require(!order.is_minted, "You already minted NFT");
        uint no_of_nft  = no_of_nfts_for_specific;
        uint total_tonnes_allowed = (specific_tonnes_per_nft * no_of_nfts_for_specific) + remaining_tonnes ;
        require(total_tonnes_allowed == order.total_tonnes, "You are not allowed to mint this much of tonnes");
        
        address user_address  = userWallet[order.buyer_id];
        
        uint256[] memory nftlist;
        nftlist = CarbonCredit.withoutWalletMint(order_id,order.buyer_id,user_address,order.cpo_address, project_id,specific_tonnes_per_nft, no_of_nfts_for_specific);
        emit withoutWalletOrderEvent(order.buyer_id,order_id,project_id,user_address,order.cpo_address,specific_tonnes_per_nft,no_of_nfts_for_specific,nftlist);

        if(remaining_tonnes > 0){
        nftlist = CarbonCredit.withoutWalletMint(order_id,order.buyer_id,user_address,order.cpo_address, project_id,remaining_tonnes, 1);
        emit withoutWalletOrderEvent(order.buyer_id,order_id,project_id,user_address,order.cpo_address,remaining_tonnes,1,nftlist);
        no_of_nft += 1 ;

        }

        // update order 
        WithoutWalletOrderCarbonDetails storage orderUpdate = withoutWalletMintLaterOrderDetails[order_id][index];
        orderUpdate.is_minted = true;
        orderUpdate.buyer_address = user_address;
        orderUpdate.no_of_nft_for_specified_tonnes = no_of_nfts_for_specific;
        orderUpdate.tonnes_for_specified_nft = specific_tonnes_per_nft;
        orderUpdate.total_specified_tonnes = specific_tonnes_per_nft * no_of_nfts_for_specific;
        orderUpdate.remaining_tonnes = remaining_tonnes;
        orderUpdate.no_of_nft = no_of_nft;
        



    }



    function MintNow(string memory order_id,uint project_id) public  {
        require(bytes(order_id).length > 0, "Order ID cannot be empty");
        OrderCarbonDetails memory order = getOrderCarbonDetails(order_id,project_id);

        require(order.buyer_address == msg.sender, "You are not owner this order ");
        
        // Call CarbonCredit contract to mint the NFT
        CarbonCredit.ContractMint(
            order_id,
            order.buyer_address,
            order.cpo_address,
            order.project_id,
            order.tonnes,
            order.no_of_nft,
            order.price
        );
        
        // Emit event
        emit MintNowEvent(order_id,project_id);
    }

     function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        // Print a "Hello" message
        // You can't actually print messages in Solidity,
        // so we use an event to log the message
        emit NftRecevied(operator,from,tokenId);
        return IERC721Receiver.onERC721Received.selector;
    }

    event withdrawUserNftEvent(uint256 userId,uint256[] tokenIds,address userWalletAddress);

    function withdrawUserNft(uint256[] memory tokenIds,uint256 userId) external {
        require(userWallet[userId] == msg.sender, "You wallet address not matched");

        for (uint i = 0; i < tokenIds.length; i++) {
        require(nftUser[tokenIds[i]] == userId, "You are not the owner of nft");
        CarbonCredit.transferFrom(address(this), msg.sender, tokenIds[i]);

        }
        emit withdrawUserNftEvent(userId,tokenIds,msg.sender);
    }

     
}
// SPDX-License-Identifier: Unli
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


contract BCCarbonCredit is ERC721, ERC721Burnable, Ownable {

    uint256 public tokenIdCounter = 0;
    address payable public  platfromfeeAccount; // the account that receives fees
    uint public  platfromFee = 10; // the fee percentage on sales 
   
    
    mapping(uint256 => uint256) public mintPrice;
    mapping(address => bool) public whitelistContract;
    mapping(uint256 => bool) public retiredTokens;


    struct CarbonProject {
        uint project_id;
        uint tonnes;
        uint no_of_nft;
        uint price;
    }
    event publicMinting(
        uint order_id,
        uint indexed startTokenId,
        uint EndTokenId,
        uint price,
        address indexed cpo,
        address indexed buyer,
        uint platformfee,
        uint platformfeeAmount,
        uint cpoAmount,
        CarbonProject projectDetails
       
    );

    event privateMinting(
        string order_id,
        uint startTokenId,
        uint endTokenId,
        address indexed cpo,
        address indexed buyer,
        CarbonProject projectDetails
    );

    event mintAfterDelayEvent(
        string order_id,
        uint startTokenId,
        uint endTokenId,
        address indexed cpo,
        address indexed buyer,
        CarbonProject projectDetails
    );

    event ContractMinting(
        string order_id,
        uint startTokenId,
        uint endTokenId,
        address indexed cpo,
        address indexed buyer,
        CarbonProject projectDetails,
        address contractAddress
    );

    event withoutWalletMintEvent(
        string order_id,
        uint project_id,
        uint startTokenId,
        uint endTokenId,
        address indexed cpo,
        uint256 indexed userId,
        uint tonnes,
        address indexed contractAddress
    );

    constructor() ERC721("BC Carbon Credit", "BCCC") {}


    function addToWhitelist(address _address) external onlyOwner {
        whitelistContract[_address] = true;
    }

    function removeFromWhitelist(address _address) external onlyOwner {
        whitelistContract[_address] = false;
    }

    function isWhitelisted(address _address) public view returns (bool) {
        return whitelistContract[_address];
    }


        // editable platform Fee and platformFee Account 

    function setMintPrice(uint256 project_id,uint256 price) external onlyOwner{
        mintPrice[project_id] = price;
    }

    function setPlatformFeeAccount(address _platfromfeeAccount) external onlyOwner{
        platfromfeeAccount = payable(_platfromfeeAccount);

    }

    function setPlatformFeePercentage(uint _platfromFee) external onlyOwner{
        require(_platfromFee < 100, "Platform fee cannot be greater than 100%.");
        platfromFee = _platfromFee;

    }

    function _mint(address to, uint256 tokenId) internal override{
        require(isWhitelisted(msg.sender), "Only whitelisted addresses can transfer tokens");
        super._mint(to, tokenId);
    }

    function _safeMint(address to, uint256 tokenId) internal override {
        require(isWhitelisted(msg.sender), "Only whitelisted addresses can transfer tokens");
        super._safeMint(to, tokenId);
    }

    function safeTransferFrom(address from,address to,uint256 tokenId,bytes memory data) public override {
        require(isWhitelisted(msg.sender), "Only whitelisted addresses can transfer tokens");
        require(!retiredTokens[tokenId], "retired token can not transfer");
        super.safeTransferFrom(from, to, tokenId, data);
    }

    function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId
    ) public override {
    require(isWhitelisted(msg.sender), "Only whitelisted addresses can transfer tokens");
    require(!retiredTokens[tokenId], "retired token can not transfer");

    super.safeTransferFrom(from, to, tokenId);
    }
    
    
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        require(isWhitelisted(msg.sender), "Only whitelisted addresses can transfer tokens");
        require(!retiredTokens[tokenId], "retired token can not transfer");
        super.transferFrom(from, to, tokenId);
    }

    function getMintPrice(uint256 project_id) view public returns(uint){
        return((mintPrice[project_id]*(100 + platfromFee ))/100);
    }


    function _baseURI() internal pure override returns (string memory) {
        return "https://api.beachcollective.io/nft/";
    }

    function mint(uint256 order_id,uint256 project_id,uint tonnes,uint no_of_nft,address to,address _cpo) public payable {
        uint price = getMintPrice(project_id);
        require(price != 0, "Carbon price should be greater then 0");
        uint total_price = no_of_nft * tonnes * price;
        require(msg.value == total_price, "Incorrect minting price");
        require(tonnes != 0, "Carbon Tonnes should be greater then 0");
        require(no_of_nft != 0, "Carbon Tonnes should be greater then 0");
        uint startTokenId = tokenIdCounter + 1;

        for (uint256 i = 0; i < no_of_nft; i++) {
            tokenIdCounter++;
            _safeMint(to, tokenIdCounter);
        }
        CarbonProject memory newProject = CarbonProject(project_id,tonnes,no_of_nft,price);
        if (platfromFee > 0){
            uint platfromFeeAmount = msg.value * platfromFee/100 ;
            uint cpoAmount = msg.value - platfromFeeAmount;
            payable(_cpo).transfer(cpoAmount);
            platfromfeeAccount.transfer(platfromFeeAmount);
            emit publicMinting(order_id,startTokenId,tokenIdCounter,price,_cpo,to,platfromFee,platfromFeeAmount,cpoAmount,newProject);
        }else{
            payable(_cpo).transfer(msg.value);
            emit publicMinting(order_id,startTokenId,tokenIdCounter,price,_cpo,to,platfromFee,0,msg.value,newProject);
        }
    }

    

    function privateMint(string memory order_id,address to,address _cpo,uint project_id,uint tonnes,uint no_of_nft,uint price) public onlyOwner {
    uint startTokenId = tokenIdCounter + 1;

    for (uint256 i = 0; i < no_of_nft; i++) {
        tokenIdCounter++;
        _safeMint(to, tokenIdCounter);
    }
    CarbonProject memory newProject = CarbonProject(project_id,tonnes,no_of_nft,price);

    emit privateMinting(
        order_id,
        startTokenId,
        tokenIdCounter,
        _cpo,
        to,newProject);
    }

   function ContractMint(string memory order_id,address to,address _cpo,uint project_id,uint tonnes,uint no_of_nft,uint price) public returns(uint) {
    require(isWhitelisted(msg.sender), "Only whitelisted addresses can mint.");
    uint startTokenId = tokenIdCounter + 1;
    for (uint256 i = 0; i < no_of_nft; i++) {
        tokenIdCounter++;
        _safeMint(to, tokenIdCounter);
    }
    CarbonProject memory newProject = CarbonProject(project_id,tonnes,no_of_nft,price);

    emit ContractMinting(
        order_id,
        startTokenId,
        tokenIdCounter,
        _cpo,
        to,newProject,
        address(msg.sender));

    return tokenIdCounter;

    }

    function withoutWalletMint(string memory order_id,uint256 user_id,address to,address _cpo,uint256 project_id,uint256 tonnes,uint256 no_of_nft) public returns(uint256[] memory) {
    require(isWhitelisted(msg.sender), "Only whitelisted addresses can mint.");
    uint startTokenId = tokenIdCounter + 1;
    uint256[] memory tokenIdList = new uint256[](no_of_nft);
    for (uint256 i = 0; i < no_of_nft; i++) {
        tokenIdCounter++;
        _safeMint(to, tokenIdCounter);
        tokenIdList[i] = tokenIdCounter;
    }

    emit withoutWalletMintEvent(
        order_id,
        project_id,
        startTokenId,
        tokenIdCounter,
        _cpo,
        user_id,
        tonnes,
        address(msg.sender));

    return tokenIdList;

    }




    function retire(uint256 tokenId) public {
        require(isWhitelisted(msg.sender), "Only whitelisted addresses can mint.");
        require(_exists(tokenId), "Token ID does not exist");
        // _burn(tokenId);
        retiredTokens[tokenId] = true;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "Token ID does not exist");
        return string(abi.encodePacked(_baseURI(), Strings.toString(tokenId)));
    }



    function mintAfterDelay(string memory order_id,address to,address _cpo,uint project_id,uint tonnes,uint no_of_nft,uint price) public onlyOwner {
    uint startTokenId = tokenIdCounter + 1;
    for (uint256 i = 0; i < no_of_nft; i++) {
        tokenIdCounter++;

        _safeMint(to, tokenIdCounter);
    }
    CarbonProject memory newProject = CarbonProject(project_id,tonnes,no_of_nft,price);

    emit mintAfterDelayEvent(
        order_id,
        startTokenId,
        tokenIdCounter,
        _cpo,
        to,newProject);
    }

}



// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1, "Math: mulDiv overflow");

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

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
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/Math.sol";
import "./math/SignedMath.sol";

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toString(int256 value) internal pure returns (string memory) {
        return string(abi.encodePacked(value < 0 ? "-" : "", toString(SignedMath.abs(value))));
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/extensions/ERC721Burnable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "../../../utils/Context.sol";

/**
 * @title ERC721 Burnable Token
 * @dev ERC721 Token that can be burned (destroyed).
 */
abstract contract ERC721Burnable is Context, ERC721 {
    /**
     * @dev Burns `tokenId`. See {ERC721-_burn}.
     *
     * Requirements:
     *
     * - The caller must own `tokenId` or be an approved operator.
     */
    function burn(uint256 tokenId) public virtual {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        _burn(tokenId);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
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
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

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
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
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
    function transferFrom(address from, address to, uint256 tokenId) external;

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
    function setApprovalForAll(address operator, bool approved) external;

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _ownerOf(tokenId);
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not token owner or approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns the owner of the `tokenId`. Does NOT revert if token doesn't exist
     */
    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return _owners[tokenId];
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(address to, uint256 tokenId, bytes memory data) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId, 1);

        // Check that tokenId was not minted by `_beforeTokenTransfer` hook
        require(!_exists(tokenId), "ERC721: token already minted");

        unchecked {
            // Will not overflow unless all 2**256 token ids are minted to the same owner.
            // Given that tokens are minted one by one, it is impossible in practice that
            // this ever happens. Might change if we allow batch minting.
            // The ERC fails to describe this case.
            _balances[to] += 1;
        }

        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId, 1);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     * This is an internal function that does not check if the sender is authorized to operate on the token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId, 1);

        // Update ownership in case tokenId was transferred by `_beforeTokenTransfer` hook
        owner = ERC721.ownerOf(tokenId);

        // Clear approvals
        delete _tokenApprovals[tokenId];

        unchecked {
            // Cannot overflow, as that would require more tokens to be burned/transferred
            // out than the owner initially received through minting and transferring in.
            _balances[owner] -= 1;
        }
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId, 1);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId, 1);

        // Check that tokenId was not transferred by `_beforeTokenTransfer` hook
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");

        // Clear approvals from the previous owner
        delete _tokenApprovals[tokenId];

        unchecked {
            // `_balances[from]` cannot overflow for the same reason as described in `_burn`:
            // `from`'s balance is the number of token held, which is at least one before the current
            // transfer.
            // `_balances[to]` could overflow in the conditions described in `_mint`. That would require
            // all 2**256 token ids to be minted, which in practice is impossible.
            _balances[from] -= 1;
            _balances[to] += 1;
        }
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId, 1);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting and burning. If {ERC721Consecutive} is
     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s tokens will be transferred to `to`.
     * - When `from` is zero, the tokens will be minted for `to`.
     * - When `to` is zero, ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     * - `batchSize` is non-zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal virtual {}

    /**
     * @dev Hook that is called after any token transfer. This includes minting and burning. If {ERC721Consecutive} is
     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s tokens were transferred to `to`.
     * - When `from` is zero, the tokens were minted for `to`.
     * - When `to` is zero, ``from``'s tokens were burned.
     * - `from` and `to` are never both zero.
     * - `batchSize` is non-zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal virtual {}

    /**
     * @dev Unsafe write access to the balances, used by extensions that "mint" tokens using an {ownerOf} override.
     *
     * WARNING: Anyone calling this MUST ensure that the balances remain consistent with the ownership. The invariant
     * being that for any address `a` the value returned by `balanceOf(a)` must be equal to the number of tokens such
     * that `ownerOf(tokenId)` is `a`.
     */
    // solhint-disable-next-line func-name-mixedcase
    function __unsafe_increaseBalance(address account, uint256 amount) internal {
        _balances[account] += amount;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
