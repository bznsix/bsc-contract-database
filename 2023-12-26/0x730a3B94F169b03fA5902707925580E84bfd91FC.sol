// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Ownable {
    address internal _owner;
    address internal _upgrade;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function getUpgrade() public view returns(address){
        return _upgrade;
    }

    function setUpgrade(address upgrade) external virtual{
        require(msg.sender == _owner,'!owner');
        _upgrade = upgrade;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender || (_upgrade != address(0) ? msg.sender == _upgrade : false), "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Manage is Ownable{
    using SafeMath for uint256;
    struct Info{
        string hashNumber;
        uint256 timestamp; 
        uint256 reward; 
        uint256 guessMantissa;
        uint256 hashMantissa; 
        address token; 
    }
    struct Children{
        string hashNumber;
        uint256 timestamp; 
        uint256 bonus;
    }
    struct Referrals{
        address[] adr; 
        address superior; 
        uint256 totalReward; 
        uint256 totalBets;
        Info[] info;
        Children[] children;
        uint256 totalBonus; 
    }
    struct Amount{
        uint256 min;
        uint256 max; 
        bool exceed; 
    }
    address[] private tokenList;
    bool private locked;
    address private guessAddress = 0xe8Ad915d65Cd35E0642719C48811268785ddF8f2; 
    mapping(address => Referrals) private referralsList; 
    mapping(address => Amount) limit; 
    uint256 private denominator = 10000; 
    uint256 private retail = 150; 
    uint256 private odds = 9500; 
    address private _receiver; 
    address private manageAddress; 
    address private Usdt = 0x55d398326f99059fF775485246999027B3197955;

    receive() external payable {}
    constructor(){

        manageAddress = 0xF69E76D36fBa457841D902b240F975cB1aa0Aeb9;
        _receiver = 0xaA2F14Fd45FE822a6935bE130E021962CF9354c9;

        IERC20 token = IERC20(0x50fCf9351a24cb0554d68C8FC9ae49E9b96e3D2f);
        IERC20 _usdt = IERC20(Usdt);

        tokenList.push(address(token));
        tokenList.push(address(_usdt));

        Amount storage _tokenLimit = limit[address(token)];
        _tokenLimit.min = 2000 * 10**token.decimals();
        _tokenLimit.max = 200000 * 10**token.decimals();

        Amount storage _usdtLimit = limit[Usdt];
        _usdtLimit.min = 20 * 10**_usdt.decimals();
        _usdtLimit.max = 5000 * 10**_usdt.decimals();


    }

    function setOdds(uint256 _odds) external virtual onlyOwner{
        odds = _odds;
    }

    function getOdds() external view returns(uint256){
        return odds;
    }

    function setRetail(uint256 _retail) external virtual onlyOwner{
        retail = _retail;
    }
    
    function getRetail() public view returns(uint256){
        return retail;
    }

    function setDenominator(uint256 _denominator) external virtual onlyOwner{
        denominator = _denominator;
    }

    function getDenominator() external view returns(uint256){
        return denominator;
    }

    function setManageAdr(address manage) external virtual onlyOwner{
        manageAddress = manage;
    }

    function getManageAdr() external view returns(address){
        return manageAddress;
    }

    function balanceOf(address token) external view returns(uint256){
        return IERC20(token).balanceOf(address(this));
    }

    function setLimit(address token, uint256 max,uint256 min, bool exceed) external virtual onlyOwner{
        Amount storage _amount = limit[token];
        _amount.max = max;
        _amount.min = min;
        _amount.exceed = exceed;
    }

    function setMaxLimit(address token, uint256 max) external virtual onlyOwner{
         Amount storage _amount = limit[token];
         _amount.max = max;
    }

    function setMinLimit(address token, uint256 min) external virtual onlyOwner{
         Amount storage _amount = limit[token];
         _amount.min = min;
    }

    function setExceedLimit(address token, bool exceed) external virtual onlyOwner{
         Amount storage _amount = limit[token];
         _amount.exceed = exceed;
    }

    function getLimit(address token) external view returns(uint256,uint256,bool,uint256){
        Amount storage _amount = limit[token];
        uint256 max = _amount.max;
        uint256 min = _amount.min;
        bool exceed = _amount.exceed;
        return (max,min,exceed,IERC20(token).decimals());
    }

    function getReceiver() external view returns(address){
        return _receiver;
    }

    function setReceiver(address receiver) external virtual onlyOwner{
        require(receiver != address(0),'address is zero');
        _receiver = receiver;
    }

    function getToken() external view returns(address[] memory){
        return tokenList;
    }

    function addToken(address _token) external virtual onlyOwner{
        tokenList.push(_token);
    }

    function removeToken(address _token) external virtual onlyOwner{
        uint256 length = tokenList.length;
        for(uint256 i = 0 ; i < length ; i++){
            if(tokenList[i] == _token){
                if(i < length - 1){
                    tokenList[i] = tokenList[length - 1]; 
                }
                tokenList.pop();
                return; 
            }
        }
    }

    function getGuessAddress() public view returns(address){
        return guessAddress;
    }

    function setGuessAddress(address adr) external virtual onlyOwner{
        guessAddress = adr;
    }

    function setSuperior(address sender,address _superior) external virtual returns(bool){
        Referrals storage referrals = referralsList[sender];
        require(address(0) == referrals.superior && address(0) != _superior && sender != _superior,'recommended person has been set');
        referralsList[_superior].adr.push(sender);
        referrals.superior = _superior;
        return true;
    }

    function getSuperior(address sender) external view returns(address){
        return referralsList[sender].superior;
    }
    function referralReward(address token,address from,uint256 amount) private returns(uint256,address){
        address superior = referralsList[from].superior;
        uint256 rewardAmount = amount.mul(retail).div(denominator);
        address adr;
        if(superior == address(0)){
            require(IERC20(token).transfer(_receiver, rewardAmount),'Transfer failed');
        }else{
            Referrals storage referrals = referralsList[superior];
            referrals.totalBonus = referrals.totalBonus.add(rewardAmount); 
            require(IERC20(token).transfer(superior, rewardAmount),'Transfer failed');
            adr = superior;
        }
        return (rewardAmount,adr);
    }

    function char(bytes1 b) private pure returns (bytes1) {
        if (uint8(b) < 10) { // 将 bytes1 转换为 uint8
            return bytes1(uint8(b) + 0x30);
        } else {
            return bytes1(uint8(b) + 0x57);
        }
    }

    function toHexString(bytes32 value) private pure returns (string memory) {
        bytes memory data = new bytes(64);
        for (uint i = 0; i < 32; i++) {
            bytes1 b = bytes1(uint8(uint(value) / (2**(8*(31 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            data[i*2] = char(hi);
            data[i*2 + 1] = char(lo);
        }
        return string(data);
    }
    function getBlockHash() private view returns (string memory) {
        // bytes32 blockHash = blockhash(block.number - 1);
        bytes32 blockHash = keccak256(
            abi.encodePacked(
                blockhash(block.number -1),
                block.number,
                block.timestamp
            )
        );
        return toHexString(blockHash);
    }
    function lastHashChar(string memory blockHash) private pure returns(uint256){
        for(uint256 i = bytes(blockHash).length; i > 0 ; i--){
            bytes1 lastCharacter = bytes(blockHash)[i - 1];
            bytes memory result = new bytes(2);
            result[0] = lastCharacter;
            result[1] = 0;
            if(!((lastCharacter >= "a" && lastCharacter <= "z") || (lastCharacter >= "A" && lastCharacter <= "Z"))){
                bytes memory hexBytes = bytes(string(result));
                uint256 last = 0;
                for(uint256 j = 0 ; j < hexBytes.length ; j++){
                    uint8 digit = uint8(hexBytes[j]);
                    if(digit >= 48 && digit <= 57){
                        last = last * 16 + (digit - 48);
                    }
                }
                return last;
            }
        }
        return 10;
    }
    function lastAmountChar(address token,uint256 amount)private view returns(uint256){
        uint256 decimals = 1 * 10 ** IERC20(token).decimals();
        return
        amount % decimals > 0
        ? (amount % decimals) / (decimals / 10):
        (amount / decimals) % 10;
    }

    function transfer(address token,address from ,address to, uint256 amount,string memory blockHash) private{
        require(from == guessAddress && guessAddress != address(0),'non guessing address');
        uint256 bonusAmount = amount.mul(odds).div(denominator).add(amount); 
        (uint256 rewardAmount,address superior) = referralReward(token,to, amount);
        computeResult(token,superior, rewardAmount, to, amount, bonusAmount,blockHash);
    }
    function computeResult(address token,address superior,uint256 rewardAmount,address sender,uint256 amount,uint256 bonusAmount,string memory blockHash) private{
        uint256 lastHast = lastHashChar(blockHash); 
        uint256 lastAmount = lastAmountChar(token,amount);
        bool bl;
        uint256 reward;
        if(((lastHast % 2 == 0) && (lastAmount % 2 == 0)) || ((lastHast % 2 != 0) && (lastAmount % 2 != 0))){ 
            Children[] storage children = referralsList[superior].children; 
            Children memory newChildren = Children({hashNumber:blockHash,timestamp:block.timestamp,bonus:rewardAmount});
            children.push(newChildren);
            Amount storage _limit = limit[token];
            if(_limit.max < amount){ 
                if(_limit.exceed){
                    reward = bonusAmount;
                    bl = true;
                }
            }else{
                reward = bonusAmount;
                bl = true;
            }
        }
        Referrals storage referrals = referralsList[sender];
        referrals.totalBets = referrals.totalBets.add(amount);
        Info memory info = Info({
            hashNumber:blockHash,
            timestamp:block.timestamp,
            guessMantissa:lastAmount,
            hashMantissa:lastHast,
            token:token,
            reward: reward
        });
        referrals.totalReward = referrals.totalReward.add(reward);
        referrals.info.push(info);
        if(bl){
            require(IERC20(token).transfer(sender, reward),'Transfer failed');
        }
    }

    function transferFrom(string memory blockHash,address token,address to ,uint256 amount) external virtual{
        address from = msg.sender;
        transfer(token,from, to, amount,blockHash);
    }

    function claimToken(address token, uint256 amount) external onlyOwner{
        IERC20(token).transfer(_receiver, amount);
    }

    function claimAllToken(address token) external onlyOwner{
        IERC20 erc20 = IERC20(token);
        erc20.transfer(_receiver, erc20.balanceOf(address(this)));
    }

    function claimBalance() external onlyOwner{
        payable(_receiver).transfer(address(this).balance);
    }

    function getChildren(address adr) external view returns(string[] memory,uint256[] memory,uint256[] memory){
        Children[] storage children = referralsList[adr].children;
        uint256 length = children.length;
        uint256 itemLength = children.length > 5 ? 5 : length;
        string[] memory hashNumber = new string[](itemLength);
        uint256[] memory timestamp = new uint256[](itemLength);
        uint256[] memory bonus = new uint256[](itemLength);
        uint256 count = 0;
        for(uint256 i = length ;i > 0; i--){
            if(count >= 5){
                return (hashNumber,timestamp,bonus);
            }
            Children memory info = children[i-1];
            hashNumber[i-1] = info.hashNumber;
            timestamp[i-1] = info.timestamp;
            bonus[i-1] = info.bonus;
            count += 1;
        }
        return (hashNumber,timestamp,bonus);
    }

    function getTotalB(address adr) external view returns(uint256,uint256,uint256,address){
        Referrals storage referrals = referralsList[adr];
        return (referrals.totalReward,referrals.totalBets,referrals.totalBonus,referrals.superior);
    }

    function getInfo(address adr) external view returns(string[] memory,uint256[] memory,uint256[] memory){
        Referrals storage referrals = referralsList[adr];
        Info[] storage info = referrals.info;
        uint256 length = info.length;
        uint256 itemLength = info.length > 5 ? 5 : length;
        string[] memory hashNumber = new string[](itemLength);
        uint256[] memory timestamp = new uint256[](itemLength);
        uint256[] memory reward = new uint256[](itemLength);
        uint256 count = 0;
        for(uint256 i = length ;i > 0; i--){
            if(count >= 5){
                return (hashNumber,timestamp,reward);
            }
            Info storage item = info[i-1];
            hashNumber[i - 1] = item.hashNumber;
            timestamp[i - 1] = item.timestamp;
            reward[i - 1] = item.reward;
            count += 1;
        }
        return (hashNumber,timestamp,reward);
    }

    function getSubList(address adr) external view returns(address[] memory,uint256){
        address[] memory adrList= referralsList[adr].adr;
        uint256 length = adrList.length;
        uint256 count = 0;
        uint256 itemLength = adrList.length > 5 ? 5 : length;
        address[] memory List = new address[](itemLength);
        for(uint256 i = length ;i > 0; i--){
            if(count >= 5){
                return (List,length);
            }
            List[i - 1] = adrList[i - 1];
            count += 1;
        }
        return (List,length);
    }

    function getLastHash(address adr) external view returns (string memory,uint256){
        Info[] memory info = referralsList[adr].info;
        string memory str;
        uint256 timestamp;
        uint256 length = info.length;
        if(length > 0){
            Info memory item = info[length -1];
            str = item.hashNumber;
            timestamp = item.timestamp;
        }
        return (str,timestamp);
    }

}