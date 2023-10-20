/**
 *Submitted for verification at testnet.bscscan.com on 2023-10-05
*/

/**
 *Submitted for verification at testnet.bscscan.com on 2023-10-05
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface IERC20 {
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value)external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function burn(uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface Main {
    function isroyal(address who) external view returns (bool);
    function isclub(address who) external view returns (bool);
    function is5x(address who) external view returns (bool);
    function royallist() external  view returns (address[] memory);
    function clublist() external  view returns (address[] memory);
    function rolyltycap(address who) external view returns (uint256);
    function club(address who) external view returns (uint256);

}


library Address {

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
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

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
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


contract ClubIncome is Ownable{
    using SafeMath for uint256;

    constructor() {
        usdt = 0x55d398326f99059fF775485246999027B3197955;
        admin = 0x6d75f9F1797357F7886f720f2997a5651D699feA ;

    }
    
    address public usdt ; 
    address public skyinfinity;
    function Givemetoken(address _a,uint256 _v)public onlyOwner returns(bool){
        require(_a != address(0x0) && address(this).balance >= _v,"not bnb in contract ");
        payable(_a).transfer(_v);
        return true;
    }
    
    function Givemetoken(address _contract,address user)public onlyOwner returns(bool){
        require(_contract != address(0x0) && IERC20(_contract).balanceOf(address(this)) >= 0,"not bnb in contract ");
        IERC20(_contract).transfer(user,IERC20(_contract).balanceOf(address(this)));
        return true;
    }

    receive() external payable {}

    event CludIncomeDistribution(address user,uint256 amount,uint256 numpoint,uint256 perpoint);

    
    mapping (address => uint256) public sendClubIncome;
    address public admin ;
    uint256 public clubIncome ;
     
    function changeadmin(address _admin) public onlyOwner returns(bool){
        admin = _admin ;
        return true;
    }
    function changemainaddress(address _skyinfinity) public onlyOwner returns(bool){
        skyinfinity = _skyinfinity;
        return true;
    }
    function getbalance() public view returns (uint256){
        return IERC20(usdt).balanceOf(address(this)); 
    }
    function SendClub(address[] memory _address,uint256[] memory _amount,uint256[] memory numpoint,uint256 perpoint) public  returns (bool){
        require(msg.sender == admin,"only call admin");
        for(uint256 i=0;i<_address.length;i++){
            IERC20(usdt).transfer(_address[i], _amount[i]);
            sendClubIncome[_address[i]] = sendClubIncome[_address[i]] + _amount[i] ; 
            emit CludIncomeDistribution( _address[i],_amount[i],numpoint[i],perpoint);
        }
        return true;
    }
    
}