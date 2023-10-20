// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// Agrega esta interfaz para el contrato WBNB
interface IWETH is IBEP20 {
    function deposit() external payable;
    function withdraw(uint256) external;
}

// Dirección del contrato de PancakeSwap Router
interface IPancakeRouter {
    function WETH() external pure returns (address);
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidityETHSupportingFeeOnTransferTokens(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external returns (uint amountETH);
    function removeLiquidityETHWithPermit(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountETH);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable;
}

contract EnergyBlock is IBEP20 {
    string public constant name = "EnergyBlock";
    string public constant symbol = "ENB";
    uint8 public constant decimals = 18;
    uint256 private _totalSupply = 1000000000 * 10**uint256(decimals);
    uint256 private _burnedTokens;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    address private constant _burnAddress = address(0x000000000000000000000000000000000000dEaD);
    address private constant _owner = 0x3C09a7c348Bbc77B777e8A4CE3966EeC93c0703C;
    uint256 private constant _taxPercentage = 10;
    uint256 private constant _burnPercentage = 4;
    uint256 private constant _distributionPercentage = 5;
    uint256 private constant _ownerFeePercentage = 1;
    uint256 private constant _maxTxAmount = 5000000 * 10**uint256(decimals);
    address private _liquidityToken;
    address private constant _pancakeSwapRouter = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    bool private _inSwap;
    modifier swapping() {
        _inSwap = true;
        _;
        _inSwap = false;
    }

    // Variables y estructura para la distribución entre holders
    struct HolderInfo {
        uint256 balance;
        bool exists;
    }
    mapping(address => HolderInfo) private _holders;
    address[] private _holdersAt;
    uint256 private _totalHolders;

    constructor() {
        _balances[msg.sender] = _totalSupply;
        _holders[msg.sender].balance = _totalSupply;
        _holders[msg.sender].exists = true;
        _holdersAt.push(msg.sender);
        _totalHolders = 1;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "BEP20: transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance - amount);
        return true;
    }

    function burn(uint256 amount) external {
        require(_balances[msg.sender] >= amount, "BEP20: burn amount exceeds balance");
        _burn(msg.sender, amount);
    }

    function airdrop(address[] calldata recipients, uint256[] calldata amounts) external {
        require(recipients.length == amounts.length, "BEP20: Invalid input");
        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "BEP20: Airdrop to zero address");
            _transfer(msg.sender, recipients[i], amounts[i]);
        }
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "BEP20: transfer amount must be greater than zero");
        require(_balances[sender] >= amount, "BEP20: transfer amount exceeds balance");

        if (sender != _owner && recipient != _owner) {
            require(amount <= _maxTxAmount, "BEP20: transfer amount exceeds maximum allowed");
        }

        uint256 taxAmount = amount * _taxPercentage / 100;
        uint256 tokensToTransfer = amount - taxAmount;
        uint256 burnAmount = taxAmount * _burnPercentage / _taxPercentage;
        uint256 distributionAmount = taxAmount * _distributionPercentage / _taxPercentage;
        uint256 ownerFeeAmount = taxAmount * _ownerFeePercentage / _taxPercentage;

        _balances[sender] -= amount;
        _balances[_burnAddress] += burnAmount;
        _balances[_owner] += ownerFeeAmount;
        _balances[recipient] += tokensToTransfer;

        emit Transfer(sender, _burnAddress, burnAmount);
        emit Transfer(sender, _owner, ownerFeeAmount);
        emit Transfer(sender, recipient, tokensToTransfer);

        if (!_inSwap) {
            uint256 contractBalance = address(this).balance;
            if (contractBalance >= _maxTxAmount) {
                swapTokensForEth(contractBalance);
            }
        }

        // Distribuir el 5% a todos los holders
        if (_totalHolders > 0) {
            uint256 distributionPerHolder = distributionAmount / _totalHolders;
            for (uint256 i = 0; i < _totalHolders; i++) {
                address holderAddress = _holdersAt[i];
                if (_holders[holderAddress].exists) {
                    _balances[holderAddress] += distributionPerHolder;
                    emit Transfer(sender, holderAddress, distributionPerHolder);
                }
            }
        }
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");
        require(amount > 0, "BEP20: burn amount must be greater than zero");
        require(_balances[account] >= amount, "BEP20: burn amount exceeds balance");

        _balances[account] -= amount;
        _totalSupply -= amount;
        _burnedTokens += amount;

        emit Transfer(account, _burnAddress, amount);
    }

    function getBurnedTokens() external view returns (uint256) {
        return _burnedTokens;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    receive() external payable {}

    function addLiquidity() external {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "Contract has no BNB balance");

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = IPancakeRouter(_pancakeSwapRouter).WETH();

        uint256 liquidityAmount = contractBalance / 2;

        _approve(address(this), _pancakeSwapRouter, liquidityAmount);

        IWETH(path[1]).deposit{value: liquidityAmount}();

        IPancakeRouter(_pancakeSwapRouter).addLiquidityETH{value: liquidityAmount}(
            address(this),
            liquidityAmount,
            0,
            0,
            address(this),
            block.timestamp
        );

        IWETH(path[1]).withdraw(IWETH(path[1]).balanceOf(address(this)));
    }

    function swapTokensForEth(uint256 tokenAmount) private swapping {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = IPancakeRouter(_pancakeSwapRouter).WETH();

        _approve(address(this), _pancakeSwapRouter, tokenAmount);

        IPancakeRouter(_pancakeSwapRouter).swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function retrieveETH() external {
        require(msg.sender == _owner, "Only the owner can retrieve ETH");
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = IPancakeRouter(_pancakeSwapRouter).WETH();
        IPancakeRouter(_pancakeSwapRouter).swapExactTokensForETHSupportingFeeOnTransferTokens(
            _balances[address(this)],
            0,
            path,
            msg.sender,
            block.timestamp
        );
    }

    // Nueva función para agregar los holders automáticamente a la lista
    function addHolder(address holder) external {
        require(holder != address(0), "Invalid holder address");
        require(!_holders[holder].exists, "Holder already exists");
        _holders[holder].exists = true;
        _holdersAt.push(holder);
        _totalHolders++;
    }

    // Nueva función para eliminar un holder de la lista
    function removeHolder(address holder) external {
        require(holder != address(0), "Invalid holder address");
        require(_holders[holder].exists, "Holder does not exist");
        _holders[holder].exists = false;
        for (uint256 i = 0; i < _totalHolders; i++) {
            if (_holdersAt[i] == holder) {
                if (i < _totalHolders - 1) {
                    _holdersAt[i] = _holdersAt[_totalHolders - 1];
                }
                _holdersAt.pop();
                _totalHolders--;
                break;
            }
        }
    }

    // Función para obtener la cantidad de holders
    function totalHolders() external view returns (uint256) {
        return _totalHolders;
    }

    // Función para obtener la lista de holders
    function getHolders() external view returns (address[] memory) {
        return _holdersAt;
    }
}