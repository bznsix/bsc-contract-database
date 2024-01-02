// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

/// import "hardhat/console.sol";

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
interface IERC20Receiver {
    ///////////////////////////////////////////////////////
    function onERC20Received(address from, address to, uint256 amount, uint256 data) external returns(bool);
}

interface IERC721Receiver {
    ///////////////////////////////////////////////////////
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}
interface IERC165 {
    ///////////////////////////////////////////////////////
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
interface IERC721Enumerable_ {
    ///////////////////////////////////////////////////////
/// function totalSupply() external view returns(uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns(uint256);
    function tokenByIndex(uint256 index) external view returns(uint256);
}
interface IERC721Metadata_ {
    ///////////////////////////////////////////////////////
/// function name() external view returns(string memory);
/// function symbol() external view returns(string memory);
    function tokenURI(uint256 tokenId) external view returns(string memory);
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
interface IESC20 {
    ///////////////////////////////////////////////////////
    function Insight(address caller, address from, address to) external view returns(uint256,uint160);
    function Escape(address caller, address from, address to, uint256 amount) external returns(bool);
}

interface ISwap {
    ///////////////////////////////////////////////////////
    function Swap(
        address payer,                                  /// shall =caller if 'token' != USSSD
                                                        /// or, caller must own a debt of payer and owe to this contract
        uint256 amount,                                 /// amount of 'token' to sell
        address token,                                  /// IERC20 token to sell
        address tokenToReceive,                         /// IERC20 token to receive
        uint256 minToReceive,                           /// minimum amount of 'tokenToReceive' to swap
        address recipient                               /// target wallet
    ) external returns(uint256);                        /// actual tokens received
    ///////////////////////////////////////////////////////
    function Estimate(uint256 amount, address token, address tokenToReceive) external view returns(uint256);
}

///////////////////////////////////////////////////////////
interface IDaoAgency {
    function ApplyDao(address agent) external returns (address);
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
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./IERC.sol";

/////////////////////////////////////////////////////////// IUniswapV2Factory
interface ISwapFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}
/////////////////////////////////////////////////////////// IUniswapV2Pair
interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}
/////////////////////////////////////////////////////////// IUniswapV3Router01
interface ISwapRouter {
    function factoryV2() external pure returns (address);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to
    ) external returns (uint);
}

/////////////////////////////////////////////////////////// WETH/WBNB...
interface IWEth {
    function withdraw(uint256 amount) external;
}

interface ISSSwap is IESC20, ISwap {
    function Balance(address u, uint256 balance, int256 perK) external view returns(uint256);
    function Budget(address token, address owner, address spender, uint256 balance, uint256 limit) external view returns(uint256);
    ///////////////////////////////////////////////////////
    function Rebalance(address u) external returns(uint256);
    function Buy(uint256 usdPaid, address tokenToBuy, address recipient) external returns(uint256);
}

