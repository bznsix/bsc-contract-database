// SPDX-License-Identifier: GPL-3.0
/*
https://x.com/KarenBelen49693?s=09

https://t.me/TokenLaMoro

¡LaMoro: Construyendo Sueños con Propósito!

Bienvenido a LaMoro, el meme token que va más allá de las risas para construir un futuro sólido y hacer realidad un sueño . 
Queremos ser completamente transparentes contigo: ¡No somos una estafa! 
Estamos comprometidos con la honestidad y el desarrollo genuino.

Impuestos para el Desarrollo:

Sabemos que los impuestos pueden generar inquietudes, pero en LaMoro, 
queremos que sepas que cada impuesto tiene un propósito claro. 
No se trata de llenar nuestros bolsillos, ¡sino de construir un entorno sólido alrededor del token! 
Cada impuesto contribuirá al desarrollo, promoción y sostenibilidad de LaMoro.

Construcción de La Casa Soñada:

Lo más emocionante es que parte de los fondos recaudados se destinarán a ayudar en la construcción de la casa soñada.
Sí, has leído bien. Con los impuestos generados, queremos alcanzar el sueños de una CASA. 
A medida que LaMoro crece y la demanda aumenta, liberaremos tokens adicionales para poder hacer realidad ese anhelo tan especial: la construcción de un hogar .

Contribución a la Comunidad:

No solo nos enfocamos en el sueños de la Casa, sino también en nuestra comunidad. 
Parte de los fondos también se destinarán a proyectos que beneficien a los demas. 
Creemos en la prosperidad compartida y trabajamos para construir una comunidad Solida.

Únete a Nosotros en Este Viaje:

LaMoro no es solo un meme token; es una comunidad con visión de futuro. 
Únete a nosotros mientras construimos, prosperamos y hacemos realidad los sueños juntos.

¡Juntos, somos LaMoro!

*/
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/IBEP20.sol";

