// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
import "./base.sol";
contract Income_Center is Base,Context {
    using SafeERC20 for IERC20;
    event register(address referrer, address user);
    event withdraw(address user);
    event dailyCalculate();
    event transferOwnership(address oldOwner,address newOwner);
    constructor(address _TT,address _OC,address _BLOA1,address _BLOA2,address _BLOA3) payable {
        OW = _msgSender();TT = IERC20(_TT);OC = Binary_Land(_OC);BL1 = BLOC1(_BLOA1);BL2 = BLOC2(_BLOA2);BL3 = BLOC3(_BLOA3);
        US[OW] = Node({UA:address(0),LA:address(0),RA:address(0),CR:0,NR:0,CB:0,NB:0,LN:0,RN:0,FL:0,LV:3,P2:1,P3:1,UD:0,ST:true});
        BG.push(OW);PF.push(OW);LD.push(OW);LR = block.timestamp;
    }
    modifier onlyOwner() {require(_msgSender() == OW, "Only owner!");_;}
    function _chkUsr(address _a) internal view returns (bool){if(US[_a].ST) return true; else return false;}
    function _chkBln(address _a) internal view returns (bool){bool st;uint ln=BU.length;for (uint i=0;i<ln;){if(_a == BU[i]) {st = true;break ;}unchecked{++i;}}return st;}
    function _trpb() private view returns (uint256) {if (NN == 0) return  0; else  return BP / uint(NN);}    
    function A_Register(address UplineAddress) external {
        address _u_a = UplineAddress;address _c_a = _msgSender();
        require(_chkUsr(_u_a), "Upline does not exist!");
        require(!_chkUsr(_c_a), "You are already registered!");
        require(_c_a != _u_a,"Don't enter your own address!");
        Node memory _u = US[_u_a];
        require( _u.LA == address(0) || _u.RA == address(0) ,"Left/right is not empty!");
        Node memory _c = US[_c_a];uint8 _d;
        if(_u.RA == address(0)) _u.RA = _c_a; else {_u.LA = _c_a;_d = 1;}
        US[_c_a] = Node({UA:_u_a,LA:address(0),RA:address(0),CR:0,NR:0,CB:0,NB:0,LN:0,RN:0,FL:0,LV:1,P2:0,P3:0,UD:_d,ST:true});BG.push(_c_a);
        if (OU[_c_a]) US[_u_a] = _u;
        else{
            TT.safeTransferFrom(_c_a,address(this),RF);
            PDP += PC;NP += NS;
            if(_d == 0){BP += (RF-RR-PC-NS);_u.NR += RR;}else BP += (RF-PC-NS);
            RU++;uint32 CurrentBalancesCount;uint32 _nb;
            while (true) {
                if (!_u.ST) {break;}if (_d == 0) _u.RN++; else  _u.LN++;CurrentBalancesCount = _u.LN;
                if ( _u.RN < CurrentBalancesCount) CurrentBalancesCount = _u.RN;_nb = CurrentBalancesCount - (_u.CB + _u.NB); 
                if (_nb != 0){_u.NB++;if(!_chkBln(_u_a))BU.push(_u_a);if (_u.NB <= MB) NN++;}
                US[_u_a] = _u;_c_a = _u_a;_c = US[_c_a];_d = _c.UD;_u_a = _u.UA;_u = US[_u_a];
            }
        }emit register(UplineAddress, _msgSender());
    }
    function B_Withdraw() external {
        require(!LC,"... Processing ...");
        require(_chkUsr(_msgSender()), "You are not allowed.");
        uint256 _r = US[_msgSender()].NR;
        require(_r != 0, "There is nothing to withdraw.");
        US[_msgSender()].CR += _r;
        TT.safeTransfer(_msgSender(), _r);
        US[_msgSender()].NR = 0;
        emit withdraw(_msgSender());
    }  
    function _dnup() private  {
        uint256 _c = BG.length;
        for (uint256 i=0; i < _c;) {if (US[BG[i]].LA == address(0)) NB.push(BG[i]);unchecked{++i;}}_c = NB.length;
        if(_c != 0){uint256 _r = NP / _c;for(uint256 i=0;i<_c;){US[NB[i]].NR += _r;unchecked{++i;}}NP = 0;delete NB;_c = 0;}
    }  
    function _dpp() private  {
        if(PP != 0){
            uint _c = PF.length;uint _p;
            for (uint256 i = 0;i<_c;){uint16 _p2 = US[PF[i]].P2;_p += _p2;unchecked{++i;}}
            uint256 _r = PP / _p;
            for (uint256 i = 0;i<_c;){Node memory _u = US[PF[i]];_u.NR += _r * _u.P2;_u.P2 = 1;US[PF[i]] = _u;unchecked{++i;}}
            PP = 0;
        }
        if(LP != 0){
            uint _c = LD.length;uint _p;
            for (uint256 i = 0;i<_c;){uint16 _p3 = US[LD[i]].P3;_p += _p3;unchecked{++i;}}            
            uint256 _r = LP / _p;
            for (uint256 i = 0;i<_c;){Node memory _u = US[LD[i]];_u.NR += _r * _u.P3;_u.P3 = 1;US[LD[i]] = _u;unchecked{++i;}}
            LP = 0;
        }        
    }
    function C_Calculate() external  {
        require(!LC,"... Processing ...");
        LC = true;
        require(block.timestamp > LR + 1 days,"Wrong time.");
        require(_chkUsr(_msgSender()),"You are not registered.");
        if(PP != 0 || LP != 0) {_dpp();}
        if(NN != 0){
            uint8 _MB = MB;uint8 _PMP = PMP;uint8 _LMP = LMP;uint8 _PFC = PFC;uint8 _LFC = LFC;uint256 _r = _trpb();uint256 _c = BU.length;
            for (uint256 i=0; i < _c;) {
                Node memory _c_u = US[BU[i]];
                if(_c_u.NB < _MB){ _c_u.NR += _r * _c_u.NB;
                }else{
                    _c_u.NR += _r * _MB;
                    if(_c_u.LV == 1){
                        _c_u.FL++;if(_c_u.FL >= _PFC){PF.push(BU[i]);PP += _c_u.NR;_c_u.LV++;_c_u.FL = 0;_c_u.NR = 0;_c_u.P2 = 1;}
                    }else if(_c_u.LV == 2){
                        uint16 _p = _c_u.NB - _MB;if(_p == 0) _p =1;
                        if(_p >= _PMP){ _c_u.P2 = _PMP;_c_u.FL++;}else _c_u.P2 = _p;
                        if(_c_u.FL >= _LFC){ LD.push(BU[i]);LP += _c_u.NR;_c_u.LV++;_c_u.FL = 0;_c_u.NR = 0;_c_u.P3 = 1;}
                    }else{
                        uint16 _p = _c_u.NB - _MB;if(_p == 0) _p =1;
                        if(_p <= _PMP){ _c_u.P2 = _p;_c_u.P3 = 1;}else{_c_u.P2 = _PMP;_p -= _PMP;if (_p == 0) _p = 1;_c_u.P3 = _p;}
                        if(_c_u.P3 > _LMP) _c_u.P3 = _LMP;
                    }
                }_c_u.CB += _c_u.NB;_c_u.NB = 0;US[BU[i]] = _c_u;unchecked{++i;}
            }_r = 0;NN = 0;BP = 0;delete BU;
        }
        if(NP != 0) _dnup();RU = 0;LR = block.timestamp;
        TT.safeTransfer(PD,PDP);
        PDP = 0;LC = false;
        emit dailyCalculate();
    }
    function D_TransferOwnership(address newOwner) external {
        require(!LC,"... Processing ...");
        require(newOwner != address(0),"Wrong address.");
        require(!_chkUsr(newOwner),"Already registered.");
        uint _ln = BG.length;for (uint i=0; i<_ln;){if(BG[i] == _msgSender()){BG[i] = newOwner;break;}unchecked{++i;}}
        _ln = PF.length;for (uint i=0; i<_ln;){if(PF[i] == _msgSender()){PF[i] = newOwner;break;}unchecked{++i;}}
        _ln = LD.length;for (uint i=0; i<_ln;){if(LD[i] == _msgSender()){LD[i] = newOwner;break;}unchecked{++i;}}
        US[newOwner] = US[_msgSender()];
        address _up = US[_msgSender()].UA;if(US[_up].RA == _msgSender()){US[_up].RA = newOwner;}else{US[_up].LA = newOwner;}
        address _r = US[_msgSender()].RA;if(_r != address(0)){US[_r].UA = newOwner;}
        address _l = US[_msgSender()].LA;if(_l != address(0)){US[_l].UA = newOwner;}
        delete US[_msgSender()];
        emit transferOwnership(_msgSender(), newOwner);
    }
    function E_ChangeStableCoin(address _addr) external onlyOwner {TT = IERC20(_addr);}
    function F_Emergency() external onlyOwner {
        require( block.timestamp > LR + 7 days,"Wrong time.");
        require(TT.balanceOf(address(this)) != 0 , "Zero balance!");
        TT.safeTransfer(OW,TT.balanceOf(address(this)));LR = block.timestamp;
    }
    function J_Upload(address User) external onlyOwner {require(!_chkUsr(User) , "Already registered!");OU[User] = true;}
    function I_Import(address N,address UA,address LA,address RA,uint32 LN,uint32 RN,uint8 UD) external onlyOwner{
        require(!_chkUsr(N), "Already registered!");
        require(_chkUsr(UA), "upline does not exist!");
        require(US[UA].LA == address(0) || US[UA].RA == address(0) ,"Upline has two directs!");
        bool st = false;uint8 _d  = 0;
        if(UD == 0 && US[UA].RA == address(0))st = true;else if(UD == 1 && US[UA].LA == address(0)){_d = 1;st = true;}
        require(st,"Something went wrong!");
        US[N] = Node({UA:UA,LA:LA,RA:RA,CR:0,NR:0,CB:0,NB:0,LN:LN,RN:RN,FL:0,LV:1,P2:0,P3:0,UD:UD,ST:true});
        if(_d==0) US[UA].RA = N;else US[UA].LA = N;
        address _up_addr = UA;address _curr_addr = N;Node memory _up = US[_up_addr];Node memory _current = US[_curr_addr];
        while (true) {
            if (!_up.ST) {break;}
            if (_d == 0) _up.RN = _up.RN + (RN+LN+1); else  _up.LN = _up.LN + (RN+LN+1);
            US[_up_addr] = _up;_curr_addr = _up_addr;_current = US[_curr_addr];_d = _current.UD;_up_addr = _up.UA;_up = US[_up_addr];
        }
    }
    function H_Import_All() external  onlyOwner{
        require(IC>=0 || IC<3,"No more users to import.");
        address[] memory _ad;
        if(IC == 0)_ad = BL1.BLOF();else if(IC == 1)_ad = BL2.BLOF();else if(IC == 2)_ad = BL3.BLOF();
        uint _c = _ad.length;
        for(uint256 i = 0; i < _c;){
            address _a = _ad[i];
            if(!_chkUsr(_a)){
                uint8 _d;if(OC.User_Information(_a).DirectionOfCurrentNodeInUplineNode == -1)_d = 1;
                Node memory _u = 
                Node({UA:OC.User_Information(_a).UplineAddress,
                LA:OC.User_Information(_a).LeftNode,
                RA:OC.User_Information(_a).RightNode,
                CR:OC.User_Information(_a).TotalUserRewarded,
                NR:OC.User_Information(_a).RewardAmountNotReleased,
                CB:uint16(OC.User_Information(_a).NumberOfBalancedCalculated),
                NB:uint16(OC.User_Information(_a).NumberOfNewBalanced),
                LN:uint32(OC.User_Information(_a).NumberOfChildNodeOnLeft),
                RN:uint32(OC.User_Information(_a).NumberOfChildNodeOnRight),
                FL:0,LV:1,P2:0,P3:0,UD:_d,ST:OC.User_Information(_a).Status
                });US[_a] = _u;BG.push(_a);
            }unchecked{++i;}
        }unchecked{++IC;}
    }
    function G_Change_Product(address _addr) external onlyOwner{PD = _addr;}
    function Total_Number_Of_Users() external view returns (uint256 Number_of_Beginners_Users,uint256 Number_of_Professionals,uint256 Number_of_Leaders) {return (BG.length-1,PF.length-1,LD.length-1);}   
    function Today_Contract_Status() external view returns (uint32 Today_Number_Of_Registrations,uint256 Today_Balanced_Users_Count,uint32 Today_Balances_Count,uint256 Today_Reward_Per_Balance){return (RU,BU.length,NN,_trpb()/10**18);}
    function Project_Information() external view returns (uint256 Registration_Fee_in_Dollars,IERC20 Used_Token_Address){return (RF/10**18,TT);}
    function Check_User(address _your_address) external view returns (string memory){if(_chkUsr(_your_address))return "User is registered in the contract."; else return "User does not exist in the contract.";}
    function Your_Information(address _your_address) external view returns(uint32 Your_Left_Hand_Count,uint32 Your_Right_Hand_Count,uint256 Your_Calculated_Reward,uint256 Your_Not_Released_Reward,uint16 Your_Calculated_Balance,uint16 Your_Not_Released_Balance,uint8 Your_Level) {return (US[_your_address].LN,US[_your_address].RN,US[_your_address].CR/10**18,US[_your_address].NR/10**18,US[_your_address].CB,US[_your_address].NB,US[_your_address].LV);}
    function Export(address _a) external view returns(Node memory){return US[_a];}
}// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
import "./bl.sol";
import "./ou1.sol";
import "./ou2.sol";
import "./ou3.sol";
contract Base{
    struct Node {address UA;address LA;address RA;uint256 CR;uint256 NR;uint32 LN;uint32 RN;uint16 CB;uint16 NB;uint16 FL;uint16 P2;uint16 P3;uint8 LV;uint8 UD;bool ST;}
    mapping(address => Node) internal US;mapping(address => bool) internal OU; 
    address[] internal BG;address[] internal PF;address[] internal LD;address[] internal NB;address[] internal BU;address internal OW;address internal PD;
    IERC20 internal TT;uint256 internal LR;uint256 internal BP;uint256 internal PP;uint256 internal LP;uint256 internal PDP;uint256 internal NP;
    uint256 constant internal RF = 120 * 10**18;uint256 constant internal PC = 7 * 10**18;uint256 constant internal RR = 50 * 10**18;uint256 constant internal NS = 13 * 10**18;
    uint32 internal RU;uint32 internal NN;uint8 internal IC; 
    uint8 constant internal MB = 10;uint8 constant internal PFC = 8;uint8 constant internal LFC = 20;uint8 constant internal PMP = 10;uint8 constant internal LMP = 40;
    bool internal LC;Binary_Land internal OC;BLOC1 internal  BL1;BLOC2 internal  BL2;BLOC3 internal  BL3;
}    
 // SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
