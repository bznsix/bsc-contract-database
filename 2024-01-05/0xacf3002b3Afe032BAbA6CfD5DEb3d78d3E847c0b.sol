// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.19;

/// @notice Simple single owner authorization mixin.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Owned.sol)
abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnershipTransferred(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner) {
        owner = _owner;

        emit OwnershipTransferred(address(0), _owner);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function transferOwnership(address newOwner) public virtual onlyOwner {
        owner = newOwner;

        emit OwnershipTransferred(msg.sender, newOwner);
    }
}

abstract contract Fee is Owned {
    uint256 public feeRate = 500;
    address immutable usdt;

    constructor(address _u) {
        usdt = _u;
    }

    function setFeeRate(uint256 _feeRate) external onlyOwner {
        require(_feeRate <= 10_000, "<=10_000");
        feeRate = _feeRate;
    }
}

abstract contract Pausable is Owned {
    bool public paused;

    error ExpectedPause();

    modifier whenNotPaused() {
        require(!paused || msg.sender == owner, "paused");
        _;
    }

    function pause() external onlyOwner {
        paused = true;
    }

    function unpause() external onlyOwner {
        paused = false;
    }
}

interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

address constant Fund = 0xFCC6Bb27D1c0B5e79A25e84E208864458936fEB2;

abstract contract SellMarket is Pausable, Fee {
    struct ListingSell {
        address token;
        uint256 price;
        address seller;
        uint256 amount;
        uint256 index;
        bool canceled;
    }

    event SellItemListed(address indexed seller, address indexed token, uint256 amount, uint256 price);
    event SellItemCanceled(address indexed seller, uint256 id, uint256 amount);
    event ItemBuy(address indexed buyer, uint256 id, uint256 amount);

    ListingSell[] public sellItems;

    function listSell(address _token, uint256 _amount, uint256 _price) internal returns (uint256 id) {
        uint256 i = sellItems.length;

        ListingSell memory order;
        order.token = _token;
        order.seller = msg.sender;
        order.amount = _amount;
        order.price = _price;
        order.index = i;

        sellItems.push(order);
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        emit SellItemListed(msg.sender, _token, _amount, _price);
        return i;
    }

    function canceSelllListing(uint256 id) external whenNotPaused {
        ListingSell storage delItem = sellItems[id];
        require(msg.sender == delItem.seller, "not seller");
        require(delItem.amount > 0, ">0");

        uint256 ooA = delItem.amount;
        delItem.amount = 0;
        delItem.canceled = true;

        IERC20(delItem.token).transfer(msg.sender, ooA);
        emit SellItemCanceled(msg.sender, id, delItem.amount);
    }

    function buyItem(uint256 id, uint256 _amount) external whenNotPaused {
        require(_amount > 0, ">0");
        ListingSell storage listedItem = sellItems[id];

        listedItem.amount -= _amount;

        IERC20(listedItem.token).transfer(msg.sender, _amount);

        uint256 uamount = _amount * listedItem.price / 10_000;
        IERC20(IERC20(usdt)).transferFrom(msg.sender, address(this), uamount);
        uint256 fee = uamount * feeRate / 10000;
        IERC20(usdt).transfer(Fund, fee);
        IERC20(usdt).transfer(listedItem.seller, uamount - fee);

        emit ItemBuy(msg.sender, listedItem.index, _amount);
    }

    function allSellItems() external view returns (ListingSell[] memory) {
        uint256 length = sellItems.length;
        ListingSell[] memory nitem = new ListingSell[](length);
        for (uint256 i = 1; i < length; i++) {
            nitem[i] = sellItems[i];
        }
        return nitem;
    }

    function allSellItemsWithLength(uint256 start, uint256 end) external view returns (ListingSell[] memory) {
        ListingSell[] memory nitem = new ListingSell[](end - start);
        for (uint256 i = start; i < end; i++) {
            nitem[i] = sellItems[i];
        }
        return nitem;
    }

    function sellItemCount() public view returns (uint256 length) {
        length = sellItems.length;
    }
}

