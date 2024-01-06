// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

interface IOneIndex {
    function tradingFee() external view returns (uint256);

    function gasRefund() external view returns (uint256);

    function owner() external view returns (address);

    struct asset {
        address token;
        uint256 amount;
        uint256 proportion;
    }

    function getFullIndex() external view returns (asset[] memory);
}

interface IPancakeSwapRouter {
    function getAmountsOut(
        uint amountIn,
        address[] memory path
    ) external view returns (uint[] memory);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

contract TradeOneIndex {
    IOneIndex public oneIndex;
    IPancakeSwapRouter public pancakeswapRouter;
    IERC20 public usdt;

    address public owner;
    address public oneIndexAddress;
    address public oneIndexTokenAddress =
        0x84FaAbDC2b8cc4e1993b4B6A09Df8dCDB75CBCbC;

    bool private isLocked = false;

    uint256 constant APPROVAL_AMOUNT = 100000000 * 10 ** 18;
    address constant USDT_ADDRESS = 0x55d398326f99059fF775485246999027B3197955;
    address constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    address constant PANCAKESWAP_ROUTER_ADDRESS =
        0x10ED43C718714eb63d5aA57B78B54704E256024E;

    struct Position {
        address owner;
        uint256 amount;
        bool isOpen;
    }

    mapping(uint256 => Position) public positions;
    mapping(uint256 => uint256[]) public assetAmounts;
    uint256 public nextPositionId;

    event PositionOpened(
        uint256 positionId,
        address owner,
        uint256 amount,
        uint256 tradingFees
    );

    event PositionClosed(
        uint256 positionId,
        address owner,
        uint256 returnAmount,
        uint256 tradingFees
    );

    constructor(address _oneIndexAddress) {
        owner = msg.sender;
        oneIndex = IOneIndex(_oneIndexAddress);
        oneIndexAddress = _oneIndexAddress;
        usdt = IERC20(USDT_ADDRESS);
        pancakeswapRouter = IPancakeSwapRouter(PANCAKESWAP_ROUTER_ADDRESS);
        nextPositionId = 1;
        approveAllTokens();
    }

    modifier _locker() {
        require(isLocked == false, "Locked");
        isLocked = true;
        _;
        isLocked = false;
    }

    modifier _onlyOwner() {
        require(msg.sender == owner, "Only Owner");
        _;
    }

    function setOwner(address payable _newOwner) public _onlyOwner {
        owner = _newOwner;
    }

    function resetOneIndex(address _newIndexAddress) public _onlyOwner {
        oneIndexAddress = _newIndexAddress;
        oneIndex = IOneIndex(_newIndexAddress);
    }

    function resetOneIndexTokenAddress(
        address _newOneIndexTokenAddress
    ) public _onlyOwner {
        oneIndexTokenAddress = _newOneIndexTokenAddress;
    }

    function approveAllTokens() public _onlyOwner {
        usdt.approve(PANCAKESWAP_ROUTER_ADDRESS, APPROVAL_AMOUNT);
        IOneIndex.asset[] memory indexComposition = oneIndex.getFullIndex();
        for (uint256 i = 0; i < indexComposition.length; i++) {
            IERC20(indexComposition[i].token).approve(
                PANCAKESWAP_ROUTER_ADDRESS,
                APPROVAL_AMOUNT
            );
        }
    }

    function openPosition(
        uint256 _grossAmountInUSDT,
        uint256[] calldata _minAmounts
    ) public _locker {
        //Check USDT Balance and Allowance
        require(
            usdt.balanceOf(msg.sender) >= _grossAmountInUSDT,
            "Insufficient Balance"
        );

        require(
            usdt.allowance(msg.sender, address(this)) >= _grossAmountInUSDT,
            "Insufficient Allowance"
        );

        //Move USDT to Contract
        usdt.transferFrom(msg.sender, address(this), _grossAmountInUSDT);

        //Get list of assets that make up the index
        IOneIndex.asset[] memory indexComposition = oneIndex.getFullIndex();
        assetAmounts[nextPositionId] = new uint256[](indexComposition.length);

        //Calculate Amounts in USDT after commissions
        uint256 commission = computeCommission(_grossAmountInUSDT);
        uint256 amountInUSDT = getNetAmount(_grossAmountInUSDT, commission);

        //Swap USDT for assets according to index composition
        for (uint256 i = 0; i < indexComposition.length; i++) {
            assetAmounts[nextPositionId][i] = swapUSDTToAsset(
                (amountInUSDT * (indexComposition[i].proportion / 10 ** 18)) /
                    100,
                indexComposition[i].token,
                address(this),
                _minAmounts[i]
            );
        }

        //Register Position
        positions[nextPositionId] = Position(
            msg.sender,
            _grossAmountInUSDT,
            true
        );

        //Burn OneIndex Tokens
        burn1IDX(commission, _minAmounts[_minAmounts.length - 1]);

        //Emit Event
        emit PositionOpened(
            nextPositionId,
            msg.sender,
            _grossAmountInUSDT,
            commission * 2
        );

        //Increase Position ID
        nextPositionId++;
    }

    function closePosition(
        uint256 positionId,
        uint256[] calldata _minAmounts
    ) public _locker {
        require(positions[positionId].owner == msg.sender, "Not the owner");
        require(positions[positionId].isOpen, "Position already closed");

        uint256 totalReturnAmount = 0;
        for (uint256 i = 0; i < assetAmounts[positionId].length; i++) {
            IOneIndex.asset memory asset = oneIndex.getFullIndex()[i];
            totalReturnAmount += swapAssetToUSDT(
                assetAmounts[positionId][i],
                asset.token,
                msg.sender,
                _minAmounts[i]
            );
        }

        //Update Position Status
        positions[positionId].isOpen = false;

        //Emit Event
        emit PositionClosed(positionId, msg.sender, totalReturnAmount, 0);
    }

    function swapUSDTToAsset(
        uint256 _amountIn,
        address _assetAddress,
        address _beneficiary,
        uint256 _minAmount
    ) private returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = USDT_ADDRESS;
        path[1] = _assetAddress;

        uint[] memory amountsOut = pancakeswapRouter.swapExactTokensForTokens(
            _amountIn,
            _minAmount,
            path,
            _beneficiary,
            block.timestamp + 600
        );
        return amountsOut[1];
    }

