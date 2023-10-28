// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract Counter {

    uint256 number = 0;
    event Counted(uint256 numbercounted);
    /**
     * @dev Store value in variable
     */
    function add() public {
        number = number + 1;
        emit Counted(number);
    }

    /**
     * @dev Return value 
     * @return value of 'number'
     */
    function retrieve() public view returns (uint256){
        return number;
    }
}