// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
//openZeppelin IERC20
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256); 

    function approve(address spender, uint256 amount) external returns (bool); 

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool); //被授权的第三方转账调用这个
}
library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(
        address target,
        bytes memory data
    ) internal view returns (bytes memory) {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeERC20: decreased allowance below zero"
            );
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    newAllowance
                )
            );
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function selfTransfer(address recipient, uint256 amount) public returns (bool) {
        require(recipient != address(0), "Transfer to the zero address");
        require(_balances[msg.sender] >= amount, "Insufficient balance");

        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;
        emit Transfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner"); 
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// pancakeV2
interface IPancakeFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
     function getPair(address tokenA, address tokenB) external view returns (address pair);
}

// pancakeV2
interface IPancakeRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);

    function getAmountsIn(
        uint256 amountOut,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);


}

/// KRToken
contract Kr is ERC20, Ownable {
    using SafeERC20 for IERC20;
    using Address for address;

    address private deadAddress = 0x000000000000000000000000000000000000dEaD;
    address private usdtAddress;
    address private marketingAddress;
    address public pancakeSwapV2PairAddr;
    address private pancakeSwapV2Router;
    address private bonusAddress;
    address private superAdmin;
    bool public paused;
    uint256 private sellFee;
    uint256 private sellMarketingFee;
    uint256 public initSupply = 10000000000e18;
    uint256 private sellLimit = 100000000000000000000;
    bool private _reentrantFlag = false;
    bool private _reentrantFlagB = false;
    mapping(address => uint256) private usdtLimit;
    mapping(address => bool) private wlist;
    mapping(address => bool) private superWlist;
    mapping(address => uint256) private krMember;
    bool private swapOpen = false ;

     constructor(
        address _pancakeSwapV2Router,
        address _usdtAddress,
        address _marketingAddress,
        address _bonusAddress,
        address _superAdmin
    ) ERC20("Keep Rising", "KR") {
        pancakeSwapV2Router = _pancakeSwapV2Router;
        usdtAddress =  _usdtAddress; 
        marketingAddress = _marketingAddress; 
        _mint(address(this), initSupply);
        bonusAddress = _bonusAddress ; 
        superAdmin = _superAdmin ;

        pancakeSwapV2PairAddr = IPancakeFactory(
            IPancakeRouter(pancakeSwapV2Router).factory()
        ).createPair(address(this), usdtAddress);
        
        wlist[msg.sender] = true; 
        wlist[address(this)] = true;  
        wlist[marketingAddress] = true; 
        wlist[pancakeSwapV2PairAddr] = true; 
        superWlist[msg.sender] = true ;
        superWlist[marketingAddress] = true ;
        superWlist[superAdmin] = true ;
      

        IERC20(pancakeSwapV2PairAddr).safeApprove(
            pancakeSwapV2Router,
            type(uint256).max
        );

        _approve(address(this), pancakeSwapV2Router, type(uint).max);
        
        sellFee = 85;
        sellMarketingFee = 15;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    modifier onlySuperAdmin() {
        require(msg.sender == superAdmin, "Only super admin");
        _;
    }

    modifier whenPaused() {
        require(paused, "Contract is not paused");
        _;
    }

    modifier nonReentrant() {
        require(!_reentrantFlag, "ReentrancyGuard: reentrant call");
        _reentrantFlag = true;
        _;
        _reentrantFlag = false;
    }
    modifier nonReentrantB() {
        require(!_reentrantFlagB, "ReentrancyGuard: reentrant call");
        _reentrantFlagB = true;
        _;
        _reentrantFlagB = false;
    }
   
    function pause() public onlyOwner whenNotPaused {
        paused = true;
    }

    function unpause() public onlySuperAdmin whenPaused {
        paused = false;  
    }

    function setConfAddress(address _marketingAddress) public onlyOwner {
        marketingAddress = _marketingAddress;
    }
    
    function setSellLimit(uint256 _sellLimit) public onlyOwner {
        sellLimit = _sellLimit;
    }
    function getSellLimit() public view onlyOwner returns (uint256){
        return sellLimit ;
    }

    function setBonusAddress(address _newBonusAddress) external onlyOwner {
        require(_newBonusAddress != address(0), "Cannot set to the zero address");
        superWlist[bonusAddress] = false ;
        bonusAddress = _newBonusAddress;
        usdtLimit[bonusAddress] =  type(uint256).max;
        superWlist[bonusAddress] = true; 
    }

    function setUSDTLimit(address wallet, uint256 amount) public onlyOwner {
        require(amount >= 0, "Amount should be greater than 0");
        usdtLimit[wallet] = amount;
    }

    function getUSDTLimit(address wallet) public view onlyOwner returns (uint256) {
        return usdtLimit[wallet];
    }

    function setwlist(address _account, bool _value) public onlyOwner {
        wlist[_account] = _value;
    }

    function setSuperWlist(address _account, bool _value) public onlyOwner {
         superWlist[_account] = _value;
    }

    function isAddressInSuperWlist(address _address) public view onlyOwner returns (bool) {
        return superWlist[_address];
    }

    
    function _setSwapOpen(bool _status) private nonReentrantB{
        swapOpen = _status ;
    }

    function getBonusAddress() public view onlyOwner returns (address) {
        return bonusAddress;
    }

    function isInWlist(address _account) public view onlyOwner returns (bool) {
        return wlist[_account];
    }

    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address sender = msg.sender;
        if(to == pancakeSwapV2Router || to == pancakeSwapV2PairAddr || sender == pancakeSwapV2PairAddr || sender== pancakeSwapV2Router){
              require(swapOpen , "please use it in Kr Dapp"); 
        }
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public  override returns (bool) {
        if(from == pancakeSwapV2Router || to == pancakeSwapV2PairAddr || from == pancakeSwapV2PairAddr || to== pancakeSwapV2Router){
              require(swapOpen, "please use it in Kr Dapp"); 
        }
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function updateSellFee(
        uint256 _sellFee,
        uint256 _sellMarketingFee
    ) public onlyOwner {
        sellFee = _sellFee;
        sellMarketingFee = _sellMarketingFee;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0) && to != address(0), "ERC20: transfer the zero address");
        if (wlist[from] || superWlist[from] ) {
            super._transfer(from, to, amount);
        } else {
            super._transfer(from, to, (amount * 80) / 100);
            super._transfer(from, deadAddress, (amount * 20) / 100);
        }
    }

    function getAmountUsdtOut(uint256 amountIn) public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdtAddress;
        return
            IPancakeRouter(pancakeSwapV2Router).getAmountsOut(amountIn, path)[
                1
            ];
    }

    function getAmountkfOut(uint256 amountIn) public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = usdtAddress;
        path[1] = address(this);
        return
            IPancakeRouter(pancakeSwapV2Router).getAmountsOut(amountIn, path)[
                1
            ];
    }

    event BuyKR(address indexed account, uint256 amount,uint256 krAmount);

    function buyKr(uint256 amountU) public  whenNotPaused nonReentrant{
        require(superWlist[msg.sender]||(krMember[msg.sender] >= 70000000000000000000), "Insufficient permissions");
        require(IERC20(usdtAddress).balanceOf(msg.sender) >= amountU, "Insufficient USDT balance");
        require(amountU <= usdtLimit[msg.sender], "USDT limit exceeded.");
        _setSwapOpen(true);
        IERC20(usdtAddress).safeTransferFrom(msg.sender, address(this), amountU);
        IERC20(usdtAddress).approve(pancakeSwapV2Router, amountU);
        uint256 totalKrsBoughtForBonus ;
        if(superWlist[msg.sender]){
            swapUsdtToKr(amountU, msg.sender); 
            totalKrsBoughtForBonus = 0 ;
        }
        else {
            uint256 part1 = (amountU * 666) / 1000; 
            uint256 part2 = (amountU * 300) / 1000; 
            uint256 part3 = amountU - part1 - part2;  
            addLiquidity(initSupply, part1); 
            uint256 initialKrBalanceBonus = IERC20(address(this)).balanceOf(bonusAddress);
            swapUsdtToKr(part3, bonusAddress);  
            uint256 finalKrBalanceBonus = IERC20(address(this)).balanceOf(bonusAddress);
            totalKrsBoughtForBonus= finalKrBalanceBonus - initialKrBalanceBonus;
            swapUsdtToKr(part2, msg.sender); 
            usdtLimit[msg.sender] -= amountU;
        }
          _setSwapOpen(false);
        emit BuyKR(msg.sender, amountU,totalKrsBoughtForBonus);
    }

    event UpgradeEvent(address indexed user, uint256 amountU,uint256 krAmount);

    function userUpgrade(uint256 amountU) public  whenNotPaused nonReentrant {
        require(IERC20(usdtAddress).balanceOf(msg.sender) >= amountU, "Insufficient USDT balance");
        IERC20(usdtAddress).safeTransferFrom(msg.sender, address(this), amountU);
        IERC20(usdtAddress).approve(pancakeSwapV2Router, amountU);
        _setSwapOpen(true);
        uint256 liquidityU = (amountU * 60) / 100; 
        uint256 krPurchaseU = (amountU * 30) / 100;
        uint256 bonusU = (amountU * 8) / 100; 
        uint256 projectU = (amountU * 2) / 100;  
        addLiquidity(initSupply, liquidityU); 
        uint256 initialKrBalanceBonus = IERC20(address(this)).balanceOf(bonusAddress);
        swapUsdtToKr(krPurchaseU, bonusAddress);
        uint256 finalKrBalanceBonus = IERC20(address(this)).balanceOf(bonusAddress);
        uint256 totalKrsBoughtForBonus = finalKrBalanceBonus - initialKrBalanceBonus;
        IERC20(usdtAddress).safeTransfer(marketingAddress, projectU);
        IERC20(usdtAddress).safeTransfer(bonusAddress, bonusU);
        _setSwapOpen(false);
        krMember[msg.sender] += amountU ;
        emit UpgradeEvent(msg.sender, amountU,totalKrsBoughtForBonus);

    }

    event SellKR(
        address indexed account,
        uint256 _userShare, 
        uint256 _refluxUsdt, 
        uint256 _sellofUsdt 
    );

    function sellKr(uint256 tokensToSell) public  whenNotPaused  nonReentrant returns (uint256) {
        require(superWlist[msg.sender]||(krMember[msg.sender] >= 70000000000000000000), "Insufficient permissions");
        require(balanceOf(msg.sender) >= tokensToSell, "Insufficient KR balance");
        uint256 usdtVaule = getAmountUsdtOut(tokensToSell);
        require(usdtVaule <= sellLimit, "Insufficient sellLimit");
        super._transfer(msg.sender, address(0xdead), tokensToSell);
        uint256 userShare ;
        uint256 liquidityKrBalance = this.balanceOf(pancakeSwapV2PairAddr);
        uint256 pairTotalSupply = IERC20(pancakeSwapV2PairAddr).totalSupply();
        uint256 liquidityToRemove = tokensToSell * pairTotalSupply/liquidityKrBalance;
        uint256 usdtBefore = IERC20(usdtAddress).balanceOf(address(this));
        _setSwapOpen(true);
        removeLiquidity(liquidityToRemove, (tokensToSell * 90) / 100, 0);
        uint256 usdtAfter = IERC20(usdtAddress).balanceOf(address(this));
        uint256 totalUsdtRetrieved = usdtAfter - usdtBefore;
        if(superWlist[msg.sender]){
            IERC20(usdtAddress).safeTransfer(msg.sender, totalUsdtRetrieved);
            emit SellKR(msg.sender, totalUsdtRetrieved, 0,totalUsdtRetrieved);  
        }else{
            userShare = (totalUsdtRetrieved * sellFee) / 100;
            IERC20(usdtAddress).safeTransfer(msg.sender, userShare);
            uint256 teamReserveShare = (totalUsdtRetrieved * sellMarketingFee) / 100;
            uint256 partA = (teamReserveShare * 666) / 1000;
            uint256 partB = teamReserveShare - partA ;
            IERC20(usdtAddress).safeTransfer(bonusAddress, partB);
            IERC20(usdtAddress).safeTransfer(marketingAddress, partA); 
            emit SellKR(msg.sender, userShare, partB,totalUsdtRetrieved);  
        }
         _setSwapOpen(false);
        return userShare;
    }

    function addLiquidity(uint256 tokenAmount, uint256 usdtAmount) private {
        IPancakeRouter(pancakeSwapV2Router).addLiquidity(
            address(this), 
            usdtAddress, 
            tokenAmount, 
            usdtAmount, 
            1, 
            usdtAmount, 
            address(this), 
            block.timestamp 
        );
    }

    function swapUsdtToKr(uint256 tokenAmount, address receiver) private {
        address[] memory path = new address[](2);
        path[0] = usdtAddress;
        path[1] = address(this);
        IPancakeRouter(pancakeSwapV2Router)
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                0, 
                path, 
                receiver, 
                block.timestamp 
            );
    }

    function removeLiquidity(
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin
    ) private {
        IPancakeRouter(pancakeSwapV2Router).removeLiquidity(
            address(this),
            usdtAddress, 
            liquidity, 
            amountAMin, 
            amountBMin, 
            address(this), 
            block.timestamp );
    }

    function firstAddLiquidity(
        uint256 tokenAmount, uint256 usdtAmount
    ) public onlyOwner whenNotPaused nonReentrant {
        _setSwapOpen(true);
        IERC20(usdtAddress).safeTransferFrom(msg.sender, address(this), usdtAmount);
        IERC20(usdtAddress).approve(pancakeSwapV2Router, usdtAmount);
        addLiquidity(tokenAmount, usdtAmount); 
        _setSwapOpen(false);
    }

    function withdrawToken(
        address _tokenAddress,
        address _to,
        uint256 amount
    ) public onlyOwner whenNotPaused nonReentrant {
        _setSwapOpen(true);
        IERC20(_tokenAddress).transfer(_to, amount);
        _setSwapOpen(false);
    }    

    function safeWithdrawToken(
        address _tokenAddress,
        address _to,
        uint256 amount
    ) public onlySuperAdmin whenPaused nonReentrant {
        _setSwapOpen(true);
        IERC20(_tokenAddress).transfer(_to, amount);
        _setSwapOpen(false);
    } 

    
    function safeSellKr(uint256 tokensToSell) public  onlySuperAdmin whenPaused  nonReentrant {
        require(superWlist[msg.sender], "Insufficient permissions");
        require(balanceOf(msg.sender) >= tokensToSell, "Insufficient KR balance");
        super._transfer(msg.sender, address(0xdead), tokensToSell);
        uint256 liquidityKrBalance = this.balanceOf(pancakeSwapV2PairAddr);
        uint256 pairTotalSupply = IERC20(pancakeSwapV2PairAddr).totalSupply();
        uint256 liquidityToRemove = tokensToSell * pairTotalSupply/liquidityKrBalance;
        uint256 usdtBefore = IERC20(usdtAddress).balanceOf(address(this));
        _setSwapOpen(true);
        removeLiquidity(liquidityToRemove, (tokensToSell * 90) / 100, 0);
        uint256 usdtAfter = IERC20(usdtAddress).balanceOf(address(this));
        uint256 totalUsdtRetrieved = usdtAfter - usdtBefore;
        IERC20(usdtAddress).safeTransfer(msg.sender, totalUsdtRetrieved);
    }

    function getContractParams() external view onlyOwner returns (address, uint256, uint256) {
        return (superAdmin, sellFee, sellMarketingFee);
    }
}