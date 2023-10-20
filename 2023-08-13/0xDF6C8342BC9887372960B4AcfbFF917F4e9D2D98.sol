// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;
interface TokenLike {
    function transferFrom(address,address,uint) external;
    function transfer(address,uint) external;
    function balanceOf(address) external view  returns (uint);
}
interface ExchequerLike {
    function lpPool(address) external returns (uint);
    function getlpPool() external view returns (uint);
}
contract TMDlpPoolFarm {

    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "TMDlpPoolFarm/not-authorized");
        _;
    }

    struct UserInfo {
        uint256    amount;   
        int256    rewardDebt;
        uint256    harved;
    }

    uint256   public acclpPerShare;
    TokenLike public token = TokenLike(0x0f27d12182f7f4D879d267B31BD02dd27086e7Ce);
    TokenLike public lptoken = TokenLike(0xDb91Be3e38196907B6Fe0C0AF2845EB249D21788);
    ExchequerLike public exchequer;

    mapping (address => UserInfo) public userInfo;


    event Deposit( address  indexed  owner,
                   uint256           wad
                  );
    event Harvest( address  indexed  owner,
                   uint256           wad
                  );
    event Withdraw( address  indexed  owner,
                    uint256           wad
                 );


        // --- Math ---
    function add(uint x, int y) internal pure returns (uint z) {
        z = x + uint(y);
        require(y >= 0 || z <= x);
        require(y <= 0 || z >= x);
    }
    function sub(uint x, int y) internal pure returns (uint z) {
        z = x - uint(y);
        require(y <= 0 || z <= x);
        require(y >= 0 || z >= x);
    }
    function mul(uint x, int y) internal pure returns (int z) {
        z = int(x) * y;
        require(int(x) >= 0);
        require(y == 0 || z / y == int(x));
    }
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    
        return c;
      }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), "TMDlpPoolFarm/SignedSafeMath: subtraction overflow");

        return c;
    }
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "TMDlpPoolFarm/SignedSafeMath: addition overflow");

        return c;
    }
    function toUInt256(int256 a) internal pure returns (uint256) {
        require(a >= 0, "Integer < 0");
        return uint256(a);
    }
    constructor() {
        wards[msg.sender] = 1;
    }
    function setAddress(address _token,address _lptoken ,address _exchequer) external auth {
        token = TokenLike(_token);
        lptoken = TokenLike(_lptoken); 
        exchequer = ExchequerLike(_exchequer);
    }
    //The pledge LP  
    function deposit(uint _amount) public {
        updateReward();
        lptoken.transferFrom(msg.sender, address(this), _amount);
        UserInfo storage user = userInfo[msg.sender]; 
        user.amount = add(user.amount,_amount); 
        user.rewardDebt = add(user.rewardDebt,int256(mul(_amount,acclpPerShare) / 1e18));
        emit Deposit(msg.sender,_amount);     
    }
    function depositAll() public {
        uint _amount = lptoken.balanceOf(msg.sender);
        if (_amount == 0) return;
        deposit(_amount);
    }
    //Update mining data
    function updateReward() internal {
        uint lpSupply = lptoken.balanceOf(address(this));
        if (lpSupply == 0) return;
        uint256 yield = exchequer.lpPool(address(this));
        uint256 lpReward = div(mul(yield,uint(1e18)),lpSupply);
        acclpPerShare = add(acclpPerShare,lpReward);
    }
    //The harvest from mining
    function harvest() public returns (uint256) {
        updateReward();
        UserInfo storage user = userInfo[msg.sender];
        int256 accumulatedlp = int(mul(user.amount,acclpPerShare) / 1e18);
        uint256 _pendinglp = toUInt256(sub(accumulatedlp,user.rewardDebt));

        // Effects
        user.rewardDebt = accumulatedlp;

        // Interactions
        if (_pendinglp != 0) {
            token.transfer(msg.sender, _pendinglp);
            user.harved = add(user.harved,_pendinglp);
        }    
        emit Harvest(msg.sender,_pendinglp); 
       return  _pendinglp;    
    }
    //Withdrawal pledge currency
    function withdraw(uint256 _amount) public {
        updateReward();
        UserInfo storage user = userInfo[msg.sender];
        user.rewardDebt = sub(user.rewardDebt,int(mul(_amount,acclpPerShare) / 1e18));
        user.amount = sub(user.amount,_amount);
        lptoken.transfer(msg.sender, _amount);
        emit Withdraw(msg.sender,_amount);     
    }
    function withdrawAll() public {
        UserInfo storage user = userInfo[msg.sender]; 
        uint256 _amount = user.amount;
        if (_amount == 0) return;
        withdraw(_amount);
    }
    //Estimate the harvest
    function beharvest(address usr) public view returns (uint256) {
        uint lpSupply = lptoken.balanceOf(address(this));
        uint256 yield = exchequer.getlpPool();
        uint256 lpReward = div(mul(yield,uint(1e18)),lpSupply);
        uint256 _acclpPerShare = add(acclpPerShare,lpReward);
        UserInfo storage user = userInfo[usr];
        int256 accumulatedlp = int(mul(user.amount,_acclpPerShare) / 1e18);
        uint256 _pendinglp = toUInt256(sub(accumulatedlp,user.rewardDebt));
        return _pendinglp;
    }
 }