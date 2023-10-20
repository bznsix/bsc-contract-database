// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {OrderStructs} from "./libraries/orderStructs.sol";

contract ExecutiveManager {
    using OrderStructs for OrderStructs.Maker;

    uint256 listingCounter = 1;

    mapping(bytes32 => OrderStructs.Maker) public dataForOrderHash;

    mapping(bytes32 => bool) public listedProjects;

    bytes32[] public hashs;

    event MarketMaker(address from, bytes32 orderHash);

    function createMarketMaker(OrderStructs.Maker calldata makerBid) external {
        bytes32 orderHash = makerBid.hash();

        if (listedProjects[orderHash])
            revert("This Project has already been listed");

        listedProjects[orderHash] = true;

        dataForOrderHash[orderHash].collection = makerBid.collection;
        dataForOrderHash[orderHash].media = makerBid.media;
        dataForOrderHash[orderHash].status = makerBid.status;

        hashs.push(orderHash);

        // Emitir um evento para registrar o hash gerado
        emit MarketMaker(msg.sender, orderHash);
    }

    function getDataForOrderHash(
        bytes32 orderHash
    ) public view returns (OrderStructs.Maker memory) {
        return dataForOrderHash[orderHash];
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library OrderStructs {
    struct ListCollection {
        address nft;
        bool status;
    }

    struct Maker {
        address collection;
        string[] media;
        string status;
    }

    struct Taker {
        address recipient;
    }

    bytes32 internal constant _MAKER_TYPEHASH =
        keccak256(
            "Maker("
            "address collection,"
            "string[] media,"
            "string status,"
            ")"
        );

    function hash(Maker memory maker) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    _MAKER_TYPEHASH,
                    maker.collection,
                    maker.media,
                    maker.status
                )
            );
    }
}

contract ExecutionManager {
    using OrderStructs for OrderStructs.Maker;

    function createMarketMaker(
        OrderStructs.Maker calldata makerBid
    ) public pure returns (bytes32) {
        return makerBid.hash();
    }
}
