// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

interface IERC20_ {
    /////////////////////////////////////////////////////// interface of the ERC20 standard as defined in the EIP
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    ///////////////////////////////////////////////////////
}
interface IERC20 is IERC20_ {
    ///////////////////////////////////////////////////////
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface IERC721_ {
    ///////////////////////////////////////////////////////
/// function balanceOf(address owner) external view returns(uint256 balance);
    function ownerOf(uint256 tokenId) external view returns(address);
    function getApproved(uint256 tokenId) external view returns(address);
    function isApprovedForAll(address owner, address operator) external view returns(bool);
    ///////////////////////////////////////////////////////
/// function transferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
/// function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool approved) external;
    ///////////////////////////////////////////////////////
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
}
library Num {
    ///////////////////////////////////////////////////////
    uint256 public constant MAX256      = type(uint256).max;
    uint256 public constant MAX160      = type(uint160).max;
    uint128 public constant MAX128      = type(uint128).max;
    uint64  public constant MAX64       = type(uint64 ).max;
    uint32  public constant MAX32       = type(uint32 ).max;
    uint256 public constant GWEI        = 10**9;
    uint256 public constant TWEI        = 10**12;
    uint256 public constant _0_000001   = 10**12;
    uint256 public constant _0_00001    = 10**13;
    uint256 public constant _0_0001     = 10**14;
    uint256 public constant _0_001      = 10**15;
    uint256 public constant _0_01       = 10**16;
    uint256 public constant _0_1        = 10**17;
    uint256 public constant _1          = 10**18;
    uint256 public constant _10         = 10**19;
    uint256 public constant _100        = 10**20;
    uint256 public constant _1000       = 10**21;
    uint256 public constant _10000      = 10**22;
    uint256 public constant _100000     = 10**23;
    uint256 public constant _1000000    = 10**24;
    ///////////////////////////////////////////////////////
    uint256 public constant CENT        = 10**16;
    uint256 public constant DIME        = 10**17;
    ///////////////////////////////////////////////////////
    address public constant _0          = address(0);
    address public constant MAP_        = address(0x10);
    address public constant _MAP        = address(0xFFFFFFFFFF);
    address public constant ESC         = address(0xFFFFFFFFFFFFFFFF);
    address public constant NULL        = address(type(uint160).max);
    ///////////////////////////////////////////////////////
    function _Mapped(address a) internal pure returns(bool) {
        return (MAP_ <= a)&&(a <= _MAP);
    }
    function _Mapped(address a, address b) internal pure returns(bool) {
        return _Mapped((a != NULL) ? a : b);
    }
    function _Escaped(address a) internal pure returns(bool) {
        return (MAP_ <= a)&&(a <= ESC);
    }
    function _Escaped(address a, address b) internal pure returns(bool) {
        return _Escaped((a != NULL) ? a : b);
    }
    ///////////////////////////////////////////////////////
    uint160 public constant _900        =  0x900;
    uint160 public constant URL         =  0x192;
    uint160 public constant GAS         =  0x9a5;
    ///////////////////////////////////////////////////////
    uint160 public constant SN          =   0x50;
    uint160 public constant VERSION     =   0x51;
    uint160 public constant VER2        =   0x52;
    uint160 public constant ACCOUNT     =   0xAC;
    uint160 public constant BLK         =   0xB1;
    uint160 public constant HASH        =   0xB5;
    uint160 public constant BALANCE     =   0xBA;
    uint160 public constant ESCAPE      =   0xE5;
    uint160 public constant ESCAPED     =   0xED;
    uint160 public constant CTX         =   0xFC;
    uint160 public constant STATUS      =   0xFF;
    ///////////////////////////////////////////////////////
    uint160 public constant USD         = 0xadd0;
    uint160 public constant USD1        = 0xadd1;
    uint160 public constant USD2        = 0xadd2;
    uint160 public constant TOKEN       = 0xadd8;
    uint160 public constant USD_        = 0xadd9;
    uint160 public constant NFT         = 0xaddA;
    uint160 public constant BIND        = 0xaddB;
    uint160 public constant SWAP        = 0xaddC;
    uint160 public constant DAO         = 0xaddD;
    uint160 public constant OWNER       = 0xaddE;
    uint160 public constant DELEGATE    = 0xaddF;
    ///////////////////////////////////////////////////////
    uint160 public constant DEBT        = 0xDeb0;
    uint160 public constant DEBTOFF     = 0xDeb1;
    uint160 public constant DEBTPASS    = 0xDeb2;
    ///////////////////////////////////////////////////////
}

/////////////////////////////////////////////////////////// IUniswapV2Router01
interface ISwapRouter {
    function factoryV2() external pure returns (address);
}
/////////////////////////////////////////////////////////// IUniswapV2Factory
interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
/////////////////////////////////////////////////////////// IUniswapV2Pair
interface ISwapPair {
    function sync() external;
}

library _MGT {
    ///////////////////////////////////////////////////////
    uint160 public constant BUY         =   0xFD01;
    uint160 public constant SELL        =   0xFD02;
    ///////////////////////////////////////////////////////
}
contract MGT is IERC20 {
    address internal  _owner;                           /// superuser
    address internal  _dex;
    address internal  _nft;                             /// MFNft
    ///////////////////////////////////////////////////////
    struct Tax {
        address bank;
        uint16  buy;                                    /// 32768 = 50%: per buy
        uint16  sell;                                   /// 32768 = 50%: per sell
    }
    Tax     internal  _tax;
    ///////////////////////////////////////////////////////
    struct Progress {
        uint64  nftId;                                  /// latest airdropped NFT id
        uint64  phase;                                  /// current airdrop phase
        uint128 amount;                                 /// tokens airdropped so far
    }
    struct Phase {
        uint128 unit;                                   /// tokens to drop per NFT in this phase
        uint128 nftIdMax;                               /// maximum NFT id of this phase
    }
    Progress internal _progress;
    mapping(uint64 => Phase)                        internal _phases;
    mapping(address => uint256)                     internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;
    ///////////////////////////////////////////////////////
    constructor(
        address nft,                                    /// NFT contract
        address mft,                                    /// MFT contract
        address router,                                 /// UniSwap/PancakeSwap
        uint64  k                                       /// = 1000
    ) {
        unchecked {
            if(router.code.length > 0)
                _dex = ISwapFactory(ISwapRouter(router).factoryV2()).createPair(address(this),mft);
            uint n;
            Phase memory p;
            p.unit = uint128(Num._0_01*85);
            p.nftIdMax = 4*k;                           /// 1~4000 receive 0.85 MGT per nft
            n += p.unit* 4*k;
            _phases[1] = p;
            p.unit = uint128(Num._0_01*70);
            p.nftIdMax = 6*k;                           /// 4001~6000 receive 0.7 MGT per nft
            n += p.unit* 2*k;
            _phases[2] = p;
            p.unit = uint128(Num._0_01*60);
            p.nftIdMax = 8*k;                           /// 6001~8000 receive 0.6 MGT per nft
            n += p.unit* 2*k;
            _phases[3] = p;
            p.unit = uint128(Num._0_01*50);
            p.nftIdMax =10*k;                           /// 8001~10000 receive 0.5 MGT per nft
            n += p.unit* 2*k;
            _phases[4] = p;
            _progress.phase = 1;                        /// 1st phase airdrop starts right the way
            _nft = nft;
            Tax memory tax;
            tax.bank = _owner = msg.sender;
            tax.buy  = uint16(uint(3)*0x10000/100);     /// 3% commission per buy
            tax.sell = uint16(uint(3)*0x10000/100);     /// 3% commission per sell
            _tax = tax;
            _balances[address(this)] = n;               /// funds for airdrops
            _balances[_owner] = Num._10000-n;
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function name() external view virtual override returns(string memory) {
        return 'MGT';
    }
    ///////////////////////////////////////////////////////
    function symbol() public view virtual override returns(string memory) {
        return 'MGT';
    }
    ///////////////////////////////////////////////////////
    function decimals() external view virtual override returns(uint8) {
        return 18;
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function totalSupply() external view virtual override returns(uint256) {
        return Num._10000;
    }
    ///////////////////////////////////////////////////////
    function balanceOf(address account) external view virtual override returns(uint256) {
        unchecked {
            uint160 cmd = uint160(account);
            if(account == Num._0    ) return _balances[Num._0];
            if(account > Num.ESC    ) return _balances[account];
            if(account < Num.MAP_   ) return _phases[uint64(cmd)].unit;
            if(cmd == Num.OWNER     ) return uint160(_owner);
            if(cmd == Num.SWAP      ) return uint160(_dex);
            if(cmd == Num.NFT       ) return uint160(_nft);
            if(cmd == Num.ACCOUNT   ) return uint160(_tax.bank);
            if(cmd == Num.SN        ) return Num._1*_progress.nftId;
            if(cmd == Num.BLK       ) return Num._1*_progress.phase;
            if(cmd == Num.ESCAPED   ) return _progress.amount;
            if(cmd == _MGT.BUY      ) return (Num._100*_tax.buy)>>16;
            if(cmd == _MGT.SELL     ) return (Num._100*_tax.sell)>>16;
            return 0;
        }
    }
    ///////////////////////////////////////////////////////
    function allowance(address owner, address spender) external view virtual override returns(uint256) {
        return _allowances[owner][spender];
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function approve(address spender, uint256 amount) external virtual override returns(bool) {
        unchecked {
            _allowances[msg.sender][spender] = amount;
            emit Approval(msg.sender,spender,amount);
            return true;
        }
    }
    ///////////////////////////////////////////////////////
    function transfer(address to, uint256 amount) external virtual override returns(bool) {
        unchecked {
            if(amount == 0)                             /// transfer owner when called by owner and 'amount'== 0
                if(_transferOwner(msg.sender,to))
                    return true;
            if(to < Num.MAP_)                           /// burn tokens if 'to'== 0x0~0xF
                to = Num._0;
            else if(to == Num.ESC)                      /// onwer only: trigger airdrop
                return _transfer(msg.sender,amount/Num._1);
            return _transferFrom(msg.sender,to,amount);
        }
    }
    ///////////////////////////////////////////////////////
    function transferFrom(address from, address to, uint256 amount) external virtual override returns(bool) {
        unchecked {
            if(from <= Num.ESC)
                return _config(uint160(from),to,amount);
            if(msg.sender != from) {
                uint256 a = _allowances[from][msg.sender];
                if(a < Num.MAX256) {
                    require(a >= amount,'*');
                    _allowances[from][msg.sender] = a-amount;
                }
            }
            return _transferFrom(from,to,amount);
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function _config(uint160 cmd, address arg, uint256 n) internal returns(bool) {
        unchecked {
            require(msg.sender == _owner,'!');
            if(cmd == _MGT.BUY      ) _tax.buy  = uint16((n<<16)/Num._100); else
            if(cmd == _MGT.SELL     ) _tax.sell = uint16((n<<16)/Num._100); else
            if(cmd == Num.ACCOUNT   ) _tax.bank = arg; else
                return false;
            return true;
        }
    }
    ///////////////////////////////////////////////////////
    function _transferOwner(address from, address to) internal virtual returns(bool) {
        unchecked {
            if(Num._Escaped(to)||(from == to))
                return false;
            require(from == _owner,"!");                /// only owner can transfer his ownership
            if((_owner = to) == Num._0)                 /// transfer owner
                emit Transfer(from,to,0);               /// the ownership is permanently given up when 'to'== 0x0
            return true;
        }
    }
    ///////////////////////////////////////////////////////
    function _transferTax(address from, uint256 amount, bool buy) internal virtual returns(uint256) {
        unchecked {
            Tax memory tax = _tax;
            if(tax.bank == Num._0)
                return amount;
            uint256 commission = buy ? tax.buy : tax.sell;
            commission = (amount*commission)>>16;
            if(commission == 0)
                return amount;
            _balances[tax.bank] += commission;
            emit Transfer(from,tax.bank,commission);
            return amount-commission;
        }
    }
    ///////////////////////////////////////////////////////
    function _transferFrom(address from, address to, uint256 amount) internal virtual returns(bool) {
        unchecked {
            if(from == to)
                return false;
            address dex = _dex;
            bool sell = (to == dex);
            bool buy = (from == dex);
            uint256 balance = _balances[from];
            require(balance >= amount,'#');
            _balances[from] = balance-amount;
            bool dropped = (_progress.nftId >= 10000);
            if(!dropped) {                              /// cannot trade before airdrop finish
                require(!buy,'Not yet to buy!');
                if(_progress.amount > 0)
                    require(!sell,'Not yet to sell!');
            }
            else if(buy||sell)                          /// commission
                amount = _transferTax(from,amount,buy);
            _balances[to] += amount;                    /// nevermind overflow, total=10000
            emit Transfer(from,to,amount);
            return true;
        }
    }
    ///////////////////////////////////////////////////////
    function _transfer(address caller, uint n) internal virtual returns(bool) {
        unchecked {
            require(caller == _owner,'!');
            address nft = _nft;
            uint nfts = IERC20_(nft).totalSupply();     /// total NFT minted so far
            Progress memory progress = _progress;
            Phase memory phase = _phases[progress.phase];
            if(progress.nftId >= phase.nftIdMax) {      /// current phase finished
                phase = _phases[++ progress.phase];     /// check if ready for next phase
            /// require(nfts >= phase.nftIdMax,'Not yet for next phase!');
                require(phase.unit > 0,'No more airdrops!');
            }
            n += progress.nftId;
            if(n > phase.nftIdMax)                      /// do not cross phase boundary within one call
                n = phase.nftIdMax;
            if(n > nfts)                                /// within minted NFT list
                n = nfts;
            require(progress.nftId < n,'Out of NFTs!');
            for(; progress.nftId < n;) {                /// airdrop to NFt holders
                address to = IERC721_(nft).ownerOf(++ progress.nftId);
                _transferFrom(address(this),to,phase.unit);
                progress.amount += phase.unit;
            }
            _progress = progress;
            return true;
        }
    }
}