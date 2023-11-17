// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;


/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or
     *   {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the address zero.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}


interface IERC20 {
    function decimals() external view returns (uint256);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
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

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function totalSupply() external view returns (uint);

    function kLast() external view returns (uint);

    function sync() external;
}


contract GDPBurn2Earn is Ownable {

    address public usdtAddress = address(0x55d398326f99059fF775485246999027B3197955);
    address public gdpAddress = address(0x8624B3A4F29620390d06286DF207F6791C243389);
    address public burnAddress = address(0x000000000000000000000000000000000000dEaD);
    address public pairAddress = address(0xC69d7310a07582015a34cD057a49928bc7754797);
    address public adminAddress = address(0xcdf5A3eEF15236696c0bbeE2A78433E871e64e10);
    ISwapRouter private immutable _swapRouter;
    uint256 private constant MAX = ~uint256(0);

    mapping(address => address) refAddress;
    mapping(address => uint256) validRefNum;

    struct Product {
        uint256 amount;
        uint256 claimed;
        uint256 timestamp;
    }

    mapping (address => Product[]) private ProductA;
    mapping (address => Product[]) private ProductB;
    mapping (address => Product[]) private ProductC;

    uint256 public totalBurnValue;
    uint256 public totalReward;
    uint256 public totalTeamReward;

    mapping (address => uint256) private teamReward;
    mapping (address => uint256) private teamTotalReward;
    mapping (address => uint256) private teamTotalBurnValue;
    mapping (address => bool) private valUsed;
    
    constructor(){
        ISwapRouter swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _swapRouter = swapRouter;
        IERC20 token = IERC20(usdtAddress);
        token.approve(address(0x10ED43C718714eb63d5aA57B78B54704E256024E), MAX);
    }

    function joinMing(address _token, uint256 amount, address ref) public {
        require(msg.sender != address(ref), "EOR");
        if (_token == usdtAddress){
            IERC20 token = IERC20(_token);
            bool res = token.transferFrom(msg.sender, address(this), amount);
            require(res, "Transfer error");
            swapToken2Burn(amount);
            buildPkg(amount);
            if (amount >= 100 && !valUsed[msg.sender]){
                refAddress[msg.sender] = ref;
                valUsed[msg.sender] = true;
                validRefNum[address(ref)] = validRefNum[address(ref)] + 1;
                teamTotalBurnValue[ref] = teamTotalBurnValue[ref] + amount;
            }
        }else if (_token == gdpAddress){
            IERC20 token = IERC20(_token);
            bool res = token.transferFrom(msg.sender, burnAddress, amount);
            require(res, "Transfer error");
            ISwapPair mainPair = ISwapPair(pairAddress);
            (uint r0, uint256 r1,) = mainPair.getReserves();
            uint256 usdtValue = _swapRouter.quote(amount, r1, r0);
            buildPkg(usdtValue);
            if (usdtValue >= 100 && !valUsed[msg.sender]){
                refAddress[msg.sender] = ref;
                valUsed[msg.sender] = true;
                validRefNum[address(ref)] = validRefNum[address(ref)] + 1;
                teamTotalBurnValue[ref] = teamTotalBurnValue[ref] + usdtValue;
            }
        }
    }


    function caculTeamReward(address _owner, uint256 _amount)  private {
        if(refAddress[_owner] != address(0)){
            uint256 rewardAmount = _amount * 50 / 1000;
            uint256 enableReward = 0;
            address tempOwner = _owner;
            for (uint i; i < 10; i++) 
            {
                if (tempOwner == address(0)){
                    continue ;
                }
                address upper = refAddress[tempOwner];
                if (upper != address(0)){
                    if(validRefNum[address(upper)] > i){
                        teamReward[address(upper)] = teamReward[address(upper)] + rewardAmount;
                        teamTotalReward[address(upper)] = teamTotalReward[address(upper)] + rewardAmount;
                        enableReward = enableReward + rewardAmount;
                    }
                    tempOwner = address(upper);
                }else {
                    tempOwner = address(0);
                }
            }
            totalTeamReward = totalTeamReward + enableReward;
        }
    }

    function minerInfo(address owner, uint256 pId) public view  returns (Product[] memory pl){
        if (pId == 0){
            return ProductA[owner];
        }else if (pId == 1){
            return ProductB[owner];
        }else if (pId == 2){
            return ProductC[owner];
        }
    }

    function claimProfit() public returns(bool _res) {
        Product[] storage pLA = ProductA[msg.sender];
        uint256 totalProfit = 0;
        for (uint i = 0; i < pLA.length; i++) 
        {
            if(pLA[i].claimed < pLA[i].amount){
                uint256 times = (block.timestamp - pLA[i].timestamp) / 24 hours;
                if (times > 0){
                    uint256 profit = (times * pLA[i].amount / 100 ) - pLA[i].claimed;
                    pLA[i].claimed = pLA[i].claimed + profit;
                    totalProfit += profit;
                }
            }
        }
        Product[] storage pLB = ProductB[msg.sender];
        for (uint i = 0; i < pLB.length; i++) 
        {
            if(pLB[i].claimed < pLB[i].amount){
                uint256 times = (block.timestamp - pLB[i].timestamp) / 24 hours;
                if (times > 0){
                    uint256 profit = (times * pLB[i].amount / 100 ) - pLB[i].claimed;
                    pLB[i].claimed = pLB[i].claimed + profit;
                    totalProfit += profit;
                }
            }
        }
        Product[] storage pLC = ProductC[msg.sender];
        for (uint i = 0; i < pLC.length; i++) 
        {
            if(pLC[i].claimed < pLC[i].amount){
                uint256 times = (block.timestamp - pLC[i].timestamp) / 24 hours;
                if (times > 0){
                    uint256 profit = (times * pLC[i].amount / 100 ) - pLC[i].claimed;
                    pLC[i].claimed = pLC[i].claimed + profit;
                    totalProfit += profit;
                }
            }
        }
        ISwapPair mainPair = ISwapPair(pairAddress);
        (uint r0, uint256 r1,) = mainPair.getReserves();
        uint256 rAmount = _swapRouter.quote(totalProfit,r0, r1);
        IERC20 token = IERC20(gdpAddress);
        require(token.balanceOf(address(this)) >= rAmount, "Insufficient balance");
        _res = token.transfer(msg.sender, rAmount);
        require(_res, "Transfer error");
        caculTeamReward(msg.sender, totalProfit);
        totalReward = totalReward + totalProfit;
        return _res;
    }

    function claimTeamReward() public returns(bool _res) {
        require(teamReward[msg.sender] > 0, "Insufficient Reward");
        ISwapPair mainPair = ISwapPair(pairAddress);
        (uint r0, uint256 r1,) = mainPair.getReserves();
        uint256 rAmount = _swapRouter.quote(teamReward[msg.sender],r0, r1);
        IERC20 token = IERC20(gdpAddress);
        require(token.balanceOf(address(this)) >= rAmount, "Insufficient balance");
        _res = token.transfer(msg.sender, rAmount);
        require(_res, "Transfer error");
        return _res;
    }

    function withdraw() public returns(bool _res) {
        IERC20 token = IERC20(gdpAddress);
        _res = token.transfer(address(adminAddress), token.balanceOf(address(this)));
        return _res;
    }

    function profitInfo(address owner) public view  returns (uint256 totalProfit){
        Product[] memory pLA = ProductA[address(owner)];
        for (uint i = 0; i < pLA.length; i++) 
        {
            if(pLA[i].claimed < pLA[i].amount){
                uint256 times = (block.timestamp - pLA[i].timestamp) / 24 hours;
                if (times > 0){
                    uint256 profit = (times * pLA[i].amount / 100 ) - pLA[i].claimed;
                    totalProfit += profit;
                }
            }
        }
        Product[] memory pLB = ProductB[address(owner)];
        for (uint i = 0; i < pLB.length; i++) 
        {
            uint256 times = (block.timestamp - pLB[i].timestamp) / 24 hours;
            if (times > 0){
                uint256 profit = (times * pLB[i].amount / 100 ) - pLB[i].claimed;
                totalProfit += profit;
            }
        }
        Product[] memory pLC = ProductC[address(owner)];
        for (uint i = 0; i < pLC.length; i++) 
        {
            uint256 times = (block.timestamp - pLC[i].timestamp) / 24 hours;
            if (times > 0){
                uint256 profit = (times * pLC[i].amount / 100 ) - pLC[i].claimed;
                totalProfit += profit;
            }
        }
        return totalProfit;
    }

    function buildPkg(uint256 amount) private {
        if (amount < 1001 * 1e18){
            ProductA[msg.sender].push(Product(amount*2,0,block.timestamp));
        }else if (amount >= 1001 * 1e18 && amount < 5001 * 1e18){
            ProductB[msg.sender].push(Product(amount*5/2,0,block.timestamp));
        }else if (amount >= 5001 * 1e18){
            ProductC[msg.sender].push(Product(amount*3,0,block.timestamp));
        }
        totalBurnValue = totalBurnValue + amount;
    }

    function swapToken2Burn(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = usdtAddress;
        path[1] = gdpAddress;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            burnAddress,
            block.timestamp
        );
    }

    function getTotalBurnValue() public view returns(uint256 v){
        return totalBurnValue;
    }
    
    function getTeamReward(address _owner) public view returns(uint256 v){
        return teamReward[address(_owner)];
    }

    function getTotalTeamReward(address _owner) public view returns(uint256 v){
        return teamTotalReward[address(_owner)];
    }

    function getTotalTeamTotalBurnValue(address _owner) public view returns(uint256 v){
        return teamTotalBurnValue[address(_owner)];
    }

    function getRefAddress(address _owner) public view returns(address v){
        return refAddress[address(_owner)];
    }

    function getValidRefNum(address _owner) public view returns(uint256 v){
        return validRefNum[address(_owner)];
    }

    function getValidRefNum() public view returns(uint256 v){
        return totalReward;
    }

    function getAllTeamReward() public view returns(uint256 v){
        return totalTeamReward;
    }
}