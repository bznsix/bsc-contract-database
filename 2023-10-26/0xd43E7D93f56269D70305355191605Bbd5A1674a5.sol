// Copyright (c) OmniBTC, Inc.
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "IERC20.sol";
import "IWormholeAdapterPool.sol";
import "LibLendingCodec.sol";
import "LibDecimals.sol";
import "LibDolaTypes.sol";
import "LibAsset.sol";

contract LendingPortal {
    uint8 public constant LENDING_APP_ID = 1;

    IWormholeAdapterPool public immutable wormholeAdapterPool;

    event RelayEvent(
        uint64 sequence,
        uint64 nonce,
        uint256 feeAmount,
        uint16 appId,
        uint8 callType
    );

    event LendingPortalEvent(
        uint64 nonce,
        address sender,
        bytes dolaPoolAddress,
        uint16 sourceChainId,
        uint16 dstChainId,
        bytes receiver,
        uint64 amount,
        uint8 callType
    );

    event ClaimRewardEvent(
        uint64 nonce,
        address sender,
        bytes rewardPool,
        bytes withdrawPool,
        bytes receiver,
        uint16 sourceChainId,
        uint16 dstChainId,
        uint16 boostPoolId,
        uint16 boostAction
    );

    constructor(IWormholeAdapterPool _wormholeAdapterPool) {
        wormholeAdapterPool = _wormholeAdapterPool;
    }

    function supply(
        address token,
        uint256 amount,
        uint256 fee
    ) external payable {
        uint64 nonce = IWormholeAdapterPool(wormholeAdapterPool).getNonce();
        uint64 fixAmount = LibDecimals.fixAmountDecimals(
            amount,
            LibAsset.queryDecimals(token)
        );
        uint16 dolaChainId = wormholeAdapterPool.dolaChainId();
        bytes memory appPayload = LibLendingCodec.encodeDepositPayload(
            dolaChainId,
            nonce,
            LibDolaTypes.addressToDolaAddress(dolaChainId, msg.sender),
            LibLendingCodec.SUPPLY
        );
        // Deposit assets to the pool and perform amount checks
        LibAsset.depositAsset(token, amount);
        if (!LibAsset.isNativeAsset(token)) {
            LibAsset.maxApproveERC20(
                IERC20(token),
                address(wormholeAdapterPool),
                amount
            );
        }

        uint64 sequence = IWormholeAdapterPool(wormholeAdapterPool).sendDeposit{
            value: msg.value - fee
        }(token, amount, LENDING_APP_ID, appPayload);

        address relayer = IWormholeAdapterPool(wormholeAdapterPool)
            .getOneRelayer(nonce);

        LibAsset.transferAsset(address(0), payable(relayer), fee);

        emit RelayEvent(
            sequence,
            nonce,
            fee,
            LENDING_APP_ID,
            LibLendingCodec.SUPPLY
        );

        emit LendingPortalEvent(
            nonce,
            msg.sender,
            abi.encodePacked(token),
            dolaChainId,
            0,
            abi.encodePacked(msg.sender),
            fixAmount,
            LibLendingCodec.SUPPLY
        );
    }

    // withdraw use 8 decimal
    function withdraw(
        bytes memory token,
        bytes memory receiver,
        uint16 dstChainId,
        uint64 amount,
        uint256 fee
    ) external payable {
        uint64 nonce = IWormholeAdapterPool(wormholeAdapterPool).getNonce();
        uint16 dolaChainId = wormholeAdapterPool.dolaChainId();

        bytes memory appPayload = LibLendingCodec.encodeWithdrawPayload(
            dolaChainId,
            nonce,
            amount,
            LibDolaTypes.DolaAddress(dstChainId, token),
            LibDolaTypes.DolaAddress(dstChainId, receiver),
            LibLendingCodec.WITHDRAW
        );
        uint64 sequence = IWormholeAdapterPool(wormholeAdapterPool).sendMessage(
            LENDING_APP_ID,
            appPayload
        );

        address relayer = IWormholeAdapterPool(wormholeAdapterPool)
            .getOneRelayer(nonce);

        LibAsset.transferAsset(address(0), payable(relayer), fee);

        emit RelayEvent(
            sequence,
            nonce,
            fee,
            LENDING_APP_ID,
            LibLendingCodec.WITHDRAW
        );

        emit LendingPortalEvent(
            nonce,
            msg.sender,
            abi.encodePacked(token),
            dolaChainId,
            dstChainId,
            receiver,
            amount,
            LibLendingCodec.WITHDRAW
        );
    }

    function borrow(
        bytes memory token,
        bytes memory receiver,
        uint16 dstChainId,
        uint64 amount,
        uint256 fee
    ) external payable {
        uint64 nonce = IWormholeAdapterPool(wormholeAdapterPool).getNonce();
        uint16 dolaChainId = wormholeAdapterPool.dolaChainId();

        bytes memory appPayload = LibLendingCodec.encodeWithdrawPayload(
            dolaChainId,
            nonce,
            amount,
            LibDolaTypes.DolaAddress(dstChainId, token),
            LibDolaTypes.DolaAddress(dstChainId, receiver),
            LibLendingCodec.BORROW
        );

        uint64 sequence = IWormholeAdapterPool(wormholeAdapterPool).sendMessage(
            LENDING_APP_ID,
            appPayload
        );

        address relayer = IWormholeAdapterPool(wormholeAdapterPool)
            .getOneRelayer(nonce);

        LibAsset.transferAsset(address(0), payable(relayer), fee);

        emit RelayEvent(
            sequence,
            nonce,
            fee,
            LENDING_APP_ID,
            LibLendingCodec.BORROW
        );

        emit LendingPortalEvent(
            nonce,
            msg.sender,
            abi.encodePacked(token),
            dolaChainId,
            dstChainId,
            receiver,
            amount,
            LibLendingCodec.BORROW
        );
    }

    function repay(
        address token,
        uint256 amount,
        uint256 fee
    ) external payable {
        uint64 nonce = IWormholeAdapterPool(wormholeAdapterPool).getNonce();
        uint64 fixAmount = LibDecimals.fixAmountDecimals(
            amount,
            LibAsset.queryDecimals(token)
        );
        uint16 dolaChainId = wormholeAdapterPool.dolaChainId();

        bytes memory appPayload = LibLendingCodec.encodeDepositPayload(
            dolaChainId,
            nonce,
            LibDolaTypes.addressToDolaAddress(dolaChainId, msg.sender),
            LibLendingCodec.REPAY
        );

        // Deposit assets to the pool and perform amount checks
        LibAsset.depositAsset(token, amount);
        if (!LibAsset.isNativeAsset(token)) {
            LibAsset.maxApproveERC20(
                IERC20(token),
                address(wormholeAdapterPool),
                amount
            );
        }

        uint64 sequence = IWormholeAdapterPool(wormholeAdapterPool).sendDeposit{
            value: msg.value - fee
        }(token, amount, LENDING_APP_ID, appPayload);

        address relayer = IWormholeAdapterPool(wormholeAdapterPool)
            .getOneRelayer(nonce);

        LibAsset.transferAsset(address(0), payable(relayer), fee);

        emit RelayEvent(
            sequence,
            nonce,
            fee,
            LENDING_APP_ID,
            LibLendingCodec.REPAY
        );

        emit LendingPortalEvent(
            nonce,
            msg.sender,
            abi.encodePacked(token),
            dolaChainId,
            0,
            abi.encodePacked(msg.sender),
            fixAmount,
            LibLendingCodec.REPAY
        );
    }

    function liquidate(
        uint16 repayPoolId,
        uint64 liquidateUserId,
        uint16 liquidatePoolId,
        uint256 fee
    ) external payable {
        uint64 nonce = IWormholeAdapterPool(wormholeAdapterPool).getNonce();
        uint16 dolaChainId = wormholeAdapterPool.dolaChainId();

        bytes memory appPayload = LibLendingCodec.encodeLiquidatePayloadV2(
            dolaChainId,
            nonce,
            repayPoolId,
            liquidateUserId,
            liquidatePoolId
        );

        // Deposit assets to the pool and perform amount checks

        uint64 sequence = IWormholeAdapterPool(wormholeAdapterPool).sendMessage(
            LENDING_APP_ID,
            appPayload
        );

        address relayer = IWormholeAdapterPool(wormholeAdapterPool)
            .getOneRelayer(nonce);

        LibAsset.transferAsset(address(0), payable(relayer), fee);

        emit RelayEvent(
            sequence,
            nonce,
            fee,
            LENDING_APP_ID,
            LibLendingCodec.LIQUIDATE
        );

        emit LendingPortalEvent(
            nonce,
            msg.sender,
            abi.encodePacked(msg.sender),
            dolaChainId,
            0,
            abi.encodePacked(msg.sender),
            0,
            LibLendingCodec.LIQUIDATE
        );
    }

    function as_collateral(uint16[] memory dolaPoolIds, uint256 fee)
        external
        payable
    {
        uint64 nonce = IWormholeAdapterPool(wormholeAdapterPool).getNonce();
        uint16 dolaChainId = wormholeAdapterPool.dolaChainId();

        bytes memory appPayload = LibLendingCodec.encodeManageCollateralPayload(
            dolaPoolIds,
            LibLendingCodec.AS_COLLATERAL
        );
        uint64 sequence = IWormholeAdapterPool(wormholeAdapterPool).sendMessage(
            LENDING_APP_ID,
            appPayload
        );

        address relayer = IWormholeAdapterPool(wormholeAdapterPool)
            .getOneRelayer(nonce);

        LibAsset.transferAsset(address(0), payable(relayer), fee);

        emit RelayEvent(
            sequence,
            nonce,
            fee,
            LENDING_APP_ID,
            LibLendingCodec.AS_COLLATERAL
        );

        emit LendingPortalEvent(
            nonce,
            msg.sender,
            bytes(""),
            dolaChainId,
            0,
            abi.encodePacked(msg.sender),
            0,
            LibLendingCodec.AS_COLLATERAL
        );
    }

    function cancel_as_collateral(uint16[] memory dolaPoolIds, uint256 fee)
        external
        payable
    {
        uint64 nonce = IWormholeAdapterPool(wormholeAdapterPool).getNonce();
        uint16 dolaChainId = wormholeAdapterPool.dolaChainId();

        bytes memory appPayload = LibLendingCodec.encodeManageCollateralPayload(
            dolaPoolIds,
            LibLendingCodec.CANCEL_AS_COLLATERAL
        );
        uint64 sequence = IWormholeAdapterPool(wormholeAdapterPool).sendMessage(
            LENDING_APP_ID,
            appPayload
        );

        address relayer = IWormholeAdapterPool(wormholeAdapterPool)
            .getOneRelayer(nonce);

        LibAsset.transferAsset(address(0), payable(relayer), fee);

        emit RelayEvent(
            sequence,
            nonce,
            fee,
            LENDING_APP_ID,
            LibLendingCodec.CANCEL_AS_COLLATERAL
        );

        emit LendingPortalEvent(
            nonce,
            msg.sender,
            bytes(""),
            dolaChainId,
            0,
            abi.encodePacked(msg.sender),
            0,
            LibLendingCodec.CANCEL_AS_COLLATERAL
        );
    }

    function sponsor(
        address token,
        uint256 amount,
        uint256 fee
    ) external payable {
        uint64 nonce = IWormholeAdapterPool(wormholeAdapterPool).getNonce();
        uint64 fixAmount = LibDecimals.fixAmountDecimals(
            amount,
            LibAsset.queryDecimals(token)
        );
        uint16 dolaChainId = wormholeAdapterPool.dolaChainId();
        address receiver = address(0);
        bytes memory appPayload = LibLendingCodec.encodeDepositPayload(
            dolaChainId,
            nonce,
            LibDolaTypes.addressToDolaAddress(dolaChainId, receiver),
            LibLendingCodec.SPONSOR
        );
        // Deposit assets to the pool and perform amount checks
        LibAsset.depositAsset(token, amount);
        if (!LibAsset.isNativeAsset(token)) {
            LibAsset.maxApproveERC20(
                IERC20(token),
                address(wormholeAdapterPool),
                amount
            );
        }

        uint64 sequence = IWormholeAdapterPool(wormholeAdapterPool).sendDeposit{
            value: msg.value - fee
        }(token, amount, LENDING_APP_ID, appPayload);

        address relayer = IWormholeAdapterPool(wormholeAdapterPool)
            .getOneRelayer(nonce);

        LibAsset.transferAsset(address(0), payable(relayer), fee);

        emit RelayEvent(
            sequence,
            nonce,
            fee,
            LENDING_APP_ID,
            LibLendingCodec.SPONSOR
        );

        emit LendingPortalEvent(
            nonce,
            msg.sender,
            abi.encodePacked(token),
            dolaChainId,
            0,
            abi.encodePacked(msg.sender),
            fixAmount,
            LibLendingCodec.SPONSOR
        );
    }

    function claim_reward(
        bytes memory rewardPool,
        bytes memory token,
        bytes memory receiver,
        uint16 dstChainId,
        uint16 boostPoolId,
        uint8 boostAction,
        uint256 fee
    ) external payable {
        uint64 nonce = IWormholeAdapterPool(wormholeAdapterPool).getNonce();

        uint16 rewardPoolChainId = 0;

        bytes memory appPayload = LibLendingCodec.encodeClaimRewardPayload(
            wormholeAdapterPool.dolaChainId(),
            nonce,
            LibDolaTypes.DolaAddress(rewardPoolChainId, rewardPool),
            LibDolaTypes.DolaAddress(dstChainId, token),
            LibDolaTypes.DolaAddress(dstChainId, receiver),
            boostPoolId,
            boostAction,
            LibLendingCodec.CLAIM_REWARD
        );
        uint64 sequence = IWormholeAdapterPool(wormholeAdapterPool).sendMessage(
            LENDING_APP_ID,
            appPayload
        );

        address relayer = IWormholeAdapterPool(wormholeAdapterPool)
            .getOneRelayer(nonce);

        LibAsset.transferAsset(address(0), payable(relayer), fee);

        emit RelayEvent(
            sequence,
            nonce,
            fee,
            LENDING_APP_ID,
            LibLendingCodec.CLAIM_REWARD
        );

        emit ClaimRewardEvent(
            nonce,
            msg.sender,
            abi.encodePacked(rewardPool),
            abi.encodePacked(token),
            abi.encodePacked(receiver),
            wormholeAdapterPool.dolaChainId(),
            dstChainId,
            boostPoolId,
            boostAction
        );
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
// Copyright (c) OmniBTC, Inc.
// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

interface IWormholeAdapterPool {
    function dolaChainId() external view returns (uint16);

    function getNonce() external returns (uint64);

    function getOneRelayer(uint64 nonce) external view returns (address);

    function sendDeposit(
        address pool,
        uint256 amount,
        uint16 appId,
        bytes memory appPayload
    ) external payable returns (uint64);

    function sendMessage(
        uint16 appId,
        bytes memory appPayload
    ) external returns (uint64);
}
// Copyright (c) OmniBTC, Inc.
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "LibBytes.sol";
import "LibDolaTypes.sol";

library LibLendingCodec {
    using LibBytes for bytes;

    uint8 internal constant SUPPLY = 0;
    uint8 internal constant WITHDRAW = 1;
    uint8 internal constant BORROW = 2;
    uint8 internal constant REPAY = 3;
    uint8 internal constant LIQUIDATE = 4;
    uint8 internal constant AS_COLLATERAL = 5;
    uint8 internal constant CANCEL_AS_COLLATERAL = 6;
    uint8 internal constant SPONSOR = 7;
    uint8 internal constant CLAIM_REWARD = 8;

    struct DepositPayload {
        uint16 sourceChainId;
        uint64 nonce;
        LibDolaTypes.DolaAddress receiver;
        uint8 callType;
    }

    struct WithdrawPayload {
        uint16 sourceChainId;
        uint64 nonce;
        uint64 amount;
        LibDolaTypes.DolaAddress poolAddress;
        LibDolaTypes.DolaAddress receiver;
        uint8 callType;
    }

    struct LiquidatePayload {
        uint16 sourceChainId;
        uint64 nonce;
        uint16 repayPoolId;
        uint64 liquidateUserId;
        uint16 liquidatePoolId;
        uint8 callType;
    }

    struct ManageCollateralPayload {
        uint16[] dolaPoolIds;
        uint8 callType;
    }

    struct ClaimRewardPayload {
        uint16 sourceChainId;
        uint64 nonce;
        LibDolaTypes.DolaAddress rewardPoolAddress;
        LibDolaTypes.DolaAddress withdrawPoolAddress;
        LibDolaTypes.DolaAddress receiver;
        uint16 boostPoolId;
        uint8 boostAction;
        uint8 callType;
    }

    function encodeDepositPayload(
        uint16 sourceChainId,
        uint64 nonce,
        LibDolaTypes.DolaAddress memory receiver,
        uint8 callType
    ) internal pure returns (bytes memory) {
        bytes memory dolaAddress = LibDolaTypes.encodeDolaAddress(
            receiver.dolaChainId,
            receiver.externalAddress
        );
        bytes memory encodeData = abi.encodePacked(
            sourceChainId,
            nonce,
            uint16(dolaAddress.length),
            dolaAddress,
            callType
        );
        return encodeData;
    }

    function decodeDepositPayload(bytes memory payload)
        internal
        pure
        returns (DepositPayload memory)
    {
        uint256 length = payload.length;
        uint256 index;
        uint256 dataLen;
        DepositPayload memory decodeData;

        dataLen = 2;
        decodeData.sourceChainId = payload.toUint16(index);
        index += dataLen;

        dataLen = 8;
        decodeData.nonce = payload.toUint64(index);
        index += dataLen;

        dataLen = 2;
        uint16 receiveLength = payload.toUint16(index);
        index += dataLen;

        dataLen = receiveLength;
        decodeData.receiver = LibDolaTypes.decodeDolaAddress(
            payload.slice(index, dataLen)
        );
        index += dataLen;

        dataLen = 1;
        decodeData.callType = payload.toUint8(index);
        index += dataLen;

        require(index == length, "INVALID LENGTH");

        return decodeData;
    }

    function encodeWithdrawPayload(
        uint16 sourceChainId,
        uint64 nonce,
        uint64 amount,
        LibDolaTypes.DolaAddress memory poolAddress,
        LibDolaTypes.DolaAddress memory receiver,
        uint8 callType
    ) internal pure returns (bytes memory) {
        bytes memory poolDolaAddress = LibDolaTypes.encodeDolaAddress(
            poolAddress.dolaChainId,
            poolAddress.externalAddress
        );
        bytes memory receiverDolaAddress = LibDolaTypes.encodeDolaAddress(
            receiver.dolaChainId,
            receiver.externalAddress
        );
        bytes memory encodeData = abi.encodePacked(
            sourceChainId,
            nonce,
            amount,
            uint16(poolDolaAddress.length),
            poolDolaAddress,
            uint16(receiverDolaAddress.length),
            receiverDolaAddress,
            callType
        );
        return encodeData;
    }

    function decodeWithdrawPayload(bytes memory payload)
        internal
        pure
        returns (WithdrawPayload memory)
    {
        uint256 length = payload.length;
        uint256 index;
        uint256 dataLen;
        WithdrawPayload memory decodeData;

        dataLen = 2;
        decodeData.sourceChainId = payload.toUint16(index);
        index += dataLen;

        dataLen = 8;
        decodeData.nonce = payload.toUint64(index);
        index += dataLen;

        dataLen = 8;
        decodeData.amount = payload.toUint64(index);
        index += dataLen;

        dataLen = 2;
        uint16 poolLength = payload.toUint16(index);
        index += dataLen;

        dataLen = poolLength;
        decodeData.poolAddress = LibDolaTypes.decodeDolaAddress(
            payload.slice(index, dataLen)
        );
        index += dataLen;

        dataLen = 2;
        uint16 receiveLength = payload.toUint16(index);
        index += dataLen;

        dataLen = receiveLength;
        decodeData.receiver = LibDolaTypes.decodeDolaAddress(
            payload.slice(index, dataLen)
        );
        index += dataLen;

        dataLen = 1;
        decodeData.callType = payload.toUint8(index);
        index += dataLen;

        require(index == length, "INVALID LENGTH");

        return decodeData;
    }

    function encodeLiquidatePayloadV2(
        uint16 sourceChainId,
        uint64 nonce,
        uint16 repayPoolId,
        uint64 liquidateUserId,
        uint16 liquidatePoolId
    ) internal pure returns (bytes memory) {
        bytes memory encodeData = abi.encodePacked(
            sourceChainId,
            nonce,
            repayPoolId,
            liquidateUserId,
            liquidatePoolId,
            LIQUIDATE
        );
        return encodeData;
    }

    function decodeLiquidatePayloadV2(bytes memory payload)
        internal
        pure
        returns (LiquidatePayload memory)
    {
        uint256 length = payload.length;
        uint256 index;
        uint256 dataLen;
        LiquidatePayload memory decodeData;

        dataLen = 2;
        decodeData.sourceChainId = payload.toUint16(index);
        index += dataLen;

        dataLen = 8;
        decodeData.nonce = payload.toUint64(index);
        index += dataLen;

        dataLen = 2;
        decodeData.repayPoolId = payload.toUint16(index);
        index += dataLen;

        dataLen = 8;
        decodeData.liquidateUserId = payload.toUint64(index);
        index += dataLen;

        dataLen = 2;
        decodeData.liquidatePoolId = payload.toUint16(index);
        index += dataLen;

        dataLen = 1;
        decodeData.callType = payload.toUint8(index);
        index += dataLen;

        require(decodeData.callType == LIQUIDATE, "INVALID CALL TYPE");
        require(index == length, "INVALID LENGTH");

        return decodeData;
    }

    function encodeManageCollateralPayload(
        uint16[] memory dolaPoolIds,
        uint8 callType
    ) internal pure returns (bytes memory) {
        bytes memory encodeData = abi.encodePacked(uint16(dolaPoolIds.length));

        for (uint256 i = 0; i < dolaPoolIds.length; i++) {
            encodeData = encodeData.concat(abi.encodePacked(dolaPoolIds[i]));
        }

        encodeData = encodeData.concat(abi.encodePacked(callType));
        return encodeData;
    }

    function decodeManageCollateralPayload(bytes memory payload)
        internal
        pure
        returns (ManageCollateralPayload memory)
    {
        uint256 length = payload.length;
        uint256 index;
        uint256 dataLen;
        ManageCollateralPayload memory decodeData;

        dataLen = 2;
        uint16 poolIdsLength = payload.toUint16(index);
        index += dataLen;

        uint16[] memory dolaPoolIds = new uint16[](poolIdsLength);
        for (uint256 i = 0; i < poolIdsLength; i++) {
            dataLen = 2;
            uint16 dolaPoolId = payload.toUint16(index);
            index += dataLen;
            dolaPoolIds[i] = dolaPoolId;
        }
        decodeData.dolaPoolIds = dolaPoolIds;

        dataLen = 1;
        decodeData.callType = payload.toUint8(index);
        index += dataLen;

        require(index == length, "INVALID LENGTH");

        return decodeData;
    }

    function encodeClaimRewardPayload(
        uint16 sourceChainId,
        uint64 nonce,
        LibDolaTypes.DolaAddress memory rewardPoolAddress,
        LibDolaTypes.DolaAddress memory withdrawPoolAddress,
        LibDolaTypes.DolaAddress memory receiver,
        uint16 boostPoolId,
        uint8 boostAction,
        uint8 callType
    ) internal pure returns (bytes memory) {
        bytes memory rewardPoolDolaAddress = LibDolaTypes.encodeDolaAddress(
            rewardPoolAddress.dolaChainId,
            rewardPoolAddress.externalAddress
        );
        bytes memory withdrawPoolDolaAddress = LibDolaTypes.encodeDolaAddress(
            withdrawPoolAddress.dolaChainId,
            withdrawPoolAddress.externalAddress
        );
        bytes memory receiverDolaAddress = LibDolaTypes.encodeDolaAddress(
            receiver.dolaChainId,
            receiver.externalAddress
        );
        bytes memory encodeData = abi.encodePacked(
            sourceChainId,
            nonce,
            uint16(rewardPoolDolaAddress.length),
            rewardPoolDolaAddress,
            uint16(withdrawPoolDolaAddress.length),
            withdrawPoolDolaAddress,
            uint16(receiverDolaAddress.length),
            receiverDolaAddress,
            boostPoolId,
            boostAction,
            callType
        );
        return encodeData;
    }

    function decodeClaimRewardPayload(bytes memory payload)
        internal
        pure
        returns (ClaimRewardPayload memory)
    {
        uint256 length = payload.length;
        uint256 index;
        uint256 dataLen;
        ClaimRewardPayload memory decodeData;

        dataLen = 2;
        decodeData.sourceChainId = payload.toUint16(index);
        index += dataLen;

        dataLen = 8;
        decodeData.nonce = payload.toUint64(index);
        index += dataLen;

        dataLen = 2;
        uint16 rewardPoolLength = payload.toUint16(index);
        index += dataLen;

        dataLen = rewardPoolLength;
        decodeData.rewardPoolAddress = LibDolaTypes.decodeDolaAddress(
            payload.slice(index, dataLen)
        );
        index += dataLen;

        dataLen = 2;
        uint16 withdrawPoolLength = payload.toUint16(index);
        index += dataLen;

        dataLen = withdrawPoolLength;
        decodeData.withdrawPoolAddress = LibDolaTypes.decodeDolaAddress(
            payload.slice(index, dataLen)
        );
        index += dataLen;

        dataLen = 2;
        uint16 receiveLength = payload.toUint16(index);
        index += dataLen;

        dataLen = receiveLength;
        decodeData.receiver = LibDolaTypes.decodeDolaAddress(
            payload.slice(index, dataLen)
        );
        index += dataLen;

        dataLen = 2;
        decodeData.boostPoolId = payload.toUint16(index);
        index += dataLen;

        dataLen = 1;
        decodeData.boostAction = payload.toUint8(index);
        index += dataLen;

        dataLen = 1;
        decodeData.callType = payload.toUint8(index);
        index += dataLen;

        require(index == length, "INVALID LENGTH");

        return decodeData;
    }
}
// Copyright (c) OmniBTC, Inc.
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

library LibBytes {
    // solhint-disable no-inline-assembly

    function concat(bytes memory _preBytes, bytes memory _postBytes)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory tempBytes;

        assembly {
            // Get a location of some free memory and store it in tempBytes as
            // Solidity does for memory variables.
            tempBytes := mload(0x40)

            // Store the length of the first bytes array at the beginning of
            // the memory for tempBytes.
            let length := mload(_preBytes)
            mstore(tempBytes, length)

            // Maintain a memory counter for the current write location in the
            // temp bytes array by adding the 32 bytes for the array length to
            // the starting location.
            let mc := add(tempBytes, 0x20)
            // Stop copying when the memory counter reaches the length of the
            // first bytes array.
            let end := add(mc, length)

            for {
                // Initialize a copy counter to the start of the _preBytes data,
                // 32 bytes into its memory.
                let cc := add(_preBytes, 0x20)
            } lt(mc, end) {
                // Increase both counters by 32 bytes each iteration.
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                // Write the _preBytes data into the tempBytes memory 32 bytes
                // at a time.
                mstore(mc, mload(cc))
            }

            // Add the length of _postBytes to the current length of tempBytes
            // and store it as the new length in the first 32 bytes of the
            // tempBytes memory.
            length := mload(_postBytes)
            mstore(tempBytes, add(length, mload(tempBytes)))

            // Move the memory counter back from a multiple of 0x20 to the
            // actual end of the _preBytes data.
            mc := end
            // Stop copying when the memory counter reaches the new combined
            // length of the arrays.
            end := add(mc, length)

            for {
                let cc := add(_postBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            // Update the free-memory pointer by padding our last write location
            // to 32 bytes: add 31 bytes to the end of tempBytes to move to the
            // next 32 byte block, then round down to the nearest multiple of
            // 32. If the sum of the length of the two arrays is zero then add
            // one before rounding down to leave a blank 32 bytes (the length block with 0).
            mstore(
                0x40,
                and(
                    add(add(end, iszero(add(length, mload(_preBytes)))), 31),
                    not(31) // Round down to the nearest 32 bytes.
                )
            )
        }

        return tempBytes;
    }

    function concatStorage(bytes storage _preBytes, bytes memory _postBytes)
        internal
    {
        assembly {
            // Read the first 32 bytes of _preBytes storage, which is the length
            // of the array. (We don't need to use the offset into the slot
            // because arrays use the entire slot.)
            let fslot := sload(_preBytes.slot)
            // Arrays of 31 bytes or less have an even value in their slot,
            // while longer arrays have an odd value. The actual length is
            // the slot divided by two for odd values, and the lowest order
            // byte divided by two for even values.
            // If the slot is even, bitwise and the slot with 255 and divide by
            // two to get the length. If the slot is odd, bitwise and the slot
            // with -1 and divide by two.
            let slength := div(
                and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)),
                2
            )
            let mlength := mload(_postBytes)
            let newlength := add(slength, mlength)
            // slength can contain both the length and contents of the array
            // if length < 32 bytes so let's prepare for that
            // v. http://solidity.readthedocs.io/en/latest/miscellaneous.html#layout-of-state-variables-in-storage
            switch add(lt(slength, 32), lt(newlength, 32))
            case 2 {
                // Since the new array still fits in the slot, we just need to
                // update the contents of the slot.
                // uint256(bytes_storage) = uint256(bytes_storage) + uint256(bytes_memory) + new_length
                sstore(
                    _preBytes.slot,
                    // all the modifications to the slot are inside this
                    // next block
                    add(
                        // we can just add to the slot contents because the
                        // bytes we want to change are the LSBs
                        fslot,
                        add(
                            mul(
                                div(
                                    // load the bytes from memory
                                    mload(add(_postBytes, 0x20)),
                                    // zero all bytes to the right
                                    exp(0x100, sub(32, mlength))
                                ),
                                // and now shift left the number of bytes to
                                // leave space for the length in the slot
                                exp(0x100, sub(32, newlength))
                            ),
                            // increase length by the double of the memory
                            // bytes length
                            mul(mlength, 2)
                        )
                    )
                )
            }
            case 1 {
                // The stored value fits in the slot, but the combined value
                // will exceed it.
                // get the keccak hash to get the contents of the array
                mstore(0x0, _preBytes.slot)
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                // save new length
                sstore(_preBytes.slot, add(mul(newlength, 2), 1))

                // The contents of the _postBytes array start 32 bytes into
                // the structure. Our first read should obtain the `submod`
                // bytes that can fit into the unused space in the last word
                // of the stored array. To get this, we read 32 bytes starting
                // from `submod`, so the data we read overlaps with the array
                // contents by `submod` bytes. Masking the lowest-order
                // `submod` bytes allows us to add that value directly to the
                // stored value.

                let submod := sub(32, slength)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(
                    sc,
                    add(
                        and(
                            fslot,
                            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00
                        ),
                        and(mload(mc), mask)
                    )
                )

                for {
                    mc := add(mc, 0x20)
                    sc := add(sc, 1)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
            default {
                // get the keccak hash to get the contents of the array
                mstore(0x0, _preBytes.slot)
                // Start copying to the last used word of the stored array.
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                // save new length
                sstore(_preBytes.slot, add(mul(newlength, 2), 1))

                // Copy over the first `submod` bytes of the new data as in
                // case 1 above.
                let slengthmod := mod(slength, 32)
                let submod := sub(32, slengthmod)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(sc, add(sload(sc), and(mload(mc), mask)))

                for {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
        }
    }

    function indexOf(
        bytes memory _bytes,
        uint8 _e,
        uint256 _start
    ) internal pure returns (uint256) {
        while (_start < _bytes.length) {
            if (toUint8(_bytes, _start) == _e) {
                return _start;
            }
            _start += 1;
        }
        return _bytes.length;
    }

    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    ) internal pure returns (bytes memory) {
        require(_length + 31 >= _length, "slice_overflow");
        require(_bytes.length >= _start + _length, "slice_outOfBounds");

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                // Get a location of some free memory and store it in tempBytes as
                // Solidity does for memory variables.
                tempBytes := mload(0x40)

                // The first word of the slice result is potentially a partial
                // word read from the original array. To read it, we calculate
                // the length of that partial word and start copying that many
                // bytes into the array. The first word we copy will start with
                // data we don't care about, but the last `lengthmod` bytes will
                // land at the beginning of the contents of the new array. When
                // we're done copying, we overwrite the full first word with
                // the actual length of the slice.
                let lengthmod := and(_length, 31)

                // The multiplication in the next line is necessary
                // because when slicing multiples of 32 bytes (lengthmod == 0)
                // the following copy loop was copying the origin's length
                // and then ending prematurely not copying everything it should.
                let mc := add(
                    add(tempBytes, lengthmod),
                    mul(0x20, iszero(lengthmod))
                )
                let end := add(mc, _length)

                for {
                    // The multiplication in the next line has the same exact purpose
                    // as the one above.
                    let cc := add(
                        add(
                            add(_bytes, lengthmod),
                            mul(0x20, iszero(lengthmod))
                        ),
                        _start
                    )
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                //update free-memory pointer
                //allocating the array padded to 32 bytes like the compiler does now
                mstore(0x40, and(add(mc, 31), not(31)))
            }
            //if we want a zero-length slice let's just return a zero-length array
            default {
                tempBytes := mload(0x40)
                //zero out the 32 bytes slice we are about to return
                //we need to do it because Solidity does not garbage collect
                mstore(tempBytes, 0)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    function toAddress(bytes memory _bytes, uint256 _start)
        internal
        pure
        returns (address)
    {
        require(_bytes.length >= _start + 20, "toAddress_outOfBounds");
        address tempAddress;

        assembly {
            tempAddress := div(
                mload(add(add(_bytes, 0x20), _start)),
                0x1000000000000000000000000
            )
        }

        return tempAddress;
    }

    function toUint8(bytes memory _bytes, uint256 _start)
        internal
        pure
        returns (uint8)
    {
        require(_bytes.length >= _start + 1, "toUint8_outOfBounds");
        uint8 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x1), _start))
        }

        return tempUint;
    }

    function toUint16(bytes memory _bytes, uint256 _start)
        internal
        pure
        returns (uint16)
    {
        require(_bytes.length >= _start + 2, "toUint16_outOfBounds");
        uint16 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x2), _start))
        }

        return tempUint;
    }

    function toUint32(bytes memory _bytes, uint256 _start)
        internal
        pure
        returns (uint32)
    {
        require(_bytes.length >= _start + 4, "toUint32_outOfBounds");
        uint32 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x4), _start))
        }

        return tempUint;
    }

    function toUint64(bytes memory _bytes, uint256 _start)
        internal
        pure
        returns (uint64)
    {
        require(_bytes.length >= _start + 8, "toUint64_outOfBounds");
        uint64 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x8), _start))
        }

        return tempUint;
    }

    function toUint96(bytes memory _bytes, uint256 _start)
        internal
        pure
        returns (uint96)
    {
        require(_bytes.length >= _start + 12, "toUint96_outOfBounds");
        uint96 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0xc), _start))
        }

        return tempUint;
    }

    function toUint128(bytes memory _bytes, uint256 _start)
        internal
        pure
        returns (uint128)
    {
        require(_bytes.length >= _start + 16, "toUint128_outOfBounds");
        uint128 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x10), _start))
        }

        return tempUint;
    }

    function toUint256(bytes memory _bytes, uint256 _start)
        internal
        pure
        returns (uint256)
    {
        require(_bytes.length >= _start + 32, "toUint256_outOfBounds");
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }

    function toBytes32(bytes memory _bytes, uint256 _start)
        internal
        pure
        returns (bytes32)
    {
        require(_bytes.length >= _start + 32, "toBytes32_outOfBounds");
        bytes32 tempBytes32;

        assembly {
            tempBytes32 := mload(add(add(_bytes, 0x20), _start))
        }

        return tempBytes32;
    }

    function equal(bytes memory _preBytes, bytes memory _postBytes)
        internal
        pure
        returns (bool)
    {
        bool success = true;

        assembly {
            let length := mload(_preBytes)

            // if lengths don't match the arrays are not equal
            switch eq(length, mload(_postBytes))
            case 1 {
                // cb is a circuit breaker in the for loop since there's
                //  no said feature for inline assembly loops
                // cb = 1 - don't breaker
                // cb = 0 - break
                let cb := 1

                let mc := add(_preBytes, 0x20)
                let end := add(mc, length)

                for {
                    let cc := add(_postBytes, 0x20)
                    // the next line is the loop condition:
                    // while(uint256(mc < end) + cb == 2)
                } eq(add(lt(mc, end), cb), 2) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    // if any of these checks fails then arrays are not equal
                    if iszero(eq(mload(mc), mload(cc))) {
                        // unsuccess:
                        success := 0
                        cb := 0
                    }
                }
            }
            default {
                // unsuccess:
                success := 0
            }
        }

        return success;
    }

    function equalStorage(bytes storage _preBytes, bytes memory _postBytes)
        internal
        view
        returns (bool)
    {
        bool success = true;

        assembly {
            // we know _preBytes_offset is 0
            let fslot := sload(_preBytes.slot)
            // Decode the length of the stored array like in concatStorage().
            let slength := div(
                and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)),
                2
            )
            let mlength := mload(_postBytes)

            // if lengths don't match the arrays are not equal
            switch eq(slength, mlength)
            case 1 {
                // slength can contain both the length and contents of the array
                // if length < 32 bytes so let's prepare for that
                // v. http://solidity.readthedocs.io/en/latest/miscellaneous.html#layout-of-state-variables-in-storage
                if iszero(iszero(slength)) {
                    switch lt(slength, 32)
                    case 1 {
                        // blank the last byte which is the length
                        fslot := mul(div(fslot, 0x100), 0x100)

                        if iszero(eq(fslot, mload(add(_postBytes, 0x20)))) {
                            // unsuccess:
                            success := 0
                        }
                    }
                    default {
                        // cb is a circuit breaker in the for loop since there's
                        //  no said feature for inline assembly loops
                        // cb = 1 - don't breaker
                        // cb = 0 - break
                        let cb := 1

                        // get the keccak hash to get the contents of the array
                        mstore(0x0, _preBytes.slot)
                        let sc := keccak256(0x0, 0x20)

                        let mc := add(_postBytes, 0x20)
                        let end := add(mc, mlength)

                        // the next line is the loop condition:
                        // while(uint256(mc < end) + cb == 2)
                        // solhint-disable-next-line no-empty-blocks
                        for {

                        } eq(add(lt(mc, end), cb), 2) {
                            sc := add(sc, 1)
                            mc := add(mc, 0x20)
                        } {
                            if iszero(eq(sload(sc), mload(mc))) {
                                // unsuccess:
                                success := 0
                                cb := 0
                            }
                        }
                    }
                }
            }
            default {
                // unsuccess:
                success := 0
            }
        }

        return success;
    }
}
// Copyright (c) OmniBTC, Inc.
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "LibBytes.sol";

