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

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20 {
  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);
}


error HouseRace__AmountNotAvailableToWithdraw();
error HouseRace__TransferFailed();

contract GalaRaceBusdStake is Ownable {
  struct Details {
    uint256 amount;
    address player;
  }

  IERC20 private immutable i_erc20Helper;
  uint256 private busdBalance;
  uint256 public gameId;
  address private wallet1;
  address private wallet2;
  mapping(address => uint256) private balances;
  mapping(uint256 => Details) private gameRecords;
  mapping(uint256 => uint256) public results;

  constructor(address _busd, address _addr1, address _addr2) {
    i_erc20Helper = IERC20(_busd);
    wallet1 = _addr1;
    wallet2 = _addr2;
  }

  function StakeBusd(uint256 _amount, uint256 _number) external {
    require(_amount > 0, "Amount Can't be zero");
    uint256 amountForWallets = (_amount * 300) / 1000;
    uint256 amountForContract = (_amount * 400) / 1000;
    bool success1 = i_erc20Helper.transferFrom(
      _msgSender(),
      wallet1,
      amountForWallets
    );
    if (!success1) {
      revert HouseRace__TransferFailed();
    }
    bool success2 = i_erc20Helper.transferFrom(
      _msgSender(),
      wallet2,
      amountForWallets
    );
    if (!success2) {
      revert HouseRace__TransferFailed();
    }
    bool success3 = i_erc20Helper.transferFrom(
      _msgSender(),
      address(this),
      amountForContract
    );
    if (!success3) {
      revert HouseRace__TransferFailed();
    }
    gameId = gameId + 1;
    uint256 _gameId = gameId;
    busdBalance = busdBalance + amountForContract;
    gameRecords[_gameId] = Details(amountForContract, _msgSender());
    uint256 result = rand(_number);

    uint256 finalRank;
    uint256 reward;
    if (result > 5) {
      finalRank = result;
    } else {
      uint256 rank = estimatingWinner(amountForContract);

      if (rank == 0) {
        finalRank = result + 10;
      } else if (result < rank) {
        uint256 value = rewardCalculation(rank, amountForContract);
        finalRank = rank;
        reward = value;
      } else {
        uint256 value = rewardCalculation(result, amountForContract);
        finalRank = result;
        reward = value;
      }
    }
    if (reward > 0) {
      balances[_msgSender()] = balances[_msgSender()] + reward;
      busdBalance = busdBalance - reward;
    }
    results[_gameId] = finalRank;
  }

  function rand(uint256 _number) internal view returns (uint256 result) {
    uint256 number = uint256(
      keccak256(
        abi.encodePacked(
          tx.origin,
          blockhash(block.number - 1),
          block.timestamp,
          _number
        )
      )
    );
    result = (number % 20) + 1;
  }

  function estimatingWinner(uint256 _amount) private view returns (uint256) {
    if (busdBalance >= _amount * 20) {
      return 1;
    } else if (busdBalance >= _amount * 10) {
      return 2;
    } else if (busdBalance >= _amount * 5) {
      return 3;
    } else if (busdBalance >= _amount * 3) {
      return 4;
    } else if (busdBalance >= _amount * 2) {
      return 5;
    } else {
      return 0;
    }
  }

  function rewardCalculation(
    uint256 _rank,
    uint256 _amount
  ) private pure returns (uint256) {
    if (_rank == 1) {
      return _amount * 20;
    } else if (_rank == 2) {
      return _amount * 10;
    } else if (_rank == 3) {
      return _amount * 5;
    } else if (_rank == 4) {
      return _amount * 3;
    } else {
      return _amount * 2;
    }
  }

  function withdraw() external {
    uint256 amount = balances[_msgSender()];
    if (amount == 0) {
      revert HouseRace__AmountNotAvailableToWithdraw();
    }
    balances[_msgSender()] = 0;
    i_erc20Helper.transfer(_msgSender(), amount);
  }

   function updateWallet1(address _newWallet) external onlyOwner {
        wallet1 = _newWallet;
    }

    function updateWallet2(address _newWallet) external onlyOwner {
        wallet2 = _newWallet;
    }
}