abstract contract BuyMarket is Pausable, Fee {
    struct ListingBuy {
        address token;
        uint256 price;
        address buyer;
        uint256 amount;
        uint256 index;
        bool canceled;
    }

    event BuyItemListed(address indexed buyer, address indexed token, uint256 amount, uint256 price);
    event BuyItemCanceled(address indexed buyer, uint256 id, uint256 amount);
    event ItemSell(address indexed seller, uint256 id, uint256 amount);

    ListingBuy[] public buyItems;

    function listBuy(address _token, uint256 _amount, uint256 _price) internal returns (uint256 id) {
        uint256 i = buyItems.length;

        ListingBuy memory order;
        order.token = _token;
        order.buyer = msg.sender;
        order.amount = _amount;
        order.price = _price;
        order.index = i;

        buyItems.push(order);
        IERC20(usdt).transferFrom(msg.sender, address(this), _amount * _price / 10_000);
        emit BuyItemListed(msg.sender, _token, _amount, _price);
        return i;
    }

    function canceBuylListing(uint256 id) external whenNotPaused {
        ListingBuy storage delItem = buyItems[id];
        require(msg.sender == delItem.buyer, "not Buyer");
        require(delItem.amount > 0, ">0");

        uint256 ooA = delItem.amount;

        delItem.amount = 0;
        delItem.canceled = true;

        uint256 returnUSD = ooA * delItem.price / 10_000;
        IERC20(usdt).transfer(msg.sender, returnUSD);
        emit BuyItemCanceled(msg.sender, id, returnUSD);
    }

    function sellItem(uint256 id, uint256 _amount) external whenNotPaused {
        require(_amount > 0, ">0");
        ListingBuy storage listedItem = buyItems[id];

        listedItem.amount -= _amount;

        uint256 uamount = _amount * listedItem.price / 10_000;
        uint256 fee = uamount * feeRate / 10000;
        IERC20(usdt).transfer(Fund, fee);
        IERC20(usdt).transfer(msg.sender, uamount - fee);

        IERC20(listedItem.token).transferFrom(msg.sender, listedItem.buyer, _amount);

        emit ItemSell(msg.sender, listedItem.index, _amount);
    }

    function allbuyItems() external view returns (ListingBuy[] memory) {
        uint256 length = buyItems.length;
        ListingBuy[] memory nitem = new ListingBuy[](length);
        for (uint256 i = 1; i < length; i++) {
            nitem[i] = buyItems[i];
        }
        return nitem;
    }

    function getBuyItem(uint256 index) external view returns (ListingBuy memory) {
        return buyItems[index];
    }

    function allbuyItemsWithLength(uint256 start, uint256 end) external view returns (ListingBuy[] memory) {
        ListingBuy[] memory nitem = new ListingBuy[](end - start);
        for (uint256 i = start; i < end; i++) {
            nitem[i] = buyItems[i];
        }
        return nitem;
    }

    function buyItemCount() public view returns (uint256 length) {
        length = buyItems.length;
    }
}

contract Marketplace is Fee, SellMarket, BuyMarket {
    mapping(address => uint256) public lastTimeListItem;

    constructor(address _u) Owned(msg.sender) Fee(_u) {}

    function listItem(address _token, uint256 _amount, uint256 _price, bool _sell)
        external
        whenNotPaused
        returns (uint256)
    {
        require(_amount > 0, "_amount>0");
        require(_price > 0, "_price>0");

        require((lastTimeListItem[msg.sender] + 5 seconds) <= block.timestamp, "5m");
        lastTimeListItem[msg.sender] = block.timestamp;

        if (_sell) {
            return listSell(_token, _amount, _price);
        } else {
            return listBuy(_token, _amount, _price);
        }
    }
}