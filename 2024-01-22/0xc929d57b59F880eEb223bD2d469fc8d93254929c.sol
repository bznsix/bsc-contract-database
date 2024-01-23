// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.4.22 <0.9.0;
// import "./Smart_Binance_Pro_Fork.sol";
// import "./S1.sol";
// import "./S2.sol";
// import "./S3.sol";
// import "./S4.sol";
// import "./S5.sol";
// import "./S6.sol";
// import "./S7.sol";
// import "./S8.sol";
// import "./S9.sol";
// import "./S10.sol";
// import "./S11.sol";
// import "./S12.sol";
// import "./S13.sol";
// import "./S14.sol";
// import "./S15.sol";
// import "./S16.sol";
// import "./S17.sol";
// import "./S18.sol";


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal pure virtual returns (bytes calldata) {
        return msg.data;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Insufficient balance");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "Approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) +
            (value);
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) -
            (value);
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(
            data,
            "Low-level call failed"
        );
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "ERC20 Operation did not succeed"
            );
        }
    }
}

contract Smart_Binance_Pro_Fork2 is Context {
    using SafeERC20 for IERC20;
    struct Node {
        uint32 id;
        uint32 SA;
        uint32 SB;
        uint24 SC;
        uint24 SD;
        uint24 QZ3;
        uint8 QZ2;
        uint8 Won;
        bool SE;
        address UP;
        address SF;
        address SG; }
    struct SH { uint16 point; address SI; }
    mapping(address => Node) internal _U;
    mapping(uint32 => uint32) internal QF;
    mapping(uint32 => uint32) internal QL;
    mapping(uint32 => address) internal QD;
    mapping(uint256 => address) internal QY;
    mapping(uint24 => address) internal QZ;
    mapping(uint24 => address) internal QZ1;
    mapping(uint24 => SH) internal SY;
    mapping(uint16 => address) internal SS;
    mapping(uint16 => address) internal QX;
    mapping(uint16 => address) internal QZ9;
    mapping(uint16 => address) internal Dont_Change_myAddress;
    address internal QE;
    // address internal SBTF;
    address internal OP;
    address internal SV;
    IERC20 internal Tether;
    uint32 internal SW;
    uint32 internal CS;
    uint24 internal SR;
    uint24 internal SO;
    uint24 internal SK;
    uint24 internal SP;
    uint16 internal SQ;
    uint16 internal QZ8;
    uint16 internal _Dont_Change_Id;
    uint256 internal _T_S;
    uint256 internal SN;
    uint256 internal QG;
    uint256 internal QZ7;
    bool internal _LOCK;
    bool internal Set_Bank;
    bool Set_One_Change;
    string internal IPFS;
    // Smart_Binance_Pro_Fork internal NBJ;
    // S1 internal co1;
    // S2 internal co2;
    // S3 internal co3;
    // S4 internal co4;
    // S5 internal co5;
    // S6 internal co6;
    // S7 internal co7;
    // S8 internal co8;
    // S9 internal co9;
    // S10 internal co10;
    // S11 internal co11;
    // S12 internal co12;
    // S13 internal co13;
    // S14 internal co14;
    // S15 internal co15;
    // S16 internal co16;
    // S17 internal co17;
    // S18 internal co18;

    constructor() {
        QE = _msgSender();
        Tether = IERC20(0x55d398326f99059fF775485246999027B3197955);
        // SBTF = 0xf5277092994033D53eBc988b9d90b3F079307992;
        // OP = 0xF9B29B8853c98B68c19f53F5b39e69eF6eAF1e2c;
        SV = 0xe317DE453861E071D88823EF4531C58d4a765F7f;
        // NBJ = Smart_Binance_Pro_Fork(0x87894D200a7bD50EeE34a3f970Bc5aa0D3C5935E);
        // co1 = S1(0xb21AAb44926D3568D81f6c7a62bFA4f816265489);
        // co2 = S2(0x71516304b03B682c99e06351AE3da61b6f676Bc2);
        // co3 = S3(0x87c9Ab0FE143a18b72fd3325eCB95E75e93eFc18);
        // co4 = S4(0x37Ac1C0B04Ba5Bef1B03539C4e6e1DfA003Aa5a8);
        // co5 = S5(0x0586dB7e902e3CdD9E02D832807cd57F9FaC3BE6);
        // co6 = S6(0x6C231F99DaB5Afb86cffacD1784a9B40c47Cb2A9);
        // co7 = S7(0xd502859542f397344Ec0dE8060031774711FBf71);
        // co8 = S8(0xE88DdF84B5f14C4c7e16e161900469FC56bC7A9A);
        // co9 = S9(0x785ca009B68327cc373289b3646c1800Be833532);
        // co10 = S10(0x1E45187F75d9Fe3a4DC7BD2a9c1d8BB8f216Fea9);
        // co11 = S11(0x8493AC9F11ec9238E5206F4aaa72e27fC68bC3C0);
        // co12 = S12(0x1fAAbBd09C077cc833E0c15269BF254558fee6c4);
        // co13 = S13(0x3aFF65bf4D8D468018FBB774B8aF4DeB5D69d7fb);
        // co14 = S14(0xa3121eBDb4A672C05443cF0DF574c994E3E0F862);
        // co15 = S15(0x32Aa22322396C140dCd1a1E778dDb4De355e665E);
        // co16 = S16(0xD38cB46e49571C2d82193d7180494F69866AFC26);
        // co17 = S17(0xd365a23a251546491DAB34469AAaefB5716aFF82);
        // co18 = S18(0x841eb4FEd12Cc118b284E1E6Af85071B61A545D7);
        // _LOCK = true;
        _T_S = block.timestamp;
    }

    function Reward_4() external {QJ();}

    function QJ() private {
        require(QH(_msgSender()), "User Not Exist");
        // require(_LOCK == false, "Proccesing");
        // require(block.timestamp > _T_S + 4 hours, "Reward_4 Time Has Not Come");
        QC();
        uint24 TMP = QT();
        require(TMP > 0, "Total Point Is 0");
        // _LOCK = true;
        SK = TMP;
        uint256 CZ = QZ5();
        SN = CZ;
        for (uint24 i = 0; i < SR; i = QA(i)) {
            Node memory T_N = _U[QZ[i]];
            uint24 RST = QS(QZ[i]);
            if (T_N.SC == RST) {
                T_N.SC = 0;
                T_N.SD -= RST;
            } else if (T_N.SD == RST) {
                T_N.SC -= RST;
                T_N.SD = 0;
            } else {
                if (T_N.SC < T_N.SD) {
                    T_N.SD -= T_N.SC;
                    T_N.SC = 0;
                } else {
                    T_N.SC -= T_N.SD;
                    T_N.SD = 0;
                }
            }
            _U[QZ[i]] = T_N;
            if (QZ6(QZ[i]) < 100) {
                if (RST * CZ > Tether.balanceOf(address(this))) {
                    Tether.safeTransfer(QZ[i], Tether.balanceOf(address(this)));
                } else {
                    Tether.safeTransfer(QZ[i], RST * CZ);
                }
            } else {
                if (((RST * CZ * 9) / 10) > Tether.balanceOf(address(this))) {
                    Tether.safeTransfer(QZ[i], Tether.balanceOf(address(this)));
                } else {
                    Tether.safeTransfer(QZ[i], ((RST * CZ * 9) / 10));
                }
            }
        }
        if ((QZ7 * QG * 10**17) > Tether.balanceOf(address(this))) {
            Tether.safeTransfer(_msgSender(), Tether.balanceOf(address(this)));
        } else {
            Tether.safeTransfer(_msgSender(), (QZ7 * QG * 10**17));
        }
        Tether.safeTransfer(SV, Tether.balanceOf(address(this)));
        // IERC20(SBTF).safeTransfer(QE, TMP * 10**18);
        _T_S = block.timestamp;
        QG = 0;
        SR = 0;
        SO = 0;
        QZ8 = 0;
        // _LOCK = false;
    }

    function QC() private {
        address U_P;
        address C_N;
        uint24 QZ4 = QP();
        for (uint256 USER = 0; USER < QG; USER = QB(USER)) {
            U_P = _U[_U[QY[USER]].UP].UP;
            C_N = _U[QY[USER]].UP;
            if (QW(C_N) == true) {
                QZ[SR] = C_N;
                SR++;
            }
            while (_U[C_N].QZ3 >= QZ4) {
                if (_U[C_N].SE == false) {
                    _U[U_P].SC++;
                    _U[U_P].SA++;
                } else {
                    _U[U_P].SD++;
                    _U[U_P].SB++;
                }
                if (QW(U_P) == true) {
                    QZ[SR] = U_P;
                    SR++;
                }
                C_N = U_P;
                U_P = _U[U_P].UP;
            }
            if (SZ(C_N) == 2**23) {
                SY[SP].point++;
                SY[SP].SI = C_N;
                SP++;
            } else {
                SY[SZ(C_N)].point++;
            }
        }
        for (uint24 j = 0; j < SP; j = QA(j)) {
            U_P = _U[SY[j].SI].UP;
            C_N = SY[j].SI;
            while (U_P != address(0)) {
                if (_U[C_N].SE == false) {
                    _U[U_P].SC += SY[j].point;
                    _U[U_P].SA += SY[j].point;
                } else {
                    _U[U_P].SD += SY[j].point;
                    _U[U_P].SB += SY[j].point;
                }
                if (QW(U_P) == true) {
                    QZ[SR] = U_P;
                    SR++;
                }
                C_N = U_P;
                U_P = _U[U_P].UP;
            }
        }
        for (uint24 i = 0; i < SP; i = QA(i)) {
            SY[i].point = 0;
        }
        SP = 0;
    }

    function Register(address Up) external {QI(Up);}
    function QI(address Up) private {
        // require(_LOCK == false, "Proccesing");
        require(_U[Up].QZ2 != 2, "Upline Has 2 Directs");
        require(_msgSender() != Up, "Its Your Address");
        require(!QH(_msgSender()), "You Are Registered");
        require(QH(Up), "Upline Is Not Exist");
        // _LOCK = true;
        Tether.safeTransferFrom(_msgSender(), address(this), 100 * 10**17);
        QD[SW] = _msgSender();
        SW++;
        Node memory user = Node({
            id: SW,
            SA: 0,
            SB: 0,
            SC: 0,
            SD: 0,
            QZ3: _U[Up].QZ3 + 1,
            QZ2: 0,
            Won: 0,
            SE: _U[Up].QZ2 == 0 ? false : true,
            UP: Up,
            SF: address(0),
            SG: address(0)
        });
        _U[_msgSender()] = user;
        QY[QG] = _msgSender();
        QG++;
        if (_U[Up].QZ2 == 0) {
            _U[Up].SC++;
            _U[Up].SA++;
            _U[Up].SF = _msgSender();
        } else {
            _U[Up].SD++;
            _U[Up].SB++;
            _U[Up].SG = _msgSender();
        }
        _U[Up].QZ2++;
        // _LOCK = false;
    }

    function Smart_Gift(uint8 X) external {
        // require(_LOCK == false, "Proccesing");
        require(QH(_msgSender()), "User Is Not Exist");
        require(QZ6(_msgSender()) < 1, "Just Point 0");
        require(QM(_msgSender()) < 21, "Just Big Side < 20");
        require(QU(_msgSender()), "You Did Smart_Gift Today");
        require(_U[_msgSender()].Won < 31, "You Won 30 Times");
        require(X < 6 && X > 0, "Just 1-2-3-4-5");
        require(Just_Gift_Balance() > 4, "Smart_Gift Balance Is 0");
        // _LOCK = true;
        QZ1[SO] = _msgSender();
        SO++;
        if (X == random(4)) {
            Tether.safeTransfer(_msgSender(), 5 * 10**17);
            // IERC20(SBTF).safeTransfer(_msgSender(), 1 * 10**18);
            _U[_msgSender()].Won++;
            QZ9[QZ8] = _msgSender();
            QZ8++;
        }
        // _LOCK = false;
    }

    function Dont_Change_My_Address() external {
        require( QH(_msgSender()),"User Is Not Exist" );
        require(_IS_USER_NotChange_LIST(_msgSender()), "You Did Before");
        Dont_Change_myAddress[_Dont_Change_Id] = _msgSender();
        _Dont_Change_Id++;}

    function Change_My_Address(address X) external {
        // require(_LOCK == false, "Proccesing");
        require(X != address(0), "Dont Enter address 0");
        require( QH(_msgSender()),"User Is Not Exist");
        require(! QH(X), "New Address Is Exist!");
        require(_IS_USER_NotChange_LIST(_msgSender()),"New Address Is In : Dont_Change_My_Address!");
        // _LOCK = true;
        Node memory A = _U[_msgSender()];
        QD[A.id] = X;
        Node memory B = _U[A.SF];
        B.UP = X;
        _U[A.SF] = B;
        Node memory C = _U[A.SG];
        C.UP = X;
        _U[A.SG] = C;
        Node memory U = _U[A.UP];
        if (A.SE == false) {U.SF = X;} else {U.SG = X;}
        _U[A.UP] = U;
        _U[X] = A;
        delete _U[_msgSender()];
        // _LOCK = false;
        }
    function _Write_IPFS(string memory I) public {
        require(_msgSender() == OP, "Just Operator");
        IPFS = I; }

    function _Set_Change_One_Address(address A) public {
        require(Set_One_Change == false, "Just One Times.");
        // require(_msgSender() == OP, "Just Operator");
        uint24 tmp = _U[A].SC;
        _U[A].SC = _U[A].SD;
        _U[A].SD = tmp;
        Set_One_Change = true;
    }

    function _Set_Reward_Fee(uint256 X) external {
        // require(_msgSender() == OP, "Just Operator");
        require(X <= 5 && X > 0, "Just 1-5");
        QZ7 = X;
    }

    function Smart_Buy_Over() public {
        // require(_LOCK == false, "Proccesing");
        require(QL[_U[_msgSender()].id] < 1, "Just 1 Time");
        require(QH(_msgSender()), "User Is Not Exist");
        require(QZ6(_msgSender()) > 2, "Just Point > 3");
        require(QM(_msgSender()) > 3, "Just Big Side > 4");
        require(Tether.balanceOf(_msgSender()) >= (30 * 10**17),"You dont have enough Tether!");
        // _LOCK = true;
        Tether.safeTransferFrom(_msgSender(), address(this), 30 * 10**17);
        Tether.safeTransfer(SV, 20 * 10**17);
        if (_U[QE].SC > 15) {
            _U[QE].SC -= 3;
            _U[QE].SA -= 3;
        } else if (_U[_U[QE].SF].SC > 15) {
            _U[_U[QE].SF].SC -= 3;
            _U[_U[QE].SF].SA -= 3;
        } else if (_U[_U[_U[QE].SF].SF].SC > 15) {
            _U[_U[_U[QE].SF].SF].SC -= 3;
            _U[_U[_U[QE].SF].SF].SA -= 3;
        }
        if (_U[_msgSender()].SC > _U[_msgSender()].SD) {
            _U[_msgSender()].SC += 3;
            _U[_msgSender()].SA += 3;
        } else {
            _U[_msgSender()].SD += 3;
            _U[_msgSender()].SB += 3;
        }
        QL[_U[_msgSender()].id]++;
        // _LOCK = false;
    }

    function _Upload( 
        address User, uint32 AL, uint32 AR, uint24 L, 
        uint24 R, uint8 C, bool LR, address UA, address LA, address RA ) external {
            // require(_msgSender() == OP, "Just Operator");
            // require(_Stop == false, "Stop"); 
            QD[SW] = User; SW++; 
            Node memory user = Node({
                id: SW, SA: AL, SB: AR, SC: L, SD: R, QZ3: 0, QZ2: C, Won: 0, SE: LR, UP: UA, SF: LA, SG: RA }); 
                _U[User] = user; }



    // function _Set_Users(uint8 CSC) external {
    //     require(_msgSender() == OP, "Just Operator");
    //     address[] memory ZA1;
    //     if (CSC == 1) {
    //         ZA1 = co1.GA();
    //     } else if (CSC == 2) {
    //         ZA1 = co2.GA();
    //     } else if (CSC == 3) {
    //         ZA1 = co3.GA();
    //     } else if (CSC == 4) {
    //         ZA1 = co4.GA();
    //     } else if (CSC == 5) {
    //         ZA1 = co5.GA();  
    //     } else if (CSC == 6) {
    //         ZA1 = co6.GA();
    //     } else if (CSC == 7) {
    //         ZA1 = co7.GA();
    //     } else if (CSC == 8) {
    //         ZA1 = co8.GA();
    //     } else if (CSC == 9) {
    //         ZA1 = co9.GA();
    //     } else if (CSC == 10) {
    //         ZA1 = co10.GA();
    //     } else if (CSC == 11) {
    //         ZA1 = co11.GA();
    //     } else if (CSC == 12) {
    //         ZA1 = co12.GA();
    //     } else if (CSC == 13) {
    //         ZA1 = co13.GA();
    //     } else if (CSC == 14) {
    //         ZA1 = co14.GA();
    //     } else if (CSC == 15) {
    //         ZA1 = co15.GA();
    //     } else if (CSC == 16) {
    //         ZA1 = co16.GA();
    //     } else if (CSC == 17) {
    //         ZA1 = co17.GA();
    //     } else if (CSC == 18) {
    //         ZA1 = co18.GA();
    //     }
    //     for (uint32 i = 0; i < ZA1.length; i++) {
    //         QD[CS] = ZA1[i];
    //         CS++;
    //     }
    // }

    // function _Import(uint24 start, uint24 end) external {
    //     require(_msgSender() == OP, "Just Operator");
    //     address User;
    //     for (uint24 i = start; i <= end; i++) {
    //         User = QD[i];
    //         SW++;
    //         Node memory user = Node({
    //             id: SW,
    //             SA: uint32(NBJ.User_Info(User).SA),
    //             SB: uint32(NBJ.User_Info(User).SB),
    //             SC: uint24(NBJ.User_Info(User).SC),
    //             SD: uint24(NBJ.User_Info(User).SD),
    //             QZ3: uint24(NBJ.User_Info(User).QZ3),
    //             QZ2: uint8(NBJ.User_Info(User).QZ2),
    //             Won: 0,
    //             SE: NBJ.User_Info(User).SE,
    //             UP: NBJ.User_Info(User).UP,
    //             SF: NBJ.User_Info(User).SF,
    //             SG: NBJ.User_Info(User).SG
    //         });
    //         _U[User] = user;
    //     }
    // }

    // function Smart_AirDrop() external {
    //     require(QH(_msgSender()), "User Is Not Exist");
    //     require(QF[_U[_msgSender()].id] < 2, "Just 2 Times");
    //     uint32 K = QZ6(_msgSender());
    //     if (K >= 0 && K < 1000) {
    //         IERC20(SBTF).transfer(_msgSender(), 100 * 10**18);
    //         QF[_U[_msgSender()].id]++;
    //     } else if (K >= 1000 && K < 5000) {
    //         IERC20(SBTF).transfer(_msgSender(), 1000 * 10**18);
    //         QF[_U[_msgSender()].id]++;
    //     } else if (K >= 5000) {
    //         IERC20(SBTF).transfer(_msgSender(), 10000 * 10**18);
    //         QF[_U[_msgSender()].id]++;
    //     }
    // }

    function _2_Days_Buy_Back() external {
        // require(block.timestamp > _T_S + 48 hours,"_2_Days_Buy_Back Time Has Not Come" );
        uint256 P = 90 * 10**18;
        for (uint24 i = 0; i < QG; i++) {
            if (P <= Tether.balanceOf(address(this))) {Tether.safeTransfer(QY[i], P);}}
        Tether.safeTransfer(SV, Tether.balanceOf(address(this)));
        // IERC20(SBTF).safeTransfer(QE, IERC20(SBTF).balanceOf(address(this)));
        _T_S = block.timestamp;
        QG = 0;
        SR = 0;
        SO = 0;
        QZ8 = 0;
        _LOCK = false;
    }

    function QZ5() private view returns (uint256) {return (QG * 90 * 10**17) / QT();}

    function random(uint256 Y) private view returns (uint256) {
        return
            (uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.prevrandao,
                        msg.sender
                    )
                )
            ) % Y) + 1;
    }

    function QH(address A) private view returns (bool) {
        return (_U[A].id != 0);
    }

    function QW(address A) private view returns (bool) {
        if (QS(A) > 0) {
            for (uint24 i = 0; i < SR; i++) {
                if (QZ[i] == A) {
                    return false;
                }
            }
            return true;
        } else {
            return false;
        }
    }

    function QU(address A) private view returns (bool) {
        for (uint24 i = 0; i < SO; i++) {
            if (QZ1[i] == A) {
                return false;
            }
        }
        return true;
    }

    function SZ(address A) private view returns (uint24) {
        for (uint24 i = 0; i < SP; i++) {
            if (SY[i].SI == A) {
                return i;
            }
        }
        return 2**23;
    }

    function _IS_USER_NotChange_LIST(address A) private view returns (bool) {
        for (uint8 i = 0; i < _Dont_Change_Id; i++) {
            if (Dont_Change_myAddress[i] == A) {
                return false;
            }
        }
        return true;
    }

    // function QN(address A) private view returns (bool) {
    //     for (uint8 i = 0; i < _C; i++) {
    //         if (ST[i] == A) {
    //             return false;
    //         }
    //     }
    //     return true;
    // }

    function QA(uint24 x) private pure returns (uint24) {
        unchecked {
            return x + 1;
        }
    }

    function QB(uint256 x) private pure returns (uint256) {
        unchecked {
            return x + 1;
        }
    }

    function QS(address A) private view returns (uint24) {
        uint24 min = _U[A].SC <= _U[A].SD ? _U[A].SC : _U[A].SD;
        if (min > 10) {
            return 10;
        } else {
            return min;
        }
    }

    function QT() private view returns (uint24) {
        uint24 T_P;
        for (uint24 i = 0; i < SR; i++) {
            T_P += QS(QZ[i]);
        }
        return T_P;
    }

    function Start() external {
        // require(_msgSender() == OP, "Just Operator");
        _LOCK = false;
    }

    function QP() private view returns (uint24) {
        uint24 min = _U[QY[0]].QZ3;
        for (uint24 i = 0; i < QG; i++) {
            if (min > _U[QY[i]].QZ3) {
                min = _U[QY[i]].QZ3;
            }
        }
        return min;
    }

    function _Set_S_Coin(uint8 A) external {
        require(_msgSender() == OP, "Just Operator");
        require(A >= 0 && A < 3, "Just 1-2-3");
        address[3] memory C = [
            0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d,
            0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3,
            0x40af3827F39D0EAcBF4A168f8D4ee67c121D11c9
        ];
        Tether = IERC20(C[A]);
    }

    function _Set_Smart_Bank(address X) external {
        require(_msgSender() == OP, "Just Operator");
        require(Set_Bank == false, "Just 1 Time");
        SV = X;
        Set_Bank = true;
    }

    function _Read_Smart_Bank() external view returns (address) {
        return SV;
    }

    function QM(address X) private view returns (uint32) {
        return _U[X].SA >= _U[X].SB ? _U[X].SA : _U[X].SB;
    }

    function _Read_IPFS() public view returns (string memory) {
        return IPFS;
    }

    function All_Register() public view returns (uint32) {
        return SW;
    }

    function All_User_Address(uint32 start, uint32 end) public view returns (address[] memory) {
        uint32 index;
        address[] memory ret = new address[]((end - start) + 1);
        for (uint32 i = start; i <= end; i++) {
            ret[index] = QD[i];
            index++;
        }
        return ret;
    }

    function Last_Value_Point() public view returns (uint256) {
        return SN / 10**18;
    }

    function Last_Total_Piont() public view returns (uint24) {
        return SK;
    }

    function Just_Contract_Balance() public view returns (uint256) {
        return Tether.balanceOf(address(this)) / 10**18;
    }

    function Just_Gift_Balance() public view returns (uint256) {
        return ((Tether.balanceOf(address(this)) / 10**18) - (QG * 95));
    }

    function User_Point_More_Than(uint32 X)
        public
        view
        returns (address[] memory)
    {
        address[] memory ret = new address[](SW);
        uint32 A;
        for (uint32 i = 0; i <= SW; i++) {
            uint32 min = QZ6(QD[i]);
            if (min >= X) {
                ret[A] = QD[i];
                A++;
            }
        }
        address[] memory ret2 = new address[](A);
        for (uint32 i = 0; i < A; i++) {
            ret2[i] = ret[i];
        }
        return ret2;
    }

    function Today_Register_Number() public view returns (uint256) {
        return QG;
    }

    function Today_Register_Address() public view returns (address[] memory) {
        address[] memory ret = new address[](QG);
        for (uint256 i = 0; i < QG; i++) {
            ret[i] = QY[i];
        }
        return ret;
    }

    function Today_Gift_Win_Address() public view returns (address[] memory) {
        address[] memory ret = new address[](QZ8);
        for (uint16 i = 0; i < QZ8; i++) {
            ret[i] = QZ9[i];
        }
        return ret;
    }

    // function _SBTF() external view returns (address) {
    //     return SBTF;
    // }

    function QZ6(address X) private view returns (uint32) {
        return _U[X].SA <= _U[X].SB ? _U[X].SA : _U[X].SB;
    }

    function Add_Approve_S_Coin() external view returns (address) {
        return address(Tether);
    }

    function User_Info(address User) public view returns (Node memory) {
        return _U[User];
    }

}