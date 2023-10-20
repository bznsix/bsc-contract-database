pragma solidity ^0.8.4;
    // SPDX-License-Identifier: Unlicensed

    abstract contract Context {
        function _msgSender() internal view virtual returns (address payable) {
            return payable(msg.sender);
        }

        function _msgData() internal view virtual returns (bytes memory) {
            this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
            return msg.data;
        }
    }

    contract Ownable is Context {
        address private _owner;

        event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

        constructor () {
            address msgSender = _msgSender();
            _owner = msgSender;
            emit OwnershipTransferred(address(0), msgSender);
        }

        function owner() public view returns (address) {
            return _owner;
        }   
        
        modifier onlyOwner() {
            require(_owner == _msgSender(), "Ownable: caller is not the owner");
            _;
        }


        function transferOwnership(address newOwner) public virtual onlyOwner {
            require(newOwner != address(0), "Ownable: new owner is the zero address");
            emit OwnershipTransferred(_owner, newOwner);
            _owner = newOwner;
        }
    }


    abstract contract ReentrancyGuard {
    
        uint256 private constant _NOT_ENTERED = 1;
        uint256 private constant _ENTERED = 2;

        uint256 private _status;

        constructor() {
            _status = _NOT_ENTERED;
        }

    
        modifier nonReentrant() {
            // On the first call to nonReentrant, _notEntered will be true
            require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

            // Any calls to nonReentrant after this point will fail
            _status = _ENTERED;

            _;

            // By storing the original value once again, a refund is triggered (see
            // https://eips.ethereum.org/EIPS/eip-2200)
            _status = _NOT_ENTERED;
        }
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
            // assert(a == b * c + a % b); // There is no case in which this doesn't hold
            return c;
        }

        function mod(uint256 a, uint256 b) internal pure returns (uint256) {
            return mod(a, b, "SafeMath: modulo by zero");
        }

        function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
            require(b != 0, errorMessage);
            return a % b;
        }
    }

    interface IERC20 {

        function totalSupply() external view returns (uint256);
        function balanceOf(address account) external view returns (uint256);
        function transfer(address recipient, uint256 amount) external returns (bool);
        function allowance(address owner, address spender) external view returns (uint256);
        function approve(address spender, uint256 amount) external returns (bool);
        function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(address indexed owner, address indexed spender, uint256 value);
        
    }

    interface IProviderPair {
            function getReserves()
                external
                view
                returns (
                    uint112,
                    uint112,
                    uint32
                );
            function token0() external view returns(address);
            function token1() external view returns(address);
        }   

    // import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

    interface AggregatorV3Interface{
        function latestRoundData() external view returns(uint80, int, uint, uint, uint80);
    }

    contract Presale is ReentrancyGuard, Ownable {
        using SafeMath for uint256;
        
        mapping (address => uint256) public _contributions;
        mapping (address => uint256) public _BUSDcontributions;
        mapping (address => uint256) public _ETHcontributions;
        mapping (address => uint256) public _BTCcontributions;

        IERC20 public _BUSD;
        IERC20 public _ETH;
        IERC20 public _BTC;
        IProviderPair public BusdBnb;
        IProviderPair public BusdEth;
        IProviderPair public BusdBtc;

        // AggregatorV3Interface internal priceFeed;
        address payable public _wallet;
        uint256 public _busdrate;
        uint256 public _bnbRaised;
        uint256 public _busdRaised;
        uint256 public _ethRaised;
        uint256 public _btcRaised;
        uint256 public startICOTime;
        uint public hardCap;
        uint public minSaleCYY;
        uint256 public endICO;

        event TokensPurchased(address  purchaser, address  beneficiary, uint256 value, uint256 amount);

        constructor (address payable wallet, IERC20 busd, IERC20 eth, IERC20 btc, uint256 cycoinBusdRate, IProviderPair _BusdBnb, IProviderPair _BusdEth, IProviderPair _BusdBtc)  {
            require(wallet != address(0), "Pre-Sale: wallet is the zero address");
            // priceFeed = AggregatorV3Interface(_priceFeed);
            _BUSD = busd;
            _ETH = eth;
            _BTC = btc;
            _wallet = wallet;
            _busdrate = cycoinBusdRate;
            BusdBnb = _BusdBnb;
            BusdEth = _BusdEth;
            BusdBtc = _BusdBtc;
        }

        receive () external payable {
            if(endICO > 0 && block.timestamp < endICO){
                buyTokens(_msgSender());
            } else {
                endICO = 0;
                revert("Pre-Sale is closed");
            }
        }

        function TotalTokenDistributed() public view returns(uint256){
            uint256 tokensAmt = _getTokenAmount(_bnbRaised);
            uint256 busdtokensAmt = _getTokenAmountBUSD(_busdRaised);
            uint256 ethtokensAmt = _getTokenAmountETH(_ethRaised);
            uint256 btctokensAmt = _getTokenAmountBTC(_btcRaised);
            uint256 totalAmount = tokensAmt + busdtokensAmt + ethtokensAmt + btctokensAmt;
            return totalAmount;
        }
        
        //Start Pre-Sale
        function startICO(uint _start, uint _end , uint256 _hardCap) external onlyOwner icoNotActive() {
            require(_start < _end, "Start time must be less then end time");
            startICOTime = _start;
            endICO = _end; 
            hardCap = _hardCap;
            _bnbRaised = 0;
            _busdRaised = 0;
            _ethRaised = 0;
            _btcRaised = 0;
        }
        
        function stopICO() external onlyOwner icoActive(){
            startICOTime = 0;
            endICO = 0;
        }
        
        function AddProvider(IProviderPair _BusdBnb, IProviderPair _BusdEth, IProviderPair _BusdBtc) external onlyOwner{
            BusdBnb = _BusdBnb;
            BusdEth = _BusdEth;
            BusdBtc = _BusdBtc;
        }
        //Pre-Sale 
        function buyTokens(address _beneficiary) public nonReentrant icoActive payable {
            uint256 bnbAmount = msg.value;
            _wallet.transfer(bnbAmount);
            uint256 tokens = _getTokenAmount(bnbAmount);
            _bnbRaised = _bnbRaised.add(bnbAmount);
            _contributions[_beneficiary] = _contributions[_beneficiary].add(bnbAmount);
            emit TokensPurchased(_msgSender(), _beneficiary, bnbAmount, tokens);
        }

        function buyTokensBUSD(address _beneficiary, uint256 _BUSDAmount) public nonReentrant icoActive {
            _BUSD.transferFrom(msg.sender,_wallet, _BUSDAmount);
            uint256 tokens = _getTokenAmountBUSD(_BUSDAmount);
            _busdRaised = _busdRaised.add(_BUSDAmount);
            _BUSDcontributions[_beneficiary] = _BUSDcontributions[_beneficiary].add(_BUSDAmount);
            emit TokensPurchased(_msgSender(), _beneficiary, _BUSDAmount, tokens);
        }

        function buyTokensETH(address _beneficiary, uint256 _ETHAmount) public nonReentrant icoActive {
            _ETH.transferFrom(msg.sender,_wallet, _ETHAmount);
            uint256 tokens = _getTokenAmountETH(_ETHAmount);
            _ethRaised = _ethRaised.add(_ETHAmount);
            _ETHcontributions[_beneficiary] = _ETHcontributions[_beneficiary].add(_ETHAmount);
            emit TokensPurchased(_msgSender(), _beneficiary, _ETHAmount, tokens);
        }

        function buyTokensBTC(address _beneficiary, uint256 _BTCAmount) public nonReentrant icoActive {
            _BTC.transferFrom(msg.sender,_wallet, _BTCAmount);
            uint256 tokens = _getTokenAmountBTC(_BTCAmount);
            _btcRaised = _btcRaised.add(_BTCAmount);
            _BTCcontributions[_beneficiary] = _BTCcontributions[_beneficiary].add(_BTCAmount);
            emit TokensPurchased(_msgSender(), _beneficiary, _BTCAmount, tokens);
        }

        function withdraw() external onlyOwner icoNotActive{
            uint256 busdbalance = _BUSD.balanceOf(address(this));
            uint256 ethbalance = _ETH.balanceOf(address(this));
            uint256 btcbalance = _BTC.balanceOf(address(this));
            _wallet.transfer(address(this).balance);  
            _BUSD.transfer(_wallet, busdbalance);
            _ETH.transfer(_wallet, ethbalance);
            _BTC.transfer(_wallet, btcbalance);
        }

        
        function setStartICO(uint256 _start) external onlyOwner{
            startICOTime = _start;
        }

        function setEndICO(uint256 _endICO) external onlyOwner{
            endICO = _endICO;
        }

        function setAddress(IERC20 busd, IERC20 eth, IERC20 btc) external onlyOwner icoNotActive{
            _BUSD = busd;
            _ETH = eth;
            _BTC = btc;
        }

        function setbusdrate(uint256 _newRate) external onlyOwner icoNotActive{
            _busdrate = _newRate;
        }

        function setHardCap(uint256 _value) external onlyOwner{
            hardCap = _value;
        }
        
        function setWalletReceiver(address payable _newWallet) external onlyOwner(){
            _wallet = _newWallet;
        }
        
        function takeTokens(IERC20 _TokenAddress)  public onlyOwner icoNotActive{
            IERC20 tokenBEP = _TokenAddress;
            uint256 tokenAmt = tokenBEP.balanceOf(address(this));
            require(tokenAmt > 0, 'BEP-20 balance is 0');
            tokenBEP.transfer(_wallet, tokenAmt);
        }
        
        modifier icoActive() {
            require(endICO > 0 && block.timestamp < endICO && startICOTime < block.timestamp, "ICO must be active");
            _;
        }
        
        modifier icoNotActive() {
            require(endICO < block.timestamp, "ICO should not be active");
            _;
        }

        function _getTokenAmount(uint256 _bnbAmount) internal view returns (uint256) {
            return _bnbAmount.mul(bnbRate()).div(10**9);
        }

        function _getTokenAmountBUSD(uint256 _busdAmount) internal view returns (uint256) {
            return (_busdAmount.mul(_busdrate)).div(10**9);
        } 
        
        function _getTokenAmountETH(uint256 _ethAmount) internal view returns (uint256) {
            return _ethAmount.mul(ethRate()).div(10**9);
        } 
        
        function _getTokenAmountBTC(uint256 _btcAmount) internal view returns (uint256) {
            return _btcAmount.mul(btcRate()).div(10**9);
        }

        function getPriceData(IProviderPair _pairAddress) public view returns (uint256) {
            uint112 reserve0;
            uint112 reserve1;
            uint32 timestamp;
            uint256 exchangeRate;
            (reserve0, reserve1, ) = IProviderPair(_pairAddress).getReserves();
            uint256 reserve0_= uint256(reserve0);
            uint256 reserve1_= uint256(reserve1);
            address token0 = IProviderPair(_pairAddress).token0();
            if(token0 == address(_BUSD)){
                exchangeRate = (reserve0_*(10**9))/reserve1_;    
            }else{
                exchangeRate = (reserve1_*(10**9))/reserve0_;
            }
            return (exchangeRate);
        }
        
        function bnbRate() public view returns(uint256){
            uint256 bnbrate = (getPriceData(BusdBnb).mul(_busdrate)).div(10**9);
            return (bnbrate);
        }

        function ethRate() public view returns(uint256){
            uint256 ethrate = (getPriceData(BusdEth).mul(_busdrate)).div(10**9);
            return (ethrate);
        }

        function btcRate() public view returns(uint256){
            uint256 btcrate = (getPriceData(BusdBtc).mul(_busdrate)).div(10**9);
            return (btcrate);
        }
    }