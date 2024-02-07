/**
 *Submitted for verification at BscScan.com on 2024-02-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

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

library TransferHelper {
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function decimals() external view returns (uint8);
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

contract OTCController is Ownable, ReentrancyGuard {
    mapping(address => bool) public isExcludedFromFees;  
    mapping(address => uint256) public totalFees;        
    address public treasury = address(0x573f6136285e7955E34cF87BEdFc6a789A77aAb3);      

    struct ProductInfo {
        uint256 pId;                   
        address baseToken;              
        uint8 baseTokenDecimal;       
        string baseTokenUrl;           
        address quoteToken;           
        uint8 quoteTokenDecimal;      
        string quoteTokenUrl;          
        uint8 priceDecimal;         
        uint256 volumeMin;            
        uint256 guidePrice;            
        uint16 feeThousandth;      
        uint16 acceptorThousandth;    
        uint8 isUse;                 
    }
    ProductInfo[] public productInfos; 

    mapping(uint256 => uint256) public productTotalVol; 
    mapping(uint256 => uint256) public productTotalAmt; 

    struct OrderInfo {
        uint256 orderId;              
        uint256 pId;                    
        address user;                 
        uint256 time;                 
        uint8 direction;             
        uint256 price;                
        uint256 volume;               
        uint256 doneVolume;           
        uint256 fees;                 
        uint8 status;                 
        uint256 prev;                 
        uint256 next;                 
    }
    OrderInfo[] public orderInfos;   
    mapping (uint256 => mapping(address => uint256[])) public orderUserIdx;   
    
    mapping (uint256 => mapping(uint256 => uint256)) public priceBuyOrderFirst; 
    mapping (uint256 => mapping(uint256 => uint256)) public priceBuyOrderLast;      
    mapping (uint256 => mapping(uint256 => uint256)) public priceSellOrderFirst;    
    mapping (uint256 => mapping(uint256 => uint256)) public priceSellOrderLast;   

    struct AskBidInfo {
        uint256 price;  
        uint256 volume;  
    }
    mapping (uint256 => mapping(uint8 => mapping(uint256 => bool))) public priceExists; 
    mapping (uint256 => mapping(uint8 => uint256[])) public priceArr;   

    mapping (uint256 => mapping(uint8 => mapping(uint256 => uint256))) public priceVolMap;  


    constructor() {
        orderInfos.push(OrderInfo({orderId:0,pId:0,user:address(0),time:0,direction:0,price:0,volume:0,doneVolume:0,fees:0,status:0,prev:0,next:0}));
    }


    event SetExcludeFromFees(address account, bool excluded);

    function setExcludeFromFees(address account_, bool excluded_) public onlyOwner returns (bool success) {
        isExcludedFromFees[account_] = excluded_;

        emit SetExcludeFromFees(account_, excluded_);

        return true;
    }

    event SetTreasury(address treasury);
    function setTreasury(address treasury_) public onlyOwner returns (bool success) {
        treasury = treasury_;
        
        emit SetTreasury(treasury_);

        return true;
    }

    event AddProduct(uint256 pId);
    function addProduct(address baseToken_, string memory baseTokenUrl_, address quoteToken_, string memory quoteTokenUrl_, uint8 priceDecimal_, uint256 volumeMin_, uint256 guidePrice_, uint16 feeThousandth_, uint16 acceptorThousandth_) public onlyOwner returns(bool) {
        require(feeThousandth_ < 1000 && acceptorThousandth_ < 1000 && acceptorThousandth_ <= feeThousandth_, "Fee And Acceptor Error");

        ProductInfo memory pi = ProductInfo({
            pId: productInfos.length + 1, 
            baseToken: baseToken_, 
            baseTokenDecimal: IERC20(baseToken_).decimals(),
            baseTokenUrl: baseTokenUrl_,
            quoteToken: quoteToken_,
            quoteTokenDecimal: IERC20(quoteToken_).decimals(),
            quoteTokenUrl: quoteTokenUrl_,
            priceDecimal: priceDecimal_,
            volumeMin: volumeMin_,
            guidePrice: guidePrice_,
            feeThousandth: feeThousandth_,
            acceptorThousandth: acceptorThousandth_,
            isUse: 1
        });
        productInfos.push(pi);
        emit AddProduct(pi.pId);
        return true;
    }


    event EditProduct(uint256 pId);
    function editProduct(uint256 pId_, uint8 priceDecimal_, uint256 volumeMin_, uint16 feeThousandth_, uint16 acceptorThousandth_) public onlyOwner returns(bool) {
        require(feeThousandth_ < 1000 && acceptorThousandth_ < 1000 && acceptorThousandth_ <= feeThousandth_, "Fee And Acceptor Error");

        ProductInfo storage pi = productInfos[pId_ - 1];
        
        pi.priceDecimal = priceDecimal_;
        pi.volumeMin = volumeMin_;
        pi.feeThousandth = feeThousandth_;
        pi.acceptorThousandth = acceptorThousandth_;

        emit EditProduct(pi.pId);
        return true;
    }

    event StopProduct(uint256 pId);
    function stopProduct(uint256 _pId) public onlyOwner returns(bool) {
        ProductInfo storage pi = productInfos[_pId - 1];

        pi.isUse = 2;

        emit StopProduct(_pId);

        return true;
    }


    event AddOrder(uint256 pId, uint8 direction, uint256 price, uint256 volume);

    function order(uint256 pId_, uint8 direction_, uint256 price_, uint256 volume_) external nonReentrant {
        require(pId_ <= productInfos.length, "Product Not Found.");

        ProductInfo memory pi = productInfos[pId_ - 1];

        require(pi.isUse == 1, "Product Not In Use.");
        require(volume_ >= pi.volumeMin, "Volume Error.");
        require(price_ / (10 ** (18 - pi.priceDecimal)) * (10 ** (18 - pi.priceDecimal))  == price_, "Price Error.");
        require(direction_ == 1 || direction_ == 2, "Direction Error.");

        OrderInfo memory oi = OrderInfo({
            orderId: orderInfos.length, 
            pId: pId_,
            user: _msgSender(), 
            time: block.timestamp, 
            direction: direction_, 
            price:  price_,
            volume: volume_,
            doneVolume: 0,
            fees: 0,
            status: 1,
            prev: direction_ == 1 ? priceBuyOrderLast[pId_][price_] : priceSellOrderLast[pId_][price_],
            next: 0
        });

        if (direction_ == 1) { 
            uint256 amt = price_ * volume_ / 1e18;
            uint256 amtBefore = IERC20(pi.quoteToken).balanceOf(address(this));
            TransferHelper.safeTransferFrom(pi.quoteToken, _msgSender(), address(this), amt);
            require(IERC20(pi.quoteToken).balanceOf(address(this)) - amtBefore == amt, "Volume Not Enough.");

            if(priceBuyOrderLast[pId_][price_] > 0) {
                orderInfos[priceBuyOrderLast[pId_][price_]].next = orderInfos.length;
            }
            priceBuyOrderLast[pId_][price_] = orderInfos.length;
            
            if(priceBuyOrderFirst[pId_][price_] == 0) {
                priceBuyOrderFirst[pId_][price_] = orderInfos.length;
            }
        } else {  
            uint256 amtBefore = IERC20(pi.baseToken).balanceOf(address(this));
            TransferHelper.safeTransferFrom(pi.baseToken, _msgSender(), address(this), volume_);
            require(IERC20(pi.baseToken).balanceOf(address(this)) - amtBefore == volume_, "Volume Not Enough.");

            if (priceSellOrderLast[pId_][price_] > 0) {
                orderInfos[priceSellOrderLast[pId_][price_]].next = orderInfos.length;
            }
            priceSellOrderLast[pId_][price_] = orderInfos.length;

            if(priceSellOrderFirst[pId_][price_]==0) {
                priceSellOrderFirst[pId_][price_] = orderInfos.length;
            }
        }
        priceVolMap[pId_][direction_][price_] += volume_;

        if (!priceExists[pId_][direction_][price_]) {
            priceArr[pId_][direction_].push(price_);
            priceExists[pId_][direction_][price_] = true;
        }

        orderInfos.push(oi);
        orderUserIdx[pId_][_msgSender()].push(orderInfos.length - 1);

        emit AddOrder(pId_, direction_, price_, volume_);
    }


    event AddTrade(address user, uint256 pId, uint8 direction, uint256 price, uint256 volume);

    function trade(uint256 pId_, uint8 direction_, uint256 price_, uint256 volume_) public nonReentrant {
        require(pId_ <= productInfos.length, "Product Not Found.");
        ProductInfo storage pi = productInfos[pId_ - 1];
        require(pi.isUse == 1, "Product Not In Use.");
        require(volume_ >= pi.volumeMin, "Volume Error.");
        require(direction_ == 1 || direction_ == 2, "Direction Error.");
        require(priceVolMap[pId_][direction_ == 1 ? 2 : 1][price_] >= volume_, "Volume Max Than Order.");

        uint256 firstOrderId = priceSellOrderFirst[pId_][price_];        
        if (direction_ == 2) {
            firstOrderId = priceBuyOrderFirst[pId_][price_];
        }
        require(firstOrderId > 0, "No Order.");        


        if(direction_ == 1) {  
            if (isExcludedFromFees[_msgSender()]) { 
                uint256 amt = (volume_ * price_ * (1000 - pi.acceptorThousandth) / 1000) / 1e18;
                uint256 amtBefore = IERC20(pi.quoteToken).balanceOf(address(this));
                TransferHelper.safeTransferFrom(pi.quoteToken, _msgSender(), address(this), amt);
                require(IERC20(pi.quoteToken).balanceOf(address(this)) - amtBefore == amt, "Volume Not Enough.");

                totalFees[pi.quoteToken] += (volume_ * price_ * (pi.feeThousandth - pi.acceptorThousandth) / 1000) / 1e18;
                TransferHelper.safeTransfer(pi.quoteToken, treasury, (volume_ * price_ * (pi.feeThousandth - pi.acceptorThousandth) / 1000) / 1e18);
            } else {
                uint256 amt = volume_ * price_ / 1e18;
                uint256 amtBefore = IERC20(pi.quoteToken).balanceOf(address(this));
                TransferHelper.safeTransferFrom(pi.quoteToken, _msgSender(), address(this), amt);
                require(IERC20(pi.quoteToken).balanceOf(address(this)) - amtBefore == amt, "Volume Not Enough.");

                totalFees[pi.quoteToken] += volume_ * price_ * pi.feeThousandth / 1000 / 1e18;
                TransferHelper.safeTransfer(pi.quoteToken, treasury, volume_ * price_ * pi.feeThousandth / 1000 / 1e18);
            }            
        } else { 
            uint256 amtBefore = IERC20(pi.baseToken).balanceOf(address(this));
            TransferHelper.safeTransferFrom(pi.baseToken, _msgSender(), address(this), volume_);
            require(IERC20(pi.baseToken).balanceOf(address(this)) - amtBefore == volume_, "Volume Not Enough.");
        }
        
        uint256 volumeLeft = volume_;
        while (volumeLeft > 0) {
            OrderInfo storage orderInfo = orderInfos[firstOrderId];
            
            uint256 fillAmount = orderInfo.volume - orderInfo.doneVolume >= volumeLeft ? volumeLeft : orderInfo.volume - orderInfo.doneVolume;
            orderInfo.doneVolume += fillAmount;
            volumeLeft -= fillAmount;
            
            if (direction_ == 1) { 
                TransferHelper.safeTransfer(pi.quoteToken, orderInfo.user, fillAmount * price_ * (1000 - pi.feeThousandth) / 1000 / 1e18);

                orderInfo.fees += fillAmount * price_ * pi.feeThousandth / 1000 / 1e18;
            }else{
                TransferHelper.safeTransfer(pi.baseToken, orderInfo.user, fillAmount);
            }

            if(orderInfo.volume == orderInfo.doneVolume) {
                if(direction_ == 1) {
                    priceSellOrderFirst[pId_][price_] = orderInfo.next;
                }else{
                    priceBuyOrderFirst[pId_][price_] = orderInfo.next;
                }
                orderInfo.status = 3;
            } else {
                orderInfo.status = 2;
            }

            if(orderInfo.next == 0) {
                break;
            }
            firstOrderId = orderInfo.next;
        }

        require(volumeLeft == 0, "Volume Not Enough...");

        if (direction_ == 1) { 
            TransferHelper.safeTransfer(pi.baseToken, _msgSender(), volume_);
        } else {
            uint256 amt = volume_ * price_;
            TransferHelper.safeTransfer(pi.quoteToken, _msgSender(), amt * (1000 - pi.feeThousandth) / 1000 / 1e18);

            totalFees[pi.quoteToken] += amt * pi.feeThousandth / 1000 / 1e18;
            TransferHelper.safeTransfer(pi.quoteToken, treasury, amt * pi.feeThousandth / 1000 / 1e18);
        }

        priceVolMap[pId_][direction_ == 1 ? 2 : 1][price_] -= volume_;

        pi.guidePrice = price_;
        productTotalVol[pId_] += volume_;
        productTotalAmt[pId_] += price_ * volume_ / 1e18;

        emit AddTrade(_msgSender(), pId_, direction_, price_, volume_);
    }

    

    event Cancel(uint256 orderId);
    function cancel(uint256 orderId_) public nonReentrant {
        OrderInfo storage orderInfo = orderInfos[orderId_];
        require(orderInfo.user == _msgSender() || owner() == _msgSender(), "Not Your Order.");
        require(orderInfo.status < 3, "Canceled Or Finished.");
        ProductInfo memory pi = productInfos[orderInfo.pId - 1];

        if(orderInfo.prev > 0) orderInfos[orderInfo.prev].next = orderInfo.next;
        if(orderInfo.next > 0) orderInfos[orderInfo.next].prev = orderInfo.prev;

        if(priceSellOrderFirst[orderInfo.pId][orderInfo.price]==orderId_) priceSellOrderFirst[orderInfo.pId][orderInfo.price] = orderInfo.next;
        if(priceSellOrderLast[orderInfo.pId][orderInfo.price]==orderId_) priceSellOrderLast[orderInfo.pId][orderInfo.price] = orderInfo.prev;
        if(priceBuyOrderFirst[orderInfo.pId][orderInfo.price]==orderId_) priceBuyOrderFirst[orderInfo.pId][orderInfo.price] = orderInfo.next;
        if(priceBuyOrderLast[orderInfo.pId][orderInfo.price]==orderId_) priceBuyOrderLast[orderInfo.pId][orderInfo.price] = orderInfo.prev;

        if(orderInfo.direction == 1) {
            uint256 amt = (orderInfo.volume - orderInfo.doneVolume) * orderInfo.price / 1e18; 
            TransferHelper.safeTransfer(pi.quoteToken, _msgSender(), amt);
        }else{
            TransferHelper.safeTransfer(pi.baseToken, _msgSender(), orderInfo.volume - orderInfo.doneVolume);
        }
        orderInfo.status = 4;
        priceVolMap[orderInfo.pId][orderInfo.direction][orderInfo.price] -= (orderInfo.volume - orderInfo.doneVolume);

        emit Cancel(orderId_);
    }



    function getAskBids(uint256 pId_) public view returns(AskBidInfo[] memory _askInfos, AskBidInfo[] memory _bidInfos) {
        uint256 len;
        for(uint256 i = 0; i < priceArr[pId_][2].length; i++) {
            if (priceVolMap[pId_][2][priceArr[pId_][2][i]] > 0) {
                len ++;
            }
        }
        _askInfos = new AskBidInfo[](len);

        uint256 j;
        for(uint256 i = 0; i < priceArr[pId_][2].length; i++) {
            if (priceVolMap[pId_][2][priceArr[pId_][2][i]] > 0) {
                AskBidInfo memory ab = AskBidInfo({
                    price: priceArr[pId_][2][i], 
                    volume: priceVolMap[pId_][2][priceArr[pId_][2][i]]
                });

                _askInfos[j++] = ab;
            }
        }


        len = 0;
        for(uint256 i = 0; i < priceArr[pId_][1].length; i++) {
            if (priceVolMap[pId_][1][priceArr[pId_][1][i]] > 0) {
                len ++;
            }
        }
        _bidInfos = new AskBidInfo[](len);

        j = 0;
        for(uint256 i = 0; i < priceArr[pId_][1].length; i++) {
            if (priceVolMap[pId_][1][priceArr[pId_][1][i]] > 0) {
                AskBidInfo memory ab = AskBidInfo({
                    price: priceArr[pId_][1][i], 
                    volume: priceVolMap[pId_][1][priceArr[pId_][1][i]]
                });

                _bidInfos[j++] = ab;
            }
        }
    }


    function getUserOrders(address user_, uint256 pId_) public view returns(OrderInfo[] memory _orderInfos) {
        if (orderUserIdx[pId_][user_].length == 0) {
            return _orderInfos;
        }
         
        _orderInfos = new OrderInfo[](orderUserIdx[pId_][user_].length);

        uint256 i;
        for(uint256 k = orderUserIdx[pId_][user_].length - 1; k >= 0 ; ){
            _orderInfos[i++] = orderInfos[orderUserIdx[pId_][user_][k]];
            if (k > 0) {
                k--;
            } else {
                break;
            }
        }
    }


    function getUserOrdersPage(address user_, uint256 pId_, uint256 page_, uint256 num_) public view returns(OrderInfo[] memory _orderInfos, uint256 _orderTotal) {
        _orderTotal = orderUserIdx[pId_][user_].length;

        if ((page_ - 1) * num_ >= _orderTotal) {
            return (_orderInfos, _orderTotal);
        }

        uint256 j = _orderTotal >= page_ * num_ ? num_ : _orderTotal - (page_ - 1) * num_;
        if (j == 0) {
            return (_orderInfos, _orderTotal);
        }
        _orderInfos = new OrderInfo[](j);

        uint256 _fromIdx = _orderTotal - (page_ - 1) * num_ - 1;

        j = 0;
        for(uint256 i = _fromIdx; i >= 0 && j < num_;) {
            _orderInfos[j] = orderInfos[orderUserIdx[pId_][user_][i]];
            j++;
            if (i > 0) {
                i--;
            } else {
                break;
            }            
        }

        return (_orderInfos, _orderTotal);
    }


    function getProducts() public view returns(ProductInfo[] memory _productInfos) {
        _productInfos = new ProductInfo[](productInfos.length);

        for(uint256 k = 0; k < productInfos.length; k++){
            _productInfos[k] = productInfos[k];
        }
    }

    function rescueToken(address tokenAddress, uint256 tokens) public onlyOwner returns (bool success) {
        TransferHelper.safeTransfer(tokenAddress, owner(), tokens);
        return true;
    }

    function rescueETH() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }
}