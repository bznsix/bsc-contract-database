// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import '../token/IERC20.sol';
import '../utils/Admin.sol';

contract DeriBurnerBSC is Admin {

    address public constant deri = 0xe60eaf5A997DFAe83739e035b005A33AfdCc6df5;
    address public constant wormholeBSC = 0x15a5969060228031266c64274a54e02Fbd924AbF;
    address public constant wormholeETH = 0x6874640cC849153Cb3402D193C33c416972159Ce;

    constructor () {
        IERC20(deri).approve(wormholeBSC, type(uint256).max);
    }

    function bridgeDeriToEthereumBurner() external _onlyAdmin_ {
        uint256 balance = IERC20(deri).balanceOf(address(this));
        if (balance != 0) {
            IWormhole(wormholeBSC).freeze(balance, 1, wormholeETH);
        }
    }

}

interface IWormhole {
    function freeze(uint256 amount, uint256 toChainId, address toWormhole) external;
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

interface IERC20 {

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    event Transfer(address indexed from, address indexed to, uint256 amount);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import './IAdmin.sol';

abstract contract Admin is IAdmin {

    address public admin;

    modifier _onlyAdmin_() {
        require(msg.sender == admin, 'Admin: only admin');
        _;
    }

    constructor () {
        admin = msg.sender;
        emit NewAdmin(admin);
    }

    function setAdmin(address newAdmin) external _onlyAdmin_ {
        admin = newAdmin;
        emit NewAdmin(newAdmin);
    }

}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

interface IAdmin {

    event NewAdmin(address indexed newAdmin);

    function admin() external view returns (address);

    function setAdmin(address newAdmin) external;

}
