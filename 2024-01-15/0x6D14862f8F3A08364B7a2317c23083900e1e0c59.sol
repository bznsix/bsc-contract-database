// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.17;


// IERC20 standard interface
interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// Ownership smart contract
abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(msg.sender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
interface AggregatorV3Interface {

  function decimals()
    external
    view
    returns (
      uint8
    );

  function description()
    external
    view
    returns (
      string memory
    );

  function version()
    external
    view
    returns (
      uint256
    );

  function getRoundData(
    uint80 _roundId
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}

// Main Token sale smart contract 
contract BBC_PRESALE is Ownable{
    // Live BNB price variable 
    AggregatorV3Interface internal priceFeed;

    //public variables
    IBEP20 public token;
    address public busdToken;


    uint256 public exchangeRateInBUSD; // exchange rate => 1 BUSD = how many tokens

    
    // Events
    event TokensPurchasedWithBNB(address indexed buyer, uint256 amount, uint256 tokenPaid);
    event TokensPurchasedWithUSDT(address indexed buyer, address tokenAddress, uint256 amount);
    

    constructor(
        IBEP20 _token,
        uint256 _exchangeRateInBUSD
    ) {
        token = _token;
        exchangeRateInBUSD = _exchangeRateInBUSD;
       priceFeed = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE);

    }

 
 

    function updateexchangeRateInBUSD(uint256 _exchangeRate) external onlyOwner {
        exchangeRateInBUSD = _exchangeRate;
    }

   

    function setBUSDToken(address _busdToken) external onlyOwner {
        busdToken = _busdToken;
    }

 function getLatestPriceBNB() public view returns (int) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price / 100000000;
    }
    /**
    * Token Buy
    */

    function buyTokensWithBNB() external payable {
        require (msg.value > 0, "You need to send some BNB");
        int256 latestPrice = getLatestPriceBNB();
        uint256 nativeprice = uint256(latestPrice) ;
        uint256 tokensToBuy = msg.value * (exchangeRateInBUSD * nativeprice);

        require(token.balanceOf(address(this)) >= tokensToBuy, "Not enough tokens left for sale");

        token.transfer(msg.sender, tokensToBuy);
        payable(owner()).transfer(msg.value);

        emit TokensPurchasedWithBNB(msg.sender, msg.value, tokensToBuy);
    }


    function buyTokensWithBUSD(uint256 usdtAmount) external {
        
        require(IBEP20(busdToken).balanceOf(msg.sender) >= usdtAmount, "Not suffiecient balance");
        require(usdtAmount > 0, "Token amount should be greater than zero");

        uint256 amount = usdtAmount * exchangeRateInBUSD;

        require(token.balanceOf(address(this)) >= amount, "Not enough tokens left for sale");
           
        IBEP20(busdToken).transferFrom(msg.sender, owner(), usdtAmount);
            
        token.transfer(msg.sender, amount);

        emit TokensPurchasedWithUSDT(msg.sender, busdToken, amount);
        
    }

    /**
    * This lets owner to withdraw any leftover tokens.
    */
    function withdrawLeftoverTokens(address tokenAddress) external onlyOwner{
        uint256 balance = IBEP20(tokenAddress).balanceOf(address(this));
        require(balance > 0, "No token balance to withdraw");
        IBEP20(tokenAddress).transfer(msg.sender, balance);
    }
}