contract BLOC3{ 
    address[] internal BLOA;
    constructor() payable { 
        BLOA = [ 
        0x4b32C268C92290D62700d5A72B43952b5867e195,
        0xE15f1C118f0Ad6EA04b633B22FC2a87766E41508,
        0xFFd1338680739669860A51f71a7e4600520086FE,
        0x5EdA25189dE22F4e5Cd1f31058e42990dD5B203B,
        0x668568F9AB1F610DA6718c6f5A2b9cA7f8f06062,
        0x86B4335D902f8C685445BC167b4a0F27F35144Da,
        0x2e4090E550532814544693f3354592962384e410,
        0x028fdd3bF5330F421E88404F92c923C01335e9Cc,
        0xAcCe6735A87d3313CD19C3Cc2e8fC4B7cA733281,
        0x66d7293da168D614254BF1C85722017F3A08c08c,
        0x67B437fe315f56227f120527AC1c9aA773Db1f44,
        0x974a3C721401b3ee4e9DD9fc0e28F476f68C93F7,
        0x8781DC52e4b4A29cc3Ff1799d38ab3292E49ab95,
        0x4085a0420c0096996237F9658cc8C0575B4A4d21,
        0x016d765283B3cE35A079ffaDb474ABeFDc5B059B,
        0x834920784f3438050EeFBf952659Fa67463105eF,
        0x5ab879F0087Db296b536A391726FC5Cd7DfE8D0B,
        0x87b32a2418496D8dFE4011624b3BF82A7F0A9529,
        0x5484242F3Ac9dB4814CdBA0a02f91A7081Ee4F33,
        0x2612Ef04936Fd65ae7e3aD2A8217003084634450,
        0xA2903aE673d14aB656765908F066BAc44F48de20,
        0x5FD890c9E459ff1a8fbc2C416740702e465355c0,
        0xeAceA6E112ed237BEe8ad10122858D4c5eaE40eB,
        0x4d3b81147A1b24ea08419ec4C8C6D72aC812c57F,
        0x35E4c0dfB8bF50E5C95B7Fc046D9a7cf914Dc04E,
        0x409De8cB598DA65Ca1c565101EFf0Be298BA18fe,
        0xD8109b3d41898A339f8e19dBc94B92823645f706,
        0xFe368dC1DD0a9C1dc8373D33958297654c82d9c0,
        0x93F708FE591a9b8E5231e4dFb9CCcf7bA4fF1030,
        0x477c333827C0fF7B2cf5C004481fEDc048D4dd57,
        0x114eC40e95e5627F95B5FeF0e8073BF70bf82E03,
        0xa34Aea2d9d2d8f6187Dba747d471BfAD6868a10C,
        0xeC804f16B75835ed5C9f099beE509F3FFA09f87d,
        0xDD76DB87F6781B5D28F3Ca0593dDe3E86031D30c,
        0xc6eb979bF9f7232E17a0909883D3E05A90165e1a,
        0xE36ea67ebFEc6e17f4673b4965A8234bC8d15545,
        0x571B98140A60eE83eCF7bB8B2E316872d8f9198D,
        0x8869cEf9a8EbC9f72332b3ACfA48BF53766FAB32,
        0xE1fD7eB82859eA3879210e2Eb790482cE044ecc2,
        0x04d558667B1C69c625a8B3BF2aC64DEd868f9DeF,
        0xb82fFF54c0535818087272E6D77E15bbeb8Bb9be,
        0x959ABc919Df0d07ADdd5116D9C306549a0d798b3,
        0xA09c4D01d556Fc955eCe05eC539c833703102995,
        0x22fd59e1E86a3E2CBE3b4d8Dc97674c24f5CA7a1,
        0x653b0df3FC4d1a7eE100A0dfbec14db4c64C8599,
        0x8DDAB83b26C24e5BEBD171Bb4f35E8c21CE63364,
        0x1788A5aEAe6dC1aB1B72c9E0155ACE47647675D3,
        0x27a745707885cd1D2E24D36Ae84ad280A01ED497,
        0x9285ef4f76854192FEA203072D8A961aEB386727,
        0x48f6e5950D8F61F7dBf06918908d3AD6d15A885D,
        0x71f8802C405739A39afD8Fc56f525F1C218373fD,
        0x4394ACa1aB0986c60877c9546fb726d0F961792e,
        0x470CB08E25f68955dC3A9197fFf0785bAb921721,
        0x3AB6Ce71B0bc6a9Ce111b5d179506b7fFc93aD88,
        0x99602d70A98C587023922c467E4793c6Ddc950C1,
        0xB02234e5583632f28F0b5AA2e3f2871c580d59bA,
        0x319EfEd9479A8709D2bcf655705Ed20C6db45c10,
        0x6804643926873B872523033cF4141EAdc3F0927E,
        0xB8313E6996eE92B7cEB2DbcBF5E31635f8527e4D,
        0xb79cDa92A01945727b27f30b1BEea25E3c4Dc902,
        0xA9434FAa148Fe818a0eb59aC6e037368Dec31F51,
        0x9a4A77e4a93b17BB04F5aeb0453595D65132969e,
        0xCDfeAFbD6179CfC3311AD701c685EF7AffdA9D31,
        0x0e8e700536520419114eBa559D5Eac452AA4566d,
        0x0cd657DA7eF4f923C026EB74812230B7cB437ecc,
        0xd00726B547eFD2802B14f73e7d8d745520EBc96B,
        0xccaf6501589F15B41d1478B3a6c0F7c3a902E69d
    ];} 
    function BLOF() public view returns(address[] memory){ return BLOA; }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
contract BLOC2{ 
    address[] internal BLOA;
    constructor() payable { 
        BLOA = [ 
        0xeb0b96658Cac5150090db2768f1fFc60b55c43CF,
        0xE61d406852c36492Fb10000AE636ee43CCc49b4F,
        0x65BA12453c892Be02F257124CFf1326031FB4cC6,
        0xEA992a311CD623455518dAf7F62AacC750C42ccc,
        0x96bF9394c9a86264d38b15C50fAdF11eB1BDB3B1,
        0xce262AC363B6DdEE98De5FF7f233cD4cc6be3aaD,
        0xC07EaF9F15394ADccE4a080cc9710FED41cD2Ce8,
        0x78b7856Fe18EfbCF2B80204e27544e7791222298,
        0x6bE83611beeCd97a9A3879E5d0Fa0111cDC9C014,
        0x2386d59817512e25E3bD3BAD451aEAC598a0b3d4,
        0x61E1d52edabeC2e0d7FcD4184cc46AFF2AA78d00,
        0x84d74C230d1B5E9cD10654Dc280Bd20c68905E6a,
        0x7595ddcE74499C4e15561B33f4BE7C4F02a721bB,
        0x79cFd9aC4b5dE749d384bc8601114be2e4f2BA19,
        0x988Bf72BE7fab992ac19E61126c4Af183Ce6e90D,
        0xD0e7312a1b89856A8d346517C9104f8cBB074645,
        0x44b6554B345A3092a3DAA3210e9b1347249Db52a,
        0x65a5964e796bF026541B4AC1418A38C8DA8D5262,
        0x1EbA82774a95A6C1A7ACBFfb99ad0B9f5E8a1D6D,
        0x774609F1c34e59c65C3357f7Da9cB0776499E7A8,
        0xFC98a5B6648cE7d62a253EDD37070E7d484e3185,
        0x79bc1BE5054065355b28f33a17E8c6B95b206876,
        0x3eba57a9abdDFBddBFEe77107c4F81384D2c42B9,
        0xa0197cE062f879413A65B9f8979A35eEef062EB7,
        0xdCA74b512dF907C9dE84677107aD5D559C5bA9aC,
        0xb1a8bF576832eeE9bB613158dc9fdc7CE70ef99D,
        0x1E9B37b6d5D63a033e8911d3bD950c3f2eE7d9Ea,
        0x8d57F28445c42fb0Cc80f3a2F88157D54dadc158,
        0x53Da71866744De8E9714b95f2Dd59ec0D3566BeC,
        0x7113bD281c563231d8f3cEB3278062a2708ac895,
        0xf6BF5c8953B54A7BcDC6f2AaC6814ce6a2b6bb88,
        0xf97992CBe138409FC8817D461A01FcF3F56C1c19,
        0x936bb9eF1DD4845Bed55af93859345664627E336,
        0xd5383F5E83a0BFD3fb5515687C08ce44d7514D1c,
        0x80137E81597D676B3F3D026e1fF4B3D13D0678A4,
        0xAFcA87B7D43FC7a84EAC877C28C9Aa4cBE14cF15,
        0x2575EAB22CDFeEEd0f62EDc36Fd27A5DF0d045dC,
        0xcA82B0eac8F0768A1F8f76F9b0B6AEC6b52978F5,
        0x2453a0B58eC05752301D686eafb1F266E546E968,
        0xA06c3ccB9225A2aEd6633accD49A458875aDA522,
        0x81ECfbD7241E0F70b345460E9f900AeAA7b48F44,
        0xF9604281aB67fb764D56304eE2D9890De66dE7b1,
        0x0250edA8Dd2fdC390A40296F0bA4ffF7C8340Ee9,
        0x59206A66e763aaAcEed3cca845cE6399D3E68F33,
        0x3201fB4995fd9a33503cD898fD15E0E73069a9F5,
        0x518b66101E7f12F18d14d87d7dD770A4e35650F0,
        0xB67c3a77ce52d5E8A2035134510F4346df0D4C20,
        0x3e00cB1156b22734099b05C194E98bdF973c0129,
        0x36590d4cD6cCAB9304934c8aE09D140CF1208E11,
        0x7bEF09EF7a2CB05Cc3CF9eaf10D9505363869950,
        0x0812BD203C03EeeeAB0E3f724Be9D82F44803B63,
        0x17B545eC7c8093fD31A42828e15bFB93471E4De9,
        0xf5b77d0562BCDF8aC1bB29b59409217C4D77Bb7F,
        0x158b5414F3f97b85376A3A3E2aeF62D7E579D724,
        0x2a430B0A5d2d703FB33455604Fe3c6317204CefA,
        0xA55d9ba9169Dba5bbC7B3f0A7c42caC1D236d28c,
        0x26e1DC5Dffd0396f1047faA8D8F6f0f76b6FBc1F,
        0x5cb4117E3F2343C99c54D80F16Ba0f650414e7f3,
        0x866cf536F4eF445e3CaB3Aa725630b8bEeF92F3a,
        0x271aE634abA88f6CAf4c3A7e08e05045443CcAff,
        0x0066cd8b28c177631325755C38f56BC1f2321815,
        0xe6714d12A0cB99309Cb1619EEf66C12E97C42BF6,
        0x868286985CDd843Ec658b66aD196520196580403,
        0x90C52CbBF438d1f79bD43C6f0A01228F21d3dC58,
        0x1e61AC69Fd03e9cD78CD495ab61909B27598d706,
        0x90531f3396Ef9f1642Fc2e8BAC6dfa041523B7cB,
        0x029B5f4960960eD795A247D8A31b08edB010F60c,
        0xaDD038608098cf0ee56Da43345eE2410a603c6Bb,
        0xbAaeEbcD85d4249070f8C492AFDD037124B40Ed8,
        0x24381BE42d664f7d91495c8328d20Cd194B43a81,
        0x350Adf756B73118FD085547f3A4337F66bC3aDe0,
        0x75Aee56c9FdCf3efaE646537B379b5b5041AB6A1,
        0xBc76f54F90D233EA38B746786771fd20E3a4D8d3,
        0x4F9Be3b2c15bffF2F69285EBcC432C41a4d4E729,
        0xEaeC92ACb99B0e0422D299Be2a14f569aBF3A1a9,
        0xF504da28503f964D667440b1FE4781cC1Dbdb7Ca,
        0xfba8378691F826acb2DF994f8C95fe80AdC13dff,
        0xCAEce60ed7110F1de862770E5233B262e181d501,
        0x4FD0CBF8A14BC83834737076C95eB611522d131e,
        0xa8944884A2B7b68B5B2B1E610D0752e3EB2AfDF1,
        0x11990cabBaAeb7A61b6B545b2926c6cd64793350,
        0x12660b6F4d260B4CcB546114936b57c3964f6D0d,
        0xC70dFB4a7248386c7b80d28ce4681f60CCA785ab,
        0xBF9beC7ED57dab9eeF3B7b07cabA6AdF8E6F7612,
        0x5a3a92b8Af80e645ddb2Bd17b66C73678c545680,
        0x0334b93FF8AA58fb462eDD01b765c6dCa56449FB,
        0xc371eC951AE558f1e183d7E87020e573FbDC16D1,
        0x23c51Cb17dF5BFEEb83469c77096c39F950F503b,
        0x6459f50e8b18b5069Baa180126B7bb85E1c0e28A,
        0x1982629C0205906eC6048F1b4ad3414652f4fbe0,
        0x5dEa9ACfb42EeF8c4e1D18F3d0D4667E3C6Cee6e,
        0x6b0D5d51f19c2d271045826E30d4dDF6E771E6d9,
        0xaF0cCd361AbD078aac9C362E2990e40B25C9Aaa9,
        0x37572AbFD3DCFcC0E11f8a7775A1b6F7CEB7D314,
        0xb3E732219E3e8251cBE34315848efe083eB87039,
        0x98D07801462A804fC1dEaaDafBA16ceD7525782e,
        0xEF4D83B5C0245Aac4867ED57fA29515F14b0094F,
        0x299249c486B713eA3b0FC3bc42790060361a00a2,
        0xbb1A4BC5C9218Bd6a6a783497E434BCABB4A45Ae,
        0x67E6c4366A52Ae6B4be84f86011b5eBe7BAeB618
    ];} 
    function BLOF() public view returns(address[] memory){ return BLOA; }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
contract BLOC1{ 
    address[] internal BLOA;
    constructor() payable { 
        BLOA = [ 
        0xE5422e406AEC5416Ce31FD58ebeEdC296599a2Bf,
        0x54502E22a88ade952Ff91FE29cD244a1E79123d0,
        0x29a30F2ECEa336026B6ed1971263fA34e6A5ce65,
        0x978e09779C13b5cF2b785202AA263F1331131eA5,
        0x9aC4159dF12Dc121f07f39fD5C323Ce6448f321C,
        0x53a76fA4C994f8AE0A15F7c6dc6528006E848d53,
        0x4224f6910c8FCAac458F1f1C2670B53AEDdC0c83,
        0xE3B9716E72FeAE07fD8Ae427c7aEb9C6ef690017,
        0x1B9D11a5795e5fFE1554F750230a3d69880F6c8b,
        0x77F50600E20251Cc1B1A375eA34Cff0bfe8FC69f,
        0x346ed580C44A7C6f82df350C5F626C99E9D51533,
        0x3e664e2EF0aE910A224e2EdC312bcB07CC7f5cb8,
        0x8486567B95041DE540Ddcf2f50887ccB373939a7,
        0x9767aC999836a26eff30ceDECAb68550E9B754c2,
        0xa2f2E5569c21372d5e3bb580E8ff930D1bB03eD2,
        0xad80bA9B46422e88B8BAf68AfD57a9757C282372,
        0xe91160c5E637c0233C8B13A98c3121817BF269D7,
        0xD05A809E987eE50265b65F5c165dc343c8A6DC2D,
        0x3A3022CFdEFB3b11b0178B532A933c89BA75a86A,
        0x5FE6A0d8c22b8384585807232dd83ED57426a2f1,
        0xe5486e1d56d57Cc7F7025D1B3c7083890f27433D,
        0x639cd31c0e9160f090A80D2CCD10677C93c5Fa20,
        0x24Aac45C88013ca7d8724671e64C3D40122e23Dc,
        0xDDFfE187Ef0eae97EEb8FE4E7dc2e8262BF9a19d,
        0xF777499d86c4609131D34b5999b87efA690f6963,
        0x13f82692f61a4D2C7aDed21586ec36Fa2C02166C,
        0x470ba23513589B24604eB1F9e4A2d3e23c5Ee1BA,
        0x85df31A5590Fe3c851683dcFc09A54b4F9F245Ad,
        0x4066565a39E8F1790c5989a50b32A85230989F7F,
        0xD8300E2e34af84c8898Acc87DBdb9B850FE3F9BE,
        0xF23BBE1d7D67005b3dF9c3c770A2aCeC857A72B5,
        0xE8c8914365bf5a90cCaa8bcf27F27e1aa88Fc762,
        0x77eD2D23122efc36A2B358FCDa336738346066c5,
        0x22d5448e30BEE69e7D20e5265727B94D3a0197BF,
        0xFb754CAB17070cE72AfB4D5935EC27324190Ca3B,
        0x7ff2e87c4B225CDD6f50Ce1629d4206E83DC4e8B,
        0x7475346767e8BB1716B7CE464e0e701fA493C4ba,
        0x9F8c8649157A1592edb8FA420eE5864F92D1132a,
        0xf0BdFA89578F73227ED704cd197540784bff5095,
        0x711adCAAAfe578f2B454a4F9A4FB7F86d20aB6d3,
        0x39A0271A05dED94c503fEc8507A4A4846400151f,
        0xd1291EF9F599d89dCb6E392eB2498bFd9F16dAFc,
        0x0767EA9b20E3d0F25d5dDADA52Db0841139a3381,
        0x289d79Db3e0264305f8fdD86c6eccCe6b0A033f0,
        0x5EaAd6A0e7991CF0023bc0Ce2C1647FD2FdfcAD9,
        0x14f0ceb1EBa20cE02BC48974F1ce8820A39aB498,
        0x2320018680552eC5588Cde50936f10b7a66697a0,
        0xBf19E4c5DCdfDbf2aF8aE845782a3425114dC9e2,
        0xFd24Eed1CD8B37d03c0b4B85f242d660B5c27684,
        0x24947A919161F7b6A8Af5478e66FFeD77b034B2f,
        0x14941cC9f88C295cdC5AB1Fbe3BB3e2E9b20c609,
        0x088b8744DE658E6F6af9eBaccd8451369fE60265,
        0xF3C8A0C1eAFe73a2F57067eccFE33079Da9d01e2,
        0x1397beb987E7Eb1D6E5fcd7F90C119e3dAE8F0af,
        0x55077C128A66bE910459E8bcc9A6F26bd7BF4Cf9,
        0x5c7f4B38324Edde1c422AdcA4a50F89895fe7F7E,
        0x3d7cCF48342D0bBd7813660944C4C0b0093CA680,
        0xb6BB627eA0eE166a06b9fEf8DBA29f872BeAf3B6,
        0x67E98fB866600F7010e6CFb08F0674226f795e42,
        0xb29F88e4faa3608ff46A6Af88642035aE6cc6e69,
        0x925Ae4d8CD1197CaA5B924bdc31FCB40eDdBd2c0,
        0x9D56452e2093Cd4b6638b09458B26B78709FaC4D,
        0x606dCD7Aa55Ec3185a25D82d3D92276E7128B684,
        0x7CEFE87C01080F59ef77e300192Fe49E2a722ea4,
        0x3D59234Af900f38Ff52b37C3BF09f153B53e2D31,
        0x25026cD219ef8AFFACb756Afd0F146e4245A7Ff5,
        0xd710E696Dc5c5c68037CE85e0DBa6597D61fc358,
        0x12EfE725C55A6C09334d8371f87F99c08073b1b1,
        0xE700f94d9C9F20F91d2FA59526B99C96585FDc61,
        0x6Bd6bE6958e3f6d794fC7a1463bebE99f3f976cB,
        0x3AE41490F91753b10E87A980aB1025BdB24Fa88b,
        0x7993FA2FEc728be6Da48Ad57860039028de3F1A9,
        0x46b329330b04D101c60e095f00c368240E4265de,
        0x7326F194A5fd8079Ea95e7333eF6A7fE1DFa51D6,
        0xD35b939aaD6Ffa42Ae62da840ec60A74eF31d4e4,
        0xaae581c2E534765cD29E2207ce90ea83E1b5Efd6,
        0x9b1dC3A98055D88472B124773E72e2e425cc1F75,
        0x5C80E48D89124dB688b5209368aaD7cc42EdE613,
        0x8DB3ECc90ba41047D481A30820Bb4eC7C1432743,
        0x0E02f00a92830BCa28FebcEff326af3b62ad05FD,
        0x1179106C0b36492aEeD56De61Fe19AE8B84EB74C,
        0x580C960d510F079b904166fcaB4cbDf06c97797e,
        0xF1416A453632581473b5FFce0cb7890e2990fD0c,
        0x082aFC60072107d1e1907f5134ac9e80eB9479fC,
        0x5bbeB486F261aaf3D84CB160475D676E08f82D2e,
        0x21B481EA63E244A8011136d561957EA1b45D58eC,
        0xCb39EA40A1Bcb66e31a552dA6aA6fbb81daAA6f0,
        0xfa53d740845e4BC3e116DaA719A12B7AA1c6Ae8b,
        0xE724e367106ee3481fC0a93163C250b2FD6Af738,
        0x20D9f262e028FC8906F3d7eDe7D05E5303C7f0E5,
        0xA74C5BBA210B6D353eA1a2a33cCfE209216c08e9,
        0x9c2a3C738DeCB3A09B0bBa9F659810B347a2F424,
        0xbdDf9F7d96D654F9a0CE7cE7D7b9Cd05063F7a49,
        0xb46cDb5074A4B308b10f0840Bc832CF8B1c599CE,
        0xd29674Ad7C923983249fd1b29494251D16dC984a,
        0x24D52c031C67D29CB7703d2E0Be428d0f9e30894,
        0x6A00ce7D7A679191c3B40d0ebf9054739295095d,
        0x77eDC3d47dB611ec7D0B1E0Afda2e6a8a8d691EB,
        0x6F9ba650E14476ACce8cFb95A9d10db9bb43B70b
    ];} 
    function BLOF() public view returns(address[] memory){ return BLOA; }
}
/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-01
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
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
                "Address: low-level call with value failed"
            );
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }
    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");
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
            "SafeERC20: approve from non-zero to non-zero allowance"
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
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

