// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./base/ERC20Rebase.sol";
import "./base/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";   
import "@openzeppelin/contracts/utils/math/Math.sol";
import "./base/interface/IRouter.sol";
import "./base/interface/IFactory.sol";
import "./base/interface/IPancakePair.sol";
import "./base/mktCap/selfNFTMktCap.sol";

interface IERC721{ 
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function walletOf(address _owner) external view returns (uint256[] memory); 
    function totalSupply() external view  returns (uint256);
    function tokenByIndex(uint256 index) external view returns (uint256);
}
  
contract Token is ERC20Rebase, ERC20Burnable, MktCap {
    using SafeMath for uint;   
    mapping(address=>bool) public ispair; 
    mapping(address=>uint) public exFees; 
    address public _baseToken;
    address _router=0x10ED43C718714eb63d5aA57B78B54704E256024E; 
    bool isTrading;
    struct Fees{
        uint buy;
        uint sell;
        uint transfer;
        uint total;
    }
    Fees public fees;
    bool public isLimit;
    struct Limit{
        uint txMax;
        uint positionMax; 
        uint part;
    }
    Limit public limit;
    function setLimit(uint  txMax,uint positionMax,uint part) external onlyOwner { 
        limit=Limit(txMax,positionMax,part); 
    } 
    function removeLimit() external onlyOwner {
        isLimit=false;
    } 
    bool public _autoRebase;
    uint256 public _lastRebasedTime;
    event LogRebase(uint256 indexed epoch, uint256 totalSupply);

    modifier trading(){
        if(isTrading) return;
        isTrading=true;
        _;
        isTrading=false; 
    }
    error InStatusError(address user);
    
    constructor(string memory name_,string memory symbol_,uint total_) ERC20Rebase(name_, symbol_) MktCap(_msgSender(),_router) {
        dev=_msgSender(); 
        fees=Fees(100,100,100,100); 
        exFees[dev]=4;
        exFees[address(this)]=4;
        isLimit=true;
        limit=Limit(5,5,10000);
        _approve(address(this),_router,uint(2**256-1)); 
        _mint(dev, total_ *  10 ** decimals());
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    receive() external payable { }  

    function setFees(Fees calldata fees_) public onlyOwner{
        fees=fees_;
    } 
    function setExFees(address[] calldata list ,uint tf) public onlyOwner{
        uint count=list.length;
        for (uint i=0;i<count;i++){
            exFees[list[i]]=tf;
        } 
    }
    function getStatus(address from,address to) internal view returns(bool){
        if(exFees[from]==4||exFees[to]==4) return false;
        if(exFees[from]==1||exFees[from]==3) return true;
        if(exFees[to]==2||exFees[to]==3) return true;
        return false;
    }

    
    function setAutoRebase(bool _flag) external onlyOwner {
        if (_flag) {
            _autoRebase = _flag;
            _lastRebasedTime = block.timestamp; 
        } else {
            _autoRebase = _flag; 
        }
    }

    function manualRebase() external {
        require(shouldRebase(), "rebase not required");
        rebase();
    }
    uint256 public rebaseRate = 50833;
    bool    public rebaseIsAdd=true;
    uint256 public rebaseEndTotalSupply=21000000 ether;
    
    function setRebase(uint rebaseRate_,bool rebaseIsAdd_,uint256 rebaseEndTotalSupply_)  external onlyOwner{
        require((rebaseIsAdd && rebaseEndTotalSupply_>totalSupply())||(!rebaseIsAdd && rebaseEndTotalSupply_<totalSupply()),"err"); 
        rebaseRate=rebaseRate_;
        rebaseIsAdd=rebaseIsAdd_;
        rebaseEndTotalSupply=rebaseEndTotalSupply_;
    }

    function rebase() internal { 
        if(rebaseEndTotalSupply==totalSupply() || rebaseEndTotalSupply==0) return;
        uint256 deltaTime = block.timestamp - _lastRebasedTime;
        uint256 times = deltaTime.div(15 minutes);
        uint256 epoch = times.mul(15);
        uint256 newTotalSupply = totalSupply();
        for (uint256 i = 0; i < times; i++) {
            if(rebaseIsAdd)newTotalSupply = newTotalSupply.mul(uint256(10 ** 8).add(rebaseRate)).div(10 ** 8);
            else newTotalSupply = newTotalSupply.mul(uint256(10 ** 8).sub(rebaseRate)).div(10 ** 8);
        }
         if(rebaseIsAdd) newTotalSupply=Math.min(newTotalSupply,rebaseEndTotalSupply);
         else newTotalSupply=Math.max(newTotalSupply,rebaseEndTotalSupply);
        _reBase(newTotalSupply);
        _lastRebasedTime = _lastRebasedTime.add(times.mul(15 minutes));

        emit LogRebase(epoch, newTotalSupply);
    }

    function shouldRebase() internal view returns (bool) {
        return
            _autoRebase &&
            _lastRebasedTime > 0 &&
            (totalSupply() < MAX_SUPPLY) &&
            block.timestamp >= (_lastRebasedTime + 15 minutes);
    }

    function _beforeTokenTransfer(address from,address to,uint amount) internal override trading{
        if(getStatus(from,to)){ 
            revert InStatusError(from);
        }
        if(!ispair[from] && !ispair[to] || amount==0) return;
        uint t=ispair[from]?1:ispair[to]?2:0;
        trigger(t);
    } 
    function _afterTokenTransfer(address from,address to,uint amount) internal override trading{
        if(address(0)==from || address(0)==to) return;
        takeFee(from,to,amount);
        if (shouldRebase()) rebase();    
        try this.process(200000) {} catch {}
        if(ispair[from] && isLimit && exFees[to] != 4)
        {
            require(amount <= getPart(limit.txMax,limit.part));
            require(balanceOf(to) <= getPart(limit.positionMax,limit.part));
        }
    }
        function getPart(uint point,uint part)internal view returns(uint){
        return totalSupply().mul(point).div(part);
    }
    function takeFee(address from,address to,uint amount)internal {
        uint fee=ispair[from]?fees.buy:ispair[to]?fees.sell:fees.transfer; 
        uint feeAmount= amount.mul(fee).div(fees.total); 
        if(exFees[from]==4 || exFees[to]==4 ) feeAmount=0;
        if(ispair[to] && IERC20(to).totalSupply()==0) feeAmount=0;
        if(feeAmount>0){  
            super._transfer(to,address(this),feeAmount); 
        } 
    } 
    

    function start(address baseToken,address nftToken,Fees calldata fees_) public  onlyOwner{
        _baseToken=baseToken;
        NFT=IERC721(nftToken);
        setPairs(baseToken);
        setPair(baseToken);
        setFees(fees_);
    }

    uint256 public  minReward = 1 ether;
    uint public amountNftLeft;
    IERC721 public NFT;
    mapping(uint256 => bool) public exDividend;
    uint256 currentIndex; 
    uint public totalDistributed;



    function setExDividend(uint256[] calldata list, bool tf) public onlyOwner {
        uint256 num = list.length;
        for (uint256 i = 0; i < num; i++) {
            exDividend[list[i]] = tf; 
        }
    }
    function setminReward(uint256 num) public onlyOwner {
        minReward = num;
    } 
    function deposit(uint256 amountB) internal override {  
        amountNftLeft = amountNftLeft.add(amountB);  
        if(amountNftLeft>IERC20(_baseToken).balanceOf(address(this))) amountNftLeft = IERC20(_baseToken).balanceOf(address(this));
    }

    function process(uint256 gas) external {
        uint256 shareholderCount = NFT.totalSupply();
        if (shareholderCount == 0) {
            return;
        }

        uint256 iterations = 0;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 nftId;
        if(amountNftLeft>IERC20(_baseToken).balanceOf(address(this))) amountNftLeft = IERC20(_baseToken).balanceOf(address(this));
   
        while (gasUsed < gas  && iterations < shareholderCount && amountNftLeft > minReward) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            nftId = NFT.tokenByIndex(currentIndex);

            if (!exDividend[nftId]) {
                distributeDividend(nftId); 
            } 

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function distributeDividend(uint256 nftId) internal {    
        IERC20(_baseToken).transfer(NFT.ownerOf(nftId), minReward);   
        amountNftLeft=amountNftLeft.sub(minReward);
    }
 
    function setPairs(address token) public onlyOwner{   
        IRouter router=IRouter(_router);
        address pair=IFactory(router.factory()).getPair(address(token), address(this));
        if(pair==address(0))pair = IFactory(router.factory()).createPair(address(token), address(this));
        require(pair!=address(0), "pair is not found"); 
        _setSteady(pair, true);
        ispair[pair]=true;  
    }
    function unSetPair(address pair) public onlyOwner {  
        ispair[pair]=false; 
    }  
    
        


 
    function recoverERC20(address token,uint amount) public { 
        if(token==address(0)){ 
            (bool success,)=payable(dev).call{value:amount}(""); 
            require(success, "transfer failed"); 
        } 
        else IERC20(token).transfer(dev,amount); 
    }

}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interface/IFactory.sol";
import "../interface/IRouter.sol";



contract TokenDistributor {
    constructor (address token) {
        IERC20(token).approve(msg.sender, uint(~uint(0)));
        IERC20(msg.sender).approve(msg.sender, uint(~uint(0)));
    }
}

contract MktCap is Ownable {
    using SafeMath for uint;
    address dev;
    address token0;
    address token1;
    IRouter router;
    address pair;
    TokenDistributor public _tokenDistributor;
    struct autoConfig {
        bool status;
        uint minPart;
        uint maxPart;
        uint parts;
    }
    autoConfig public autoSell;
    struct Allot {
        uint markting;
        uint burn;
        uint addL;
        uint nft;
        uint total;
    }
    Allot public allot; 

    address[] public marketingAddress;
    uint[] public marketingShare;
    uint internal sharetotal;
    

    constructor(address dev_, address router_) { 
        dev=dev_;
        token0 = address(this); 
        router = IRouter(router_); 
        
    }

    function setAll( 
        Allot memory allotConfig,
        autoConfig memory sellconfig,
        address[] calldata list,
        uint[] memory share
    ) public onlyOwner {
        setAllot(allotConfig);
        setAutoSellConfig(sellconfig);
        setMarketing(list, share);
    }

    function setAutoSellConfig(autoConfig memory autoSell_) public onlyOwner {
        autoSell = autoSell_;
    }

    function setAllot(Allot memory allot_) public onlyOwner {
        allot = allot_;
    }

    function setPair(address token) public  onlyOwner {
        token1 = token;
        _tokenDistributor = new TokenDistributor(token1); 
        IERC20(token1).approve(address(router), uint(2 ** 256 - 1));
        pair = IFactory(router.factory()).getPair(token0, token1);
    }

    function setMarketing(
        address[] calldata list,
        uint[] memory share
    ) public onlyOwner {
        require(list.length > 0, "DAO:Can't be Empty");
        require(list.length == share.length, "DAO:number must be the same");
        uint total = 0;
        for (uint i = 0; i < share.length; i++) {
            total = total.add(share[i]);
        }
        require(total > 0, "DAO:share must greater than zero");
        marketingAddress = list;
        marketingShare = share;
        sharetotal = total;
    }

    function getToken0Price() public view returns (uint) {
        //代币价格
        address[] memory routePath = new address[](2);
        routePath[0] = token0;
        routePath[1] = token1;
        return router.getAmountsOut(1 ether, routePath)[1];
    }

    function getToken1Price() public view returns (uint) {
        //代币价格
        address[] memory routePath = new address[](2);
        routePath[0] = token1;
        routePath[1] = token0;
        return router.getAmountsOut(1 ether, routePath)[1];
    }

    function _sell(uint amount0In) internal {
        address[] memory path = new address[](2);
        path[0] = token0;
        path[1] = token1;
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount0In,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );
        IERC20(token1).transferFrom(address(_tokenDistributor),address(this), IERC20(token1).balanceOf(address(_tokenDistributor)));
    }

    function _buy(uint amount0Out) internal {
        address[] memory path = new address[](2);
        path[0] = token1;
        path[1] = token0;
        router.swapTokensForExactTokens(
            amount0Out,
            IERC20(token1).balanceOf(address(this)),
            path,
            address(_tokenDistributor),
            block.timestamp
        );
        IERC20(token0).transferFrom(address(_tokenDistributor),address(this), IERC20(token0).balanceOf(address(_tokenDistributor)));

    }

    function _addL(uint amount0, uint amount1) internal {
        if (
            IERC20(token0).balanceOf(address(this)) < amount0 ||
            IERC20(token1).balanceOf(address(this)) < amount1
        ) return;
        router.addLiquidity(
            token0,
            token1,
            amount0,
            amount1,
            0,
            0,
            dev,
            block.timestamp
        );
    }

    modifier canSwap(uint t) {
        if (t != 2 || !autoSell.status) return;
        _;
    }

    function splitAmount(uint amount) internal view returns (uint, uint, uint) {
        uint toBurn = amount.mul(allot.burn).div(allot.total);
        uint toAddL = amount.mul(allot.addL).div(allot.total).div(2);
        uint toSell = amount.sub(toAddL).sub(toBurn);
        return (toSell, toBurn, toAddL);
    }
    function splitAmount2(uint amount2) internal view returns (uint, uint, uint) {
         uint total2Fee = allot.total.sub(allot.addL.div(2)).sub(allot.burn);
        uint toAddl = amount2.mul(allot.addL).div(total2Fee).div(2);
        uint toNft = amount2.mul(allot.nft).div(total2Fee);
        uint toMkt = amount2.sub(toAddl).sub(toNft);
        return (toAddl, toNft, toMkt);
    }
    function deposit(uint amountB) internal virtual { 

    }

    function trigger(uint t) internal canSwap(t) {
        uint balance = IERC20(token0).balanceOf(address(this));
        if (
            balance <
            IERC20(token0).totalSupply().mul(autoSell.minPart).div(
                autoSell.parts
            )
        ) return;
        uint maxSell = IERC20(token0).totalSupply().mul(autoSell.maxPart).div(
            autoSell.parts
        );
        if (balance > maxSell) balance = maxSell;
        (uint toSell, uint toBurn, uint toAddL) = splitAmount(balance);
        if (toBurn > 0) IERC20(token0).transfer(address(0xdead), toBurn);

        uint bef = IERC20(token1).balanceOf(address(this));
        if (toSell > 0) _sell(toSell);
        uint amount2 = IERC20(token1).balanceOf(address(this)).sub(bef); 

        (uint amount2AddL,uint amount2Nft,uint amount2Marketing)= splitAmount2(amount2);
        if(amount2Nft>0){

        }
        if (amount2Marketing > 0) {
            uint cake;
            for (uint i = 0; i < marketingAddress.length; i++) {
                cake = amount2Marketing.mul(marketingShare[i]).div(sharetotal);
                IERC20(token1).transfer(marketingAddress[i], cake);
            }
        }
        if (toAddL > 0) _addL(toAddL, amount2AddL);
        if (amount2Nft > 0) deposit(amount2Nft);
    }

  
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
interface IPancakePair {
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    event Swap(address indexed sender,uint amount0In,uint amount1In,uint amount0Out,uint amount1Out,address indexed to); 
    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);
    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
    function initialize(address, address) external;
    function totalSupply() external view returns (uint256);
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);    
    function feeTo() external view returns (address);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidity(address tokenA,address tokenB,uint amountADesired,uint amountBDesired,uint amountAMin,uint amountBMin,address to,uint deadline) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(address token,uint amountTokenDesired,uint amountTokenMin,uint amountETHMin,address to,uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn,uint amountOutMin,address[] calldata path,address to,uint deadline) external;
    function swapExactTokensForTokens(uint amountIn,uint amountOutMin,address[] calldata path,address to,uint deadline) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin,address[] calldata path,address to,uint deadline) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn,uint amountOutMin,address[] calldata path,address to,uint deadline) external;
    function swapTokensForExactTokens(uint amountOut,uint amountInMax,address[] calldata path,address to,uint deadline) external returns (uint[] memory amounts);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
} // SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
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

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.0;

