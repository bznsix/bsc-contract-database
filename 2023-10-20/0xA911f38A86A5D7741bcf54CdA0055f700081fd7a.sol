// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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

interface IERC20 { 
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
}

IERC20 constant USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);

contract XREIDO is Ownable{


    uint private unlocked = 1;
    modifier lock() 
    {
          require(unlocked == 1, 'upline: locked');
          unlocked = 0;
          _;
         unlocked = 1;
    }

    uint256 usdt_ai_price = 3;

    uint256[] uplineAmunt =  [100,50];

    function editUsdtAllinPrice(uint256 pice)
        public  checkEdit
    {
        usdt_ai_price = pice;
    }   

    uint256 public wdStartTime = 1704038400; 

    function editWdStartTime(uint256 time)
        public  checkEdit
    {
        wdStartTime = time;
    }

    address public su = 0xdE2534e04D5B2a81bE4CC0FeBe394ebc54A2A4a0;

    function editSu(address addrSu)
        public checkEdit
    {
        su = addrSu;
    }

    uint256 public numberOfHolders = 1;

    function editNumberOfHokders(uint256 num)
    public checkEdit
    {
        numberOfHolders = num;
    }

    uint256  public totalTranche = 10;

     function edittotalTranche(uint256 num)
    public checkEdit
    {
        totalTranche = num;
    }

    mapping (address => bool)  ist;

    struct user
    {        
        uint256 amount;
        uint256 ai_tranche;
        uint256 ai_amount;
        uint256 ai_output;

        address upline;
        uint256 upline_one_count;
        uint256 upline_one_reward;
        
        uint256 upline_two_count;
        uint256 upline_two_reward;

        uint256 total_output;
        uint256 create_time;    
    }

    mapping(address => user)   users;

    mapping(address => address[])   users_upline_one;

    mapping(address =>  address[])   users_upline_two;

    struct Rv
    {
        address addr;
        uint256 amount;
        uint256 times;
    }

    function selectUpineOne(address addr,uint256 index,uint256 pageSize)
        public view returns(Rv[] memory)
    {
        uint256  onelength = users_upline_one[addr].length;
        if(pageSize < onelength){
            onelength = pageSize;
        }
        if(onelength < index){
            index = 0;
        }
        uint256 j = 0;
        Rv[] memory  rv = new Rv[](onelength - index); 
        for(uint256 i = index; i < onelength; ++i)
        {
            address Rvv= users_upline_one[addr][i];
            rv[j].addr = Rvv;
            rv[j].amount= users[Rvv].ai_amount;
            rv[j].times = users[Rvv].create_time;
            j++;
        }
        return rv;
    } 

   function selectUpineTwo(address addr,uint256 index,uint256 pageSize)
        public view returns(Rv[] memory rv )
    {
        uint256  onelength = users_upline_two[addr].length;
        if(pageSize < onelength){
            onelength = pageSize;
        }
        if(onelength < index){
            index = 0;
        }
        uint256 j = 0;
        rv = new Rv[](onelength - index); 
        for(uint256 i = index; i < onelength; ++i)
        {
            address Rvv= users_upline_two[addr][i];
            rv[j].addr = Rvv;
            rv[j].amount= users[Rvv].ai_amount;
            rv[j].times = users[Rvv].create_time;
            j++;
        }
    } 

    mapping(address=>bool) public blacklists;

    function addRoverBlacklist(address addr,bool v)
    public checkEdit
    {
        blacklists[addr] = v;
    }

    event Deplay(address,uint256,uint256);

    function deplay(uint256 amount) 
        external lock
    {        
       require( users[_msgSender()].ai_tranche + amount <= totalTranche ,"tranche_er");
       uint256 u_u = uU(amount);
        
        users[_msgSender()].amount += u_u;
        users[_msgSender()].ai_amount += uR(amount);
        users[_msgSender()].ai_tranche += amount;
        users[_msgSender()].create_time = block.timestamp;

        if(ist[_msgSender()] == false) {
            numberOfHolders +=1;
            ist[_msgSender()] = true;
        } 

       uint256 _v =  uplineShare(u_u);

        USDT.transferFrom(_msgSender(),su,u_u - _v);
        emit Deplay(_msgSender(),amount,users[_msgSender()].ai_amount);
    }

    function uplineShare(uint256 a)
        private    returns(uint256 v)
    {

        if(users[_msgSender()].upline != address(0))
        {
            address addr = users[_msgSender()].upline;
            
            users[addr].upline_one_reward +=  (a * uplineAmunt[0]) / 1000;
            v += (a * uplineAmunt[0]) / 1000;
            USDT.transferFrom(_msgSender(),addr, (a * uplineAmunt[0]) / 1000);

            if(users[addr].upline != address(0))
            {
                users[users[addr].upline].upline_two_reward += (a * uplineAmunt[1]) / 1000;
                v += (a * uplineAmunt[1]) / 1000;
                USDT.transferFrom(_msgSender(),users[addr].upline, (a * uplineAmunt[1]) / 1000);
            }
        }
    }

    address public XREToken;

    function editAiToken(address addr)
        public checkEdit
    {
        XREToken = addr;
    }    

    event WD(address,uint256);
    function wd()
        external  lock
    {
        require(block.timestamp >= wdStartTime,"time_err");
        require(blacklists[_msgSender()] ==false ,"blacklists_err");
        require(XREToken != address(0),"token_err");
        require(users[_msgSender()].amount > 0,"deply_err");

        uint256 ai_output =  users[_msgSender()].ai_amount - users[_msgSender()].ai_output;
        if(ai_output >0 )
        {
            users[_msgSender()].ai_output += ai_output;
        }
        require(ai_output > 0 ,"wd_err");

        users[_msgSender()].total_output += ai_output;
        IERC20(XREToken).transfer(_msgSender(),ai_output);
        emit WD(_msgSender(),ai_output);
    }

    function upline(address addr) 
        external lock
    {
        require(users[_msgSender()].upline == address(0),"upline_err");
        require(_msgSender() != addr,"upline_err");
        users[_msgSender()].upline = addr;
        users[addr].upline_one_count += 1;
        users_upline_one[addr].push(_msgSender());

        if(users[addr].upline != address(0))
        {
            users[users[addr].upline].upline_two_count += 1;
            users_upline_two[users[addr].upline].push(_msgSender());
        }

    }

    function selectUsersInfo(address addr)
        public view  
        returns(user memory)
    {        
        return users[addr];
    }

    function selectUpline(address addr)
        public view  
        returns(address)
    {        
        return (users[addr].upline);

    }

    function addEditApprove(address addr,bool qd)
    public onlyOwner
    {
        editApprove[addr] = qd;
    }

    function selectEditApprove(address addr)
    public view returns(bool)
    {
        return editApprove[addr];
    }

    mapping(address => bool) editApprove;

    modifier checkEdit()
    {
        require(editApprove[_msgSender()] || owner() == _msgSender(),"edit_err");
         _;
    }

    function editUpline(address addr,address upAddr)
        external checkEdit  
    {        
        users[addr].upline = upAddr;
    }

    function uR(uint256 a_)
        private pure returns(uint256)
    {
        return  a_ * 100000 * 1 ether;        
    }

     function uU(uint256 a_)
        private pure returns(uint256)
    {
        return a_ *  500 ether;        
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) public  onlyOwner
    {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "XRE::safeTransfer: transfer failed"
        );
    }

}