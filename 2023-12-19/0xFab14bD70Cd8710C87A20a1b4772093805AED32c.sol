// SPDX-License-Identifier: MIT
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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
     constructor ()  {
        address msgSender = payable(_msgSender());
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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
  
}

contract LiangPrivateSale is Ownable {
    IERC20 public token; // The token being sold
    IERC20 public usdt; // The token being sold
    address public wallet; // Address where funds are collected
   
    uint256 public ratePhase1; // Rate of tokens to ether for Phase 1
    uint256 public ratePhase2; // Rate of tokens to ether for Phase 2
    uint256 public ratePhase3; // Rate of tokens to ether for Phase 3
    uint256 public ratePhase4; // Rate of tokens to ether for Phase 4
    
    uint256 public phase1Tokens; // Total tokens available in Phase 1
    uint256 public phase2Tokens; // Total tokens available in Phase 2
    uint256 public phase3Tokens; // Total tokens available in Phase 3
    uint256 public phase4Tokens; // Total tokens available in Phase 4
  
    uint256 public weiRaised; // Total amount of wei raised
    //address  public _usdt=0x55d398326f99059fF775485246999027B3197955;
    address  public _usdt=0x55d398326f99059fF775485246999027B3197955;

    constructor(
        address _token,
        address _wallet,
        uint256 _ratePhase1,
        uint256 _ratePhase2,
        uint256 _ratePhase3,
        uint256 _ratePhase4,
        uint256 _phase1Tokens,
        uint256 _phase2Tokens,
        uint256 _phase3Tokens,
        uint256 _phase4Tokens
    ) {
        token = IERC20(_token);
        usdt = IERC20(_usdt);
        wallet = _wallet;
        ratePhase1 = _ratePhase1;
        ratePhase2 = _ratePhase2;
        ratePhase3 = _ratePhase3;
        ratePhase4 = _ratePhase4;
        phase1Tokens = _phase1Tokens;
        phase2Tokens = _phase2Tokens;
        phase3Tokens = _phase3Tokens;
        phase4Tokens = _phase4Tokens;  
    }

    function buyTokens(uint256 _amount) public payable {
        require(_amount > 0, "You must send some USDT");
        uint256 tokens;
        usdt.approve(address(this), _amount);
        bool status=usdt.transferFrom(address(msg.sender),address(this), _amount);
        if(status){ 
            if (phase1Tokens > 0 ) {
                tokens = (_amount * 10**18) / ratePhase1;
                require(phase1Tokens >= tokens, "Not enough tokens in Phase 1");
                phase1Tokens -= tokens;
            } else if(phase2Tokens > 0   ) {
                // Phase 2
                tokens = (_amount * 10**18)  / ratePhase2;
                require(phase2Tokens >=tokens , "Not enough tokens in Phase 2");
                phase2Tokens -= tokens;
            }else if(phase3Tokens > 0  ) {
                // Phase 3
                tokens = (_amount * 10**18)  / ratePhase3;
                require(phase3Tokens >=tokens , "Not enough tokens in Phase 3");
                phase3Tokens -= tokens;
            }else if(phase4Tokens > 0  ){
                tokens = (_amount * 10**18)  / ratePhase4;
                require(phase4Tokens >=tokens, "Not enough tokens in Phase 4");
                phase4Tokens -= tokens;
            }
            token.transfer(msg.sender, tokens);
            weiRaised += _amount;
        }
    }

    function withdrawFunds() public onlyOwner {
        payable(wallet).transfer(address(this).balance);
    }

    function withdrawtoken(uint256 tokens) public onlyOwner {
        token.transfer(msg.sender, tokens);
    }
    function withdrawusdt(uint256 tokens) public onlyOwner {
        usdt.transfer(msg.sender, tokens);
    }

    function setRatePhase1(uint256 _rate) public onlyOwner {
        ratePhase1 = _rate;
    }

    function setRatePhase2(uint256 _rate) public onlyOwner {
        ratePhase2 = _rate;
    }

    function setRatePhase3(uint256 _rate) public onlyOwner {
        ratePhase3 = _rate;
    }

    function setRatePhase4(uint256 _rate) public onlyOwner {
        ratePhase4 = _rate;
    }
}