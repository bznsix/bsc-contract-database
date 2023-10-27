// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.19;
import {Ownable, Context} from "./Ownable.sol";
import {IERC20} from "./IERC20.sol";
import {SafeMath} from "./SafeMath.sol";
import {Address} from "./Address.sol";
import {InfoTokenSociety} from "./InfoTokenSociety.sol";
import {Social} from "./Social.sol";
import {IPancakeFactory} from "./IPancakeFactory.sol";
import {IPancakePair} from "./IPancakePair.sol";
import {IPancakeRouter02} from "./IPancakeRouter02.sol";
import {Fee} from "./Fee.sol";
import {AntiBotInterface} from "./AntiBotInterface.sol";
import {ReflexDistributor} from "./ReflexDistributor.sol";
import {RouterDex} from "./RouterDex.sol";
import {IPancakeFactory} from "./IPancakeFactory.sol";

contract MultiWalletToken is Context, IERC20, Ownable{
    //Contrato Criado na:  www.prevenda.finance 
    //você também pode criar seu lançamento justo, sua pre-venda seu stake e muito mais... 
    //suporte via telegram: @luiztoken

    using SafeMath for uint256;
    using Address for address;

    string private _name;
    string private _symbol;
    uint8 private _decimals = 18;
    address antibotManager;
    address public immutable deadAddress = address(0);
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public noF;
    string public site;
    string public telegram;
    string public twitter;
    ReflexDistributor public distributor;
    uint256 distributorGas = 3000;
    bool public feeInBNB;

    uint256 private _totalSupply;
    bool public sellTaxEnabled;
    bool public buyTaxEnabled;
    IPancakeRouter02 public uniswapV2Router;
    Fee[] public taxes;
    bool inSwapAndLiquify;
    uint256 public reflectionFee;
    uint256 public reflectionThreshold;
    mapping (address => bool) public isDividendExempt;

    receive() external payable {}

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor (
        InfoTokenSociety memory infoToken,
        address router,
        address creator,
        uint256 burnQuantity,
        Social memory social,
        Fee[] memory _taxes,
        address _antibotManager,
        address rewardToken,
        uint256 minStakeToRewardInHours,
        bool _feeInBNB,
        uint256 _reflectionFee
    )  {
        for(uint256 i = 0; i < _taxes.length; i++){
            if(_taxes[i].wallet == address(0)) continue;
            taxes.push(_taxes[i]);
            noF[_taxes[i].wallet] = true;
        }
        isDividendExempt[address(this)] = true;
        isDividendExempt[0x000000000000000000000000000000000000dEaD] = true;
        isDividendExempt[address(0)] = true;
        reflectionFee = _reflectionFee;
        feeInBNB = _feeInBNB;
        distributor = new ReflexDistributor(router,rewardToken, minStakeToRewardInHours);
        antibotManager = _antibotManager;
        buyTaxEnabled = infoToken.buyTax;
        sellTaxEnabled = infoToken.sellTax;
        site = social.site;
        telegram = social.telegram;
        twitter = social.twitter;
        _name = infoToken.name;
        _symbol = infoToken.symbol;
        _totalSupply = infoToken.totalSupply  * 10 ** _decimals;
        uniswapV2Router = IPancakeRouter02(router);
        _allowances[address(this)][address(uniswapV2Router)] = _totalSupply;
        noF[creator] = true;
        noF[address(this)] = true;
        noF[_msgSender()] = true;
        _balances[creator] = _totalSupply;
        reflectionThreshold = _totalSupply * 2 / 4000;
        emit Transfer(address(0), creator, _totalSupply);
        if(burnQuantity > 0){
            _burn(creator, burnQuantity * 10 ** _decimals);
        }
    }
    function toggleFeeInBNB(bool newValue) external onlyOwner {
        feeInBNB = newValue;
    }
    function toggleSellTax(bool newStatus) external onlyOwner {
        sellTaxEnabled = newStatus;
    }
    function toggleBuyTax(bool newStatus) external onlyOwner {
        buyTaxEnabled = newStatus;
    }
    function _totalTaxIfSelling() public view returns(uint256){
        if(!sellTaxEnabled) return 0;
        uint256 retorno = 0;
        for(uint256 i = 0; i < taxes.length; i++){
            retorno = retorno.add(taxes[i].percentage);
        }
        return retorno.add(reflectionFee);
    }
    function _totalTaxIfBuying() public view returns(uint256){
        if(!buyTaxEnabled) return 0;
        uint256 retorno = 0;
        for(uint256 i = 0; i < taxes.length; i++){
            retorno = retorno.add(taxes[i].percentage);
        }
        return retorno.add(reflectionFee);
    }
    function updateTax(address _wallet, uint256 _percentage) public onlyOwner {
        for(uint8 i = 0; i < taxes.length; i++ ){
            if(taxes[i].wallet == _wallet){
                taxes[i].percentage = _percentage;
            }
        }
    }
    function isMarketPair(address _pair) public view returns(bool){
        if(!_pair.isContract()) return false;
        try IPancakePair(_pair).token0() returns (address){
            return true;
        } catch {
            return false;
        }
    }
    function taxesList() external view returns(Fee[] memory){
        return taxes;
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
    function setnoF(address account, bool newValue) public onlyOwner() {
        noF[account] = newValue;
    }
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(deadAddress));
    }
    function transferToAddressETH(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
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
        require(amount > 0, "Transfer amount must be greater than zero");
        if(inSwapAndLiquify) return _basicTransfer(sender, recipient, amount);

        if(!noF[sender] && !noF[recipient]){
            AntiBotInterface(antibotManager).safeTransfer(sender, recipient, amount);
        }
        
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        uint256 finalAmount = (noF[sender] || noF[recipient]) ?
                                        amount : takeFee(sender, recipient, amount);
        _balances[recipient] = _balances[recipient].add(finalAmount);
        if(!isDividendExempt[sender]) {
            try distributor.setShare(sender, _balances[sender]) {} catch {}
        }
        if(!isDividendExempt[recipient]) {
            try distributor.setShare(recipient, _balances[recipient]) {} catch {} 
        }
        try distributor.process(distributorGas) {} catch {}

        emit Transfer(sender, recipient, finalAmount);
        return true;
    }
    function takeFee(address sender, address recipient, uint256 amount) internal  lockTheSwap returns (uint256) {
        uint256 feeAmount = 0;
        if(isMarketPair(sender)) {
            feeAmount = amount.mul(_totalTaxIfBuying()).div(1000);
        } else if(isMarketPair(recipient)) {
            feeAmount = amount.mul(_totalTaxIfSelling()).div(1000);
        }
        if(feeAmount > 0) {
            feeAmount = 0;
            uint256 amountReflection = amount.mul(reflectionFee).div(1000);
            _balances[address(this)] = _balances[address(this)].add(amountReflection);
            emit Transfer(sender, address(this), amountReflection);
            if(!isMarketPair(sender) && _balances[address(this)] >= reflectionThreshold){
                swapForBNB(address(this), _balances[address(this)]);
                if(address(this).balance > 0){
                    try distributor.deposit{value: address(this).balance}() {} catch {}
                }
            }
            feeAmount = amountReflection;
            for(uint8 i = 0; i < taxes.length; i++){
                uint256 _amountToTransfer = amount.mul(taxes[i].percentage).div(1000);
                if(feeInBNB){
                    uint256 amountBefore = address(this).balance;
                    swapForBNB(address(this), _amountToTransfer);
                    uint256 amountFinal = address(this).balance.sub(amountBefore);
                    if(amountFinal > 0){
                        payable(taxes[i].wallet).transfer(amountFinal);
                    }
                } else {
                    _balances[taxes[i].wallet] = _balances[taxes[i].wallet].add(_amountToTransfer);
                    emit Transfer(sender, taxes[i].wallet, _amountToTransfer);
                }
                feeAmount = feeAmount.add(_amountToTransfer);
            }
        }
        return amount.sub(feeAmount);
    }
    function swapForBNB(address to, uint256 amount) internal {
        if(!haveLiquidity(address(this),uniswapV2Router.WETH())) return;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            to,
            block.timestamp
        );
    }
    function haveLiquidity(address tokenA, address tokenB) internal view returns(bool) {
        address pair = IPancakeFactory(uniswapV2Router.factory()).getPair(tokenA, tokenB);
        if(pair == address(0)) return false;
        if(IPancakePair(pair).totalSupply() > 0){
            return true;
        }
        return false;
    }
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _balances[deadAddress] = _balances[deadAddress] + amount;
        emit Transfer(account, deadAddress, amount);
    }
    function burn(uint256 _amount) external{
        _burn(_msgSender(), _amount);
    }
}//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0;

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.19;