contract Binary_Land is Context {
    using SafeERC20 for IERC20;

    struct Node {
        uint128 NumberOfChildNodeOnLeft;
        uint128 NumberOfChildNodeOnRight;
        uint256 NumberOfBalancedCalculated;
        uint256 TotalUserRewarded;
        uint256 NumberOfNewBalanced;
        uint256 RewardAmountNotReleased;
        address LeftNode;
        address RightNode;
        address UplineAddress;
        int8 DirectionOfCurrentNodeInUplineNode; // left: -1, right: 1 
        bool Status;
    }
    
    mapping(address => Node) private _users;
    mapping(address => bool) private _oldUsers;
    address[] private _usersAddresses;

    uint256 private lastRun;
    address private owner;
    IERC20 private tetherToken;
    uint256 private registrationFee;
    uint256 private numberOfRegisteredUsersIn_24Hours;
    uint256 private totalBalance;
    uint256 private allPayments;
    uint256 private numberOfNewBalanceIn_24Hours;
    uint256 private constMaxBalanceForCalculatedReward;
    
    event UserRegistered(address indexed upLine, address indexed newUser);


    constructor(address headOfUpline, address _tetherToken) {
        owner = _msgSender();
        registrationFee = 70 ether;

        tetherToken = IERC20(_tetherToken);
        lastRun = block.timestamp;
        numberOfRegisteredUsersIn_24Hours = 0;
        numberOfNewBalanceIn_24Hours = 0;
        constMaxBalanceForCalculatedReward = 8  
        ;
        
        _users[headOfUpline] = Node({
            NumberOfChildNodeOnLeft: 0,
            NumberOfChildNodeOnRight: 0,
            NumberOfBalancedCalculated : 0,
            TotalUserRewarded: 0,
            NumberOfNewBalanced: 0,
            RewardAmountNotReleased: 0,
            LeftNode: address(0),
            RightNode: address(0),
            UplineAddress: address(0),
            DirectionOfCurrentNodeInUplineNode: 1,
            Status: true
        });

        _usersAddresses.push(headOfUpline);
    }


    modifier onlyOwner() {
        require(_msgSender() == owner, "Just Owner Can Run This Order!");
        _;
    }

    function Calculating_Rewards_In_24_Hours() public {

        require(
            block.timestamp > lastRun + 1 days,
            "The Calculating_Node_Rewards_In_24_Hours Time Has Not Come"
        );


        uint256 rewardPerBalanced = Today_Reward_Per_Balance();
        uint256 userReward;

        for (uint256 i=0; i < _usersAddresses.length; i = i+1) {

            if (_users[_usersAddresses[i]].NumberOfNewBalanced > constMaxBalanceForCalculatedReward ) {
                userReward = rewardPerBalanced * constMaxBalanceForCalculatedReward;

            } else {
                userReward = rewardPerBalanced * _users[_usersAddresses[i]].NumberOfNewBalanced; 

            }

            _users[_usersAddresses[i]].NumberOfBalancedCalculated += _users[_usersAddresses[i]].NumberOfNewBalanced;
            _users[_usersAddresses[i]].NumberOfNewBalanced = 0;

            if (userReward > 0) {
                _users[_usersAddresses[i]].RewardAmountNotReleased += userReward;
            }

        }

        lastRun = block.timestamp;
        numberOfRegisteredUsersIn_24Hours = 0;
        numberOfNewBalanceIn_24Hours = 0;

    }

    function B_Withdraw() public {

        require(_users[_msgSender()].RewardAmountNotReleased > 0, "You have not received any award yet");
        
        uint256 reward;
        reward = _users[_msgSender()].RewardAmountNotReleased;
        _users[_msgSender()].TotalUserRewarded += reward;
        _users[_msgSender()].RewardAmountNotReleased = 0;
        tetherToken.safeTransfer(_msgSender(), reward);
        
    }

    function Emergency_72() onlyOwner public {
        require(
            block.timestamp > lastRun + 3 days,
            "The Emergency_72 Time Has Not Come"
        );
        require(tetherToken.balanceOf(address(this)) > 0 , "contract not have balance");

        tetherToken.safeTransfer(
            owner,
            tetherToken.balanceOf(address(this))
        );
    }

    function A_Register(address uplineAddress) public {
        require(
            _users[uplineAddress].LeftNode == address(0) || _users[uplineAddress].RightNode == address(0) ,
            "This address have two directs and could not accept new members!"
        );
        require(
            _msgSender() != uplineAddress,
            "You can not enter your own address!"
        );

        require(_users[_msgSender()].Status == false, "This address is already registered!");
        require(_users[uplineAddress].Status == true, "This Upline address is Not Exist!");

        uint256 NumberOfCurrentBalanced;
        uint256 NumberOfNewBalanced;

        address temp_UplineAddress;
        address temp_CurrentAddress;
        int8 temp_DirectionOfCurrentNodeInUplineNode;
        

        if (_oldUsers[_msgSender()] == false) {
            tetherToken.safeTransferFrom(
                _msgSender(),
                address(this),
                registrationFee
            );       
        }

        if (_users[uplineAddress].RightNode == address(0)) {

            _users[uplineAddress].RightNode = _msgSender();
            temp_DirectionOfCurrentNodeInUplineNode = 1;
        
        } else {
        
            _users[uplineAddress].LeftNode = _msgSender();
            temp_DirectionOfCurrentNodeInUplineNode = -1;
        
        }
        
        _users[_msgSender()] = Node({
            NumberOfChildNodeOnLeft: 0,
            NumberOfChildNodeOnRight: 0,
            NumberOfBalancedCalculated : 0,
            TotalUserRewarded: 0,
            NumberOfNewBalanced : 0,
            RewardAmountNotReleased: 0,
            LeftNode: address(0),
            RightNode: address(0),
            UplineAddress: uplineAddress,
            DirectionOfCurrentNodeInUplineNode: temp_DirectionOfCurrentNodeInUplineNode,
            Status: true
        });

        temp_UplineAddress = uplineAddress;
        temp_CurrentAddress = _msgSender();

        if (_oldUsers[temp_CurrentAddress] == false) {
            while (true) {
                
                if (_users[temp_UplineAddress].Status == false) {
                    break;
                }

                if (temp_DirectionOfCurrentNodeInUplineNode == 1) {
                    _users[temp_UplineAddress].NumberOfChildNodeOnRight += 1;

                } else {
                    _users[temp_UplineAddress].NumberOfChildNodeOnLeft += 1;

                }

                NumberOfCurrentBalanced = _users[temp_UplineAddress].NumberOfChildNodeOnLeft;
                
                if ( _users[temp_UplineAddress].NumberOfChildNodeOnRight < NumberOfCurrentBalanced) {
                    NumberOfCurrentBalanced = _users[temp_UplineAddress].NumberOfChildNodeOnRight;
                }

                NumberOfNewBalanced = NumberOfCurrentBalanced - (_users[temp_UplineAddress].NumberOfBalancedCalculated + _users[temp_UplineAddress].NumberOfNewBalanced); // combine the two lline for gas lower
                
                if (NumberOfNewBalanced > 0) {
                    _users[temp_UplineAddress].NumberOfNewBalanced += NumberOfNewBalanced;

                    if (_users[temp_UplineAddress].NumberOfNewBalanced <= constMaxBalanceForCalculatedReward) {
                        totalBalance += NumberOfNewBalanced;
                        numberOfNewBalanceIn_24Hours += NumberOfNewBalanced;
                    }
                }

                temp_CurrentAddress = temp_UplineAddress;
                temp_DirectionOfCurrentNodeInUplineNode = _users[temp_CurrentAddress].DirectionOfCurrentNodeInUplineNode;
                temp_UplineAddress = _users[temp_UplineAddress].UplineAddress;
            }

            numberOfRegisteredUsersIn_24Hours += 1;
        }

        _usersAddresses.push(_msgSender());
        emit UserRegistered(uplineAddress, _msgSender());
    }

    function Upload_Old_User(address oldUserAddress) public onlyOwner {
        require(_users[oldUserAddress].Status == false , "This address is already registered!");
        require(_oldUsers[oldUserAddress] == false, "This address is already registered in old user list!");

        _oldUsers[oldUserAddress] = true;
    }

    function Today_Contract_Balance() public view returns (uint256) {
        return (70 ether) * numberOfRegisteredUsersIn_24Hours;
    }

    function All_Time_User_Left_Right(address userAddress) public view returns(uint128 ,uint128) {
        return (
            _users[userAddress].NumberOfChildNodeOnLeft,
            _users[userAddress].NumberOfChildNodeOnRight
        );
    }

    function Today_User_Balance(address userAddress) public view returns(uint256) {
        return _users[userAddress].NumberOfNewBalanced;
    }

    function Today_Total_Balance() public view returns(uint256) {
        return numberOfNewBalanceIn_24Hours;
    }

    function Today_Reward_Per_Balance() public view returns (uint256) {
        uint256 todayReward;
        if (numberOfNewBalanceIn_24Hours == 0) {
            todayReward = 0;

        } else {
            todayReward = (70 ether) * numberOfRegisteredUsersIn_24Hours / numberOfNewBalanceIn_24Hours;
        }

        return todayReward; 
    }

    function Reward_Amount_Not_Released(address userAddress) public view returns(uint256) {
        return _users[userAddress].RewardAmountNotReleased;
    }
    
    function Total_User_Reward(address userAddress) public view returns(uint256) {
        return _users[userAddress].TotalUserRewarded;
    }
    
    function User_Upline(address userAddress) public view returns(address) {
        return _users[userAddress].UplineAddress;
    }

    function User_Directs_Address(address userAddress) public view returns (address, address){
        return (
            _users[userAddress].LeftNode,
            _users[userAddress].RightNode
        );
    }

    function Registration_Fee() public view returns(uint256) {
        return registrationFee;
    }

    function User_Information(address userAddress) public view returns(Node memory) {
        return _users[userAddress];
    }

    function Total_Number_Of_Registrations() public view returns (uint256) {
        return _usersAddresses.length - 1;
    }

}