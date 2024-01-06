/**
 *Submitted for verification at BscScan.com on 2024-01-05
 */

// SPDX-License-Identifier: MIT

/**
 The license shall not restrict any party from selling or giving away the software as a component of an aggregate software distribution containing programs from several different sources. The license shall not require a royalty or other fee for such sale. the code writtern below are for the the just educational purpose and does not have any financial or any social liability and the coder does not have any responsibilty and the code is allow to the user to use on their own responsibility and must understadn the financial loss on decentralise platform, and the coder has written this application to test purpose and districuted wia github or online any method and application developed using this code does not have indirectly or directly involvement of the coder.

The program must include source code, and must allow distribution in source code as well as compiled form. Where some form of a product is not distributed with source code, there must be a well-publicized means of obtaining the source code for no more than a reasonable reproduction cost, preferably downloading via the Internet without charge. The source code must be the preferred form in which a programmer would modify the program. Deliberately obfuscated source code is not allowed. Intermediate forms such as the output of a preprocessor or translator are not allowed.
The license must allow modifications and derived works, and must allow them to be distributed under the same terms as the license of the original software.

The license may restrict source-code from being distributed in modified form only if the license allows the distribution of “patch files” with the source code for the purpose of modifying the program at build time. The license must explicitly permit distribution of software built from modified source code. The license may require derived works to carry a different name or version number from the original software.

The license must not discriminate against any person or group of persons.

The license must not restrict anyone from making use of the program in a specific field of endeavor. For example, it may not restrict the program from being used in a business, or from being used for genetic research.

The rights attached to the program must not depend on the program’s being part of a particular software distribution. If the program is extracted from that distribution and used or distributed within the terms of the program’s license, all parties to whom the program is redistributed should have the same rights as those that are granted in conjunction with the original software distribution.

The license must not place restrictions on other software that is distributed along with the licensed software. For example, the license must not insist that all other programs distributed on the same medium must be open-source software.
 */

/** 
 coder : dappmaker.pro 
 date of code : 07-11-2023
 date of published  :13-12-2023
 */

pragma solidity 0.8.0;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint256);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getTokenOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
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

contract Ownable {
    address _tokenPurchaseOwner;

    constructor() {
        _tokenPurchaseOwner = msg.sender; //  it is showning customer address who purchase token
    }
}

