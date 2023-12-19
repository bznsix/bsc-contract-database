// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
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
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
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
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            
            if (returndata.length > 0) {
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

contract Ownable is Context {
    address private _owner;
    address public cdeadAddress = 0x000000000000000000000000000000000000dEaD;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
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
        emit OwnershipTransferred(_owner, cdeadAddress);
        _owner = cdeadAddress;
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract myIDNO is Context, IERC20, Ownable {
    
	using SafeMath for uint256;
	using Address for address;

	string private _name = "IDNO";
	string private _symbol = "IDNO";
	uint8 private _decimals = 18;
	address public deadAddress = 0x000000000000000000000000000000000000dEaD;
	address public _LPAddress;
	address public Firstadd;
	
	IERC20 public _LP;  //default

	mapping (address => uint256) _balances;
	mapping (address => mapping (address => uint256)) private _allowances;

	uint256 private _totalSupply = 333333333 * 10**_decimals;
	uint256 private _fee = 100;

 	mapping (address => uint256) public _swapPair;

 	mapping (address => address) public _linker;
	mapping (address => uint256) public _wflist;
	mapping (address => uint256) public _lpday;
	mapping (address => uint256) public _lpwin;
	mapping (address => uint256) public _lpwithdrow;
	mapping (address => uint256) public _lplist;
	mapping (address => uint256) public _lpaddid;
	mapping (uint256 => address) public _lpidadd;
	uint256 public _lpid = 0;
	uint256 public _lpupip = 1;
	mapping (address => uint256) public _bagday;
	mapping (address => uint256) public _bagwin;
	mapping (address => uint256) public _wdday;
	mapping (address => uint256) public _addlevel;
	mapping (address => mapping (uint256 => uint256)) public _addlevelc;

	constructor (address _firstadd) {
		_balances[address(this)] = _totalSupply;
		emit Transfer(address(0), address(this), _totalSupply);
		uint256 _firstvalue = 33333333 * 10**_decimals;
		_basicTransfer(address(this), _firstadd, _firstvalue);
		_wflist[_firstadd] = 1;
		_wflist[address(this)] = 1;
	}

	function setPair(address _Addr, uint256 _v) public onlyOwner {
		_swapPair[_Addr] = _v;
	}
	function setLP(address _LpAdd) public onlyOwner {
		_LPAddress = _LpAdd;
		_LP = IERC20(_LpAdd); 
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

	function totalSupply() public view override returns (uint256) {
		return _totalSupply;
	}

	function balanceOf(address account) public view override returns (uint256) {
		return _balances[account];
	}

	function allowance(address owner, address spender) public view override returns (uint256) {
		return _allowances[owner][spender];
	}

	function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
		_approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
		return true;
	}

	function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
		_approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
		return true;
	}


	function approve(address spender, uint256 amount) public override returns (bool) {
		_approve(_msgSender(), spender, amount);
		return true;
	}

	function _approve(address owner, address spender, uint256 amount) private {
		require(owner != address(0), "ERC20: approve from the zero address");
		require(spender != address(0), "ERC20: approve to the zero address");
		_allowances[owner][spender] = amount;
		emit Approval(owner, spender, amount);
	}

	function getCirculatingSupply() public view returns (uint256) {
		return _totalSupply.sub(balanceOf(deadAddress));
	}

	function transfer(address recipient, uint256 amount) public override returns (bool) {
		_transfer(_msgSender(), recipient, amount);
		return true;
	}

	function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
		_transfer(sender, recipient, amount);
		_approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
		return true;
	}

	function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {
		require(sender != address(0), "ERC20: transfer from the zero address");
		require(recipient != address(0), "ERC20: transfer to the zero address");
		if (sender==address(this)){ 
			return _basicTransfer(sender, recipient, amount); 
		}else{
			address _feeadd = recipient;
			uint256 istrade = 0;
			uint256 finalAmount = amount;
			if (_linker[recipient] == address(0) && amount>0 && _swapPair[sender]==0 && _swapPair[recipient]==0){
				_linker[recipient] = sender;
				_bagday[recipient] = block.timestamp;
				_levelup(recipient);
			}
			if (_swapPair[sender]>0){
				_lplist[recipient] = 0;
				istrade = 1;
			}
			if (_swapPair[recipient]>0){
				_lplist[sender] = 0;
				_feeadd = sender;
				istrade = 1;
			}
			if (amount>0){
				if (istrade>0){
					_bagupWin(_feeadd);
				}else{
					_bagupWin(sender);
					_bagupWin(recipient);
				}				
				if (_wflist[sender]==0 && _wflist[recipient]==0){
					uint256 _feeamount = amount.mul(_fee).div(1000);				
					_transferFee(sender, _feeamount);
					finalAmount = amount.sub(_feeamount);
				}

				_balances[recipient] = _balances[recipient].add(finalAmount);
				_balances[sender] = _balances[sender].sub(finalAmount, "Insufficient Balance");
				emit Transfer(sender, recipient, finalAmount);

				if (_swapPair[sender]==0){
					_lpupdate(sender);	
				}
			}else{
				_lpupdate(sender);
				_lpupdateLevel();
				_WinWithdrow(sender);
				emit Transfer(sender, recipient, amount);
			}
			return true;
		}
	}

	function _WinWithdrow(address sender) internal returns (bool) {
		uint256 _nday = ((block.timestamp).sub(_wdday[sender])).div(86400);
		if (_nday>=7){
			_bagupWin(sender);
			_lpupWin(sender);

			uint256 _nwin = _lpwin[sender];
			uint256 _nwinall = _lpwin[sender].add(_bagwin[sender]);
			if (_nwin>0){
				_balances[address(this)] = _balances[address(this)].sub(_nwin, "Insufficient Balance");
				_balances[sender] = _balances[sender].add(_nwin);
				emit Transfer(address(this), sender, _nwin);
				_lpwin[sender] = 0;
			}
			_nwin = _bagwin[sender];
			if (_nwin>0){
				_balances[address(this)] = _balances[address(this)].sub(_nwin, "Insufficient Balance");
				_balances[sender] = _balances[sender].add(_nwin);
				emit Transfer(address(this), sender, _nwin);
				_bagwin[sender] = 0;
			}
			_wdday[sender] = block.timestamp;
			if (_nwinall>0){
				_WinWithdrowFee(sender, _nwinall);
			}
		}		
		return true;
	}
	function _lpupWin(address sender) internal returns (bool) {
		uint256 _nday = ((block.timestamp).sub(_lpday[sender]));
		if (_nday>0 && _lplist[sender]>0){
			uint256 _nwin = _lplist[sender].mul(_nday).mul(15).div(1000).div(86400);
			_lpwin[sender] = _lpwin[sender].add(_nwin);
		}
		_lpday[sender] = block.timestamp;
		return true;
	}

	function _bagupWin(address _addr) internal returns (bool) {
		uint256 _nwin = balanceOf(_addr);
		uint256 _nday = (block.timestamp).sub(_bagday[_addr]);
		if (_nday>0 && _nwin>0 && _addr!= deadAddress){
			_nwin = _nwin.mul(_nday).mul(10).div(1000).div(86400);
			_bagwin[_addr] = _bagwin[_addr].add(_nwin);
		}
		_bagday[_addr] = block.timestamp;
		return true;
	}

	function _lpupdate(address sender) internal returns (bool) {
		if (_LPAddress!=address(0)){
			uint256 _oldlp = _lplist[sender];
			uint256 _newlp = _LP.balanceOf(sender);
			if (_oldlp!=_newlp){
				_lpupWin(sender);
				_lplist[sender] = _newlp;
				if (_lpaddid[sender]==0){
					_lpid = _lpid+1;
					_lpaddid[sender] = _lpid;
					_lpidadd[_lpid] = sender;
				}
			}
		}
		return true;
	}

	function _lpupdateLevel() internal returns (bool) {
		if (_lpid>0 && _LPAddress!=address(0)){
			uint256 _oldlp = 0;
			uint256 _newlp = 0;
			address _addr;
			uint256 _upidmin = 1;
			uint256 _upidmax = _lpupip + 100;
			if (_upidmax>_lpid){
				_upidmax = _lpid;
			}
			if (_upidmax>100){
				_upidmin = _upidmax - 100;
			}
			while (_upidmin<=_upidmax){
				_addr = _lpidadd[_upidmin];
				if (_addr != address(0)){
					_oldlp = _lplist[_addr];
					_newlp = _LP.balanceOf(_addr);	
					if (_oldlp!=_newlp){
						_lpupWin(_addr);
						_lplist[_addr] = _newlp;
					}
				}
				_upidmin = _upidmin+1;
			}
			_lpupip = _upidmax;
		}
		return true;
	}

	function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
		_bagupWin(recipient);
		_balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
		_balances[recipient] = _balances[recipient].add(amount);
		emit Transfer(sender, recipient, amount);
		return true;
	}
	

	function _levelup(address _addr) internal returns (bool) { 
		address _linkadd = _linker[_addr];
		for (uint256 i=1;i<=5;i++){
			if (_linkadd != address(0)){
				_addlevelc[_linkadd][i] = _addlevelc[_linkadd][i] + 1;
				if (_addlevelc[_linkadd][i]>=5 && _addlevel[_linkadd]<i){
					_addlevel[_linkadd] = i;
					_linkadd = _linker[_linkadd];
				}else{
					i = 6;
				}
			}else{
				i = 6;
			}
		}
		return true;
	}

	function _WinWithdrowFee(address sender, uint256 afee) internal returns (bool) {   
		uint256 _linkfee = 0; 
		address _linkadd = _linker[sender];
		for (uint256 i=1;i<=5;i++){
			if (_linkadd != address(0) && _addlevel[_linkadd]>=i){
				_linkfee = afee.mul(30).div(1000);
				if (i==1){
					_linkfee = afee.mul(300).div(1000);
				}else if (i==2){
					_linkfee = afee.mul(200).div(1000);
				}else if (i==3){
					_linkfee = afee.mul(100).div(1000);
				}else if (i==4){
					_linkfee = afee.mul(50).div(1000);
				}
				_basicTransfer(address(this), _linkadd, _linkfee);
			}
			_linkadd = _linker[_linkadd];
		}
		return true;
	}

	function _transferFee(address sender, uint256 afee) internal returns (bool) {   
		uint256 _linkfee = 0; 
		address _linkadd = _linker[sender];
		uint256 _burnfee = 0;
		for (uint256 i=1;i<=5;i++){
			if (_linkadd != address(0) && _addlevel[_linkadd]>=i){
				_linkfee = afee.mul(50).div(1000);
				if (i==1){
					_linkfee = afee.mul(200).div(1000);
				}else if (i==2){
					_linkfee = afee.mul(150).div(1000);
				}else if (i==3){
					_linkfee = afee.mul(120).div(1000);
				}else if (i==4){
					_linkfee = afee.mul(80).div(1000);
				}
				_burnfee = _burnfee.add(_linkfee);
				_basicTransfer(sender, _linkadd, _linkfee);
			}
			_linkadd = _linker[_linkadd];	
		}
		_basicTransfer(sender, deadAddress, afee.sub(_burnfee));
		return true;
	}
}