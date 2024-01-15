// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IPancakeV3SwapCallback {
    function pancakeV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;
}

interface IV3SwapRouter is IPancakeV3SwapCallback {
    function multicall(uint256 deadline, bytes[] calldata data) external payable returns (bytes[] memory results);

    function unwrapWETH9(uint256 amountMinimum, address recipient) external payable;

    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);
}

contract Swap is Ownable {
    using SafeMath for uint256;

    uint256 commissionRate;
    uint256 commissionRateDiv;

    address routerAddress;
    address wbnb;

    address recipientForETH;

    constructor() {
        routerAddress = 0x13f4EA83D0bd40E75C8222255bc855a974568Dd4;
        wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        recipientForETH = 0x0000000000000000000000000000000000000002;
        commissionRate = 5;
        commissionRateDiv = 1000;
    }


    function swapSingle(
        address _token0,
        address _token1,
        uint24 _fee,
        address _recipient,
        uint256 _amountIn,
        uint256 _amountOutMinimum,
        uint160 _sqrtPriceLimitX96
    ) external payable returns (uint256 amountOut) {
        uint256 value = 0;
        if (_token0 != wbnb) {
            IERC20(_token0).transferFrom(msg.sender, address(this), _amountIn);
            _amountIn = _amountIn.mul(commissionRateDiv.sub(commissionRate)).div(commissionRateDiv);
        } else {
            value = msg.value.mul(commissionRateDiv.sub(commissionRate)).div(commissionRateDiv);
            _amountIn = value;
        }

        amountOut = IV3SwapRouter(routerAddress).exactInputSingle{value: value}(IV3SwapRouter.ExactInputSingleParams(
            _token0,
            _token1,
            _fee,
            _recipient,
            _amountIn,
            _amountOutMinimum,
            _sqrtPriceLimitX96
        ));
    }

    function swap(
        bytes calldata _path,
        address _recipient,
        uint256 _amountIn,
        uint256 _amountOutMinimum,
        address _token0
    ) external payable returns (uint256 amountOut) {
        uint256 value = 0;
        if (_token0 != wbnb) {
            IERC20(_token0).transferFrom(msg.sender, address(this), _amountIn);
            _amountIn = _amountIn.mul(commissionRateDiv.sub(commissionRate)).div(commissionRateDiv);
        } else {
            value = msg.value.mul(commissionRateDiv.sub(commissionRate)).div(commissionRateDiv);
            _amountIn = value;
        }

        amountOut = IV3SwapRouter(routerAddress).exactInput{value: value}(IV3SwapRouter.ExactInputParams(
            _path,
            _recipient,
            _amountIn,
            _amountOutMinimum
        ));
    }

    function multicall(
        bytes calldata _path,
        address _recipient,
        uint256 _amountIn,
        uint256 _amountOutMinimum,
        address _token0
    ) external payable {
        IERC20(_token0).transferFrom(msg.sender, address(this), _amountIn);

        bytes[] memory calles = new bytes[](2);

        calles[0] = encodeExactInputCall(
            _path,
            recipientForETH,
            _amountIn.mul(commissionRateDiv.sub(commissionRate)).div(commissionRateDiv),
            _amountOutMinimum
        );
        calles[1] = encodeUnwrapWETH9(_amountOutMinimum,_recipient);

        IV3SwapRouter(routerAddress).multicall(block.timestamp+300, calles);
    }

    function multicallSingle(
        address _token0,
        address _token1,
        uint24 _fee,
        address _recipient,
        uint256 _amountIn,
        uint256 _amountOutMinimum,
        uint160 _sqrtPriceLimitX96
    ) external payable {
        IERC20(_token0).transferFrom(msg.sender, address(this), _amountIn);

        bytes[] memory calles = new bytes[](2);

        calles[0] = encodeExactInputSingleCall(
            _token0,
            _token1,
            _fee,
            recipientForETH,
            _amountIn.mul(commissionRateDiv.sub(commissionRate)).div(commissionRateDiv),
            _amountOutMinimum,
            _sqrtPriceLimitX96
        );
        calles[1] = encodeUnwrapWETH9(_amountOutMinimum,_recipient);

        IV3SwapRouter(routerAddress).multicall(block.timestamp+300,calles);
    }

    function encodeExactInputCall(
        bytes calldata _path,
        address _recipient,
        uint256 _amountIn,
        uint256 _amountOutMinimum
    ) public view returns (bytes memory) {
        return abi.encodeWithSelector(IV3SwapRouter(routerAddress).exactInput.selector, 
            IV3SwapRouter.ExactInputParams(
                _path,
                _recipient,
                _amountIn.mul(commissionRateDiv.sub(commissionRate)).div(commissionRateDiv),
                _amountOutMinimum
            )
        );
    }

    function encodeExactInputSingleCall(
        address _token0,
        address _token1,
        uint24 _fee,
        address _recipient,
        uint256 _amountIn,
        uint256 _amountOutMinimum,
        uint160 _sqrtPriceLimitX96
    ) public view returns (bytes memory) {
        return abi.encodeWithSelector(IV3SwapRouter(routerAddress).exactInputSingle.selector, 
            IV3SwapRouter.ExactInputSingleParams(
                _token0,
                _token1,
                _fee,
                _recipient,
                _amountIn.mul(commissionRateDiv.sub(commissionRate)).div(commissionRateDiv),
                _amountOutMinimum,
                _sqrtPriceLimitX96
            )
        );
    }

    function encodeUnwrapWETH9(
        uint256 _amount, address _recipient
    ) public view returns (bytes memory) {
        return abi.encodeWithSelector(IV3SwapRouter(routerAddress).unwrapWETH9.selector, 
            _amount,
            _recipient
        );
    }

    function approve(address _token, uint256 _amount) external {
        IERC20(_token).approve(routerAddress, _amount);
    }

    // only owner

    function setCommission(uint256 _commissionRate, uint256 _commissionRateDiv) public onlyOwner {
        commissionRate = _commissionRate;
        commissionRateDiv = _commissionRateDiv;
    }

    function setRouterAddress(address _routerAddress) public onlyOwner {
        routerAddress = _routerAddress;
    }

    function setRecipientForEth(address _token) public onlyOwner {
        IERC20(_token).transfer(msg.sender, IERC20(_token).balanceOf(address(this)));
    }

    function withdraw(address _token) public onlyOwner {
        IERC20(_token).transfer(msg.sender, IERC20(_token).balanceOf(address(this)));
    }

    function withdrawEth() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}