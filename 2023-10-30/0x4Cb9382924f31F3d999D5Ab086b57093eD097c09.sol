// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IoldSell {
    function binder(address, uint256) external view returns (address);

    function bought(address) external view returns (bool);

    function getBinderLength(address account) external view returns (uint256);

    function inviter(address) external view returns (address);

    function rewards(address) external view returns (uint256);

    function teamNum(address) external view returns (uint256);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface ISwapRouter {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

contract Selling is Ownable {
    uint256 private constant MAX = ~uint256(0);
    uint256 private total_price = 100 * 10 ** 18;
    uint256 private buy_amount = 50 * 10 ** 18;
    uint256 private inviter_rewards = 30 * 10 ** 18;
    uint256 private top_inviter_rewards = 20 * 10 ** 18;

    address private immutable usdtAddress;
    address private immutable wbnbAddress;
    address private immutable defaultAddress;
    address private immutable oldAddress;
    address public immutable salecoin;

    mapping(address => address) public inviter;
    mapping(address => address[]) public binder;
    mapping(address => uint256) public teamNum;
    mapping(address => uint256) public rewards;

    mapping(address => bool) public bought;

    ISwapRouter private _router;
    IERC20 USDT;

    bool public status;
    IoldSell _oldsell;

    constructor() {
        _router = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        usdtAddress = 0x55d398326f99059fF775485246999027B3197955;
        wbnbAddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        salecoin = 0x299ECC384ded931a8F611B215dbfd370B5E1CCf3;
        defaultAddress = 0x5801ec90200bbCa54ACB82af0a4Af82365A93955;
        oldAddress = 0x381C59C2d4e9dF4D0D4D620D79F81D3b97D96767;
        _oldsell = IoldSell(oldAddress);

        USDT = IERC20(usdtAddress);
        USDT.approve(address(_router), MAX);
        USDT.approve(owner(), MAX);
    }

    function Buy(address _inviter) public {
        require(status, "not open");
        require(
            bought[_inviter] || _inviter == defaultAddress,
            "invalid inviter"
        );
        address buyer = msg.sender;
        require(!bought[buyer], "Only buy once");

        USDT.transferFrom(buyer, address(this), total_price);
        SwapTokenForBuyer(buyer);
        bought[buyer] = true;

        address top_inviter;
        top_inviter = inviter[_inviter];
        if (top_inviter == address(0)) {
            top_inviter = defaultAddress;
        } else {
            teamNum[top_inviter] += 1;
        }

        USDT.transfer(_inviter, inviter_rewards);
        USDT.transfer(top_inviter, top_inviter_rewards);
        rewards[_inviter] += inviter_rewards;
        rewards[top_inviter] += top_inviter_rewards;

        inviter[buyer] = _inviter;
        binder[_inviter].push(buyer);
        teamNum[_inviter] += 1;
    }

    function SwapTokenForBuyer(address _buyer) private {
        address[] memory path = new address[](3);
        path[0] = usdtAddress;
        path[1] = wbnbAddress;
        path[2] = salecoin;
        _router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            buy_amount,
            0,
            path,
            _buyer,
            block.timestamp
        );
    }

    function updateStatus(bool _status) public onlyOwner {
        status = _status;
    }

    function updateParams(
        uint256 _total_price,
        uint256 _buy_amount,
        uint256 _inviter_rewards,
        uint256 _top_inviter_rewards
    ) public onlyOwner {
        require(
            _buy_amount + _inviter_rewards + _top_inviter_rewards ==
                _total_price,
            "Wrong parameter"
        );
        total_price = _total_price;
        buy_amount = _buy_amount;
        inviter_rewards = _inviter_rewards;
        top_inviter_rewards = _top_inviter_rewards;
    }

    function batchSyncAddressData(address[] calldata _addr) public onlyOwner {
        uint256 _len = _addr.length;
        for (uint256 i = 0; i < _len; i++) {
            syncAddressData(_addr[i]);
        }
    }

    function syncAddressData(address addr) public onlyOwner {
        teamNum[addr] = _oldsell.teamNum(addr);
        inviter[addr] = _oldsell.inviter(addr);
        rewards[addr] = _oldsell.rewards(addr);
        bought[addr] = _oldsell.bought(addr);
        uint256 _len = _oldsell.getBinderLength(addr);
        for (uint256 i = 0; i < _len; i++) {
            address binder_addr = _oldsell.binder(addr, i);
            binder[addr].push(binder_addr);
        }
    }

    function setAddressData(
        address addr,
        bool _bought,
        address _inviter,
        uint256 _rewards,
        uint256 _teamNum
    ) public onlyOwner {
        teamNum[addr] = _teamNum;
        inviter[addr] = _inviter;
        rewards[addr] = _rewards;
        bought[addr] = _bought;
    }

    function addAddressBinders(
        address addr,
        address[] calldata _binders
    ) public onlyOwner {
        uint256 _len = _binders.length;
        for (uint256 i = 0; i < _len; i++) {
            binder[addr].push(_binders[i]);
        }
    }

    function delAddressBinders(address addr) public onlyOwner {
        delete binder[addr];
    }

    function getBinderLength(address account) public view returns (uint256) {
        return binder[account].length;
    }
}