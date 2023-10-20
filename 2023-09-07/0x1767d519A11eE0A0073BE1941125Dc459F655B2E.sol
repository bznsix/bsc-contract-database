// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)
interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
 

// File: @openzeppelin\contracts\utils\introspection\IERC165.sol
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


// File: @openzeppelin\contracts\token\ERC721\IERC721.sol
interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// File: @openzeppelin\contracts\token\ERC20\IERC20.sol
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// File: @openzeppelin\contracts\token\ERC20\extensions\IERC20Metadata.sol
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

// File: @openzeppelin\contracts\utils\Context.sol
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin\contracts\token\ERC20\ERC20.sol
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

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address"); 
        _beforeTokenTransfer(from, to, amount);
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }
        emit Transfer(from, to, amount);
        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
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
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}

// File: @openzeppelin\contracts\token\ERC20\extensions\ERC20Burnable.sol
abstract contract ERC20Burnable is Context, ERC20 {
   
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}

// File: @openzeppelin\contracts\access\Ownable.sol
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

 


    // import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
    // import "@openzeppelin/contracts/utils/math/SafeMath.sol";
    // import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
    // import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
    // import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
    // import "@openzeppelin/contracts/access/Ownable.sol";



    contract ORG is ERC20 , Ownable , ERC20Burnable , IERC721Receiver  {
   
    function onERC721Received(
            address,
            address,
            uint256,
            bytes calldata
        ) external pure override returns (bytes4) {
            return IERC721Receiver.onERC721Received.selector;
        }

   
    mapping(uint256 => address) public NFT;
   
 
  
    uint256[] public max_reward_persecond;
    uint256[] config_timelock=[7890000,15780000,31560000,47340000,63120000,94680000]; //3,6,12,18,24,36 months
    uint256 constant   config_referral_percent = 10;
    uint256 public unMint = 2e24;
    uint256 public LastUseDeFi;
    uint256 constant   YearlyDistributionDeFi = 5;
    uint256 constant   YearlyDistributionStaking = 5;
    uint256 constant   secondperyears = 31560000;
    address public DeFiContract;
    bool    public DeFiIsFix = false;
    
   
   
    mapping(address => address) public upline;
   
    //log staking
    struct staking {
            address addr;
            uint256 tokenid;
            uint256 timestamp;
            uint256 pid;
            bool thisIn;
        }
      
    staking[] public stakings;
    
     //log staking
    struct nft_log {
            address addr;
            address upline;
            uint256 nft;
            uint256 timestamp;
            uint256 lastclaim;
            uint256 rewardpersecond;
            uint256 pid;
        }
     mapping(uint256 => nft_log) public nft_logs;


    //log staking user
    struct nft_users {
            uint256 timestamp;
            uint256 tokenId;
            bool thisIn;
        }
     mapping(address => nft_users[]) public nftlogs;
     uint256 public CountLockedNftFloor = 0;

  
    constructor() ERC20("ONERICH GROUP", "ORG") {

         _limit_mint(msg.sender, 2e23); //initial mint
        max_reward_persecond =[1e10,1e10,1e10,1e10,1e10,1e10];
        LastUseDeFi = block.timestamp;
     

        NFT[100]=0xdB92bE5d6ef6136c3e8d54e161A10E83E4F4A113;
        NFT[1000]=0xAE2650dFD2b0D435fc395EeDf2fd14e30AF9A354;
        NFT[10000]=0x909a73b84C5D394d8fFbf1af87a6686dBdD814Ec;
        NFT[100000]=0x891a9b49c02bD3c87b89e7d0fAd209A4f5f7f440;

    }

    event Stake(address addr, address nft , uint256 tokenId, uint256 pid);
    event Unstake(address addr, address nft , uint256 tokenId, uint256 pid);
    event Claim(address addr, uint256 tokenId, uint256 amount);
    event Affiliate(address addr, uint256 tokenId, uint256 amount);
    event SendToDefi(uint256 time, uint256 amount);
    

    //protector max suply
    function  _limit_mint(address a,uint256 b) internal {
        if(unMint<b) return; 
        _mint(a, b);
        unMint = unMint - b;
    }

     function maxSupply() public view returns(uint256) {
       return unMint + totalSupply();
    }

 
   //reconfig reward per second to set max APR
    function reconfig_reward(uint256  reward1,uint256  reward2,uint256  reward3,uint256  reward4,uint256  reward5,uint256  reward6) public onlyOwner  {
        if(reward1>0)max_reward_persecond[0] = reward1;//unable set to zero
        if(reward2>0)max_reward_persecond[1] = reward2;//unable set to zero
        if(reward3>0)max_reward_persecond[2] = reward3;//unable set to zero
        if(reward4>0)max_reward_persecond[3] = reward4;//unable set to zero
        if(reward5>0)max_reward_persecond[4] = reward5;//unable set to zero
        if(reward6>0)max_reward_persecond[5] = reward6;//unable set to zero
        
    }

   //stakeing nft 
    function stake( address Upline,uint256 tokenId,uint256 nft,uint256 pid) public {
        require(tokenId>0,"Require nft id");
        require(Upline != msg.sender,"Upline invalid");
        require(pid <=5 ,"Invalid pid");
        require(NFT[nft] != address(0),"Require valid nft");

        nft_log storage nftdata = nft_logs[tokenId];      
        IERC721(NFT[nft]).safeTransferFrom(msg.sender, address(this), tokenId);


        if(upline[msg.sender] != address(0)) Upline = upline[msg.sender];
        else upline[msg.sender] = Upline;
        
        //Note the data of staking at contract   
        nftdata.addr        = msg.sender;
        nftdata.upline      = Upline;
        nftdata.timestamp   = block.timestamp + config_timelock[pid];
        nftdata.lastclaim   = block.timestamp;
        nftdata.rewardpersecond = max_reward_persecond[pid];
        nftdata.pid = pid;
        nftdata.nft = nft;

        CountLockedNftFloor=CountLockedNftFloor + nft;

        
        //log the staking data in array
        stakings.push(staking({
            addr:msg.sender,
            tokenid:tokenId,
            timestamp:block.timestamp,
            pid:pid,
            thisIn:true
        }));

        //Log users staking In+Out
        nftlogs[msg.sender].push(nft_users({
            tokenId:tokenId,
            timestamp: nftdata.timestamp,
            thisIn:true
        }));
        
        
    emit Stake(msg.sender, NFT[nft] ,tokenId,pid);
    
    }

    function stakings_length() public view returns(uint256) {
         return stakings.length;
     }
    function user_stakings_length(address _user) public view returns(uint256) {
         return nftlogs[_user].length;
    }

 
    // Staking distribution limit | YearlyDistributionStaking
    function pendingreward(uint256 tokenId) public view returns(uint256) {
        if(nft_logs[tokenId].addr==address(0)) return 0;
        uint256 persecond = (((YearlyDistributionStaking * unMint * nft_logs[tokenId].nft)/100)/secondperyears)/CountLockedNftFloor;
        uint256 diverent = (block.timestamp - nft_logs[tokenId].lastclaim) * persecond;
        uint256 unMintAfterDiverent = unMint - diverent ; //Math.min(unmintbefore,unmintafter)
        uint256 floor_persecond  = (((YearlyDistributionStaking * unMintAfterDiverent * nft_logs[tokenId].nft) / 100) / secondperyears)/CountLockedNftFloor;
        uint256 AvailableReward  = (block.timestamp - nft_logs[tokenId].lastclaim) * floor_persecond;
        uint256 MaxReward = (block.timestamp - nft_logs[tokenId].lastclaim) * nft_logs[tokenId].rewardpersecond * nft_logs[tokenId].nft;
        if(MaxReward>AvailableReward)MaxReward = AvailableReward;
        return  MaxReward ;
     }



    // anyone can help to process claim reward 
    function claim_staking_reward(uint256 tokenId) public  {
       uint256 pending = pendingreward(tokenId);
       nft_log storage nftdata = nft_logs[tokenId];
          if(pending>0){
              if(nftdata.upline != address(0)){
                uint256 affReward  = (pending * config_referral_percent) / 100;
                _limit_mint(nftdata.upline, affReward);  
                emit Affiliate(nftdata.upline, tokenId, affReward);
    
              }
               _limit_mint(nftdata.addr, pending);     
          }
        nftdata.lastclaim = block.timestamp;
        nftdata.rewardpersecond = max_reward_persecond[nftdata.pid];
      
        emit Claim(nftdata.addr,tokenId,pending);
    
     }


    function configinfo_reward() public view returns(uint256,uint256,uint256,uint256,uint256,uint256) {
      return (
           max_reward_persecond[0]>0?max_reward_persecond[0]:0,
           max_reward_persecond[1]>0?max_reward_persecond[1]:0,
           max_reward_persecond[2]>0?max_reward_persecond[2]:0,
           max_reward_persecond[3]>0?max_reward_persecond[3]:0,
           max_reward_persecond[4]>0?max_reward_persecond[4]:0,
           max_reward_persecond[5]>0?max_reward_persecond[5]:0
       );

    }

 
    function unstake(uint256 tokenId ,bool is_emergency) public {
        require(tokenId>0,"Require tokenId");
        if(!is_emergency){
        claim_staking_reward(tokenId);
        }
        nft_log storage nftdata = nft_logs[tokenId];
        if(nftdata.timestamp<=block.timestamp && nftdata.addr==msg.sender){
            IERC721(NFT[nftdata.nft]).safeTransferFrom(address(this),msg.sender, tokenId);

            emit Unstake(nftdata.addr,nftdata.addr ,   tokenId, nftdata.pid);
   

            //reset data after unstaking
            nftdata.addr = address(0);
            nftdata.timestamp = 0;
            nftdata.lastclaim = 0;

            CountLockedNftFloor=CountLockedNftFloor - nftdata.nft;

            stakings.push(staking({
                addr:msg.sender,
                tokenid:tokenId,
                timestamp:block.timestamp,
                pid : nftdata.pid,
                thisIn:false
            }));

            nftlogs[msg.sender].push(nft_users({
                tokenId:tokenId,
                timestamp: nftdata.timestamp,
                thisIn:false
            })); 

          
         }
        
      
    
      }
     
 

      // DeFi FUNCTION
      // DeFi distribution limit | YearlyDistributionDeFi
    function defiPool() public view returns(uint256) {
        uint256 persecond = ((YearlyDistributionDeFi * unMint) / 100) / secondperyears;
        uint256 diverent = (block.timestamp - LastUseDeFi) * persecond;
        uint256 unMintAfterDiverent = unMint - diverent;
        uint256 floor_persecond = ((YearlyDistributionDeFi * unMintAfterDiverent) / 100) / secondperyears;
        uint256 unUseDeFiPool = (block.timestamp - LastUseDeFi) * floor_persecond;
        return unUseDeFiPool;
    }

    // unable to change contract after fix
    function setContract(address defi) public onlyOwner {
         require(!DeFiIsFix,"Unable to change DeFi contract");
         require(defi != address(0),"Unable to change DeFi contract");
         DeFiContract = defi;
    }

    // onetime setup , unable to undo
    function SetFixDefi() public onlyOwner { 
         require(DeFiContract != address(0),"Unable to change DeFi contract");
         DeFiIsFix = true;
    }
    
    // move reward alocation to DeFi contract
    function moveToDefi() public {
        require(DeFiContract != address(0),"Unset DeFi Contract");
        uint256 amount = defiPool();
        if(amount>0)_limit_mint(DeFiContract,amount);
        LastUseDeFi =block.timestamp;
        emit SendToDefi(LastUseDeFi ,  amount);
    
        
    }

     
 }