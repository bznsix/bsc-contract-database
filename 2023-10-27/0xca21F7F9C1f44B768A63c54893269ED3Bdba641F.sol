{"MetaHypeCoin.sol":{"content":"// SPDX-License-Identifier: MIT\r\npragma solidity ^0.8.0;\r\n\r\nimport \"./SafeMath.sol\";\r\nimport \"./nftstake.sol\";\r\nimport \"./ReentrancyGuard.sol\";\r\n\r\ninterface call {\r\n    function Updateuser(address adr) external view returns (uint256);\r\n}\r\n\r\ncontract MetaHype is IERC20, Ownable, ReentrancyGuard, call {\r\n    using SafeMath for uint256;\r\n    string public constant Name = \"METAHYPETOKEN\";\r\n    string public constant symbol = \"MTH\";\r\n    uint256 public constant decimals = 18;\r\n    uint256 public _totalSupply;\r\n    address private Staking;\r\n    uint256 public Rate;\r\n    address public Admin;\r\n    NFTStraking private nft;\r\n    Records private rec;\r\n    uint256 public trck1;\r\n    uint256 public trck2;\r\n    uint256 private component;\r\n    uint256 public d = 100000;\r\n\r\n\r\n\r\n\r\n    struct record {\r\n        uint256 lastupdate;\r\n        uint256 amount;\r\n        uint256 amtmint;\r\n    }\r\n    mapping(address =\u003e record) public Record;\r\n\r\n    mapping(address =\u003e mapping(address =\u003e uint256)) public allowance;\r\n    mapping(address =\u003e uint256) private balance;\r\n\r\n    // mapping (address )\r\n    constructor(\r\n        uint256 rate,\r\n        address adr,\r\n        uint256 comp\r\n    ) {\r\n        Rate = rate;\r\n        nft = NFTStraking(adr);\r\n        rec = Records(adr);\r\n        component = comp;\r\n    }\r\n\r\n    modifier onlyaddress() {\r\n        require(getTotalStake(_msgSender()) \u003e= 100 * 10**18,\"Only valid address call this method\");\r\n        _;\r\n    }\r\n\r\n    function balanceOf(address user) public view override returns (uint256) {\r\n        return balance[user];\r\n    }\r\n\r\n    function totalSupply() external view returns (uint256) {\r\n        return _totalSupply;\r\n    }\r\n\r\n    function transfer(address _to, uint256 _amount)external override returns (bool){\r\n        require(_to != address(0), \"Invalid address\");\r\n        require(_amount \u003e 0, \"Amount must be greater than 0\");\r\n        require(balance[msg.sender] \u003e= _amount, \"Insufficient balance\");\r\n        balance[msg.sender] -= _amount;\r\n        balance[_to] += _amount;\r\n\r\n        emit Transfer(msg.sender, _to, _amount);\r\n        return true;\r\n    }\r\n\r\n    function approve(address _spender, uint256 _amount)external override returns (bool){\r\n        require(_spender != address(0), \"Invalid address\");\r\n        allowance[msg.sender][_spender] = _amount;\r\n        emit Approval(msg.sender, _spender, _amount);\r\n        return true;\r\n    }\r\n\r\n    function transferFrom(address _from,address _to,uint256 _amount) external override returns (bool) {\r\n        require(_from != address(0), \"Invalid \u0027from\u0027 address\");\r\n        require(_to != address(0), \"Invalid \u0027to\u0027 address\");\r\n        require(_amount \u003e 0, \"Amount must be greater than 0\");\r\n        require(balance[_from] \u003e= _amount, \"Insufficient balance\");\r\n        require(allowance[_from][msg.sender] \u003e= _amount, \"Allowance exceeded\");\r\n        balance[_from] -= _amount;\r\n        balance[_to] += _amount;\r\n        allowance[_from][msg.sender] -= _amount;\r\n        emit Transfer(_from, _to, _amount);\r\n        return true;\r\n    }\r\n\r\n    function setRate(uint256 rate) external onlyOwner {\r\n        Rate = rate;\r\n    }\r\n\r\n    function getTotalStake(address user) public view returns (uint256 Totalstake){\r\n        return nft.balances(user);\r\n    }\r\n\r\n    function getToken(address user) public view returns (uint256 amount) {\r\n        return rec.mintingTokens(user);\r\n    }\r\n\r\n    function setamt(uint256[] memory amt, address[] memory user) external {\r\n        require(_msgSender() == Admin,\"Admin only changed\");\r\n        require(amt.length == user.length,\"Invalid addresses\");\r\n        for(uint256 i =0; i \u003c amt.length; i++){\r\n         if(getTotalStake(user[i]) \u003e= 100*10**18){\r\n           Record[user[i]].amtmint += amt[i];\r\n        }\r\n     }\r\n    }\r\n      function setupdate(uint256[] memory update, address[] memory user) external {\r\n        require(_msgSender() == Admin,\"Admin only changed\");\r\n        require(update.length == user.length,\"Invalid address\");\r\n        for(uint256 i =0; i \u003c update.length; i++){\r\n         if(getTotalStake(user[i]) \u003e= 100*10**18){\r\n           Record[user[i]].lastupdate = update[i];\r\n        }\r\n     }\r\n    }\r\n\r\n\r\n    function setupdate(uint256 update,address user) external {\r\n         require(_msgSender() == Admin,\"Admin only changed\");\r\n         Record[user].lastupdate = update;\r\n    }\r\n\r\n      function setamt(uint256 amt,address user) external {\r\n         require(_msgSender() == Admin,\"Admin only changed\");\r\n         Record[user].amtmint += amt;\r\n    }\r\n\r\n\r\n\r\n\r\n    function mint( address recipient,uint256 amount,uint256 value,uint256 key) external onlyaddress returns (bool) {\r\n        require( Record[_msgSender()].amtmint \u003e 0,\"you have no amount to claim\");\r\n        if(Record[_msgSender()].amtmint \u003c amount){\r\n            amount = Record[_msgSender()].amtmint;\r\n        }\r\n        \r\n        require((block.timestamp - Record[_msgSender()].lastupdate \u003e= 1 days \u0026\u0026 Record[_msgSender()].lastupdate != 0),\"please try for next day\");\r\n        require(getTotalStake(_msgSender()).mul(3) \u003e= Record[_msgSender()].amount + getToken(_msgSender()) \u0026\u0026\r\n                 getTotalStake(_msgSender()).mul(3) - (Record[_msgSender()].amount + getToken(_msgSender())) \u003e= amount, \"please give correct amount\");\r\n        require(recipient != address(0) \u0026\u0026 component == value,\"ERC20: mint to the zero address\");\r\n        require(nft.balances(_msgSender()) \u003e= 100 * 10**18,\"you are not eligible for minting the token\");\r\n       _minthandler(_msgSender(), amount);\r\n       Record[_msgSender()].amtmint -= amount;\r\n        return true;\r\n    }\r\n\r\n    function burn(uint256 amount, address recipient) external override returns (bool){\r\n        require(_msgSender() == Staking, \"You can not call this method\");\r\n        require(recipient != address(0), \"ERC20: mint to the zero address\");\r\n        require(balance[recipient] \u003e= amount, \"You have not balance\");\r\n        balance[recipient] = balance[recipient].sub(amount);\r\n        _totalSupply = _totalSupply.sub(amount);\r\n        emit Transfer(recipient, address(0), amount);\r\n        return true;\r\n    }\r\n\r\n    function _burn(uint256 amount) external returns (bool) {\r\n        require(_msgSender() != address(0), \"ERC20: mint to the zero address\");\r\n        require(balance[_msgSender()] \u003e= amount, \"You have not balance\");\r\n        balance[_msgSender()] = balance[_msgSender()].sub(amount);\r\n        _totalSupply = _totalSupply.sub(amount);\r\n        emit Transfer(_msgSender(), address(0), amount);\r\n        return true;\r\n    }\r\n\r\n    function _minthandler(address recipient, uint256 amount)private nonReentrant{\r\n        uint256 Tamount = (amount.mul(Rate)).div(d);\r\n        balance[recipient] = balance[recipient].add(Tamount);\r\n        _totalSupply = _totalSupply.add(Tamount);\r\n        Record[recipient].amount += amount;\r\n        Record[recipient].lastupdate = block.timestamp;\r\n        emit Transfer(address(0), recipient, Tamount);\r\n    }\r\n\r\n    function getRemainingAmt(address user)public view returns(uint amount){\r\n        return Record[user].amtmint; \r\n    }\r\n    function getRemainingTotalEarnAmt(address user)public view returns(uint amount){\r\n        return getTotalStake(user).mul(3) - (Record[user].amount + getToken(user)); \r\n    }\r\n\r\n    function setAdmin(address adr) external onlyOwner {\r\n        Admin = adr;\r\n        trck1 ++;\r\n    }\r\n\r\n    function Updateuser(address adr) public view override returns (uint256) {\r\n        return Record[adr].lastupdate;\r\n    }\r\n\r\n    function setStakingAd(address adr) external onlyOwner {\r\n        Staking = adr;\r\n    }\r\n\r\n}\r\n"},"Mintingcoin.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\n\n\nimport \"./Records.sol\";\n\ninterface IERC20 {\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\n    function transfer(address to, uint256 _amount) external returns (bool);\n    function approve(address spender, uint256 amount) external returns (bool);\n    function burn(uint256 _amount, address user) external returns(bool);\n    function mint(address _to, uint256 _amount,uint256 key,uint256 Dollor) external returns(bool); \n    function balanceOf(address account) external view returns (uint256); \n        event Transfer(address indexed from, address indexed to, uint256 value);\n      event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n\ninterface calling {\n    function called(address _to, uint256 _amount, uint256 _key,uint256 Dollor) external;\n    \n}\n\ncontract MintingCoin is IERC20, Records,calling{\n     string public name = \"METAHYPETOKEN\";   \n     string public symbol = \"MTH\";\n     uint8 public decimals = 18;\n    uint256 public totalSupply;\n    address public owner;\n    address private Adr;\n    uint256 public rate = 10;\n    \n\n    address public StrkingAddress;\n    \n    mapping(address =\u003e uint256) public _balanceOf;\n    mapping(address =\u003e mapping(address =\u003e uint256)) public allowance;\n    \n\n    event Burn(address indexed from, uint256 value);\n    \n    constructor() {\n     StrkingAddress = address(this);\n    }\n\n\n    \n    function mint(address _to, uint256 _amount, uint256 _key, uint256 Dollor) external override returns (bool) {\n        require(getKey() == _key,\"You\u0027re not eligible for claim \");\n        require(balances[_to] \u003e 0 , \"You must have atlest one Straked\");\n        require(msg.sender == StrkingAddress);\n\n        _balanceOf[_to] += _amount;\n        totalSupply += _amount;\n        mintingTokens[_to] += Dollor ;\n        require(balances[_to] * 3 \u003e= mintingTokens[_to],\"You not claim upto 3X\");\n         if (balances[_to] * 3 \u003c= mintingTokens[_to]) {\n            balances[_to] = 0;\n            mintingTokens[_to] = 0;\n        }\n   \n            \n        emit Transfer(address(0), _to, _amount);\n        return true;\n    }\n\n    function setStrakingAddress(address add) external onlyOwner{\n        StrkingAddress = add;\n    }\n        function balanceOf(address user) public view override returns (uint256) {\n        return _balanceOf[user];\n    }\n\n    function burn(uint256 _amount,address user) external override returns (bool) {\n        require(_amount \u003e 0, \"Amount must be greater than 0\");\n        require(_balanceOf[user] \u003e= _amount, \"Insufficient balance\");     \n        _balanceOf[user] -= _amount;\n        totalSupply -= _amount;\n        \n        emit Transfer(msg.sender, address(0), _amount);\n        emit Burn(user, _amount);\n        return true;\n    }\n    function setAdr(address adr)external onlyOwner{\n        Adr = adr;\n    }\n    \n    function transfer(address _to, uint256 _amount) external override returns (bool) {\n        require(_to != address(0), \"Invalid address\");\n        require(_amount \u003e 0, \"Amount must be greater than 0\");\n        require(_balanceOf[msg.sender] \u003e= _amount, \"Insufficient balance\");\n        _balanceOf[msg.sender] -= _amount;\n        _balanceOf[_to] += _amount;\n        \n        emit Transfer(msg.sender, _to, _amount);\n        return true;\n    }\n    \n    function approve(address _spender, uint256 _amount) external override returns (bool) {\n        require(_spender != address(0), \"Invalid address\");\n        \n        allowance[msg.sender][_spender] = _amount;\n        \n        emit Approval(msg.sender, _spender, _amount);\n        return true;\n    }\n    \n    function transferFrom(address _from, address _to, uint256 _amount) external override returns (bool) {\n        require(_from != address(0), \"Invalid \u0027from\u0027 address\");\n        require(_to != address(0), \"Invalid \u0027to\u0027 address\");\n        require(_amount \u003e 0, \"Amount must be greater than 0\");\n        require(_balanceOf[_from] \u003e= _amount, \"Insufficient balance\");\n        require(allowance[_from][msg.sender] \u003e= _amount, \"Allowance exceeded\");     \n        _balanceOf[_from] -= _amount;\n        _balanceOf[_to] += _amount;\n        allowance[_from][msg.sender] -= _amount;\n        \n        emit Transfer(_from, _to, _amount);\n        return true;\n    }\n\n         function called(address _to, uint256 _amount, uint256 _key, uint256 Dollor) external override  {\n              require(_msgSender() == Adr,\"..\");\n               IERC20 token = IERC20(address(this));\n               token.mint(_to, _amount, _key, Dollor);         \n       }\n       \n       function _mint(address to , uint256 amount)external onlyOwner{\n           _balanceOf[to] += amount;\n           totalSupply +=amount;\n       }\n         function SetRate(uint256 setrate)external onlyOwner{\n        rate = setrate;\n    }\n\n}\n"},"nftstake.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nimport \"./Records.sol\";\nimport \"./Mintingcoin.sol\";\n\n\ncontract NFTStraking is Records, MintingCoin {\n\n    IERC20 public usdtToken;\n    mapping(address =\u003e uint256) public lastUpdateTime;\n    event Staked(address indexed user, uint256 amount);\n    event claim_(address indexed user, uint256 amount, uint256 rewards);\n\n    uint256 public dailyRewardPercentage = 5;\n      bool public FreezClaim = true;\n\n\n\n\n    uint256 public Volt1Percentage = 90;\n    uint256 public Volt2Percentage = 10;\n    address private volt1Address ;\n    address private volt2Address;\n\n    address public tokenContract;\n\n\n    struct CustomerRecord {\n        uint256 totalVotes;\n        uint256 TotalNFTStaking;\n        uint256 totalPoints;\n        mapping(uint256 =\u003e bool) votedTopics;\n    }\n    \n    mapping(address =\u003e CustomerRecord) public customerRecords;\n\n    event Voted(address indexed voter, uint256 topicId, bool vote);\n\n    struct VoteRecord {\n        uint256 startDate;\n        uint256 endDate;\n        uint256 totalYes;\n        uint256 totalNo;\n        bool finish;\n    }\n\n\n    mapping(uint256 =\u003e VoteRecord) public voteRecords;\n\n    constructor(address _usdtToken) {\n        usdtToken = IERC20(_usdtToken);\n        tokenContract = address(this);\n    }\n\n\n    function BuyNFT(uint256 _amount) external {\n        require(_amount \u003e 0, \"Amount must be greater than 0\");\n        require(_amount % 100 == 0 ,\"Amount must be multiple of 100\");\n        usdtToken.transferFrom(msg.sender, address(this), _amount);\n        balances[msg.sender] += _amount;\n        customerRecords[msg.sender].TotalNFTStaking += _amount;\n        lastUpdateTime[msg.sender] = block.timestamp;\n        VoltTransfer(_amount);\n        emit Staked(msg.sender, _amount);\n    }\n\n    function Check_Claim_Amount(address staked) public  view returns (uint256 reward){\n        require(!FreezClaim,\"At a movement claim is stop by the deployer\");\n        require(balances[staked] * 3 \u003e= mintingTokens[staked]);\n        uint256 stakedAmount = balances[staked];\n        if(stakedAmount == 0){\n            return 0;\n        }\n        uint256 add;\n        uint256 stakingDays = (block.timestamp - lastUpdateTime[staked]) /\n            1 days;\n        uint256 rewards = (stakedAmount * 5) / 1000;\n\n        if (block.timestamp - lastUpdateTime[staked] \u003e 1 days) {\n            for (uint256 i = 0; i \u003c stakingDays; i++) {\n                add += rewards;\n                add += (add * 5) / 1000;\n                if (balances[staked] * 3 \u003c= add) {\n                    break;\n                }\n            }\n            return add *  rate;\n        } else if (block.timestamp - lastUpdateTime[staked] == 1 days) {\n            return rewards * rate;\n        } else {\n            return 0;\n        }\n    }\n    function claim() external {\n    require(!FreezClaim,\"At a movement claim is stop by the deployer\");\n    uint256 stakedAmount = balances[msg.sender];\n    require(stakedAmount \u003e 0, \"No staked amount\");\n    require( balances[msg.sender] * 3 \u003e= mintingTokens[msg.sender], \"Already received 3x rewards\");\n    require( block.timestamp - lastUpdateTime[msg.sender] \u003e= 1 days, \"Can only claim once per day\");\n\n\n    IERC20(tokenContract).mint(msg.sender,Check_Claim_Amount(msg.sender), getKey(),Check_Claim_Amount(msg.sender)/rate);\n\n\n        lastUpdateTime[msg.sender] = block.timestamp;\n        emit claim_(msg.sender, stakedAmount,Check_Claim_Amount(msg.sender));\n    }\n\n\n    function createVote(uint256 _voteId,uint256 _startDate, uint256 _endDate ) external {\n        require(msg.sender == Owner(), \"Only the owner can create votes\");\n        voteRecords[_voteId].startDate = _startDate;\n        voteRecords[_voteId].endDate = _endDate;\n        voteRecords[_voteId].finish = false;\n    }\n\n    function setFinishVote(uint256 _voteId, bool setFinish) external {\n        require(msg.sender == Owner(),\"Only Owner can wants to finish the voting\");\n        voteRecords[_voteId].finish = setFinish;\n    }\n\n    function vote(uint256 _voteId, bool _vote) external {\n        require(!voteRecords[_voteId].finish, \"Owner already finish the voting\");\n        require(  block.timestamp \u003e= voteRecords[_voteId].startDate, \"Voting has not started\");\n        require(block.timestamp \u003c= voteRecords[_voteId].endDate,\"Voting has ended\" );\n        require(balances[msg.sender] \u003e= 100 * 10**18,\"Insufficient balance to vote\" );\n        require( !customerRecords[msg.sender].votedTopics[_voteId], \"Already voted for this topic\" );\n        uint256 usdtBalance = balances[msg.sender];\n        uint256 points = usdtBalance / (100 * 10**18);\n        customerRecords[msg.sender].totalVotes += 1;\n        customerRecords[msg.sender].totalPoints += points;\n        customerRecords[msg.sender].votedTopics[_voteId] = _vote;\n        if (_vote) {\n            voteRecords[_voteId].totalYes += points;\n        } \n        else {\n            voteRecords[_voteId].totalNo += points;\n        }\n        emit Voted(msg.sender, _voteId, _vote);\n    }\n\n    function getCustomerRecord(address _customer) external view returns (uint256 totalVotes,uint256 totalPoints,uint256 totalStaked,bool Staking)\n    {\n        totalVotes = customerRecords[_customer].totalVotes;\n        totalPoints = customerRecords[_customer].totalPoints;\n        totalStaked = customerRecords[_customer].TotalNFTStaking;\n        uint256 amount = customerRecords[_customer].TotalNFTStaking;\n        if(amount \u003e 0 ) {\n          Staking = true;\n        }\n        else {\n            \n             Staking = false;\n        }\n    }\n\n    function getVoteRecord(uint256 _voteId) external view  returns ( uint256 startDate, uint256 endDate,uint256 totalYes, uint256 totalNo\n        )\n    {\n        startDate = voteRecords[_voteId].startDate;\n        endDate = voteRecords[_voteId].endDate;\n        totalYes = voteRecords[_voteId].totalYes;\n        totalNo = voteRecords[_voteId].totalNo;\n    }\n\n   function setVoltAddress(address volt1,address volt2) external onlyOwner{\n       volt1Address = volt1;\n       volt2Address = volt2;\n}\n    function setVoltpercentage(uint256  _volt1, uint256 _volt2) external  onlyOwner{  \n        require( msg.sender == Owner(),\"Only owner can set the percentage of volt\");\n        require( _volt1 \u003c 100 \u0026\u0026 _volt2 \u003c 100,\"Percentage must be under the value of 100\");\n        require( _volt1 + _volt2 == 100,\"Provide the valid percentage of volt1 and volt2 both sum equal to 100\");\n        Volt1Percentage = _volt1;\n        Volt2Percentage = _volt2;\n    }\n\n    function VoltTransfer(uint256 amount) internal {\n        uint256 voli1Amount = (amount * Volt1Percentage) / 100;\n        uint256 voli2Amount = (amount * Volt2Percentage) / 100;\n        usdtToken.transfer(volt1Address, voli1Amount);\n        usdtToken.transfer(volt2Address, voli2Amount);\n    }\n    function _FreezClaim(bool status)external onlyOwner{\n        FreezClaim = status;\n    }\n}"},"Records.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        this; \n        return msg.data;\n    }\n}\n\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    constructor() {\n        _setOwner(_msgSender());\n    }\n\n    function Owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    modifier onlyOwner() {\n        require(Owner() == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    function renounceOwnership() public virtual onlyOwner {\n        _setOwner(address(0));\n    }\n\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _setOwner(newOwner);\n    }\n\n    function _setOwner(address newOwner) private {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n\n\ncontract Records is Ownable{\n     uint256 private key;\n     mapping(address =\u003e uint256) public balances;\n     mapping(address =\u003e uint256) public mintingTokens;\n\n     function setKey(uint256 _key)external onlyOwner{\n    key = _key;\n     }\n\n    function getKey()internal view returns(uint256) {\n        return key;\n\n    }\n}\n"},"ReentrancyGuard.sol":{"content":"// SPDX-License-Identifier: MIT\r\n// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)\r\n\r\npragma solidity ^0.8.0;\r\n\r\n/**\r\n * @dev Contract module that helps prevent reentrant calls to a function.\r\n *\r\n * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier\r\n * available, which can be applied to functions to make sure there are no nested\r\n * (reentrant) calls to them.\r\n *\r\n * Note that because there is a single `nonReentrant` guard, functions marked as\r\n * `nonReentrant` may not call one another. This can be worked around by making\r\n * those functions `private`, and then adding `external` `nonReentrant` entry\r\n * points to them.\r\n *\r\n * TIP: If you would like to learn more about reentrancy and alternative ways\r\n * to protect against it, check out our blog post\r\n * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].\r\n */\r\nabstract contract ReentrancyGuard {\r\n    // Booleans are more expensive than uint256 or any type that takes up a full\r\n    // word because each write operation emits an extra SLOAD to first read the\r\n    // slot\u0027s contents, replace the bits taken up by the boolean, and then write\r\n    // back. This is the compiler\u0027s defense against contract upgrades and\r\n    // pointer aliasing, and it cannot be disabled.\r\n\r\n    // The values being non-zero value makes deployment a bit more expensive,\r\n    // but in exchange the refund on every call to nonReentrant will be lower in\r\n    // amount. Since refunds are capped to a percentage of the total\r\n    // transaction\u0027s gas, it is best to keep them low in cases like this one, to\r\n    // increase the likelihood of the full refund coming into effect.\r\n    uint256 private constant _NOT_ENTERED = 1;\r\n    uint256 private constant _ENTERED = 2;\r\n\r\n    uint256 private _status;\r\n\r\n    constructor() {\r\n        _status = _NOT_ENTERED;\r\n    }\r\n\r\n    /**\r\n     * @dev Prevents a contract from calling itself, directly or indirectly.\r\n     * Calling a `nonReentrant` function from another `nonReentrant`\r\n     * function is not supported. It is possible to prevent this from happening\r\n     * by making the `nonReentrant` function external, and making it call a\r\n     * `private` function that does the actual work.\r\n     */\r\n    modifier nonReentrant() {\r\n        // On the first call to nonReentrant, _notEntered will be true\r\n        require(_status != _ENTERED, \"ReentrancyGuard: reentrant call\");\r\n\r\n        // Any calls to nonReentrant after this point will fail\r\n        _status = _ENTERED;\r\n\r\n        _;\r\n\r\n        // By storing the original value once again, a refund is triggered (see\r\n        // https://eips.ethereum.org/EIPS/eip-2200)\r\n        _status = _NOT_ENTERED;\r\n    }\r\n}"},"SafeMath.sol":{"content":"// SPDX-License-Identifier: MIT\r\n// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)\r\n\r\npragma solidity ^0.8.0;\r\n\r\n// CAUTION\r\n// This version of SafeMath should only be used with Solidity 0.8 or later,\r\n// because it relies on the compiler\u0027s built in overflow checks.\r\n\r\n/**\r\n * @dev Wrappers over Solidity\u0027s arithmetic operations.\r\n *\r\n * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler\r\n * now has built in overflow checking.\r\n */\r\nlibrary SafeMath {\r\n    /**\r\n     * @dev Returns the addition of two unsigned integers, with an overflow flag.\r\n     *\r\n     * _Available since v3.4._\r\n     */\r\n    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {\r\n        unchecked {\r\n            uint256 c = a + b;\r\n            if (c \u003c a) return (false, 0);\r\n            return (true, c);\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.\r\n     *\r\n     * _Available since v3.4._\r\n     */\r\n    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {\r\n        unchecked {\r\n            if (b \u003e a) return (false, 0);\r\n            return (true, a - b);\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.\r\n     *\r\n     * _Available since v3.4._\r\n     */\r\n    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {\r\n        unchecked {\r\n            // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n            // benefit is lost if \u0027b\u0027 is also tested.\r\n            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\r\n            if (a == 0) return (true, 0);\r\n            uint256 c = a * b;\r\n            if (c / a != b) return (false, 0);\r\n            return (true, c);\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the division of two unsigned integers, with a division by zero flag.\r\n     *\r\n     * _Available since v3.4._\r\n     */\r\n    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {\r\n        unchecked {\r\n            if (b == 0) return (false, 0);\r\n            return (true, a / b);\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.\r\n     *\r\n     * _Available since v3.4._\r\n     */\r\n    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {\r\n        unchecked {\r\n            if (b == 0) return (false, 0);\r\n            return (true, a % b);\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the addition of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s `+` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - Addition cannot overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return a + b;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s `-` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - Subtraction cannot overflow.\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return a - b;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the multiplication of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s `*` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - Multiplication cannot overflow.\r\n     */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return a * b;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers, reverting on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s `/` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return a / b;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * reverting when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return a % b;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * CAUTION: This function is deprecated because it requires allocating memory for the error\r\n     * message unnecessarily. For custom revert reasons use {trySub}.\r\n     *\r\n     * Counterpart to Solidity\u0027s `-` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - Subtraction cannot overflow.\r\n     */\r\n    function sub(\r\n        uint256 a,\r\n        uint256 b,\r\n        string memory errorMessage\r\n    ) internal pure returns (uint256) {\r\n        unchecked {\r\n            require(b \u003c= a, errorMessage);\r\n            return a - b;\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers, reverting with custom message on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\r\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(\r\n        uint256 a,\r\n        uint256 b,\r\n        string memory errorMessage\r\n    ) internal pure returns (uint256) {\r\n        unchecked {\r\n            require(b \u003e 0, errorMessage);\r\n            return a / b;\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * reverting with custom message when dividing by zero.\r\n     *\r\n     * CAUTION: This function is deprecated because it requires allocating memory for the error\r\n     * message unnecessarily. For custom revert reasons use {tryMod}.\r\n     *\r\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(\r\n        uint256 a,\r\n        uint256 b,\r\n        string memory errorMessage\r\n    ) internal pure returns (uint256) {\r\n        unchecked {\r\n            require(b \u003e 0, errorMessage);\r\n            return a % b;\r\n        }\r\n    }\r\n}"}}