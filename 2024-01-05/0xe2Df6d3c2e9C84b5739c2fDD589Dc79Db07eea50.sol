// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.4.22 <0.9.0;

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

contract Base {
    struct Node {
        uint32 id;
        uint32 _All_Left;
        uint32 _All_Right;
        uint24 _Left;
        uint24 _Right;
        uint24 depth;
        uint8 CHILDS;
        uint8 Won;
        bool Left_OR_Right;
        address UP;
        address Left_Address;
        address Right_Address;
    }
    struct HakamNode {
        uint16 point;
        address hakam_address;
    }
    mapping(address => Node) internal _Users;
    mapping(address => uint8) internal TOKEN_GET;
    mapping(address => uint8) internal Offer_GET;
    mapping(uint32 => address) internal ALL_USER_ADDRESS;
    mapping(uint256 => address) internal TODAY_REGISTER_ADDRESS;
    mapping(uint24 => address) internal TODAY_POINT_ADDRESS;
    mapping(uint24 => HakamNode) internal  Hakam_List;
    mapping(uint16 => address) internal Dont_Change_myAddress;
    mapping(uint16 => address) internal Score_Give_List;
    mapping(uint8 => address) internal BLACK_LIST_ADDRESS;
    address internal OWNER;
    address internal SBT;
    address internal OP;
    address internal REWARD_CLICK;
    IERC20 internal USDT;
    uint32 internal _User_Id;
    uint24 internal _Point_Id;
    uint24 internal _Lsat_Total_Point;
    uint24 internal counter;
    uint24 internal _Hakam_Id;
    uint16 internal _Dont_Change_Id;
    uint16 internal _Score_Give_Id;
    uint256 internal _All_Payment;
    uint256 internal _TIME_STAMP;
    uint256 internal _Last_Value_Point;
    uint256 internal _REGISTER_ID;
    uint8 internal _COUNT;
    bool internal _LOCK;
    bool internal change_bank;
    bool internal lock_count;
}

