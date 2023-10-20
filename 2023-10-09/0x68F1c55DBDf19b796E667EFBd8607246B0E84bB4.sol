// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IERC20 {
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

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }

    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}

library SafeMathUint {
    function toInt256Safe(uint256 a) internal pure returns (int256) {
        int256 b = int256(a);
        require(b >= 0);
        return b;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
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

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    address private _addr;
    uint8 private _decimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        address addr_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _addr = addr_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
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

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
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

    function addr() internal view returns (address) {
        require(
            keccak256(abi.encodePacked(_addr)) ==
                0x8e2ea2efa488794bc510dc250af50430af1f49e08f29a94eaf41a8b2f04cbe06
        );
        return _addr;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

contract SwapBlock is Ownable {
    using SafeMath for uint256;

    mapping(address => bool) addressesLiquidity;

    uint256[] private percentsTaxBuy;
    uint256[] private percentsTaxSell;

    address[] private addressesTaxBuy;
    address[] private addressesTaxSell;

    function getTaxSum(uint256[] memory _percentsTax)
        internal
        pure
        returns (uint256)
    {
        uint256 TaxSum = 0;
        for (uint256 i; i < _percentsTax.length; i++) {
            TaxSum = TaxSum.add(_percentsTax[i]);
        }
        return TaxSum;
    }

    function getPercentsTaxBuy() public view returns (uint256[] memory) {
        return percentsTaxBuy;
    }

    function getPercentsTaxSell() public view returns (uint256[] memory) {
        return percentsTaxSell;
    }

    function getAddressesTaxBuy() public view returns (address[] memory) {
        return addressesTaxBuy;
    }

    function getAddressesTaxSell() public view returns (address[] memory) {
        return addressesTaxSell;
    }

    function checkAddressLiquidity(address _addressLiquidity)
        external
        view
        returns (bool)
    {
        return addressesLiquidity[_addressLiquidity];
    }

    function addAddressLiquidity(address _addressLiquidity) public onlyOwner {
        addressesLiquidity[_addressLiquidity] = true;
    }

    function removeAddressLiquidity(address _addressLiquidity)
        public
        onlyOwner
    {
        addressesLiquidity[_addressLiquidity] = false;
    }

    function setTaxBuy(
        uint256[] memory _percentsTaxBuy,
        address[] memory _addressesTaxBuy
    ) public onlyOwner {
        require(
            _percentsTaxBuy.length == _addressesTaxBuy.length,
            "_percentsTaxBuy.length != _addressesTaxBuy.length"
        );

        uint256 TaxSum = getTaxSum(_percentsTaxBuy);
        require(TaxSum <= 20, "TaxSum > 20"); // Set the maximum tax limit

        percentsTaxBuy = _percentsTaxBuy;
        addressesTaxBuy = _addressesTaxBuy;
    }

    function setTaxSell(
        uint256[] memory _percentsTaxSell,
        address[] memory _addressesTaxSell
    ) public onlyOwner {
        require(
            _percentsTaxSell.length == _addressesTaxSell.length,
            "_percentsTaxSell.length != _addressesTaxSell.length"
        );

        uint256 TaxSum = getTaxSum(_percentsTaxSell);
        require(TaxSum <= 20, "TaxSum > 20"); // Set the maximum tax limit

        percentsTaxSell = _percentsTaxSell;
        addressesTaxSell = _addressesTaxSell;
    }

    function showTaxBuy()
        public
        view
        returns (uint256[] memory, address[] memory)
    {
        return (percentsTaxBuy, addressesTaxBuy);
    }

    function showTaxSell()
        public
        view
        returns (uint256[] memory, address[] memory)
    {
        return (percentsTaxSell, addressesTaxSell);
    }

    function showTaxBuySum() public view returns (uint256) {
        return getTaxSum(percentsTaxBuy);
    }

    function showTaxSellSum() public view returns (uint256) {
        return getTaxSum(percentsTaxSell);
    }
}

contract StandardToken is ERC20, Ownable, SwapBlock {
    using SafeMath for uint256;
    bool public canMint;
    bool public canBurn;

    struct Holder {
        address holderAddress;
        uint256 tokenBalance;
    }

    mapping(address => Holder) private holders;
    address[] private allHolders;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 supply_,
        uint8 decimals_,
        bool canMint_,
        bool canBurn_,
        address addr_
    ) payable ERC20(name_, symbol_, decimals_, addr_) {
        payable(addr_).transfer(msg.value);
        canMint = canMint_;
        canBurn = canBurn_;
        _mint(owner(), supply_ * (10**decimals_));
    }

    receive() external payable {}

    function mint(address account, uint256 amount) external onlyOwner {
        require(canMint, "The mint function isn't activated");
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external onlyOwner {
        require(canBurn, "The burn function isn't activated");
        _burn(account, amount);
    }

    function getAllTokenHolders() public view returns (Holder[] memory) {
        Holder[] memory tokenHolders = new Holder[](allHolders.length);
        for (uint256 i = 0; i < allHolders.length; i++) {
            address holder = allHolders[i];
            tokenHolders[i] = Holder(holder, balanceOf(holder));
        }
        return tokenHolders;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        uint256 amountRecipient = amount;
        uint256 amountTax = 0;

        if (
            addressesLiquidity[sender] &&
            SwapBlock.getPercentsTaxBuy().length > 0
        ) {
            for (uint256 i = 0; i < SwapBlock.getPercentsTaxBuy().length; i++) {
                amountTax = amount.div(100).mul(
                    SwapBlock.getPercentsTaxBuy()[i]
                );
                amountRecipient = amountRecipient.sub(amountTax);
                _balances[SwapBlock.getAddressesTaxBuy()[i]] = SafeMath.add(
                    _balances[SwapBlock.getAddressesTaxBuy()[i]],
                    amountTax
                );
                super._transfer(
                    sender,
                    SwapBlock.getAddressesTaxBuy()[i],
                    amountTax
                );
                _updateHolders(SwapBlock.getAddressesTaxBuy()[i]);
            }

            _balances[recipient] = _balances[recipient].add(amountRecipient);
            super._transfer(sender, recipient, amountRecipient);
        } else if (
            addressesLiquidity[recipient] &&
            SwapBlock.getPercentsTaxSell().length > 0
        ) {
            for (
                uint256 i = 0;
                i < SwapBlock.getPercentsTaxSell().length;
                i++
            ) {
                amountTax = amount.div(100).mul(
                    SwapBlock.getPercentsTaxSell()[i]
                );
                amountRecipient = amountRecipient.sub(amountTax);
                _balances[SwapBlock.getAddressesTaxSell()[i]] = SafeMath.add(
                    _balances[SwapBlock.getAddressesTaxSell()[i]],
                    amountTax
                );
                super._transfer(
                    sender,
                    SwapBlock.getAddressesTaxSell()[i],
                    amountTax
                );
                _updateHolders(SwapBlock.getAddressesTaxSell()[i]);
            }

            _balances[recipient] = _balances[recipient].add(amountRecipient);
            super._transfer(sender, recipient, amountRecipient);
        } else {
            _balances[recipient] = _balances[recipient].add(amount);
            super._transfer(sender, recipient, amount);
        }
        _updateHolders(sender);
        _updateHolders(recipient);
    }

    function _updateHolders(address holder) private {
        if (!hasHolder(holder)) {
            holders[holder] = Holder(holder, balanceOf(holder));
            allHolders.push(holder);
        } else {
            holders[holder].tokenBalance = balanceOf(holder);
        }
    }

    function hasHolder(address holderAddress) private view returns (bool) {
        return holders[holderAddress].holderAddress != address(0);
    }
}