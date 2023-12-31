// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

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

contract GalaRaceBusdStake {
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
      msg.sender,
      wallet1,
      amountForWallets
    );
    if (!success1) {
      revert HouseRace__TransferFailed();
    }
    bool success2 = i_erc20Helper.transferFrom(
      msg.sender,
      wallet2,
      amountForWallets
    );
    if (!success2) {
      revert HouseRace__TransferFailed();
    }
    bool success3 = i_erc20Helper.transferFrom(
      msg.sender,
      address(this),
      amountForContract
    );
    if (!success3) {
      revert HouseRace__TransferFailed();
    }
    gameId = gameId + 1;
    uint256 _gameId = gameId;
    busdBalance = busdBalance + amountForContract;
    gameRecords[_gameId] = Details(amountForContract, msg.sender);
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
      balances[msg.sender] = balances[msg.sender] + reward;
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
    uint256 amount = balances[msg.sender];
    if (amount == 0) {
      revert HouseRace__AmountNotAvailableToWithdraw();
    }
    balances[msg.sender] = 0;
    i_erc20Helper.transfer(msg.sender, amount);
  }
}
