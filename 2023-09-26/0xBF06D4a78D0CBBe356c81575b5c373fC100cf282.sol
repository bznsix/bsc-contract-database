// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
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
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
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
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Airdrop is Ownable {
    address public constant token = 0x4950C48Ccf576d185eB3A0820728A6cFE435d493;
    uint256 public constant start = 1695657600;
    address[] public addresses = [
        0x23Fc6f7b077206b6Be4A13d66e9e0894E9D3028e,
        0xD89A88119E24426565eb582B964f55BeBa035386,
        0xc0Fd20106991b8C82Be46AA5d5c21a4725472CD7,
        0xE5008755600A13C10D8194f817a1bb7A86dC50eF,
        0x35c3A5fBBcB7A3cAfCD986E893Cf9BfA127a9cc3,
        0x3480084122Ac67aDd76816Cb531327E888f85d00,
        0x5F30aeE83D8098f54Cd200DB9D82D035661657a2,
        0xA7097CA6Be7582A197917b93fa041261B4e18C93,
        0x1309F11FDE4f27C222d6b7156Bf5741E71fefb2f,
        0x2C05d2397AE6154d8d714Fd7e814066720F47ca3,
        0xfB3eDcC6b1727942951aF5e933bB8f1941fe5197,
        0x9882Dae0dee373d781f39e0bBB9D9e1B2f005512,
        0xb0C927D275509C280fB4A810a8f8416467Bc68E1,
        0xB6a90D3c43c5b4bb16A4812DB18fc627De1BE44f,
        0x3de928d9675FD151069554F29114c61af1D89CC7,
        0x77e3346f054D2A633CF28abaB08DbABaDcFc23c8,
        0xc0Fd20106991b8C82Be46AA5d5c21a4725472CD7,
        0xf9A816A3831832f89394c4cAfEDbc97EE718ea56,
        0xB880D0ce2082E8411E63CF0d57e4183c2956025e,
        0x0d58f7B78d7Dda4Fb42D63Eb77B6c2B2015BD2B8,
        0x18b33dBb9344d914eF81c2A5A18e0D18FDd51234,
        0x6007dA70Ac83070fFAde1D48E4240Ca94d859536,
        0x7Ac39C7e1a873Eb9461aB9EdFB6aA42C6FB7a96c,
        0xB7D4204A9e0Ede3BE755A65B66bF9E54B7163a1A,
        0xc356B69A86A98bDd105972DC24b1048110a05F6f,
        0xED55c709941d432Ff541a328F1D1893db341b314,
        0x2cc05823EcA53d483f879D0c5283b988684dfcB8,
        0x2077fE5EFdbA73e1Ff8117D42A93fcd2B36dF69d,
        0xf7Eb188e3D3E0f577d22dCcda3aa3835111865c1,
        0x27AdD55D1B72A02a42B1f63cc12b4D1443d30E19,
        0x84B5C7AbC6d60aE13eC44463252A7754d182240c,
        0x05e88FbF649f8d75Ec13Fc376E1144fc42673567,
        0x0C0B0ca894E3942aA9621DBa57C30b8Eef3CC33b,
        0x1eFB1a780d8E36DBB270277bFEF852cd90574E90,
        0x2690EB948dF81bc7442C4F8c30415eF82CCb5889,
        0x295F7b961DF17Bce2Cd745Ed254750E556345b0F,
        0x4397548B8D9A53Cd38b2515578f9c4CE3fA911a5,
        0x5f3bbc845758Ef973D38398F57e0A1EB4A86d4b3,
        0x6157B2B1f995B5d4849FB0933e4Fb3645F15c5c5,
        0x6267B7F076e3EDD36967BC5ebe96c50a2e8DA93D,
        0x62883e92Af25Ad5625E0b9445927E934439fdeE9,
        0x776Ee34b808E62Efc4c918D3eDefd71DB0941391,
        0x9544bD563e37Fb723Ab33B64BD74439E16E392D1,
        0xD29b14A0209c8464bA891d6cf610E6e68674e205,
        0xd96E77095Be26EE62119a00673Ff90c88F6B4B49,
        0xDEb07586a1D66D3A05D3d8A422a7e9135A03c4f4,
        0x7FF177B6f9f8fe3Fd51F56243bd7615C62726369,
        0x5F30aeE83D8098f54Cd200DB9D82D035661657a2,
        0x20A5b683CE660C007a4564D7bcB2e6aB389a9984,
        0xB3f01217FA5fd82a679A9379B57294130bD9C3de,
        0x257e114B2Ce02ed5f228B8e38836Cc0426Bde4eb,
        0x27819bC1C84eF8656637FceDe40D21B29e5c7558,
        0x29147e0809b8F727b3b44FFf2F67FDba628912AB,
        0x41C7CC92d22A8C36241f0Cb9fb1F247B524AbB66,
        0x69349aDDEf4550a121E6358e4DdC938b0e592924,
        0x93C929437417B362C4aa85EC6F284b4054E324B7,
        0x973CEC450e063Fd99eD5Eec6a24b3aAc49e1AAa1,
        0xAEd0ecB6D6eF010243048f3A73F944470D30Ef98,
        0xdf0010d1cb36c54951b1D1f9127D2FF9BE74D38e,
        0xe2735A790153846f2e3756912cE0CE4829850B9B,
        0xf6957aF17dAdFD9E650a65Cf05B2606fbB94d2A8,
        0x5D41abD86ecfbcD30d2B5E4B8f0336884f2dDc6e,
        0xa7cB388b88e45cefEF9c81623238d8EB74B327B3,
        0xa88f010F97A8Ff24caaF35f8b553547C8583043A,
        0xcDe0a73499e94877ef92Ef87A740E7034fcee414,
        0xD42A3203E6D0f484B5d87DBE4c79206309C63575,
        0x3de928d9675FD151069554F29114c61af1D89CC7,
        0x50191DdB8E63679617daa06525dd9692222A0f0c,
        0x5d3f3FB1d7547A12BCEBEcFF92F4499bAf595463,
        0x71c13a0725EAE6A4824aBF7A5E90437A32DB148E,
        0x8d421bCD19E6c24a4925d39d9E71AdEF7C6cc947,
        0xa06D2545304207cCF3AfF5471d65377cCC596Ee6,
        0xB5742b67BaB7767cF74C310986b313547D18f129,
        0xD226b392065B05959a22BfCa89146c099B6b73A4,
        0xc590274e2C937659D11703a0cf0887F2b09Bf07D,
        0x2545317581cc60Ef893b1aE30d5F3Bb72831bD53,
        0xed1A0Fa5aAbd44647B67Bb00644A8Da42e092a8C,
        0x3Ba7C65cde06286738e8E2755f0802F5b2Ee951f,
        0xA30Cfea11Fcf853c2e49023b1781d37b78d74BE6,
        0xc799065617458db4032802C61AeBC3233ab5Bcb2,
        0x906B1513a60da473551a7bADed281d59DF27664d,
        0xDa3555E71a6252d4b0c1D3bf1f9A4122F00b2Ab9,
        0xF454bE2DD399d463bF7E0303dEe3611bDcE6a519,
        0x13469c89307C0541244D0daA78A74349e77b57b7,
        0xA13b2374e79Dbbf0797F7F10CE31841116f35331,
        0x35F89135b755FA2B3260f64B0A8627D150Ab6795,
        0x493322DDEaf655EF7b7AB967DFc087b364Af0dF8,
        0x27AdD55D1B72A02a42B1f63cc12b4D1443d30E19,
        0xd3034987C9188b23214433f4FF515F512c8B6483,
        0x2545317581cc60Ef893b1aE30d5F3Bb72831bD53,
        0x28864FB9bc6717574fd92ab980521F7C5d2A8f7a,
        0x37DB3C117A65783EcdCa066bcD8EE4f11c4A3d9a,
        0x438042680d429e614d89be059bd410d7A565a58b,
        0x6fc2b2C893E606630Ccb14cb01f5D4C3c9cbc3ee,
        0xa984C07955D897B8a2E4A1AF108883F05a27b6Ab,
        0xc3Cc2EAF23458509E88BC47D4ab4E4715602da01,
        0xd9Ee607b864b1eB32C3C1206819160e784488D66,
        0xfC0488E50830bf4c008C5D9b76Bf0935c4911eBD,
        0x865C270D9EfD5F2095544bf0Fd8dCc0600047cd9
    ];
    uint256[] public amounts = [
        116666,
        77500,
        71428,
        65833,
        52547,
        41666,
        41666,
        41666,
        34833,
        33333,
        26390,
        25000,
        25000,
        25000,
        21666,
        20833,
        20380,
        19020,
        18750,
        16666,
        16666,
        16666,
        16666,
        16666,
        16666,
        16666,
        16533,
        16333,
        14285,
        14208,
        13750,
        12500,
        12500,
        12500,
        12500,
        12500,
        12500,
        12500,
        12500,
        12500,
        12500,
        12500,
        12500,
        12500,
        12500,
        12500,
        11666,
        10839,
        10000,
        10000,
        9083,
        8333,
        8333,
        8333,
        8333,
        8333,
        8333,
        8333,
        8333,
        8333,
        8333,
        6520,
        6520,
        6520,
        6520,
        6520,
        6250,
        6250,
        6250,
        6250,
        6250,
        6250,
        6250,
        6250,
        6225,
        5771,
        4187,
        4166,
        4166,
        4166,
        3993,
        3750,
        3750,
        3333,
        3031,
        2500,
        2468,
        1875,
        1875,
        1687,
        1666,
        1666,
        1666,
        1666,
        1666,
        1666,
        1666,
        1312,
        1250
    ];
    mapping(uint256 => bool) public status;

    function send() public onlyOwner {
        if (block.timestamp < start) revert();

        uint256 day = (block.timestamp - start) / 1 days;
        if (status[day] == true) revert();

        status[day] = true;

        for (uint i = 0; i < addresses.length; i++) {
            IERC20(token).transfer(addresses[i], (amounts[i] * 1e18) / 200);
        }
    }

    function claim() public onlyOwner {
        uint256 amount = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(msg.sender, amount);
    }
}
