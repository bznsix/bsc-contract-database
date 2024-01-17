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
// contracts/IDbxToken.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

abstract contract IDbxToken {
    function capAsset(
        address account, 
        uint256 asset
    ) external virtual returns (bool);

    function mintDbx(
        address account, 
        uint256 amount
    ) external virtual returns (bool);

    function burnFrom(
        address account, 
        uint256 amount
    ) external virtual;

    function balanceOf(address account) external view virtual returns (uint256);
}// contracts/IMVDnft.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

abstract contract IMVDnft {
    function mint(
        address account, 
        uint256 asset,
        address referer,
        uint256 quantity
    ) external view virtual returns (bool);

    function burnFrom(
        address account, 
        uint256 tokenId,
        uint256 value
    ) external virtual;

    function mintType(uint256 tokenId) external view virtual returns(uint);
    function rate(uint256 tokenId) external view virtual returns(uint256);
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Context.sol";
import "./interface/IMVDnft.sol";
import "./interface/IDbxToken.sol";

contract MVDnftBurn is Context {
    uint256 private constant DNFT_REWARD = 5e8;
    uint256 private constant REWARD_TIER_1 = 25;
    uint256 private constant REWARD_TIER_2 = 150;
    uint256 private _totalAsset;

    IMVDnft private mvdnft;
    IDbxToken private iDbxToken;
    uint[] private rewards = new uint[](3);

    constructor(IMVDnft mvdnft_, IDbxToken iDbxToken_) {
        mvdnft = mvdnft_;
        iDbxToken = iDbxToken_;
        rewards[0] = 250000 * 1e18;
        rewards[1] = 450000 * 1e18;
        rewards[2] = 500000 * 1e18;
        _migrate();
    }

    function burn(uint256 tokenId_, uint256 quantity_) external {
        require(quantity_ > 0, "MVDnftBurn: Invalid quantity");

        uint256 asset = mvdnft.rate(tokenId_) * quantity_;

        require(asset > 0, "MVDnftBurn: Invalid asset");
        mvdnft.burnFrom(_msgSender(), tokenId_, quantity_);

        uint256 nodeReward = (DNFT_REWARD * asset) + _bonusOf(asset);
        _totalAsset += asset;

        require(
            iDbxToken.mintDbx(_msgSender(), nodeReward),
            "MVDnftBurn: MintDbx failed"
        );
    }

    function bonusOf(uint256 asset) public view returns (uint256 bonusAmount) {
        return _bonusOf(asset);
    }

    function totalAsset() public view returns (uint256) {
        return _totalAsset;
    }

    function _bonusOf(
        uint256 asset
    ) internal view returns (uint256 bonusAmount) {
        uint256 usableAmount = 0;
        uint256 usedAmount = 0;
        uint256 totalAssetMinted = _totalAsset;
        uint256 amount = asset;
        for (uint256 i = 0; i < rewards.length; i++) {
            uint256 remainingTierAmount = rewards[i] >= totalAssetMinted ? rewards[i] - totalAssetMinted : 0;
            if (remainingTierAmount > 0) {
                usableAmount = amount > remainingTierAmount ? remainingTierAmount : amount;
                usedAmount += usableAmount;
                amount -= usableAmount;
                totalAssetMinted += usableAmount;
                if (i > 0) {
                    bonusAmount += ((usableAmount * ((_rewardPercentageOf(i)))) / 100) * DNFT_REWARD;
                }
            }

            if (usedAmount == asset) {
                break;
            }
        }
    }

    function _rewardPercentageOf(
        uint256 tier
    ) internal pure returns (uint256 bonusAmount) {
        if (tier == 2) {
            return REWARD_TIER_2;
        } else if (tier == 1) {
            return REWARD_TIER_1;
        }

        return 0;
    }

    function _migrate() internal {
        _totalAsset = 1e19;
        require(
            iDbxToken.mintDbx(0xe95481b5568baa7d915457Ca6736683df5ef81e8, _totalAsset * 4e8),
            "MVDnftBurn: MintDbx failed"
        );
    }
}
