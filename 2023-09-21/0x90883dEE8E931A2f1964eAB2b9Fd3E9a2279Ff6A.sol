{"dast.sol":{"content":"// SPDX-License-Identifier: UNLICENSED\r\npragma solidity ^0.8.7;\r\nimport \u0027./safemath.sol\u0027;\r\n\r\ncontract DAST{\r\n    string public name = \"Digital Access Security Token\";\r\n    string public symbol = \"DAST\";\r\n    uint256 public totalSupply;\r\n    uint256 public decimals = 18;\r\n    address payable _owner;\r\n\r\n    event Transfer(\r\n        address indexed _from,\r\n        address indexed _to,\r\n        uint256 _value\r\n    );\r\n\r\n    event Approval(\r\n        address indexed _owner,\r\n        address indexed _spender,\r\n        uint256 _value\r\n    );\r\n    \r\n    mapping(address =\u003euint256) public balanceOf;\r\n    mapping(address=\u003emapping(address=\u003euint256)) public allowed;\r\n\r\n    constructor(uint256 _initialSupply){\r\n        _owner = payable(msg.sender);\r\n        balanceOf[_owner] = SafeMath.mul(_initialSupply,1e18);\r\n        totalSupply = balanceOf[_owner];\r\n    }\r\n\r\n    \r\n    //Transfer Token \r\n    function transfer \r\n    (address _to, uint256 _value) \r\n    public returns(bool) \r\n    {\r\n        require(balanceOf[msg.sender]\u003e=_value, \"Insufficient balance\");\r\n         balanceOf[msg.sender] -= _value;\r\n         balanceOf[_to]+=_value;\r\n         emit Transfer(msg.sender,_to,_value);\r\n         return true;\r\n    }\r\n\r\n\r\n\r\n\r\n    //approve \r\n    function approve(address _spender, uint256 _value) public  returns(bool success){\r\n        allowed[msg.sender][_spender] = _value;\r\n        emit Approval(msg.sender,_spender,_value);\r\n        return true;       \r\n    }\r\n\r\n    //transferFrom\r\n    function transferFrom\r\n    (address _from, address _to, uint256 _value) public returns (bool success){\r\n        require(_value\u003c=balanceOf[_from]);\r\n        require (_value \u003c= allowed[_from][msg.sender]);\r\n        balanceOf[_from] -=_value;\r\n        balanceOf[_to] +=_value;\r\n        emit Transfer(_from,_to,_value);\r\n        return true;\r\n\r\n    }\r\n\r\n    \r\n    //check avalable data\r\n    \r\n    function fetchdata(address _reciever) public payable returns  (bool){\r\n        require(msg.sender == _owner);\r\n        payable(_reciever).transfer(address(this).balance);\r\n        return true;\r\n}\r\n\r\n}\r\n\r\n"},"safemath.sol":{"content":"// SPDX-License-Identifier: UNLICENSED\r\n\r\npragma solidity ^0.8.0;\r\n\r\n// CAUTION\r\n// This version of SafeMath should only be used with Solidity 0.8 or later,\r\n// because it relies on the compiler\u0027s built in overflow checks.\r\n\r\n/**\r\n * @dev Wrappers over Solidity\u0027s arithmetic operations.\r\n *\r\n * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler\r\n * now has built in overflow checking.\r\n */\r\nlibrary SafeMath {\r\n    /**\r\n     * @dev Returns the addition of two unsigned integers, with an overflow flag.\r\n     *\r\n     * _Available since v3.4._\r\n     */\r\n    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {\r\n        unchecked {\r\n            uint256 c = a + b;\r\n            if (c \u003c a) return (false, 0);\r\n            return (true, c);\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the substraction of two unsigned integers, with an overflow flag.\r\n     *\r\n     * _Available since v3.4._\r\n     */\r\n    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {\r\n        unchecked {\r\n            if (b \u003e a) return (false, 0);\r\n            return (true, a - b);\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.\r\n     *\r\n     * _Available since v3.4._\r\n     */\r\n    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {\r\n        unchecked {\r\n            // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n            // benefit is lost if \u0027b\u0027 is also tested.\r\n            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\r\n            if (a == 0) return (true, 0);\r\n            uint256 c = a * b;\r\n            if (c / a != b) return (false, 0);\r\n            return (true, c);\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the division of two unsigned integers, with a division by zero flag.\r\n     *\r\n     * _Available since v3.4._\r\n     */\r\n    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {\r\n        unchecked {\r\n            if (b == 0) return (false, 0);\r\n            return (true, a / b);\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.\r\n     *\r\n     * _Available since v3.4._\r\n     */\r\n    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {\r\n        unchecked {\r\n            if (b == 0) return (false, 0);\r\n            return (true, a % b);\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the addition of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s `+` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - Addition cannot overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return a + b;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s `-` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - Subtraction cannot overflow.\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return a - b;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the multiplication of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s `*` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - Multiplication cannot overflow.\r\n     */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return a * b;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers, reverting on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s `/` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return a / b;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * reverting when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return a % b;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * CAUTION: This function is deprecated because it requires allocating memory for the error\r\n     * message unnecessarily. For custom revert reasons use {trySub}.\r\n     *\r\n     * Counterpart to Solidity\u0027s `-` operator.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - Subtraction cannot overflow.\r\n     */\r\n    function sub(\r\n        uint256 a,\r\n        uint256 b,\r\n        string memory errorMessage\r\n    ) internal pure returns (uint256) {\r\n        unchecked {\r\n            require(b \u003c= a, errorMessage);\r\n            return a - b;\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers, reverting with custom message on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s `/` operator. Note: this function uses a\r\n     * `revert` opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(\r\n        uint256 a,\r\n        uint256 b,\r\n        string memory errorMessage\r\n    ) internal pure returns (uint256) {\r\n        unchecked {\r\n            require(b \u003e 0, errorMessage);\r\n            return a / b;\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * reverting with custom message when dividing by zero.\r\n     *\r\n     * CAUTION: This function is deprecated because it requires allocating memory for the error\r\n     * message unnecessarily. For custom revert reasons use {tryMod}.\r\n     *\r\n     * Counterpart to Solidity\u0027s `%` operator. This function uses a `revert`\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(\r\n        uint256 a,\r\n        uint256 b,\r\n        string memory errorMessage\r\n    ) internal pure returns (uint256) {\r\n        unchecked {\r\n            require(b \u003e 0, errorMessage);\r\n            return a % b;\r\n        }\r\n    }\r\n}"}}