/**
 *Submitted for verification at BscScan.com on 2024-01-04
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
   
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
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

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
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

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
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

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}



// File: BEPPausable.sol


pragma solidity ^0.8.0;

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract BEPPausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;

  /**
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyOwner whenNotPaused returns (bool) {
    paused = true;
    emit Pause();
    return true;
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused returns (bool) {
    paused = false;
    emit Unpause();
    return true;
  }
}

interface IDexRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IDexFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IDexPair {
    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

contract XDRAGON_BORROW is Ownable, BEPPausable {
    IDexRouter public dexRouter;
    address public XDA_ADDRESS = 0x663be6BE35382Ed86066276560f07412E6368Cc7;
    address public XDU_ADDRESS = 0x25B7bdC411984510E8E956be0F11dCFb39963149;
    uint256 public startPrice;
    uint256 public percentCanborrow;
    uint256 public convertId;
    uint256 public convertLockingAmount;
    uint256 public etherLiquidateAmount;
    address[] public  lsAccount;
    uint256 public MAX_REPAY;
    uint256 public LIMIT_REPAY_SECOND;

    struct Account{
        uint256 etherAmount;
        uint256 tokenAmount;
        uint256 lastTimeRepay;
        BorrowInfo[] lsBorrow;
        PayInfo[] lspay;
        ConvertsInfo[] lsConvert;
    }

    struct BorrowInfo{
        uint256 etherAmount;
        uint256 tokenAmount;
        uint256 time;
    }

    struct PayInfo{
        uint256 etherAmount;
        uint256 tokenAmount;
        uint256 time;
    }

    struct ConvertsInfo{
        uint256 id;
        uint256 xduAmount;
        uint256 xdaAmount;
        uint256 startTime;
        uint256 unlockTime;
        bool claimed; 
    }

    mapping(address => Account) public mapAcc;

    constructor() payable {
        dexRouter = IDexRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        startPrice = 1600;
        percentCanborrow = 85;
        convertLockingAmount = 0;
        etherLiquidateAmount = 0;
        convertId = 1;
        MAX_REPAY = 5 * (10 ** 18);
        LIMIT_REPAY_SECOND = 30 * 60;
    }

    receive() external payable {

  	}

    function setDexRouter(address _router) external onlyOwner  whenNotPaused{ 
        dexRouter = IDexRouter(_router);
    }

    function setStartPrice(uint256 _p) external onlyOwner  whenNotPaused{ 
        startPrice = _p;
    }

    function setPercentCanborrow(uint256 _p) external onlyOwner  whenNotPaused{ 
        percentCanborrow = _p;
    }

    function setXDA_ADDRESS(address _address) external onlyOwner  whenNotPaused{ 
        XDA_ADDRESS = _address;
    }

     function setXDU_ADDRESS(address _address) external onlyOwner  whenNotPaused{ 
        XDU_ADDRESS = _address;
    }

    function setMAXREPAY(uint256 _MAX_REPAY) external onlyOwner  whenNotPaused{ 
        MAX_REPAY = _MAX_REPAY;
    }

    function setLIMIT_REPAY_SECOND(uint256 _LIMIT_REPAY_SECOND) external onlyOwner  whenNotPaused{ 
        LIMIT_REPAY_SECOND = _LIMIT_REPAY_SECOND;
    }

    function claimStuckTokens(address token) external onlyOwner {
        require(token != address(this), "Owner cannot claim native tokens");
        IERC20 ERC20token = IERC20(token);
        uint256 balance = ERC20token.balanceOf(address(this));
        ERC20token.transfer(msg.sender, balance);
    }

    function borrrow() external payable  whenNotPaused{
        require(msg.value > 0, "msg.value <= 0");
        Account storage acc = mapAcc[msg.sender];
        uint256 etherAmount = msg.value;
        uint256 tokenAmount = calTokenCanBorrow(msg.value);
        require(IERC20(XDA_ADDRESS).balanceOf(address(this)) >= tokenAmount, "not enough token");
        if (acc.lsBorrow.length == 0)
            lsAccount.push(msg.sender);
        acc.etherAmount += etherAmount;
        acc.tokenAmount += tokenAmount;
        acc.lsBorrow.push(BorrowInfo(etherAmount, tokenAmount, block.timestamp));
        IERC20(XDA_ADDRESS).transfer(msg.sender, tokenAmount);
    }

    function pay(uint256 tokenAmount) external whenNotPaused{
        Account storage acc = mapAcc[msg.sender];
        require(acc.tokenAmount > 0, "acc.tokenAmount <= 0");
        require(acc.lastTimeRepay + LIMIT_REPAY_SECOND < block.timestamp, "acc.lastTimeRepay + LIMIT_REPAY_SECOND >= block.timestamp");
        uint256 etherAmount = acc.etherAmount * tokenAmount / acc.tokenAmount;
        if (tokenAmount >= acc.tokenAmount)
        {
            tokenAmount = acc.tokenAmount;
            etherAmount = acc.etherAmount;
        }
        require(etherAmount > 0, "etherAmount <= 0");
        require(etherAmount <= MAX_REPAY, "etherAmount > MAX_REPAY");
        require(tokenAmount > 0, "tokenAmount <= 0");
        require(IERC20(XDA_ADDRESS).allowance(msg.sender,address(this)) >= tokenAmount,"The XDA allowed is not enough. You need approve more XDA");
        require(IERC20(XDA_ADDRESS).balanceOf(msg.sender) >= tokenAmount,"not enough token");
        require(address(this).balance >= etherAmount, "Address: insufficient balance");
        acc.lastTimeRepay = block.timestamp;
        acc.tokenAmount -= tokenAmount;
        acc.etherAmount -= etherAmount;
        acc.lspay.push(PayInfo(tokenAmount, etherAmount, block.timestamp));
        IERC20(XDA_ADDRESS).transferFrom(msg.sender, address(this), tokenAmount);
        (bool success, ) = msg.sender.call{value: etherAmount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function checkLiquidate() external {
        uint256 tokenPrice = getTokenPrice(XDA_ADDRESS);
        for(uint256 i = 0; i < lsAccount.length; i++){
            address add = lsAccount[i];
            if (mapAcc[add].etherAmount > 0)
            {
                if (mapAcc[add].etherAmount * tokenPrice < mapAcc[add].tokenAmount){                  
                    etherLiquidateAmount += mapAcc[add].etherAmount;
                    mapAcc[add].etherAmount = 0;
                    mapAcc[add].tokenAmount = 0;
                }
            }
        }
    }

    function claimLiquidate() external onlyOwner{
        require(address(this).balance >= etherLiquidateAmount, "insufficient balance");
        uint256 amount = etherLiquidateAmount;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
        etherLiquidateAmount -= amount;
    }

     function claimLiquidate2() external onlyOwner{
        require(address(this).balance > 0, "insufficient balance");
        uint256 amount = address(this).balance;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function calTokenCanBorrow(uint256 etherAmount) public view returns (uint256) {   
        uint256 res = getTokenPrice(XDA_ADDRESS) * etherAmount * percentCanborrow / 100;
        return res;
    }

    function getTokenPrice(address token) public view returns (uint256){
        if (startPrice == 0){
            address[] memory path = new address[](2);
            path[0] = dexRouter.WETH();
            path[1] = address(token);
            uint256[] memory amounts = new uint256[](2);
            amounts = dexRouter.getAmountsOut(1, path);
            return amounts[1];
        } else{
            return startPrice;
        }
       
    }

    function convert(uint256 xduAmount, uint256 tax) external whenNotPaused{
        require(IERC20(XDU_ADDRESS).allowance(msg.sender,address(this)) >= xduAmount,"The XDU allowed is not enough. You need approve more XDU");
        require(IERC20(XDU_ADDRESS).balanceOf(msg.sender) >= xduAmount,"not enough token");
        require(xduAmount > 0, "amount < 0");
        uint256 blockTime = block.timestamp;
        uint256 unlockTime = blockTime;
        if (tax == 0){
            unlockTime += 7 * 86400;
        } else if (tax == 10){
            unlockTime += 6 * 86400;
        } else if (tax == 20){
            unlockTime += 5 * 86400;
        } else if (tax == 30){
            unlockTime += 4 * 86400;
        } else if (tax == 40){
            unlockTime += 3 * 86400;
        } else if (tax == 50){
            unlockTime += 2 * 86400;
        } else if (tax == 60){
            unlockTime += 1 * 86400;
        } else if (tax == 70){
            unlockTime += 0 * 86400;
        } else {
            require(false, "tax not correct");
        }
        uint256 xdaAmount = xduAmount * (100 - tax) / 100;
        require(IERC20(XDA_ADDRESS).balanceOf(address(this)) >= convertLockingAmount + xdaAmount, "Not enough XDA");
        Account storage acc = mapAcc[msg.sender];
        ConvertsInfo memory convertsInfo = ConvertsInfo(convertId, xduAmount, xdaAmount, blockTime, unlockTime, false);
        convertLockingAmount += xdaAmount;
        if (tax == 70){
            convertsInfo.claimed = true;
            convertLockingAmount -= convertsInfo.xdaAmount;
        }
        acc.lsConvert.push(convertsInfo);
        convertId++;
        IERC20(XDU_ADDRESS).transferFrom(msg.sender,address(this),xduAmount);
        if (tax == 70){
            IERC20(XDA_ADDRESS).transfer(msg.sender, convertsInfo.xdaAmount);
        }
    }

    function claim_convert(uint256 id) external whenNotPaused{
        require(id > 0, "id <= 0");
        Account storage acc = mapAcc[msg.sender];
        for(uint256 i = 0;i < acc.lsConvert.length;  i++)
        {
            if (acc.lsConvert[i].id == id)
            { 
                require(acc.lsConvert[i].claimed == false, "convert claimed");
                require(block.timestamp <= acc.lsConvert[i].unlockTime, "convert not unlock yet");
                acc.lsConvert[i].claimed = true;
                convertLockingAmount -= acc.lsConvert[i].xdaAmount;
                IERC20(XDA_ADDRESS).transfer(msg.sender, acc.lsConvert[i].xdaAmount);
                break;
            }
        }

    }

    function getLsBorrow(address addr) public view returns (BorrowInfo[] memory) {
        return mapAcc[addr].lsBorrow;
    }

    function getLsPay(address addr) public view returns (PayInfo[] memory) {
        return mapAcc[addr].lspay;
    }

     function getLsConvert(address addr) public view returns (ConvertsInfo[] memory) {
        return mapAcc[addr].lsConvert;
    }

    

}