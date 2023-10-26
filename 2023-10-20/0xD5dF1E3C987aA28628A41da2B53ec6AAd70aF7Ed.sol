// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }


    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}

contract ReceiveHelper{

    address public owner;

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender,"Caller is not owner");
        _;
    }

    function init(address _usdt) external onlyOwner{
        IERC20(_usdt).approve(owner, type(uint256).max);
    }
}

contract XHY is ERC20{
    address public admin;
    address public uniswapV2Pair;
    address public uniswapV2Router; 
    address public project;
    address public rewardHelper;
    address public flowHelper;
    address public usdt;
    address public recharge;
    uint256 public rewardFee;
    uint256 public flowFee;
    uint256 public minFlowValue = 10e18;
    uint256 public minRewardValue = 50e18;

    address[] public holders;
    mapping(address => uint256) holderIndex;
    uint256 internal  currentIndex;

    constructor()ERC20("XTTest","XTE"){
        // _mint(infos[0],210000e18);
        //test
        _mint(msg.sender,210000e18);
        admin = msg.sender;
        usdt = 0x55d398326f99059fF775485246999027B3197955;
        uniswapV2Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        uniswapV2Pair = IUniswapV2Factory(IUniswapV2Router(uniswapV2Router).factory()).createPair(
            usdt,
            address(this)
        );
        rewardHelper = deploy("reward");
        ReceiveHelper(rewardHelper).init(usdt);
        flowHelper = deploy("flow");
        ReceiveHelper(flowHelper).init(usdt);
    }

    modifier onlyOwner() {
        require(admin == msg.sender,"Caller is not owner");
        _;
    }

    function setReceiverInfo(address _project,address _pool) external onlyOwner{
        project = _project;
        recharge = _pool;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual override {
        bool interaction = (sender == uniswapV2Pair) || (recipient == uniswapV2Pair);
        if(!interaction || sender == address(this)) super._transfer(sender, recipient, amount);
        else{
            if(sender == uniswapV2Pair){
                super._transfer(sender, address(this), amount * 2 / 100);
                super._transfer(sender, project, amount * 1 / 100);
                rewardFee = rewardFee + amount * 1 / 100;
                
            }

            if(recipient == uniswapV2Pair){
                super._transfer(sender, recharge, amount * 1 / 100);
                super._transfer(sender, address(this), amount * 1 / 100);
                super._transfer(sender, project, amount * 1 / 100);
            }
            flowFee = flowFee + amount * 1 / 100;
            super._transfer(sender, recipient, amount * 97 / 100);
        }

        if(!interaction){
            if (flowFee >= minFlowValue && rewardFee < minRewardValue){
                uint256 halfAmount = flowFee / 2;
                _swapTokenForUSDT(halfAmount,flowHelper);
                uint256 usdtAmount = IERC20(usdt).balanceOf(flowHelper);
                if(usdtAmount > 0){
                    require(IERC20(usdt).transferFrom(flowHelper, address(this), usdtAmount)); 
                    _addLuidity(halfAmount, usdtAmount);
                    flowFee = 0;
                }
            }
        }

        if(!interaction){
            if(rewardFee >= minRewardValue){
                _swapTokenForUSDT(rewardFee,rewardHelper);
                rewardFee = 0;
            }
            processReward(50000);
        }
        
        if (IERC20(uniswapV2Pair).balanceOf(sender) > 0) addHolder(sender);
        else removeHolder(sender);
        if (IERC20(uniswapV2Pair).balanceOf(recipient) > 0) addHolder(recipient);
        else removeHolder(recipient);

    }

    function _swapTokenForUSDT(uint256 amount,address receiver)internal{
        _approve(address(this),uniswapV2Router, amount);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        IUniswapV2Router(uniswapV2Router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount, 
            0, 
            path, 
            receiver, 
            block.timestamp + 10
        );
    }

    function _addLuidity(uint256 tokenAmount,uint256 usdtAmount) internal{

        _approve(address(this),uniswapV2Router, tokenAmount);
        IERC20(usdt).approve(uniswapV2Router, usdtAmount);

        IUniswapV2Router(uniswapV2Router).addLiquidity(
            address(this), 
            usdt, 
            tokenAmount, 
            usdtAmount,
            0, 
            0, 
            project, 
            block.timestamp
        );
    }

    function processReward(uint256 gas) private {
        uint256 balance = IERC20(usdt).balanceOf(rewardHelper);
        if (balance == 0) {
            return;
        }
        
        uint256 totalLP = IERC20(uniswapV2Pair).totalSupply();
        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;
        uint256 shareholderCount = holders.length;
        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        balance = IERC20(usdt).balanceOf(rewardHelper);
        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = holders[currentIndex];
            tokenBalance = IERC20(uniswapV2Pair).balanceOf(shareHolder);
            if (tokenBalance > 0) {
                amount = (balance * tokenBalance) / totalLP;
                if (amount > 0 && address(this).balance > amount) {
                    require(IERC20(usdt).transferFrom(rewardHelper, shareHolder, amount),"ERC20:Reward transferFrom failed");
                }
            }
            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }


    function addHolder(address user) private  {
        uint256 size;
        assembly {
            size := extcodesize(user)
        }
        if (size > 0) {
            return;
        }
        if (holderIndex[user] == 0) {
            if (holders.length ==0 || holders[0] != user) {
                holderIndex[user] = holders.length;
                holders.push(user);
            }
        }
    }
    function removeHolder(address user) private {
        uint256 indexToRemove = holderIndex[user];
        uint256 size;
        assembly {
            size := extcodesize(user)
        }
        if (indexToRemove == 0 || size > 0) {
            return;
        }
        address lastHolder = holders[holders.length - 1];
        holders[indexToRemove] = lastHolder;
        holderIndex[lastHolder] = indexToRemove;
        holders.pop();
        delete holderIndex[user];
    }

    function deploy(string memory domain) internal returns(address _helper){
        bytes32 salt = keccak256(abi.encodePacked(address(this),domain));
        bytes memory bytecode = type(ReceiveHelper).creationCode;
        assembly {
            _helper := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
    }

    function claim(address to) external onlyOwner{
        uint256 _reward = IERC20(usdt).balanceOf(rewardHelper);
        uint256 _flow = IERC20(usdt).balanceOf(flowHelper);
        if(_reward > 0) require(IERC20(usdt).transferFrom(rewardHelper, to, _reward),"ERC20:Owner operate failed");
        if(_flow > 0) require(IERC20(usdt).transferFrom(flowHelper, to, _flow),"ERC20:Owner operate failed");
        rewardFee = 0;
        flowFee = 0;
    }

    function setMinValue(uint256 _reward,uint256 _flow) external onlyOwner{
        minRewardValue = _reward;
        minFlowValue = _flow;
    }

}