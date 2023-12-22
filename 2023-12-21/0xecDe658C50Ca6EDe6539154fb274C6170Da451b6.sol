/**
 *Submitted for verification at testnet.bscscan.com on 2023-06-28
*/

/**
 *Submitted for verification at BscScan.com on 2020-09-14
 */

pragma solidity ^0.4.25;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract Multisend {
    uint256 public FEE_SERVICE;
    address public WALLET_RECEIVER;
    address private owner;

    constructor(uint256 _FEE_SERVICE, address _WALLET_RECEIVER) public {
        owner = msg.sender;
        FEE_SERVICE = _FEE_SERVICE;
        WALLET_RECEIVER = _WALLET_RECEIVER;
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the contract owner can call this function."
        );
        _;
    }

    function Owner() public view returns (address) {
        return owner;
    }

    function multisendTokenBase(address[] recipients, uint256[] values)
        external
        payable
    {
        uint256 totalValue = msg.value;
        require(totalValue >= FEE_SERVICE, "Insufficient Balance Fee");

        uint256 actualValue = totalValue - FEE_SERVICE;
        uint256 recipientCount = recipients.length;

        for (uint256 i = 0; i < recipientCount; i++) {
            require(actualValue >= values[i], "Insufficient value");
            recipients[i].transfer(values[i]);
            actualValue -= values[i];
        }

        if (FEE_SERVICE > 0) {
            WALLET_RECEIVER.transfer(FEE_SERVICE);
        }
        if (actualValue > 0) {
            msg.sender.transfer(actualValue);
        }
    }

    function multisendToken(
        IERC20 token,
        address[] recipients,
        uint256[] values
    ) external payable {
        require(msg.value >= FEE_SERVICE, "Insufficient Balance Fee");
        uint256 total = 0;
        for (uint256 i = 0; i < recipients.length; i++) total += values[i];
        require(token.transferFrom(msg.sender, address(this), total));
        for (i = 0; i < recipients.length; i++)
            require(token.transfer(recipients[i], values[i]));

        bool feeTransferSuccess = WALLET_RECEIVER.call.value(FEE_SERVICE)("");
        require(feeTransferSuccess, "Gas fee transfer failed");
    }

    function rescueStuckToken(address _token, address _to) external onlyOwner {
        require(_token != address(this), "Invalid token");
        uint256 _amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(_to, _amount);
    }

    function rescueStuckTokenBase() external onlyOwner {
        bool success;
        (success) = address(msg.sender).call.value(address(this).balance)("");
    }

    function multisendTokenAndTokenBase(
        IERC20 token,
        address[] recipients,
        uint256[] tokenValues,
        uint256[] bnbValues
    ) external payable {
        require(msg.value >= FEE_SERVICE, "Insufficient BNB fee");
         uint256 total = 0;
        for (uint256 i = 0; i < recipients.length; i++) total += tokenValues[i];
        require(token.transferFrom(msg.sender, address(this), total));
        for (i = 0; i < recipients.length; i++)
            require(token.transfer(recipients[i], tokenValues[i]));

        uint256 totalBNB = msg.value - FEE_SERVICE;
        require(totalBNB >= bnbValues[0], "Insufficient BNB value");
        for (i = 0; i < recipients.length; i++) {
            require(bnbValues[i] > 0, "BNB value must be greater than 0");
            require(totalBNB >= bnbValues[i], "Insufficient BNB value");
            recipients[i].transfer(bnbValues[i]);
            totalBNB -= bnbValues[i];
        }

        bool feeTransferSuccess = WALLET_RECEIVER.call.value(FEE_SERVICE)("");
        require(feeTransferSuccess, "Gas fee transfer failed");

        // Return excess BNB to the sender
        if (totalBNB > 0) {
            msg.sender.transfer(totalBNB);
        }
    }

    

    function updateFeeService(uint256 _FEE_SERVICE) public onlyOwner {
        FEE_SERVICE = _FEE_SERVICE;
    }

    function updateWalletReceiver(address _WALLET_RECEIVER) public onlyOwner {
        WALLET_RECEIVER = _WALLET_RECEIVER;
    }

   
}