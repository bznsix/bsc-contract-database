// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Contract {

    address public manager;
    address public rAdmin;
    address public miner;

    uint256 public _asset_rate;
    uint256 public _miner_rate;

    constructor(address _receive,address _miner) {
        manager = msg.sender;
        rAdmin = _receive;
        miner = _miner;
        _asset_rate = 80;
        _miner_rate = 20;
    }

    // ----------------------------------------------------------------------------------------------------
    // recharge
    // ----------------------------------------------------------------------------------------------------

    struct RechargeRecord { IERC20 token; uint256 orderId; uint256 amount; uint times; }
    mapping (address => RechargeRecord[]) _rechargeRecords;

    // recharge of user
    function buy(IERC20 _token, uint256 _orderId, uint256 _amount) public {
        require(IERC20(_token).balanceOf(msg.sender) >= _amount, "the balanceOf address is not enough !!");
        require(IERC20(_token).allowance(msg.sender, address(this)) >= _amount, "the allowance is not enough !!");

        uint _asset = _amount*_asset_rate/100;
        uint _miner = _amount*_miner_rate/100;
        //按比率转到资金钱包和运营钱包
        IERC20(_token).transferFrom(msg.sender, rAdmin, _asset);
        IERC20(_token).transferFrom(msg.sender, miner, _miner);

        _rechargeRecords[msg.sender].push(RechargeRecord(_token, _orderId, _amount, block.timestamp));
    }

    // records of recharge
    function buyRecords(address _addr) view public returns (RechargeRecord[] memory) {
        return _rechargeRecords[_addr];
    }

    // ----------------------------------------------------------------------------------------------------
    // manager
    // ----------------------------------------------------------------------------------------------------

    // only manager
    modifier onlyManager() {
        require(msg.sender == manager);
        _;
    }

    // set manager
    function setManager(address _addr) public onlyManager returns(address) {
        manager = _addr;
        return manager;
    }

    // set receive
    function setReceive(address _addr) public onlyManager returns(address) {
        rAdmin = _addr;
        return rAdmin;
    }

    // set rate
    function setRate(uint256 asset_rate,uint256 miner_rate) public onlyManager returns(uint256, uint256) {
        _asset_rate = asset_rate;
        _miner_rate = miner_rate;
        return (_asset_rate,_miner_rate);
    }

    // get rate
    function getRate() view public returns(uint256, uint256) {
        return (_asset_rate,_miner_rate);
    }

    // batch transfer of manager
    function batchTransfer(IERC20 _token, address[] memory _tos, uint256[] memory _amounts, uint256[] memory _total) public {
        require(_tos.length > 0, "the addresses is empty !!");
        require(_amounts.length > 0, "the amount is empty !! ");
        require(_total.length > 0, "the amount is empty !! ");
        require(_tos.length == _amounts.length, "the tos length unequal to amounts length !!");
        require(_tos.length == _total.length, "the tos length unequal to total length !!");

        uint256 _total_recive = 0;
        uint256 _total_amount = 0;
        for( uint i = 0; i < _amounts.length; i++ ) {
            _total_recive = _total_recive + _amounts[i];
            _total_amount = _total_amount + _total[i];

        }
        require(IERC20(_token).balanceOf(msg.sender) >= _total_amount, "the balanceOf address is not enough !!");
        require(IERC20(_token).allowance(msg.sender, address(this)) >= _total_amount, "the allowance is not enough !!");

        for( uint i = 0; i < _tos.length; i++ ) {
            IERC20(_token).transferFrom(msg.sender, _tos[i], _amounts[i]);
        }

        uint256 _operate_amount = _total_amount - _total_recive;
        IERC20(_token).transferFrom(msg.sender, rAdmin, _operate_amount);
    }
}