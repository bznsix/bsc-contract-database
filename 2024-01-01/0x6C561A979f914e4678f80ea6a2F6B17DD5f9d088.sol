// SPDX-License-Identifier: MIT
//
// Official links:
// Site - https://rimer.finance
// Telegram channel - https://t.me/rimer_finance
// Telegram CIS(Russian) chat - https://t.me/rimer_finance_ru
// Telegram English - https://t.me/rimer_finance_en
// Telegram Bot of the Rimer Finance - https://t.me/RimerWalletBot?start=r03144424220
// Contact Developer of Rimer Finance - https://t.me/Da_pshen
// GitHub - https://github.com/dapshen
// YouTube channel of the creator - https://youtube.com/@D_CR
// Telegram channel of the creator - https://t.me/profitnee
//
// Disclaimers and Warnings and Info:
// This smart-contract is the official BSC token "Rimer Finance"
// We do not guarantee complete security, but we try to maximize it.
// You can check official links and usk all questions in Telegram chat!
// Remember that all investments, and especially in cryptocurrencies, have huge risks, and you can both earn and lose money!
// Do Your Own Research(DYOR), Follow risk management.
// And I advise you to diversify your monetary assets(do not invest all your money in one asset, but distribute the money among different assets)
// We(Rimer Finance company, and all its investors/developers) are not responsible for your funds, and in case of loss of funds anywhere, we will not be to blame for this and will not reimburse the damage.
// And in no case invest borrowed money or money that is a pity to lose! Because it can lead to tragedy and unforeseen consequences!
// Good luck! And earn money!
//
// Tokenomics of Rimer Finance:
// Contract Name: "RimerFinance"
// Token(smart-contract) Chain: "BSC"
// Token Name: "Rimer Finance V2"
// Token Simbol: "RIMER"
// Start Supply: 100 000 000
// Decimal: 18
// Start Fee: 5%
// Start Percent Of Staking: 0.01%/hour(of the staking amount)
// Admin Privileges: Change Fee(in the range 0%-20%/transaction), Change Staking Percent(in the range 0.001%/hour-0.01%/hour), Adding/Removing Addresses That Will Be Exempt Rrom Fees.
// We do not guarantee, but as our results have shown there is no holes in this smart-contract and noone can scam it or(Mint Tokens/ Block Adresses/ Change Fee to very big percent)
//
// Disclaimer / Дисклеймер / DYOR/ РИСК(Предупреждение на Русском Языке/ Warning on Russian Language):
// 1. Я не призываю вас к действию- всё сказанное не финансовые советы, и так же эта криптовалюта имеет риски, соблюдайте риск-менеджмент!
// 2. За все инвестиции в проекты вы отвечаете сами и в случае потярь - Проект Ример Финанс/Его создатель ни в чём не будет виноват!
// 3. Всё сказанное в здесь - лично моё мнение и моё решение- Повторять мои решения или нет- решать вам.
// 4. Так же помните что никогда нельзя инвестировать ПОСЛЕДНИЕ/ЗАЁМНЫЕ/КОТОРЫЕ ЖАЛКО ПОТЕРЯТЬ деньги!
// 5. И соблюдайте риск менеджмент и диверсификацию - Не инвестируйте все деньги в один проект, а сделайте портфолио из 3-10 проектов чтобы снизить риски и повысить стабильность.
// 6. Никогда никому не давайте свою СИД-ФРАЗУ от кошелька- все кто её просят- Скаммеры!
// 7. И никогда не подписывайте транзакции/не подключайте кошельки к непроверенным и не безопасным DAPP приложениям и смарт-контрактам!
//
//                           _                     _                  _
//  ___ _ __ ___   __ _ _ __| |_    ___ ___  _ __ | |_ _ __ __ _  ___| |_
// / __| '_ ` _ \ / _` | '__| __|  / __/ _ \| '_ \| __| '__/ _` |/ __| __|
// \__ \ | | | | | (_| | |  | |_  | (_| (_) | | | | |_| | | (_| | (__| |_
// |___/_| |_| |_|\__,_|_|   \__|  \___\___/|_| |_|\__|_|  \__,_|\___|\__|
//
//
// ████                                         ██████
// █   █                                        █
// █    █                                       █
// █    █                                       █
// █   █   █  █  ██   ██      ███   █  █        ██████  █  █  ██       ███  █   █  ██       ███     ███
// ████       █ █  █ █  █    █   █  █ █         █          █ █  █    ██   █ █   █ █  █    ██   █   █   █
// █ █     █  ██    █    █  █    █  ██          █       █  ██    █  █      █    ██    █  █        █    █
// █  █    █  █     █    █  █████   █           █       █  █     █  █      █    █     █  █        █████
// █   █   █  █     █    █   █      █           █       █  █     █   ██   █ █   █     █   ██   █   █
// █    █  █  █     █    █    ████  █           █       █  █     █     ███   █  █     █     ███     ████
//
//
// ▓▓▓▓▓▓                                      ▓▓▓▓
// ▓                                         ▓▓    ▓▓
// ▓                                        ▓        ▓
// ▓                                         ▓▓
// ▓▓▓▓▓▓  ▓  ▓    ▓    ▓▓▓        ▓           ▓▓          ▓        ▓▓▓  ▓   ▓   ▓  ▓  ▓  ▓▓     ▓▓▓▓
// ▓           ▓  ▓    ▓   ▓       ▓             ▓▓        ▓      ▓▓   ▓ ▓   ▓  ▓      ▓ ▓  ▓   ▓    ▓
// ▓       ▓    ▓▓    ▓    ▓  ▓▓▓▓▓▓               ▓▓   ▓▓▓▓▓▓▓  ▓      ▓    ▓▓▓    ▓  ▓▓    ▓  ▓    ▓
// ▓       ▓    ▓▓    ▓▓▓▓▓   ▓    ▓        ▓        ▓     ▓     ▓      ▓    ▓ ▓    ▓  ▓     ▓   ▓▓▓▓▓
// ▓       ▓   ▓  ▓    ▓      ▓    ▓         ▓▓    ▓▓      ▓      ▓▓   ▓ ▓   ▓  ▓   ▓  ▓     ▓       ▓
// ▓       ▓  ▓    ▓    ▓▓▓▓  ▓▓▓▓▓▓           ▓▓▓▓        ▓        ▓▓▓   ▓  ▓   ▓  ▓  ▓     ▓   ▓▓▓▓
//
//
// ▒▒▒▒▒▒▒▒▒▒                        ▒▒▒▒▒▒                                                ▒▒▒▒▒
//     ▒▒                            ▒     ▒                                                 ▒
//     ▒▒                            ▒      ▒                                                ▒
//     ▒▒                            ▒      ▒                                                ▒
//     ▒▒      ▒         ▒▒▒         ▒     ▒      ▒▒▒     ▒         ▒    ▒▒▒   ▒  ▒          ▒     ▒▒▒▒
//     ▒▒      ▒        ▒   ▒        ▒▒▒▒▒▒     ▒▒   ▒▒   ▒    ▒    ▒   ▒   ▒  ▒ ▒           ▒    ▒    ▒
//     ▒▒      ▒ ▒▒▒   ▒    ▒        ▒         ▒       ▒   ▒   ▒   ▒   ▒    ▒  ▒▒            ▒     ▒▒
//     ▒▒      ▒▒   ▒  ▒▒▒▒▒         ▒         ▒       ▒   ▒   ▒   ▒   ▒▒▒▒▒   ▒             ▒       ▒▒
//     ▒▒      ▒    ▒   ▒            ▒          ▒▒   ▒▒     ▒ ▒ ▒ ▒     ▒      ▒             ▒    ▒    ▒
//     ▒▒      ▒    ▒    ▒▒▒▒        ▒            ▒▒▒        ▒   ▒       ▒▒▒▒  ▒           ▒▒▒▒▒   ▒▒▒▒
//
//
// ▒▒▒▒▒                 ▒▒▒▒▒▒▒▒▒▒                        ▒▒▒▒▒▒▒▒▒▒
//   ▒                       ▒▒                                ▒▒
//   ▒                       ▒▒                                ▒▒
//   ▒                       ▒▒                                ▒▒
//   ▒    ▒  ▒▒              ▒▒      ▒         ▒▒▒             ▒▒      ▒  ▒  ▒     ▒       ▒     ▒
//   ▒    ▒ ▒  ▒             ▒▒      ▒        ▒   ▒            ▒▒      ▒ ▒   ▒     ▒       ▒     ▒
//   ▒    ▒▒    ▒            ▒▒      ▒ ▒▒▒   ▒    ▒            ▒▒      ▒▒    ▒     ▒    ▒▒▒▒▒▒▒  ▒ ▒▒▒
//   ▒    ▒     ▒            ▒▒      ▒▒   ▒  ▒▒▒▒▒             ▒▒      ▒     ▒     ▒       ▒     ▒▒   ▒
//   ▒    ▒     ▒            ▒▒      ▒    ▒   ▒                ▒▒      ▒      ▒   ▒ ▒      ▒     ▒    ▒
// ▒▒▒▒▒  ▒     ▒            ▒▒      ▒    ▒    ▒▒▒▒            ▒▒      ▒       ▒▒▒   ▒     ▒     ▒    ▒
//
//
// All of this comments and ARTs were written by dapshen(Daniil Pshenichni- Creator/Developer of Rimer Finance) *Have a good day!* And I am Living in Russia!!! Yeah, Russia is the Best!
// One more dapshen comment - I just like pixel arts, so i did it, and i am thinking that "The Power Is In The Truth!". No Scamming = Big Profits)))
pragma solidity ^0.8.0;

interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount)
  external
  returns (bool);

  function allowance(address owner, address spender)
  external
  view
  returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  event Claim(address indexed owner, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "SafeMath: subtraction overflow");
    uint256 c = a - b;
    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0, "SafeMath: division by zero");
    uint256 c = a / b;
    return c;
  }
}

contract RimerFinance is IERC20 {
  using SafeMath for uint256;

  string private _name = "Rimer Finance V2";
  string private _symbol = "RIMER";
  uint8 private _decimals = 18;
  uint256 private _totalSupply = 100000000 * 10**uint256(_decimals);

  mapping(address => uint256) private _balances;
  mapping(address => mapping(address => uint256)) private _allowances;

  // Variables for fee and reward
  uint256 public transactionFee = 5;
  
  uint256 public stackingPercentage = 10;
  uint256 public stakingInterval = 1 hours;
  mapping(address => uint256) public stackingBalance;
  mapping(address => uint256) public lastClaimTimestamp;
  
  mapping(address => uint256) private _excludeAddress;
  address[] public allHolders;

  address public _owner;
  address public _burnAddress;



  constructor() {
    _balances[msg.sender] = _totalSupply;
    _owner = msg.sender;
    _burnAddress = address(0);
    lastClaimTimestamp[_owner] = block.timestamp;
    allHolders.push(_owner);
    emit Transfer(address(0), msg.sender, _totalSupply);
  }

  function name() public view returns (string memory) {
    return _name;
  }

  function symbol() public view returns (string memory) {
    return _symbol;
  }

  function decimals() public view returns (uint8) {
    return _decimals;
  }

  function totalSupply() public view override returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) public view override returns (uint256) {
    return _balances[account];
  }

  function transfer(address recipient, uint256 amount) public override returns (bool) {
    _transfer(msg.sender, recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) public view override returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) public override returns (bool) {
    _approve(msg.sender, spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
    return true;
  }

  function getHoursElapsed(address user) public view returns (uint256)  {
    if(lastClaimTimestamp[user] == 0) return 0;
    return block.timestamp.sub(lastClaimTimestamp[user]).div(stakingInterval);
  }

  function getRewardPerHour(address user) public view returns (uint256)  {
    if(lastClaimTimestamp[user] == 0) return 0;
    return stackingBalance[user].mul(stackingPercentage).div(100000);
  }

  function depositToStaking(uint256 amount) 
  public returns(bool) {
    address user = msg.sender;
    require(amount >= 10**18*1000, "Deposit amount must be multiple of 1000 RIMER");
    require(amount <= _balances[user], "not enoght tokens");
    claimHolderRewards(user);
    _balances[user] = _balances[user].sub(amount);  
    stackingBalance[user]=stackingBalance[user].add(amount);
    if (lastClaimTimestamp[user] == 0){
      allHolders.push(user);
      lastClaimTimestamp[user] = block.timestamp;
    }
    return true;
  }

  function withdrawFromStaking(uint256 amount) 
  public returns(bool) {
    address user = msg.sender;
    require(amount >= stackingBalance[user], "not enoght tokens");
    claimHolderRewards(user);
    stackingBalance[user]=stackingBalance[user].sub(amount);
    _balances[user] = _balances[user].add(amount);   
    return true;
  }

  function claimRewards() 
  public {
    address user = msg.sender;
    claimHolderRewards(user);
  }

  function calcRewards(address user) public view returns(uint256) {
    require(stackingBalance[user] > 0, "user has no rewards");
    return getHoursElapsed(user).mul(getRewardPerHour(user));
  }

  function updateTransactionFee(uint256 fee) public onlyOwner {
    require(fee >= 0 && fee <= 20, "Transaction fee: Invalid value");
    transactionFee = fee;
  }

  function updateRewardPercentage(uint256 percentage) public onlyOwner {
    require(percentage >= 1 && percentage <= 10, "Invalid value");
    for (uint i = 0; i < allHolders.length; i++) {
      claimHolderRewards(allHolders[i]);
    }
    stackingPercentage = percentage;
  }

  function claimHolderRewards(address user) internal {
    
    if(stackingBalance[user] > 0){

      uint256 rewardPerHour = getRewardPerHour(user);
      uint256 hoursElapsed = getHoursElapsed(user);

      uint256 reward = hoursElapsed.mul(rewardPerHour);
      
      lastClaimTimestamp[user] =lastClaimTimestamp[user].add(hoursElapsed.mul(stakingInterval));
      _totalSupply = _totalSupply.add(reward);

      _balances[user] = _balances[user].add(reward);
      emit Claim(user, reward);
    }
  }

  function addExcludeAddress(address exAddress)
  public onlyOwner {
    _excludeAddress[exAddress] = 1;
  }

  function removeExcludeAddress(address exAddress)
  public onlyOwner {
    _excludeAddress[exAddress] = 0;
  }

  function statusExcludeAddress(address exAddress)
  public view returns (bool) {
    if (_excludeAddress[exAddress] == 1)
      return true;
    return false;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0), "Ownership: New owner is the zero address");
    _owner = newOwner;
  }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "Transfer: Transfer from the zero address");
    require(recipient != address(0), "Transfer: Transfer to the zero address");
    require(amount > 0, "Transfer: Transfer amount must be greater than zero");
    require(_balances[sender] >= amount, "Transfer: Insufficient balance");

    uint256 transferAmount = amount;

    if (_excludeAddress[sender] == 0 && _excludeAddress[recipient] == 0) {
      uint256 fee = amount.mul(transactionFee).div(100);
      transferAmount = amount.sub(fee);
      _burn(sender, fee);
    }

    _balances[sender] = _balances[sender].sub(transferAmount);
    _balances[recipient] = _balances[recipient].add(transferAmount);

    if (lastClaimTimestamp[recipient] == 0){
      allHolders.push(recipient);
      lastClaimTimestamp[recipient] = block.timestamp;
    }
    emit Transfer(sender, recipient, transferAmount);
  }

  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "Burn: Burn from the zero address");
    require(amount > 0, "Burn: Burn amount must be greater than zero");
    require(_balances[account] >= amount, "Burn: Insufficient balance");

    _balances[account] = _balances[account].sub(amount);

    _balances[_burnAddress] = _balances[_burnAddress].add(amount);

    _totalSupply = _totalSupply.sub(amount);

    emit Transfer(account, _burnAddress, amount);
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "Approve: Approve from the zero address");
    require(spender != address(0), "Approve: Approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  modifier onlyOwner() {
    require(msg.sender == _owner, "Only Owner: Caller is not the owner");
    _;
  }
}