contract LaMoro is IBEP20 {
    using SafeMath for uint256;

    string private _name = "LaMoro";
    string private _symbol = "LaMoro";
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 50000000 * 10**_decimals;
    address private _owner;
    address private _taxWallet = 0xcE889444B52eB11B7325e5c2021E8d5306756467;
    uint256 private _buyTax = 1;
    uint256 private _sellTax = 1;
    uint256 private _maxBuyAmount = _totalSupply.div(10);
    uint256 private _maxTxAmount = _totalSupply.div(10);
    bool private _paused = false;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Paused(address account);
    event Unpaused(address account);
    event Mint(address account, uint256 amount);
    event Burn(address account, uint256 amount);

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _txCounter;
    mapping(address => bool) private _isExcludedFromBuyLimit;
    mapping(address => bool) private _isExcludedFromSellTax;

    modifier onlyOwner() {
        require(_owner == msg.sender, "LaMoro: Solo el dueno puede llamar a esta funcion");
        _;
    }

    function getOwner() external view override returns (address) {
        return _owner;
    }

    modifier whenNotPaused() {
        require(!_paused, "LaMoro: El token esta pausado");
        _;
    }

    modifier whenPaused() {
        require(_paused, "LaMoro: El token no esta pausado");
        _;
    }

    constructor() {
        _balances[msg.sender] = _totalSupply;
        _owner = msg.sender;
        emit Transfer(address(0), msg.sender, _totalSupply);

        _isExcludedFromBuyLimit[_owner] = true;
        _isExcludedFromBuyLimit[_taxWallet] = true;
        _isExcludedFromSellTax[_owner] = true;
        _isExcludedFromSellTax[_taxWallet] = true;
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override whenNotPaused returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override whenNotPaused returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override whenNotPaused returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(amount <= currentAllowance, "LaMoro: La cantidad excede la autorizacion");

        _approve(sender, msg.sender, currentAllowance - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public whenNotPaused returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public whenNotPaused returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(subtractedValue <= currentAllowance, "LaMoro: El valor restado excede la autorizacion");

        _approve(msg.sender, spender, currentAllowance - subtractedValue);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "LaMoro: La transferencia desde la direccion cero no esta permitida");
        require(recipient != address(0), "LaMoro: La transferencia a la direccion cero no esta permitida");
        require(amount > 0, "LaMoro: La cantidad debe ser mayor que cero");

        uint256 senderBalance = _balances[sender];
        require(amount <= senderBalance, "LaMoro: La cantidad excede el balance");

        uint256 senderTxCounter = _txCounter[sender];
        require(senderTxCounter < _maxTxAmount, "LaMoro: Se ha alcanzado el limite de transacciones por dia");
        _txCounter[sender] = senderTxCounter + 1;

        uint256 tax = 0;

        if (recipient == address(this)) {
            tax = _sellTax;
            if (!_isExcludedFromSellTax[sender]) {
                uint256 taxValue = amount.mul(tax).div(100);
                amount = amount.sub(taxValue);
                _balances[_taxWallet] = _balances[_taxWallet].add(taxValue);
                emit Transfer(sender, _taxWallet, taxValue);
            }
        } else if (sender == address(this)) {
            tax = _buyTax;
            if (!_isExcludedFromBuyLimit[recipient]) {
                require(amount <= _maxBuyAmount, "LaMoro: La cantidad excede el limite de compra");
            }
            uint256 taxValue = amount.mul(tax).div(100);
            amount = amount.sub(taxValue);
            _balances[_taxWallet] = _balances[_taxWallet].add(taxValue);
            emit Transfer(sender, _taxWallet, taxValue);
        }

        _balances[sender] = senderBalance - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "LaMoro: La autorizacion desde la direccion cero no esta permitida");
        require(spender != address(0), "LaMoro: La autorizacion a la direccion cero no esta permitida");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function mint(address account, uint256 amount) public onlyOwner whenNotPaused {
        require(account != address(0), "LaMoro: Minting to zero address is not allowed");
        require(amount > 0, "LaMoro: La cantidad debe ser mayor que cero");
        _totalSupply = _totalSupply + amount;
        _balances[account] = _balances[account] + amount;

        emit Transfer(address(0), account, amount);
        emit Mint(account, amount);
    }

    function burn(address account, uint256 amount) public onlyOwner whenNotPaused {
        require(account != address(0), "LaMoro: La quema desde la direccion cero no esta permitida");
        require(amount > 0, "LaMoro: La cantidad debe ser mayor que cero");

        uint256 accountBalance = _balances[account];
        require(amount <= accountBalance, "LaMoro: La cantidad excede el balance");

        _balances[account] = accountBalance - amount;
        _totalSupply = _totalSupply - amount;

        emit Transfer(account, address(0), amount);
        emit Burn(account, amount);
    }

    function pause() public onlyOwner whenNotPaused {
        _paused = true;
        emit Paused(_owner);
    }

    function unpause() public onlyOwner whenPaused {
        _paused = false;
        emit Unpaused(_owner);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "LaMoro: La transferencia de propiedad a la direccion cero no esta permitida");
        address oldOwner = _owner;
        _owner = newOwner;

        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function setBuyTax(uint256 newBuyTax) public onlyOwner {
        require(newBuyTax <= 1, "LaMoro: El impuesto de compra no puede ser mayor que 1");
        _buyTax = newBuyTax;
    }

    function setSellTax(uint256 newSellTax) public onlyOwner {
        require(newSellTax <= 1, "LaMoro: El impuesto de venta no puede ser mayor que 1");
        _sellTax = newSellTax;
    }

    function setTaxWallet(address newTaxWallet) public onlyOwner {
        require(newTaxWallet != address(0), "LaMoro: La billetera de impuestos no puede ser la direccion cero");
        _taxWallet = newTaxWallet;
    }

    function setMaxBuyAmount(uint256 newMaxBuyAmount) public onlyOwner {
        require(newMaxBuyAmount <= _totalSupply, "LaMoro: El limite de compra no puede ser mayor que el suministro total");
        _maxBuyAmount = newMaxBuyAmount;
    }

    function setMaxTxAmount(uint256 newMaxTxAmount) public onlyOwner {
        require(newMaxTxAmount <= _totalSupply, "LaMoro: El limite de transacciones no puede ser mayor que el suministro total");
        _maxTxAmount = newMaxTxAmount;
    }

    function excludeFromBuyLimit(address account) public onlyOwner {
        require(account != address(0), "LaMoro: La exclusion de la direccion cero no esta permitida");
        _isExcludedFromBuyLimit[account] = true;
    }

    function includeInBuyLimit(address account) public onlyOwner {
        require(account != address(0), "LaMoro: La inclusion de la direccion cero no esta permitida");
        _isExcludedFromBuyLimit[account] = false;
    }

    function excludeFromSellTax(address account) public onlyOwner {
        require(account != address(0), "LaMoro: La exclusion de la direccion cero no esta permitida");
        _isExcludedFromSellTax[account] = true;
    }

    function includeInSellTax(address account) public onlyOwner {
        require(account != address(0), "LaMoro: La inclusion de la direccion cero no esta permitida");
        _isExcludedFromSellTax[account] = false;
    }
}
contract LaMoroWithRenounce is LaMoro {
    constructor() {
        // No se requiere ninguna lógica adicional en el constructor.
    }

    // La función renounceOwnership ya está heredada de LaMoro, no es necesario volver a implementarla aquí.
}
// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.4.0;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
