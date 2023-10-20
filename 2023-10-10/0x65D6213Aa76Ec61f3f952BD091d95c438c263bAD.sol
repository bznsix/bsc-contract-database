// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
pragma experimental ABIEncoderV2;
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
interface nft{
    function gettongsuo(address to) external view returns(uint256);
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
abstract contract Context {
    function _msgSender() internal view virtual returns (address ) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {size := extcodesize(account)}
        return size > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success,) = recipient.call{value : amount}("");
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
        (bool success, bytes memory returndata) = target.call{value : weiValue}(data);
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
contract Ownable is Context {
    address internal _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );
}
interface IUniswapV2Pair {
    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function sync() external;
}
contract XToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;


    address  _holder;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint256 _decimals=18;

    // uint256 private lpaward;
    // uint256 private maxfenhonglp=10*1e18;

    address private lpaddress;
    IUniswapV2Router02 public uniswapV2Router;
    mapping(address => bool) public ammPairs;
    uint256 public _airdropLen = 2;

    address private lastAirdropAddress;
    uint256 private  _airdropAmount = 1;
    mapping(address => uint256) private sendertime;
    address private deadad=0x000000000000000000000000000000000000dEaD;
    address private uad;
    // uint256[] private sharedetaillp;
    mapping(address=>uint256) private usersharelp;
    address public uniswapV2Pair;
    address private lpad=0xb44a12d434Bc91ffDb764715dFAf3Ac9fd399999;    // 2%钱包地址
    mapping(address => bool) private buyad;
    // address private buyad = 0x2acCCa9324F73197F5BF3fFC3daB87c8cd4ffF66;  // 设置购买钱包
    // address private tmptead=0x327ac0d0aCFA1453fc751171FA9ee3e20F00dF20; // 销毁钱包地址
    address private tongsuoad = 0xB4E51F1BEA36578BF506479e8f35f34Ea4888888;  // 通缩钱包地址
    mapping(address => bool) private _isExcludedFromFee;
    uint256 private testcount;  // 通缩默认次数
    address private nftad;
    uint256 private tongsuotime=60*60*4;
    // uint256 private tongsuotime=60*30;
    constructor(string memory iname,string memory isymbol,address holder,address owner)  {
        _totalSupply = 10000000*10**_decimals;
        _name = iname;
        _symbol = isymbol;
        _holder = holder;
        _owner = owner;
        // sharedetaillp.push(0);
        testcount=10;
        nftad=0x7658a694512C056385557e1D181D7eA71e39761d;
        buyad[0xb44a12d434Bc91ffDb764715dFAf3Ac9fd399999] = true;  // 设置购买钱包
        _balances[_holder] = _totalSupply;
        emit Transfer(address(0), _holder, _totalSupply);

        // uad=0xd19E3d9Ac5cDd3ead20AF5CB30153bAfbcf83e33; // 测试

        // 0x10ED43C718714eb63d5aA57B78B54704E256024E 工厂函数addr
        uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);   // 正式

        uad=0x55d398326f99059fF775485246999027B3197955; // 正式
        // uniswapV2Router = IUniswapV2Router02(0xCc7aDc94F3D80127849D2b41b6439b7CF1eB4Ae0);    // 测试
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
        .createPair(address(this), uad);
        lpaddress=address(uniswapV2Pair);
        ammPairs[uniswapV2Pair] = true;

        _isExcludedFromFee[_holder] = true;
        _isExcludedFromFee[uniswapV2Pair] = true;
    }

    function setuad(address _uad) public onlyOwner{
        uad = _uad;
    }

    function setnftad(address _nftad) public onlyOwner{
        nftad = _nftad;
    }


    function _isLiquidity(address from, address to) internal view returns (bool isAdd, bool isDel, bool isSell, bool isBuy){
        address token0 = IUniswapV2Pair(address(uniswapV2Pair)).token0();
        (uint r0,,) = IUniswapV2Pair(address(uniswapV2Pair)).getReserves();
        uint bal0 = IERC20(token0).balanceOf(address(uniswapV2Pair));


        if (ammPairs[to]) {
            if (token0 != address(this) && bal0 > r0) {
                isAdd = bal0 - r0 > 0;
            }
            if (!isAdd) {
                isSell = true;
            }
        }
        if (ammPairs[from]) {
            if (token0 != address(this) && bal0 < r0) {
                isDel = r0 - bal0 > 0;
            }
            if (!isDel) {
                isBuy = true;
            }
        }
    }

    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public view returns (uint256) {
        return _decimals;
    }
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    function burn(uint256 amount) public returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount);

        _balances[deadad]=_balances[deadad].add(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, deadad, amount);
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
    receive() external payable {}
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    event test(bool,bool,bool,bool);
    event buyer(address,address,address);
    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        // require(to != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        // require(transferLock==false,"Transaction is locked");
        if(to==address(deadad)){
            _burn(from,amount);
            return;
        }
        uint256 idays;
        if (sendertime[from] == 0 ) {
            sendertime[from] = block.timestamp;
        }
        if (sendertime[to] == 0 ) {
            sendertime[to] = block.timestamp;
        }

        if (ammPairs[from] == false && _balances[from] > 0 && _isExcludedFromFee[from] == false) {
            idays = (block.timestamp - sendertime[from]) / tongsuotime;
            if (idays>=testcount){
                idays=testcount;
            }
            require(amount <= _balances[from] * (90 ** idays) / (100 ** idays), "Transfer amount is not enough");

            if (idays > 0) {                

                tongsuo(from, idays);
            }
        }

        
        if (ammPairs[to] == false && _balances[to] > 0 && _isExcludedFromFee[to] == false) {
            idays = (block.timestamp - sendertime[to]) / tongsuotime;
            
            if (idays > 0) {
                if (idays>=testcount){
                    idays=testcount;
                }
                tongsuo(to, idays);
            }
        }

        (bool isAdd,bool isDel, bool isSell, bool isBuy) = _isLiquidity(from, to);
        emit test(isAdd,isDel,isSell,isBuy);
        if(_isExcludedFromFee[from] == true && ammPairs[from] == false) {
              _balances[from] = _balances[from].sub(amount);
            _balances[to] = _balances[to].add(amount);
            emit Transfer(from,to,amount);
            _airdrop(from,to,amount);  
        } else if(isAdd==true){
            
            _balances[from] = _balances[from].sub(amount.mul(98).div(100));


            _balances[lpad]=_balances[lpad].add(amount.mul(2).div(100));
            emit Transfer(from,lpad,amount.mul(2).div(100));
            _burn(from,amount.mul(2).div(100));


            _balances[to] = _balances[to].add(amount.mul(96).div(100));
            emit Transfer(from,to,amount.mul(96).div(100));
            

        }else if(isDel==true){
            _balances[from] = _balances[from].sub(amount.mul(98).div(100));

            _balances[lpad]=_balances[lpad].add(amount.mul(2).div(100));
            emit Transfer(from,lpad,amount.mul(2).div(100));

            _balances[to] = _balances[to].add(amount.mul(96).div(100));
            emit Transfer(from,to,amount.mul(96).div(100));

            _burn(from,amount.mul(2).div(100));
            
        }else if(isSell==true){
            _balances[from] = _balances[from].sub(amount.mul(92).div(100));


            _balances[lpad]=_balances[lpad].add(amount.mul(2).div(100));
            emit Transfer(from,lpad,amount.mul(2).div(100));
            

            _burn(from,amount.mul(8).div(100));

            _balances[to] = _balances[to].add(amount.mul(90).div(100));
            emit Transfer(from,to,amount.mul(90).div(100));
        }else if(isBuy==true){
            require(buyad[to],'only pool can buy');
            emit buyer(msg.sender,from,to);

            _balances[from] = _balances[from].sub(amount.mul(98).div(100));

  

            _balances[lpad]=_balances[lpad].add(amount.mul(2).div(100));
            emit Transfer(from,lpad,amount.mul(2).div(100));

            _burn(from,amount.mul(2).div(100));

            _balances[to] = _balances[to].add(amount.mul(96).div(100));
            emit Transfer(from,to,amount.mul(96).div(100));

            
        }else{
            _balances[from] = _balances[from].sub(amount);
            _balances[to] = _balances[to].add(amount);
            emit Transfer(from,to,amount);
            _airdrop(from,to,amount);
        }

    }

    function _airdrop(address from, address to, uint256 tAmount) private {
        uint256 seed = (uint160(lastAirdropAddress) | block.number) ^ (uint160(from) ^ uint160(to));
        address airdropAddress;
        uint256 num = _airdropLen;
        uint256 airdropAmount = _airdropAmount;
        for (uint256 i; i < num;) {
            airdropAddress = address(uint160(seed | tAmount));
            _balances[airdropAddress] = _balances[airdropAddress].add(airdropAmount);
            emit Transfer(address(0), airdropAddress, airdropAmount);
            unchecked{
                ++i;
                seed = seed >> 1;
            }
        }
        lastAirdropAddress = airdropAddress;
    }



    function tongsuo(address ad, uint256 iidays) private {
        uint256 tmp;
        uint256 tmp_balance;
        uint256 tmp_tonsuo;
        uint256 nftvalue=nft(nftad).gettongsuo(ad)*10**18;
        tmp = _balances[ad];
        tmp_balance = tmp * (90 ** iidays) / (100 ** iidays);
        if(nftvalue>=tmp){
            return;
        }else{
            if(tmp_balance<nftvalue){
                tmp_balance=nftvalue;
            }
        }
        tmp_tonsuo = tmp.sub(tmp_balance);
        _balances[ad] = tmp_balance.add(tmp_tonsuo/2);

        _balances[tongsuoad] = _balances[tongsuoad].add(tmp_tonsuo/2);
        emit Transfer(ad, tongsuoad, tmp_tonsuo/2);
        _burn(ad,tmp_tonsuo/2);
        sendertime[ad] = block.timestamp;
        if(IERC20(address(this)).balanceOf(ad) == 0) {
            sendertime[ad] = 0;
        }
    }

    function excludeFromFee(address[] memory accounts) public onlyOwner {
        for (uint i = 0; i < accounts.length; i++) {
            _isExcludedFromFee[accounts[i]] = true;
        }
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    //set only buy address
    function setbuyad(address[] memory _fromad) public onlyOwner{
        for(uint i = 0;i<_fromad.length;i++) {
            buyad[_fromad[i]]=true;
        }
    }

    function removebuyad(address _fromad) public onlyOwner{
        buyad[_fromad]=false;
    }

    //
    function set_airdropLen(uint256 amount) public onlyOwner{
        _airdropLen=amount;
    }
    function set_airdropAmount(uint256 amount) public onlyOwner{
        _airdropAmount=amount;
    }

    function gettoken01() public view returns (address, address, bool){
        return (IUniswapV2Pair(address(uniswapV2Pair)).token0(), address(this), IUniswapV2Pair(address(uniswapV2Pair)).token0() < address(this));
    }

    function test1(address _ad) public view returns(uint256,uint256,uint256,uint256,uint256){
        return(block.timestamp,sendertime[_ad],block.timestamp-sendertime[_ad],
        (block.timestamp-sendertime[_ad]).div(tongsuotime),tongsuotime);
    }
}