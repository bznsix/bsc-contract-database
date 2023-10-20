// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

abstract contract Context {

    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

import "./Context.sol";

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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

    function waiveOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

error ShuffleIdMaxAmountMissmatch();
error ShuffleIdMaxAmountExceed();

/// @notice Library to get pseudo random number and get shuffled token Ids
library ShuffleId {
    using ShuffleId for IdMatrix;

    struct IdMatrix {
        uint256 _count;
        /// @dev The maximum count of tokens token tracker will hold.
        uint256 _max;
        // Used for random index assignment
        mapping(uint256 => uint256) _matrix;
    }

    function count(IdMatrix storage self) internal view returns (uint256) {
        return self._count;
    }
    function max(IdMatrix storage self) internal view returns (uint256) {
        return self._max;
    }


    /// Update the max supply for the collection
    /// @param supply the new token supply.
    /// @dev create additional token supply for this collection.
    function setMax(IdMatrix storage self, uint256 supply) internal {
        if (self._count >= supply) revert ShuffleIdMaxAmountMissmatch();
        self._max = supply;
    }

    /// @dev Randomly gets a new token ID and keeps track of the ones that are still available.
    /// @return the next token ID
    function next(IdMatrix storage self) internal returns (uint256) {
        if (self._count >= self._max) revert ShuffleIdMaxAmountExceed();
        uint256 maxIndex = self._max - self._count;
        uint256 random = diceRoll(maxIndex, self._count);

        uint256 value = 0;
        if (self._matrix[random] == 0) {
            // If this matrix position is empty, set the value to the generated random number.
            value = random;
        } else {
            // Otherwise, use the previously stored number from the matrix.
            value = self._matrix[random];
        }

        // If the last available tokenID is still unused...
        if (self._matrix[maxIndex - 1] == 0) {
            // ...store that ID in the current matrix position.
            self._matrix[random] = maxIndex - 1;
        } else {
            // ...otherwise copy over the stored number to the current matrix position.
            self._matrix[random] = self._matrix[maxIndex - 1];
        }
        self._count++;
        return value;
    }

    /// @dev Generate almost random number in range
    /// @return rundom number
    function diceRoll(uint256 range, uint256 seed) internal view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        msg.sender,
                        gasleft(),
                        seed,
                        // block.basefee,
                        block.coinbase,
                        block.difficulty,
                        block.gaslimit,
                        block.timestamp
                    )
                )
            ) % range;
    }
}
// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

import "./helpers/Ownable.sol";
import "./helpers/ShuffleId.sol";
import "./interfaces/IERC20.sol";

contract MashaGame is Ownable{

    mapping(address => address) public ref;
    mapping(address => uint256) public totalRefIncome;
    mapping(address => address[]) public refUsers;

    event GameFinish(address indexed _user, uint256 winAmount, uint256 number, uint256 bidResult);

    struct GameItem {
        address user;
        uint256 amount;
        uint256 targetNumber;
        uint256 realNumber;
        uint256 winAMount;
    }

    IERC20 public token;

    struct PrizeRule {
        uint256 min;
        uint256 max;
        uint256 multiply;
    }

    PrizeRule[11] public rules;

    GameItem[] private games;

    uint256 private totalBids;
    address public deadAddress = 0x000000000000000000000000000000000000dEaD;

    constructor (address _token) {
        token = IERC20(_token);

        rules[0] = PrizeRule(0, 350, 0);
        rules[1] = PrizeRule(351, 480, 105);
        rules[2] = PrizeRule(481, 580, 110);
        rules[3] = PrizeRule(581, 650, 115);
        rules[4] = PrizeRule(651, 730, 120);
        rules[5] = PrizeRule(731, 800, 131);
        rules[6] = PrizeRule(801, 860, 140);
        rules[7] = PrizeRule(861, 910, 165);
        rules[8] = PrizeRule(911, 950, 170);
        rules[9] = PrizeRule(951, 980, 180);
        rules[10] = PrizeRule(981, 999, 200);

        ref[msg.sender] = msg.sender;
    }

    function getTotalGames() external view returns(uint256)
    {
        return games.length - 1;
    }

    function getBid(uint256 _number) external view returns(GameItem memory)
    {
        require(games.length - 1 >= _number, 'Error: out of bounds');
        return games[_number];
    }

    function bid(address inviter, uint256 _amount, uint256 _number) external {
        require(token.allowance(msg.sender, address(this)) >= _amount, 'Error: low allowance amount');
        require(token.balanceOf(msg.sender) >= _amount, 'Error: low balance');
        require(_number <= 10, 'Error: number to large');

        address _inviter;
        if (ref[msg.sender] == address(0)) {
            if (inviter == address(0)) {
                _inviter = owner();
            } else {
                ref[msg.sender] = inviter;
                refUsers[inviter].push(msg.sender);
                _inviter = inviter;
            }
        } else {
            _inviter = ref[msg.sender];
        }

        uint256 gameResult = _getPercent();

        if (gameResult < _number) {
            token.transferFrom(msg.sender, address(this), _amount);
            games.push(GameItem(msg.sender, _amount, _number, gameResult, 0));

            emit GameFinish(msg.sender, 0, _number, gameResult);
            return;
        }

        uint256 winAmount = _amount * rules[_number].multiply / 100;
        uint256 transferAmount = 0;
        games.push(GameItem(msg.sender, _amount, _number, gameResult, winAmount));

        if (winAmount > _amount) {
            transferAmount = winAmount - _amount;
            uint256 feeAmount = transferAmount * 5 / 100;

            _sendRef(_inviter, feeAmount);
            token.transfer(owner(), feeAmount);

            token.transfer(msg.sender, transferAmount - (2 * feeAmount));
        } else if (_amount > winAmount) {
            transferAmount = _amount - winAmount;
            token.transferFrom(msg.sender, address(this), transferAmount);
        }

        emit GameFinish(msg.sender, winAmount, _number, gameResult);
    }

    function _sendRef(address _inviter, uint256 _amount) internal {
        uint256 firstLine = _amount * 60 / 100;
        uint256 secondLine = _amount * 40 / 100;
        uint256 thirdLine = _amount - firstLine - secondLine;
        address inviter = _inviter;

        token.transfer(inviter, firstLine);
        totalRefIncome[inviter] += firstLine;

        inviter = _getInviter(inviter);
        token.transfer(inviter, secondLine);
        totalRefIncome[inviter] += secondLine;

        inviter = _getInviter(inviter);
        token.transfer(inviter, thirdLine);
        totalRefIncome[inviter] += secondLine;
    }

    function getUsers(address _user) external view returns(address[] memory) {
        return refUsers[_user];
    }

    function _getInviter(address user) internal view returns(address) {
        if (ref[user] == address(0)) {
            return owner();
        }
        return ref[user];
    }

    function _getPercent() internal returns(uint256)
    {
        totalBids++;
        uint256 random = uint256(ShuffleId.diceRoll(1000, totalBids));

        for (uint256 i = 0; i < rules.length; i ++) {
            if (random >= rules[i].min && random <= rules[i].max) {
                return i;
            }
        }
        return 0;
    }

    function updateRule(uint256 _number, uint256 _min, uint256 _max, uint256 _multiply) external onlyOwner
    {
        require(_number <= 10, 'Error: rule number must be less or equal 10');
        rules[_number].min = _min;
        rules[_number].max = _max;
        rules[_number].multiply = _multiply;
    }

    function emergencyWithdraw(address _token, uint256 _amount) external onlyOwner
    {
        IERC20 withdrawToken = IERC20(_token);
        withdrawToken.transfer(owner(), _amount);
    }
}
