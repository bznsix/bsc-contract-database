// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;





library Address {

    function isContract(address account) internal view returns (bool) {
 
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }


    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }


    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, 'Address: low-level call failed');
    }


    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }


    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
    }

 
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'Address: call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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
// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;


contract Context {

    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;



interface IBEP20 {
  
    function totalSupply() external view returns (uint256);

   
    function decimals() external view returns (uint8);

  
    function symbol() external view returns (string memory);


    function name() external view returns (string memory);

 
    function getOwner() external view returns (address);

   
    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

 
 
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "./Context.sol";


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

 
    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }


    function owner() public view returns (address) {
        return _owner;
    }

  
    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }


    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }


    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }


    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;


import "./IBEP20.sol";
import "./SafeMath.sol";
import "./Address.sol";



library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            'SafeBEP20: approve from non-zero to non-zero allowance'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            'SafeBEP20: decreased allowance below zero'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }


    function _callOptionalReturn(IBEP20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, 'SafeBEP20: low-level call failed');
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), 'SafeBEP20: BEP20 operation did not succeed');
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

library SafeMath {
   
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
    }


    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }


    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }


    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
    }


    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "./helpers/Ownable.sol";
import "./helpers/SafeBEP20.sol";

contract HNRUSDController is Ownable {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    struct StableToken {
        uint256 deposited;
        uint256 withdrawn;
        uint256 fee;
        bool active;
    }

    mapping(address => StableToken) public stableTokens;

    IBEP20 public husdToken;
    address public feeTo;

    uint256 public defaultFee = 200;

    event BuyHNRUSD(address indexed token, uint256 amount);
    event SellHNRUSD(address indexed token, uint256 amount);
    event StableSwap(address indexed tokenIn, address indexed tokenOut, uint256 amount);

    constructor(address husd, address _feeTo) public {
        husdToken = IBEP20(husd);
        feeTo = _feeTo;
    }

    modifier tokenIsActive(address token) {
        require(stableTokens[token].active, "Token is not active");
        _;
    }

    function setFeeTo(address _feeTo) public onlyOwner {
        feeTo = _feeTo;
    }

    function setFee(address token, uint256 _fee) public onlyOwner {
        StableToken storage stable = stableTokens[token];
        stable.active = true;
        stable.fee = _fee;
    }

    function addStable(address token, uint256 _fee) public onlyOwner {
        StableToken storage stable = stableTokens[token];
        stable.active = true;
        stable.fee = _fee;
    }

    function setActive(address token, bool _active) public onlyOwner {
        StableToken storage stable = stableTokens[token];
        stable.active = _active;
    }

    function calculateFee(address token, uint256 amount) public view returns (uint256) {
        uint256 tokenFee = stableTokens[token].fee == 0 ? defaultFee : stableTokens[token].fee;
        uint256 minAmount = 1000 * (10 ** 18);

        if (amount <= minAmount) {
            return tokenFee;
        } else if (amount > minAmount && amount <= (minAmount * 10)) {
            return tokenFee.mul(4).div(5);
        } else if (amount > (minAmount * 10) && amount <= (minAmount * 25)) {
            return tokenFee.mul(3).div(5);
        } else if (amount > (minAmount * 25) && amount <= (minAmount * 100)) {
            return tokenFee.mul(2).div(5);
        } else if (amount > (minAmount * 100)) {
            return tokenFee.div(5);
        }
    }

    function sellHNRUSD(address token, uint256 amount) public tokenIsActive(token) {
        IBEP20 sToken = IBEP20(token);
        uint256 balance = sToken.balanceOf(address(this));
        require(balance >= amount, "Not enough balance");

        StableToken storage stable = stableTokens[token];
        uint256 sFEE = stable.fee == 0 ? defaultFee : stable.fee;

        husdToken.safeTransferFrom(msg.sender, address(this), amount);

        uint256 fee = amount.mul(sFEE).div(100000);

        sToken.safeTransfer(feeTo, fee);

        uint256 curAmount = amount.sub(fee);
        sToken.safeTransfer(msg.sender, curAmount);

        stable.withdrawn = stable.withdrawn.add(amount);

        emit SellHNRUSD(token, amount);
    }

    function buyHNRUSD(address token, uint256 amount) public tokenIsActive(token) {
        uint256 husdAmount = husdToken.balanceOf(address(this));
        require(husdAmount >= amount, "Not enough amount");

        StableToken storage stable = stableTokens[token];

        uint256 sFEE = calculateFee(token, amount);

        IBEP20 sToken = IBEP20(token);
        sToken.safeTransferFrom(msg.sender, address(this), amount);

        uint256 fee = amount.mul(sFEE).div(100000);

        sToken.safeTransfer(feeTo, fee);

        uint256 curAmount = amount.sub(fee);

        husdToken.safeTransfer(msg.sender, curAmount);

        stable.deposited = stable.deposited.add(amount);

        emit BuyHNRUSD(token, amount);
    }

    function stablesSwap(address stIn, address stOut, uint256 amount) public tokenIsActive(stIn) tokenIsActive(stOut) {
        require(IBEP20(stOut).balanceOf(address(this)) >= amount, "Not enough balance");

        IBEP20(stIn).safeTransferFrom(msg.sender, address(this), amount);

        uint256 totalFee = calculateFee(stIn, amount).add(calculateFee(stOut, amount)).mul(2);
        uint256 feeAmount = amount.mul(totalFee).div(100000);

        IBEP20(stIn).safeTransfer(feeTo, feeAmount);

        uint256 finalAmount = amount.sub(feeAmount);
        IBEP20(stOut).safeTransfer(msg.sender, finalAmount);

        stableTokens[stIn].deposited = stableTokens[stIn].deposited.add(amount);
        stableTokens[stOut].withdrawn = stableTokens[stOut].withdrawn.add(amount);

        emit StableSwap(stIn, stOut, amount);
    }

    function getReserves(address token) public onlyOwner {
        StableToken memory stable = stableTokens[token];
        require(stable.deposited == 0, "Stable Token can't be received");
        IBEP20(token).safeTransfer(msg.sender, IBEP20(token).balanceOf(address(this)));

    }
}