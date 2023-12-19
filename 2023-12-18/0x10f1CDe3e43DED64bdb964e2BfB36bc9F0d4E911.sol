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

contract HPJHIDO is Ownable{

    uint private unlocked = 1;
    modifier lock() 
    {
        require(unlocked == 1, 'upline: locked');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    uint256 total_v;

    uint256 public totalHpjhV;

     function editTotalV(uint256 v)
        public  checkEdit
    {
        total_v = v;
    } 

    function selectAmount()
        public  view  returns (uint256)
    {
        return total_v;
    }
   
    uint256  startPrice = 200;

    function editStartPrice(uint256 p)
        public checkEdit
    {
        startPrice = p;
    }

    function selectPrice()
        public view returns(uint256)
    {
        return startPrice;
    }

    function amountNum(uint256 a)
        public  view returns(uint256)
    {
        return   ((a / startPrice) / 1e15 ) * 1 ether;
    }
   
    address public su =0xE71606e5B60E142D87E7F14c3aF5DF3186B23B42;

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

    function selectDarrs()
        public view returns (uint256[] memory)
    {
        return d_arrs;
    }

    struct user
    {        
        uint256 amount;
        uint256 hpjh_amount;
        uint256 hpjh_output;

        address upline;
        uint256 upline_one_count;
        uint256 upline_one_reward;

        uint256 one_count;
        uint256 three_count;
        uint256 five_count;

        uint256 total_output;
        bool once;
        uint256 create_time;    
    }

    function editOncerCount1(address _a ,uint256 _b)
        public checkEdit
    {
        users[_a].one_count = _b;
    }
      function editOncerCoun3(address _a ,uint256 _b)
        public checkEdit
    {
        users[_a].three_count = _b;
    }
      function editOncerCount5(address _a ,uint256 _b)
        public checkEdit
    {
        users[_a].five_count = _b;
    }

    uint256[]  d_arrs =[5,3,2];

    function selectCount(uint256 a)
        private 
    {
        if(a == amountArr[0])
        {
            require(users[_msgSender()].once == false,"subscribed_er");
            users[_msgSender()].once = true;
        }else if(a == amountArr[1])
        {
            require(users[_msgSender()].one_count >= d_arrs[0],"one_people_er");
            users[_msgSender()].one_count -= d_arrs[0];
        }else if(a == amountArr[2])
        {
            require(users[_msgSender()].three_count >= d_arrs[1],"three_people_er");
            users[_msgSender()].three_count-=d_arrs[1];
        }else if(a == amountArr[3])
        {
            require(users[_msgSender()].five_count >= d_arrs[2],"five_people_er");
            users[_msgSender()].five_count-=d_arrs[2];
        }
    }

    function edituplieOneCount(address a,uint256 v)
        public  checkEdit
    {
        users[a].upline_one_count = v;
    } 

    mapping(address => user)   users;
    mapping(address => address[])   users_upline;

    struct Rv
    {
        address addr;
        uint256 amount;
        uint256 times;
    }

    function selectUpineOne(address addr,uint256 index,uint256 pageSize)
        public view returns(Rv[] memory)
    {
        uint256  onelength = users_upline[addr].length;
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
            address Rvv= users_upline[addr][i];
            rv[j].addr = Rvv;
            rv[j].amount= users[Rvv].hpjh_amount;
            rv[j].times = users[Rvv].create_time;
            j++;
        }
        return rv;
    }

    uint256[] amountArr  =[100 ether,300 ether, 500 ether,1000 ether];

    mapping(address=>bool) public ist;
    event Deplay(address,uint256,uint256);
  
    function deplay(uint256 amount) 
        external lock
    {        
        require(amount == amountArr[0]  || amount == amountArr[1]
                || amount == amountArr[2]  || amount == amountArr[3],"amount_er");

        selectCount(amount);

        users[_msgSender()].amount += amount;

        uint256 u_h = amountNum (amount);
        
        users[_msgSender()].hpjh_amount += u_h;
      
        users[_msgSender()].create_time = block.timestamp;

        if(ist[_msgSender()] == false) {
            numberOfHolders +=1;
            ist[_msgSender()] = true;
        }

        totalHpjhV += u_h;
        total_v += amount;
        uplineShare(amount,u_h);
        USDT.transferFrom(_msgSender(),su,amount);
        emit Deplay(_msgSender(),amount,u_h);
    }

    function uplineShare(uint256 a,uint256 b)
        private   
    {
       address addr =  users[_msgSender()].upline;
        if(addr != address(0))
        {
            users[addr].upline_one_reward += b / 10;
            if(a == amountArr[0])
            {
                users[addr].one_count+=1;
            }else if(a == amountArr[1])
            {
               users[addr].three_count+=1;
            } else if(a == amountArr[2])
            {
                users[addr].five_count+=1;
            }  
        }
    }

    address public HPGToken;

    function editHpgToken(address addr)
        public checkEdit
    {
        HPGToken = addr;
    }    

    event WD(address,uint256);
    function wd(uint256 a)
        external  lock
    {
        require(HPGToken != address(0),"token_err");
        require(users[_msgSender()].amount > 0,"deply_err");
       uint256 hpjh_output =  users[_msgSender()].hpjh_amount - users[_msgSender()].hpjh_output;
        
        if(hpjh_output >= a )
        {
            users[_msgSender()].hpjh_output += a;
        }else{
            hpjh_output += users[_msgSender()].upline_one_reward;
            
            if(hpjh_output  >= a )
            {
                users[_msgSender()].hpjh_output = users[_msgSender()].hpjh_amount;
                users[_msgSender()].upline_one_reward = hpjh_output - a;
            }else{
                hpjh_output = 0;
            }
        }
        require(hpjh_output > 0 ,"wd_err"); 
        users[_msgSender()].total_output += a;      
        IERC20(HPGToken).transfer(_msgSender(),a);
        emit WD(_msgSender(),a);
    }

    function upline(address addr) 
        external lock
    {
        require(users[addr].amount > 0 ,"upline_amount_er");
        require(users[_msgSender()].upline == address(0),"upline_zero_er");
        require(_msgSender() != addr,"upline_err");
        users[_msgSender()].upline = addr;
        users[addr].upline_one_count += 1;
        users_upline[addr].push(_msgSender());    
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
            "HPG::safeTransfer: transfer failed"
        );
    }

}