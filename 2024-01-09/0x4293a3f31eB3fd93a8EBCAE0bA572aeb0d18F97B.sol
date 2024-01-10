// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

abstract contract Ownable{
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(msg.sender);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "./interfaces/IFactory.sol";
import "./interfaces/IJsonTool.sol";
import "./interfaces/ICreate.sol";
import "./interfaces/IIns20.sol";
import "./library/Counters.sol";
import "./library/JsmnSolLib.sol";
import "./helpers/Ownable.sol";

contract InsFactory is Ownable, IFactory {
    using Counters for Counters.Counter;
    
    Counters.Counter private _inscriptionIdTracker;
    address public jsonTool;
    address public create;
    mapping(string => address) public override ins20Contracts;
    mapping(address => uint256) public override ins20TokenIndex;
    mapping(address => string[]) public holderTokens;
    mapping(address => bool) public override isOperator;
    INS20Token[] public ins20Tokens;
    mapping(string => ListTick[]) public tickLists;
    mapping(string => mapping(uint256 => uint256))  tickListsindex;
    mapping(uint256 => address) public listOwnerAddr;
    mapping(address => ListTick[]) public ownerList;
    mapping(address => mapping(uint256 => uint256)) ownerListindex;
    uint256 nonce = 0;
    event Deploy(
        address indexed tokenAddress,
        INS20Token  tokenInfo
    );
    event Mint(
        address indexed to,
        address tokenAddress,
        uint256 value
    );
    event Transfer(
        address indexed from, 
        address indexed to,
        address tokenAddress,
        uint256 value
    );
    event List(
        address indexed tokenAddress,
        address indexed seller,
        uint256 indexed liatId,
        string  tick,
        uint256 amount,
        uint256 price,
        uint256 timestamp
    );
    event UnList(
        address indexed tokenAddr,
        address indexed seller,
        uint256 indexed liatId,
        string  tick,
        uint256 amount,
        uint256 price,
        uint256 timestamp
    );
    event Buy(
        address indexed tokenAddr,
        address indexed buyer,
        uint256 indexed liatId,
        string  tick,
        address seller,
        uint256 amount,
        uint256 price,
        uint256 timestamp
    );
   event Sold(
        address indexed tokenAddr,
        address indexed seller,
        uint256 indexed liatId,
        string  tick,
        address buyer,
        uint256 amount,
        uint256 price,
        uint256 timestamp
    );

    constructor(address _jsonToolAddr) {
        isOperator[msg.sender] = true;
        isOperator[address(this)] = true;
        jsonTool = _jsonToolAddr;
        _inscriptionIdTracker.increment(); // default inscription ID 1
    }

    fallback(bytes calldata input) external payable returns (bytes memory) {
        require(msg.sender == tx.origin, "!EOA");
        require(JsmnSolLib.equals(string(input[0:6]),JsmnSolLib.INS_HEADER_HASH), "!header");
        uint256 id = _inscriptionIdTracker.current();
        _inscriptionIdTracker.increment();
        string memory content = string(input[6:bytes(input).length]);
        IJsonTool.JsonValue memory jsonVal = IJsonTool(jsonTool).parseJsonAndExecute(content);
        require(jsonVal.executeFlag, "!json execute failed");
        if (JsmnSolLib.equals(jsonVal.op,JsmnSolLib.INS20_OP_HASH_DEPLOY)) {
            require(ins20Contracts[jsonVal.tick] == address(0),"!deploy");
            createINS20(jsonVal.tick, jsonVal.max, jsonVal.lim, jsonVal.fee, id);
            emit Deploy(ins20Contracts[jsonVal.tick],ins20Tokens[ins20TokenIndex[ins20Contracts[jsonVal.tick]]]);
        } else if (JsmnSolLib.equals(jsonVal.op,JsmnSolLib.INS20_OP_HASH_MINT)) {
            address tokenAddr = ins20Contracts[jsonVal.tick];
            require(tokenAddr != address(0), "!mint");
            bool ret = IIns20(tokenAddr).mint{value:msg.value}(msg.sender, jsonVal.amt);
            if (ret) {
                addHoldTick(msg.sender,jsonVal.tick);
                emit Mint(msg.sender,ins20Contracts[jsonVal.tick],jsonVal.amt);
            } else {
                emit Mint(msg.sender,ins20Contracts[jsonVal.tick],0);
            }
        } else if (JsmnSolLib.equals(jsonVal.op,JsmnSolLib.INS20_OP_HASH_TRANSFER)) {
            address tokenAddr = ins20Contracts[jsonVal.tick];
            IIns20(tokenAddr).transferFrom(msg.sender, jsonVal.receiver,jsonVal.amt);
            addHoldTick(jsonVal.receiver,jsonVal.tick);
            if(balanceOfTick(jsonVal.tick,msg.sender)==0){
                removeHoldTick(msg.sender,jsonVal.tick);
            }
            emit Transfer(msg.sender,jsonVal.receiver,ins20Contracts[jsonVal.tick],jsonVal.amt);
        } else if (JsmnSolLib.equals(jsonVal.op,JsmnSolLib.INS20_OP_HASH_LIST)) {
            require(ins20Contracts[jsonVal.tick] != address(0),"!list");
            uint256 listId = creatNewList(jsonVal.tick,jsonVal.amt,jsonVal.price);
            emit List(ins20Contracts[jsonVal.tick],msg.sender,listId,jsonVal.tick,jsonVal.amt,jsonVal.price,block.timestamp);
        } else if (JsmnSolLib.equals(jsonVal.op,JsmnSolLib.INS20_OP_HASH_UNLIST)) {
            require(ins20Contracts[jsonVal.tick] != address(0) 
                && listOwnerAddr[jsonVal.listid] == msg.sender,"!unlist");
            removeList(jsonVal.tick,msg.sender,jsonVal.listid);
        } else if (JsmnSolLib.equals(jsonVal.op,JsmnSolLib.INS20_OP_HASH_BUY)) {
            require(ins20Contracts[jsonVal.tick] != address(0) 
                && listOwnerAddr[jsonVal.listid] != address(0),"!buy");
            buyToken(jsonVal.tick,listOwnerAddr[jsonVal.listid],jsonVal.listid);
            removeList(jsonVal.tick,listOwnerAddr[jsonVal.listid],jsonVal.listid);
            emit Transfer(listOwnerAddr[jsonVal.listid],msg.sender,ins20Contracts[jsonVal.tick],jsonVal.amt);
        } else {
            revert();
        }
        return abi.encode(0);
    }

    function createINS20(
        string memory tick,
        uint256 maxSupply,
        uint256 amountPerMint,
        uint256 fee,
        uint256 scriptionId
    ) internal {
        require(ins20Contracts[tick] == address(0), "deployed");
        address token = ICreate(create).createINS20(maxSupply, amountPerMint, fee, msg.sender, tick);
        ins20Contracts[tick] = address(token);
        INS20Token memory tokenInfo = INS20Token(
            address(token),
            tick,
            maxSupply,
            amountPerMint,
            fee,
            scriptionId,
            msg.sender,
            block.timestamp
        );
        ins20Tokens.push(tokenInfo);
        ins20TokenIndex[address(token)] = ins20Tokens.length-1;
    }

    receive() external payable {}

    //// management ////
    function withdraw() external onlyOwner {
        require(address(this).balance > 0, "no balance");
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }

    function setOperator(address operator, bool _isOperator) external onlyOwner {
        isOperator[operator] = _isOperator;
    }

    function setCreate(address _create) external onlyOwner {
        create = _create;
    }

    function getTokenCount() public view override returns (uint256) {
        return ins20Tokens.length;
    }

    function ins20TokensOf(uint256 index) public view override returns(INS20Token memory) {
        return ins20Tokens[index];
    }

    function getTickListsCount(string memory tick) external view override returns(uint256) {
        return tickLists[tick].length;
    }

    function tickListOf(string memory tick, uint256 index) external view override returns(ListTick memory) {
        return tickLists[tick][index];
    }

    function getOwnerListCount(address account) external view override returns(uint256) {
        return ownerList[account].length;
    }

    function ownerListOf(address account, uint256 index) external view override returns(ListTick memory) {
        return ownerList[account][index];
    }

    function checkHoldTick(address holder,string memory tick) public view returns (bool) {
        for (uint256 i = 0; i < holderTokens[holder].length; i++) {
            if (JsmnSolLib.equals(holderTokens[holder][i],tick)) {return true;}
        }
        // if we reach here, then the key doesn't exist
        return false;
    }

    function addHoldTick(address holder,string memory tick) internal returns (bool) {
        if (!checkHoldTick(holder,tick)) {
            holderTokens[holder].push(tick);
        }
        return true;
    }

    function removeHoldTick(address holder,string memory tick) internal returns (bool) {
        if (!checkHoldTick(holder,tick)) {return false;}
        // create a new keyArray array, remove key from it, and set it as the new keyArray array
        string[] memory newkeyArray = new string[](holderTokens[holder].length - 1);
        uint256 j = 0;
        for (uint256 i = 0; i < holderTokens[holder].length; i++) {
        if (!JsmnSolLib.equals(holderTokens[holder][i],tick)) {
            newkeyArray[j] = holderTokens[holder][i];
            j++;
        }
        }
        // set the new keyArray array
        holderTokens[holder] = newkeyArray;
        return true;
    }

    function balanceOfTick(string memory tick,address account) public view returns(uint256 holdbalance) {
        address tokenAddr = ins20Contracts[tick];
        if (tokenAddr != address(0)) {
            holdbalance = IIns20(tokenAddr).balanceOf(account);
        }
    }

    function creatNewList(string memory tick,uint256 amt,uint256 price) internal returns (uint256) {
        require(listamontcheck(tick,amt), "Insufficient balance!");
        uint256 listId = listidCrate(amt,price);
        ListTick memory listInfo = ListTick(
            tick,
            listId,
            msg.sender,
            amt,
            price,
            price/amt,
            block.timestamp
        );
        tickLists[tick].push(listInfo);
        tickListsindex[tick][listId]=tickLists[tick].length-1;

        ownerList[msg.sender].push(listInfo);
        ownerListindex[msg.sender][listId]=ownerList[msg.sender].length-1;

        listOwnerAddr[listId] = msg.sender;
        return listId;
    }

    function removeList(string memory tick,address listowner,uint256 listId) internal returns (bool) {
        //allist
        uint256 index = tickListsindex[tick][listId];
        ListTick memory deletListInfo =tickLists[tick][index];
        uint256 movedListId = tickLists[tick][tickLists[tick].length-1].listId;
        tickLists[tick][index] = tickLists[tick][tickLists[tick].length-1];
        tickLists[tick].pop();
        delete tickListsindex[tick][listId];
        tickListsindex[tick][movedListId]=index;

        //userlist
        uint256 userIndex = ownerListindex[listowner][listId];
        uint256 usermovedListId = ownerList[listowner][ownerList[listowner].length-1].listId;
        ownerList[listowner][userIndex] = ownerList[listowner][ownerList[listowner].length-1];
        ownerList[listowner].pop();
        delete ownerListindex[listowner][usermovedListId];
        ownerListindex[listowner][usermovedListId]=userIndex;
        address ownaddr = listOwnerAddr[listId];
        delete listOwnerAddr[listId];
        if(listowner == ownaddr){
            emit UnList(ins20Contracts[tick],msg.sender,listId,tick,deletListInfo.amt,deletListInfo.price,block.timestamp);
        }else{
            emit Sold(ins20Contracts[tick],listowner,listId,tick,msg.sender,deletListInfo.amt,deletListInfo.price,block.timestamp);
        }
        return true;
    }

    function buyToken(string memory tick,address listowner,uint256 listId) internal returns (bool) {
        ListTick memory listInfo = tickLists[tick][tickListsindex[tick][listId]];
        require(listInfo.price == msg.value, "!Insufficient payvalue");
        IIns20(ins20Contracts[tick]).transferFrom(listowner, msg.sender,listInfo.amt);
        payable(listowner).transfer(msg.value * 995 / 1000);
        return true;
    }

    function listamontcheck(string memory tick,uint256 amt) internal view returns (bool) {
        uint256 listAmut = 0;
        for (uint256 i = 0; i < ownerList[msg.sender].length; i++) {
            if (!JsmnSolLib.equals(ownerList[msg.sender][i].tick,tick)) {
                listAmut=listAmut+ownerList[msg.sender][i].amt;
            }
        }
        return balanceOfTick(tick,msg.sender)>=listAmut+amt;
    }
    
    function listidCrate(uint256 amt,uint256 price) internal returns(uint256) {
        nonce += 1;
        return uint256(keccak256(abi.encodePacked(amt,price,nonce, msg.sender, block.number)));
    }

}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

interface ICreate {
    function createINS20(
        uint256 maxSupply,
        uint256 amountPerMint,
        uint256 fee,
        address deployer,
        string memory tick
    ) external returns(address);
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

interface IFactory {
    struct INS20Token {
        address tokenAddress;
        string tick;
        uint256 maxSupply;
        uint256 amountPerMint;
        uint256 fee;
        uint256 deployId;
        address deployer;
        uint256 timestamp;
    }

    struct ListTick {
        string tick;
        uint256 listId;
        address listOwner;
        uint256 amt;
        uint256 price;
        uint256 perPrice;
        uint256 timestamp;
    }

    function isOperator(address) external view returns (bool);
    function getTokenCount() external view returns (uint256);
    function ins20TokensOf(uint256 index) external view returns(INS20Token memory);
    function ins20Contracts(string memory) external view returns(address);
    function ins20TokenIndex(address) external view returns(uint256);
    function getTickListsCount(string memory tick) external view returns(uint256);
    function tickListOf(string memory tick, uint256 index) external view returns(ListTick memory);
    function getOwnerListCount(address account) external view returns(uint256);
    function ownerListOf(address account, uint256 index) external view returns(ListTick memory);
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IIns20 {
    function mint(address to, uint256 amount) external payable returns(bool);
    function name() external view returns(string memory);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

interface IJsonTool {
    struct JsonValue {
        bool executeFlag;
        string p;
        string op;
        string tick;
        uint256 max;
        uint256 lim;
        uint256 amt;
        uint256 fee;
        address receiver;
        uint256 price;
        uint256 listid;
    }
    function parseJsonAndExecute(string calldata content) external pure returns (JsonValue memory);
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

library JsmnSolLib {

    enum JsmnType { UNDEFINED, OBJECT, ARRAY, STRING, PRIMITIVE }

    uint constant RETURN_SUCCESS = 0;
    uint constant RETURN_ERROR_INVALID_JSON = 1;
    uint constant RETURN_ERROR_PART = 2;
    uint constant RETURN_ERROR_NO_MEM = 3;

    string constant INS_HEADER_HASH = "data:,";
    uint256 constant INS20_MAX_JSON_TOKEN = 12;
    string constant INS20_P_HASH = "p";
    string constant INS20_OP_HASH = "op";
    string constant INS20_P_HASH_INS20 = "ins20";
    string constant INS20_OP_HASH_DEPLOY = "deploy";
    string constant INS20_OP_HASH_MINT = "mint";
    string constant INS20_OP_HASH_TRANSFER = "transfer";
    string constant INS20_OP_HASH_LIST = "list";
    string constant INS20_OP_HASH_UNLIST = "unlist";
    string constant INS20_OP_HASH_BUY = "buy";
    string constant INS20_TICK_HASH = "tick";
    string constant INS20_MAX_HASH = "max";
    string constant INS20_LIM_HASH = "lim";
    string constant INS20_AMT_HASH = "amt";
    string constant INS20_MINT_FEE = "fee";
    string constant INS20_PRICE_HASH = "price";
    string constant INS20_LISTID_HASH = "listid";
    string constant INS20_RECEIVER_HASH = "receiver";

    struct Token {
        JsmnType jsmnType;
        uint start;
        bool startSet;
        uint end;
        bool endSet;
        uint8 size;
    }

    struct Parser {
        uint pos;
        uint toknext;
        int toksuper;
    }

    function init(uint length) internal pure returns (Parser memory, Token[] memory) {
        Parser memory p = Parser(0, 0, -1);
        Token[] memory t = new Token[](length);
        return (p, t);
    }

    function allocateToken(Parser memory parser, Token[] memory tokens) internal pure returns (bool, Token memory) {
        if (parser.toknext >= tokens.length) {
            // no more space in tokens
            return (false, tokens[tokens.length-1]);
        }
        Token memory token = Token(JsmnType.UNDEFINED, 0, false, 0, false, 0);
        tokens[parser.toknext] = token;
        parser.toknext++;
        return (true, token);
    }

    function fillToken(Token memory token, JsmnType jsmnType, uint start, uint end) internal pure {
        token.jsmnType = jsmnType;
        token.start = start;
        token.startSet = true;
        token.end = end;
        token.endSet = true;
        token.size = 0;
    }

    function parseString(Parser memory parser, Token[] memory tokens, bytes memory s) internal pure returns (uint) {
        uint start = parser.pos;
        bool success;
        Token memory token;
        parser.pos++;

        for (; parser.pos<s.length; parser.pos++) {
            bytes1 c = s[parser.pos];

            // Quote -> end of string
            if (c == '"') {
                (success, token) = allocateToken(parser, tokens);
                if (!success) {
                    parser.pos = start;
                    return RETURN_ERROR_NO_MEM;
                }
                fillToken(token, JsmnType.STRING, start+1, parser.pos);
                return RETURN_SUCCESS;
            }

            if (uint8(c) == 92 && parser.pos + 1 < s.length) {
                // handle escaped characters: skip over it
                parser.pos++;
                if (s[parser.pos] == '\"' || s[parser.pos] == '/' || s[parser.pos] == '\\'
                    || s[parser.pos] == 'f' || s[parser.pos] == 'r' || s[parser.pos] == 'n'
                    || s[parser.pos] == 'b' || s[parser.pos] == 't') {
                        continue;
                        } else {
                            // all other values are INVALID
                            parser.pos = start;
                            return(RETURN_ERROR_INVALID_JSON);
                        }
                    }
            }
        parser.pos = start;
        return RETURN_ERROR_PART;
    }

    function parsePrimitive(Parser memory parser, Token[] memory tokens, bytes memory s) internal pure returns (uint) {
        bool found = false;
        uint start = parser.pos;
        bytes1 c;
        bool success;
        Token memory token;
        for (; parser.pos < s.length; parser.pos++) {
            c = s[parser.pos];
            if (c == ' ' || c == '\t' || c == '\n' || c == '\r' || c == ','
                || c == 0x7d || c == 0x5d) {
                    found = true;
                    break;
            }
            if (uint8(c) < 32 || uint8(c) > 127) {
                parser.pos = start;
                return RETURN_ERROR_INVALID_JSON;
            }
        }
        if (!found) {
            parser.pos = start;
            return RETURN_ERROR_PART;
        }

        // found the end
        (success, token) = allocateToken(parser, tokens);
        if (!success) {
            parser.pos = start;
            return RETURN_ERROR_NO_MEM;
        }
        fillToken(token, JsmnType.PRIMITIVE, start, parser.pos);
        parser.pos--;
        return RETURN_SUCCESS;
    }

    function parse(string memory json, uint numberElements) internal pure returns (uint, Token[] memory tokens, uint) {
        bytes memory s = bytes(json);
        bool success;
        Parser memory parser;
        (parser, tokens) = init(numberElements);

        // Token memory token;
        uint r;
        uint count = parser.toknext;
        uint i;
        Token memory token;

        for (; parser.pos<s.length; parser.pos++) {
            bytes1 c = s[parser.pos];

            // 0x7b, 0x5b opening curly parentheses or brackets
            if (c == 0x7b || c == 0x5b) {
                count++;
                (success, token) = allocateToken(parser, tokens);
                if (!success) {
                    return (RETURN_ERROR_NO_MEM, tokens, 0);
                }
                if (parser.toksuper != -1) {
                    tokens[uint(parser.toksuper)].size++;
                }
                token.jsmnType = (c == 0x7b ? JsmnType.OBJECT : JsmnType.ARRAY);
                token.start = parser.pos;
                token.startSet = true;
                parser.toksuper = int(parser.toknext - 1);
                continue;
            }

            // closing curly parentheses or brackets
            if (c == 0x7d || c == 0x5d) {
                JsmnType tokenType = (c == 0x7d ? JsmnType.OBJECT : JsmnType.ARRAY);
                bool isUpdated = false;
                for (i=parser.toknext-1; i>=0; i--) {
                    token = tokens[i];
                    if (token.startSet && !token.endSet) {
                        if (token.jsmnType != tokenType) {
                            // found a token that hasn't been closed but from a different type
                            return (RETURN_ERROR_INVALID_JSON, tokens, 0);
                        }
                        parser.toksuper = -1;
                        tokens[i].end = parser.pos + 1;
                        tokens[i].endSet = true;
                        isUpdated = true;
                        break;
                    }
                }
                if (!isUpdated) {
                    return (RETURN_ERROR_INVALID_JSON, tokens, 0);
                }
                for (; i>0; i--) {
                    token = tokens[i];
                    if (token.startSet && !token.endSet) {
                        parser.toksuper = int(i);
                        break;
                    }
                }

                if (i==0) {
                    token = tokens[i];
                    if (token.startSet && !token.endSet) {
                        parser.toksuper = int128(uint128(i));
                    }
                }
                continue;
            }

            // 0x42
            if (c == '"') {
                r = parseString(parser, tokens, s);

                if (r != RETURN_SUCCESS) {
                    return (r, tokens, 0);
                }
                //JsmnError.INVALID;
                count++;
				if (parser.toksuper != -1)
					tokens[uint(parser.toksuper)].size++;
                continue;
            }

            // ' ', \r, \t, \n
            if (c == ' ' || c == 0x11 || c == 0x12 || c == 0x14) {
                continue;
            }

            // 0x3a
            if (c == ':') {
                parser.toksuper = int(parser.toknext -1);
                continue;
            }

            if (c == ',') {
                if (parser.toksuper != -1
                    && tokens[uint(parser.toksuper)].jsmnType != JsmnType.ARRAY
                    && tokens[uint(parser.toksuper)].jsmnType != JsmnType.OBJECT) {
                        for(i = parser.toknext-1; i>=0; i--) {
                            if (tokens[i].jsmnType == JsmnType.ARRAY || tokens[i].jsmnType == JsmnType.OBJECT) {
                                if (tokens[i].startSet && !tokens[i].endSet) {
                                    parser.toksuper = int(i);
                                    break;
                                }
                            }
                        }
                    }
                continue;
            }

            // Primitive
            if ((c >= '0' && c <= '9') || c == '-' || c == 'f' || c == 't' || c == 'n') {
                if (parser.toksuper != -1) {
                    token = tokens[uint(parser.toksuper)];
                    if (token.jsmnType == JsmnType.OBJECT
                        || (token.jsmnType == JsmnType.STRING && token.size != 0)) {
                            return (RETURN_ERROR_INVALID_JSON, tokens, 0);
                        }
                }

                r = parsePrimitive(parser, tokens, s);
                if (r != RETURN_SUCCESS) {
                    return (r, tokens, 0);
                }
                count++;
                if (parser.toksuper != -1) {
                    tokens[uint(parser.toksuper)].size++;
                }
                continue;
            }

            // printable char
            if (c >= 0x20 && c <= 0x7e) {
                return (RETURN_ERROR_INVALID_JSON, tokens, 0);
            }
        }

        return (RETURN_SUCCESS, tokens, parser.toknext);
    }

    function getBytes(string memory json, uint start, uint end) internal pure returns (string memory) {
        bytes memory s = bytes(json);
        bytes memory result = new bytes(end-start);
        for (uint i=start; i<end; i++) {
            result[i-start] = s[i];
        }
        return string(result);
    }

    // parseInt
    function parseInt(string memory _a) internal pure returns (int) {
        return parseInt(_a, 0);
    }

    // parseInt(parseFloat*10^_b)
    function parseInt(string memory _a, uint _b) internal pure returns (int) {
        bytes memory bresult = bytes(_a);
        int mint = 0;
        bool decimals = false;
        bool negative = false;
        for (uint i=0; i<bresult.length; i++){
            if ((i == 0) && (bresult[i] == '-')) {
                negative = true;
            }
            if ((uint8(bresult[i]) >= 48) && (uint8(bresult[i]) <= 57)) {
                if (decimals){
                   if (_b == 0) break;
                    else _b--;
                }
                mint *= 10;
                mint += int256(uint256(uint8(bresult[i]) - 48));
            } else if (uint8(bresult[i]) == 46) decimals = true;
        }
        if (_b > 0) mint *= int(10**_b);
        if (negative) mint *= -1;
        return mint;
    }

    function uint2str(uint i) internal pure returns (string memory){
        if (i == 0) return "0";
        uint j = i;
        uint len;
        while (j != 0){
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (i != 0){
            bstr[k--] = bytes1(uint8(48 + i % 10));
            i /= 10;
        }
        return string(bstr);
    }

    function parseBool(string memory _a) internal pure returns (bool) {
        if (strCompare(_a, 'true') == 0) {
            return true;
        } else {
            return false;
        }
    }

    function strCompare(string memory _a, string memory _b) internal pure returns (int) {
        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
        uint minLength = a.length;
        if (b.length < minLength) minLength = b.length;
        for (uint i = 0; i < minLength; i ++)
            if (a[i] < b[i])
                return -1;
            else if (a[i] > b[i])
                return 1;
        if (a.length < b.length)
            return -1;
        else if (a.length > b.length)
            return 1;
        else
            return 0;
    }

    /**
    * Compare two strings and return true if they are equal
    * @param _a string a
    * @param _b string b
    */
    function equals(string memory _a, string memory _b) internal pure returns (bool){
        return keccak256(bytes(_a)) == keccak256(bytes(_b));
    }


    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT license
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toUint(string memory s) internal pure returns (uint) {
        bytes memory b = bytes(s);
        uint result = 0;
        for (uint256 i = 0; i < b.length; i++) {
            uint256 c = uint256(uint8(b[i]));
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
        return result;
    }

    function isDigit(string memory s) internal pure returns (bool) {
        bytes memory b = bytes(s);
        for (uint i = 0; i < b.length; i++) {
            uint256 c = uint256(uint8(b[i]));
            if (c < 48 || c > 57) {
                return false;
            }
        }
        return true;
    }

    function isAddr(string memory s) internal pure returns (bool) {
        bytes memory b = bytes(s);
        if (b.length >= 1 + 20 && b[0] == '0' && (b[1] == 'x' || b[1] == 'X')) {
            return true;
        }
        return true;
    }

    function toAddress(string memory s) internal pure returns (address) {
        bytes memory _bytes = hexStringToAddress(s);
        address tempAddress;
        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), 1)), 0x1000000000000000000000000)
        }
        return tempAddress;
    }

    function hexStringToAddress(string memory s) internal pure returns (bytes memory) {
        bytes memory ss = bytes(s);
        bytes memory r = new bytes(ss.length/2);
        for (uint i=0; i<ss.length/2; ++i) {
            r[i] = bytes1(fromHexChar(uint8(ss[2*i])) * 16 +
                        fromHexChar(uint8(ss[2*i+1])));
        }

        return r;

    }

    function fromHexChar(uint8 c) internal pure returns (uint8) {
        if (bytes1(c) >= bytes1('0') && bytes1(c) <= bytes1('9')) {
            return c - uint8(bytes1('0'));
        }
        if (bytes1(c) >= bytes1('a') && bytes1(c) <= bytes1('f')) {
            return 10 + c - uint8(bytes1('a'));
        }
        if (bytes1(c) >= bytes1('A') && bytes1(c) <= bytes1('F')) {
            return 10 + c - uint8(bytes1('A'));
        }
        return 0;
    }
}