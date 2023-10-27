// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
interface IAccessControl {
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);
    function hasRole(bytes32 role, address account) external view returns (bool);
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
    function renounceRole(bytes32 role, address account) external;
}
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;
    function toString(uint256 value) internal pure returns (string memory) {
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
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }
    mapping(bytes32 => RoleData) private _roles;
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor() {
        _status = _NOT_ENTERED;
    }
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}
interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool _approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
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
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;
    string private _name;
    string private _symbol;
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not token owner nor approved for all"
        );
        _approve(to, tokenId);
    }
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);

        return _tokenApprovals[tokenId];
    }
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");

        _transfer(from, to, tokenId);
    }
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");
        _safeTransfer(from, to, tokenId, data);
    }
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");
        _beforeTokenTransfer(address(0), to, tokenId);
        _balances[to] += 1;
        _owners[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
        _afterTokenTransfer(address(0), to, tokenId);
    }
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);
        _beforeTokenTransfer(owner, address(0), tokenId);
        _approve(address(0), tokenId);
        _balances[owner] -= 1;
        delete _owners[tokenId];
        emit Transfer(owner, address(0), tokenId);
        _afterTokenTransfer(owner, address(0), tokenId);
    }
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");
        _beforeTokenTransfer(from, to, tokenId);
        _approve(address(0), tokenId);
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;
        emit Transfer(from, to, tokenId);
        _afterTokenTransfer(from, to, tokenId);
    }
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}
interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
    function tokenByIndex(uint256 index) external view returns (uint256);
}
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;
    mapping(uint256 => uint256) private _ownedTokensIndex;
    uint256[] private _allTokens;
    mapping(uint256 => uint256) private _allTokensIndex;
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);
        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];
            _ownedTokens[from][tokenIndex] = lastTokenId;
            _ownedTokensIndex[lastTokenId] = tokenIndex;
        }
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];
        uint256 lastTokenId = _allTokens[lastTokenIndex];
        _allTokens[tokenIndex] = lastTokenId;
        _allTokensIndex[lastTokenId] = tokenIndex;
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}
contract MetagaugeNFT is ERC721Enumerable, Ownable, AccessControl, ReentrancyGuard {
    using Strings for uint256;
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    uint256 private minPrice;
    uint256 private RODTransferFee;
    uint256 private BNBTransferFee;
    address private MGRCA;
    address private RODCA;
    mapping(uint256 => string) private _tokenURIs;
    mapping(string => AdminSale) private adminSales;
    mapping(uint256 => Sale) private sales;
    constructor() ERC721("Metagauge NFT", "MGN") {
        _transferOwnership(_msgSender());
        setAdminRole(_msgSender());
        minPrice = 10 ** 15;
        RODTransferFee = 500;
        BNBTransferFee = 250;
        adminSales["PB"] = AdminSale(false, new address[](0), new address[](0), 0, 0, 0);
        adminSales["OG"] = AdminSale(false, new address[](0), new address[](0), 0, 0, 0);
        adminSales["WL"] = AdminSale(false, new address[](0), new address[](0), 0, 0, 0);
        adminSales["AD"] = AdminSale(false, new address[](0), new address[](0), 0, 0, 0);
    }
    struct AdminSale {
        bool status;
        address[] members;
        address[] buyers;
        uint256 price;
        uint256 amountPerMember;
        uint256 totalAmount;
    }
    struct Sale {
        bool status;
        bool isAuction;
        address manager;
        string unit;
        uint256 price;
        uint256 minBidAmount;
        address topBidder;
        uint256 topBidAmount;
        
    }
    event SaleTransferred(string unit, uint256 price, address topBidder, uint256 topBidAmount);
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Enumerable, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);
        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        return super.tokenURI(tokenId);
    }
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
    receive() external payable {}
    fallback() external payable {}
    function setAdminRole(address to) public onlyOwner {
        _grantRole(ADMIN_ROLE, to);
    }
    function revokeAdminRole(address to) public onlyOwner {
        _revokeRole(ADMIN_ROLE, to);
    }
    function setCA(
        address _MGRCA,
        address _RODCA
    ) public onlyOwner {
        if (MGRCA != _MGRCA) {
            revokeAdminRole(MGRCA);
            setAdminRole(_MGRCA);
            MGRCA = _MGRCA;
        }
        if (RODCA != _RODCA) {
            revokeAdminRole(RODCA);
            setAdminRole(_RODCA);
            RODCA = _RODCA;
        }
    }
    function getCA() public view returns (address, address) {
        return (MGRCA, RODCA);
    }
    function setOptions(
        uint256 _minPrice,
        uint256 _RODTransferFee,
        uint256 _BNBTransferFee
    ) public onlyOwner {
        minPrice = _minPrice;
        RODTransferFee = _RODTransferFee;
        BNBTransferFee = _BNBTransferFee;
    }
    function getOptions() public view returns (uint256, uint256, uint256) {
        return (minPrice, RODTransferFee, BNBTransferFee);
    }
    function setAdminSale(
        string memory saleType,
        uint256 status,
        uint256 price,
        uint256 totalAmount
    ) public onlyOwner {
        require(status < 2, "invalid status value");
        if (keccak256(abi.encode(saleType)) != keccak256(abi.encode("AD"))) {
            require(price >= minPrice, "price must bigger than minimum price");
        }
        bool adminSaleStatus = false;
        if (status == 1) {
            adminSaleStatus = true;
        }
        adminSales[saleType].status = adminSaleStatus;
        adminSales[saleType].price = price;
        adminSales[saleType].totalAmount = totalAmount;
    }
    function setAdminSaleForMembers(
        string memory saleType,
        uint256 status,
        address[] memory members,
        uint256 price,
        uint256 amountPerMember,
        uint256 totalAmount
    ) public onlyOwner {
        require(status < 2, "invalid status value");
        if (keccak256(abi.encode(saleType)) != keccak256(abi.encode("AD"))) {
            require(price >= minPrice, "price must bigger than minimum price");
        }
        bool adminSaleStatus = false;
        if (status == 1) {
            adminSaleStatus = true;
        }
        adminSales[saleType].status = adminSaleStatus;
        adminSales[saleType].members = members;
        adminSales[saleType].price = price;
        adminSales[saleType].amountPerMember = amountPerMember;
        adminSales[saleType].totalAmount = totalAmount;
    }
    function initializeAdminSale(
        string memory saleType
    ) public onlyOwner {
        adminSales[saleType] = AdminSale(false, new address[](0), new address[](0), 0, 0, 0);
    }
    function getAdminSale(string memory key) public view returns (AdminSale memory) {
        return adminSales[key];
    }
    function _mint(
        address to,
        uint256 tokenId,
        string memory uri
    ) internal virtual {
        super._mint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        require(!sales[tokenId].status, "cannot transfer token during sell on market");
        super._transfer(from, to, tokenId);
    }
    function mintByAdmin(
        address to,
        uint256 tokenId,
        string memory uri
    ) public onlyRole(ADMIN_ROLE) {
        _mint(to, tokenId, uri);
    }
    function transferByAdmin(
        address holder,
        address to,
        uint256 tokenId
    ) public onlyRole(ADMIN_ROLE) {
        _transfer(holder, to, tokenId);
    }
    function mintWithRODByAdmin(
        address to,
        uint256 rod,
        uint256 tokenId,
        string memory uri
    ) public onlyRole(ADMIN_ROLE) {
        address sender = _msgSender();
        (bool success,) = address(RODCA).call(abi.encodeWithSignature("transferByAdmin(address,address,uint256)", to, sender, rod));
        require(success, "failed to call transferByAdmin() in ROD contract");
        mintByAdmin(to, tokenId, uri);
    }
    function transferWithRODByAdmin(
        uint256 tokenId,
        address holder,
        address buyer,
        uint256 rod
    ) public onlyRole(ADMIN_ROLE) {
        (bool success,) = address(RODCA).call(abi.encodeWithSignature("transferByAdmin(address,address,uint256)", buyer, holder, rod));
        require(success, "failed to call transferByAdmin() in ROD contract");
        transferByAdmin(holder, buyer, tokenId);
    }
    function airdropByAdmin(
        address to,
        uint256 tokenId,
        string memory uri
    ) public onlyRole(ADMIN_ROLE) {
        AdminSale memory adminSale = getAdminSale("AD");
        require(adminSale.status, "admin airdrop closed");
        require(adminSale.totalAmount > 0, "amount sold out");
        require(!_exists(tokenId), "token id already exists");
        _mint(to, tokenId, uri);
        adminSales["AD"].totalAmount = adminSale.totalAmount - 1;
    }
    function buyAdminSale(
        string memory saleType,
        uint256 tokenId,
        string memory uri
    ) public payable nonReentrant {
        AdminSale memory adminSale = getAdminSale(saleType);
        uint256 bnb = msg.value;
        address buyer = _msgSender();
        require(buyer.balance >= bnb, "not enough BNB");
        require(adminSale.status, "not on sale");
        require(bnb == adminSale.price, "incorrect BNB value for sale");
        require(adminSale.totalAmount > 0, "sold out");
        require(!_exists(tokenId), "token id already exists");
        require(adminSale.members.length == 0, "sale not for public");
        (bool sendToOwner,) = payable(owner()).call{value: bnb}("");
        require(sendToOwner, "failed to send BNB for owner");
        if (adminSale.amountPerMember > 0) {
            uint256 buyCount;
            for (uint256 n; n < adminSale.buyers.length; n ++) {
                if (adminSale.buyers[n] == buyer) {
                    buyCount ++;
                }
            }
            require(buyCount < adminSale.amountPerMember, "already buyed as limit");
        }
        _mint(buyer, tokenId, uri);
        adminSales[saleType].buyers.push(buyer);
        adminSales[saleType].totalAmount = adminSale.totalAmount - 1;
    }
    function buyAdminSaleByMember(
        string memory saleType,
        uint256 tokenId,
        string memory uri
    ) public payable nonReentrant {
        AdminSale memory adminSale = getAdminSale(saleType);
        uint256 bnb = msg.value;
        address buyer = _msgSender();
        require(buyer.balance >= bnb, "not enough BNB");
        require(adminSale.status, "not on sale");
        require(bnb == adminSale.price, "incorrect bnb value for sale");
        require(adminSale.totalAmount > 0, "sold out");
        require(!_exists(tokenId), "token id already exists");
        require(adminSale.members.length > 0, "cannot find member set");
        bool isMember = false;
        for (uint256 i; i < adminSale.members.length; i ++) {
            if (adminSale.members[i] == buyer) {
                isMember = true;
            }
        }
        require(isMember, "buyer is not member for this sale");
        if (adminSale.amountPerMember > 0) {
            uint256 buyCount;
            for (uint256 n; n < adminSale.buyers.length; n ++) {
                if (adminSale.buyers[n] == buyer) {
                    buyCount ++;
                }
            }
            require(buyCount < adminSale.amountPerMember, "already buyed as limit");
        }
        (bool sendToOwner,) = payable(owner()).call{value: bnb}("");
        require(sendToOwner, "failed to send BNB for owner");
        _mint(buyer, tokenId, uri);
        adminSales[saleType].buyers.push(buyer);
        adminSales[saleType].totalAmount = adminSale.totalAmount - 1;
    }
    function setSale(
        uint256 tokenId,
        bool status,
        bool isAuction,
        address manager,
        string memory unit,
        uint256 price,
        uint256 minBidAmount,
        address topBidder,
        uint256 topBidAmount
    ) internal {
        require(_exists(tokenId), "token not exists");
        sales[tokenId] = Sale(status, isAuction, manager, unit, price, minBidAmount, topBidder, topBidAmount);
    }
    function switchSaleStatus(
        uint256 tokenId
    ) public onlyRole(ADMIN_ROLE) {
        Sale memory sale = getSale(tokenId);
        require(bytes(sale.unit).length > 0, "token not on sale");
        if (sale.status) {
            sales[tokenId].status = false;
        }
        if (!sale.status) {
            sales[tokenId].status = true;
        }
    }
    function unregisterSaleByHolder(
        uint256 tokenId
    ) public {
        Sale memory sale = getSale(tokenId);
        address holder = _msgSender();
        require(ownerOf(tokenId) == holder, "only holder can unregister sale");
        require(sale.status, "token not on sale");
        require(sale.topBidAmount == 0, "cannot cancel after bid");
        setSale(tokenId, false, false, address(0), "", 0, 0, address(0), 0);
    }
    function getSale(
        uint256 tokenId
    ) public view returns (Sale memory) {
        return sales[tokenId];
    }
    function calculateSaleFee(
        uint256 tokenId
    ) public view returns (uint256, uint256) {
        Sale memory sale = getSale(tokenId);
        require(sale.status, "token not on sale");
        uint256 value;
        uint256 fee;
        uint256 result;
        if (sale.isAuction) {
            value = sale.topBidAmount;
        } else {
            value = sale.price;
        }
        if (keccak256(abi.encode(sale.unit)) == keccak256(abi.encode("ROD"))) {
            fee = value * RODTransferFee / 10000;
            result = value - fee;
        }
        if (keccak256(abi.encode(sale.unit)) == keccak256(abi.encode("BNB"))) {
            fee = value * BNBTransferFee / 10000;
            result = value - fee;
        }
        return (fee, result);
    }
    function registerOnMarketByAdmin(
        address seller,
        uint256 tokenId,
        uint256 isAuction,
        address manager,
        string memory unit,
        uint256 price,
        uint256 minBidAmount
    ) public onlyRole(ADMIN_ROLE) {
        require(ownerOf(tokenId) == seller, "seller is not owner of token");
        require(!sales[tokenId].status, "already on sale");
        require(isAuction < 2, "invalid auction value");
        bool auction = false;
        if (isAuction == 1) {
            require(hasRole(ADMIN_ROLE, manager), "invalid manager address");
            require(minBidAmount >= minPrice, "bid amount must bigger than minimum price");
            auction = true;
        }
        if (isAuction == 0) {
            require(price >= minPrice, "price must bigger than minimum price");
        }
        setSale(tokenId, true, auction, manager, unit, price, minBidAmount, address(0), 0);
    }
    function bidOnMarket(
        uint256 tokenId
    ) public payable nonReentrant {
        Sale memory sale = getSale(tokenId);
        address bidder = _msgSender();
        address seller = ownerOf(tokenId);
        uint bnb = msg.value;
        require(bidder != seller, "already holding token");
        require(bidder.balance >= bnb, "not enough BNB to bid");
        require(sale.status, "token not on sale");
        require(sale.isAuction, "type of sale is not auction");
        require(keccak256(abi.encode(sale.unit)) == keccak256(abi.encode("BNB")), "sale does not for BNB");
        require(bnb >= sale.minBidAmount, "BNB must bigger than minimum amount for bidding");
        require(bnb > sale.topBidAmount, "BNB must bigger than current top bid amount");
        if (sale.price > 0) {
            require(bnb <= sale.price, "cannot bid BNB bigger than price");
        }
        sales[tokenId].topBidder = bidder;
        sales[tokenId].topBidAmount = bnb;
        uint256 forManager = bnb - sale.topBidAmount;
        (bool sendToManager,) = payable(sale.manager).call{value: forManager}("");
        require(sendToManager, "failed to send BNB for owner");
        if (sale.topBidAmount > 0) {
            (bool sendToCurrentTopBidder,) = payable(sale.topBidder).call{value: sale.topBidAmount}("");
            require(sendToCurrentTopBidder, "failed to send BNB for current top bidder");
        }
    }
    function bidOnMarketByRODCA(
        uint256 tokenId,
        address bidder,
        uint256 rod
    ) public onlyRole(ADMIN_ROLE) returns (address, uint256, address) {
        Sale memory sale = getSale(tokenId);
        address seller = ownerOf(tokenId);
        require(bidder != seller, "already holding token");
        require(sale.status, "token not on sale");
        require(sale.isAuction, "type of sale is not auction");
        require(hasRole(ADMIN_ROLE, sale.manager), "invalid manager address");
        require(keccak256(abi.encode(sale.unit)) == keccak256(abi.encode("ROD")), "sale does not for ROD");
        require(rod >= sale.minBidAmount, "ROD must bigger than minimum amount for bidding");
        require(rod > sale.topBidAmount, "ROD must bigger than current top bid amount");
        if (sale.price > 0) {
            require(rod <= sale.price, "cannot bid ROD bigger than price");
        }
        sales[tokenId].topBidder = bidder;
        sales[tokenId].topBidAmount = rod;
        return (sale.topBidder, sale.topBidAmount, sale.manager);
    }
    function finishBidByAdmin(
        uint256 tokenId
    ) public payable onlyRole(ADMIN_ROLE) {
        Sale memory sale = getSale(tokenId);
        (, uint256 forSeller) = calculateSaleFee(tokenId);
        require(_msgSender() == sale.manager, "only manager can finish auction");
        require(msg.value == forSeller, "invalid BNB value for seller");
        require(sale.status, "token not on sale");
        require(sale.isAuction, "type of sale is not auction");
        require(keccak256(abi.encode(sale.unit)) == keccak256(abi.encode("BNB")), "sale does not for BNB");
        require(sale.topBidder !=  address(0), "no bid for sale");
        setSale(tokenId, false, false, address(0), "", 0, 0, address(0), 0);
        if (sale.topBidAmount > 0) {
            address seller = ownerOf(tokenId);
            _transfer(seller, sale.topBidder, tokenId);
            (bool sendToSeller,) = payable(seller).call{value: forSeller}("");
            require(sendToSeller, "failed to send BNB for seller");
            emit SaleTransferred(sale.unit, sale.price, sale.topBidder, sale.topBidAmount);
        }   
    }
    function finishRODBidByAdmin(
        uint256 tokenId
    ) public onlyRole(ADMIN_ROLE) {
        Sale memory sale = getSale(tokenId);
        (, uint256 forSeller) = calculateSaleFee(tokenId);
        require(_msgSender() == sale.manager, "only manager can finish auction");
        require(sale.status, "token not on sale");
        require(sale.isAuction, "type of sale is not auction");
        require(keccak256(abi.encode(sale.unit)) == keccak256(abi.encode("ROD")), "sale does not for ROD");
        require(sale.topBidder !=  address(0), "no bid for sale");
        setSale(tokenId, false, false, address(0), "", 0, 0, address(0), 0);
        if (sale.topBidAmount > 0) {
            address seller = ownerOf(tokenId);
            _transfer(ownerOf(tokenId), sale.topBidder, tokenId);
            (bool sendToSeller,) = address(RODCA).call(abi.encodeWithSignature("transferByAdmin(address,address,uint256)", sale.manager, seller, forSeller));
            require(sendToSeller, "failed to send BNB for seller");
            emit SaleTransferred(sale.unit, sale.price, sale.topBidder, sale.topBidAmount);
        }
    }
    function transferOnMarket(
        uint256 tokenId
    ) public payable nonReentrant {
        Sale memory sale = getSale(tokenId);
        uint256 bnb = msg.value;
        address buyer = _msgSender();
        address seller = ownerOf(tokenId);
        require(buyer != seller, "already holding token");
        require(sale.status, "token not on sale");
        require(!sale.isAuction, "type of sale is auction");
        require(keccak256(abi.encode(sale.unit)) == keccak256(abi.encode("BNB")), "sale does not for BNB");
        require(sale.price == bnb, "incorrect amount of BNB");
        require(buyer.balance >= sale.price, "not enough BNB to transfer");
        (uint256 forOwner, uint256 forSeller) = calculateSaleFee(tokenId);
        if (forOwner > 0) {
            (bool sendToOwner,) = payable(owner()).call{value: forOwner}("");
            require(sendToOwner, "failed to send BNB for owner");
        }
        (bool sendToSeller,) = payable(seller).call{value: forSeller}("");
        require(sendToSeller, "failed to send BNB for seller");
        setSale(tokenId, false, false, address(0), "", 0, 0, address(0), 0);
        _transfer(seller, buyer, tokenId);
        emit SaleTransferred(sale.unit, sale.price, buyer, sale.price);
    }
    function transferOnMarketByRODCA(
        uint256 tokenId,
        address buyer,
        uint256 rod
    ) public onlyRole(ADMIN_ROLE) returns (uint256, uint256, address) {
        Sale memory sale = getSale(tokenId);
        address seller = ownerOf(tokenId);
        require(buyer != seller, "already holding token");
        require(sale.status, "token not on sale");
        require(!sale.isAuction, "type of sale is auction");
        require(keccak256(abi.encode(sale.unit)) == keccak256(abi.encode("ROD")), "sale does not for ROD");
        require(sale.price == rod, "incorrect amount of ROD");
        (uint256 forOwner, uint256 forSeller) = calculateSaleFee(tokenId);
        setSale(tokenId, false, false, address(0), "", 0, 0, address(0), 0);
        _transfer(seller, buyer, tokenId);
        emit SaleTransferred(sale.unit, sale.price, buyer, sale.price);
        return (forOwner, forSeller, seller);
    }
}