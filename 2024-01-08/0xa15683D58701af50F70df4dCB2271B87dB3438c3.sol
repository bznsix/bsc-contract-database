// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.9;
library TransferHelper {

    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}
contract Airdrop{
    address public Owner;  
    constructor(){
        Owner = msg.sender; 
    }
    modifier onlyOwner {
        require(msg.sender == Owner,"Its restricted");
        _; 
    }
    function airdrop(address[] calldata Addresses , address tokenaddr, uint[] calldata amounts) external {
        require(Addresses.length == amounts.length,"Addresses length mismatch"); 
        uint length = Addresses.length; 
        for(uint i = 0; i < length; i++){
            TransferHelper.safeTransferFrom(tokenaddr,msg.sender,Addresses[i],amounts[i]); 
        }
    }
    function airdropEth(address[] calldata Addresses, uint[] calldata amounts)external{
        require(Addresses.length == amounts.length,"Addresses length mismatch"); 
        uint length = Addresses.length; 
        for(uint i = 0; i < length; i++){
            TransferHelper.safeTransferETH(Addresses[i],amounts[i]); 
        }
    }
}