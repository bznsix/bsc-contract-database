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
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.21;

/// @title Interface for ExactInputDelegateSwapModule
interface ExactInputDelegateSwapModule {
    struct ExactInputParams {
        uint256 inputTokenAmount;
        uint256 paymentTokenAmountMin;
        uint256 deadline;
        bytes swapData;
    }

    function exactInputNativeSwap(bytes calldata swapParams) external returns (uint256);

    function exactInputSwap(bytes calldata swapParams) external returns (uint256);

    function decodeSwapData(bytes calldata swapData) external returns (address, address, address);
}
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.21;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/ExactInputDelegateSwapModule.sol";

interface ISpritzPay {
    function payWithToken(address paymentTokenAddress, uint256 paymentTokenAmount, bytes32 paymentReference) external;
}

interface IReceiverFactory {
    function getDestinationAddresses() external view returns (address, address);
}

contract SpritzReceiver {
    error NotController();
    error InvalidDestination();
    error SwapFailure();
    error DecodeFailure();
    error FailedSweep();

    bytes32 private immutable accountReference;
    address private immutable controller;
    address private immutable factory;

    modifier onlyController() {
        if (msg.sender != controller) revert NotController();
        _;
    }

    constructor(address _controller, bytes32 _accountReference) payable {
        controller = _controller;
        accountReference = _accountReference;
        factory = msg.sender;
    }

    function payWithToken(address token, uint256 amount) external onlyController {
        (address spritzPay, ) = getDestinationAddresses();
        _payWithToken(spritzPay, token, amount);
    }

    function payWithSwap(
        uint256 sourceTokenAmount,
        uint256 paymentTokenAmountMin,
        uint256 deadline,
        bytes calldata swapData
    ) external onlyController {
        (address spritzPay, address swapModule) = getDestinationAddresses();

        (address sourceToken, address paymentToken, address weth) = decodeSwapData(swapModule, swapData);

        string memory selector;

        if (sourceToken == weth) {
            selector = address(this).balance >= sourceTokenAmount
                ? "exactInputNativeSwap(bytes)"
                : "exactInputSwap(bytes)";
        } else {
            selector = "exactInputSwap(bytes)";
        }

        ExactInputDelegateSwapModule.ExactInputParams memory swapParams = ExactInputDelegateSwapModule
            .ExactInputParams({
                inputTokenAmount: sourceTokenAmount,
                paymentTokenAmountMin: paymentTokenAmountMin,
                deadline: deadline,
                swapData: swapData
            });

        uint256 paymentTokenReceived = delegateSwap(
            swapModule,
            abi.encodeWithSignature(selector, abi.encode(swapParams))
        );

        _payWithToken(spritzPay, paymentToken, paymentTokenReceived);
    }

    function _payWithToken(address spritzPay, address token, uint256 amount) internal {
        ensureSpritzPayAllowance(spritzPay, token);
        ISpritzPay(spritzPay).payWithToken(address(token), amount, accountReference);
    }

    function ensureSpritzPayAllowance(address spritzPay, address token) internal {
        uint256 allowance = IERC20(token).allowance(address(this), spritzPay);
        if (allowance == 0) {
            IERC20(token).approve(spritzPay, type(uint256).max);
        }
    }

    function getDestinationAddresses() internal view returns (address spritzPay, address swapModule) {
        (spritzPay, swapModule) = IReceiverFactory(factory).getDestinationAddresses();
        if (spritzPay == address(0) || swapModule == address(0)) revert InvalidDestination();
    }

    function decodeSwapData(
        address swapModule,
        bytes calldata swapData
    ) internal view returns (address inputToken, address outputToken, address weth) {
        bytes memory data = abi.encodeWithSelector(ExactInputDelegateSwapModule.decodeSwapData.selector, swapData);

        (bool success, bytes memory result) = swapModule.staticcall(data);
        if (!success) revert DecodeFailure();

        (inputToken, outputToken, weth) = abi.decode(result, (address, address, address));
    }

    function delegateSwap(address target, bytes memory data) internal returns (uint256 paymentTokenReceived) {
        (bool success, bytes memory result) = target.delegatecall(data);
        if (!success || result.length == 0) {
            if (result.length == 0) {
                revert SwapFailure();
            } else {
                assembly {
                    let resultSize := mload(result)
                    revert(add(32, result), resultSize)
                }
            }
        }

        (paymentTokenReceived) = abi.decode(result, (uint256));
    }

    /**
     * @dev Withdraw deposited tokens to the given address
     * @param token Token to withdraw
     * @param to Target address
     */
    function sweep(IERC20 token, address to) external onlyController {
        token.transfer(to, token.balanceOf(address(this)));
    }

    /**
     * @dev Withdraw ETH to the given address
     * @param to Target address
     */
    function nativeSweep(address to) external onlyController {
        (bool success, ) = to.call{ value: address(this).balance }("");
        if (!success) revert FailedSweep();
    }

    receive() external payable {}
}
