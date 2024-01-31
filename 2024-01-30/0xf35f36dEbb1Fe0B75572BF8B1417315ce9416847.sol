//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract DragonCoin is ERC20, ERC20Capped, Ownable {
    // Addresses
    address public DEAD = 0x000000000000000000000000000000000000dEaD;
    address private deployerWallet = 0xE670de93DC7D1944F57C61a9314b06DFF7BBEd1D;
    address private stakingWallet = 0xbF003d1988b6EE92cFaDDe09bA43E916B76a3A3C;
    address private cexWallet = 0xF2556F64B17f72C8A2E80E1caD80eD6D4EeA7849;
    address private lpWallet = 0x5023ec088779AFd7569508F86DBDaDd839E8E02a;
    address private p2eWalletOne = 0x1C8cC019dEAEf654Aeb3c8fb948A130aE2EacB22;
    address private p2eWalletTwo = 0xdF51D96B5aB16c753D34c278E7E6185B1eD4E21C;
    address private p2eWalletThree = 0x612f209901Fb0d5e3A0525b3b3d5F921288F56cE;
    address private marketingWallet = 0x2C1bd5DF1F8F9C829f8Bbab0F7576ECEf12f65E9;
    address private marketingWalletOne = 0xC66fe47981a8E65bFb3f18741b9742B00A76bCCC;
    address private marketingWalletTwo = 0xd96541330657Fee4f27268577827320Feb20ebaE;
    address private marketingWalletThree = 0xd17360C901faF0Fa9B671d219a60793073d283D1;
    address private marketingWalletFour = 0xd0F1EA13970ECb65596f76B5a77870C870d66D00;
    address private marketingWalletFive = 0xaaD141D497366BD299dcf98fC33bd65d544D2D5c;
    address private marketingWalletSix = 0x3111F6930d768fCc2f336e82eB5D22ED281bD2Ee;
    address private marketingWalletSev = 0x397123D20fBF39545F2E897D18af928859009859;
    address private marketingWalletEig = 0x14444FbF063dF1456AB813d4b9588F4efC9848cA;
    address private marketingWalletNine = 0xC89d320AfdC0B3305617268890c9E45b26404E74;
    address private marketingWalletTen = 0xAb3DaF14BD077f34ca0746AC99ED1CF720503D85;
    address private redistributionWallet = 0x25fF47A614e6D0BE79A5d61691E6eadD4a57Ed21;
    
    address public _pair;

    // Balances
    uint256 public redistributionBalance;

    // Max Supply
    uint256 public MAX_SUPPLY = 1_000_000_000_000;

    // Tax Rates
    uint16 public buyTaxRate = 50; // 5% on buy
    uint16 public sellTaxRate = 50; // 5% on sell
    uint16 public transferTaxRate = 50; // 5% on transfer
    uint16 public maximumTaxPercentage = 100; // 10%

    // Flags
    bool public taxesEnabled; // Flag to enable/disable taxes
    bool private pairAddressSet = false;

    // Struct to hold tax percentages
    struct Taxes {
        uint16 marketing;
        uint16 burn;
        uint16 team;
        uint16 redistribution;
        uint16 lp;
    }

    // Events
    event EtherWithdrawn(address indexed to, uint256 amount);
    event EtherDeposited(address indexed from, uint256 amount);
    event BotStateChanged(address indexed account, bool newState);
    event ExcludedFromTaxes(address indexed account);
    event IncludedInTaxes(address indexed account);
    event TaxRatesUpdated(
        uint16 indexed newBuyTaxRate,
        uint16 indexed newSellTaxRate,
        uint16 indexed newTransferTaxRate
    );
    event TaxesUpdated(
        uint16 marketing,
        uint16 burn,
        uint16 team,
        uint16 redistribution,
        uint16 lp
    );
    event TaxesEnabled(string message);
    event TaxesDisabled(string message);
    event PairAddressUpdated(address indexed newPair);

    // Struct instance to hold tax percentages
    Taxes public transferTaxes = Taxes(300, 100, 300, 200, 100); // Initialize with default values (3%, 1%, 3%, 2%, 1%)

    // Mapping to exclude addresses from taxes
    mapping(address => bool) private _isExcludedFromTaxes;

    // Mapping to detect bot addresses
    mapping(address => bool) private _isBot;

    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        uint256 supply
    ) ERC20(tokenName, tokenSymbol) ERC20Capped(supply * 1 ether) {
        require(supply <= MAX_SUPPLY, "Initial supply exceeds max supply");
        // Mint 80% of the tokens to LP/DEPLOYER address
        uint256 lpTokens = (supply * 1 ether * 80) / 100;
        _mint(deployerWallet, lpTokens);

        // Mint 5% of the tokens to STAKING address
        uint256 stakingTokens = (supply * 1 ether * 5) / 100;
        _mint(stakingWallet, stakingTokens);

        // Mint 4% of the tokens to CEX address
        uint256 cexTokens = (supply * 1 ether * 4) / 100;
        _mint(cexWallet, cexTokens);

        // Mint 6% of the tokens to P2E address
        uint256 p2eTokens = (supply * 1 ether * 5) / 100;
        _mint(p2eWalletOne, p2eTokens);

        uint256 remainingPercentage = (supply * 1 ether * 5) / 1000; // 0.5% as 5 / 1000

        _mint(p2eWalletTwo, remainingPercentage);
        _mint(p2eWalletThree, remainingPercentage);
        _mint(marketingWalletOne, remainingPercentage);
        _mint(marketingWalletTwo, remainingPercentage);
        _mint(marketingWalletThree, remainingPercentage);
        _mint(marketingWalletFour, remainingPercentage);
        _mint(marketingWalletFive, remainingPercentage);
        _mint(marketingWalletSix, remainingPercentage);
        _mint(marketingWalletSev, remainingPercentage);
        _mint(marketingWalletEig, remainingPercentage);
        _mint(marketingWalletNine, remainingPercentage);
        _mint(marketingWalletTen, remainingPercentage);

        excludeFromTaxes(address(this));
        excludeFromTaxes(deployerWallet);
        excludeFromTaxes(lpWallet);
        excludeFromTaxes(stakingWallet);
        excludeFromTaxes(cexWallet);
        excludeFromTaxes(marketingWallet);
        excludeFromTaxes(marketingWalletThree);
        excludeFromTaxes(marketingWalletFour);
        excludeFromTaxes(marketingWalletFive);
        excludeFromTaxes(p2eWalletOne);
        excludeFromTaxes(p2eWalletTwo);
        excludeFromTaxes(p2eWalletThree);

        taxesEnabled = true;
    }

    function _transfer(
    address sender,
    address recipient,
    uint256 amount
    ) internal virtual override(ERC20) {
        // Check if the sender is identified as a bot
        if (_isBot[sender]) {
            revert("You are identified as a bot");
        }

        // Check if taxes are enabled
        if (taxesEnabled) {
            // Calculate taxes
            uint256 taxAmount = 0;

            // Adjusted logic based on scenarios
            if (sender == _pair) {
                // Buy transaction
                if (!_isExcludedFromTaxes[recipient]) {
                    // Deduct buy taxes
                    taxAmount = (amount * buyTaxRate) / 1000;
                }
            } else if (recipient == _pair) {
                // Sell transaction
                if (!_isExcludedFromTaxes[sender]) {
                    // Deduct sell taxes
                    taxAmount = (amount * sellTaxRate) / 1000;
                }
            } else {
                // Regular transfer
                if (!_isExcludedFromTaxes[sender] && !_isExcludedFromTaxes[recipient]) {
                    // Deduct transfer taxes
                    taxAmount = (amount * transferTaxRate) / 1000;
                }
            }

            // Continue with the rest of the logic when taxAmount > 0
            if (taxAmount > 0) {
                // Deduct tax amount from the transferred amount
                uint256 netAmount = amount - taxAmount;

                // Distribute taxes
                distributeTaxes(sender, taxAmount);

                // Call parent implementation with the net amount after taxes
                super._transfer(sender, recipient, netAmount);
                return;
            }
        }

        // If taxes are disabled or no taxes to deduct, simply transfer the amount
        super._transfer(sender, recipient, amount);
    }

    function distributeTaxes(address sender, uint256 taxAmount) private {
        // Distribute taxes
        uint256 redistribution = (taxAmount * transferTaxes.redistribution) / 1000;
        redistributionBalance += redistribution;

        super._transfer(sender, address(this), redistribution);

        uint256 lpAmount = (taxAmount * transferTaxes.lp) / 1000;
        super._transfer(sender, lpWallet, lpAmount);

        address[5] memory teamWallets = [
            0xe30828551bE2230cf6bfB39055D7557da4deb287,
            0xe63351353B064D99c652F64F86D0121CFAC74eF1,
            0x52f2D80c879C96209C4A7eB9b355a344ca6A132B,
            0x36F83890173C68Af527e4d74D581873490E7A0BC,
            0x04ae22013966860cf675C99AC43Ce613E2C5E30e
        ];

        uint256 teamShare = (taxAmount * transferTaxes.team) / 1000 / teamWallets.length;
        for (uint256 i = 0; i < teamWallets.length; i++) {
            super._transfer(sender, teamWallets[i], teamShare);
        }

        super._transfer(sender, marketingWallet, (taxAmount * transferTaxes.marketing) / 1000);
        super._transfer(sender, DEAD, (taxAmount * transferTaxes.burn) / 1000);
    }

    function _mint(address account, uint256 amount)
        internal
        virtual
        override(ERC20, ERC20Capped)
    {
        require(totalSupply() + amount <= cap(), "ERC20Capped: cap exceeded");
        super._mint(account, amount);
    }

    /**
     * @dev Excludes an address from taxes. Only callable by the owner.
     * @param account The address to be excluded from taxes.
     * @notice Once excluded, the specified address will not incur any taxes on transfers.
     */
    function excludeFromTaxes(address account) public onlyOwner {
        require(account != address(0), "Invalid address");
        _isExcludedFromTaxes[account] = true;
        emit ExcludedFromTaxes(account);
    }

    /**
     * @dev Includes an address in taxes. Only callable by the owner.
     * @param account The address to be included in taxes.
     * @notice Once included, the specified address will be subject to taxes on transfers.
     */
    function includeInTaxes(address account) public onlyOwner {
        require(account != address(0), "Invalid address");
        _isExcludedFromTaxes[account] = false;
        emit IncludedInTaxes(account);
    }

    /**
     * @dev Performs an airdrop to multiple recipients.
     * @param recipients An array of addresses to receive the airdrop.
     * @param amounts An array of amounts to be airdropped to each recipient.
     * @notice The amounts array must have the same length as the recipients array.
     */
    function airdrop(address[] memory recipients, uint256[] memory amounts)
        external
        onlyOwner
    {
        require(
            recipients.length == amounts.length,
            "Mismatched arrays length"
        );

        for (uint256 i = 0; i < recipients.length; i++) {
            uint256 amount = amounts[i];

            require(amount > 0, "Airdrop amount must be greater than 0");
            require(
                amount <= redistributionBalance,
                "Insufficient redistribution balance"
            );

            // Perform airdrop
            _transfer(address(this), recipients[i], amount);

            // Update redistribution balance
            redistributionBalance -= amount;
        }
    }

    /**
     * @dev Checks if an address is excluded from taxes.
     * @param account The address to check for exclusion from taxes.
     * @return Whether the address is excluded from taxes or not.
     */
    function isExcludedFromTaxes(address account) public view returns (bool) {
        return _isExcludedFromTaxes[account];
    }

    /**
     * @dev Sets the bot status of an address. Only callable by the owner.
     * @param account The address for which the bot status is to be set.
     * @param state The new bot status to be set (true for bot, false for non-bot).
     * @notice Bots may have restricted functionality depending on your implementation.
     */

    function setBot(address account, bool state) external onlyOwner {
        require(account != address(0), "Invalid address");
        require(_isBot[account] != state, "Value already set");
        _isBot[account] = state;
        emit BotStateChanged(account, state);
    }

    /**
     * @dev Checks if an address is identified as a bot.
     * @param account The address to check for bot status.
     * @return Whether the address is identified as a bot or not.
     * @notice Bot status may affect certain functionalities based on your implementation.
     */

    function isBot(address account) public view returns (bool) {
        return _isBot[account];
    }

    /**
     * @dev Enables taxes. Only callable by the owner.
     * @notice Once enabled, taxes will be applied on transfers according to configured rates.
     */
    function enableTaxes() external onlyOwner {
        taxesEnabled = true;
        emit TaxesEnabled("Taxes are now enabled.");
    }

    /**
     * @dev Disables taxes. Only callable by the owner.
     * @notice Once disabled, taxes will not be applied on transfers.
     */
    function disableTaxes() external onlyOwner {
        taxesEnabled = false;
        emit TaxesDisabled("Taxes are now disabled.");
    }

    /**
     * @dev Sets the pair address for the contract. Only callable by the owner.
     * @param newPair The new pair address to be set.
     * @notice The pair address is typically associated with a decentralized exchange (DEX).
     */
    function setPairAddress(address newPair) external onlyOwner {
        require(
            newPair != address(0),
            "DragonCoin: Pair address cannot be zero address"
        );

        // Ensure that the pair address can be set only once
        require(
            !pairAddressSet,
            "DragonCoin: Pair address can be set only once"
        );

        _pair = newPair;
        pairAddressSet = true;

        emit PairAddressUpdated(newPair);
    }

    /**
     * @dev Function to withdraw Ether to a specific address. Only callable by the owner.
     * @param to The address to which the Ether should be withdrawn.
     * @param amount The amount of Ether to be withdrawn.
     */
    function withdrawEther(address to, uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Insufficient balance");
        payable(to).transfer(amount);

        // Emit an event to log the withdrawal of Ether.
        emit EtherWithdrawn(to, amount);
    }

    /**
     * @dev Function to update tax rates. Only callable by the owner.
     * @param newBuyTaxRate The new tax rate for buys.
     * @param newSellTaxRate The new tax rate for sells.
     * @param newTransferTaxRate The new tax rate for transfers.
     * @notice Tax rates are in basis points (1% = 100 basis points).
     */

    function updateTaxRates(
        uint16 newBuyTaxRate,
        uint16 newSellTaxRate,
        uint16 newTransferTaxRate
    ) external onlyOwner {
        require(
            newBuyTaxRate <= maximumTaxPercentage &&
                newSellTaxRate <= maximumTaxPercentage &&
                newTransferTaxRate <= maximumTaxPercentage,
            "Invalid tax rate"
        );
        buyTaxRate = newBuyTaxRate;
        sellTaxRate = newSellTaxRate;
        transferTaxRate = newTransferTaxRate;

        emit TaxRatesUpdated(newBuyTaxRate, newSellTaxRate, newTransferTaxRate);
    }

    /**
     * @dev Function to update taxes percentages. Only callable by the owner.
     * @param marketing The new percentage for marketing.
     * @param burn The new percentage for burning.
     * @param team The new percentage for the team.
     * @param redistribution The new percentage for redistribution.
     * @param lp The new percentage for LP tokens.
     * @notice The sum of percentages should not exceed 1000 (100%).
     */
    function updateTaxes(
        uint16 marketing,
        uint16 burn,
        uint16 team,
        uint16 redistribution,
        uint16 lp
    ) external onlyOwner {
        require(
            marketing + burn + team + redistribution + lp <= 1000,
            "Total taxes cannot exceed 100%"
        );
        transferTaxes = Taxes(marketing, burn, team, redistribution, lp);

        emit TaxesUpdated(marketing, burn, team, redistribution, lp);
    }

    receive() external payable {
        emit EtherDeposited(msg.sender, msg.value);
    }
}// SPDX-License-Identifier: MIT
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/ERC20Capped.sol)

pragma solidity ^0.8.0;

import "../ERC20.sol";

/**
 * @dev Extension of {ERC20} that adds a cap to the supply of tokens.
 */
abstract contract ERC20Capped is ERC20 {
    uint256 private immutable _cap;

    /**
     * @dev Sets the value of the `cap`. This value is immutable, it can only be
     * set once during construction.
     */
    constructor(uint256 cap_) {
        require(cap_ > 0, "ERC20Capped: cap is 0");
        _cap = cap_;
    }

    /**
     * @dev Returns the cap on the token's total supply.
     */
    function cap() public view virtual returns (uint256) {
        return _cap;
    }

    /**
     * @dev See {ERC20-_mint}.
     */
    function _mint(address account, uint256 amount) internal virtual override {
        require(ERC20.totalSupply() + amount <= cap(), "ERC20Capped: cap exceeded");
        super._mint(account, amount);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
