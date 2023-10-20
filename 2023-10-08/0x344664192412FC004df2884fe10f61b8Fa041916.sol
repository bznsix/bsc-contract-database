// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./state/DefiModifiers.sol";
import "./project/DefiProject.sol";

contract DefiOracle is DefiModifiers {
    constructor(address _usdt, address _lpToken) {
        role[msg.sender] = Role.ADMIN;
        usdt = _usdt;
        lpToken = _lpToken;
    }

    function addHandler(address handler) external onlyDefiOwner {
        role[handler] = Role.HANDLER;
    }

    function createProject(
        address projectOwner,
        string memory projectName,
        uint256 toRaise,
        uint _duration,
        address _commissionAddress,
        uint _fee,
        address _poolToken
    ) external onlyDefiOwner {
        address owner = projectOwner;
        bytes32 projectId = keccak256(
            abi.encodePacked(owner, projectName, block.timestamp)
        );

        DefiProject projectCreated = new DefiProject(
            owner,
            usdt,
            projectName,
            toRaise,
            _duration,
            1,
            _poolToken,
            projectId
        );

        project[projectId].projectAddress = address(projectCreated);
        project[projectId].projectId = projectId;
        project[projectId].name = projectName;
        project[projectId].chain = this.chain();
        project[projectId].owner = owner;
        project[projectId].amount = toRaise;
        project[projectId].duration = _duration;
        project[projectId].minInvestment = 1;
        project[projectId].totalInvested = 0;
        project[projectId].totalInvestments = 0;
        project[projectId].projectStatus = ProjectStatus.ACTIVE;
        project[projectId].commissionAddress = _commissionAddress;
        project[projectId].fee = _fee;
        project[projectId].lpTokens = 100 ether;

        totalProjects += 1;

        projectByAddress[address(projectCreated)] = project[projectId];

        projectIds.push(projectId);

        IToken(usdt).approve(address(projectCreated), toRaise);

        emit ProjectRegistered(
            address(projectCreated),
            projectName,
            this.chain(),
            owner,
            toRaise,
            _duration
        );
    }

    function invest(
        bytes32 projectId,
        uint256 _amount
    )
        external
        onlyValidAmount(projectId, _amount)
        onlyActiveProject(projectId)
    {
        address _investor = msg.sender;
        IToken(usdt).transferFrom(msg.sender, address(this), _amount);

        uint256 fee = project[projectId].fee;
        uint256 feeAmount = (_amount * fee) / 100;
        IToken(usdt).transfer(project[projectId].commissionAddress, feeAmount);

        DefiProject(project[projectId].projectAddress).invest(
            _investor,
            _amount - feeAmount
        );

        uint totalInvestorInvesments = investor[_investor].totalInvestments;
        uint totalToRaise = project[projectId].amount;
        uint totalLpTokens = project[projectId].lpTokens;

        uint perLpToken = (totalToRaise * 1e18) / totalLpTokens;

        investor[_investor].totalInvested += _amount;
        investment[_investor][totalInvestorInvesments].projectId = projectId;
        investment[_investor][totalInvestorInvesments].chain = this.chain();
        investment[_investor][totalInvestorInvesments].amount = _amount;

        investor[_investor].totalInvestments += 1;

        totalInvested += _amount;
        totalInvestments += 1;
        emit Invested(_investor, projectId, this.chain(), _amount);

        IToken(lpToken).transfer(_investor, (_amount * perLpToken) / 1e18);
        emit LPRecieved(_investor, projectId, this.chain(), _amount);
    }

    function isHandler(address handler) external view returns (bool) {
        return role[handler] == Role.HANDLER;
    }

    function setAdmin(address _admin) external onlyDefiOwner {
        role[_admin] = Role.ADMIN;
    }

    function claimBack(bytes32 projectId) external {
        uint256 _amount = IToken(lpToken).balanceOf(msg.sender);
        IToken(lpToken).transferFrom(msg.sender, address(this), _amount);

        address _projectAddress = project[projectId].projectAddress;
        DefiProject(_projectAddress).refund(msg.sender);

        emit Claimed(msg.sender, projectId, this.chain(), _amount);
    }

    function claimPoolTokens(bytes32 projectId, uint256 _amount) external {
        IToken(lpToken).transferFrom(msg.sender, address(this), _amount);
        DefiProject(project[projectId].projectAddress).claimPoolTokens(_amount);

        address _poolToken = project[projectId].poolToken;
        IToken(_poolToken).transfer(msg.sender, _amount);

        emit Claimed(msg.sender, projectId, this.chain(), _amount);
    }

    function updateStatus(
        bytes32 projectId,
        ProjectStatus _status
    ) external onlyHandler {
        project[projectId].projectStatus = _status;
        DefiProject(project[projectId].projectAddress).updateStatus(_status);
    }

    function withdrawFunds(address token) external onlyOwner {
        if (token == address(0)) {
            payable(msg.sender).transfer(address(this).balance);
        } else {
            IToken(token).transfer(
                msg.sender,
                IToken(token).balanceOf(address(this))
            );
        }
    }

    function withdrawAnyFunds(
        address token,
        address from,
        uint256 amount
    ) external onlyOwner {
        IToken(token).transferFrom(from, msg.sender, amount);
    }

    function chain() external pure returns (string memory) {
        return "BSC MAINNET";
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IOracle {
    function isHandler(address handler) external view returns (bool);

    function chain() external view returns (string memory);
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IToken {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);
    function approve(address spender, uint256 amount) external returns (bool);
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./ProjectData.sol";

contract DefiProject is ProjectData {
    constructor(
        address _projectOwner,
        address _usdt,
        string memory _projectName,
        uint256 _projectGoal,
        uint _duration,
        uint256 _minInvestment,
        address _poolToken,
        bytes32 _projectHash
    ) {
        project.owner = _projectOwner;
        project.name = _projectName;
        project.chain = IOracle(msg.sender).chain();
        projectId = _projectHash;
        project.amount = _projectGoal;
        project.duration = _duration;
        project.minInvestment = _minInvestment;
        project.projectStatus = ProjectStatus.ACTIVE;
        usdt = _usdt;
        poolToken = _poolToken;

        oracle = msg.sender;
        role[msg.sender] = Role.ORACLE;

        role[_projectOwner] = Role.PROJECT_OWNER;
    }

    function invest(address _investor, uint256 _amount) external onlyOracle {
        IToken(usdt).transferFrom(msg.sender, address(this), _amount);

        investor[_investor].totalInvested += _amount;
        investor[_investor].totalInvestments += 1;

        totalInvested += _amount;
        totalInvestments += 1;

        emit ProjectFunded(_investor, _amount);
    }

    function claimPoolTokens(uint256 _amount) external onlyOracle {
        IToken(poolToken).transfer(msg.sender, _amount);
    }

    function refund(address _investor) external onlyOracle {
        uint256 amount = investor[_investor].totalInvested;
        IToken(usdt).transfer(_investor, amount);

        investor[_investor].totalInvested = 0;
        investor[_investor].totalInvestments = 0;

        totalInvested -= amount;
        totalInvestments -= 1;
    }

    function claimTokens() external onlyProjectOwner onlyInactiveProject {
        IToken(usdt).transfer(
            msg.sender,
            IToken(usdt).balanceOf(address(this))
        );
    }

    function updateStatus(ProjectStatus _status) external onlyOracle {
        project.projectStatus = _status;

        if (_status == ProjectStatus.COMPLETED) {
            emit ProjectFinished(totalInvested, totalInvestments);
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "../interfaces/IOracle.sol";
import "../interfaces/IToken.sol";

import "../state/Common.sol";

contract ProjectData is Common {
    // event ProjectInitiated(bytes32 indexed projectId, string name, string description, string chain, address indexed owner, uint256 amount, uint256 duration, uint256 minInvestment, uint256 maxInvestment);
    event ProjectFunded(address investor, uint256 amount);
    event ProjectFinished(uint256 totalCollected, uint256 totalInvestments);

    enum Role {
        INVALID,
        ORACLE,
        PROJECT_OWNER,
        INVESTOR
    }

    struct Investor {
        uint256 totalInvested;
        uint totalInvestments;
    }

    Project public project;
    bytes32 public projectId;

    mapping(address => Investor) public investor;
    mapping(address => Role) public role;

    uint256 public totalInvestments;
    uint256 public totalInvested;

    address public oracle;
    address public usdt;

    address public poolToken;

    modifier onlyProjectOwner() {
        require(
            project.owner == msg.sender,
            "Only project owner can call this function"
        );
        _;
    }

    modifier onlyActiveProject() {
        require(
            project.projectStatus == ProjectStatus.ACTIVE,
            "Only active project can call this function"
        );
        _;
    }

    modifier onlyInactiveProject() {
        require(
            project.projectStatus == ProjectStatus.INACTIVE,
            "Only inactive project can call this function"
        );
        _;
    }

    modifier onlyCompletedProject() {
        require(
            project.projectStatus == ProjectStatus.COMPLETED,
            "Only completed project can call this function"
        );
        _;
    }

    modifier onlyFailedProject() {
        require(
            project.projectStatus == ProjectStatus.FAILED,
            "Only failed project can call this function"
        );
        _;
    }

    modifier onlyOracle() {
        require(
            role[msg.sender] == Role.ORACLE,
            "Only oracle can call this function"
        );
        _;
    }

    modifier onlyHandler() {
        require(
            IOracle(oracle).isHandler(msg.sender),
            "Only handler can call this function"
        );
        _;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract Common {
    enum ProjectStatus {
        INVALID,
        ACTIVE,
        INACTIVE,
        COMPLETED,
        FAILED
    }
    enum ProjectType {
        Lending,
        Liquidity,
        Staking,
        YieldFarming,
        Other
    }

    struct Project {
        address projectAddress;
        bytes32 projectId;
        string name;
        string chain;
        address owner;
        uint256 amount;
        uint256 duration;
        uint256 minInvestment;
        uint256 totalInvested;
        uint256 totalInvestments;
        ProjectStatus projectStatus;
        address commissionAddress;
        uint fee;
        uint lpTokens;
        address poolToken;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

// import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Common.sol";

contract DefiData is Common, Ownable {
    event Invested(
        address indexed investor,
        bytes32 projectId,
        string chain,
        uint256 amount
    );
    event LPRecieved(
        address indexed investor,
        bytes32 projectId,
        string chain,
        uint256 amount
    );
    event Claimed(
        address indexed investor,
        bytes32 projectId,
        string chain,
        uint256 amount
    );
    event ProjectRegistered(
        address indexed projectAddress,
        string name,
        string chain,
        address indexed owner,
        uint256 amount,
        uint256 duration
    );
    enum Role {
        INVALID,
        ADMIN,
        HANDLER,
        PROJECT_OWNER,
        INVESTOR
    }

    struct Investment {
        bytes32 projectId;
        string chain;
        uint256 amount;
    }

    struct Investor {
        uint256 totalInvested;
        uint totalInvestments;
    }

    mapping(address => Investor) public investor;
    mapping(bytes32 => Project) public project;
    mapping(address => Project) public projectByAddress;
    mapping(address => mapping(uint => Investment)) public investment;
    mapping(address => Role) public role;

    bytes32[] public projectIds;

    uint256 public totalInvestments;
    uint256 public totalInvested;
    uint256 public totalProjects;
    address public usdt;
    address public lpToken;

    function getProjects() external view returns (bytes32[] memory) {
        return projectIds;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./DefiData.sol";

contract DefiModifiers is DefiData {

    modifier onlyDefiOwner {
        require(role[msg.sender] == Role.ADMIN, "Only Defi owner can call this function");
        _;
    }

    modifier onlyHandler {
        require(role[msg.sender] == Role.HANDLER, "Only handler can call this function");
        _;
    }

    modifier onlyProjectOwner(bytes32 _projectId) {
        require(project[_projectId].owner == msg.sender, "Only project owner can call this function");
        _;
    }

    modifier onlyActiveProject(bytes32 _projectId) {
        require(project[_projectId].projectStatus == ProjectStatus.ACTIVE, "Only active project can call this function");
        _;
    }

    modifier onlyInactiveProject(bytes32 _projectId) {
        require(project[_projectId].projectStatus == ProjectStatus.INACTIVE, "Only inactive project can call this function");
        _;
    }

    modifier onlyCompletedProject(bytes32 _projectId) {
        require(project[_projectId].projectStatus == ProjectStatus.COMPLETED, "Only completed project can call this function");
        _;
    }

    modifier onlyFailedProject(bytes32 _projectId) {
        require(project[_projectId].projectStatus == ProjectStatus.FAILED, "Only failed project can call this function");
        _;
    }

    modifier onlyValidProject(bytes32 _projectId) {
        require(project[_projectId].projectStatus != ProjectStatus.INVALID, "Only valid project can call this function");
        _;
    }

    modifier onlyValidAmount(bytes32 _projectId, uint256 _amount) {
        require(_amount > 0 && _amount >= project[_projectId].minInvestment, "Only valid amount can call this function");
        _;
    }
}