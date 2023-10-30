// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface t {
    function test(address user) external;
}

contract Test2 {
    t public tt;

    function setT(address ttt) external{
        tt = t(ttt);
    }
    function k()external{
        tt.test(address(this));
    }
}
