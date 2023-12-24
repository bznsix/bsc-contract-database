// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IERC20 {
    function tranferWithLockPeriod(
        address to,
        uint256 amount,
        uint256 lockingPeriod
    ) external returns (bool);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


contract MultiSender {
    address public DMCT;
    address public owner;

    constructor(address _dmct) {
        DMCT = _dmct;
        owner = 0x0C76E38DeF4F982207B2B3831d34954B181a3945;
    }

    function MultiSend(
        address[] memory _wallets,
        uint256[] memory _amounts,
        address _contractAddress,
        uint256 _lockTime
    ) public {
        require(_wallets.length == _amounts.length, "Invalid Data length");
        
            uint256 totalAmount;
            for (uint256 i = 0; i < _amounts.length; i++) {
                totalAmount += _amounts[i];
            }
            if (_contractAddress != DMCT) {
            IERC20(_contractAddress).transferFrom(
                msg.sender,
                address(this),
                totalAmount
            );
        }

        require(IERC20(_contractAddress).balanceOf(address(this)) >= totalAmount, "Please load tokens on the contract");

        // Direct transfer
        for (uint256 i = 0; i < _amounts.length; i++) {
            if (_contractAddress == DMCT) {
                IERC20(_contractAddress).tranferWithLockPeriod(
                    _wallets[i],
                    _amounts[i],
                    _lockTime
                );
            } else {
                IERC20(_contractAddress).transfer(_wallets[i], _amounts[i]);
            }
        }
    }

    function retriveFund(address _contractAddress, uint256 _amount) public {
        require(msg.sender == owner, "Caller is not owner");
        IERC20(_contractAddress).transfer(owner, _amount);
    }
}

// ["0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB", "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4"]
// ["1000000000000000000", "5000000000000000000"]