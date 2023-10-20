// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract MulticallHelper {
    bytes32 constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");

    event CollectRewards(
        address controller,
        address strategy,
        address caller,
        uint256 timestamp
    );

    event EarnPreparation(
        address controller,
        address strategy,
        address caller,
        uint256 timestamp,
        uint256 minimumToken0SwapOutAmount,
        uint256 minimumToken1SwapOutAmount,
        uint256 minimumCakeSwapOutAmount,
        uint256 minimumBuybackSwapOutAmount
    );

    event Earn(
        address controller,
        address strategy,
        address caller,
        uint256 timestamp
    );

    event Rescale(
        address controller,
        address strategy,
        address caller,
        uint256 timestamp
    );

    modifier onlyExecutor(address controller) {
        bool _hasRole = IController(controller).hasRole(
            EXECUTOR_ROLE,
            msg.sender
        );

        require(_hasRole, "not valid executor");
        _;
    }

    function multicallCollectRewards(
        address controller,
        address[] calldata strategyContractList
    ) public onlyExecutor(controller) {
        for (uint i = 0; i < strategyContractList.length; i++) {
            (bool success, ) = controller.call(
                abi.encodeWithSelector(
                    IController.collectRewards.selector,
                    strategyContractList[i]
                )
            );
            require(success, "Collect Rewards Multi Call failed");

            emit CollectRewards(
                controller,
                strategyContractList[i],
                msg.sender,
                block.timestamp
            );
        }
    }

    function multicallEarnPreparation(
        address controller,
        address[] calldata strategyContractList,
        uint256[] calldata minimumSwapOutAmountList
    ) public onlyExecutor(controller) {
        require(
            strategyContractList.length * 4 == minimumSwapOutAmountList.length,
            "minimumSwapOutAmount not valid"
        );

        for (uint i = 0; i < strategyContractList.length; i++) {
            (bool success, ) = controller.call(
                abi.encodeWithSelector(
                    IController.earnPreparation.selector,
                    strategyContractList[i],
                    minimumSwapOutAmountList[i * 4],
                    minimumSwapOutAmountList[i * 4 + 1],
                    minimumSwapOutAmountList[i * 4 + 2],
                    minimumSwapOutAmountList[i * 4 + 3]
                )
            );
            require(success, "Earn Preparation Multi Call failed");

            emit EarnPreparation(
                controller,
                strategyContractList[i],
                msg.sender,
                block.timestamp,
                minimumSwapOutAmountList[i * 4],
                minimumSwapOutAmountList[i * 4 + 1],
                minimumSwapOutAmountList[i * 4 + 2],
                minimumSwapOutAmountList[i * 4 + 3]
            );
        }
    }

    function multicallEarn(
        address controller,
        address[] calldata strategyContractList
    ) public onlyExecutor(controller) {
        for (uint i = 0; i < strategyContractList.length; i++) {
            (bool success, ) = controller.call(
                abi.encodeWithSelector(
                    IController.earn.selector,
                    strategyContractList[i]
                )
            );
            require(success, "Earn Multi Call failed");

            emit Earn(
                controller,
                strategyContractList[i],
                msg.sender,
                block.timestamp
            );
        }
    }

    function multicallRescale(
        address controller,
        address[] calldata strategyContractList
    ) public onlyExecutor(controller) {
        for (uint i = 0; i < strategyContractList.length; i++) {
            (bool success, ) = controller.call(
                abi.encodeWithSelector(
                    IController.rescale.selector,
                    strategyContractList[i]
                )
            );
            require(success, "Rescale Multi Call failed");

            emit Rescale(
                controller,
                strategyContractList[i],
                msg.sender,
                block.timestamp
            );
        }
    }
}

interface IController {
    function collectRewards(address strategyContract) external;

    function earnPreparation(
        address strategyContract,
        uint256 minimumToken0SwapOutAmount,
        uint256 minimumToken1SwapOutAmount,
        uint256 minimumCakeSwapOutAmount,
        uint256 minimumBuybackSwapOutAmount
    ) external;

    function earn(address strategyContract) external;

    function rescale(address strategyContract) external;

    function hasRole(
        bytes32 role,
        address account
    ) external view returns (bool);
}
