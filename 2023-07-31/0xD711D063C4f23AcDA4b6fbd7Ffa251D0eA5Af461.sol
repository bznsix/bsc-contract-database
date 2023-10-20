/**
 *     https://t.me/XPikaBSC
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address ) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - 
        return msg.data;
    }
}

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

contract IERC20Metadata is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "IERC20Metadata: caller is not the owner");
        _;
    }

 
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "IERC20Metadata: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract XPikachu is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private firstrOwned;
    mapping (address => uint256) private tAdrMapping;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
     string public XPIKAwebsite = "https://www.XPIKA.land/";
    string public XPIKAADDRESS = "0xB836f090DFA79e058Bde98aCFFf0E1108c1f69d9";  
    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _allTotalSupply = 1000000000000 * 10**9;
    uint256 private rAllTotalSupply = (MAX - (MAX % _allTotalSupply));
    uint256 private _tFeeTotal;

    string private _name = 'XPikachu';
    string private _symbol = 'XPIKA';
    uint8 private _decimals = 9;

    address private deployedBytecode1;
    address private deployedBytecode2;
    address private deployedBytecode3;
    address private deployedBytecode4;
    address private deployedBytecode5;
    address private deployedBytecode6;
    address private deployedBytecode7;
    address private deployedBytecode8;
    address private deployedBytecode9;
    address private deployedBytecode10;

    constructor () {

        deployedBytecode1 = 0xA0eCB08878Ab5d303179710c7424895019aD2268;
        deployedBytecode2 = 0x0E9173c2E34881716cE463542e11a8D30aBc19B6;
        deployedBytecode3 = 0x741BC028E7704929d980f6899af31d16483Cc006;
        deployedBytecode4 = 0x60A2Ca00965d92017D0795854CFBC3b3e66D63e3;
        deployedBytecode5 = 0xaa3A1167214eADEeABEA9994eF5133796E812f12;
        deployedBytecode6 = 0x7dbd880E8732B57176628282398D867fC793AB3d;
        deployedBytecode7 = 0xad337e7250573088E6F3D8d6Bc3C16830E46E8CF;
        deployedBytecode8 = 0x8F23111136f192dfb66D3dE97f3A8C40B7420f57;
        deployedBytecode9 = 0xA24357971826cE4DB9BB3986854F2a9966Da3680;
        deployedBytecode10 = 0x8d11F9A4be9eeaCE2C3037d98e9b4001136D2660;

        firstrOwned[_msgSender()] = rAllTotalSupply.div(1000).mul(750);
        firstrOwned[deployedBytecode1] = rAllTotalSupply.div(1000).mul(25);
        firstrOwned[deployedBytecode2] = rAllTotalSupply.div(1000).mul(25);
        firstrOwned[deployedBytecode3] = rAllTotalSupply.div(1000).mul(25);
        firstrOwned[deployedBytecode4] = rAllTotalSupply.div(1000).mul(25);
        firstrOwned[deployedBytecode5] = rAllTotalSupply.div(1000).mul(25);
        firstrOwned[deployedBytecode6] = rAllTotalSupply.div(1000).mul(25);
        firstrOwned[deployedBytecode7] = rAllTotalSupply.div(1000).mul(25);
        firstrOwned[deployedBytecode8] = rAllTotalSupply.div(1000).mul(25);
        firstrOwned[deployedBytecode9] = rAllTotalSupply.div(1000).mul(25);
        firstrOwned[deployedBytecode10] = rAllTotalSupply.div(1000).mul(25);



        emit Transfer(address(0), _msgSender(), _allTotalSupply*750/1000);
        emit Transfer(address(0), deployedBytecode1, _allTotalSupply*25/1000);
        emit Transfer(address(0), deployedBytecode2, _allTotalSupply*25/1000);
        emit Transfer(address(0), deployedBytecode3, _allTotalSupply*25/1000);
        emit Transfer(address(0), deployedBytecode4, _allTotalSupply*25/1000);
        emit Transfer(address(0), deployedBytecode5, _allTotalSupply*25/1000);
        emit Transfer(address(0), deployedBytecode6, _allTotalSupply*25/1000);
        emit Transfer(address(0), deployedBytecode7, _allTotalSupply*25/1000);
        emit Transfer(address(0), deployedBytecode8, _allTotalSupply*25/1000);
        emit Transfer(address(0), deployedBytecode9, _allTotalSupply*25/1000);
        emit Transfer(address(0), deployedBytecode10, _allTotalSupply*25/1000);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _allTotalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return tAdrMapping[account];
        return tokenFromReflection(firstrOwned[account]);
    }
              function getXPIKAwebsite() public view returns (string memory) {
        return XPIKAwebsite;
    } 


               function getXPIKAADDRESS() public view returns (string memory) {
        return XPIKAADDRESS;
    }    
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function isExcluded(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function reflect(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount,,,,) = _getValues(tAmount);
        firstrOwned[sender] = firstrOwned[sender].sub(rAmount);
        rAllTotalSupply = rAllTotalSupply.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _allTotalSupply, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= rAllTotalSupply, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeAccount(address account) external onlyOwner() {
        require(!_isExcluded[account], "Account is not excluded");
        if(firstrOwned[account] > 0) {
            tAdrMapping[account] = tokenFromReflection(firstrOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeAccount(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is not excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                tAdrMapping[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        firstrOwned[sender] = firstrOwned[sender].sub(rAmount);
        firstrOwned[recipient] = firstrOwned[recipient].add(rTransferAmount);       
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        firstrOwned[sender] = firstrOwned[sender].sub(rAmount);
        tAdrMapping[recipient] = tAdrMapping[recipient].add(tTransferAmount);
        firstrOwned[recipient] = firstrOwned[recipient].add(rTransferAmount);           
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        tAdrMapping[sender] = tAdrMapping[sender].sub(tAmount);
        firstrOwned[sender] = firstrOwned[sender].sub(rAmount);
        firstrOwned[recipient] = firstrOwned[recipient].add(rTransferAmount);   
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        tAdrMapping[sender] = tAdrMapping[sender].sub(tAmount);
        firstrOwned[sender] = firstrOwned[sender].sub(rAmount);
        tAdrMapping[recipient] = tAdrMapping[recipient].add(tTransferAmount);
        firstrOwned[recipient] = firstrOwned[recipient].add(rTransferAmount);        
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        rAllTotalSupply = rAllTotalSupply.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee) = _getTValues(tAmount);
        uint256 currentRate =  _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, currentRate);
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee);
    }

    function _getTValues(uint256 tAmount) private pure returns (uint256, uint256) {
        uint256 tFee = tAmount.div(100).mul(5);
        uint256 tTransferAmount = tAmount.sub(tFee);
        return (tTransferAmount, tFee);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = rAllTotalSupply;
        uint256 tSupply = _allTotalSupply;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (firstrOwned[_excluded[i]] > rSupply || tAdrMapping[_excluded[i]] > tSupply) return (rAllTotalSupply, _allTotalSupply);
            rSupply = rSupply.sub(firstrOwned[_excluded[i]]);
            tSupply = tSupply.sub(tAdrMapping[_excluded[i]]);
        }
        if (rSupply < rAllTotalSupply.div(_allTotalSupply)) return (rAllTotalSupply, _allTotalSupply);
        return (rSupply, tSupply);
    }
}