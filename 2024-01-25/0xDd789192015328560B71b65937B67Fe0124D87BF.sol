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
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
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
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Dividend is Ownable {

    address public USDT = 0x55d398326f99059fF775485246999027B3197955;
    
    uint256 public totalWholeMember;
    uint256 public totalPresidentMember;
    uint256 public totalDirectorMember;
    uint256 public totalBossMember;

    uint256 public wholeCurrent;
    uint256 public shareholderCurrent;

    mapping(address => uint256) public wholeWhiteList;
    mapping(address => uint256) public presidentWhiteList;
    mapping(address => uint256) public directorWhiteList;
    mapping(address => uint256) public bossWhiteList;    

    mapping(uint256 => mapping(address => bool)) public wholeClaimMap;
    mapping(uint256 => mapping(address => bool)) public presidentClaimMap;
    mapping(uint256 => mapping(address => bool)) public directorClaimMap;
    mapping(uint256 => mapping(address => bool)) public bossClaimMap;


    mapping(uint256 => uint256) public wholeCurrentTotalMember;
    mapping(uint256 => uint256) public presidentCurrentTotalMember;
    mapping(uint256 => uint256) public directorCurrentTotalMember;
    mapping(uint256 => uint256) public bossCurrentTotalMember;

    mapping(uint256 => uint256) public wholeCurrentAmount;
    mapping(uint256 => uint256) public presidentCurrentAmount;
    mapping(uint256 => uint256) public diretorCurrentAmount;
    mapping(uint256 => uint256) public bossCurrentAmount;

    uint256 public wholeRemainAsset;
    uint256 public presidentRemainAsset;
    uint256 public directorRemainAsset;
    uint256 public bossRemainAsset;

    uint256 public totalWholeClaimed;
    uint256 public totalPresidentClaimed;
    uint256 public totalDirectorClaimed;
    uint256 public totalBossClaimed;

    address public mstContract;

    mapping(address => uint256) public wholeClaimedMap;
    uint256 public maxWholeAmount = 200 ether;

    function setMaxWholeAmount(uint256 _amount) external onlyOwner {
        maxWholeAmount = _amount;
    }

    function setMstContract(address _contract) external onlyOwner {
        mstContract = _contract;
    }

    function addMember(address _member, uint256 _level) external {
        require(msg.sender == mstContract, "error");
        if (_level <= 6 && wholeWhiteList[_member] == 0) {
            wholeClaimMap[wholeCurrent][_member] = true;
            wholeWhiteList[_member] = 1;
            totalWholeMember += 1;
        } else if(_level == 7 && presidentWhiteList[_member] == 0) {
            presidentClaimMap[shareholderCurrent][_member] = true;
            presidentWhiteList[_member] = 1;
            totalPresidentMember += 1;
        } else if (_level == 8 && directorWhiteList[_member] == 0) {
            presidentWhiteList[_member] = 0;
            totalPresidentMember -= 1;
            directorClaimMap[shareholderCurrent][_member] = true;
            directorWhiteList[_member] = 1;
            totalDirectorMember += 1;
        } else if (_level == 9 && bossWhiteList[_member] == 0) {
            directorWhiteList[_member] = 0;
            totalDirectorMember -= 1;
            bossClaimMap[shareholderCurrent][_member] = true;
            bossWhiteList[_member] = 1;
            totalBossMember += 1;
        }
    }

    function addMemberByAdmin(address _member, uint256  _level) external onlyOwner {
        if (_level <= 6 && wholeWhiteList[_member] != 1) {
            wholeClaimMap[shareholderCurrent][_member] = true;
            wholeWhiteList[_member] = 1;
            totalWholeMember += 1;
        } else if(_level == 7 && presidentWhiteList[_member] != 1) {
            presidentClaimMap[shareholderCurrent][_member] = true;
            presidentWhiteList[_member] = 1;
            totalPresidentMember += 1;
        } else if (_level == 8 && directorWhiteList[_member] != 1) {
            directorClaimMap[shareholderCurrent][_member] = true;
            directorWhiteList[_member] = 1;
            totalDirectorMember += 1;
        } else if (_level == 9 && bossWhiteList[_member] != 1) {
            bossClaimMap[shareholderCurrent][_member] = true;
            bossWhiteList[_member] = 1;
            totalBossMember += 1;
        }
    }

    function removeMemberFromShareholderByAdmin(address _member) external onlyOwner {
        if (presidentWhiteList[_member] == 1) {
            presidentWhiteList[_member] = 2;
            totalPresidentMember -= 1;
        } else if (directorWhiteList[_member] == 1) {
            directorWhiteList[_member] = 2;
            totalDirectorMember -= 1;
        } else if (bossWhiteList[_member] == 1) {
            bossWhiteList[_member] = 2;
            totalBossMember -= 1;
        }
    }

    function removeMemberFromWholeByAdmin(address _member) external onlyOwner {
        if (wholeWhiteList[_member] == 1) {
            wholeWhiteList[_member] = 2;
            totalWholeMember -= 1;
        }
    }

    function shareholderDividend(uint256 _presidentAmount, uint256 _directorAmount, uint256 _bossAmount) external onlyOwner {
        shareholderCurrent += 1;
        presidentCurrentTotalMember[shareholderCurrent] = totalPresidentMember;
        directorCurrentTotalMember[shareholderCurrent] = totalDirectorMember;
        bossCurrentTotalMember[shareholderCurrent] = totalBossMember;
        presidentCurrentAmount[shareholderCurrent] = presidentRemainAsset + _presidentAmount;
        diretorCurrentAmount[shareholderCurrent] = directorRemainAsset + _directorAmount;
        bossCurrentAmount[shareholderCurrent] = bossRemainAsset + _bossAmount;
        presidentRemainAsset += _presidentAmount;
        directorRemainAsset += _directorAmount;
        bossRemainAsset += _bossAmount;
        IERC20(USDT).transferFrom(msg.sender, address(this), _presidentAmount + _directorAmount + _bossAmount);
    }

    function renounceShareholderDividend() external onlyOwner {
        shareholderCurrent += 1;
        presidentCurrentTotalMember[shareholderCurrent] = totalPresidentMember;
        directorCurrentTotalMember[shareholderCurrent] = totalDirectorMember;
        bossCurrentTotalMember[shareholderCurrent] = totalBossMember;
        presidentCurrentAmount[shareholderCurrent] = 0;
        diretorCurrentAmount[shareholderCurrent] = 0;
        bossCurrentAmount[shareholderCurrent] = 0;
        IERC20(USDT).transfer(msg.sender, presidentRemainAsset + directorRemainAsset + bossRemainAsset);
        presidentRemainAsset = 0;
        directorRemainAsset = 0;
        bossRemainAsset = 0;
    }

    function wholeDividend(uint256 _wholeAmount) external onlyOwner {
        wholeCurrent += 1;
        wholeCurrentTotalMember[wholeCurrent] = totalWholeMember;
        wholeCurrentAmount[wholeCurrent] = wholeRemainAsset + _wholeAmount;
        wholeRemainAsset += _wholeAmount;
        IERC20(USDT).transferFrom(msg.sender, address(this), _wholeAmount);
    }

    function renounceWholeDividend() external onlyOwner {
        wholeCurrent += 1;
        wholeCurrentTotalMember[wholeCurrent] = totalWholeMember;
        wholeCurrentAmount[wholeCurrent] = 0;
        IERC20(USDT).transfer(msg.sender, wholeRemainAsset);
        wholeRemainAsset = 0;
    }

    function claimWholeDividend() external {
        require(wholeWhiteList[msg.sender] == 1, "error");
        require(!wholeClaimMap[wholeCurrent][msg.sender], "error");
        require(wholeClaimedMap[msg.sender] < maxWholeAmount, "error");
        uint256 amount = wholeCurrentAmount[wholeCurrent] / wholeCurrentTotalMember[wholeCurrent];
        wholeClaimMap[wholeCurrent][msg.sender] = true;
        require(wholeRemainAsset >= amount);
        wholeRemainAsset -= amount;
        wholeClaimedMap[msg.sender] += amount;
        totalWholeClaimed += amount;
        IERC20(USDT).transfer(msg.sender, amount);
    }

    function claimPresidentDividend() external {
        require(presidentWhiteList[msg.sender] == 1, "error");
        require(!presidentClaimMap[shareholderCurrent][msg.sender], "error");
        uint256 amount = presidentCurrentAmount[shareholderCurrent] / presidentCurrentTotalMember[shareholderCurrent];
        presidentClaimMap[shareholderCurrent][msg.sender] = true;
        require(presidentRemainAsset >= amount);
        presidentRemainAsset -= amount;
        totalPresidentClaimed += amount;
        IERC20(USDT).transfer(msg.sender, amount);
    }

    function claimDirectorDividend() external {
        require(directorWhiteList[msg.sender] == 1, "error");
        require(!directorClaimMap[shareholderCurrent][msg.sender], "error");
        uint256 amount = diretorCurrentAmount[shareholderCurrent] / directorCurrentTotalMember[shareholderCurrent];
        directorClaimMap[shareholderCurrent][msg.sender] = true;
        require(directorRemainAsset >= amount);
        directorRemainAsset -= amount;
        totalDirectorClaimed += amount;
        IERC20(USDT).transfer(msg.sender, amount);
    }

    function claimBossDividend() external {
        require(bossWhiteList[msg.sender] == 1, "error");
        require(!bossClaimMap[shareholderCurrent][msg.sender], "error");
        uint256 amount = bossCurrentAmount[shareholderCurrent] / bossCurrentTotalMember[shareholderCurrent];
        bossClaimMap[shareholderCurrent][msg.sender] = true;
        require(bossRemainAsset >= amount);
        bossRemainAsset -= amount;
        totalBossClaimed += amount;
        IERC20(USDT).transfer(msg.sender, amount);
    }

    function getWholeDividendAmount(address _receiver) external  view returns (uint256 amount){
        if (wholeWhiteList[_receiver] == 1 && !wholeClaimMap[wholeCurrent][_receiver]) {
            amount = wholeCurrentAmount[wholeCurrent] / wholeCurrentTotalMember[wholeCurrent];
        } else {
            amount = 0;
        }
    }

    function getPresidentDividendAmount(address _receiver) external  view returns (uint256 amount){
        if (presidentWhiteList[_receiver] == 1 && !presidentClaimMap[shareholderCurrent][_receiver]) {
            amount = presidentCurrentAmount[shareholderCurrent] / presidentCurrentTotalMember[shareholderCurrent];
        } else {
            amount = 0;
        }
    }
    function getDirectorDividendAmount(address _receiver) external  view returns (uint256 amount){
        if (directorWhiteList[_receiver] == 1 && !directorClaimMap[shareholderCurrent][_receiver]) {
            amount = diretorCurrentAmount[shareholderCurrent] / directorCurrentTotalMember[shareholderCurrent];
        } else {
            amount = 0;
        }
    }
    function getBossDividendAmount(address _receiver) external  view returns (uint256 amount){
        if (bossWhiteList[_receiver] == 1 && !bossClaimMap[shareholderCurrent][_receiver]) {
            amount = bossCurrentAmount[shareholderCurrent] / bossCurrentTotalMember[shareholderCurrent];
        } else {
            amount = 0;
        }
    }

    function withdrawToken(address token) external onlyOwner {
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }

    function setUSDT(address _usdt) external onlyOwner {
        USDT = _usdt;
    }
}