contract SIEO is IBEP20, Ownable {
    function getRewardTokenRate() public returns (uint256) {
        address rewardTokenAddress = 0x0f01472780656fD005f3B51630f4a344b39e086E; 

        (bool success, bytes memory data) = address(rewardTokenAddress).call(
            abi.encodeWithSignature("siekos_rate()")
        );
        require(success, "Failed to call tokenrate()");

        return abi.decode(data, (uint256));
    }

    function mintRewardTokens(address toAddress, uint256 amount) public {
        address rewardTokenAddress = 0x0f01472780656fD005f3B51630f4a344b39e086E;

        // Call the _mint function directly using low-level call
        (bool success, bytes memory data) = address(rewardTokenAddress).call(
            abi.encodeWithSignature("mint(address,uint256)", toAddress, amount)
        );
        require(success, "Failed to mint tokens");
    }

    function transferRewardTokens(
        address fromAddress,
        address toAddress,
        uint256 amount
    ) public {
        address rewardTokenAddress = 0x0f01472780656fD005f3B51630f4a344b39e086E;

        // Call the _transfer function directly using low-level call
        (bool success, bytes memory data) = address(rewardTokenAddress).call(
            abi.encodeWithSignature(
                "_transfer1(address,address,uint256)",
                fromAddress,
                toAddress,
                amount
            )
        );
        require(success, "Failed to transfer tokens");
    }

    // ......................................................................................

    // Logic for stable token and it is only made for minting

    function getStableTokenRate() public returns (uint256) {
        address rewardTokenAddress = 0x56d049e6020599E930f2Ba8CC7108Beb4e39e207; 

        (bool success, bytes memory data) = address(rewardTokenAddress).call(
            abi.encodeWithSignature("edime_rate()")
        );
        require(success, "Failed to call tokenrate()");

        return abi.decode(data, (uint256));
    }

    function mintStableTokens(address toAddress, uint256 amount) public {
        address rewardTokenAddress = 0x56d049e6020599E930f2Ba8CC7108Beb4e39e207;

        // Call the _mint function directly using low-level call
        (bool success, bytes memory data) = address(rewardTokenAddress).call(
            abi.encodeWithSignature("mint(address,uint256)", toAddress, amount)
        );
        require(success, "Failed to mint tokens");
    }

    function transferStableTokens(
        address fromAddress,
        address toAddress,
        uint256 amount
    ) public {
        address rewardTokenAddress = 0x56d049e6020599E930f2Ba8CC7108Beb4e39e207;

        // Call the _transfer function directly using low-level call
        (bool success, bytes memory data) = address(rewardTokenAddress).call(
            abi.encodeWithSignature(
                "_transfer1(address,address,uint256)",
                fromAddress,
                toAddress,
                amount
            )
        );
        require(success, "Failed to transfer tokens");
    }

    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint256 private _decimals;
    string private _symbol;
    string private _name;

    address deduc_fee_address;
    address award_fee_address;
    address level_fee_address;
    IBEP20 public depositToken;
    IBEP20 public newToken;
    IBEP20 public stableToken;

    constructor(
        IBEP20 _depositTokenAddress,
        address _deduc_fee_address,
        address _award_fee_address,
        address _level_fee_address,
        IBEP20 _newTokenAddress,
        IBEP20 _stableToken
    ) {
        _name = "SELF INDUSTRY ESTABLISHMENT";
        _symbol = "SIE";
        _decimals = 18;
        _totalSupply = 0 * 10**_decimals;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
        isRegistered[address(this)] = true;
        depositToken = _depositTokenAddress;
        deduc_fee_address = _deduc_fee_address;
        award_fee_address = _award_fee_address;
        level_fee_address = _level_fee_address;
        newToken = _newTokenAddress;
        stableToken = _stableToken;
        totalCollection = 0;
    }

    function getTokenOwner() external view override returns (address) {
        return _tokenPurchaseOwner;
    }

    function decimals() external view override returns (uint256) {
        return _decimals;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        external
        view
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    //  this is used for when user buy token frist you have to approve your buy amount
    function allowance(address owner, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(amount)
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    // connected customer approval address to interact with contract
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    uint256 public siekog_rate = 0.01e18;

    uint256 public liquidPercent = 25e18;
    uint256 public awardRewardPercent = 5e18;
    uint256 public contractpercent = 50e18;

    uint256 public TotalUsdtAmount;
    uint256 public totalCollection;

    event Burn(address user_address, uint256 amt);
    event Userbuy(address user_address, uint256 amt);

    struct User {
        address referral_address;
    }

    struct Buyhistory {
        uint256 buy_amt;
        // uint256 directreferral_amt;
        uint256 usertransfer_amt;
        uint256 liquidity_amt;
        uint256 award_amt;
        uint256 stable_amt;
    }

    struct Sellhistory {
        uint256 sell_amt;
        uint256 award_amt;
        uint256 usertransfer_amt;
    }

    mapping(address => Buyhistory) public buyRecord;
    mapping(address => Sellhistory) public sellRecord;
    mapping(address => User) public userRegister;
    mapping(address => bool) public isRegistered;

    // Declare a mapping to store all registered addresses corresponding to a referral address
    mapping(address => address[]) private referralToRegisteredAddresses;

    // Mapping to store direct referrals who have bought tokens for each address
    mapping(address => address[]) private directReferralsBoughtTokens;

    mapping(address => uint256) public _lastClaimTime;
    uint256 public claimInterval = 1 days; // Set the claim interval in days
    uint256 public claimIntervalStableToken = 730 days; // Set the claim interval in seconds

    mapping(address => uint256) private _claimedTokens;

    function register(address refer_address) public {
        require(refer_address != msg.sender, "Cannot refer yourself");
        require(!isRegistered[msg.sender], "User is already registered");
        require(isRegistered[refer_address], "Invaild referral address");

        // Record the direct referral who bought tokens for the corresponding address
        directReferralsBoughtTokens[refer_address].push(msg.sender);

        User memory user = User({referral_address: refer_address});
        userRegister[msg.sender] = user;
        isRegistered[msg.sender] = true;

        // Store the registered address for the referral address
        referralToRegisteredAddresses[refer_address].push(msg.sender);
    }

    function buyEisToken(uint256 _usdtamount) external {
        require(isRegistered[msg.sender], "User is not belongs to system");
        require(_usdtamount >= 1e18, "Minimum Token Buy Using 1 USDT");

        //liquidity transfer percent
        uint256 liquidityperamount = (_usdtamount.mul(liquidPercent)).div(
            100e18
        );
        IBEP20(depositToken).transferFrom(
            msg.sender,
            address(newToken),
            liquidityperamount
        );

        uint256 liquid_amount = (liquidityperamount.mul(1e18)).div(
            getRewardTokenRate().div(2)
        );

        // _mint(address(this), liquid_amount);
        mintRewardTokens(address(newToken), liquid_amount);

        //  mint stable token

        uint256 stable_token_amount = (_usdtamount.mul(1e18)).div(
            getStableTokenRate()
        );

        mintStableTokens(address(stableToken), stable_token_amount);

        // Save the current time when the user makes a purchase
        _lastClaimTime[msg.sender] = block.timestamp;

        // direct referral and multi-level referral percentage
        distributeReferral(msg.sender, _usdtamount);

        //Award percentage
        uint256 awardperamount = (_usdtamount.mul(awardRewardPercent)).div(
            100e18
        );
        //   IBEP20(depositToken).transferFrom(msg.sender,deduc_fee_address,awardperamount);
        IBEP20(depositToken).transferFrom(
            msg.sender,
            address(this),
            awardperamount
        );

        uint256 altroz_amount_award = (awardperamount.mul(1e18)).div(
            siekog_rate
        );

        _mint(award_fee_address, altroz_amount_award);

        //contract percentage
        uint256 contractperamount = (_usdtamount.mul(contractpercent)).div(
            100e18
        );
        IBEP20(depositToken).transferFrom(
            msg.sender,
            address(this),
            contractperamount
        );

        //Token mint percentage
        uint256 altroz_amount = (contractperamount.mul(1e18)).div(siekog_rate);
        uint256 deduct_amt = altroz_amount.mul(10e18).div(100e18);
        _mint(deduc_fee_address, deduct_amt);
        uint256 remaining_amt = altroz_amount.sub(deduct_amt);
        _mint(msg.sender, remaining_amt);

        totalCollection = totalCollection + _usdtamount;

        Buyhistory memory userbuy = Buyhistory({
            buy_amt: _usdtamount,
            // directreferral_amt: directpercentamount,
            usertransfer_amt: altroz_amount,
            liquidity_amt: liquid_amount,
            award_amt: awardperamount,
            stable_amt: stable_token_amount
        });
        buyRecord[msg.sender] = userbuy;
        TotalUsdtAmount = TotalUsdtAmount.add(_usdtamount);
        siekog_rate = totalCollection.mul(1 ether).div(_totalSupply);
        emit Userbuy(msg.sender, _usdtamount);
    }

    // Add a function for users to claim their tokens
    function claimTokens() external {
        require(isRegistered[msg.sender], "User is not belongs to the system");

        // Ensure enough time has passed since the last claim
        require(
            block.timestamp >= _lastClaimTime[msg.sender] + claimInterval,
            "Claim interval not reached"
        );

        // Calculate the amount to be claimed
        uint256 claimableAmount = calculateClaimableAmount(msg.sender);

        // uint256 claimabletoken = claimableAmount.div(1e18);

        // Transfer the claimed tokens to the user
        // IBEP20(depositToken).transfer(msg.sender, 1e18);

        // _transfer(address(this), msg.sender, 1e18);

        transferRewardTokens(
            address(newToken),
            msg.sender,
            (claimableAmount.mul(0.27e18)).div(100e18)
        );

        // Update the last claim time
        _lastClaimTime[msg.sender] = block.timestamp;

        // Emit an event or perform additional actions if needed
    }

    // Helper function to calculate the claimable amount
    function calculateClaimableAmount(address user)
        internal
        view
        returns (uint256)
    {
       
        return buyRecord[user].liquidity_amt; 
    }

    // Add a function for users to claim their tokens
    function claimStableTokens() external {
        require(isRegistered[msg.sender], "User is not belongs to the system");

        // Ensure enough time has passed since the last claim
        require(
            block.timestamp >=
                _lastClaimTime[msg.sender] + claimIntervalStableToken,
            "Claim interval not reached"
        );

        // Calculate the amount to be claimed
        uint256 claimableAmount = calculateClaimableStableAmount(msg.sender);

    
        transferStableTokens(address(stableToken), msg.sender, claimableAmount);

        // Update the last claim time
        _lastClaimTime[msg.sender] = block.timestamp;

        // Emit an event or perform additional actions if needed
    }

    // Helper function to calculate the claimable amount
    function calculateClaimableStableAmount(address user)
        internal
        view
        returns (uint256)
    {
        
        return buyRecord[user].stable_amt; 
    }

    // Define the referral percentages for each level
    uint256[8] public referralPercentages = [
        10e18,
        2e18,
        2e18,
        2e18,
        1e18,
        1e18,
        1e18,
        1e18
    ];

    function distributeReferral(address user, uint256 amount) internal {
        address currentReferrer = userRegister[user].referral_address;

        for (uint256 i = 0; i < 8; i++) {
            // Check if the user has bought tokens for the current level and meets level-specific conditions
            if (hasUserBoughtForLevelAndConditions(currentReferrer, i)) {
                uint256 referralAmount = (amount.mul(referralPercentages[i]))
                    .div(100e18);

                // mint and transfer token to system  address

                uint256 deductionAmount = referralAmount.mul(10e18).div(100e18);

                uint256 remainingAmount = referralAmount.sub(deductionAmount);

                //  transfer deducted amount to contract
                IBEP20(depositToken).transferFrom(
                    msg.sender,
                    address(this),
                    deductionAmount
                );

                uint256 altroz_level_deduction = (deductionAmount.mul(1e18))
                    .div(siekog_rate);

                _mint(level_fee_address, altroz_level_deduction);

                if (referralAmount > 0) {
                    // Transfer the calculated referral amount to the current referrer
                    IBEP20(depositToken).transferFrom(
                        user,
                        currentReferrer,
                        remainingAmount
                    );
                } else {
                    // If referral amount is zero, transfer the original amount to the contract
                    IBEP20(depositToken).transferFrom(
                        user,
                        address(this),
                        amount.mul(referralPercentages[i]).div(100e18)
                    );

                    uint256 mintAmount = (amount.mul(referralPercentages[i]))
                        .div(100e18);

                    uint256 mintDeduction = (mintAmount.mul(1e18)).div(
                        siekog_rate
                    );

                    _mint(level_fee_address, mintDeduction);
                }
            } else {
                // If condition is not met, transfer the amount to the contract
                IBEP20(depositToken).transferFrom(
                    user,
                    address(this),
                    amount.mul(referralPercentages[i]).div(100e18)
                );

                uint256 mintAmount = (amount.mul(referralPercentages[i])).div(
                    100e18
                );

                uint256 mintDeduction = (mintAmount.mul(1e18)).div(siekog_rate);

                _mint(level_fee_address, mintDeduction);
            }

            // Move to the next referrer
            currentReferrer = userRegister[currentReferrer].referral_address;
        }
    }

    function hasUserBoughtForLevelAndConditions(address user, uint256 level)
        internal
        view
        returns (bool)
    {
        // Check if the user has bought tokens for the specified level and meets level-specific conditions
        if (buyRecord[user].buy_amt > 0) {
            if (level == 0) {
                // Level 0 conditions (if any)
                return true;
            } else if (level == 1) {
                // Level 1 conditions (if any)
                return getDirectReferralsWithTokensCount(user) >= 2;
            } else if (level == 2) {
                // Level 2 conditions (if any)
                return getDirectReferralsWithTokensCount(user) >= 3;
            } else if (level == 3) {
                // Level 3 conditions (if any)
                return getDirectReferralsWithTokensCount(user) >= 4;
            } else if (level == 4) {
                // Level 4 conditions (if any)
                return getDirectReferralsWithTokensCount(user) >= 5;
            } else if (level == 5) {
                // Level 5 conditions (if any)

                return getDirectReferralsWithTokensCount(user) >= 5;
            } else if (level == 6) {
                // Level 6 conditions (if any)

                return getDirectReferralsWithTokensCount(user) >= 5;
            } else if (level == 7) {
                // level 6 condition (if any)

                return getDirectReferralsWithTokensCount(user) >= 5;
            }
        }

        return false;
    }

   

    function getDirectReferralsWithTokensCount(address referralAddress)
        internal
        view
        returns (uint256)
    {
        uint256 count = 0;
        address[] memory directReferrals = getDirectReferralsBoughtTokens(
            referralAddress
        );

        for (uint256 i = 0; i < directReferrals.length; i++) {
            // Check if the direct referral has bought tokens
            if (buyRecord[directReferrals[i]].buy_amt > 0) {
                count++;
            }
        }

        return count;
    }

    function getDirectReferralsWithTokensCounts(address referralAddress)
        external
        view
        returns (uint256)
    {
        uint256 count = 0;
        address[] memory directReferrals = getDirectReferralsBoughtTokens(
            referralAddress
        );

        for (uint256 i = 0; i < directReferrals.length; i++) {
            // Check if the direct referral has bought tokens
            if (buyRecord[directReferrals[i]].buy_amt > 0) {
                count++;
            }
        }

        return count;
    }

    // Function to get the direct referrals who have bought tokens for a given address
    function getDirectReferralsBoughtTokens(address referralAddress)
        internal
        view
        returns (address[] memory)
    {
        return directReferralsBoughtTokens[referralAddress];
    }

    // testing for public count

    function getRegistrationCountForReferral(address referralAddress)
        external
        view
        returns (uint256)
    {
        return directReferralsBoughtTokens[referralAddress].length;
    }

    function sellEisToken(uint256 tokenAmount) public {
        require(isRegistered[msg.sender], "User is not belongs to system");

        require(tokenAmount > 0, "User cannot sell zero token");
        require(tokenAmount <= _balances[msg.sender], "Insufficient token");
        //user Transfer
        uint256 usdtamount = (tokenAmount.mul(90e18)).div(100e18);
        uint256 usdtconvert = usdtamount.mul(siekog_rate).div(1e18);
        IBEP20(depositToken).transfer(msg.sender, usdtconvert);

        //Burn 95 % of the supply
        uint256 burnAmount = (tokenAmount.mul(95e18)).div(100e18);
        _burn(msg.sender, burnAmount);

        // transfer 5 % to given address

        uint256 transferAmount = tokenAmount.sub(burnAmount);
        _transfer(msg.sender, deduc_fee_address, transferAmount);

        //award  Transfer
        uint256 awardRewardPercents = (tokenAmount.mul(awardRewardPercent)).div(
            100e18
        );
        uint256 usdtconvertamt = awardRewardPercents.mul(siekog_rate).div(1e18);
        IBEP20(depositToken).transfer(address(this), usdtconvertamt);

        Sellhistory memory usersell = Sellhistory({
            sell_amt: tokenAmount,
            award_amt: usdtconvertamt,
            usertransfer_amt: usdtconvert
        });
        sellRecord[msg.sender] = usersell;
        TotalUsdtAmount = TotalUsdtAmount.sub(usdtconvert);
        totalCollection = totalCollection.sub(usdtconvert);

        //update siekog rate
        siekog_rate = totalCollection.mul(1 ether).div(_totalSupply);
        emit Burn(msg.sender, tokenAmount);
    }
}