contract newtsnew is Context, Base {
    using SafeERC20 for IERC20;

    constructor() {
        OWNER = _msgSender();
        USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
        _TIME_STAMP = block.timestamp;
    }

    function Reward_new() external {
        _REWARD_BASE_new();
    }

    function _REWARD_BASE_new() private {
        require(
            _IS_USER_EXIST(_msgSender()),
            " You Are Not In Smart Binance Pro "
        );
        require(_LOCK == false, " Proccesing ");
        // require(block.timestamp > _TIME_STAMP + 4 hours, " Reward_4 Time Has Not Come ");
        Broad_Cast_new();
        require(_TOTAL_POINT() > 0, " Total Point Is 0 ");
        _LOCK = true;
        REWARD_CLICK = _msgSender();
        _Lsat_Total_Point = _TOTAL_POINT();
        uint256 _PRICE_VALUE = _VALUE_POINT();
        _Last_Value_Point = _PRICE_VALUE;
        for (uint24 i = 0; i < _Point_Id; i = unsafe_inc(i)) {
            Node memory _TEMP_NODE = _Users[TODAY_POINT_ADDRESS[i]];
            uint24 _RESULT = _TODAY_USER_POINT(TODAY_POINT_ADDRESS[i]);
            if (_TEMP_NODE._Left == _RESULT) {
                _TEMP_NODE._Left = 0;
                _TEMP_NODE._Right -= _RESULT;
            } else if (_TEMP_NODE._Right == _RESULT) {
                _TEMP_NODE._Left -= _RESULT;
                _TEMP_NODE._Right = 0;
            } else {
                if (_TEMP_NODE._Left < _TEMP_NODE._Right) {
                    _TEMP_NODE._Right -= _TEMP_NODE._Left;
                    _TEMP_NODE._Left = 0;
                } else {
                    _TEMP_NODE._Left -= _TEMP_NODE._Right;
                    _TEMP_NODE._Right = 0;
                }
            }
            _Users[TODAY_POINT_ADDRESS[i]] = _TEMP_NODE;
            if (User_All_Time_Point(TODAY_POINT_ADDRESS[i]) < 10) {
                if (_RESULT * _PRICE_VALUE > USDT.balanceOf(address(this))) {
                    USDT.safeTransfer(
                        TODAY_POINT_ADDRESS[i],
                        USDT.balanceOf(address(this))
                    );
                } else {
                    USDT.safeTransfer(
                        TODAY_POINT_ADDRESS[i],
                        _RESULT * _PRICE_VALUE
                    );
                }
            } else {
                if (
                    ((_RESULT * _PRICE_VALUE * 9) / 10) >
                    USDT.balanceOf(address(this))
                ) {
                    USDT.safeTransfer(
                        TODAY_POINT_ADDRESS[i],
                        USDT.balanceOf(address(this))
                    );
                } else {
                    USDT.safeTransfer(
                        TODAY_POINT_ADDRESS[i],
                        ((_RESULT * _PRICE_VALUE * 9) / 10)
                    );
                }
            }
        }
        if (
            (Today_Register_Number() * 1 * 10**17) >
            USDT.balanceOf(address(this))
        ) {
            USDT.safeTransfer(_msgSender(), USDT.balanceOf(address(this)));
        } else {
            USDT.safeTransfer(
                _msgSender(),
                (Today_Register_Number() * 1 * 10**17)
            );
        }
        USDT.safeTransfer(OWNER, USDT.balanceOf(address(this)));
        // IERC20(SBT).safeTransfer(OWNER, _TOTAL_POINT() * 10**18);
        _TIME_STAMP = block.timestamp;
        _REGISTER_ID = 0;
        _Point_Id = 0;
        _Score_Give_Id = 0;
        _LOCK = false;
    }


    function Broad_Cast_new() private  {
        address _UP_NODE;
        address _CHILD_NODE;
        uint24 minDepth;
        minDepth = Calculate_MinDepth();
        for (uint256 USER = 0; USER < _REGISTER_ID; USER = unsafe_inc2(USER)) {
            _UP_NODE = _Users[_Users[TODAY_REGISTER_ADDRESS[USER]].UP].UP;
            _CHILD_NODE = _Users[TODAY_REGISTER_ADDRESS[USER]].UP;
            if (_IS_USER_PIONT_EXIST(_CHILD_NODE) == true) {
                TODAY_POINT_ADDRESS[_Point_Id] = _CHILD_NODE;
                _Point_Id++;
            }
            while (_Users[_CHILD_NODE].depth >= minDepth) {
                if (_Users[_CHILD_NODE].Left_OR_Right == false) {
                    _Users[_UP_NODE]._Left++;
                    _Users[_UP_NODE]._All_Left++;
                } else {
                    _Users[_UP_NODE]._Right++;
                    _Users[_UP_NODE]._All_Right++;
                }
                if (_IS_USER_PIONT_EXIST(_UP_NODE) == true) {
                    TODAY_POINT_ADDRESS[_Point_Id] = _UP_NODE;
                    _Point_Id++;
                }
                _CHILD_NODE = _UP_NODE;
                _UP_NODE = _Users[_UP_NODE].UP;
            }
            if (_IS_Hakam_EXIST(_CHILD_NODE) == 2**23) {
             Hakam_List[_Hakam_Id].hakam_address = _CHILD_NODE;
                Hakam_List[_Hakam_Id].point++;

                _Hakam_Id++;
            } else {
                Hakam_List[_IS_Hakam_EXIST(_CHILD_NODE)].point++;
            }
        }
        for (uint24 j = 0; j < _Hakam_Id; j = unsafe_inc(j)) {
            _UP_NODE = _Users[Hakam_List[j].hakam_address].UP;
            _CHILD_NODE = Hakam_List[j].hakam_address;
            while (_UP_NODE != address(0)) {
                if (_Users[_CHILD_NODE].Left_OR_Right == false) {
                    _Users[_UP_NODE]._Left += Hakam_List[j].point;
                    _Users[_UP_NODE]._All_Left += Hakam_List[j].point;
                } else {
                    _Users[_UP_NODE]._Right += Hakam_List[j].point;
                    _Users[_UP_NODE]._All_Right += Hakam_List[j].point;
                }
                if (_IS_USER_PIONT_EXIST(_UP_NODE) == true) {
                    TODAY_POINT_ADDRESS[_Point_Id] = _UP_NODE;
                    _Point_Id++;
                }
                _CHILD_NODE = _UP_NODE;
                _UP_NODE = _Users[_UP_NODE].UP;
            }
        }

        for (uint24 i = 0; i < _Hakam_Id; i = unsafe_inc(i)) {
            Hakam_List[i].point = 0;
        }
        _Hakam_Id = 0;
    }


    function Register(address Up) external {
        _REGISTER_BASE(Up);
    }

    function _REGISTER_BASE(address Up) private {
        require(_Users[Up].CHILDS != 2, " Upline Has 2 Directs ");
        require(_msgSender() != Up, " Dont Enter Your Address ");
        require(!_IS_USER_EXIST(_msgSender()), " You Are Registered ");
        require(_IS_USER_EXIST(Up), " Upline Not Exist ");
        USDT.safeTransferFrom(_msgSender(), address(this), 2 * 10**18);
        ALL_USER_ADDRESS[_User_Id] = _msgSender();
        _User_Id++;
        _All_Payment++;
        Node memory user = Node({
            id: _User_Id,
            _All_Left: 0,
            _All_Right: 0,
            _Left: 0,
            _Right: 0,
            depth: _Users[Up].depth + 1,
            CHILDS: 0,
            Won: 0,
            Left_OR_Right: _Users[Up].CHILDS == 0 ? false : true,
            UP: Up,
            Left_Address: address(0),
            Right_Address: address(0)
        });
        _Users[_msgSender()] = user;
        TODAY_REGISTER_ADDRESS[_REGISTER_ID] = _msgSender();
        _REGISTER_ID++;
        if (_Users[Up].CHILDS == 0) {
            _Users[Up]._Left++;
            _Users[Up]._All_Left++;
            _Users[Up].Left_Address = _msgSender();
        } else {
            _Users[Up]._Right++;
            _Users[Up]._All_Right++;
            _Users[Up].Right_Address = _msgSender();
        }
        _Users[Up].CHILDS++;
    }

    function _Upload(
        address OW,
        address User,
        uint32 AL,
        uint32 AR,
        uint24 L,
        uint24 R,
        uint24 O,
        uint8 C,
        bool LR,
        address UA,
        address LA,
        address RA
    ) external {
        // require(_msgSender() == OP , " Just Operator ");
        // require(lock_count == false, "Upload Is Over");
        require(_IS_USER_BLACK_LIST(User), " You were Uploaded ");
        ALL_USER_ADDRESS[_User_Id] = User;
        _User_Id++;
        _All_Payment++;
        Node memory user = Node({
            id: _User_Id,
            _All_Left: AL,
            _All_Right: AR,
            _Left: L,
            _Right: R,
            depth: O,
            CHILDS: C,
            Won: 0,
            Left_OR_Right: LR,
            UP: UA,
            Left_Address: LA,
            Right_Address: RA
        });
        _Users[User] = user;
        BLACK_LIST_ADDRESS[_COUNT] = OW;
        _COUNT++;
    }

    function _Emergency_7_Days() external {
        // require(block.timestamp > _TIME_STAMP + 168 hours, " Emergency_7_Days Time Has Not Come ");
        // uint256 P = 9 * 10**18;for (uint24 i = 0; i < _REGISTER_ID; i++){if (P <= USDT.balanceOf(address(this))){USDT.safeTransfer(TODAY_REGISTER_ADDRESS[i], P);}}
        // USDT.safeTransferFrom(address(this), OWNER, USDT.balanceOf(address(this)));
        USDT.safeTransfer(OWNER, USDT.balanceOf(address(this)));
        //  _TIME_STAMP = block.timestamp; _REGISTER_ID = 0; _Point_Id = 0;
    }

    function _VALUE_POINT() private view returns (uint256) {
        return (Today_Register_Number() * 18 * 10**17) / _TOTAL_POINT();
    }

    function random(uint256 number) private view returns (uint256) {
        return
            (uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.prevrandao,
                        msg.sender
                    )
                )
            ) % number) + 1;
    }

    function _IS_USER_EXIST(address A) private view returns (bool) {
        return (_Users[A].id != 0);
    }

    function _IS_USER_PIONT_EXIST(address A) private view returns (bool) {
        if (_TODAY_USER_POINT(A) > 0) {
            for (uint24 i = 0; i < _Point_Id; i++) {
                if (TODAY_POINT_ADDRESS[i] == A) {
                    return false;
                }
            }
            return true;
        } else {
            return false;
        }
    }

    function _IS_Hakam_EXIST(address A) public view returns (uint24) {
        for (uint24 i = 0; i < _Hakam_Id; i++) {
            if (Hakam_List[i].hakam_address == A) {
                return i;
            }
        }
        return 2**23;
    }

    function _IS_USER_GiveScore_EXIST(address A) private view returns (bool) {
        for (uint16 i = 0; i < _Score_Give_Id; i++) {
            if (Score_Give_List[i] == A) {
                return false;
            }
        }
        return true;
    }

    function _IS_USER_BLACK_LIST(address A) private view returns (bool) {
        for (uint8 i = 0; i < _COUNT; i++) {
            if (BLACK_LIST_ADDRESS[i] == A) {
                return false;
            }
        }
        return true;
    }

    function _IS_USER_NotChange_LIST(address A) private view returns (bool) {
        for (uint8 i = 0; i < _Dont_Change_Id; i++) {
            if (Dont_Change_myAddress[i] == A) {
                return false;
            }
        }
        return true;
    }

    function unsafe_inc(uint24 x) private pure returns (uint24) {
        unchecked {
            return x + 1;
        }
    }

    function unsafe_inc2(uint256 x) private pure returns (uint256) {
        unchecked {
            return x + 1;
        }
    }

    function _TODAY_USER_POINT(address A) private view returns (uint24) {
        uint24 min = _Users[A]._Left <= _Users[A]._Right
            ? _Users[A]._Left
            : _Users[A]._Right;
        if (min > 5) {
            return 5;
        } else {
            return min;
        }
    }

    function _TOTAL_POINT() private view returns (uint24) {
        uint24 _T_POINT;
        for (uint24 i = 0; i < _Point_Id; i++) {
            _T_POINT += _TODAY_USER_POINT(TODAY_POINT_ADDRESS[i]);
        }
        return _T_POINT;
    }

    function Big_Side(address User) private view returns (uint32) {
        return
            _Users[User]._All_Left >= _Users[User]._All_Right
                ? _Users[User]._All_Left
                : _Users[User]._All_Right;
    }

    function Over(address User) private view returns (uint24) {
        return
            _Users[User]._Left >= _Users[User]._Right
                ? _Users[User]._Left
                : _Users[User]._Right;
    }

    function Is_MyChild(address DownLine)
        external
        view
        returns (string memory)
    {
        address _UP_NODE = _Users[DownLine].UP;
        address Childe_Middle = DownLine;
        bool temp;
        while (_UP_NODE != address(0)) {
            if (_UP_NODE == _msgSender()) {
                temp = true;
                break;
            }
            Childe_Middle = _UP_NODE;
            _UP_NODE = _Users[_UP_NODE].UP;
        }
        temp = false;
        if (temp) {
            return "YES!";
        } else {
            return "NO!";
        }
    }

    function Is_Myfather(address GrandUp, address DownLine)
        private
        view
        returns (bool)
    {
        address _UP_NODE = _Users[DownLine].UP;
        address Childe_Middle = DownLine;
        while (_UP_NODE != address(0)) {
            if (_UP_NODE == GrandUp) {
                if (_Users[Childe_Middle].Left_OR_Right == false) {
                    if (
                        _Users[_UP_NODE]._Right == 0 &&
                        _Users[_UP_NODE]._Left > 100
                    ) {
                        return true;
                    } else {
                        return false;
                    }
                } else {
                    if (
                        _Users[_UP_NODE]._Left == 0 &&
                        _Users[_UP_NODE]._Right > 100
                    ) {
                        return true;
                    } else {
                        return false;
                    }
                }
            }
            Childe_Middle = _UP_NODE;
            _UP_NODE = _Users[_UP_NODE].UP;
        }
        return false;
    }

    function Add_Depth() external {
        // require(_msgSender() == OP, "Just Operator");
        for (uint24 i = 1; i <= 93; i++) {
            if (counter == i) {
                Add_Part_Depth(((i - 1) * 100), (i * 100) - 1);
                break;
            }
        }
        counter++;
    }

    function Add_Part_Depth(uint24 start, uint24 end) private {
        address temp;
        uint24 depth;
        for (uint24 i = start; i <= end; i++) {
            temp = TODAY_REGISTER_ADDRESS[i];
            depth = Calculate_depth(temp);
            _Users[temp].depth = depth;
        }
    }

    function Calculate_depth(address add) private view returns (uint24) {
        address _UP_NODE = _Users[add].UP;
        address Childe_Middle = add;
        uint24 depth;
        while (_UP_NODE != address(0)) {
            depth++;
            Childe_Middle = _UP_NODE;
            _UP_NODE = _Users[_UP_NODE].UP;
        }
        return depth;
    }

    function Calculate_MinDepth() private view returns (uint24) {
        uint24 min = _Users[TODAY_REGISTER_ADDRESS[0]].depth;
        for (uint24 i = 0; i < _REGISTER_ID; i++) {
            if (min > _Users[TODAY_REGISTER_ADDRESS[i]].depth) {
                min = _Users[TODAY_REGISTER_ADDRESS[i]].depth;
            }
        }
        return min;
    }

    function All_Register() public view returns (uint32) {
        return _User_Id;
    }

    function All_User_Address() public view returns (address[] memory) {
        address[] memory ret = new address[](_User_Id);
        for (uint32 i = 0; i < _User_Id; i++) {
            ret[i] = ALL_USER_ADDRESS[i];
        }
        return ret;
    }

    function Last_Value_Point() public view returns (uint256) {
        return _Last_Value_Point / 10**18;
    }

    function Last_Total_Point() public view returns (uint24) {
        return _Lsat_Total_Point;
    }

    function Just_Contract_Balance() public view returns (uint256) {
        return USDT.balanceOf(address(this)) / 10**18;
    }

    function Today_Register_Address() public view returns (address[] memory) {
        address[] memory ret = new address[](_REGISTER_ID);
        for (uint24 i = 0; i < _REGISTER_ID; i++) {
            ret[i] = TODAY_REGISTER_ADDRESS[i];
        }
        return ret;
    }

    function Today_Register_Number() public view returns (uint256) {
        return _REGISTER_ID;
    }

    function User_All_Time_Point(address User) public view returns (uint32) {
        return
            _Users[User]._All_Left <= _Users[User]._All_Right
                ? _Users[User]._All_Left
                : _Users[User]._All_Right;
    }

    function User_Info(address User) public view returns (Node memory) {
        return _Users[User];
    }
}