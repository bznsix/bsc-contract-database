// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "../interfaces/IPlaybuxQuestNFT.sol";

contract AirdropWalkToWin is Ownable, Pausable {
    IPlaybuxQuestNFT public immutable NFT;
    address[] private RECEIVERS = [
        0x2189aADF64fA4bc5cd5F585EB3E50D11e0ef1674,
        0xB80cE08F7ecb58D93421e0Db19a1e2D8077AE087,
        0x29eC15f83cE1DF9fCeA32e54Ce5B1B59a792AAf5,
        0xAADa5d807E1b7bC6AE5A028DcC9D711d3dF16061,
        0xC4fE9A30657971ce8Bfb05Fb6c30996242e96A16,
        0x355C81E2a70f97D8F9AdAEE06cB04fE651b7126B,
        0x074A565cb00430b4Fd1cEbF6d7f68D613307581a,
        0xf1a1D5287c485Da7964507dB049F752da9f80584,
        0x4E3cC50553F0d8544A298517844421C7f316EcF1,
        0x3dBE14b844BD5dCe1AA233452D5698Bfb2088337,
        0x9d30e181E93B680662646fE622F9812A05552393,
        0x1506bF1b4979B3cC94C979878E6661A31Af004B3,
        0x59BAbD3F217f18AFE02081101812644F83Ba049b,
        0xC1f8344792F33722c39db965b257C9f3E0a4a320,
        0x973D58B370348B13B436A887b9cB0b050819BF77,
        0xE256A6CA469081774F9B7ff593b312E7544713F2,
        0x677b750119cCb654b9E86071E7007A11b0882d6e,
        0xD27126B0AD33799098e29037b4350CfE9bf6F5d8,
        0x17E9283E1b209F2BeF7c8b611Cd7825acD82E06F,
        0x006828f55e2d5A48293f6B6f415561330dCF05Fb,
        0x8dD51BFE723b4177BE06227d55B3356EA336aE99,
        0xb2E999FBe093AEfa92F7ee5F1d2fd29c9437404C,
        0xc8c16c236A825F3DCa939b84C1e34cf03507bbC5,
        0x5F67722Bb1dAb5d86485B7BD0118977C01417725,
        0xAB29582fDA8F7f04469A9a180648f13A40663830,
        0x8F39CBaefb1AA2BC66521d1F0f64E2797eD01fEC,
        0x50ae47077dE7942909508FaaC53881fE820e6483,
        0xE99eD1e6aaFFeeFEc35BC3d7c72b264740487617,
        0xCB895Dfa8808d0c5A900ced39Da485DdC0bF31E9,
        0xe8aaFf6ff88B793F66c3af0B2A098C104A7def1C,
        0x0E9e22dA80721292140eba0783988796207F954a,
        0xdd317cdd649cE3c208098F7d840dF2a35DeC452B,
        0xE3a10daa4Afea422529CC4830fDd8b810ECee715,
        0xF54abb55c5223Cbb28C80759658266f96e8f24Cd,
        0xD36D8bb6bddD40df6a5e36E4cb69690609D9E863,
        0xE0Ecf2A7C047d72b5d66f94C02c193fD26486eDa,
        0x9781F7E4BD35d31d4F643baFa3f3C6eBcE3D65A8,
        0x3E68FCA5b47bF0510DEBB0fa95d51c54B032A1C8,
        0x53A1808b1Ec5c97254368475323B6732533800BE,
        0x1DefcD0ca309C1A588Aa35a5dAE84991A3e98a7a,
        0x4eA1325D5c96cC5a92DaC67010D44f47450B17E1,
        0x5baDF5870CAaDCC96D0D0E82bBE8f143ABFce0B7,
        0x19bfA6236b11396B6eFA4C1bF62d452146A9FB14,
        0x6Bf0Af943AC30Cb9a191b75F5F0569f2Ea2F5206,
        0xB446a18cCD9f9cC3BB84D779b47Bd1903B5c3cf5,
        0x5ef51faC2C239980a6B10c6de67e499fb1155022,
        0x3EE7E7C4E75174808eFe37db4d3537384fc5F14B,
        0x4C904f1c39087768b3128182F3A281f7c627bde3,
        0x05b98DEc0bF2D2D78997E07517693335aB8f99D3,
        0x9E1C6eB16e04a1778234fD6b3af78C2C53503F86,
        0xaE5750A0Db265434a4434e168FaAbd3b7CAdb070,
        0xD644C1B56c3F8FAA7beB446C93dA2F190bFaeD9B,
        0x98b267c74728e49fD14bdEEdd7e08F6c610Be38A,
        0xDa67917EE1e316EA41F0A30d35b84B99EF26D83F,
        0xE304769b9415a23a1FC3DA8e480765962C4e41E8,
        0x54135B80F795EC386bce92298AB3FA939394BE8D,
        0xAe0ed6c4A5C9F56152E13B63015a2793ee061Ade,
        0xE5d0101d8eBb71D38419C8a0130c08723818A1ff,
        0x8Fae50cF2E2Ad4f25B2cBD12440aE0588815d67F,
        0xFA8Ba03b1720D59c6EAb5Ea8eF85a7E7fcDdE096,
        0x4eF91cfE3BC07c0D82BDDDf0d123F770B4cc3fA3,
        0xdF2aDF272e40fE277321B21AA58DDCcc3Bc648eE,
        0xd2C33CB8481Fb75D76D4182d119cA3c2cc07e2E1,
        0x0169F983FF868994CFa4B6Dd595219434D26df55,
        0x9Fd6283D3F6ABe65B1aE27c3fe498F10631281E7,
        0x66cF5A52bBCacD1cfa1cd65eDdF94d7bf2e4a7bB,
        0x6258A43550f68eC04385D36B3c4aea61c9C8E3FF,
        0x8098e3f6235aB6146d4c919D679c24dDD068643e,
        0x2F8964f395613b188bC71B1021625fDEBE5bC567,
        0x839F1de869BF8D37420DCaDe9537d5f4D38F5C1A,
        0xfB68149c04B3F68dbe3c73A4600a0eb873100705,
        0xfA63C18AB19AfFB567C91f3b516f210b30A2Ed30,
        0xDA99F3770e54a808A0211D3a31937061f67a8Cb1,
        0xb6F2128A9b8c6eD9100c5AffB8A366F9561b80B3,
        0x3C220C7ADA23D17989090f31EE5e75ECF7Da7FBa,
        0x555E89390e95B7285cD5A884f0a5bA8ccAc38ccE,
        0x93C10b5B55ACA304086De9D0de20461bCE998cBB,
        0xE05aB1a32eD3A29edAC4c17eC4B5715e798772af,
        0x477ee7Fc5926224aD511C9A4Ed2e8C7121Fe5aEE,
        0x56e3581416C867D29CE7429C208048C9CA50e1FB,
        0x574bf1bbBa911775F2F95B9c031b864E23821366,
        0x7dae8DFE6b017F24f53574338BAD6355959676AF,
        0xEb7F86EC225808d018989Bd08C5C7800BEbe9493,
        0x6C75881D661f2d0d160011BDC967263C02D18357,
        0xfbE902fbCF72ab5Daa455c7090B699C0A73A66E1,
        0x853c7403ACb907d071109D18f1F0B3112628ACED,
        0xBc46Ab3B79372492B654fB4B972CCc3533ec85a7,
        0x25264Fdc2D80f9a0ff7a34bcb47Fb4284157615F,
        0xf3Aa2B47cfE428f90Ea292288db70f95016Dd7bB,
        0x09892f4D082545D4C48f04c59314559aC154694f,
        0xDCD1c123Af9Cb547951f21f560558bbf5E7c2C5B,
        0x76C5762E65cB28B928466256C680F5342C4Ad234,
        0x4e988C25653D3A33c992d318Fb1B07b8ebC8db9d,
        0x5D5658e00AE51938423A31227971Fc9848Fb87F4,
        0x7AC36247457Dab3aBB833aCcC538a3e56ce538B1,
        0x2bF230EB212F7C12630A1F1ab10aB6fDb6cDD315,
        0xc1deEA95Ed5d402d052FA169dF008Faf54C3F837,
        0x7aDDD53f094F3Efb7aa248319df56Cd62D417C5B,
        0x3b2732B4d942c7E9334720D69A7e29386656895B,
        0xA2a7d00b85bB130959768B4db3E3EF762A5992c0
    ];

    uint256[] private TYPES = [
        147,
        146,
        146,
        146,
        146,
        145,
        145,
        145,
        145,
        145,
        145,
        145,
        145,
        145,
        145,
        145,
        145,
        145,
        145,
        145,
        144,
        144,
        144,
        144,
        144,
        144,
        144,
        144,
        144,
        144,
        144,
        144,
        144,
        144,
        144,
        144,
        144,
        144,
        144,
        144,
        144,
        144,
        144,
        144,
        144,
        144,
        144,
        144,
        144,
        144,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143,
        143
    ];

    bool private minted = false;

    constructor(IPlaybuxQuestNFT _nft) {
        NFT = _nft;
        _pause();
    }

    function airdrop() external onlyOwner whenNotPaused {
        require(RECEIVERS.length == TYPES.length, "Airdrop: invalid length");
        require(!minted, "Airdrop: minted");
        minted = true;
        for (uint256 i = 0; i < RECEIVERS.length; i++) {
            NFT.mintTo(RECEIVERS[i], TYPES[i]);
        }
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IPlaybuxQuestNFT is IERC721 {
    function mintTo(address _to, uint256 _type) external;

    function burnByTokenId(uint256 _tokenId) external;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
