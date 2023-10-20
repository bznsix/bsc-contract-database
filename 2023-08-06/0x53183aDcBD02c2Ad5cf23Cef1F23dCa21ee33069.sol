// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC20 {

    uint internal _totalSupply;
    mapping(address => uint) internal _balanceOf;
    mapping(address => mapping(address => uint)) internal _allowance;

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function _mint(address to, uint value) internal {
        _beforeTokenTransfer(address(0), to, value);
        _totalSupply += value;
        _balanceOf[to] += value;
        emit Transfer(address(0), to, value);
        _afterTokenTransfer(address(0), to, value);
    }

    function _burn(address from, uint value) internal {
        _beforeTokenTransfer(from, address(0), value);
        _balanceOf[from] -= value;
        _totalSupply -= value;
        emit Transfer(from, address(0), value);
        _afterTokenTransfer(from, address(0), value);
    }

    function _approve(
        address owner,
        address spender,
        uint value
    ) internal virtual {
        _allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(
        address from,
        address to,
        uint value
    ) internal virtual {
        _beforeTokenTransfer(from, to, value);
        _balanceOf[from] -= value;
        _balanceOf[to] += value;
        emit Transfer(from, to, value);
        _afterTokenTransfer(from, to, value);
    }

    function allowance(address owner, address spender) external view virtual returns (uint) {
        return _allowance[owner][spender];
    }

    function _spendAllowance(address owner, address spender, uint value) internal virtual {
        if (_allowance[owner][spender] != type(uint256).max) {
            require(_allowance[owner][spender] >= value, "ERC20: insufficient allowance");
            _allowance[owner][spender] -= value;
        }
    }

    function totalSupply() external view virtual returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address owner) external view virtual returns (uint) {
        return _balanceOf[owner];
    }

    function approve(address spender, uint value) external virtual returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint value) external virtual returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(
        address from,
        address to,
        uint value
    ) external virtual returns (bool) {
        _spendAllowance(from, msg.sender, value);
        _transfer(from, to, value);
        return true;
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint value
    ) internal virtual {}

    function _beforeTokenTransfer(
        address from,
        address to,
        uint value
    ) internal virtual {}
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "./ERC20.sol";

