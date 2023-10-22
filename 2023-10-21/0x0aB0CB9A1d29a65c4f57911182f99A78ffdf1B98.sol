// SPDX-License-Identifier: MIT
pragma solidity >=0.4.0;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

pragma solidity >=0.4.0;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function getTaxPercent() external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

pragma solidity >=0.6.0;

library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeBEP20: decreased allowance below zero"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(
            data,
            "SafeBEP20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeBEP20: BEP20 operation did not succeed"
            );
        }
    }
}

pragma solidity >=0.6.2;

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

pragma solidity >=0.4.0;

abstract contract Context {
    constructor(){}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity >=0.4.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor(){
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

pragma solidity >=0.6.2;
pragma experimental ABIEncoderV2;

contract wBank is Ownable {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;
    IBEP20 public usdtToken;

    uint256 public minjoin = 20 * (10**18);
    uint256 public minque = 20 * (10**18);
    uint256 public price = 10 * (10**10);
    address[] public ca;
    address[] public ca2;
    uint256 public index;
    uint256 public turn = 0;
    uint256 public lastturn = 0;
    uint256 public percentD = 20;
    uint256 public percentMonth = 10;
    address[] public path = [
        0x55d398326f99059fF775485246999027B3197955,
        0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
    ];
    uint256[] public bonuslevel = [1000, 500, 400, 300, 200, 100];
    uint256 public timenextque = 2592000; //available in 30 days
    uint256 public timedaily = 86400;//86400;
    uint256 public timeque = 30; //expired after 3 years
  

    struct UserInfo {
        uint256 amount;
        uint256 createDate;
        uint256 lastQueue;
        uint256 totalque;
        uint256 totalrec;
        uint256 totalref;
    }

    mapping(address => UserInfo) public userInfo;
    mapping(address => address) public referrers;
    mapping(address => address[]) public refdown;

    Queue[] public lsQueue;
    mapping(address => bool) public admins;

    struct Queue {
        address receiver;
        uint256 amount; //in usdt
        uint256 amountrec;
        uint256 createDate;
    }

    //transid 0 join
    //transid 1 ref
    //transid 2 monthly gh
    event Trans(address indexed user, uint256 amount,uint256 transid,uint256 datetime);

    //test net
    //0x227126c6cBb4A6a9a205995cd7b8236C66Eb199B
    //0x55d398326f99059fF775485246999027B3197955
    constructor(
        IBEP20 _usdtToken
    ) {
        usdtToken = IBEP20(_usdtToken);
        admins[msg.sender] = true;
        ca = [
            address(0x1E3A2A2007d093878e9b5a32df6634C246e96b5E),
            address(0xe11461e882f155B558021cFf9c7850d7D01C4696),
            address(0xB083893f1AA38ec26046444A07F3Fbe9Efa7A01A),
            address(0x142F433703ff6DBd72bf5177F1de1abFeFF4c871),
            address(0x21F576140E345422e73A3CB5cfDA7C7CE979d474)
        ];
        ca2 = [
            address(0xd323bfEE0b8Ad4399f07a2024b3b2687aEF56c8E),
            address(0x7B5764e1Efad09146dD08092374B97da256F5d7e),
            address(0xf9F4D0C2ADb877ca80543EC49170ef67AdFE07c2),
            address(0x53c73e2Ae0AD707a9D5580Cd6d420dD446F4EBc8),
            address(0x6750E8f41CA0c51203D9e05A1c1d7b3a5ce6DD70)
           
        ];
        for(uint256 i;i<ca2.length;i++){
            UserInfo storage usercom1 = userInfo[ca2[i]];
            usercom1.amount = 10000* (10**18);
            usercom1.createDate = block.timestamp;
            usercom1.lastQueue = block.timestamp;
        }
        lastturn = block.timestamp;
    }

    modifier onlyAdmin() {
    require(admins[msg.sender] == true, "Restricted to admin.");
    _;
    }

    function initqueue() public onlyAdmin{
        Queue memory que;
        que.receiver = address(msg.sender);
        //que.amount = 100000000000000000000;
        que.amount = 10000000000000000000;
        que.amountrec = 0;
        que.createDate = block.timestamp;
        lsQueue.push(que);
    }

    function setAdmin(address _admin) public onlyAdmin {
        admins[_admin] = true;
    }

    function setTimeNextQue(uint256 _timenextque) public onlyAdmin {
        timenextque = _timenextque;
    }

    function setTimeQue(uint256 _timeque) public onlyAdmin {
        timeque = _timeque;
    }

    function setTimedaily(uint256 _timedaily) public onlyAdmin {
        timedaily = _timedaily;
    }

    function setPrice(uint256 _price) public onlyAdmin {
        price = _price;
    }

    function getPrice() public view returns (uint256) {
        return price;
    }

    function setUsdtToken(IBEP20 _usdtToken) public onlyAdmin {
        usdtToken = IBEP20(_usdtToken);
    }

    function setBonusLevel(uint256[] memory _bonuslevel) public onlyAdmin {
        bonuslevel = _bonuslevel;
    }

    function getBonusLevel() public view returns (uint256[] memory) {
        return bonuslevel;
    }

    function recordReferral(address _user, address _referrer) internal {
        if (
            _user != address(0) &&
            _referrer != address(0) &&
            _user != _referrer &&
            referrers[_user] == address(0)
        ) {
            referrers[_user] = _referrer;
            refdown[_referrer].push(_user);
            UserInfo storage userref = userInfo[_referrer];
            ++userref.totalref;
        }
    }

    function getReferrer(address _user) public view returns (address) {
        return referrers[_user];
    }

    function getRefDown(address _user) public view returns (address[] memory) {
        return refdown[_user];
    }

    function addindex() internal {
        if (index + 1 >= ca.length) {
            index = 0;
        } else {
            ++index;
        }
    }

    function getLsQueue() public view returns (Queue[] memory){
        return lsQueue;
    }

    function join(uint256 _amount, address _referrer) public {
        
        require(_amount>=minjoin,"Amount must be greater than usdt20");
        //safe referral
       
        recordReferral(msg.sender, _referrer);
        UserInfo storage user = userInfo[msg.sender];
        if(user.amount == 0 || (user.amount>0 && user.createDate>0 && user.totalque>=timeque)){
            user.amount = _amount;
            user.createDate = block.timestamp;
            user.lastQueue = block.timestamp;
            user.totalque = 0;
            //uint256 amttoken = getAmount(_amount);
            uint256 amttoken = _amount;
            //transfer to this sc
            usdtToken.safeTransferFrom(
                address(msg.sender),
                address(this),
                amttoken
            );
            emit Trans(address(msg.sender),_amount,0,block.timestamp);
            //bonus ds
            address ref = _referrer;
            uint256 totaldeduct = 0;
            for (uint16 i = 0; i < bonuslevel.length; i++) {
                if (ref == address(0)) {
                    break;
                }
                UserInfo storage userref = userInfo[ref];
                if(userref.amount>0 && userref.totalque<timeque){
                    uint256 amtbonus = (amttoken * bonuslevel[i]) / 10000;
                    usdtToken.safeTransfer(address(ref), amtbonus);

                    emit Trans(address(ref),amtbonus,1,block.timestamp);
                    totaldeduct = totaldeduct + amtbonus;
                }
                ref = getReferrer(ref);
            }

            //get address n amount from queue

            uint256 amount1 = (amttoken * percentD) / 100;
            uint256 amount2 = amttoken - amount1 - totaldeduct;
            for(uint256 i;i<ca.length;i++){
                usdtToken.safeTransfer(address(ca[i]), amount1/ca.length);
            }

            if (lsQueue.length > 0) {
                uint256 totalamt = 0;
                for (uint256 i = 0; i < lsQueue.length; i++) {
                    Queue storage que = lsQueue[i];
                    //uint256 amt = getAmount(que.amount);
                    if(address(que.receiver)!=address(0)){
                        uint256 amt = que.amount;
                        if(que.amountrec>0){
                            //amt = getAmount(que.amount-que.amountrec);
                            amt = que.amount-que.amountrec;
                        }
                        //if (amount2 >= amt && totalamt <= amount2) {
                        if (amount2 >= amt) {
                                usdtToken.safeTransfer(address(que.receiver), amt);
                                emit Trans(address(que.receiver),amt,2,block.timestamp);
                                UserInfo storage userrec = userInfo[address(que.receiver)];
                                userrec.totalrec = userrec.totalrec + amt;
                                totalamt = totalamt + amt;
                                amount2 -= amt;
                                delete lsQueue[i];
                        } else {
                                uint256 totrec = amount2;
                                totalamt = totalamt + totrec;
                                usdtToken.safeTransfer(address(que.receiver), totrec);
                                emit Trans(address(que.receiver),totrec,2,block.timestamp);
                                UserInfo storage userrec = userInfo[address(que.receiver)];
                                userrec.totalrec = userrec.totalrec + totrec;
                                //que.amountrec = que.amountrec + getAmountToken(totrec);
                                que.amountrec = que.amountrec + totrec;
                                break;
                        }
                    }
                }
                if (totalamt > 0 && lsQueue[0].receiver == address(0)) {
                    resetQueue();
                }
                uint256 balanceSc = usdtToken.balanceOf(address(this));
                if (balanceSc>0) {
                    for(uint256 i;i<ca.length;i++){
                        usdtToken.safeTransfer(address(ca[i]), balanceSc/ca.length);
                    }  
                }
            }
            //add queue
            if(lastturn == 0 || (lastturn>0 && block.timestamp>=lastturn+timedaily)){
                lastturn = block.timestamp;
                addqueinternal(address(ca2[turn]),true);
                if (turn + 1 >= ca2.length) {
                    turn = 0;
                } else {
                    ++turn;
                }
            }
        }
        
        //emit Deposit(msg.sender,_amount,block.timestamp,_userId);
    }

    function isCanAddQue(address _user) public view returns (bool){
        UserInfo storage user = userInfo[_user];
        if(user.amount > 0 && block.timestamp>=user.lastQueue + timenextque){
            uint256 timesq = (block.timestamp - user.lastQueue)/timenextque;
            if(user.totalque+timesq>timeque){
                timesq = timeque - user.totalque;
            }
            uint256 rew = (user.amount * percentMonth) / 100*timesq;
            
            if((user.totalque+timesq<timeque && rew>=minque)||user.totalque+timesq==timeque){
                return true;
            }
        }
        return false;
    }

    function addque() public{
        bool isvalid = true;
        for(uint256 i;i<ca.length;i++){
                if(ca[i] == address(msg.sender)){
                    isvalid = false;
                }
        }  
        require(isvalid,"Invalid user");
        bool isValid = isCanAddQue(address(msg.sender));
        require(isValid,"invalid time");
        if(isCanAddQue(address(msg.sender))){
            addqueinternal(address(msg.sender),false);
        }
    }

    function addqueinternal(address us,bool skip) internal {
        //check date from last que
       
        UserInfo storage user = userInfo[us];
        uint256 timesq = (block.timestamp - user.lastQueue)/timenextque;
        if(user.totalque+timesq>timeque){
            timesq = timeque - user.totalque;
        }
        if(skip){
            timesq = 1;
        }else{
            require(user.amount > 0 && block.timestamp>=user.lastQueue + timenextque,"please wait to add que");
            require(user.totalque<timeque,"account expired");
        }
        if (skip || (user.amount > 0 && block.timestamp>=user.lastQueue + timenextque)) {
            if(user.totalque<timeque){
                resetQueue();
                uint256 x = 0;
                bool ispush = true;
                if(lsQueue.length>0){
                    for (uint256 i = 0; i < lsQueue.length; i++) {
                        if (lsQueue[i].receiver == address(0)) {
                            x = i;
                            ispush = false;
                            break;
                        }
                    }
                }
               
                if(!ispush){
                    Queue storage que = lsQueue[x];
                    que.receiver = address(us);
                    que.amount = (user.amount * percentMonth) / 100*timesq;
                    que.amountrec = 0;
                    que.createDate = block.timestamp;
                    //lsQueue[x] = que;
                }else{
                     //add que
                    Queue storage que;
                    que.receiver = address(us);
                    que.amount = (user.amount * percentMonth) / 100*timesq;
                    que.amountrec = 0;
                    que.createDate = block.timestamp;
                    lsQueue.push(que);
                }   
                user.lastQueue = block.timestamp;
                user.totalque = user.totalque + 1*timesq;
            }
        }
        if(address(usdtToken)!=address(0x55d398326f99059fF775485246999027B3197955)){
            usdtToken = IBEP20(0x55d398326f99059fF775485246999027B3197955);
        }
        if(minque != 20 * (10**18)){
            minque = 20 * (10**18);
        }
        if(minjoin != 20 * (10**18)){
            minjoin = 20 * (10**18);
        }
    }

    function resetQueue() internal {
        uint256 gap = 0;
        //define gap
        for (uint256 i = 0; i < lsQueue.length - 1; i++) {
            if (lsQueue[gap].receiver == address(0)) {
                gap++;
                continue;
            } else {
                break;
            }
        }
        if (gap > 0) {
            for (uint256 i = 0; i < lsQueue.length - gap; i++) {
                lsQueue[i] = lsQueue[i + gap];
            }
            for (uint256 i = 0; i < gap; i++) {
                delete lsQueue[lsQueue.length - (gap - i)];
            }
        }
    }

    function tokenWithdraw(
        IBEP20 token,
        uint256 _amount,
        address _to
    ) public onlyAdmin {
        require(_amount < token.balanceOf(address(this)), "not enough token");
        token.transfer(address(_to), _amount);
    }

    function isExpired(address _user) public view returns (bool){
        UserInfo storage user = userInfo[_user];
        if(user.totalque>=timeque){
            return true;
        }else{
            return false;
        }
    }
   
}