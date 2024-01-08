pragma solidity ^0.4.24;

contract BNGold {
    function buy(address _referredBy) public payable returns(uint256);
    function exit() public;
}

contract DistributeDividends {
    BNGold BNGoldContract = BNGold(0x66cB2D528A3380Bd919245D8812b45B03D421Ce5);
    
    /// @notice Any funds sent here are for dividend payment.
    function () public payable {
    }
    
    /// @notice Distribute dividends to the BNGold contract. Can be called
    ///     repeatedly until practically all dividends have been distributed.
    /// @param rounds How many rounds of dividend distribution do we want?
    function distribute(uint256 rounds) public {
        for (uint256 i = 0; i < rounds; i++) {
            if (address(this).balance < 0.001 ether) {
                // Balance is very low. Not worth the gas to distribute.
                break;
            }
            
            BNGoldContract.buy.value(address(this).balance)(msg.sender);
            BNGoldContract.exit();
        }
  }
}