contract SlippageERC20 is ERC20 {

    /// @notice permission tpye
    /// main permission
    uint8 public constant OWNER = 0;
    /// mint permission
    uint8 public constant MINTER = 1;

    /// @notice param tpye
    /// from slip, general for sell
    uint8 public constant FROM_SLIP = 2;
    /// to slip, general for buy
    uint8 public constant TO_SLIP = 3;
    /// set slip white list
    uint8 public constant SLIP_WHITE_LIST = 4;
    /// set black list
    uint8 public constant BLACK_LIST = 5;
    /// withdraw token
    uint8 public constant WITHDRAW = 6;
    /// set default tax rate
    uint8 public constant DEFAULT_TAX_RATE = 7;
    /// default tax rate, transfer tax rate except fromSlip, toSlip, slipWhiteList
    uint32 public defaultTaxRateE5 = 0;

    /// @notice permission => caller => isPermission
    mapping (uint8 => mapping(address => bool)) public permissions;
    /// @notice set permission event
    event PermissionSet(uint8 indexed permission, address indexed account, bool indexed value);

    /// @notice check permission
    modifier onlyCaller(uint8 _permission) {
        require(permissions[_permission][msg.sender], "Calls have not allowed");
        _;
    }

    /// @notice from
    mapping(address => uint32) public fromSlipE5;
    /// @notice to
    mapping(address => uint32) public toSlipE5;

    mapping(address => bool) public slipWhiteList;
    event SetSlipWhiteList(address indexed user, bool indexed value);

    mapping(address => bool) public blackList;
    event SetBlackList(address indexed user, bool indexed value);

    function _initERC20_() internal {
        // set permission for own
        address _owner = msg.sender;
        _setPermission(OWNER, _owner, true);
        _setPermission(MINTER, _owner, true);
        _setSlipWhiteList(_owner, true);
    }

    function _setSlipWhiteList(address _user, bool _value) internal {
        slipWhiteList[_user] = _value;
        emit SetSlipWhiteList(_user, _value);
    }

    function _setBlackList(address _user, bool _value) internal {
        blackList[_user] = _value;
        emit SetBlackList(_user, _value);
    }

    /// @notice set permission
    function _setPermission(uint8 _permission, address _account, bool _value) internal {
        permissions[_permission][_account] = _value;
        emit PermissionSet(_permission, _account, _value);
    }

    /// @notice set permissions
    function setPermissions(uint8[] calldata _permissions, address[] calldata _accounts, bool[] calldata _values) external onlyCaller(OWNER) {
        require(_permissions.length == _accounts.length && _accounts.length == _values.length, "Lengths are not equal");
        for (uint i = 0; i < _permissions.length; i++) {
            _setPermission(_permissions[i], _accounts[i], _values[i]);
        }
    }

    /// @notice set
    function setConfig(uint8[] calldata _configTypes, bytes[] calldata _datas) external onlyCaller(OWNER) {
        uint len = _configTypes.length;
        for(uint i = 0; i < len; i++) {
            if (_configTypes[i] == FROM_SLIP) {
                (address _from, uint32 _feeE5) = abi.decode(_datas[i], (address, uint32));
                fromSlipE5[_from] = _feeE5;
            } else if (_configTypes[i] == TO_SLIP) {
                (address _to, uint32 _feeE5) = abi.decode(_datas[i], (address, uint32));
                toSlipE5[_to] = _feeE5;
            } else if (_configTypes[i] == SLIP_WHITE_LIST) {
                (address _account, bool _value) = abi.decode(_datas[i], (address, bool));
                _setSlipWhiteList(_account, _value);
            } else if (_configTypes[i] == BLACK_LIST) {
                (address _account, bool _value) = abi.decode(_datas[i], (address, bool));
                _setBlackList(_account, _value);
            } else if (_configTypes[i] == WITHDRAW) {
                (address _to, uint _amount) = abi.decode(_datas[i], (address, uint));
                _balanceOf[address(this)] -= _amount;
                _balanceOf[_to] += _amount;
                emit Transfer(address(this), _to, _amount);
            } else if (_configTypes[i] == DEFAULT_TAX_RATE) {
                (uint32 _feeE5) = abi.decode(_datas[i], (uint32));
                defaultTaxRateE5 = _feeE5;
            }
        }
    }

    /// @notice slipperage transfer
    function _transfer(address _from, address _to, uint256 _amount) internal override {
        uint _fee = 0;
        if (!slipWhiteList[_from] && !slipWhiteList[_to]) {
            _fee = _amount * (fromSlipE5[_from] + toSlipE5[_to]) / 1e5;
            /// @dev default tax rate without slip
            if ( defaultTaxRateE5 > 0 && _fee == 0) {
                _fee = _amount * defaultTaxRateE5 / 1e5;
            }
            if (_fee > 0) {
                _transferSlippage(_from, _to, _amount, _fee);
            }
        }
        _beforeTokenTransfer(_from, _to, _amount);
        _balanceOf[_from] -= _amount;
        _amount -= _fee;
        _balanceOf[_to] += _amount;
        emit Transfer(_from, _to, _amount);
        _afterTokenTransfer(_from, _to, _amount);
    }

    /// @notice this function just for filter transfer allwoed
    function _beforeTokenTransfer(address _from, address _to, uint256) internal virtual override {
        require(!blackList[_from] && !blackList[_to], "blacklisted");
    }

    /// @notice default transfer fee
    function _transferSlippage(address _from, address, uint256, uint _fee) internal virtual {
        _balanceOf[address(this)] += _fee;
        emit Transfer(_from, address(this), _fee);
    }

    function burn(uint256 _amount) external {
        _burn(msg.sender, _amount);
    }
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SlippageERC20} from "../utils/SlippageERC20.sol";

contract CDA is SlippageERC20 {
    
    string public name;
    string public symbol;
    uint8 public immutable decimals;

    /// @notice community node
    address public communityNode;
    /// @notice super node
    address public superNode;
    /// @notice developer node
    address public developerNode;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _totalSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        _mint(msg.sender, _totalSupply);
        _initERC20_();
    }

    function setAddress(
        address _superNode,
        address _developerNode,
        address _communityNode
    ) external onlyCaller(OWNER) {
        superNode = _superNode;
        developerNode = _developerNode;
        communityNode = _communityNode;
        _setSlipWhiteList(_superNode, true);
        _setSlipWhiteList(_developerNode, true);
        _setSlipWhiteList(_communityNode, true);
    }

    function _transferSlippage(address _from, address, uint256, uint _fee) internal override {
        uint _fee10 = _fee / 10;
        _setTransfer(_from, address(0), _fee10 * 5);
        _setTransfer(_from, superNode, _fee10 * 2);
        _setTransfer(_from, communityNode, _fee10 * 2);
        _setTransfer(_from, developerNode, _fee - 9 * _fee10);

    }

    function _setTransfer(address _from, address _to, uint _amount) internal {
        _balanceOf[_to] += _amount;
        emit Transfer(_from, _to, _amount);
    }

}