library LibDolaTypes {
    using LibBytes for bytes;

    struct DolaAddress {
        uint16 dolaChainId;
        bytes externalAddress;
    }

    function addressToDolaAddress(uint16 chainId, address evmAddress)
        internal
        pure
        returns (DolaAddress memory)
    {
        return DolaAddress(chainId, abi.encodePacked(evmAddress));
    }

    function dolaAddressToAddress(DolaAddress memory dolaAddress)
        internal
        pure
        returns (address)
    {
        require(
            dolaAddress.externalAddress.length == 20,
            "Not normal evm address"
        );
        return dolaAddress.externalAddress.toAddress(0);
    }

    function encodeDolaAddress(uint16 dolaChainId, bytes memory externalAddress)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory payload = abi.encodePacked(dolaChainId, externalAddress);
        return payload;
    }

    function decodeDolaAddress(bytes memory payload)
        internal
        pure
        returns (DolaAddress memory)
    {
        uint256 length = payload.length;
        uint256 index;
        uint256 dataLen;
        DolaAddress memory dolaAddress;

        dataLen = 2;
        dolaAddress.dolaChainId = payload.toUint16(index);
        index += dataLen;

        dolaAddress.externalAddress = payload.slice(index, length - dataLen);
        return dolaAddress;
    }
}
// Copyright (c) OmniBTC, Inc.
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