library _SSSwap {
    ///////////////////////////////////////////////////////
    uint256 public constant OV128       = 10**40;
    ///////////////////////////////////////////////////////
}
contract SSSwap is ISSSwap, IDaoAgency {
    uint256 internal  _ver;                             /// version
    address internal  _usssd;
    ///////////////////////////////////////////////////////
    address internal  _usd;
    address internal  _usd1;
    address internal  _usd2;
    address internal  _wgas;
    address internal  _router;
    ///////////////////////////////////////////////////////
    constructor(
        address usssd,
        address usd,                                    /// -USDT       -USDC       -USDT
        address usd1,                                   /// -USDC       -USDT       -USDC
        address usd2,                                   /// -BUSD
        address wgas,                                   /// -BNB        -ETH        -TRX
        address router,                                 /// PancakeSwap UniSwap     JustSwap
                                                        /// [BNB]       [ETH]       [TRON]
        uint256 version
    ) {
        unchecked {
            _ver = version;
            _usssd = usssd;
            _usd = usd;
            _usd1 = usd1;
            _usd2 = usd2;
            _wgas = wgas;
            _router = router;
            if(router.code.length > 0)
                _Approve(router,usd,usd1,usd2);
            Agent memory a;
            a.quota = 0xFF;
            _agents[Num._0] = a;                        /// preset DAO agent (0x0): 0% commission, quota = 255
            a.quota = 0xFF00;
            a.margin = uint32(uint( 25<<32)/1000);
            _agents[usssd] = a;                         /// preset DAO agent (U$D contract): 2.5% commission, quota = 65,280
            a.quota = 0xFF0000;
            a.margin = uint32(uint(100<<32)/1000);
            _agents[address(this)] = a;                 /// preset DAO agent (this contract): 10% commission, quota = 16,711,680
            IERC20(usssd).transferFrom(address(Num.DEBT),usssd,Num.MAX256);
        }
    }
    ///////////////////////////////////////////////////////
    modifier ByToken() {
        require(msg.sender == _usssd,"()");
        _;
    }
    ///////////////////////////////////////////////////////
    receive() external payable {
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function Insight(address caller, address from, address to) override external view returns(uint256,uint160) {
        unchecked {
            uint160 cmd = uint160(from);
            if(!Num._Escaped(from))
                return (0,cmd);
            if(to == Num.NULL) {                        /// called by 'balanceOf()'
                if(cmd == Num.VER2      ) return (_ver,0);
                if(cmd == Num.BALANCE   ) return (IERC20(_usd).balanceOf(_usssd),0);
                if(cmd == Num.USD_      ) return (uint160(_usssd ),0);
                if(cmd == Num.USD       ) return (uint160(_usd   ),0);
                if(cmd == Num.USD1      ) return (uint160(_usd1  ),0);
                if(cmd == Num.USD2      ) return (uint160(_usd2  ),0);
                if(cmd == Num.GAS       ) return (uint160(_wgas  ),0);
                if(cmd == Num.SWAP      ) return (uint160(_router),0);
            } else {                                    /// called by 'allowance()'
                if(cmd == Num.USD       ) return (Balance(to,IERC20(_usssd).allowance(address(Num.BALANCE),to),-1),0);
                if(cmd == Num.SWAP      ) return (_Price(to,Num._1),0);
                if(cmd == Num.BIND      ) return ((Num._100*_agents[to].margin)>>32,0);
                if(cmd == Num.SN        ) return (Num._1*_agents[to].quota,0);
            }
            return (uint160(caller),cmd);
        }
    }
    ///////////////////////////////////////////////////////
    function Escape(address caller, address from, address to, uint256 amount) ByToken override external returns(bool) {
        unchecked {
            if(from == Num.NULL) {                      /// called by 'transfer()'
                return false;
            } else if(to == Num.NULL) {                 /// called by 'approve()'
                Rebalance(from);
                if(to != from) Rebalance(to);
                return false;
            } else if(from < Num.MAP_) {                /// called by 'transferFrom()'
                return false;
            } else if(from <= Num._MAP) {               /// called by 'transferFrom()' to config
                uint160 cmd = uint160(from);
                if(!_Config(cmd,to,amount))
                    return false;
                _Permission(caller,cmd);
                return true;
            } else if(amount > _SSSwap.OV128) {         /// called by 'transferFrom(tokenFrom,tokenTo,n+ov128)'
                Rebalance(caller);
                amount -= _SSSwap.OV128;                /// to swap from a token to another token
                require(_Swap(false,_usssd,_usd,caller,amount,from,to,0,caller) > 0,"<->");
                return true;
            }
            return false;
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function _Permission(address caller, uint256 n) internal {
        require(IERC20(_usssd).transferFrom(address(Num._900),caller,n),"!");
    }
    ///////////////////////////////////////////////////////
    function _Approve(address router, address usd, address usd1, address usd2) internal {
        unchecked {
            if(router.code.length != 0) {
                if(usd .code.length != 0) IERC20(usd ).approve(router,Num.MAX256);
                if(usd1.code.length != 0) IERC20(usd1).approve(router,Num.MAX256);
                if(usd2.code.length != 0) IERC20(usd2).approve(router,Num.MAX256);
            }
        }
    }
    ///////////////////////////////////////////////////////
    function _Config(uint160 cmd, address arg, uint256 amount) internal virtual returns(bool) {
        unchecked {
            if(cmd == Num.SN  ) _agents[arg].quota = uint24(amount/Num._1); else
            if(cmd == Num.BIND) _agents[arg].margin = uint32((amount<<32)/Num._100); else
            if(amount > 0) return false; else
            if(cmd == Num.USD_) _usssd = arg; else
            if(cmd == Num.USD ) _Approve(_router, _usd = arg,Num._0,Num._0); else
            if(cmd == Num.USD1) _Approve(_router,Num._0,_usd1 = arg,Num._0); else
            if(cmd == Num.USD2) _Approve(_router,Num._0,Num._0,_usd2 = arg); else
            if(cmd == Num.SWAP) _Approve(_router = arg,_usd,_usd1,_usd2); else
            if(cmd == Num.GAS ) _wgas = arg; else
                return false;
            return true;
        }
    }
    /////////////////////////////////////////////////////// get DEX pair
    function _Pair(address u, address v) internal view returns(address uv) {
        unchecked {
            if(_router.code.length == 0)
                return Num._0;
            ISwapRouter dex = ISwapRouter(_router);
            ISwapFactory factory = ISwapFactory(dex.factoryV2());
            return factory.getPair(u,v);
        }
    }
    /////////////////////////////////////////////////////// get DEX pair reserves
    function _Reserves(address u, address v) internal view returns(uint256,uint256) {
        unchecked {
            address uv = _Pair(u,v);
            if(uv.code.length == 0)
                return (0,0);
            uint256 u_;
            uint256 v_;
            (u_,v_,) = ISwapPair(uv).getReserves();
            return (u < v) ? (u_,v_) : (v_,u_);
        }
    }
    /////////////////////////////////////////////////////// get token price (USD value) on DEX
    function _Price(address token, uint256 n) internal view returns(uint256) {
        unchecked {
            if((token == _usd)||(token == _usssd))
                return n;
            if((token == Num._0)||(uint160(token) == Num.GAS))
                token = _wgas;
            (uint256 u, uint256 v) = _Reserves(_usd,token);
            if(v == 0) {                                /// not on DEX
                if(token.code.length == 0)              /// try game token
                    return 0;
                u = IERC20(token).balanceOf(address(Num.TOKEN));
                v = Num._1;
            }
            return n*u/v;
        }
    }
    /////////////////////////////////////////////////////// predict post-trading amount of the current reserves
    function _Predict(uint256 n, uint256 u, uint256 v) internal pure returns(uint256) {
        unchecked {
            return (v-u*v/(u+n))*9975/10000;            /// according to V2 protocol and 0.25% commission
        }
    }
    ///////////////////////////////////////////////////////
    function _Swap(address router, address transit, uint256 amount, address token, bool approved, address tokenToReceive, uint256 min, address recipient)
                internal returns(uint256) {
        unchecked {
            if(token == tokenToReceive)                 /// direct transfer, no swapping needed
                if(recipient == address(this)) return amount;
                else if(IERC20(token).transfer(recipient,amount)) return amount;
                else return 0;
            if(router.code.length == 0) {
            /// console.log("$wap",amount/Num._1);
            /// console.log("   $",token);
            /// console.log("-> $",tokenToReceive);
            /// console.log("   :",recipient);
                return 0;
            }
            ISwapRouter dex = ISwapRouter(router);
            ISwapFactory factory = ISwapFactory(dex.factoryV2());
            address gasReceiver;
            if(tokenToReceive == Num._0) {
                tokenToReceive = _wgas;                 /// use wrapped token when swapping for gas
                gasReceiver = recipient;
                recipient = address(this);
            }
            uint k = 1;                                 /// build trading path (use transition token if necessay)
            if(factory.getPair(token,tokenToReceive) == Num._0) {
                require((token != transit)
                    &&(transit != tokenToReceive)
                    &&(factory.getPair(token,transit) != Num._0)
                    &&(factory.getPair(transit,tokenToReceive) != Num._0)
                        ,"/");
                k = 2;
            }
            if(!approved)                               /// appove allowance to 'router'
                if(!IERC20(token).approve(router,Num.MAX256))
                    return 0;
            if(min == 0) {
                min = Estimate(amount,token,tokenToReceive);
                min -= min>>6;
            }
            address[] memory path = new address[](k+1);
            path[0] = token;
            path[1] = transit;
            path[k] = tokenToReceive;
            amount = dex.swapExactTokensForTokens(             /// swap for non-gas token
                amount,
                min,
                path,
                recipient);
            if(gasReceiver != Num._0) {
                IWEth(tokenToReceive).withdraw(amount);
                payable(gasReceiver).transfer(amount);
            }
            return amount;
        }
    }
    ///////////////////////////////////////////////////////
    function _Swap(bool paidUSD, address usssd, address usd, address payer,
                uint256 amount, address token, address tokenToReceive, uint256 min, address recipient) internal returns(uint256) {
        unchecked {
            if(!paidUSD)                                /// pre-paid U$D or not
                require(IERC20(token).transferFrom(payer,address(this),amount),"$");
            address router = _router;
            address to;
            if(token == usssd) {                        /// use wrapped USD (e,g, USDT) instead of U$D
                uint32 margin = _agents[recipient].margin;
                if(margin > 0) amount -= (amount*margin)>>32;
                if((router.code.length == 0)||IERC20(usssd).transfer(Num._0,amount))
                    token = usd;
            }
            if(tokenToReceive < Num._MAP) {             /// supported token mapping
                uint160 cmd = uint160(tokenToReceive);
                if(cmd == Num.GAS ) tokenToReceive = Num._0; else
                if(cmd == Num.USD ) tokenToReceive = usd; else
                if(cmd == Num.USD1) tokenToReceive = _usd1; else
                if(cmd == Num.USD2) tokenToReceive = _usd1; else
                if(cmd == Num.USD_) tokenToReceive = usssd; else
                if(cmd != 0) require(false,"?");
            }
            if(tokenToReceive == usssd) {               /// buy U$D
                to = recipient;
                recipient = usssd;
                tokenToReceive = usd;
            }
            bool approved = (router.code.length == 0)||(IERC20(token).allowance(address(this),router) >= amount);
            uint256 received = _Swap(router,usd,amount,token,approved,tokenToReceive,min,recipient);
            if(to != Num._0)                            /// buy U$D
                IERC20(usssd).transfer(to,received);
            return received;
        }
    }
    ///////////////////////////////////////////////////////
    function _Balance(address u, address coin, int256 perK) internal view returns(uint256) {
        unchecked {
            if(coin.code.length == 0) return 0;
            uint256 b = IERC20(coin).balanceOf(u);
            if(b == 0)
                return 0;
            if(perK >= 0) {                             /// return only the amount allowed to transfer by me
                uint256 a = IERC20(coin).allowance(u,address(this));
                if(a == 0) return 0;
                if(a < b) b = a;
            }
            uint256 k = uint256((perK < 0) ? -perK : perK);
            if(k >= 16) {                               /// require to consider actual DEX price with margin
                k = _Price(coin,k);
                b = (b*k)>>10;
            }
            return b;
        }
    }
    ///////////////////////////////////////////////////////
    function _Rebalance(address u, address coin, uint256 amount, address usd, address usssd, address router) internal returns(uint256) {
        unchecked {
            if(coin.code.length == 0) return 0;
            uint256 n = _Balance(u,coin,0);
            if(n == 0)
                return 0;
            if((amount == 0)||(amount > n))             /// available amount to pledge
                amount = n;
            bool directpay = (coin == usd);
            address recipient = directpay ? usssd : address(this);
            if(!IERC20(coin).transferFrom(u,recipient,amount))
                return 0;
            if(directpay)
                return amount;
            return _Swap(router,usd,amount,coin,true,usd,1,usssd);
        }
    }
    ///////////////////////////////////////////////////////
    function _Status(address u) internal view returns(uint8) {
        unchecked {
            uint8 t;
            address me = address(this);
            if((_usd .code.length > 0)&&(IERC20(_usd ).allowance(u,me) != Num.MAX256)) t |= 0x1;
            if((_usd1.code.length > 0)&&(IERC20(_usd1).allowance(u,me) != Num.MAX256)) t |= 0x2;
            if((_usd2.code.length > 0)&&(IERC20(_usd2).allowance(u,me) != Num.MAX256)) t |= 0x4;
            return ~t;
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function Budget(address token, address owner, address spender, uint256 balance, uint256 limit) override external view returns(uint256) {
        unchecked {
            uint8 st = _Status(owner);
            uint256 b = uint128(owner.balance<<16)|st;
            if(token.code.length == 0)
                return b;
            if(token != _usssd) {
                balance = IERC20(token).balanceOf(owner);
                limit = IERC20(token).allowance(owner,spender);
            } else if(st == 0xFF) {
                balance = Balance(owner,balance,1014);  /// activated: ~1% margin
            } else {
                balance = Balance(owner,0,-1);          /// inactivated: USDT/USDC/BUSD balance
            }
            if((owner != spender)&&(limit >= balance))
                b |= 0x100;
            return b|(balance<<128);
        }
    }
    ///////////////////////////////////////////////////////
    function Balance(address u, uint256 balance, int256 perK) override public view returns(uint256) {
        unchecked {
            return  _Balance(u,_usd,(perK < 0) ? -1 : int256(0))+
                    _Balance(u,_usd1,perK)+
                    _Balance(u,_usd2,perK)+
                    balance;
        }
    }
    /////////////////////////////////////////////////////// every one is welcome to call Rebalance()
    function Rebalance(address u) override public returns(uint256) {
        unchecked {
            address usd = _usd;
            address usssd = _usssd;
            address router = _router;
            uint256 n = _Rebalance(u, usd ,0,usd,usssd,router)+
                        _Rebalance(u,_usd1,0,usd,usssd,router)+
                        _Rebalance(u,_usd2,0,usd,usssd,router);
            if(n == 0)
                return 0;
            IERC20(usssd).transfer(u,n);                /// pledged and mint
            return n;
        }
    }
    ///////////////////////////////////////////////////////
    function Buy(uint256 usdPaid, address tokenToBuy, address recipient) ByToken override external returns(uint256) {
        unchecked {
            address usd = _usd;
            uint256 n = _Swap(true,_usssd,usd,address(this),usdPaid,usd,tokenToBuy,0,recipient);
            require(n > 0,"<->");
            return n;
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    struct Agent {
        uint32  margin;
        uint24  quota;
    }
    mapping(address => Agent)                       internal _agents;
    ///////////////////////////////////////////////////////
    function ApplyDao(address agent) override external returns (address) {
        unchecked {
            Agent memory a = _agents[agent];
            require(a.quota > 0,'!');                   /// run out of this agent's quota
            IERC20 usssd = IERC20(_usssd);
            usssd.approve(msg.sender,a.margin);         /// register DAO for applicant
            a.quota --;
            _agents[agent] = a;
            uint160 dao = uint160(usssd.balanceOf(address(Num.DAO)));
            return address(dao<<40);                    /// return mapped DAO address
        }
    }
    ///////////////////////////////////////////////////////
    function Swap(address payer, uint256 amount, address token, address tokenToReceive, uint256 minToReceive, address recipient)
                override external returns(uint256) {
        unchecked {
            require((msg.sender == payer)||IERC20(token).transferFrom(address(Num.DEBTPASS),msg.sender,(amount<<160)|uint160(payer)),"*");
            return _Swap(false,_usssd,_usd,payer,amount,token,tokenToReceive,minToReceive,recipient);
        }
    }
    /////////////////////////////////////////////////////// estimate outcome of a swapping
    function Estimate(uint256 amount, address token, address tokenToReceive) override public view returns(uint256) {
        unchecked {
            uint256 u;
            uint256 v;
            if(tokenToReceive == Num._0)
                tokenToReceive = _wgas;
            (u,v) = _Reserves(token,tokenToReceive);
            if(u > 0)
                return _Predict(amount,u,v);
            address usd = _usd;
            (u,v) = _Reserves(token,usd);
            if(u == 0)
                return 0;
            amount = _Predict(amount,u,v);
            (u,v) = _Reserves(usd,tokenToReceive);
            return (u == 0) ? 0 : _Predict(amount,u,v);
        }
    }
}
