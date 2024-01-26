// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;  
  
interface IERC20 {  
    function balanceOf(address account) external view returns (uint256);  
    function transfer(address recipient, uint256 amount) external returns (bool);  
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);  
}  
  
contract BatchTransfer {  
    function batchTransferETH(address payable[] memory _recipients, uint256[] memory _amounts) public payable {  
        require(_recipients.length == _amounts.length, "Number of recipients and amounts should be equal");  
        uint256 totalAmount = 0;  
        for (uint i = 0; i < _recipients.length; i++) {  
            // Consider adding a check here to confirm the recipient received the amount.  
            _recipients[i].transfer(_amounts[i]);  
            totalAmount += _amounts[i];  
        }  
        require(totalAmount == msg.value, "Insufficient funds for transfer");  
    }  
  
    function batchTransferERC20(IERC20 _token, address[] memory _recipients, uint256[] memory _amounts) public {  
        require(_recipients.length == _amounts.length, "Number of recipients and amounts should be equal");  
        uint256 totalAmount = 0;  
        for (uint i = 0; i < _recipients.length; i++) {  
            require(_token.balanceOf(msg.sender) >= _amounts[i], "Insufficient balance for transfer");  
            bool success = false;  
            // Consider adding a loop to confirm successful transfer.  
            success = _token.transferFrom(msg.sender, _recipients[i], _amounts[i]);  
            require(success, "Transfer failed");  
            totalAmount += _amounts[i];  
        }  
        require(totalAmount > 0, "Transfer amount must be greater than 0");  
    }  
  
    function checkERC20Balance(IERC20 _token) public view returns (uint256) {  
        return _token.balanceOf(address(this));  
    }  
}