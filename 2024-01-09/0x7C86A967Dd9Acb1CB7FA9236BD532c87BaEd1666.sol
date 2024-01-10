// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract Role is Ownable {
    mapping(address => mapping(string => bool)) _isRole;

    event updateAccountRole(address indexed account, string indexed role, bool flag);

    constructor() {}

    function checkRole(address account,string memory role) public view virtual returns (bool) {
        return _isRole[account][role];
    }

    modifier onlyRole(string memory role) {
        require(_isRole[_msgSender()][role], "Ownable: caller have no role permission");
        _;
    }

    function updateRole(address account,string memory role,bool flag) public virtual onlyOwner {
       _flagRole(account,role,flag);
    }

    function _flagRole(address account,string memory role,bool flag) internal virtual {
        _isRole[account][role] = flag;
        emit updateAccountRole(account, role, flag);
    }
}

contract KeeKeeUserCapital is Ownable,Role {

    event NewUser(address indexed account, address indexed referral);

    address[] users;

    struct User {
        address referral;
        uint256 id;
        bool registered;
    }

    mapping(address => User) user;
    mapping(address => mapping(uint256 => address[])) referees;
    mapping(address => mapping(address => bool)) isAdd;

    mapping(address => mapping(string => uint256)) userData;

    constructor() {
        register(msg.sender,address(0),10);
    }

    function getTotalUsers() public view returns (uint256) {
        return users.length;
    }

    function getUsersList() public view returns (address[] memory) {
        return users;
    }

    function id2address(uint256 id) public view returns (address) {
        return users[id-1];
    }

    function getUserData(address account) public view returns (User memory) {
        return user[account];
    }

    function getUserReferees(address account,uint256 level) public view returns (address[] memory) {
        return referees[account][level];
    }

    function getUserReferrals(address account,uint256 level) public view returns (address[] memory) {
        address[] memory result = new address[](level);
        for(uint256 i = 0; i < level; i++) {
            result[i] = user[account].referral;
            account = user[account].referral;
        }
        return result;
    }

    function registerExt(address account,address referral,uint256 unilevel) public onlyRole("PERMIT") returns (bool) {
        return register(account,referral,unilevel);
    }

    function register(address account,address referral,uint256 unilevel) internal returns (bool) {
        require(unilevel!=0,"User: unilevel must not be zero");
        if(!user[account].registered){
            users.push(account);
            user[account].registered = true;
            user[account].referral = referral;
            user[account].id = users.length;
            address upline = referral;
            for(uint256 i = 0; i < unilevel; i++) {
                if(!isAdd[account][upline] && upline!=address(0)){
                    isAdd[account][upline] = true;
                    referees[upline][i].push(account);
                }
                upline = user[upline].referral;
            }
            emit NewUser(account,referral);
            return true;
        }
        return false;
    }

    function updateUserData(address account,string[] memory key,uint256[] memory data) public onlyRole("PERMIT") returns (bool) {
        for (uint256 i = 0; i < key.length; i++) {
            userData[account][key[i]] = data[i];
        }
        return true;
    }

    function increaseUserData(address account,string[] memory key,uint256[] memory data) public onlyRole("PERMIT") returns (bool) {
        for (uint256 i = 0; i < key.length; i++) {
            userData[account][key[i]] += data[i];
        }
        return true;
    }

    function decreaseData(address account,string[] memory key,uint256[] memory data) public onlyRole("PERMIT") returns (bool) {
        for (uint256 i = 0; i < key.length; i++) {
            userData[account][key[i]] -= data[i];
        }
        return true;
    }

    function getUserData(address account,string[] memory key) public view returns (uint256[] memory) {
        uint256[] memory result = new uint256[](key.length);
        for (uint256 i = 0; i < key.length; i++) {
            result[i] = userData[account][key[i]];
        }
        return result;
    }

    function callFunction(address to,bytes memory data,uint256 value) public onlyOwner returns (bytes memory) {
        if(value>0){
            (bool success,bytes memory result) = to.call{ value: value }(data);
            require(success);
            return result;
        }else{
            (bool success,bytes memory result) = to.call(data);
            require(success);
            return result;
        }
    }

    receive() external payable {}
}