interface RouterDex {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}// SPDX-License-Identifier: UNLICENSE
pragma solidity 0.8.19;

import {IReflexDistributor} from "./IReflexDistributor.sol";
import {SafeMath} from "./SafeMath.sol";
import {RouterDex} from "./RouterDex.sol";
import {IERC20} from "./IERC20.sol";
import {IPancakeFactory} from "./IPancakeFactory.sol";
import {IPancakePair} from "./IPancakePair.sol";

contract ReflexDistributor is IReflexDistributor {

    using SafeMath for uint256;
    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    RouterDex router;
    IERC20 public RewardToken;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;
    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 2;

    uint256 public minPeriod = 5 minutes;
    uint256 public minDistribution = 1 * (10 ** 2);

    uint256 currentIndex;

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token); _;
    }

    constructor (address _router, address _rewardToken, uint256 _minPeriodInHours) {
        router = RouterDex(_router);
        RewardToken = IERC20(_rewardToken);
        minPeriod = _minPeriodInHours * 60 * 60;
        _token = msg.sender;
    }

    function setDistributionCriteria(uint256 newMinPeriod, uint256 newMinDistribution) external override onlyToken {
        minPeriod = newMinPeriod;
        minDistribution = newMinDistribution;
    }

    function setShare(address shareholder, uint256 amount) external override onlyToken {
        //se o comprador  já tiver saldo, distribui os dividendos
        if(shares[shareholder].amount > 0){
            distributeDividend(shareholder);
        }
        // se a quantidade for maior que 0 e o comprador não tiver saldo, adiciona comprador a lista de acionistas
        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        // se a quantidade for 0 e o comprador tiver saldo, remove o comprador da lista de acionistas    
        }else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder);
        }
        // quantidade total de açoes - quantidade de açoes do comprador + quantidade (1000 - 100 + 200 = 1100)
        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        // quantidade de açoes do comprador = quantidade recebida na função
        shares[shareholder].amount = amount;
        // adiciona ao total de exclusão do holder a quantidade de ações do holder
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function deposit() external payable override onlyToken {
        if(!haveLiquidity(router.WETH(), address(RewardToken))) return;

        // saldo inicial do token de recompensa
        uint256 balanceBefore = RewardToken.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(RewardToken);
        //troca BNB recebido na função por token de recompensa
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );
        // calcula a quantidade recebida de token de recompensa
        uint256 amount = RewardToken.balanceOf(address(this)).sub(balanceBefore);
        // total de dividendos + quantidade recebida (1000 + 200 = 1200)
        totalDividends = totalDividends.add(amount);
        // quantidade de dividendos por ação + quantdade por ação fator x quantidade recebida / quantidade total de ações (1000 + 100 x 200 / 1000 = 1020)
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function process(uint256 gas) external override onlyToken {
        // quantidade de acionistas
        uint256 shareholderCount = shareholders.length;
        // se não tiver acionistas, retorna
        if(shareholderCount == 0) { return; }

        uint256 iterations = 0;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        // enquanto o gás usado é menor que o gás passado & as iterações são menores que a quantidade de acionistas
        while(gasUsed < gas && iterations < shareholderCount) {
            // se o indice atual for maior ou igual a quantidade de acionistas, o indice atual é 0
            if(currentIndex >= shareholderCount){ currentIndex = 0; }
            // se tiver saldo para distribuir para o acionista atual
            if(shouldDistribute(shareholders[currentIndex])){
                // distribui os dividendos para o acionista atual
                distributeDividend(shareholders[currentIndex]);
            }
            // gás usado + gas restante pré execução - gas restante pós execução
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            // gás restante = gas restante pós execução
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
    
    function shouldDistribute(address shareholder) internal view returns (bool) {
        // se a ultima distribuição para o acionista + o periodo minimo para distribuição for menor que o timestamp atual
        // & a quantidade de dividendos não pagos para o acionista form maior que a quantidade minima de distribuição
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
                && getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        // se o holder não tiver saldo, retorna
        if(shares[shareholder].amount == 0){ return; }
        //pega a quantidade de dividendos não pagos para o holder
        uint256 amount = getUnpaidEarnings(shareholder);

        if(amount > 0){
            //total distribuido + quantidade para distribuir
            totalDistributed = totalDistributed.add(amount);
            //transfere a quantidade do token de recompensa para o holder
            RewardToken.transfer(shareholder, amount);
            //atualiza a data do ultimo pagamento para o holder
            shareholderClaims[shareholder] = block.timestamp;
            //seta a quantidade paga = quantidade paga holder + quantidade para distribuir
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            //seta a quantidade excluida do holder = pega a quantidade cumulativa de dividendos do holder
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }

    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        //se o holder não tiver saldo, retorna 0
        if(shares[shareholder].amount == 0){ return 0; }
        //pega a quantiade cumulativa de dividendos do holder
        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        //pega a quantidade de dividendos já pagos
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;
        // se a quantidade de dividendos for menorou igual a quantidade paga retorna 0
        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }
        //retorna a quantidade de dividendos - a quantidade paga
        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        //quantidae de dividendos x 511500 / 100 (200*511500/100 = 1023000)
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
    
    function claimDividend(address holder) external override {
        distributeDividend(holder);
    }
    function haveLiquidity(address tokenA, address tokenB) internal view returns(bool) {
        address pair = IPancakeFactory(router.factory()).getPair(tokenA, tokenB);
        if(pair == address(0)) return false;
        if(IPancakePair(pair).totalSupply() > 0){
            return true;
        }
        return false;
    }
}// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.19;
interface AntiBotInterface {
    function safeTransfer(address from, address to, uint256 amount) external;
    function enableContractFromContract(address _newContract, address _tokenOwner) external;
}pragma solidity 0.8.19;
// SPDX-License-Identifier: Unlicensed

struct Fee {
    uint256 percentage;
    address wallet;
}
//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2;
import "./IPancakeRouter01.sol";

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0;

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);

    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);
    function burn(address to) external returns (uint amount0, uint amount1);
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

struct Social {
    string site;
    string telegram;
    string twitter;
}//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

struct InfoTokenSociety {
    string name;
    string symbol;
    uint256 totalSupply;
    bool buyTax;
    bool sellTax;
    address antibotManager;
}//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;
library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }
    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }
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
}//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.19;

interface IReflexDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
    function claimDividend(address holder) external;
}//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2;

interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}