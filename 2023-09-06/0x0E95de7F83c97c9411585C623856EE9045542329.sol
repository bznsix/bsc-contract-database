// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;
pragma experimental ABIEncoderV2;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function transferFrom(address owner , address recipient,uint256 amount)
        external
        returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract multisender {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function Send(
        address token,
        address[] memory _users,
        uint256[] memory _amounts
    ) public onlyOwner {
      require(_amounts.length == _users.length, "length of amounts is not the same as the number of users");
        for (uint256 i = 0; i < _users.length; i++) {
            IERC20(token).transferFrom(owner, _users[i], _amounts[i]);
        }
    }


}