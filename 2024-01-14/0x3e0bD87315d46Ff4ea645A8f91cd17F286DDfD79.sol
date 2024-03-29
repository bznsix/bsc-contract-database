// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
// @title SRJSWAP
// @title Interface : Token Standard #20. https://github.com/ethereum/EIPs/issue
interface BEP20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract FELTSwap {
    using SafeMath for uint256;

    address public signer;
    address public nativeAddress = 0x9D30F7086E985B60e0893f6C5e948D578E836658; // Native coin address
    address public Usdt = 0x55d398326f99059fF775485246999027B3197955; // Usdt coin address
    BEP20 public native = BEP20(nativeAddress);  // Native coin on this contract
    
   
    struct Coins{
        string symbol;
        uint256 pp;
        uint256 sp;
        bool isExists;
        bool isNative;
    }

    mapping(address => Coins) public coins;

    event Swap(address buyer, string from, string to, uint256 famount, uint256 tamount);
    event Sell(address buyer, address coin, uint256 amount);
    
    // @dev Detects Authorized Signer.
    modifier onlySigner(){
        require(msg.sender == signer,"You are not authorized signer.");
        _;
    }

    // @dev Returns coin balance on this contract.
    function getBalanceSheet(address _coin) public view returns(uint256 bal){
        require(coins[_coin].isExists,"Invalid Coin!");
        bal =  BEP20(_coin).balanceOf(address(this));
        return bal;
    }

    // @dev Restricts unauthorized access by another contract.
    modifier security{
        uint size;
        address sandbox = msg.sender;
        assembly  { size := extcodesize(sandbox) }
        require(size == 0,"Smart Contract detected.");
        _;
    }

    constructor() public {
        signer = msg.sender;

        coins[nativeAddress].symbol = "FELT";
        coins[nativeAddress].isExists = true;
        coins[nativeAddress].isNative = true;

        coins[Usdt].symbol = "Usdt";
        coins[Usdt].pp = 50;
        coins[Usdt].sp = 60;
        coins[Usdt].isExists = true;
        coins[Usdt].isNative = false;
    
    }
    
    // @dev Swap coins only which are available to swap in this contract.
    function swap(address _from, address _to, uint256 _amount) public payable security{
        require(coins[_from].isExists==true,"Invalid coin");
        require(coins[_to].isExists==true,"Invalid coin");
        
        require(coins[_from].isNative==true && coins[_to].isNative==false || coins[_from].isNative==false && coins[_to].isNative==true,"Swapping native coin only.");
        uint256 scaledAmount = 0;
        
        if(coins[_to].isNative==true){
            scaledAmount = _amount.mul(coins[_from].pp).div(100);
        }
        else if(coins[_to].isNative==false){
            scaledAmount = _amount.mul(coins[_to].sp).div(100);
        }
        require(scaledAmount<=BEP20(_to).balanceOf(address(this)),"Insufficient coins!");
        require(BEP20(_from).transferFrom(msg.sender,address(this),_amount));
        BEP20(_to).transfer(msg.sender,scaledAmount);
        emit Swap(msg.sender, coins[_from].symbol, coins[_to].symbol, _amount.div(1e18), scaledAmount.div(1e18));
    }

    // @dev Register new coin to swap on this contract
    function registerCoin(address _coin, string memory _sym, uint256 _pp, uint _sp) external onlySigner security{
        require(coins[_coin].isExists==false,"Coin already exists!");
        coins[_coin].pp = _pp;
        coins[_coin].sp = _sp;
        coins[_coin].symbol = _sym;
        coins[_coin].isExists = true;
        coins[_coin].isNative = false;
    }

    // @dev Overrides pp and sp only, not available for symbol, isExists and isNative.
    // @dev Not application for native coin.
    function setLocal(address _coin, uint256 _pp, uint _sp) external onlySigner security{
        require(coins[_coin].isExists==true && coins[_coin].isNative==false,"Either coin is native or coin does not exists!");
        coins[_coin].pp = _pp;
        coins[_coin].sp = _sp;
    }

    // @dev Settle coin to swap on this contract
    function coinSettlement(address _coin, bool action) external onlySigner security{
        require(coins[_coin].isNative==false,"Native coin settlement is not allowed.");
        coins[_coin].isExists = action;
    }

    // @dev Sell coins directly to buyer instead of swapping
    function sell(address payable buyer, address _coin, uint _amount) external onlySigner security{
        BEP20(_coin).transfer(buyer, _amount);
        emit Sell(buyer, _coin, _amount);
    }
   
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) { return 0; }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}