library LibDecimals {
    function fixAmountDecimals(uint256 amount, uint8 decimals)
        internal
        pure
        returns (uint64)
    {
        uint64 fixedAmount;
        if (decimals > 8) {
            fixedAmount = uint64(amount / (10**(decimals - 8)));
        } else if (decimals < 8) {
            fixedAmount = uint64(amount * (10**(8 - decimals)));
        } else {
            fixedAmount = uint64(amount);
        }
        require(fixedAmount > 0, "Fixed amount too low");
        return fixedAmount;
    }

    function restoreAmountDecimals(uint64 amount, uint8 decimals)
        internal
        pure
        returns (uint256)
    {
        uint256 restoreAmount;
        if (decimals > 8) {
            restoreAmount = uint256(amount * (10**(decimals - 8)));
        } else if (decimals < 8) {
            restoreAmount = uint256(amount / (10**(8 - decimals)));
        } else {
            restoreAmount = uint256(amount);
        }
        return restoreAmount;
    }
}
// Copyright (c) OmniBTC, Inc.
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
import "SafeERC20.sol";
import "IERC20.sol";

/// @title LibAsset
/// @notice This library contains helpers for dealing with onchain transfers
///         of assets, including accounting for the native asset `assetId`
///         conventions and any noncompliant ERC20 transfers
library LibAsset {
    uint256 private constant MAX_INT = type(uint256).max;

    address internal constant NULL_ADDRESS =
        0x0000000000000000000000000000000000000000; //address(0)

    /// @dev All native assets use the empty address for their asset id
    ///      by convention

    address internal constant NATIVE_ASSETID = NULL_ADDRESS; //address(0)

    /// @notice Gets the balance of the inheriting contract for the given asset
    /// @param assetId The asset identifier to get the balance of
    /// @return Balance held by contracts using this library
    function getOwnBalance(address assetId) internal view returns (uint256) {
        return
            assetId == NATIVE_ASSETID
                ? address(this).balance
                : IERC20(assetId).balanceOf(address(this));
    }

    /// @notice Transfers ether from the inheriting contract to a given
    ///         recipient
    /// @param recipient Address to send ether to
    /// @param amount Amount to send to given recipient
    function transferNativeAsset(address payable recipient, uint256 amount)
        private
    {
        if (recipient == NULL_ADDRESS) revert("NoTransferToNullAddress");
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, ) = recipient.call{value: amount}("");
        if (!success) revert("NativeAssetTransferFailed");
    }

    /// @notice Gives MAX approval for another address to spend tokens
    /// @param assetId Token address to transfer
    /// @param spender Address to give spend approval to
    /// @param amount Amount to approve for spending
    function maxApproveERC20(
        IERC20 assetId,
        address spender,
        uint256 amount
    ) internal {
        if (address(assetId) == NATIVE_ASSETID) return;
        if (spender == NULL_ADDRESS) revert("NullAddrIsNotAValidSpender");
        uint256 allowance = assetId.allowance(address(this), spender);
        if (allowance < amount)
            SafeERC20.safeApprove(IERC20(assetId), spender, MAX_INT);
    }

    /// @notice Transfers tokens from the inheriting contract to a given
    ///         recipient
    /// @param assetId Token address to transfer
    /// @param recipient Address to send token to
    /// @param amount Amount to send to given recipient
    function transferERC20(
        address assetId,
        address recipient,
        uint256 amount
    ) private {
        if (isNativeAsset(assetId)) revert("NullAddrIsNotAnERC20Token");
        SafeERC20.safeTransfer(IERC20(assetId), recipient, amount);
    }

    /// @notice Transfers tokens from a sender to a given recipient
    /// @param assetId Token address to transfer
    /// @param from Address of sender/owner
    /// @param to Address of recipient/spender
    /// @param amount Amount to transfer from owner to spender
    function transferFromERC20(
        address assetId,
        address from,
        address to,
        uint256 amount
    ) internal {
        if (assetId == NATIVE_ASSETID) revert("NullAddrIsNotAnERC20Token");
        if (to == NULL_ADDRESS) revert("NoTransferToNullAddress");
        SafeERC20.safeTransferFrom(IERC20(assetId), from, to, amount);
    }

    /// @notice Deposits an asset into the contract and performs checks to avoid NativeValueWithERC
    /// @param tokenId Token to deposit
    /// @param amount Amount to deposit
    /// @param isNative Wether the token is native or ERC20
    function depositAsset(
        address tokenId,
        uint256 amount,
        bool isNative
    ) internal {
        if (amount == 0) revert("InvalidAmount");
        if (isNative) {
            if (msg.value < amount) revert("InvalidAmount");
        } else {
            uint256 _fromTokenBalance = LibAsset.getOwnBalance(tokenId);
            LibAsset.transferFromERC20(
                tokenId,
                msg.sender,
                address(this),
                amount
            );
            if (LibAsset.getOwnBalance(tokenId) - _fromTokenBalance != amount)
                revert("InvalidAmount");
        }
    }

    /// @notice Overload for depositAsset(address tokenId, uint256 amount, bool isNative)
    /// @param tokenId Token to deposit
    /// @param amount Amount to deposit
    function depositAsset(address tokenId, uint256 amount) internal {
        return depositAsset(tokenId, amount, tokenId == NATIVE_ASSETID);
    }

    /// @notice Determines whether the given assetId is the native asset
    /// @param assetId The asset identifier to evaluate
    /// @return Boolean indicating if the asset is the native asset
    function isNativeAsset(address assetId) internal pure returns (bool) {
        return assetId == NATIVE_ASSETID;
    }

    /// @notice Wrapper function to transfer a given asset (native or erc20) to
    ///         some recipient. Should handle all non-compliant return value
    ///         tokens as well by using the SafeERC20 contract by open zeppelin.
    /// @param assetId Asset id for transfer (address(0) for native asset,
    ///                token address for erc20s)
    /// @param recipient Address to send asset to
    /// @param amount Amount to send to given recipient
    function transferAsset(
        address assetId,
        address payable recipient,
        uint256 amount
    ) internal {
        (assetId == NATIVE_ASSETID)
            ? transferNativeAsset(recipient, amount)
            : transferERC20(assetId, recipient, amount);
    }

    /// @dev Checks whether the given address is a contract and contains code
    function isContract(address contractAddr) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(contractAddr)
        }
        return size > 0;
    }

    /// @dev Query the decimals of the corresponding token
    function queryDecimals(address token) internal view returns (uint8) {
        if (token == address(0)) {
            return 18;
        } else {
            (, bytes memory queriedDecimals) = token.staticcall(
                abi.encodeWithSignature("decimals()")
            );
            uint8 decimals = abi.decode(queriedDecimals, (uint8));
            return decimals;
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "IERC20.sol";
import "Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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
