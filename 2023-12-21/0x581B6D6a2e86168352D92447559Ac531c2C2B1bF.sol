// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

import "./utils/SafeMath.sol";

contract GoldenBeans {
    using SafeMath for uint256;
    
     /* Team can:
     * -> change the Proof of BEAN balance requirement for referrals
     * -> disable Early Roasters mode exactly once
     * -> can increase early roaster max amount
     * -> add new accounts who have Baraista role */
    modifier onlyTeam {
        require(owner == msg.sender, "Only Team");
        _;
    }

    /* Bariastas can: 
     * -> add Early Roasters 
     *
     * Baristas and Team CANNOT:
     * -> take funds from contract
     * -> disable withdrawals
     * -> kill the contract
     * -> change the price of tokens */
    modifier onlyBaristas {
        require(baristas[msg.sender] == true, "Only Baristas");
        _;
    }

    /* re-entrancy protections, just in case */
    bool internal locked;
    modifier notReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    // only holders of tokens
    modifier onlyBeanMasters {
        require(balanceOf(msg.sender) > 0, "Only Bean Masters");
        _;
    }
    
    // only holders with profits
    modifier onlyBeanTycoons {
        require(myDividends(true) > 0, "Only Bean Tycoons");
        _;
    }

    // early roaster program
    modifier antiBurntBean(uint256 _amountOfEther) {
        if (onlyEarlyRoasters) {
            require(
                // is the customer in the early roaster list?
                earlyRoasters[msg.sender] == true,
                "Only early roasters");
            require(
                // does this purchase exceed the max early roaster amount?
                (earlyRoasterQuota[msg.sender] + _amountOfEther) <= earlyRoasterMaxAmount,
                "Exceeds max early roaster amount"
            );
            // update the accumulated quota
            earlyRoasterQuota[msg.sender] = SafeMath.add(earlyRoasterQuota[msg.sender], _amountOfEther);
        }  
        // execute
        _;
    }
    
    /*********************************
     *            EVENTS             *
     *********************************/
    event onRoast(
        address indexed account,
        uint256 incomingEther,
        uint256 tokensMinted,
        address indexed referredBy
    );
    
    event onDarkRoast(
        address indexed account,
        uint256 etherReinvested,
        uint256 tokensMinted
    );

    event onBrew(
        address indexed account,
        uint256 tokensBurned,
        uint256 etherEarned
    );

    event onWithdraw(
        address indexed account,
        uint256 etherWithdrawn
    );
    
    // ERC20
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 tokens
    );
    
    string public name = "Golden Beans";
    string public symbol = "BEANS";
    uint8 constant public decimals = 18;
    uint8 constant internal dividendFee_ = 10;
    uint256 constant internal tokenPriceInitial_ = 0.0000001 ether;
    uint256 constant internal tokenPriceIncremental_ = 0.00000001 ether;
    uint256 constant internal magnitude = 2**64;
    
    // Proof of Bean (defaults to 10 BEANS)
    uint256 public proofOfBean = 10 ether;
    uint256 public numberOfRoasts = 0;
    uint256 public numberOfBrews = 0;

    // early roaster program
    bool public onlyEarlyRoasters = true;
    mapping(address => bool) public earlyRoasters;
    mapping(address => uint256) public earlyRoasterQuota;
    uint256 public earlyRoasterMaxAmount = 1 ether;
    
    // amount of shares for each address
    mapping(address => uint256) internal tokenBalanceLedger_;
    mapping(address => uint256) internal referralBalance_;
    mapping(address => int256) internal payoutsTo_;
    uint256 internal tokenSupply_ = 0;
    uint256 internal profitPerShare_;
    
    // baristas list
    mapping(address => bool) public baristas;
    
    // Owner
    address public owner;

    address[6] public feeWallets;
    uint256 public feeBasis;
    uint256 constant public FEE_DIVIDER = 10000;

    constructor() {
        owner = msg.sender;
        feeWallets[0] = 0x07315b79FEa4d2eEeF6Cd6498FbF9c61A32a8678;
        feeWallets[1] = 0x6667b89c61bF929bb6440B7772F7893Fa44ED3F8;
        feeWallets[2] = 0xa5a47E554Ba4762Fb3972506F883D4479A91C01b;
        feeWallets[3] = 0xF29A99E4647209f0977237570886dC47B7a2b24E;
        feeWallets[4] = 0x7a0AD44b416A9D5B4F0154D49c65Bac66f3065a1;
        feeWallets[5] = 0x755B40Cb53D327e1BcEb8FFF4F83B58e0A8510d3;
        feeBasis = 100;
    }
    
    /**
     * Converts all incoming Ether to tokens for the caller, and passes down the referral address
     */
    function roast(address _referredBy)
        notReentrant
        external
        payable
        returns (uint256 tokens)
    {
        uint256 taxes = fees(msg.value);
        tokens = purchaseTokens(msg.value - taxes, _referredBy);
    }
    
    receive() payable external {
        uint256 taxes = fees(msg.value);
        purchaseTokens(msg.value - taxes, owner);
    }
    
    /**
     * Converts all of caller's dividends to tokens.
     */
    function darkroast()
        onlyBeanTycoons
        external
        returns (uint256 tokens)
    {
        // fetch dividends
        uint256 _dividends = myDividends(false); // retrieve ref. bonus later in the code
        
        // pay out the dividends virtually [saves gas]
        payoutsTo_[msg.sender] += (int256) (_dividends * magnitude);
        
        // retrieve ref. bonus
        _dividends += referralBalance_[msg.sender];
        referralBalance_[msg.sender] = 0;
        
        // dispatch a buy order with the dividends, with no referrer
        tokens = purchaseTokens(_dividends, address(0));
        
        // fire event
        emit onDarkRoast(msg.sender, _dividends, tokens);
    }
    
    /**
     * Combined alias of brew() and withdraw().
     */
    function exit()
        external
    {
        // get token count for caller, sell them all and receive Ether back
        uint256 _tokens = tokenBalanceLedger_[msg.sender];
        if (_tokens > 0) {
            brew(_tokens);
        }
        withdraw();
    }

    /**
     * Withdraws all of the callers earnings [receiving Ether]
     */
    function withdraw()
        onlyBeanTycoons
        public
    {
        uint256 _dividends = myDividends(false); 
        
        // update dividend tracker
        payoutsTo_[msg.sender] += (int256) (_dividends * magnitude);
        
        // add ref. bonus
        _dividends += referralBalance_[msg.sender];
        referralBalance_[msg.sender] = 0;
        
        // apply tax
        uint256 taxes = fees(_dividends);

        // send Ether
        msg.sender.transfer(_dividends - taxes);
        
        // fire event
        emit onWithdraw(msg.sender, _dividends);
    }
    
    /**
     * Liquifies tokens [no Ether is returned]
     */
    function brew(uint256 _tokens)
        onlyBeanMasters
        public
        returns (uint256 _taxedEther)
    {
        require(_tokens <= tokenBalanceLedger_[msg.sender], "invalid amount");
        uint256 _ether = tokensToEther_(_tokens);
        uint256 _dividends = SafeMath.div(_ether, dividendFee_);
        _taxedEther = SafeMath.sub(_ether, _dividends);
        
        // burn the sold tokens
        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokens);
        tokenBalanceLedger_[msg.sender] = SafeMath.sub(tokenBalanceLedger_[msg.sender], _tokens);
        
        // update dividends tracker
        int256 _updatedPayouts = (int256) (profitPerShare_ * _tokens + (_taxedEther * magnitude));
        payoutsTo_[msg.sender] -= _updatedPayouts;       
        
        // dividing by zero is a bad idea
        if (tokenSupply_ > 0) {
            // update the amount of dividends per token
            profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);
        }
        
        numberOfBrews++;

        // fire event
        emit onBrew(msg.sender, _tokens, _taxedEther);
    }
    
    /**
     * Transfer tokens from the caller to a new holder.
     * There's a 10% fee sent as dividends to current holders
     */
    function transfer(address _toAddress, uint256 _amountOfTokens)
        onlyBeanMasters
        public
        returns(bool)
    {
        // make sure customer has the requested tokens
        require(_amountOfTokens <= tokenBalanceLedger_[msg.sender], "invalid amount");
        
        // withdraw all outstanding dividends first
        if (myDividends(true) > 0) {
            withdraw();
        }
        
        // liquify 10% of the tokens that are transfered
        // these are dispersed to token holders
        uint256 _tokenFee = SafeMath.div(_amountOfTokens, dividendFee_);
        uint256 _taxedTokens = SafeMath.sub(_amountOfTokens, _tokenFee);
        uint256 _dividends = tokensToEther_(_tokenFee);
  
        // burn the fee tokens
        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokenFee);

        // exchange tokens
        tokenBalanceLedger_[msg.sender] = SafeMath.sub(tokenBalanceLedger_[msg.sender], _amountOfTokens);
        tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _taxedTokens);
        
        // update dividend trackers
        payoutsTo_[msg.sender] -= (int256) (profitPerShare_ * _amountOfTokens);
        payoutsTo_[_toAddress] += (int256) (profitPerShare_ * _taxedTokens);
        
        // disperse dividends among token holders
        profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);
        
        // fire event
        emit Transfer(msg.sender, _toAddress, _taxedTokens);
        
        // ERC20
        return true;
    }
    
    /* Team only methods  */
    /**
     *  Team can disable the early roasters phase exactly once
     */
    function disableEarlyRoasters()
        onlyTeam
        external
    {
        onlyEarlyRoasters = false;
    }

    /**
     * Team can add an address as a Bariasta
     * which also allows address to deposit as an early roaster
     */
    function addBarista(address _identifier)
        onlyTeam
        external
    {
        baristas[_identifier] = true;
        earlyRoasters[_identifier] = true;
    }

    /**
     *  Team can increase the max purchase for early roasters
     */
    function setEarlyRoasterMaxPurchase(uint256 _amount)
        onlyTeam
        external
    {
        require(_amount > earlyRoasterMaxAmount, "Can only increase amount");
        earlyRoasterMaxAmount = _amount;
    }
    
    /**
     *  Team can set the amount of BEANS required for referrals 
     */
    function setProofOfBean(uint256 _amountOfTokens)
        onlyTeam
        external
    {
        proofOfBean = _amountOfTokens;
    }
    
    /**
     *  Baristas can add early roaster addresses
     */
    
    function addEarlyRoasters(address newEarlyRoaster)  
        onlyBaristas
        external 
    {
        earlyRoasters[newEarlyRoaster] = true;
    }

    /*----------  HELPERS AND CALCULATORS  ----------*/
    /**
     * Method to view the current Ether stored in the contract
     * Example: totalEtherBalance()
     */
    function totalEtherBalance()
        public
        view
        returns(uint)
    {
        return address(this).balance;
    }
    
    /**
     * Retrieve the total token supply.
     */
    function totalSupply()
        external
        view
        returns(uint256)
    {
        return tokenSupply_;
    }
    
    /**
     * Retrieve the dividends owned by the caller.
       */ 
    function myDividends(bool _includeReferralBonus) 
        public 
        view 
        returns(uint256)
    {
        return _includeReferralBonus ? dividendsOf(msg.sender) + referralBalance_[msg.sender] : dividendsOf(msg.sender) ;
    }
    
    /**
     * Retrieve the token balance of any single address.
     */
    function balanceOf(address _customerAddress)
        view
        public
        returns(uint256)
    {
        return tokenBalanceLedger_[_customerAddress];
    }
    
    /**
     * Retrieve the dividend balance of any single address.
     */
    function dividendsOf(address _customerAddress)
        view
        public
        returns(uint256)
    {
        return (uint256) ((int256)(profitPerShare_ * tokenBalanceLedger_[_customerAddress]) - payoutsTo_[_customerAddress]) / magnitude;
    }
    
    /**
     * Return the buy price of 1 individual token.
     */
    function sellPrice() 
        external 
        view 
        returns(uint256)
    {
        if (tokenSupply_ == 0) {
            return tokenPriceInitial_ - tokenPriceIncremental_;
        } else {
            uint256 _ether = tokensToEther_(1e18);
            uint256 _dividends = SafeMath.div(_ether, dividendFee_);
            uint256 _taxedEther = SafeMath.sub(_ether, _dividends);
            return _taxedEther;
        }
    }
    
    /**
     * Return the sell price of 1 individual token.
     */
    function buyPrice() 
        external 
        view 
        returns(uint256)
    {
        if (tokenSupply_ == 0) {
            return tokenPriceInitial_ + tokenPriceIncremental_;
        } else {
            uint256 _ether = tokensToEther_(1e18);
            uint256 _dividends = SafeMath.div(_ether, dividendFee_);
            uint256 _taxedEther = SafeMath.add(_ether, _dividends);
            return _taxedEther;
        }
    }
       
    function calculateTokensReceived(uint256 _etherToSpend) 
        external 
        view 
        returns(uint256)
    {
        uint256 _dividends = SafeMath.div(_etherToSpend, dividendFee_);
        uint256 _taxedEther = SafeMath.sub(_etherToSpend, _dividends);
        uint256 _amountOfTokens = etherToTokens_(_taxedEther);
        return _amountOfTokens;
    }
    
    function calculateEtherReceived(uint256 _tokensToSell) 
        external 
        view 
        returns(uint256)
    {
        require(_tokensToSell <= tokenSupply_, "invalid tokens to sell");
        uint256 _ether = tokensToEther_(_tokensToSell);
        uint256 _dividends = SafeMath.div(_ether, dividendFee_);
        uint256 _taxedEther = SafeMath.sub(_ether, _dividends);
        return _taxedEther;
    }

    /*==========================================
    =            INTERNAL FUNCTIONS            =
    ==========================================*/
    function purchaseTokens(uint256 _incomingEther, address _referredBy)
        antiBurntBean(_incomingEther)
        internal
        returns(uint256 _amountOfTokens)
    {
        uint256 _undividedDividends = SafeMath.div(_incomingEther, dividendFee_);
        uint256 _referralBonus = SafeMath.div(_undividedDividends, 3);
        uint256 _dividends = SafeMath.sub(_undividedDividends, _referralBonus);
        uint256 _taxedEther = SafeMath.sub(_incomingEther, _undividedDividends);
        uint256 _fee = _dividends * magnitude;
        _amountOfTokens = etherToTokens_(_taxedEther);
 
        require(_amountOfTokens > 0 && (SafeMath.add(_amountOfTokens,tokenSupply_) > tokenSupply_), "invalid amount");
        
        // is the user referred?
        if (
            // is this a referred purchase?
            _referredBy != address(0) &&

            // no cheating!
            _referredBy != msg.sender &&
            
            tokenBalanceLedger_[_referredBy] >= proofOfBean
        ) {
            // bean redistribution
            referralBalance_[_referredBy] = SafeMath.add(referralBalance_[_referredBy], _referralBonus);
        } else {
            // no ref purchase
            // add the referral bonus back to the global dividends
            _dividends = SafeMath.add(_dividends, _referralBonus);
            _fee = _dividends * magnitude;
        }
        
        // we can't give people infinite ether
        if (tokenSupply_ > 0) {
            // add tokens to the pool
            tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);
 
            // take the amount of dividends gained through this transaction, and allocates them evenly to each shareholder
            profitPerShare_ += (_dividends * magnitude / (tokenSupply_));
            
            // calculate the amount of tokens the customer receives over his purchase 
            _fee = _fee - (_fee-(_amountOfTokens * (_dividends * magnitude / (tokenSupply_))));
        
        } else {
            // add tokens to the pool
            tokenSupply_ = _amountOfTokens;
        }
        
        // update circulating supply & the ledger address for the customer
        tokenBalanceLedger_[msg.sender] = SafeMath.add(tokenBalanceLedger_[msg.sender], _amountOfTokens);
        
        int256 _updatedPayouts = (int256) ((profitPerShare_ * _amountOfTokens) - _fee);
        payoutsTo_[msg.sender] += _updatedPayouts;
    
        emit onRoast(msg.sender, _incomingEther, _amountOfTokens, _referredBy);
        numberOfRoasts++;
        return _amountOfTokens;
    }

    function fees(uint256 amount) internal returns (uint256) {
        uint256 totalFees;
        for (uint256 i = 0; i < feeWallets.length; i++) {
            uint256 feeShare = amount.mul(feeBasis).div(FEE_DIVIDER);
            payable(feeWallets[i]).transfer(feeShare);
            totalFees += feeShare;
        }
        return totalFees;
    }

    /**
     * Calculate Token price based on an amount of incoming ether
     * Some conversions occurr to prevent decimal errors or underflows / overflows.
     */
    function etherToTokens_(uint256 _ether)
        internal
        view
        returns(uint256)
    {
        uint256 _tokenPriceInitial = tokenPriceInitial_ * 1e18;
        uint256 _tokensReceived = 
         (
            (
                // underflow attempts BTFO
                SafeMath.sub(
                    (sqrt
                        (
                            (_tokenPriceInitial**2)
                            +
                            (2*(tokenPriceIncremental_ * 1e18)*(_ether * 1e18))
                            +
                            (((tokenPriceIncremental_)**2)*(tokenSupply_**2))
                            +
                            (2*(tokenPriceIncremental_)*_tokenPriceInitial*tokenSupply_)
                        )
                    ), _tokenPriceInitial
                )
            )/(tokenPriceIncremental_)
        )-(tokenSupply_)
        ;
        return _tokensReceived;
    }
    
    /**
     * Calculate token sell value.
          */
     function tokensToEther_(uint256 _tokens)
        internal
        view
        returns(uint256)
    {
        uint256 tokens_ = (_tokens + 1e18);
        uint256 _tokenSupply = (tokenSupply_ + 1e18);
        uint256 _etherReceived =
        (
            // underflow attempts BTFO
            SafeMath.sub(
                (
                    (
                        (
                            tokenPriceInitial_ +(tokenPriceIncremental_ * (_tokenSupply/1e18))
                        )-tokenPriceIncremental_
                    )*(tokens_ - 1e18)
                ),(tokenPriceIncremental_*((tokens_**2-tokens_)/1e18))/2
            )
        /1e18);
        return _etherReceived;
    }
    
    function sqrt(uint x) internal pure returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

   
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

   
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

   
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}
