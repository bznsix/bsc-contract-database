// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./IBEP20.sol";
import "./Spotic.sol";

contract SalesToken is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet tokenAddresses;

    uint256 public rate = 50000;  // SPOTIC / USD * 1000
    uint256 public hardCap = 1500000000000000000000000000;
    uint256 public startTime;
    uint256 public endTime = 1750222493;
    uint256 public purchaseLimit = 8000000000000000000000000000;
    uint256 public referralPercent = 1000; // 10% = 1000 / 10000

    bool private paused = false;
    bool private unlimited = false;
    bool private preSale = true;

    uint256 curDecimal = 10 ** 18;

    address public spoticAddr;

    address usdcAddr = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
    address usdtAddr = 0x55d398326f99059fF775485246999027B3197955;
    address busdAddr = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address dogeAddr = 0xbA2aE424d960c26247Dd6c32edC70B295c744C43;
    address wethAddr = 0x4DB5a66E937A9F4473fA95b1cAF1d1E1D62E29EA;
    address solAddr = 0xFEa6aB80cd850c3e63374Bc737479aeEC0E8b9a1;

    address public bnbPriceFeedAddress =
        0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE; //bnb/usd
    address public dogePriceFeedAddress =
        0x3AB0A0d137D4F946fBB19eecc6e92E64660231C8; //doge/usd
    address public solPriceFeedAddress =
        0x0E8a53DD9c13589df6382F13dA6B3Ec8F919B323; // sol/usd
    address public etherPriceFeedAddress =
        0x9ef1B8c0E4F7dc8bF5719Ea496883DC6401d5b2e; // ether/usd

    mapping(address => uint256) purchasedAmount;

    constructor() {
        startTime = block.timestamp;
    }

    modifier isNotPaused() {
        require(!paused, "purchasing is paused");
        _;
    }

    modifier endedPreSale() {
        require(!preSale, "Token is on presale");
        _;
    }

    modifier isPurchasingPeriod() {
        require(contractStarted() && contractNotEnded(), "purchasing time expired");
        _;
    }

    modifier existedSpotic() {
        require(spoticAddr != address(0), "Spotic Address is not set");
        _;
    }

    function getInternalBNBRate() internal view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(bnbPriceFeedAddress);
        (, int256 price, , , ) = priceFeed.latestRoundData();

        // convert the price from 8 decimal places to 18 decimal places
        uint256 decimals = uint256(priceFeed.decimals());
        uint256 _bnbRate = rate.mul(uint256(price)).div(10 ** (decimals));
        return _bnbRate;
    }

    function getInternalDogeRate() internal view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(dogePriceFeedAddress);
        (, int256 price, , , ) = priceFeed.latestRoundData();

        // convert the price from 8 decimal places to 18 decimal places
        uint256 decimals = uint256(priceFeed.decimals());
        uint256 _dogeRate = rate.mul(uint256(price)).div(10 ** (decimals));
        return _dogeRate;
    }

    function getInternalEtherRate() internal view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(etherPriceFeedAddress);
        (, int256 price, , , ) = priceFeed.latestRoundData();

        // convert the price from 8 decimal places to 18 decimal places
        uint256 decimals = uint256(priceFeed.decimals());
        uint256 _etherRate = rate.mul(uint256(price)).div(10 ** (decimals));
        return _etherRate;
    }

    function getInternalSolRate() internal view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(solPriceFeedAddress);
        (, int256 price, , , ) = priceFeed.latestRoundData();

        // // convert the price from 8 decimal places to 18 decimal places
        uint256 decimals = uint256(priceFeed.decimals());
        uint256 _solRate = rate.mul(uint256(price)).div(10 ** (decimals));
        return _solRate;
    }

    function getTokenRate(address tokenAddress) internal view returns (uint256) {
        uint256 tokenRate = 1;

        if (
            tokenAddress == usdcAddr ||
            tokenAddress == usdtAddr ||
            tokenAddress == busdAddr
        ) {
            tokenRate = rate;
        } else if (tokenAddress == solAddr) {
            tokenRate = getInternalSolRate();
        } else if  (tokenAddress == wethAddr) {
            tokenRate == getInternalEtherRate();
        } else if (tokenAddress == dogeAddr) {
            tokenRate = getInternalDogeRate();
        } else {
            revert("This token is not approved yet");
        }

        return tokenRate;
    }

    function checkIfOwner() public view returns (bool) {
        return msg.sender == owner();
    }

    function contractStarted() internal view returns (bool) {
        return block.timestamp >= startTime;
    }

    function contractNotEnded() internal view returns (bool) {
        return block.timestamp < endTime;
    }

    function getBnbRate() public view returns (uint256) {
        uint256 _bnbRate = getInternalBNBRate();
        return _bnbRate;
    }

    function getSolRate() public view returns (uint256) {
        uint256 _solRate = getInternalSolRate();
        return _solRate;
    }

    function getEtherRate() public view returns (uint256) {
        uint256 _etherRate = getInternalEtherRate();
        return _etherRate;
    }

    function getDogeRate() public view returns (uint256) {
        uint256 _dogeRate = getInternalDogeRate();
        return _dogeRate;
    }

    function getStableRate() public view returns (uint256) {
        return rate;
    }

    function getPurchaseLimit() public view returns (uint256) {
        return purchaseLimit;
    }

    function getStatusOfLimit() public view returns (bool) {
        return unlimited;
    }

    function getStartedTime() public view returns (uint256) {
        return startTime;
    }

    function getEndTime() public view returns (uint256) {
        return endTime;
    }

    function getStatus() public view returns (bool) {
        return paused;
    }

    function getHardCap() public view returns (uint256) {
        return hardCap;
    }

    function getReferralPercent() public view returns (uint256) {
        return referralPercent;
    }

    function setRate(uint256 _rate) external onlyOwner {
        rate = _rate;
    }

    function setHardCap(uint256 _hardCap) external onlyOwner {
        hardCap = _hardCap;
    }

    function setStartTime(uint256 _startTime) external onlyOwner {
        startTime = _startTime;
    }

    function setEndTime(uint256 _endTime) external onlyOwner {
        endTime = _endTime;
    }

    function setPurchaseLimit(uint256 _purchaseLimit) external onlyOwner {
        purchaseLimit = _purchaseLimit;
        unlimited = false;
    }

    function setReferralPercent(
        uint256 _referralPercent
    ) external onlyOwner {
        referralPercent = _referralPercent;
    }

    function setSpoticAddr(address _spoticAddr) external onlyOwner {
        spoticAddr = _spoticAddr;
    }

    function setPaused(bool _paused) external onlyOwner {
        paused = _paused;
    }

    function setUnlimited() external onlyOwner {
        unlimited = true;
    }

    function setPresale(bool _preSale) external  onlyOwner {
        preSale = _preSale;
    }

    function burn(uint256 amount) public onlyOwner returns (bool) {
        Spotic spoticInstance = Spotic(spoticAddr);
        spoticInstance.burn(amount);
        return true;
    }

    function purchaseWithBnb() external payable isNotPaused existedSpotic isPurchasingPeriod nonReentrant {
        IBEP20 spoticInstance = IBEP20(spoticAddr);
        uint256 balance = spoticInstance.balanceOf(address(this));
        uint256 bnbRate = getInternalBNBRate();
        uint256 amount = msg.value * bnbRate / 1000;
        require(amount > 0, "You have to purchase more than zero");
        require(amount <= balance, "You cant purchase more than balance");
        if (!unlimited) {
            require(
                purchaseLimit >= purchasedAmount[msg.sender] + amount,
                "You cant purchase more than limit"
            );
        }
        purchasedAmount[msg.sender] += amount;
        hardCap -= amount;
        spoticInstance.transfer(msg.sender, amount);
    }

    function referralPurchaseWithBnb(
        address _referrencedAddress
    ) external payable isNotPaused existedSpotic isPurchasingPeriod nonReentrant {
        IBEP20 spoticInstance = IBEP20(spoticAddr);
        uint256 balance = spoticInstance.balanceOf(address(this));
        uint256 bnbRate = getInternalBNBRate();
        uint256 amount = msg.value * bnbRate / 1000;
        require(amount > 0, "You have to purchase more than zero");
        require(amount <= balance, "You cant purchase more than balance");
        if (!unlimited) {
            require(
                purchaseLimit >= purchasedAmount[msg.sender] + amount,
                "You cant purchase more than limit"
            );
        }
        require(
            _referrencedAddress != address(0),
            "Referrenced Address should not zero"
        );
        uint256 referrencedAmount = amount.mul(referralPercent).div(10000);
        purchasedAmount[msg.sender] += amount - referrencedAmount;
        hardCap -= amount;
        spoticInstance.transfer(msg.sender, amount - referrencedAmount);
    }

    function purchaseBnbWithSpotic(
        uint256 spoticAmount
    ) external isNotPaused existedSpotic isPurchasingPeriod endedPreSale nonReentrant {
        IBEP20 spoticInstance = IBEP20(spoticAddr);
        uint256 balance = spoticInstance.balanceOf(msg.sender);
        uint256 bnbRate = getInternalBNBRate();
        uint256 amount = spoticAmount.mul(1000).div(bnbRate);
        require(amount > 0, "You have to purchase more than zero");
        require(amount <= balance, "You cant purchase more than balance");

        spoticInstance.transferFrom(msg.sender, address(this), spoticAmount);
        payable(msg.sender).transfer(amount);
    }

    function referralPurchaseBnbWithSpotic(
        address _referrencedAddress,
        uint256 spoticAmount
    ) external isNotPaused existedSpotic isPurchasingPeriod endedPreSale nonReentrant {
        IBEP20 spoticInstance = IBEP20(spoticAddr);
        uint256 balance = spoticInstance.balanceOf(msg.sender);
        uint256 bnbRate = getInternalBNBRate();
        uint256 amount = spoticAmount.div(bnbRate).mul(1000);
        require(amount > 0, "You have to purchase more than zero");
        require(amount <= balance, "You cant purchase more than balance");

        require(
            _referrencedAddress != address(0),
            "Referrenced Address should not zero"
        );
        uint256 referrencedAmount = amount.mul(referralPercent).div(10000);

        payable(_referrencedAddress).transfer(referrencedAmount);
        payable(msg.sender).transfer(amount - referrencedAmount);

        spoticInstance.transferFrom(msg.sender, address(this), spoticAmount);
    }

    function purchaseWithToken(
        uint256 tokenAmount,
        address tokenAddress
    ) external isNotPaused existedSpotic isPurchasingPeriod nonReentrant {
        IBEP20 tokenInstance = IBEP20(tokenAddress);
        IBEP20 spoticInstance = IBEP20(spoticAddr);

        uint256 balance = tokenInstance.balanceOf(msg.sender);
        uint256 tokenRate = getTokenRate(tokenAddress);

        uint256 decimals = tokenInstance.decimals();
        uint256 amount = tokenAmount.mul(tokenRate).div(1000).mul(curDecimal).div(10 ** decimals);

        require(amount > 0, "You have to purchase more than zero");
        require(amount <= balance, "You cant purchase more than balance");

        if (!unlimited) {
            require(
                purchaseLimit > purchasedAmount[msg.sender] + amount,
                "You cant purchase more than limit"
            );
        }

        spoticInstance.transfer(msg.sender, amount);
        tokenInstance.transferFrom(msg.sender, address(this), tokenAmount);

        purchasedAmount[msg.sender] += amount;
        hardCap -= amount;
    }

    function referralPurchaseWithToken(
        address _referrencedAddress,
        uint256 tokenAmount,
        address tokenAddress
    ) external isNotPaused existedSpotic isPurchasingPeriod nonReentrant {
        IBEP20 tokenInstance = IBEP20(tokenAddress);
        IBEP20 spoticInstance = IBEP20(spoticAddr);
        uint256 balance = tokenInstance.balanceOf(msg.sender);
        uint256 tokenRate = getTokenRate(tokenAddress);

        uint256 decimals = tokenInstance.decimals();
        uint256 amount = tokenAmount.mul(tokenRate).div(1000).mul(curDecimal).div(10 ** decimals);

        require(amount > 0, "You have to purchase more than zero");
        require(amount <= balance, "You cant purchase more than balance");

        if (!unlimited) {
            require(
                purchaseLimit > purchasedAmount[msg.sender] + amount,
                "You cant purchase more than limit"
            );
        }
        require(
            _referrencedAddress != address(0),
            "Referrenced Address should not zero"
        );
        uint256 referrencedAmount = amount.mul(referralPercent).div(10000);

        spoticInstance.transfer(msg.sender, amount - referrencedAmount);
        spoticInstance.transfer(_referrencedAddress, referrencedAmount);
        tokenInstance.transferFrom(msg.sender, address(this), tokenAmount);

        purchasedAmount[msg.sender] += amount - referrencedAmount;
        hardCap -= amount;
    }

    function purchaseTokenWithSpotic(
        uint256 spoticAmount,
        address tokenAddress
    ) external isNotPaused existedSpotic isPurchasingPeriod endedPreSale nonReentrant {
        IBEP20 tokenInstance = IBEP20(tokenAddress);
        IBEP20 spoticInstance = IBEP20(spoticAddr);
        uint256 balance = spoticInstance.balanceOf(msg.sender);
        uint256 tokenRate = getTokenRate(tokenAddress);

        uint256 decimals = tokenInstance.decimals();
        uint256 amount = spoticAmount.mul(10 ** decimals).div(curDecimal).div(tokenRate).mul(1000);

        require(amount > 0, "You have to purchase more than zero");
        require(amount <= balance, "You cant purchase more than balance");

        spoticInstance.transferFrom(msg.sender, address(this), spoticAmount);
        tokenInstance.transfer(msg.sender, amount);
    }

    function referralPurchaseTokenWithSpotic(
        address _referrencedAddress,
        uint256 spoticAmount,
        address tokenAddress
    ) external isNotPaused existedSpotic isPurchasingPeriod endedPreSale nonReentrant {
        IBEP20 tokenInstance = IBEP20(tokenAddress);
        IBEP20 spoticInstance = IBEP20(spoticAddr);
        uint256 balance = tokenInstance.balanceOf(msg.sender);
        uint256 tokenRate = getTokenRate(tokenAddress);

        uint256 decimals = tokenInstance.decimals();
        uint256 amount = spoticAmount.mul(10 ** decimals).div(curDecimal).div(tokenRate).mul(1000);

        require(amount > 0, "You have to purchase more than zero");
        require(amount <= balance, "You cant purchase more than balance");

        if (!unlimited) {
            require(
                purchaseLimit > purchasedAmount[msg.sender] + amount,
                "You cant purchase more than limit"
            );
        }
        require(
            _referrencedAddress != address(0),
            "Referrenced Address should not zero"
        );
        uint256 referrencedAmount = amount.mul(referralPercent).div(10000);

        tokenInstance.transfer(msg.sender, amount - referrencedAmount);
        tokenInstance.transfer(_referrencedAddress, referrencedAmount);
        spoticInstance.transferFrom(msg.sender, address(this), spoticAmount);
    }

    function withdrawBnb() external onlyOwner {
        payable(address(msg.sender)).transfer(address(this).balance);
    }

    function withdrawToken(address tokenAddress) external onlyOwner {
        IBEP20 tokenInstance = IBEP20(tokenAddress);

        tokenInstance.transfer(
            msg.sender,
            tokenInstance.balanceOf(address(this))
        );
    }

    function withdrawAll() external onlyOwner {
        for (uint256 i = 0; i < tokenAddresses.length(); i++) {
            IBEP20 tokenInstance = IBEP20(tokenAddresses.at(i));

            tokenInstance.transfer(
                msg.sender,
                tokenInstance.balanceOf(address(this))
            );
        }

        payable(address(msg.sender)).transfer(address(this).balance);
    }

    function getBnbBalance() public view returns (uint256 bnbAmount) {
        return address(this).balance;
    }

    function getTokenBalance(
        address tokenAddress
    ) public view returns (uint256 bnbAmount) {
        IBEP20 tokenInstance = IBEP20(tokenAddress);
        return tokenInstance.balanceOf(address(this));
    }

}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "./IBEP20.sol";

