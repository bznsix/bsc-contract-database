{"MetaHypeCoin.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nimport \"./SafeMath.sol\";\nimport \"./nftstake.sol\";\nimport \"./ReentrancyGuard.sol\";\n\ninterface call {\n    function Updateuser(address adr) external view returns (uint256);\n}\n\ncontract MetaHype is IERC20, Ownable, ReentrancyGuard, call {\n    using SafeMath for uint256;\n    string public constant Name = \"METAHYPETOKEN\";\n    string public constant symbol = \"MTH\";\n    uint256 public constant decimals = 18;\n    uint256 public _totalSupply;\n    address private Staking;\n    uint256 public Rate;\n    address public Admin;\n    NFTStraking private nft;\n    Records private rec;\n    uint256 public trck1;\n    uint256 public trck2;\n    uint256 private component;\n\n    struct record {\n        uint256 lastupdate;\n        uint256 amount;\n    }\n    mapping(address =\u003e record) public Record;\n\n    mapping(address =\u003e mapping(address =\u003e uint256)) public allowance;\n    mapping(address =\u003e uint256) private balance;\n\n    // mapping (address )\n    constructor(\n        uint256 rate,\n        address adr,\n        uint256 comp\n    ) {\n        Rate = rate;\n        nft = NFTStraking(adr);\n        rec = Records(adr);\n        component = comp;\n    }\n\n    modifier onlyaddress() {\n        require(getTotalStake(_msgSender()) \u003e= 100 * 10**18,\"Only valid address call this method\");\n        _;\n    }\n\n    function balanceOf(address user) public view override returns (uint256) {\n        return balance[user];\n    }\n\n    function totalSupply() external view returns (uint256) {\n        return _totalSupply;\n    }\n\n    function transfer(address _to, uint256 _amount)external override returns (bool){\n        require(_to != address(0), \"Invalid address\");\n        require(_amount \u003e 0, \"Amount must be greater than 0\");\n        require(balance[msg.sender] \u003e= _amount, \"Insufficient balance\");\n        balance[msg.sender] -= _amount;\n        balance[_to] += _amount;\n\n        emit Transfer(msg.sender, _to, _amount);\n        return true;\n    }\n\n    function approve(address _spender, uint256 _amount)external override returns (bool){\n        require(_spender != address(0), \"Invalid address\");\n        allowance[msg.sender][_spender] = _amount;\n        emit Approval(msg.sender, _spender, _amount);\n        return true;\n    }\n\n    function transferFrom(address _from,address _to,uint256 _amount) external override returns (bool) {\n        require(_from != address(0), \"Invalid \u0027from\u0027 address\");\n        require(_to != address(0), \"Invalid \u0027to\u0027 address\");\n        require(_amount \u003e 0, \"Amount must be greater than 0\");\n        require(balance[_from] \u003e= _amount, \"Insufficient balance\");\n        require(allowance[_from][msg.sender] \u003e= _amount, \"Allowance exceeded\");\n        balance[_from] -= _amount;\n        balance[_to] += _amount;\n        allowance[_from][msg.sender] -= _amount;\n        emit Transfer(_from, _to, _amount);\n        return true;\n    }\n\n    function setRate(uint256 rate) external onlyOwner {\n        Rate = rate;\n    }\n\n    function getTotalStake(address user) public view returns (uint256 Totalstake){\n        return nft.balances(user);\n    }\n\n    function getToken(address user) public view returns (uint256 amount) {\n        return rec.mintingTokens(user);\n    }\n\n    function setupdate(uint256[] memory update, address[] memory user) external {\n        require(_msgSender() == Admin,\"Admin only changed\");\n        require(update.length == user.length,\"Invalid address\");\n        for(uint256 i =0; i \u003c update.length; i++){\n         if(getTotalStake(user[i]) \u003e= 100*10**18){\n           Record[user[i]].lastupdate = update[i];\n        }\n     }\n    }\n    function setupdate(uint256 update,address user) external {\n         require(_msgSender() == Admin,\"Admin only changed\");\n         Record[user].lastupdate = update;\n    }\n\n    function mint( address recipient,uint256 amount,uint256 value,uint256 key) external onlyaddress returns (bool) {\n        require((block.timestamp - Record[_msgSender()].lastupdate \u003e= 1 days \u0026\u0026 Record[_msgSender()].lastupdate != 0));\n        require(getTotalStake(_msgSender()).mul(3) \u003e= Record[_msgSender()].amount + getToken(_msgSender()) \u0026\u0026\n                 getTotalStake(_msgSender()).mul(3) - Record[_msgSender()].amount + getToken(_msgSender()) \u003e amount, \"please give correct amount\");\n        require(\n            recipient != address(0) \u0026\u0026 component == value,\n            \"ERC20: mint to the zero address\"\n        );\n        require(\n            nft.balances(_msgSender()) \u003e= 100 * 10**18,\n            \"you are not eligible for minting the token\"\n        );\n        _minthandler(_msgSender(), amount);\n        return true;\n    }\n\n    function burn(uint256 amount, address recipient) external override returns (bool){\n        require(_msgSender() == Staking, \"You can not call this method\");\n        require(recipient != address(0), \"ERC20: mint to the zero address\");\n        require(balance[recipient] \u003e= amount, \"You have not balance\");\n        balance[recipient] = balance[recipient].sub(amount);\n        _totalSupply = _totalSupply.sub(amount);\n        emit Transfer(recipient, address(0), amount);\n        return true;\n    }\n\n    function _burn(uint256 amount) external returns (bool) {\n        require(_msgSender() != address(0), \"ERC20: mint to the zero address\");\n        require(balance[_msgSender()] \u003e= amount, \"You have not balance\");\n        balance[_msgSender()] = balance[_msgSender()].sub(amount);\n        _totalSupply = _totalSupply.sub(amount);\n        emit Transfer(_msgSender(), address(0), amount);\n        return true;\n    }\n\n    function _minthandler(address recipient, uint256 amount)internal nonReentrant {\n        require((getTotalStake(recipient).mul(10)).div(100) \u003e= amount,\"You can not mint\");\n        uint256 Tamount = amount.mul(Rate);\n        balance[recipient] = balance[recipient].add(Tamount);\n        _totalSupply = _totalSupply.add(Tamount);\n        Record[recipient].amount += amount;\n        Record[recipient].lastupdate = block.timestamp;\n        emit Transfer(address(0), recipient, Tamount);\n    }\n\n    function setAdmin(address adr) external onlyOwner {\n        Admin = adr;\n        trck1 ++;\n    }\n\n    function Updateuser(address adr) public view override returns (uint256) {\n        return Record[adr].lastupdate;\n    }\n\n    function setStakingAd(address adr) external onlyOwner {\n        Staking = adr;\n    }\n}\n"},"Mintingcoin.sol":{"content":"// SPDX-License-Identifier: MIT\r\npragma solidity ^0.8.0;\r\n\r\n\r\n\r\nimport \"./Records.sol\";\r\n\r\ninterface IERC20 {\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n    function transfer(address to, uint256 _amount) external returns (bool);\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n    function burn(uint256 _amount, address user) external returns(bool);\r\n    function mint(address _to, uint256 _amount,uint256 key,uint256 Dollor) external returns(bool); \r\n    function balanceOf(address account) external view returns (uint256); \r\n        event Transfer(address indexed from, address indexed to, uint256 value);\r\n      event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\ninterface calling {\r\n    function called(address _to, uint256 _amount, uint256 _key,uint256 Dollor) external;\r\n    \r\n}\r\n\r\ncontract MintingCoin is IERC20, Records,calling{\r\n     string public name = \"METAHYPETOKEN\";   \r\n     string public symbol = \"MTH\";\r\n     uint8 public decimals = 18;\r\n    uint256 public totalSupply;\r\n    address public owner;\r\n    address private Adr;\r\n    uint256 public rate = 10;\r\n    \r\n\r\n    address public StrkingAddress;\r\n    \r\n    mapping(address =\u003e uint256) public _balanceOf;\r\n    mapping(address =\u003e mapping(address =\u003e uint256)) public allowance;\r\n    \r\n\r\n    event Burn(address indexed from, uint256 value);\r\n    \r\n    constructor() {\r\n     StrkingAddress = address(this);\r\n    }\r\n\r\n\r\n    \r\n    function mint(address _to, uint256 _amount, uint256 _key, uint256 Dollor) external override returns (bool) {\r\n        require(getKey() == _key,\"You\u0027re not eligible for claim \");\r\n        require(balances[_to] \u003e 0 , \"You must have atlest one Straked\");\r\n        require(msg.sender == StrkingAddress);\r\n\r\n        _balanceOf[_to] += _amount;\r\n        totalSupply += _amount;\r\n        mintingTokens[_to] += Dollor ;\r\n        require(balances[_to] * 3 \u003e= mintingTokens[_to],\"You not claim upto 3X\");\r\n         if (balances[_to] * 3 \u003c= mintingTokens[_to]) {\r\n            balances[_to] = 0;\r\n            mintingTokens[_to] = 0;\r\n        }\r\n   \r\n            \r\n        emit Transfer(address(0), _to, _amount);\r\n        return true;\r\n    }\r\n\r\n    function setStrakingAddress(address add) external onlyOwner{\r\n        StrkingAddress = add;\r\n    }\r\n        function balanceOf(address user) public view override returns (uint256) {\r\n        return _balanceOf[user];\r\n    }\r\n\r\n    function burn(uint256 _amount,address user) external override returns (bool) {\r\n        require(_amount \u003e 0, \"Amount must be greater than 0\");\r\n        require(_balanceOf[user] \u003e= _amount, \"Insufficient balance\");     \r\n        _balanceOf[user] -= _amount;\r\n        totalSupply -= _amount;\r\n        \r\n        emit Transfer(msg.sender, address(0), _amount);\r\n        emit Burn(user, _amount);\r\n        return true;\r\n    }\r\n    function setAdr(address adr)external onlyOwner{\r\n        Adr = adr;\r\n    }\r\n    \r\n    function transfer(address _to, uint256 _amount) external override returns (bool) {\r\n        require(_to != address(0), \"Invalid address\");\r\n        require(_amount \u003e 0, \"Amount must be greater than 0\");\r\n        require(_balanceOf[msg.sender] \u003e= _amount, \"Insufficient balance\");\r\n        _balanceOf[msg.sender] -= _amount;\r\n        _balanceOf[_to] += _amount;\r\n        \r\n        emit Transfer(msg.sender, _to, _amount);\r\n        return true;\r\n    }\r\n    \r\n    function approve(address _spender, uint256 _amount) external override returns (bool) {\r\n        require(_spender != address(0), \"Invalid address\");\r\n        \r\n        allowance[msg.sender][_spender] = _amount;\r\n        \r\n        emit Approval(msg.sender, _spender, _amount);\r\n        return true;\r\n    }\r\n    \r\n    function transferFrom(address _from, address _to, uint256 _amount) external override returns (bool) {\r\n        require(_from != address(0), \"Invalid \u0027from\u0027 address\");\r\n        require(_to != address(0), \"Invalid \u0027to\u0027 address\");\r\n        require(_amount \u003e 0, \"Amount must be greater than 0\");\r\n        require(_balanceOf[_from] \u003e= _amount, \"Insufficient balance\");\r\n        require(allowance[_from][msg.sender] \u003e= _amount, \"Allowance exceeded\");     \r\n        _balanceOf[_from] -= _amount;\r\n        _balanceOf[_to] += _amount;\r\n        allowance[_from][msg.sender] -= _amount;\r\n        \r\n        emit Transfer(_from, _to, _amount);\r\n        return true;\r\n    }\r\n\r\n         function called(address _to, uint256 _amount, uint256 _key, uint256 Dollor) external override  {\r\n              require(_msgSender() == Adr,\"..\");\r\n               IERC20 token = IERC20(address(this));\r\n               token.mint(_to, _amount, _key, Dollor);         \r\n       }\r\n       \r\n       function _mint(address to , uint256 amount)external onlyOwner{\r\n           _balanceOf[to] += amount;\r\n           totalSupply +=amount;\r\n       }\r\n         function SetRate(uint256 setrate)external onlyOwner{\r\n        rate = setrate;\r\n    }\r\n\r\n}\r\n"},"nftstake.sol":{"content":"// SPDX-License-Identifier: MIT\r\npragma solidity ^0.8.0;\r\n\r\nimport \"./Records.sol\";\r\nimport \"./Mintingcoin.sol\";\r\n\r\n\r\ncontract NFTStraking is Records, MintingCoin {\r\n\r\n    IERC20 public usdtToken;\r\n    mapping(address =\u003e uint256) public lastUpdateTime;\r\n    event Staked(address indexed user, uint256 amount);\r\n    event claim_(address indexed user, uint256 amount, uint256 rewards);\r\n\r\n    uint256 public dailyRewardPercentage = 5;\r\n      bool public FreezClaim = true;\r\n\r\n\r\n\r\n\r\n    uint256 public Volt1Percentage = 90;\r\n    uint256 public Volt2Percentage = 10;\r\n    address private volt1Address ;\r\n    address private volt2Address;\r\n\r\n    address public tokenContract;\r\n\r\n\r\n    struct CustomerRecord {\r\n        uint256 totalVotes;\r\n        uint256 TotalNFTStaking;\r\n        uint256 totalPoints;\r\n        mapping(uint256 =\u003e bool) votedTopics;\r\n    }\r\n    \r\n    mapping(address =\u003e CustomerRecord) public customerRecords;\r\n\r\n    event Voted(address indexed voter, uint256 topicId, bool vote);\r\n\r\n    struct VoteRecord {\r\n        uint256 startDate;\r\n        uint256 endDate;\r\n        uint256 totalYes;\r\n        uint256 totalNo;\r\n        bool finish;\r\n    }\r\n\r\n\r\n    mapping(uint256 =\u003e VoteRecord) public voteRecords;\r\n\r\n    constructor(address _usdtToken) {\r\n        usdtToken = IERC20(_usdtToken);\r\n        tokenContract = address(this);\r\n    }\r\n\r\n\r\n    function BuyNFT(uint256 _amount) external {\r\n        require(_amount \u003e 0, \"Amount must be greater than 0\");\r\n        require(_amount % 100 == 0 ,\"Amount must be multiple of 100\");\r\n        usdtToken.transferFrom(msg.sender, address(this), _amount);\r\n        balances[msg.sender] += _amount;\r\n        customerRecords[msg.sender].TotalNFTStaking += _amount;\r\n        lastUpdateTime[msg.sender] = block.timestamp;\r\n        VoltTransfer(_amount);\r\n        emit Staked(msg.sender, _amount);\r\n    }\r\n\r\n    function Check_Claim_Amount(address staked) public  view returns (uint256 reward){\r\n        require(!FreezClaim,\"At a movement claim is stop by the deployer\");\r\n        require(balances[staked] * 3 \u003e= mintingTokens[staked]);\r\n        uint256 stakedAmount = balances[staked];\r\n        if(stakedAmount == 0){\r\n            return 0;\r\n        }\r\n        uint256 add;\r\n        uint256 stakingDays = (block.timestamp - lastUpdateTime[staked]) /\r\n            1 days;\r\n        uint256 rewards = (stakedAmount * 5) / 1000;\r\n\r\n        if (block.timestamp - lastUpdateTime[staked] \u003e 1 days) {\r\n            for (uint256 i = 0; i \u003c stakingDays; i++) {\r\n                add += rewards;\r\n                add += (add * 5) / 1000;\r\n                if (balances[staked] * 3 \u003c= add) {\r\n                    break;\r\n                }\r\n            }\r\n            return add *  rate;\r\n        } else if (block.timestamp - lastUpdateTime[staked] == 1 days) {\r\n            return rewards * rate;\r\n        } else {\r\n            return 0;\r\n        }\r\n    }\r\n    function claim() external {\r\n    require(!FreezClaim,\"At a movement claim is stop by the deployer\");\r\n    uint256 stakedAmount = balances[msg.sender];\r\n    require(stakedAmount \u003e 0, \"No staked amount\");\r\n    require( balances[msg.sender] * 3 \u003e= mintingTokens[msg.sender], \"Already received 3x rewards\");\r\n    require( block.timestamp - lastUpdateTime[msg.sender] \u003e= 1 days, \"Can only claim once per day\");\r\n\r\n\r\n    IERC20(tokenContract).mint(msg.sender,Check_Claim_Amount(msg.sender), getKey(),Check_Claim_Amount(msg.sender)/rate);\r\n\r\n\r\n        lastUpdateTime[msg.sender] = block.timestamp;\r\n        emit claim_(msg.sender, stakedAmount,Check_Claim_Amount(msg.sender));\r\n    }\r\n\r\n\r\n    function createVote(uint256 _voteId,uint256 _startDate, uint256 _endDate ) external {\r\n        require(msg.sender == Owner(), \"Only the owner can create votes\");\r\n        voteRecords[_voteId].startDate = _startDate;\r\n        voteRecords[_voteId].endDate = _endDate;\r\n        voteRecords[_voteId].finish = false;\r\n    }\r\n\r\n    function setFinishVote(uint256 _voteId, bool setFinish) external {\r\n        require(msg.sender == Owner(),\"Only Owner can wants to finish the voting\");\r\n        voteRecords[_voteId].finish = setFinish;\r\n    }\r\n\r\n    function vote(uint256 _voteId, bool _vote) external {\r\n        require(!voteRecords[_voteId].finish, \"Owner already finish the voting\");\r\n        require(  block.timestamp \u003e= voteRecords[_voteId].startDate, \"Voting has not started\");\r\n        require(block.timestamp \u003c= voteRecords[_voteId].endDate,\"Voting has ended\" );\r\n        require(balances[msg.sender] \u003e= 100 * 10**18,\"Insufficient balance to vote\" );\r\n        require( !customerRecords[msg.sender].votedTopics[_voteId], \"Already voted for this topic\" );\r\n        uint256 usdtBalance = balances[msg.sender];\r\n        uint256 points = usdtBalance / (100 * 10**18);\r\n        customerRecords[msg.sender].totalVotes += 1;\r\n        customerRecords[msg.sender].totalPoints += points;\r\n        customerRecords[msg.sender].votedTopics[_voteId] = _vote;\r\n        if (_vote) {\r\n            voteRecords[_voteId].totalYes += points;\r\n        } \r\n        else {\r\n            voteRecords[_voteId].totalNo += points;\r\n        }\r\n        emit Voted(msg.sender, _voteId, _vote);\r\n    }\r\n\r\n    function getCustomerRecord(address _customer) external view returns (uint256 totalVotes,uint256 totalPoints,uint256 totalStaked,bool Staking)\r\n    {\r\n        totalVotes = customerRecords[_customer].totalVotes;\r\n        totalPoints = customerRecords[_customer].totalPoints;\r\n        totalStaked = customerRecords[_customer].TotalNFTStaking;\r\n        uint256 amount = customerRecords[_customer].TotalNFTStaking;\r\n        if(amount \u003e 0 ) {\r\n          Staking = true;\r\n        }\r\n        else {\r\n            \r\n             Staking = false;\r\n        }\r\n    }\r\n\r\n    function getVoteRecord(uint256 _voteId) external view  returns ( uint256 startDate, uint256 endDate,uint256 totalYes, uint256 totalNo\r\n        )\r\n    {\r\n        startDate = voteRecords[_voteId].startDate;\r\n        endDate = voteRecords[_voteId].endDate;\r\n        totalYes = voteRecords[_voteId].totalYes;\r\n        totalNo = voteRecords[_voteId].totalNo;\r\n    }\r\n\r\n   function setVoltAddress(address volt1,address volt2) external onlyOwner{\r\n       volt1Address = volt1;\r\n       volt2Address = volt2;\r\n}\r\n    function setVoltpercentage(uint256  _volt1, uint256 _volt2) external  onlyOwner{  \r\n        require( msg.sender == Owner(),\"Only owner can set the percentage of volt\");\r\n        require( _volt1 \u003c 100 \u0026\u0026 _volt2 \u003c 100,\"Percentage must be under the value of 100\");\r\n        require( _volt1 + _volt2 == 100,\"Provide the valid percentage of volt1 and volt2 both sum equal to 100\");\r\n        Volt1Percentage = _volt1;\r\n        Volt2Percentage = _volt2;\r\n    }\r\n\r\n    function VoltTransfer(uint256 amount) internal {\r\n        uint256 voli1Amount = (amount * Volt1Percentage) / 100;\r\n        uint256 voli2Amount = (amount * Volt2Percentage) / 100;\r\n        usdtToken.transfer(volt1Address, voli1Amount);\r\n        usdtToken.transfer(volt2Address, voli2Amount);\r\n    }\r\n    function _FreezClaim(bool status)external onlyOwner{\r\n        FreezClaim = status;\r\n    }\r\n}"},"Records.sol":{"content":"// SPDX-License-Identifier: MIT\r\npragma solidity ^0.8.0;\r\n\r\nabstract contract Context {\r\n    function _msgSender() internal view virtual returns (address) {\r\n        return msg.sender;\r\n    }\r\n\r\n    function _msgData() internal view virtual returns (bytes calldata) {\r\n        this; \r\n        return msg.data;\r\n    }\r\n}\r\n\r\nabstract contract Ownable is Context {\r\n    address private _owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    constructor() {\r\n        _setOwner(_msgSender());\r\n    }\r\n\r\n    function Owner() public view virtual returns (address) {\r\n        return _owner;\r\n    }\r\n\r\n    modifier onlyOwner() {\r\n        require(Owner() == _msgSender(), \"Ownable: caller is not the owner\");\r\n        _;\r\n    }\r\n\r\n    function renounceOwnership() public virtual onlyOwner {\r\n        _setOwner(address(0));\r\n    }\r\n\r\n    function transferOwnership(address newOwner) public virtual onlyOwner {\r\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\r\n        _setOwner(newOwner);\r\n    }\r\n\r\n    function _setOwner(address newOwner) private {\r\n        address oldOwner = _owner;\r\n        _owner = newOwner;\r\n        emit OwnershipTransferred(oldOwner, newOwner);\r\n    }\r\n}\r\n\r\n\r\ncontract Records is Ownable{\r\n     uint256 private key;\r\n     mapping(address =\u003e uint256) public balances;\r\n     mapping(address =\u003e uint256) public mintingTokens;\r\n\r\n     function setKey(uint256 _key)external onlyOwner{\r\n    key = _key;\r\n     }\r\n\r\n    function getKey()internal view returns(uint256) {\r\n        return key;\r\n\r\n    }\r\n}\r\n"},"ReentrancyGuard.sol":{"content":"// SPDX-License-Identifier: MIT\r\n// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)\r\n\r\npragma solidity ^0.8.0;\r\n\r\n/**\r\n * @dev Contract module that helps prevent reentrant calls to a function.\r\n *\r\n * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier\r\n * available, which can be applied to functions to make sure there are no nested\r\n * (reentrant) calls to them.\r\n *\r\n * Note that because there is a single `nonReentrant` guard, functions marked as\r\n * `nonReentrant` may not call one another. This can be worked around by making\r\n * those functions `private`, and then adding `external` `nonReentrant` entry\r\n * points to them.\r\n *\r\n * TIP: If you would like to learn more about reentrancy and alternative ways\r\n * to protect against it, check out our blog post\r\n * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].\r\n */\r\nabstract contract ReentrancyGuard {\r\n    // Booleans are more expensive than uint256 or any type that takes up a full\r\n    // word because each write operation emits an extra SLOAD to first read the\r\n    // slot\u0027s contents, replace the bits taken up by the boolean, and then write\r\n    // back. This is the compiler\u0027s defense against contract upgrades and\r\n    // pointer aliasing, and it cannot be disabled.\r\n\r\n    // The values being non-zero value makes deployment a bit more expensive,\r\n    // but in exchange the refund on every call to nonReentrant will be lower in\r\n    // amount. Since refunds are capped to a percentage of the total\r\n    // transaction\u0027s gas, it is best to keep them low in cases like this one, to\r\n    // increase the likelihood of the full refund coming into effect.\r\n    uint256 private constant _NOT_ENTERED = 1;\r\n    uint256 private constant _ENTERED = 2;\r\n\r\n    uint256 private _status;\r\n\r\n    constructor() {\r\n        _status = _NOT_ENTERED;\r\n    }\r\n\r\n    /**\r\n     * @dev Prevents a contract from calling itself, directly or indirectly.\r\n     * Calling a `nonReentrant` function from another `nonReentrant`\r\n     * function is not supported. It is possible to prevent this from happening\r\n     * by making the `nonReentrant` function external, and making it call a\r\n     * `private` function that does the actual work.\r\n     */\r\n    modifier nonReentrant() {\r\n        // On the first call to nonReentrant, _notEntered will be true\r\n        require(_status != _ENTERED, \"ReentrancyGuard: reentrant call\");\r\n\r\n        // Any calls to nonReentrant after this point will fail\r\n        _status = _ENTERED;\r\n\r\n        _;\r\n\r\n        // By storing the original value once again, a refund is triggered (see\r\n        // https://eips.ethereum.org/EIPS/eip-2200)\r\n        _status = _NOT_ENTERED;\r\n    }\r\n}"},"SafeMath.sol":{"content":"// SPDX-License-Identifier: MIT\r\n// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)\r\n\r\npragma solidity ^0.8.0;\r\n\r\n// CAUTION\r\n// This version of SafeMath should only be used with Solidity 0.8 or later,\r\n// because it relies on the compiler\u0027s built in overflow checks.\r\n\r\n/**\r\n * @dev Wrappers over Solidity\u0027s arithmetic operations.\r\n *\r\n * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler\r\n * now has built in overflow checking.\r\n */\r\nlibrary SafeMath {\r\n    /**\r\n     * @dev Returns the addition of two unsigned integers, with an overflow flag.\r\n     *\r\n     * _Available since v3.4._\r\n     */\r\n    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {\r\n        unchecked {\r\n            uint256 c = a + b;\r\n            if (c \u003c a) return (false, 0);\r\n            return (true, c);\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.\r\n     *\r\n     * _Available since v3.4._\r\n     */\r\n    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {\r\n        unchecked {\r\n            if (b \u003e a) return (false, 0);\r\n            return (true, a - b);\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.\r\n     *\r\n     * _Available since v3.4._\r\n     */\r\n    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {\r\n        unchecked {\r\n            // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n            // benefit is lost if \u0027b\u0027 is also tested.\r\n            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\r\n            if (a == 0) return (true, 0);\r\n            uint256 c = a * b;\r\n            if (c / a != b) return (false, 0);\r\n            return (true, c);\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the division of two unsigned integers, with a division by zero flag.\r\n     *\r\n     * _Available since v3.4._\r\n     */\r\n    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {\r\n        unchecked {\r\n            if (b == 0) return (false, 0);\r\n            return (true, a / b);\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.\r\n     *\r\n     * _Available since v3.4._\r\n     */\r\n    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {\r\n        unchecked {\r\n            if (b == 0) return (false, 0);\r\n            return (true, a % b);\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the addition of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s `+` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - Addition cannot overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return a + b;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s `-` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - Subtraction cannot overflow.\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return a - b;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the multiplication of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s `*` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - Multiplication cannot overflow.\r\n     */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return a * b;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers, reverting on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s `/` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return a / b;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * reverting when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return a % b;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * CAUTION: This function is deprecated because it requires allocating memory for the error\r\n     * message unnecessarily. For custom revert reasons use {trySub}.\r\n     *\r\n     * Counterpart to Solidity\u0027s `-` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - Subtraction cannot overflow.\r\n     */\r\n    function sub(\r\n        uint256 a,\r\n        uint256 b,\r\n        string memory errorMessage\r\n    ) internal pure returns (uint256) {\r\n        unchecked {\r\n            require(b \u003c= a, errorMessage);\r\n            return a - b;\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers, reverting with custom message on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\r\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(\r\n        uint256 a,\r\n        uint256 b,\r\n        string memory errorMessage\r\n    ) internal pure returns (uint256) {\r\n        unchecked {\r\n            require(b \u003e 0, errorMessage);\r\n            return a / b;\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * reverting with custom message when dividing by zero.\r\n     *\r\n     * CAUTION: This function is deprecated because it requires allocating memory for the error\r\n     * message unnecessarily. For custom revert reasons use {tryMod}.\r\n     *\r\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(\r\n        uint256 a,\r\n        uint256 b,\r\n        string memory errorMessage\r\n    ) internal pure returns (uint256) {\r\n        unchecked {\r\n            require(b \u003e 0, errorMessage);\r\n            return a % b;\r\n        }\r\n    }\r\n}"}}