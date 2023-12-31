pragma solidity =0.6.6;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract KoinLoopRouter {

    address internal immutable owner;
    uint256 internal fee;
    uint256 internal withdrawablebusd;

    IERC20 internal busd;

    constructor(address _BUSDADDRESS) public {
        owner = msg.sender;
        fee = 98;
        withdrawablebusd = 0;
        busd = IERC20(_BUSDADDRESS);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    event Received(address sender, uint amount);
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    function getPercent(uint256 number) internal returns (uint256) {
        uint256 reward = (number * fee) / 100;
        withdrawablebusd = withdrawablebusd + (number - reward);
        return (number * fee) / 100;
    }

    function sendReward(address recipient, uint256 amount) public onlyOwner {
        uint256 reward = getPercent(amount);
        require(busd.transfer(recipient, reward), "BUSD transfer failed");
    }
    
    function getWithdrawableBusd() public view onlyOwner returns (uint256) {
        return withdrawablebusd;
    }

    function withdrawMoney(address recipient) external onlyOwner {
        require(busd.transfer(recipient, withdrawablebusd), "BUSD transfer failed");
    }
}