// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
interface IECore{
    function k()external;
}
contract Test4 {
    address public sender;
    address public from;

//    IECore public f;

    function test( address user) external{
       IECore(user).k();
    }
}
