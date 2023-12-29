/**

FullStackDev  = "https://t.me/Italo_Dev_Bsc"

*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IBEP20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function decimals() external view returns (uint8);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract Shinepresale {
    address public _owner;
    address public _contract;
    uint256 public priceBNB;
    uint256 public priceUSDT;
    uint256 public minbuyBNB;
    uint256 public minbuyUSDT;

    uint256 public BNBraised;
    uint256 public USDTraised;

    uint256 public uToken; //tokenFromSale 0 bnb 1 busd 2 usdt data 11
    mapping(uint256 => address) private _uToken;

    modifier onlyOwner() {
        require(
            _owner == msg.sender,
            "Ownable: only owner can call this function"
        );
        _;
    }

    constructor(

        address tokenToSell,
        address contractOwner,
        uint256 _bnbPrice,
        uint256 _usdtPrice,
        uint256 _minbuyBNB,
        uint256 _minbuyUSDT
    ) payable {
        _contract = tokenToSell;
        _owner = contractOwner;

        priceBNB = _bnbPrice;
        priceUSDT = _usdtPrice;
        minbuyBNB = _minbuyBNB;
        minbuyUSDT = _minbuyUSDT;

        _uToken[0] = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c); // bnb
        _uToken[1] = address(0x55d398326f99059fF775485246999027B3197955); // usdt
    }

    receive() external payable {}

    function getAmountOutBNB(uint256 _amount) public view returns (uint256) {
        return ((_amount * (1 * (10**IBEP20(_contract).decimals()))) /
            priceBNB);
    }

    function getAmountOutUSDT(uint256 _amount) public view returns (uint256) {
        return ((_amount * (1 * (10**IBEP20(_contract).decimals()))) /
            priceUSDT);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function set(
        uint256 _bnbPrice,
        uint256 _usdtPrice,
        uint256 _minbuyBNB,
        uint256 _minbuyUSDT
    ) public onlyOwner {
        priceBNB = _bnbPrice;
        priceUSDT = _usdtPrice;
        minbuyBNB = _minbuyBNB;
        minbuyUSDT = _minbuyUSDT;
    }

    function buyTokens(address _beneficiary) public payable {
        require(msg.value >= minbuyBNB, "buy more");

        IBEP20(_contract).transfer(_beneficiary, getAmountOutBNB(msg.value));
        payable(_owner).transfer(msg.value);
        BNBraised += msg.value;
        emit TokenPurchase(
            msg.sender,
            _beneficiary,
            msg.value,
            getAmountOutBNB(msg.value)
        );
    }

    function buyTokensWithUSDT(address _beneficiary, uint256 _usdtAmount)
        external
    {
        require(_usdtAmount >= minbuyUSDT, "buy more");
        IBEP20 token = IBEP20(_uToken[1]);
        uint256 bold = token.balanceOf(address(this));
        token.transferFrom(msg.sender, address(this), _usdtAmount);
        uint256 bnew = token.balanceOf(address(this));
        uint256 ar = bnew - bold;
        require(ar >= _usdtAmount, "You need pay");

        IBEP20(_contract).transfer(_beneficiary, getAmountOutUSDT(ar));
        IBEP20(_uToken[1]).transfer(_owner, ar);

        USDTraised += ar;
        emit TokenPurchase(msg.sender, _beneficiary, ar, getAmountOutUSDT(ar));
    }

    function cancel() public onlyOwner {
        IBEP20(_contract).transfer(
            owner(),
            IBEP20(_contract).balanceOf(address(this))
        );
        emit _cancel(block.timestamp);
    }

    event TokenPurchase(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount
    );

    event _cancel(uint256 when);

}