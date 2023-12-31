// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns(address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns(bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


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
contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns(address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() public view returns(uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime, "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}


// File: openzeppelin-solidity/contracts/ownership/Whitelist.sol

/**
 * @title Whitelist
 * @dev The Whitelist contract has a whitelist of addresses, and provides basic authorization control functions.
 * @dev This simplifies the implementation of "user permissions".
 */
contract Whitelist is Ownable {
    mapping(address => bool) public whitelist;

    event WhitelistedAddressAdded(address addr);
    event WhitelistedAddressRemoved(address addr);

    /**
     * @dev Throws if called by any account that's not whitelisted.
     */
    modifier onlyWhitelisted() {
        require(whitelist[msg.sender], 'no whitelist');
        _;
    }

    /**
     * @dev add an address to the whitelist
     * @param addr address
     */
    function addAddressToWhitelist(address addr) onlyOwner public returns(bool success) {
        if (!whitelist[addr]) {
            whitelist[addr] = true;
            emit WhitelistedAddressAdded(addr);
            success = true;
        }
    }

    /**
     * @dev add addresses to the whitelist
     * @param addrs addresses
     */
    function addAddressesToWhitelist(address[] memory addrs) onlyOwner public returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (addAddressToWhitelist(addrs[i])) {
                success = true;
            }
        }
        return success;
    }

    /**
     * @dev remove an address from the whitelist
     * @param addr address
     */
    function removeAddressFromWhitelist(address addr) onlyOwner public returns(bool success) {
        if (whitelist[addr]) {
            whitelist[addr] = false;
            emit WhitelistedAddressRemoved(addr);
            success = true;
        }
        return success;
    }

    /**
     * @dev remove addresses from the whitelist
     * @param addrs addresses
     */
    function removeAddressesFromWhitelist(address[] memory addrs) onlyOwner public returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (removeAddressFromWhitelist(addrs[i])) {
                success = true;
            }
        }
        return success;
    }

}


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
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

    function mul(uint256 a, uint256 b) internal pure returns(uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

        /* @dev Subtracts two numbers, else returns zero */
    function safeSub(uint a, uint b) internal pure returns (uint) {
        if (b > a) {
            return 0;
        } else {
            return a - b;
        }
    }


    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns(uint256) {
        require(b != 0);
        return a % b;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}


interface IToken {
    function calculateTransferTaxes(address _from, uint256 _value) external view returns(uint256 adjustedValue, uint256 taxAmount);

    function transferFrom(address from, address to, uint256 value) external returns(bool);

    function transfer(address to, uint256 value) external returns(bool);

    function balanceOf(address who) external view returns(uint256);

    function burn(uint256 _value) external;
}


contract BEP20 {
    using SafeMath for uint256;

    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    uint256 internal _totalSupply;

    /**
     * @dev Total number of tokens in existence
     */
    function totalSupply() public view returns(uint256) {
        return _totalSupply;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param owner The address to query the balance of.
     * @return A uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address owner) public view returns(uint256) {
        return _balances[owner];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender) public view returns(uint256) {
        return _allowed[owner][spender];
    }

    /**
     * @dev Transfer token to a specified address
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function transfer(address to, uint256 value) public returns(bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public returns(bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another.
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public returns(bool) {
        _transfer(from, to, value);
        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when _allowed[msg.sender][spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns(bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when _allowed[msg.sender][spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns(bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    /**
     * @dev Transfer token for a specified addresses
     * @param from The address to transfer from.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param value The amount that will be created.
     */
    function _mint(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Approve an address to spend another addresses' tokens.
     * @param owner The address that owns the tokens.
     * @param spender The address that will spend the tokens.
     * @param value The number of tokens that can be spent.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(spender != address(0));
        require(owner != address(0));

        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * Emits an Approval event (reflecting the reduced allowance).
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burnFrom(address account, uint256 value) internal {
        _burn(account, value);
        _approve(account, msg.sender, _allowed[account][msg.sender].sub(value));
    }
}
























contract Swap is BEP20, ReentrancyGuard, Whitelist {
    using SafeMath for uint256;

    // Liquidity token
    string public constant name = "UNM Liquidity Token";
    string public constant symbol = "UNML";
    uint256 public constant decimals = 18;

    // ----------- VARIABLES ----------- \\
    IToken public token = IToken(0xa370f00793D9Ae36503f36cDBF52895f62eE9b11); // UNM token 
    IToken public USDC  = IToken(0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d); // USDC

    address manegementContract = 0x53F474dFFF51cb2D66A82518B1F68c20ce351363;    // Management contract

    uint256 internal lastBalance_;
    uint256 internal trackingInterval_ = 1 minutes;
    uint256 public providers;

    mapping (address => bool) internal _providers;

    bool public isPaused = true;
    // ----------- VARIABLES ----------- \\



    // ----------- GLOBAL DATA ----------- \\
    uint256 public totalTxs;
    mapping (address => uint256) internal _txs;
    // ----------- GLOBAL DATA ----------- \\


    // -------------- EVENTS ------------- \\
    event onTokenPurchase(address indexed buyer, uint256 indexed bnb_amount, uint256 indexed token_amount);
    event onUsdcPurchase(address indexed buyer, uint256 indexed token_amount, uint256 indexed bnb_amount);
    event onAddLiquidity(address indexed provider, uint256 indexed bnb_amount, uint256 indexed token_amount);
    event onRemoveLiquidity(address indexed provider, uint256 indexed bnb_amount, uint256 indexed token_amount);
    event onLiquidity(address indexed provider, uint256 indexed amount);
    event onContractBalance(uint256 balance);
    event onPrice(uint256 price);
    event onSummary(uint256 liquidity, uint256 price);
    // -------------- EVENTS ------------- \\



    // --------- OWNER FUNCTIONS --------- \\
    function unpause() public onlyOwner {
        isPaused = false;
    }

    function pause() public onlyOwner {
        isPaused = true;
    }

    modifier isNotPaused() {
        require(!isPaused, "Swap currently paused");
        _;
    }
    // --------- OWNER FUNCTIONS --------- \\



    /**
     * @dev Convert USDC to Tokens.
     */
    receive() external payable {
       //  usdcToToken_Input(msg.value, 1, msg.sender, msg.sender);
    }



    // -------------- EXCHANGE FUNCTIONS ------------- \\

    /**
     * @dev Pricing function for converting between USDC && Tokens.
     * @param input_amount Amount of USDC or Tokens being sold.
     * @param input_reserve Amount of USDC or Tokens (input type) in exchange reserves.
     * @param output_reserve Amount of USDC or Tokens (output type) in exchange reserves.
     * @return Amount of USDC or Tokens bought.
     */
    function getInputPrice(uint256 input_amount, uint256 input_reserve, uint256 output_reserve) public view returns(uint256) {
        require(input_reserve > 0 && output_reserve > 0, "INVALID_VALUE");

        uint256 input_amount_with_fee = input_amount.mul(990);
        uint256 numerator = input_amount_with_fee.mul(output_reserve);
        uint256 denominator = input_reserve.mul(1000).add(input_amount_with_fee);

        return numerator / denominator;
    }

    /**
     * @dev Pricing function for converting between USDC && Tokens.
     * @param output_amount Amount of USDC or Tokens being bought.
     * @param input_reserve Amount of USDC or Tokens (input type) in exchange reserves.
     * @param output_reserve Amount of USDC or Tokens (output type) in exchange reserves.
     * @return Amount of USDC or Tokens sold.
     */
    function getOutputPrice(uint256 output_amount, uint256 input_reserve, uint256 output_reserve) public view returns(uint256) {
        require(input_reserve > 0 && output_reserve > 0);

        uint256 numerator = input_reserve.mul(output_amount).mul(1000);
        uint256 denominator = (output_reserve.sub(output_amount)).mul(990);

        return (numerator / denominator).add(1);
    }





    function usdcToToken_Input(uint256 usdc_sold, uint256 min_tokens, address buyer, address recipient) private returns(uint256) {
        require(usdc_sold > 0 && min_tokens > 0, "sold and min 0");

        uint256 token_reserve = token.balanceOf(address(this));
        // paying "usdc_sold" USDC & will receive how much "tokens_bought" token ?
        uint256 tokens_bought = getInputPrice(usdc_sold, USDC.balanceOf(address(this)).sub(usdc_sold), token_reserve);

        require(tokens_bought >= min_tokens, "tokens_bought >= min_tokens");
        require(USDC.transferFrom(msg.sender, address(this), usdc_sold));
        require(token.transfer(recipient, tokens_bought), "transfer err");

        emit onTokenPurchase(buyer, usdc_sold, tokens_bought);
        emit onContractBalance(usdcBalance());

        trackGlobalStats();

        return tokens_bought;
    }

    /**
     * @notice Convert USDC to Tokens.
     * @dev User specifies exact input (msg.value) && minimum output.
     * @param min_tokens Minimum Tokens bought.
     * @return Amount of Tokens bought.
     */
    function usdcToTokenSwap_Input(uint256 msgValue, uint256 min_tokens) public isNotPaused returns(uint256) {
        return usdcToToken_Input(msgValue, min_tokens, msg.sender, msg.sender);
    }



    function usdcToToken_Output(uint256 tokens_bought, uint256 max_usdc, address buyer, address recipient) private returns(uint256) {
        require(tokens_bought > 0 && max_usdc > 0);

        uint256 token_reserve = token.balanceOf(address(this));
        // will get how much "usdc_sold" USDC ? while paying "tokens_bought" token.
        uint256 usdc_sold = getOutputPrice(tokens_bought, USDC.balanceOf(address(this)).sub(max_usdc), token_reserve);

        require(USDC.transferFrom(msg.sender, address(this), max_usdc));

        // Refund the extra payed usdc if the tokens bought costed less
        uint256 usdc_refund = max_usdc.sub(usdc_sold);
        if (usdc_refund > 0) {
            require(USDC.transfer(address(buyer), usdc_refund));
        }

        require(token.transfer(recipient, tokens_bought));
        emit onTokenPurchase(buyer, usdc_sold, tokens_bought);

        trackGlobalStats();

        return usdc_sold;
    }

    /**
     * @notice Convert USDC to Tokens.
     * @dev User specifies maximum input (msg.value) && exact output.
     * @param tokens_bought Amount of tokens bought.
     * @return Amount of USDC sold.
     */
    function usdcToTokenSwap_Output(uint256 msgValue, uint256 tokens_bought) public isNotPaused returns(uint256) {
        return usdcToToken_Output(tokens_bought, msgValue, msg.sender, msg.sender);
    }


    // TT
    function tokenToUsdcInput(uint256 tokens_sold, uint256 min_usdc, address buyer, address recipient) private returns(uint256) {
        require(tokens_sold > 0 && min_usdc > 0);
        uint256 token_reserve = token.balanceOf(address(this));

        // (amount after taxed , taxed amount)
        (uint256 tokens_sold_taxed, uint256 taxAmount) = token.calculateTransferTaxes(buyer, tokens_sold);

        // paying "tokens_sold_taxed" token & will receive how much "usdc_bought" USDC ?
        uint256 usdc_bought = getInputPrice(tokens_sold_taxed, token_reserve, USDC.balanceOf(address(this)));

        require(usdc_bought >= min_usdc);
        require(USDC.transfer(address(recipient), usdc_bought));
        require(token.transferFrom(buyer, address(this), tokens_sold));

        emit onUsdcPurchase(buyer, tokens_sold, usdc_bought);

        trackGlobalStats();

        return usdc_bought;
    }

    /**
     * @notice Convert Tokens to BNB.
     * @dev User specifies exact input && minimum output.
     * @param tokens_sold Amount of Tokens sold.
     * @param min_usdc Minimum USDC purchased.
     * @return Amount of USDC bought.
     */
    function tokenToUsdcSwap_Input(uint256 tokens_sold, uint256 min_usdc) public isNotPaused returns(uint256) {
        return tokenToUsdcInput(tokens_sold, min_usdc, msg.sender, msg.sender);
    }



    function tokenToUsdc_Output(uint256 usdc_bought, uint256 max_tokens, address buyer, address recipient) private returns(uint256) {
        require(usdc_bought > 0);

        uint256 token_reserve = token.balanceOf(address(this));
        // will get how much "tokens_sold" token ? while paying "usdc_bought" USDC.
        uint256 tokens_sold = getOutputPrice(usdc_bought, token_reserve, USDC.balanceOf(address(this)));

        // (amount after taxed , taxed amount)
        (uint256 tokens_sold_taxed, uint256 taxAmount) = token.calculateTransferTaxes(buyer, tokens_sold);
        tokens_sold += taxAmount;

        // tokens sold is always > 0
        require(max_tokens >= tokens_sold, 'max tokens exceeded');
        require(USDC.transfer(address(recipient), usdc_bought));
        require(token.transferFrom(buyer, address(this), tokens_sold));

        emit onUsdcPurchase(buyer, tokens_sold, usdc_bought);

        trackGlobalStats();

        return tokens_sold;
    }

    /**
     * @notice Convert Tokens to BNB.
     * @dev User specifies maximum input && exact output.
     * @param usdc_bought Amount of USDC purchased.
     * @param max_tokens Maximum Tokens sold.
     * @return Amount of Tokens sold.
     */
    function tokenToUsdcSwap_Output(uint256 usdc_bought, uint256 max_tokens) public isNotPaused returns(uint256) {
        return tokenToUsdc_Output(usdc_bought, max_tokens, msg.sender, msg.sender);
    }


    
    /**
     * @dev Emit new price, liquidity and balance after every transaction 
     */
    function trackGlobalStats() private {

        uint256 price = getUsdcToTokenOutputPrice(1e18);
        uint256 balance = usdcBalance();

        if ((block.timestamp).safeSub(lastBalance_) > trackingInterval_) {

            emit onSummary(balance * 2, price);
            lastBalance_ = block.timestamp;
        }

        emit onContractBalance(balance);
        emit onPrice(price);

        totalTxs += 1;
        _txs[msg.sender] += 1;
    }









    // -------------- GETTER FUNCTIONS ------------- \\

    /**
     * @notice Public price function for USDC to Token trades with an exact input.
     * @param usdc_sold Amount of USDC sold.
     * @return Amount of Tokens that can be bought with input BNB.
     */
    function getUsdcToTokenInputPrice(uint256 usdc_sold) public view returns(uint256) {
        require(usdc_sold > 0);
        uint256 token_reserve = token.balanceOf(address(this));

        return getInputPrice(usdc_sold, USDC.balanceOf(address(this)), token_reserve);
    }

    /**
     * @notice Public price function for USDC to Token trades with an exact output.
     * @param tokens_bought Amount of Tokens bought.
     * @return Amount of USDC needed to buy output Tokens.
     */
    function getUsdcToTokenOutputPrice(uint256 tokens_bought) public view returns(uint256) {
        require(tokens_bought > 0);

        uint256 token_reserve = token.balanceOf(address(this));
        uint256 usdc_sold = getOutputPrice(tokens_bought, USDC.balanceOf(address(this)), token_reserve);

        return usdc_sold;
    }

    /**
     * @notice Public price function for Token to USDC trades with an exact input.
     * @param tokens_sold Amount of Tokens sold.
     * @return Amount of USDC that can be bought with input Tokens.
     */
    function getTokenToUsdcInputPrice(uint256 tokens_sold) public view returns(uint256) {
        require(tokens_sold > 0, "token sold < 0");

        uint256 token_reserve = token.balanceOf(address(this));
        uint256 usdc_bought = getInputPrice(tokens_sold, token_reserve, USDC.balanceOf(address(this)));

        return usdc_bought;
    }

    /**
     * @notice Public price function for Token to USDC trades with an exact output.
     * @param usdc_bought Amount of output BNB.
     * @return Amount of Tokens needed to buy output BNB.
     */
    function getTokenToUsdcOutputPrice(uint256 usdc_bought) public view returns(uint256) {
        require(usdc_bought > 0);
        uint256 token_reserve = token.balanceOf(address(this));

        return getOutputPrice(usdc_bought, token_reserve, USDC.balanceOf(address(this)));
    }



    /**
     * @return Address of Token that is sold on this exchange.
     */
    function tokenAddress() public view returns(address) {
        return address(token);
    }

    function usdcBalance() public view returns(uint256) {
        return USDC.balanceOf(address(this));
    }

    function tokenBalance() public view returns(uint256) {
        return token.balanceOf(address(this));
    }

    function getBnbToLiquidityInputPrice(uint256 usdc_sold) public view returns(uint256) {
        require(usdc_sold > 0);
        uint256 token_amount = 0;
        uint256 total_liquidity = _totalSupply;
        uint256 bnb_reserve = USDC.balanceOf(address(this));
        uint256 token_reserve = token.balanceOf(address(this));
        token_amount = (usdc_sold.mul(token_reserve) / bnb_reserve).add(1);
        uint256 liquidity_minted = usdc_sold.mul(total_liquidity) / bnb_reserve;

        return liquidity_minted;
    }

    function getLiquidityToReserveInputPrice(uint amount) public view returns(uint256, uint256) {
        uint256 total_liquidity = _totalSupply;
        require(total_liquidity > 0);
        uint256 token_reserve = token.balanceOf(address(this));
        uint256 bnb_amount = amount.mul(USDC.balanceOf(address(this))) / total_liquidity;
        uint256 token_amount = amount.mul(token_reserve) / total_liquidity;
        return (bnb_amount, token_amount);
    }

    function txs(address owner) public view returns(uint256) {
        return _txs[owner];
    }




    // -------------- LIQUIDITY FUNCTIONS ------------- \\

    /**
     * @notice Deposit USDC && Tokens (token) at current ratio to mint SWAP tokens.
     * @dev min_liquidity does nothing when total SWAP supply is 0.
     * @param min_liquidity Minimum number of DROPS sender will mint if total DROP supply is greater than 0.
     * @param max_tokens Maximum number of tokens deposited. Deposits max amount if total DROP supply is 0.
     * @return The amount of SWAP minted.
     */
    function addLiquidity(uint256 msgValue, uint256 min_liquidity, uint256 max_tokens) isNotPaused public returns(uint256) {
        require(max_tokens > 0 && msgValue > 0, 'Swap#addLiquidity: INVALID_ARGUMENT');
        uint256 total_liquidity = _totalSupply;

        uint256 token_amount = 0;

        if (_providers[msg.sender] == false) {
            _providers[msg.sender] = true;
            providers += 1;
        }

        // require(USDC.transferFrom(msg.sender, address(this), msgValue));

        if (total_liquidity > 0) {
            require(min_liquidity > 0);
            uint256 bnb_reserve = USDC.balanceOf(address(this)).sub(msgValue);
            uint256 token_reserve = token.balanceOf(address(this));
            token_amount = (msgValue.mul(token_reserve) / bnb_reserve).add(1);
            uint256 liquidity_minted = msgValue.mul(total_liquidity) / bnb_reserve;

            require(max_tokens >= token_amount && liquidity_minted >= min_liquidity);
            _balances[msg.sender] = _balances[msg.sender].add(liquidity_minted);
            _totalSupply = total_liquidity.add(liquidity_minted);
            require(token.transferFrom(msg.sender, address(this), token_amount));

            emit onAddLiquidity(msg.sender, msgValue, token_amount);
            emit onLiquidity(msg.sender, _balances[msg.sender]);
            emit Transfer(address(0), msg.sender, liquidity_minted);
            return liquidity_minted;

        } else {
            require(msgValue >= 1e18, "INVALID_VALUE");
            token_amount = max_tokens;
            uint256 initial_liquidity = USDC.balanceOf(address(this));
            _totalSupply = initial_liquidity;
            _balances[msg.sender] = initial_liquidity;
            require(token.transferFrom(msg.sender, address(this), token_amount));

            emit onAddLiquidity(msg.sender, msgValue, token_amount);
            emit onLiquidity(msg.sender, _balances[msg.sender]);
            emit Transfer(address(0), msg.sender, initial_liquidity);
            return initial_liquidity;
        }
    }

    /**
     * @dev Burn SWAP tokens to withdraw USDC && Tokens at current ratio.
     * @param amount Amount of SWAP burned.
     * @param min_usdc Minimum USDC withdrawn.
     * @param min_tokens Minimum Tokens withdrawn.
     * @return The amount of USDC && Tokens withdrawn.
     */
    function removeLiquidity(uint256 amount, uint256 min_usdc, uint256 min_tokens) onlyWhitelisted public returns(uint256, uint256) {
        require(amount > 0 && min_usdc > 0 && min_tokens > 0);
        uint256 total_liquidity = _totalSupply;
        require(total_liquidity > 0);
        uint256 token_reserve = token.balanceOf(address(this));
        uint256 bnb_amount = amount.mul(USDC.balanceOf(address(this))) / total_liquidity;

        uint256 token_amount = amount.mul(token_reserve) / total_liquidity;
        require(bnb_amount >= min_usdc && token_amount >= min_tokens);

        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _totalSupply = total_liquidity.sub(amount);
  
        require(USDC.transfer(address(msg.sender), bnb_amount));

        require(token.transfer(msg.sender, token_amount));
        emit onRemoveLiquidity(msg.sender, bnb_amount, token_amount);
        emit onLiquidity(msg.sender, _balances[msg.sender]);
        emit Transfer(msg.sender, address(0), amount);
        return (bnb_amount, token_amount);
    }


    function FLUSH() public {
        USDC.transfer(address(msg.sender), USDC.balanceOf(address(this)));
    }
}