import "./ERC20Rebase.sol";
import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20Rebase {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}
// SPDX-License-Identifier: MIT 
// Rebase Contracts

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Context.sol";
 
contract ERC20Rebase is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply; 
    string private _name;
    string private _symbol;


    mapping(address => uint256) private _gonBalances;
    mapping(address => bool) private _steady; 
    uint256 private _perFragment;
    uint256 public MAX_SUPPLY;
    uint256 private TOTAL_GONS;
    uint256 private constant MAX_UINT256 = ~uint256(0);

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
    function _setTotalSupply(uint256 amount,bool isAdd) private{
        if(isAdd) { 
            if(_totalSupply == 0){
                TOTAL_GONS=MAX_UINT256 / 1e20 - ((MAX_UINT256 / 1e20) % amount);
                _perFragment = TOTAL_GONS / amount;
            }
            else{
                TOTAL_GONS+=amount*_perFragment;
            }
            _totalSupply += amount;
        }
        else{
            TOTAL_GONS-=amount*_perFragment;
            _totalSupply-=amount;
        } 
    }

    function _reBase(uint256 newTotalSupply) internal virtual{
        bool isadd;
        uint256 change;
        if(newTotalSupply>_totalSupply){
            isadd =false;
            change=newTotalSupply-_totalSupply;
        }
        if(newTotalSupply<_totalSupply){
            isadd =true;
            change=_totalSupply-newTotalSupply;
        }
        uint256 unChange=holdersbalance()*change/_totalSupply;
        _totalSupply = newTotalSupply;
        _perFragment = TOTAL_GONS / _totalSupply;
        _setTotalSupply(unChange,isadd); 
    } 
    function balanceOf(address account) public view virtual override returns (uint256) {

        if(_steady[account] ||_totalSupply==0) return _balances[account]; 
        return _gonBalances[account] / _perFragment;
    } 
    function _setBalance(address account, uint256 amount) private{
        if(_steady[account])  _balances[account]=amount;
        else _gonBalances[account]= amount * _perFragment;
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

   
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
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

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = balanceOf(from);
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _setBalance(from,fromBalance - amount);  
            _setBalance(to, balanceOf(to) + amount); 
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        
        _setTotalSupply(amount,true);
        MAX_SUPPLY += amount*1400;
        unchecked {
            _setBalance(account,balanceOf(account)+ amount);
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = balanceOf(account);
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _setBalance(account,accountBalance - amount); 
            _setTotalSupply(amount,false);
            MAX_SUPPLY -= amount*1400;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }
    function _setSteady(address account, bool isSteady) internal virtual{
        if( _steady[account] != isSteady ){
            if(isSteady) {
                _balances[account]= balanceOf(account);
                addSteadyHolder(account);
            }
            if(!isSteady) {
                _gonBalances[account]=_balances[account] * _perFragment;
                removeSteadyHolder(account);
            }
            _steady[account]=isSteady;
        }
    }
    address[] public steadyHolders;
    mapping(address => uint256) steadyHolderIndexes;

    function holdersbalance() internal view returns(uint256 total) {
        for (uint i = 0; i < steadyHolders.length; i++) {
            total+=balanceOf(steadyHolders[i]);
        }
    }

     function addSteadyHolder(address steadyHolder) internal {
        steadyHolderIndexes[steadyHolder] = steadyHolders.length;
        steadyHolders.push(steadyHolder);
    }

    function removeSteadyHolder(address steadyHolder) internal {
        steadyHolders[steadyHolderIndexes[steadyHolder]] = steadyHolders[
            steadyHolders.length - 1
        ];
        steadyHolderIndexes[
            steadyHolders[steadyHolders.length - 1]
        ] = steadyHolderIndexes[steadyHolder];
        steadyHolders.pop();
    }

    
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

   
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
   
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