    function burn1IDX(
        uint256 _commission,
        uint256 _minIdxAmount
    ) public returns (bool) {
        address[] memory path = new address[](2);
        path[0] = USDT_ADDRESS;
        path[1] = oneIndexTokenAddress;

        pancakeswapRouter.swapExactTokensForTokens(
            _commission,
            _minIdxAmount,
            path,
            BURN_ADDRESS,
            block.timestamp + 600
        );
        return true;
    }

    function swapAssetToUSDT(
        uint256 _amountIn,
        address _assetAddress,
        address _beneficiary,
        uint256 _minAmount
    ) private returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = _assetAddress;
        path[1] = USDT_ADDRESS;

        //IERC20(_assetAddress).approve(PANCAKESWAP_ROUTER_ADDRESS, amounts[0]);
        uint[] memory amountsOut = pancakeswapRouter.swapExactTokensForTokens(
            _amountIn,
            _minAmount,
            path,
            _beneficiary,
            block.timestamp + 600
        );
        return amountsOut[1];
    }

    function getAssetAmounts(
        uint256 positionId
    ) public view returns (uint256[] memory) {
        return assetAmounts[positionId];
    }

    function getNetAmount(
        uint256 _amount,
        uint256 _commission
    ) public view returns (uint256) {
        uint256 netAmount = _amount -
            (_commission * 2) -
            (oneIndex.gasRefund() * 10 ** 18);
        return netAmount;
    }

    function computeCommission(uint256 _amount) public view returns (uint256) {
        uint256 netAmount = _amount - (oneIndex.gasRefund() * 10 ** 18);
        uint256 commission = (netAmount * oneIndex.tradingFee()) / 1000;
        return commission;
    }

    function computePositionMarketValue(
        uint256 _id
    ) public view returns (uint256) {
        IOneIndex.asset[] memory indexComposition = oneIndex.getFullIndex();
        uint256[] memory localAssetAmounts = getAssetAmounts(_id);

        uint256 totalValue = 0;

        for (uint256 i = 0; i < localAssetAmounts.length; i++) {
            address[] memory path = new address[](2);
            path[0] = address(indexComposition[i].token); // Asset token address
            path[1] = USDT_ADDRESS; // USDT token address

            uint[] memory amountsOut = pancakeswapRouter.getAmountsOut(
                localAssetAmounts[i],
                path
            );
            totalValue += amountsOut[1]; // Amount in USDT
        }

        return totalValue;
    }

    function userWithdrawsUSDT(
        address _beneficiary,
        uint256 _fee,
        uint256 _netAmount
    ) public {
        //Check USDT Balance and Allowance
        uint256 totAmount = _fee + _netAmount;

        require(
            usdt.balanceOf(msg.sender) >= totAmount,
            "Insufficient Balance"
        );

        require(
            usdt.allowance(msg.sender, address(this)) >= totAmount,
            "Insufficient Allowance"
        );

        //Store msg.sender in local variable to save gas
        address spender = msg.sender;

        //Transfer USDT to beneficiary
        usdt.transferFrom(spender, _beneficiary, _netAmount);

        //Pay commission
        address feeBeneficiary = oneIndex.owner();
        usdt.transferFrom(spender, feeBeneficiary, _fee);
    }

    function adminWithdrawsCommissions(uint256 _amount) public _onlyOwner {
        require(usdt.balanceOf(address(this)) >= _amount, "Excessive Amount");
        usdt.transfer(msg.sender, _amount);
    }
}