contract Spotic is Context, IBEP20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint8 public _decimals;
  string public _symbol;
  string public _name;

  constructor() {
    _name = "Spotic Token";
    _symbol = "Spotic";
    _decimals = 18;
    _totalSupply = 10000000000000000000000000000;
    _balances[msg.sender] = _totalSupply;

    emit Transfer(address(0), msg.sender, _totalSupply);
  }

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address) {
    return owner();
  }

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8) {
    return _decimals;
  }

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory) {
    return _symbol;
  }

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory) {
    return _name;
  }

  /**
   * @dev See {BEP20-totalSupply}.
   */
  function totalSupply() external view returns (uint256) {
    return _totalSupply;
  }

  /**
   * @dev See {BEP20-balanceOf}.
   */
  function balanceOf(address account) external view returns (uint256) {
    return _balances[account];
  }

  /**
   * @dev See {BEP20-transfer}.
   *
   * Requirements:
   *
   * - `recipient` cannot be the zero address.
   * - the caller must have a balance of at least `amount`.
   */
  function transfer(address recipient, uint256 amount) external returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  /**
   * @dev See {BEP20-allowance}.
   */
  function allowance(address owner, address spender) external view returns (uint256) {
    return _allowances[owner][spender];
  }

  /**
   * @dev See {BEP20-approve}.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  /**
   * @dev See {BEP20-transferFrom}.
   *
   * Emits an {Approval} event indicating the updated allowance. This is not
   * required by the EIP. See the note at the beginning of {BEP20};
   *
   * Requirements:
   * - `sender` and `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   * - the caller must have allowance for `sender`'s tokens of at least
   * `amount`.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }

  /**
   * @dev Atomically increases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  /**
   * @dev Atomically decreases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   * - `spender` must have allowance for the caller of at least
   * `subtractedValue`.
   */
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }

  /**
   * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
   * the total supply.
   *
   * Requirements
   *
   * - `msg.sender` must be the token owner
   */
  function mint(uint256 amount) public onlyOwner returns (bool) {
    _mint(_msgSender(), amount);
    return true;
  }

  /**
   * @dev Burn `amount` tokens and decreasing the total supply.
   */
  function burn(uint256 amount) public returns (bool) {
    _burn(_msgSender(), amount);
    return true;
  }

  function burnFrom(address account, uint256 amount) public returns (bool) {
    _burnFrom(account, amount);
    return true;
  }

  /**
   * @dev Moves tokens `amount` from `sender` to `recipient`.
   *
   * This is internal function is equivalent to {transfer}, and can be used to
   * e.g. implement automatic token fees, slashing mechanisms, etc.
   *
   * Emits a {Transfer} event.
   *
   * Requirements:
   *
   * - `sender` cannot be the zero address.
   * - `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   */
  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  /** @dev Creates `amount` tokens and assigns them to `account`, increasing
   * the total supply.
   *
   * Emits a {Transfer} event with `from` set to the zero address.
   *
   * Requirements
   *
   * - `to` cannot be the zero address.
   */
  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: mint to the zero address");

    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  /**
   * @dev Destroys `amount` tokens from `account`, reducing the
   * total supply.
   *
   * Emits a {Transfer} event with `to` set to the zero address.
   *
   * Requirements
   *
   * - `account` cannot be the zero address.
   * - `account` must have at least `amount` tokens.
   */
  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }

  /**
   * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
   *
   * This is internal function is equivalent to `approve`, and can be used to
   * e.g. set automatic allowances for certain subsystems, etc.
   *
   * Emits an {Approval} event.
   *
   * Requirements:
   *
   * - `owner` cannot be the zero address.
   * - `spender` cannot be the zero address.
   */
  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  /**
   * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
   * from the caller's allowance.
   *
   * See {_burn} and {_approve}.
   */
  function _burnFrom(address account, uint256 amount) internal {
    _burn(account, amount);
    _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
  }
}// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

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
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```solidity
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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
}
