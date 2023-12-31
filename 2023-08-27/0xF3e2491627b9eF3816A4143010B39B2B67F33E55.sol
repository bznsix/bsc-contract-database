// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import {StringSet} from "../data-structures/StringSet.sol";

/**
 *  @notice A simple library to work with sets
 */
library SetHelper {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    using StringSet for StringSet.Set;

    /**
     *  @notice The function to insert an array of elements into the set
     *  @param set the set to insert the elements into
     *  @param array_ the elements to be inserted
     */
    function add(EnumerableSet.AddressSet storage set, address[] memory array_) internal {
        for (uint256 i = 0; i < array_.length; i++) {
            set.add(array_[i]);
        }
    }

    function add(EnumerableSet.UintSet storage set, uint256[] memory array_) internal {
        for (uint256 i = 0; i < array_.length; i++) {
            set.add(array_[i]);
        }
    }

    function add(StringSet.Set storage set, string[] memory array_) internal {
        for (uint256 i = 0; i < array_.length; i++) {
            set.add(array_[i]);
        }
    }

    /**
     *  @notice The function to remove an array of elements from the set
     *  @param set the set to remove the elements from
     *  @param array_ the elements to be removed
     */
    function remove(EnumerableSet.AddressSet storage set, address[] memory array_) internal {
        for (uint256 i = 0; i < array_.length; i++) {
            set.remove(array_[i]);
        }
    }

    function remove(EnumerableSet.UintSet storage set, uint256[] memory array_) internal {
        for (uint256 i = 0; i < array_.length; i++) {
            set.remove(array_[i]);
        }
    }

    function remove(StringSet.Set storage set, string[] memory array_) internal {
        for (uint256 i = 0; i < array_.length; i++) {
            set.remove(array_[i]);
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 *  @notice Example:
 *
 *  using StringSet for StringSet.Set;
 *
 *  StringSet.Set internal set;
 */
library StringSet {
    struct Set {
        string[] _values;
        mapping(string => uint256) _indexes;
    }

    /**
     *  @notice The function add value to set
     *  @param set the set object
     *  @param value_ the value to add
     */
    function add(Set storage set, string memory value_) internal returns (bool) {
        if (!contains(set, value_)) {
            set._values.push(value_);
            set._indexes[value_] = set._values.length;

            return true;
        } else {
            return false;
        }
    }

    /**
     *  @notice The function remove value to set
     *  @param set the set object
     *  @param value_ the value to remove
     */
    function remove(Set storage set, string memory value_) internal returns (bool) {
        uint256 valueIndex_ = set._indexes[value_];

        if (valueIndex_ != 0) {
            uint256 toDeleteIndex_ = valueIndex_ - 1;
            uint256 lastIndex_ = set._values.length - 1;

            if (lastIndex_ != toDeleteIndex_) {
                string memory lastValue_ = set._values[lastIndex_];

                set._values[toDeleteIndex_] = lastValue_;
                set._indexes[lastValue_] = valueIndex_;
            }

            set._values.pop();

            delete set._indexes[value_];

            return true;
        } else {
            return false;
        }
    }

    /**
     *  @notice The function returns true if value in the set
     *  @param set the set object
     *  @param value_ the value to search in set
     *  @return true if value is in the set, false otherwise
     */
    function contains(Set storage set, string memory value_) internal view returns (bool) {
        return set._indexes[value_] != 0;
    }

    /**
     *  @notice The function returns length of set
     *  @param set the set object
     *  @return the the number of elements in the set
     */
    function length(Set storage set) internal view returns (uint256) {
        return set._values.length;
    }

    /**
     *  @notice The function returns value from set by index
     *  @param set the set object
     *  @param index_ the index of slot in set
     *  @return the value at index
     */
    function at(Set storage set, uint256 index_) internal view returns (string memory) {
        return set._values[index_];
    }

    /**
     *  @notice The function that returns values the set stores, can be very expensive to call
     *  @param set the set object
     *  @return the memory array of values
     */
    function values(Set storage set) internal view returns (string[] memory) {
        return set._values;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 *  @notice This library simplifies non-obvious type castings
 */
library TypeCaster {
    /**
     *  @notice The function that casts the list of `X`-type elements to the list of uint256
     *  @param from_ the list of `X`-type elements
     *  @return array_ the list of uint256
     */
    function asUint256Array(
        bytes32[] memory from_
    ) internal pure returns (uint256[] memory array_) {
        assembly {
            array_ := from_
        }
    }

    function asUint256Array(
        address[] memory from_
    ) internal pure returns (uint256[] memory array_) {
        assembly {
            array_ := from_
        }
    }

    /**
     *  @notice The function that casts the list of `X`-type elements to the list of addresses
     *  @param from_ the list of `X`-type elements
     *  @return array_ the list of addresses
     */
    function asAddressArray(
        bytes32[] memory from_
    ) internal pure returns (address[] memory array_) {
        assembly {
            array_ := from_
        }
    }

    function asAddressArray(
        uint256[] memory from_
    ) internal pure returns (address[] memory array_) {
        assembly {
            array_ := from_
        }
    }

    /**
     *  @notice The function that casts the list of `X`-type elements to the list of bytes32
     *  @param from_ the list of `X`-type elements
     *  @return array_ the list of bytes32
     */
    function asBytes32Array(
        uint256[] memory from_
    ) internal pure returns (bytes32[] memory array_) {
        assembly {
            array_ := from_
        }
    }

    function asBytes32Array(
        address[] memory from_
    ) internal pure returns (bytes32[] memory array_) {
        assembly {
            array_ := from_
        }
    }

    /**
     *  @notice The function to transform an element into an array
     *  @param from_ the element
     *  @return array_ the element as an array
     */
    function asSingletonArray(uint256 from_) internal pure returns (uint256[] memory array_) {
        array_ = new uint256[](1);
        array_[0] = from_;
    }

    function asSingletonArray(address from_) internal pure returns (address[] memory array_) {
        array_ = new address[](1);
        array_[0] = from_;
    }

    function asSingletonArray(string memory from_) internal pure returns (string[] memory array_) {
        array_ = new string[](1);
        array_[0] = from_;
    }

    function asSingletonArray(bytes32 from_) internal pure returns (bytes32[] memory array_) {
        array_ = new bytes32[](1);
        array_[0] = from_;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

/**
 *  @notice This library is needed to simplify the interaction with autogenerated contracts
 *  that use [snarkjs](https://www.npmjs.com/package/snarkjs) to verify ZK proofs.
 *
 *  The main problem with these contracts is that the verification function always has the same signature, except for one parameter.
 *  The `input` parameter is a static array `uint256`, the size of which depends on the number of public outputs of ZK proof,
 *  therefore the signatures of the verification functions may be different for different schemes.
 *
 *  With this library there is no need to create many different interfaces for each circuit.
 *  Also, the library functions accept dynamic arrays of public signals, so you don't need to convert them manually to static ones.
 */
library VerifierHelper {
    using Strings for uint256;

    struct ProofPoints {
        uint256[2] a;
        uint256[2][2] b;
        uint256[2] c;
    }

    /**
     *  @notice Function to call the `verifyProof` function on the `verifier` contract.
     *  The ZK proof points are wrapped in a structure for convenience
     *  @param verifier_ the address of the autogenerated `Verifier` contract
     *  @param pubSignals_ the array of the ZK proof public signals
     *  @param proofPoints_ the ProofPoints struct with ZK proof points
     *  @return true if the proof is valid, false - otherwise
     */
    function verifyProof(
        address verifier_,
        uint256[] memory pubSignals_,
        ProofPoints memory proofPoints_
    ) internal view returns (bool) {
        return
            _verifyProof(
                verifier_,
                proofPoints_.a,
                proofPoints_.b,
                proofPoints_.c,
                pubSignals_,
                pubSignals_.length
            );
    }

    /**
     *  @notice Function to call the `verifyProof` function on the `verifier` contract
     *  @param verifier_ the address of the autogenerated `Verifier` contract
     *  @param pubSignals_ the array of the ZK proof public signals
     *  @param a_ the A point of the ZK proof
     *  @param b_ the B point of the ZK proof
     *  @param c_ the C point of the ZK proof
     *  @return true if the proof is valid, false - otherwise
     */
    function verifyProof(
        address verifier_,
        uint256[] memory pubSignals_,
        uint256[2] memory a_,
        uint256[2][2] memory b_,
        uint256[2] memory c_
    ) internal view returns (bool) {
        return _verifyProof(verifier_, a_, b_, c_, pubSignals_, pubSignals_.length);
    }

    /**
     *  @notice Function to call the `verifyProof` function on the `verifier` contract.
     *  The ZK proof points are wrapped in a structure for convenience
     *  The length of the `pubSignals_` arr must be strictly equal to `pubSignalsCount_`
     *  @param verifier_ the address of the autogenerated `Verifier` contract
     *  @param pubSignals_ the array of the ZK proof public signals
     *  @param proofPoints_ the ProofPoints struct with ZK proof points
     *  @param pubSignalsCount_ the number of public signals
     *  @return true if the proof is valid, false - otherwise
     */
    function verifyProofSafe(
        address verifier_,
        uint256[] memory pubSignals_,
        ProofPoints memory proofPoints_,
        uint256 pubSignalsCount_
    ) internal view returns (bool) {
        require(
            pubSignals_.length == pubSignalsCount_,
            "VerifierHelper: invalid public signals count"
        );

        return
            _verifyProof(
                verifier_,
                proofPoints_.a,
                proofPoints_.b,
                proofPoints_.c,
                pubSignals_,
                pubSignalsCount_
            );
    }

    /**
     *  @notice Function to call the `verifyProof` function on the `verifier` contract
     *  The length of the `pubSignals_` arr must be strictly equal to `pubSignalsCount_`
     *  @param verifier_ the address of the autogenerated `Verifier` contract
     *  @param pubSignals_ the array of the ZK proof public signals
     *  @param a_ the A point of the ZK proof
     *  @param b_ the B point of the ZK proof
     *  @param c_ the C point of the ZK proof
     *  @param pubSignalsCount_ the number of public signals
     *  @return true if the proof is valid, false - otherwise
     */
    function verifyProofSafe(
        address verifier_,
        uint256[] memory pubSignals_,
        uint256[2] memory a_,
        uint256[2][2] memory b_,
        uint256[2] memory c_,
        uint256 pubSignalsCount_
    ) internal view returns (bool) {
        require(
            pubSignals_.length == pubSignalsCount_,
            "VerifierHelper: invalid public signals count"
        );

        return _verifyProof(verifier_, a_, b_, c_, pubSignals_, pubSignalsCount_);
    }

    function _verifyProof(
        address verifier_,
        uint256[2] memory a_,
        uint256[2][2] memory b_,
        uint256[2] memory c_,
        uint256[] memory pubSignals_,
        uint256 pubSignalsCount_
    ) private view returns (bool) {
        string memory funcSign_ = string(
            abi.encodePacked(
                "verifyProof(uint256[2],uint256[2][2],uint256[2],uint256[",
                pubSignalsCount_.toString(),
                "])"
            )
        );

        // We have to use abi.encodePacked to encode a dynamic array as a static array (without offset and length)
        (bool success_, bytes memory returnData_) = verifier_.staticcall(
            abi.encodePacked(abi.encodeWithSignature(funcSign_, a_, b_, c_), pubSignals_)
        );

        require(success_, "VerifierHelper: failed to call verifyProof function");

        return abi.decode(returnData_, (bool));
    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

interface ICircuitValidator {
    struct CircuitQuery {
        uint256 schema;
        uint256 claimPathKey;
        uint256 operator;
        uint256[] value;
        uint256 queryHash;
        string circuitId;
    }

    function verify(
        uint256[] memory inputs,
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256 queryHash
    ) external view returns (bool r);

    function getCircuitId() external pure returns (string memory id);

    function getChallengeInputIndex() external pure returns (uint256 index);
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

uint256 constant MAX_SMT_DEPTH = 64;

interface IState {
    /**
     * @dev Struct for public interfaces to represent a state information.
     * @param id An identity.
     * @param state A state.
     * @param replacedByState A state, which replaced this state for the identity.
     * @param createdAtTimestamp A time when the state was created.
     * @param replacedAtTimestamp A time when the state was replaced by the next identity state.
     * @param createdAtBlock A block number when the state was created.
     * @param replacedAtBlock A block number when the state was replaced by the next identity state.
     */
    struct StateInfo {
        uint256 id;
        uint256 state;
        uint256 replacedByState;
        uint256 createdAtTimestamp;
        uint256 replacedAtTimestamp;
        uint256 createdAtBlock;
        uint256 replacedAtBlock;
    }

    /**
     * @dev Struct for public interfaces to represent GIST root information.
     * @param root This GIST root.
     * @param replacedByRoot A root, which replaced this root.
     * @param createdAtTimestamp A time, when the root was saved to blockchain.
     * @param replacedAtTimestamp A time, when the root was replaced by the next root in blockchain.
     * @param createdAtBlock A number of block, when the root was saved to blockchain.
     * @param replacedAtBlock A number of block, when the root was replaced by the next root in blockchain.
     */
    struct GistRootInfo {
        uint256 root;
        uint256 replacedByRoot;
        uint256 createdAtTimestamp;
        uint256 replacedAtTimestamp;
        uint256 createdAtBlock;
        uint256 replacedAtBlock;
    }

    /**
     * @dev Struct for public interfaces to represent GIST proof information.
     * @param root This GIST root.
     * @param existence A flag, which shows if the leaf index exists in the GIST.
     * @param siblings An array of GIST sibling node hashes.
     * @param index An index of the leaf in the GIST.
     * @param value A value of the leaf in the GIST.
     * @param auxExistence A flag, which shows if the auxiliary leaf exists in the GIST.
     * @param auxIndex An index of the auxiliary leaf in the GIST.
     * @param auxValue An value of the auxiliary leaf in the GIST.
     */
    struct GistProof {
        uint256 root;
        bool existence;
        uint256[MAX_SMT_DEPTH] siblings;
        uint256 index;
        uint256 value;
        bool auxExistence;
        uint256 auxIndex;
        uint256 auxValue;
    }

    /**
     * @dev Retrieve last state information of specific id.
     * @param id An identity.
     * @return The state info.
     */
    function getStateInfoById(uint256 id) external view returns (StateInfo memory);

    /**
     * @dev Retrieve state information by id and state.
     * @param id An identity.
     * @param state A state.
     * @return The state info.
     */
    function getStateInfoByIdAndState(
        uint256 id,
        uint256 state
    ) external view returns (StateInfo memory);

    /**
     * @dev Retrieve the specific GIST root information.
     * @param root GIST root.
     * @return The GIST root info.
     */
    function getGISTRootInfo(uint256 root) external view returns (GistRootInfo memory);
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

interface IStateTransitionVerifier {
    function verifyProof(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[4] memory input
    ) external view returns (bool r);
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "../state/StateV2.sol";
import "./SmtLib.sol";

/// @title A common functions for arrays.
library ArrayUtils {
    /**
     * @dev Calculates bounds for the slice of the array.
     * @param arrLength An array length.
     * @param start A start index.
     * @param length A length of the slice.
     * @param limit A limit for the length.
     * @return The bounds for the slice of the array.
     */
    function calculateBounds(
        uint256 arrLength,
        uint256 start,
        uint256 length,
        uint256 limit
    ) internal pure returns (uint256, uint256) {
        require(length > 0, "Length should be greater than 0");
        require(length <= limit, "Length limit exceeded");
        require(start < arrLength, "Start index out of bounds");

        uint256 end = start + length;
        if (end > arrLength) {
            end = arrLength;
        }

        return (start, end);
    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "solidity-bytes-utils/contracts/BytesLib.sol";

library GenesisUtils {
    /**
     * @dev int256ToBytes
     */
    function int256ToBytes(uint256 x) internal pure returns (bytes memory b) {
        b = new bytes(32);
        assembly {
            mstore(add(b, 32), x)
        }
    }

    /**
     * @dev reverse
     */
    function reverse(uint256 input) internal pure returns (uint256 v) {
        v = input;

        // swap bytes
        v =
            ((v & 0xFF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00) >> 8) |
            ((v & 0x00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF) << 8);

        // swap 2-byte long pairs
        v =
            ((v & 0xFFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000) >> 16) |
            ((v & 0x0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF) << 16);

        // swap 4-byte long pairs
        v =
            ((v & 0xFFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000) >> 32) |
            ((v & 0x00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF) << 32);

        // swap 8-byte long pairs
        v =
            ((v & 0xFFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF0000000000000000) >> 64) |
            ((v & 0x0000000000000000FFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF) << 64);

        // swap 16-byte long pairs
        v = (v >> 128) | (v << 128);
    }

    /**
     * @dev reverse uint16
     */
    function reverse16(uint16 input) internal pure returns (uint16 v) {
        v = input;

        // swap bytes
        v = (v >> 8) | (v << 8);
    }

    /**
     *   @dev sum
     */
    function sum(bytes memory array) internal pure returns (uint16 s) {
        require(array.length == 29, "Checksum requires 29 length array");

        for (uint256 i = 0; i < array.length; ++i) {
            s += uint16(uint8(array[i]));
        }
    }

    /**
     * @dev bytesToHexString
     */
    function bytesToHexString(bytes memory buffer) internal pure returns (string memory) {
        // Fixed buffer size for hexadecimal convertion
        bytes memory converted = new bytes(buffer.length * 2);

        bytes memory _base = "0123456789abcdef";

        for (uint256 i = 0; i < buffer.length; i++) {
            converted[i * 2] = _base[uint8(buffer[i]) / _base.length];
            converted[i * 2 + 1] = _base[uint8(buffer[i]) % _base.length];
        }

        return string(abi.encodePacked("0x", converted));
    }

    /**
     * @dev compareStrings
     */
    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    /**
     * @dev isGenesisState
     */
    function isGenesisState(uint256 id, uint256 idState) internal pure returns (bool) {
        bytes memory userStateB1 = int256ToBytes(idState);

        bytes memory cutState = BytesLib.slice(userStateB1, userStateB1.length - 27, 27);

        bytes memory userIdB = int256ToBytes(id);
        bytes memory idType = BytesLib.slice(userIdB, userIdB.length - 31, 2);

        bytes memory beforeChecksum = BytesLib.concat(idType, cutState);
        require(beforeChecksum.length == 29, "Checksum requires 29 length array");

        uint16 checksum = reverse16(sum(beforeChecksum));

        bytes memory checkSumBytes = abi.encodePacked(checksum);

        bytes memory idBytes = BytesLib.concat(beforeChecksum, checkSumBytes);
        require(idBytes.length == 31, "idBytes requires 31 length array");

        return id == uint256(uint248(bytes31(idBytes)));
    }

    /**
     * @dev toUint256
     */
    function toUint256(bytes memory _bytes) internal pure returns (uint256 value) {
        assembly {
            value := mload(add(_bytes, 0x20))
        }
    }

    /**
     * @dev bytesToAddress
     */
    function bytesToAddress(bytes memory bys) internal pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }

    /**
     * @dev int256ToAddress
     */
    function int256ToAddress(uint256 input) internal pure returns (address) {
        return bytesToAddress(int256ToBytes(reverse(input)));
    }
}
//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// 2019 OKIMS
//      ported to solidity 0.6
//      fixed linter warnings
//      added requiere error messages
//
//
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

library Pairing {
    struct G1Point {
        uint X;
        uint Y;
    }
    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint[2] X;
        uint[2] Y;
    }

    /// @return the generator of G1
    function P1() internal pure returns (G1Point memory) {
        return G1Point(1, 2);
    }

    /// @return the generator of G2
    function P2() internal pure returns (G2Point memory) {
        // Original code point
        return
            G2Point(
                [
                    11559732032986387107991004021392285783925812861821192530917403151452391805634,
                    10857046999023057135944570762232829481370756359578518086990519993285655852781
                ],
                [
                    4082367875863433681332203403145435568316851327593401208105741076214120093531,
                    8495653923123431417604973247489272438418190587263600148770280649306958101930
                ]
            );

        /*
        // Changed by Jordi point
        return G2Point(
            [10857046999023057135944570762232829481370756359578518086990519993285655852781,
             11559732032986387107991004021392285783925812861821192530917403151452391805634],
            [8495653923123431417604973247489272438418190587263600148770280649306958101930,
             4082367875863433681332203403145435568316851327593401208105741076214120093531]
        );
*/
    }

    /// @return r the negation of p, i.e. p.addition(p.negate()) should be zero.
    function negate(G1Point memory p) internal pure returns (G1Point memory r) {
        // The prime q in the base field F_q for G1
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        if (p.X == 0 && p.Y == 0) return G1Point(0, 0);
        return G1Point(p.X, q - (p.Y % q));
    }

    /// @return r the sum of two points of G1
    function addition(
        G1Point memory p1,
        G1Point memory p2
    ) internal view returns (G1Point memory r) {
        uint[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success
            case 0 {
                invalid()
            }
        }
        require(success, "pairing-add-failed");
    }

    /// @return r the product of a point on G1 and a scalar, i.e.
    /// p == p.scalar_mul(1) and p.addition(p) == p.scalar_mul(2) for all points p.
    function scalar_mul(G1Point memory p, uint s) internal view returns (G1Point memory r) {
        uint[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success
            case 0 {
                invalid()
            }
        }
        require(success, "pairing-mul-failed");
    }

    /// @return the result of computing the pairing check
    /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
    /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
    /// return true.
    function pairing(G1Point[] memory p1, G2Point[] memory p2) internal view returns (bool) {
        require(p1.length == p2.length, "pairing-lengths-failed");
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);
        for (uint i = 0; i < elements; i++) {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[0];
            input[i * 6 + 3] = p2[i].X[1];
            input[i * 6 + 4] = p2[i].Y[0];
            input[i * 6 + 5] = p2[i].Y[1];
        }
        uint[1] memory out;
        bool success;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(
                sub(gas(), 2000),
                8,
                add(input, 0x20),
                mul(inputSize, 0x20),
                out,
                0x20
            )
            // Use "invalid" to make gas estimation work
            switch success
            case 0 {
                invalid()
            }
        }
        require(success, "pairing-opcode-failed");
        return out[0] != 0;
    }

    /// Convenience method for a pairing check for two pairs.
    function pairingProd2(
        G1Point memory a1,
        G2Point memory a2,
        G1Point memory b1,
        G2Point memory b2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](2);
        G2Point[] memory p2 = new G2Point[](2);
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return pairing(p1, p2);
    }

    /// Convenience method for a pairing check for three pairs.
    function pairingProd3(
        G1Point memory a1,
        G2Point memory a2,
        G1Point memory b1,
        G2Point memory b2,
        G1Point memory c1,
        G2Point memory c2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](3);
        G2Point[] memory p2 = new G2Point[](3);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        return pairing(p1, p2);
    }

    /// Convenience method for a pairing check for four pairs.
    function pairingProd4(
        G1Point memory a1,
        G2Point memory a2,
        G1Point memory b1,
        G2Point memory b2,
        G1Point memory c1,
        G2Point memory c2,
        G1Point memory d1,
        G2Point memory d2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](4);
        G2Point[] memory p2 = new G2Point[](4);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p1[3] = d1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        p2[3] = d2;
        return pairing(p1, p2);
    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

library PoseidonUnit1L {
    function poseidon(uint256[1] calldata) public pure returns (uint256) {}
}

library PoseidonUnit2L {
    function poseidon(uint256[2] calldata) public pure returns (uint256) {}
}

library PoseidonUnit3L {
    function poseidon(uint256[3] calldata) public pure returns (uint256) {}
}

library PoseidonUnit4L {
    function poseidon(uint256[4] calldata) public pure returns (uint256) {}
}

library PoseidonUnit5L {
    function poseidon(uint256[5] calldata) public pure returns (uint256) {}
}

library PoseidonUnit6L {
    function poseidon(uint256[6] calldata) public pure returns (uint256) {}
}

library SpongePoseidon {
    uint32 constant BATCH_SIZE = 6;

    function hash(uint256[] calldata values) public pure returns (uint256) {
        uint256[BATCH_SIZE] memory frame = [uint256(0), 0, 0, 0, 0, 0];
        bool dirty = false;
        uint256 fullHash = 0;
        uint32 k = 0;
        for (uint32 i = 0; i < values.length; i++) {
            dirty = true;
            frame[k] = values[i];
            if (k == BATCH_SIZE - 1) {
                fullHash = PoseidonUnit6L.poseidon(frame);
                dirty = false;
                frame = [uint256(0), 0, 0, 0, 0, 0];
                frame[0] = fullHash;
                k = 1;
            } else {
                k++;
            }
        }
        if (dirty) {
            // we haven't hashed something in the main sponge loop and need to do hash here
            fullHash = PoseidonUnit6L.poseidon(frame);
        }
        return fullHash;
    }
}

library PoseidonFacade {
    function poseidon1(uint256[1] calldata el) public pure returns (uint256) {
        return PoseidonUnit1L.poseidon(el);
    }

    function poseidon2(uint256[2] calldata el) public pure returns (uint256) {
        return PoseidonUnit2L.poseidon(el);
    }

    function poseidon3(uint256[3] calldata el) public pure returns (uint256) {
        return PoseidonUnit3L.poseidon(el);
    }

    function poseidon4(uint256[4] calldata el) public pure returns (uint256) {
        return PoseidonUnit4L.poseidon(el);
    }

    function poseidon5(uint256[5] calldata el) public pure returns (uint256) {
        return PoseidonUnit5L.poseidon(el);
    }

    function poseidon6(uint256[6] calldata el) public pure returns (uint256) {
        return PoseidonUnit6L.poseidon(el);
    }

    function poseidonSponge(uint256[] calldata el) public pure returns (uint256) {
        return SpongePoseidon.hash(el);
    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "./Poseidon.sol";
import "./ArrayUtils.sol";

/// @title A sparse merkle tree implementation, which keeps tree history.
// Note that this SMT implementation can manage duplicated roots in the history,
// which may happen when some leaf change its value and then changes it back to the original value.
// Leaves deletion is not supported, although it should be possible to implement it in the future
// versions of this library, without changing the existing state variables
// In this way all the SMT data may be preserved for the contracts already in production.
library SmtLib {
    /**
     * @dev Max return array length for SMT root history requests
     */
    uint256 public constant ROOT_INFO_LIST_RETURN_LIMIT = 1000;

    /**
     * @dev Max depth hard cap for SMT
     * We can't use depth > 256 because of bits number limitation in the uint256 data type.
     */
    uint256 public constant MAX_DEPTH_HARD_CAP = 256;

    /**
     * @dev Enum of SMT node types
     */
    enum NodeType {
        EMPTY,
        LEAF,
        MIDDLE
    }

    /**
     * @dev Sparse Merkle Tree data
     * Note that we count the SMT depth starting from 0, which is the root level.
     *
     * For example, the following tree has a maxDepth = 2:
     *
     *     O      <- root level (depth = 0)
     *    / \
     *   O   O    <- depth = 1
     *  / \ / \
     * O  O O  O  <- depth = 2
     */
    struct Data {
        mapping(uint256 => Node) nodes;
        RootEntry[] rootEntries;
        mapping(uint256 => uint256[]) rootIndexes; // root => rootEntryIndex[]
        uint256 maxDepth;
        bool initialized;
        // This empty reserved space is put in place to allow future versions
        // of the SMT library to add new Data struct fields without shifting down
        // storage of upgradable contracts that use this struct as a state variable
        // (see https://docs.openzeppelin.com/upgrades-plugins/1.x/writing-upgradeable#storage-gaps)
        uint256[45] __gap;
    }

    /**
     * @dev Struct of the node proof in the SMT.
     * @param root This SMT root.
     * @param existence A flag, which shows if the leaf index exists in the SMT.
     * @param siblings An array of SMT sibling node hashes.
     * @param index An index of the leaf in the SMT.
     * @param value A value of the leaf in the SMT.
     * @param auxExistence A flag, which shows if the auxiliary leaf exists in the SMT.
     * @param auxIndex An index of the auxiliary leaf in the SMT.
     * @param auxValue An value of the auxiliary leaf in the SMT.
     */
    struct Proof {
        uint256 root;
        bool existence;
        uint256[] siblings;
        uint256 index;
        uint256 value;
        bool auxExistence;
        uint256 auxIndex;
        uint256 auxValue;
    }

    /**
     * @dev Struct for SMT root internal storage representation.
     * @param root SMT root.
     * @param createdAtTimestamp A time, when the root was saved to blockchain.
     * @param createdAtBlock A number of block, when the root was saved to blockchain.
     */
    struct RootEntry {
        uint256 root;
        uint256 createdAtTimestamp;
        uint256 createdAtBlock;
    }

    /**
     * @dev Struct for public interfaces to represent SMT root info.
     * @param root This SMT root.
     * @param replacedByRoot A root, which replaced this root.
     * @param createdAtTimestamp A time, when the root was saved to blockchain.
     * @param replacedAtTimestamp A time, when the root was replaced by the next root in blockchain.
     * @param createdAtBlock A number of block, when the root was saved to blockchain.
     * @param replacedAtBlock A number of block, when the root was replaced by the next root in blockchain.
     */
    struct RootEntryInfo {
        uint256 root;
        uint256 replacedByRoot;
        uint256 createdAtTimestamp;
        uint256 replacedAtTimestamp;
        uint256 createdAtBlock;
        uint256 replacedAtBlock;
    }

    /**
     * @dev Struct of SMT node.
     * @param NodeType type of node.
     * @param childLeft left child of node.
     * @param childRight right child of node.
     * @param Index index of node.
     * @param Value value of node.
     */
    struct Node {
        NodeType nodeType;
        uint256 childLeft;
        uint256 childRight;
        uint256 index;
        uint256 value;
    }

    using BinarySearchSmtRoots for Data;
    using ArrayUtils for uint256[];

    /**
     * @dev Reverts if root does not exist in SMT roots history.
     * @param root SMT root.
     */
    modifier onlyExistingRoot(Data storage self, uint256 root) {
        require(rootExists(self, root), "Root does not exist");
        _;
    }

    /**
     * @dev Add a leaf to the SMT
     * @param i Index of a leaf
     * @param v Value of a leaf
     */
    function addLeaf(Data storage self, uint256 i, uint256 v) external onlyInitialized(self) {
        Node memory node = Node({
            nodeType: NodeType.LEAF,
            childLeft: 0,
            childRight: 0,
            index: i,
            value: v
        });

        uint256 prevRoot = getRoot(self);
        uint256 newRoot = _addLeaf(self, node, prevRoot, 0);

        _addEntry(self, newRoot, block.timestamp, block.number);
    }

    /**
     * @dev Get SMT root history length
     * @return SMT history length
     */
    function getRootHistoryLength(Data storage self) external view returns (uint256) {
        return self.rootEntries.length;
    }

    /**
     * @dev Get SMT root history
     * @param startIndex start index of history
     * @param length history length
     * @return array of RootEntryInfo structs
     */
    function getRootHistory(
        Data storage self,
        uint256 startIndex,
        uint256 length
    ) external view returns (RootEntryInfo[] memory) {
        (uint256 start, uint256 end) = ArrayUtils.calculateBounds(
            self.rootEntries.length,
            startIndex,
            length,
            ROOT_INFO_LIST_RETURN_LIMIT
        );

        RootEntryInfo[] memory result = new RootEntryInfo[](end - start);

        for (uint256 i = start; i < end; i++) {
            result[i - start] = _getRootInfoByIndex(self, i);
        }
        return result;
    }

    /**
     * @dev Get the SMT node by hash
     * @param nodeHash Hash of a node
     * @return A node struct
     */
    function getNode(Data storage self, uint256 nodeHash) public view returns (Node memory) {
        return self.nodes[nodeHash];
    }

    /**
     * @dev Get the proof if a node with specific index exists or not exists in the SMT.
     * @param index A node index.
     * @return SMT proof struct.
     */
    function getProof(Data storage self, uint256 index) external view returns (Proof memory) {
        return getProofByRoot(self, index, getRoot(self));
    }

    /**
     * @dev Get the proof if a node with specific index exists or not exists in the SMT for some historical tree state.
     * @param index A node index
     * @param historicalRoot Historical SMT roof to get proof for.
     * @return Proof struct.
     */
    function getProofByRoot(
        Data storage self,
        uint256 index,
        uint256 historicalRoot
    ) public view onlyExistingRoot(self, historicalRoot) returns (Proof memory) {
        uint256[] memory siblings = new uint256[](self.maxDepth);
        // Solidity does not guarantee that memory vars are zeroed out
        for (uint256 i = 0; i < self.maxDepth; i++) {
            siblings[i] = 0;
        }

        Proof memory proof = Proof({
            root: historicalRoot,
            existence: false,
            siblings: siblings,
            index: index,
            value: 0,
            auxExistence: false,
            auxIndex: 0,
            auxValue: 0
        });

        uint256 nextNodeHash = historicalRoot;
        Node memory node;

        for (uint256 i = 0; i <= self.maxDepth; i++) {
            node = getNode(self, nextNodeHash);
            if (node.nodeType == NodeType.EMPTY) {
                break;
            } else if (node.nodeType == NodeType.LEAF) {
                if (node.index == proof.index) {
                    proof.existence = true;
                    proof.value = node.value;
                    break;
                } else {
                    proof.auxExistence = true;
                    proof.auxIndex = node.index;
                    proof.auxValue = node.value;
                    proof.value = node.value;
                    break;
                }
            } else if (node.nodeType == NodeType.MIDDLE) {
                if ((proof.index >> i) & 1 == 1) {
                    nextNodeHash = node.childRight;
                    proof.siblings[i] = node.childLeft;
                } else {
                    nextNodeHash = node.childLeft;
                    proof.siblings[i] = node.childRight;
                }
            } else {
                revert("Invalid node type");
            }
        }
        return proof;
    }

    /**
     * @dev Get the proof if a node with specific index exists or not exists in the SMT by some historical timestamp.
     * @param index Node index.
     * @param timestamp The latest timestamp to get proof for.
     * @return Proof struct.
     */
    function getProofByTime(
        Data storage self,
        uint256 index,
        uint256 timestamp
    ) public view returns (Proof memory) {
        RootEntryInfo memory rootInfo = getRootInfoByTime(self, timestamp);
        return getProofByRoot(self, index, rootInfo.root);
    }

    /**
     * @dev Get the proof if a node with specific index exists or not exists in the SMT by some historical block number.
     * @param index Node index.
     * @param blockNumber The latest block number to get proof for.
     * @return Proof struct.
     */
    function getProofByBlock(
        Data storage self,
        uint256 index,
        uint256 blockNumber
    ) external view returns (Proof memory) {
        RootEntryInfo memory rootInfo = getRootInfoByBlock(self, blockNumber);
        return getProofByRoot(self, index, rootInfo.root);
    }

    function getRoot(Data storage self) public view onlyInitialized(self) returns (uint256) {
        return self.rootEntries[self.rootEntries.length - 1].root;
    }

    /**
     * @dev Get root info by some historical timestamp.
     * @param timestamp The latest timestamp to get the root info for.
     * @return Root info struct
     */
    function getRootInfoByTime(
        Data storage self,
        uint256 timestamp
    ) public view returns (RootEntryInfo memory) {
        require(timestamp <= block.timestamp, "No future timestamps allowed");

        return
            _getRootInfoByTimestampOrBlock(
                self,
                timestamp,
                BinarySearchSmtRoots.SearchType.TIMESTAMP
            );
    }

    /**
     * @dev Get root info by some historical block number.
     * @param blockN The latest block number to get the root info for.
     * @return Root info struct
     */
    function getRootInfoByBlock(
        Data storage self,
        uint256 blockN
    ) public view returns (RootEntryInfo memory) {
        require(blockN <= block.number, "No future blocks allowed");

        return _getRootInfoByTimestampOrBlock(self, blockN, BinarySearchSmtRoots.SearchType.BLOCK);
    }

    /**
     * @dev Returns root info by root
     * @param root root
     * @return Root info struct
     */
    function getRootInfo(
        Data storage self,
        uint256 root
    ) public view onlyExistingRoot(self, root) returns (RootEntryInfo memory) {
        uint256[] storage indexes = self.rootIndexes[root];
        uint256 lastIndex = indexes[indexes.length - 1];
        return _getRootInfoByIndex(self, lastIndex);
    }

    /**
     * @dev Retrieve duplicate root quantity by id and state.
     * If the root repeats more that once, the length may be greater than 1.
     * @param root A root.
     * @return Root root entries quantity.
     */
    function getRootInfoListLengthByRoot(
        Data storage self,
        uint256 root
    ) public view returns (uint256) {
        return self.rootIndexes[root].length;
    }

    /**
     * @dev Retrieve root infos list of duplicated root by id and state.
     * If the root repeats more that once, the length list may be greater than 1.
     * @param root A root.
     * @param startIndex The index to start the list.
     * @param length The length of the list.
     * @return Root Root entries quantity.
     */
    function getRootInfoListByRoot(
        Data storage self,
        uint256 root,
        uint256 startIndex,
        uint256 length
    ) public view onlyExistingRoot(self, root) returns (RootEntryInfo[] memory) {
        uint256[] storage indexes = self.rootIndexes[root];
        (uint256 start, uint256 end) = ArrayUtils.calculateBounds(
            indexes.length,
            startIndex,
            length,
            ROOT_INFO_LIST_RETURN_LIMIT
        );

        RootEntryInfo[] memory result = new RootEntryInfo[](end - start);
        for (uint256 i = start; i < end; i++) {
            result[i - start] = _getRootInfoByIndex(self, indexes[i]);
        }

        return result;
    }

    /**
     * @dev Checks if root exists
     * @param root root
     * return true if root exists
     */
    function rootExists(Data storage self, uint256 root) public view returns (bool) {
        return self.rootIndexes[root].length > 0;
    }

    /**
     * @dev Sets max depth of the SMT
     * @param maxDepth max depth
     */
    function setMaxDepth(Data storage self, uint256 maxDepth) public {
        require(maxDepth > 0, "Max depth must be greater than zero");
        require(maxDepth > self.maxDepth, "Max depth can only be increased");
        require(maxDepth <= MAX_DEPTH_HARD_CAP, "Max depth is greater than hard cap");
        self.maxDepth = maxDepth;
    }

    /**
     * @dev Gets max depth of the SMT
     * return max depth
     */
    function getMaxDepth(Data storage self) external view returns (uint256) {
        return self.maxDepth;
    }

    /**
     * @dev Initialize SMT with max depth and root entry of an empty tree.
     * @param maxDepth Max depth of the SMT.
     */
    function initialize(Data storage self, uint256 maxDepth) external {
        require(!isInitialized(self), "Smt is already initialized");
        setMaxDepth(self, maxDepth);
        _addEntry(self, 0, 0, 0);
        self.initialized = true;
    }

    modifier onlyInitialized(Data storage self) {
        require(isInitialized(self), "Smt is not initialized");
        _;
    }

    function isInitialized(Data storage self) public view returns (bool) {
        return self.initialized;
    }

    function _addLeaf(
        Data storage self,
        Node memory newLeaf,
        uint256 nodeHash,
        uint256 depth
    ) internal returns (uint256) {
        if (depth > self.maxDepth) {
            revert("Max depth reached");
        }

        Node memory node = self.nodes[nodeHash];
        uint256 nextNodeHash;
        uint256 leafHash = 0;

        if (node.nodeType == NodeType.EMPTY) {
            leafHash = _addNode(self, newLeaf);
        } else if (node.nodeType == NodeType.LEAF) {
            leafHash = node.index == newLeaf.index
                ? _addNode(self, newLeaf)
                : _pushLeaf(self, newLeaf, node, depth);
        } else if (node.nodeType == NodeType.MIDDLE) {
            Node memory newNodeMiddle;

            if ((newLeaf.index >> depth) & 1 == 1) {
                nextNodeHash = _addLeaf(self, newLeaf, node.childRight, depth + 1);

                newNodeMiddle = Node({
                    nodeType: NodeType.MIDDLE,
                    childLeft: node.childLeft,
                    childRight: nextNodeHash,
                    index: 0,
                    value: 0
                });
            } else {
                nextNodeHash = _addLeaf(self, newLeaf, node.childLeft, depth + 1);

                newNodeMiddle = Node({
                    nodeType: NodeType.MIDDLE,
                    childLeft: nextNodeHash,
                    childRight: node.childRight,
                    index: 0,
                    value: 0
                });
            }

            leafHash = _addNode(self, newNodeMiddle);
        }

        return leafHash;
    }

    function _pushLeaf(
        Data storage self,
        Node memory newLeaf,
        Node memory oldLeaf,
        uint256 depth
    ) internal returns (uint256) {
        // no reason to continue if we are at max possible depth
        // as, anyway, we exceed the depth going down the tree
        if (depth >= self.maxDepth) {
            revert("Max depth reached");
        }

        Node memory newNodeMiddle;
        bool newLeafBitAtDepth = (newLeaf.index >> depth) & 1 == 1;
        bool oldLeafBitAtDepth = (oldLeaf.index >> depth) & 1 == 1;

        // Check if we need to go deeper if diverge at the depth's bit
        if (newLeafBitAtDepth == oldLeafBitAtDepth) {
            uint256 nextNodeHash = _pushLeaf(self, newLeaf, oldLeaf, depth + 1);

            if (newLeafBitAtDepth) {
                // go right
                newNodeMiddle = Node(NodeType.MIDDLE, 0, nextNodeHash, 0, 0);
            } else {
                // go left
                newNodeMiddle = Node(NodeType.MIDDLE, nextNodeHash, 0, 0, 0);
            }
            return _addNode(self, newNodeMiddle);
        }

        if (newLeafBitAtDepth) {
            newNodeMiddle = Node({
                nodeType: NodeType.MIDDLE,
                childLeft: _getNodeHash(oldLeaf),
                childRight: _getNodeHash(newLeaf),
                index: 0,
                value: 0
            });
        } else {
            newNodeMiddle = Node({
                nodeType: NodeType.MIDDLE,
                childLeft: _getNodeHash(newLeaf),
                childRight: _getNodeHash(oldLeaf),
                index: 0,
                value: 0
            });
        }

        _addNode(self, newLeaf);
        return _addNode(self, newNodeMiddle);
    }

    function _addNode(Data storage self, Node memory node) internal returns (uint256) {
        uint256 nodeHash = _getNodeHash(node);
        // We don't have any guarantees if the hash function attached is good enough.
        // So, if the node hash already exists, we need to check
        // if the node in the tree exactly matches the one we are trying to add.
        if (self.nodes[nodeHash].nodeType != NodeType.EMPTY) {
            assert(self.nodes[nodeHash].nodeType == node.nodeType);
            assert(self.nodes[nodeHash].childLeft == node.childLeft);
            assert(self.nodes[nodeHash].childRight == node.childRight);
            assert(self.nodes[nodeHash].index == node.index);
            assert(self.nodes[nodeHash].value == node.value);
            return nodeHash;
        }

        self.nodes[nodeHash] = node;
        return nodeHash;
    }

    function _getNodeHash(Node memory node) internal view returns (uint256) {
        uint256 nodeHash = 0;
        if (node.nodeType == NodeType.LEAF) {
            uint256[3] memory params = [node.index, node.value, uint256(1)];
            nodeHash = PoseidonUnit3L.poseidon(params);
        } else if (node.nodeType == NodeType.MIDDLE) {
            nodeHash = PoseidonUnit2L.poseidon([node.childLeft, node.childRight]);
        }
        return nodeHash; // Note: expected to return 0 if NodeType.EMPTY, which is the only option left
    }

    function _getRootInfoByIndex(
        Data storage self,
        uint256 index
    ) internal view returns (RootEntryInfo memory) {
        bool isLastRoot = index == self.rootEntries.length - 1;
        RootEntry storage rootEntry = self.rootEntries[index];

        return
            RootEntryInfo({
                root: rootEntry.root,
                replacedByRoot: isLastRoot ? 0 : self.rootEntries[index + 1].root,
                createdAtTimestamp: rootEntry.createdAtTimestamp,
                replacedAtTimestamp: isLastRoot
                    ? 0
                    : self.rootEntries[index + 1].createdAtTimestamp,
                createdAtBlock: rootEntry.createdAtBlock,
                replacedAtBlock: isLastRoot ? 0 : self.rootEntries[index + 1].createdAtBlock
            });
    }

    function _getRootInfoByTimestampOrBlock(
        Data storage self,
        uint256 timestampOrBlock,
        BinarySearchSmtRoots.SearchType searchType
    ) internal view returns (RootEntryInfo memory) {
        (uint256 index, bool found) = self.binarySearchUint256(timestampOrBlock, searchType);

        // As far as we always have at least one root entry, we should always find it
        assert(found);

        return _getRootInfoByIndex(self, index);
    }

    function _addEntry(
        Data storage self,
        uint256 root,
        uint256 _timestamp,
        uint256 _block
    ) internal {
        self.rootEntries.push(
            RootEntry({root: root, createdAtTimestamp: _timestamp, createdAtBlock: _block})
        );

        self.rootIndexes[root].push(self.rootEntries.length - 1);
    }
}

/// @title A binary search for the sparse merkle tree root history
// Implemented as a separate library for testing purposes
library BinarySearchSmtRoots {
    /**
     * @dev Enum for the SMT history field selection
     */
    enum SearchType {
        TIMESTAMP,
        BLOCK
    }

    /**
     * @dev Binary search method for the SMT history,
     * which searches for the index of the root entry saved by the given timestamp or block
     * @param value The timestamp or block to search for.
     * @param searchType The type of the search (timestamp or block).
     */
    function binarySearchUint256(
        SmtLib.Data storage self,
        uint256 value,
        SearchType searchType
    ) internal view returns (uint256, bool) {
        if (self.rootEntries.length == 0) {
            return (0, false);
        }

        uint256 min = 0;
        uint256 max = self.rootEntries.length - 1;
        uint256 mid;

        while (min <= max) {
            mid = (max + min) / 2;

            uint256 midValue = fieldSelector(self.rootEntries[mid], searchType);
            if (midValue == value) {
                while (mid < self.rootEntries.length - 1) {
                    uint256 nextValue = fieldSelector(self.rootEntries[mid + 1], searchType);
                    if (nextValue == value) {
                        mid++;
                    } else {
                        return (mid, true);
                    }
                }
                return (mid, true);
            } else if (value > midValue) {
                min = mid + 1;
            } else if (value < midValue && mid > 0) {
                // mid > 0 is to avoid underflow
                max = mid - 1;
            } else {
                // This means that value < midValue && mid == 0. So we found nothing.
                return (0, false);
            }
        }

        // The case when the searched value does not exist and we should take the closest smaller value
        // Index in the "max" var points to the root entry with max value smaller than the searched value
        return (max, true);
    }

    /**
     * @dev Selects either timestamp or block field from the root entry struct
     * depending on the search type
     * @param rti The root entry to select the field from.
     * @param st The search type.
     */
    function fieldSelector(
        SmtLib.RootEntry memory rti,
        SearchType st
    ) internal pure returns (uint256) {
        if (st == SearchType.BLOCK) {
            return rti.createdAtBlock;
        } else if (st == SearchType.TIMESTAMP) {
            return rti.createdAtTimestamp;
        } else {
            revert("Invalid search type");
        }
    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "../lib/ArrayUtils.sol";

/// @title Library for state data management.
// It's purpose is to keep records of identity states along with their metadata and history.
library StateLib {
    /**
     * @dev Max return array length for id history requests
     */
    uint256 public constant ID_HISTORY_RETURN_LIMIT = 1000;

    /**
     * @dev Struct for public interfaces to represent a state information.
     * @param id identity.
     * @param state A state.
     * @param replacedByState A state, which replaced this state for the identity.
     * @param createdAtTimestamp A time when the state was created.
     * @param replacedAtTimestamp A time when the state was replaced by the next identity state.
     * @param createdAtBlock A block number when the state was created.
     * @param replacedAtBlock A block number when the state was replaced by the next identity state.
     */
    struct EntryInfo {
        uint256 id;
        uint256 state;
        uint256 replacedByState;
        uint256 createdAtTimestamp;
        uint256 replacedAtTimestamp;
        uint256 createdAtBlock;
        uint256 replacedAtBlock;
    }

    /**
     * @dev Struct for identity state internal storage representation.
     * @param state A state.
     * @param timestamp A time when the state was committed to blockchain.
     * @param block A block number when the state was committed to blockchain.
     */
    struct Entry {
        uint256 state;
        uint256 timestamp;
        uint256 block;
    }

    /**
     * @dev Struct for storing all the state data.
     * We assume that a state can repeat more than once for the same identity,
     * so we keep a mapping of state entries per each identity and state.
     * @param statesHistories A state history per each identity.
     * @param stateEntries A state metadata of each state.
     */
    struct Data {
        /*
        id => stateEntry[]
        --------------------------------
        id1 => [
            index 0: StateEntry1 {state1, timestamp2, block1},
            index 1: StateEntry2 {state2, timestamp2, block2},
            index 2: StateEntry3 {state1, timestamp3, block3}
        ]
        */
        mapping(uint256 => Entry[]) stateEntries;
        /*
        id => state => stateEntryIndex[]
        -------------------------------
        id1 => state1 => [index0, index2],
        id1 => state2 => [index1]
         */
        mapping(uint256 => mapping(uint256 => uint256[])) stateIndexes;
        // This empty reserved space is put in place to allow future versions
        // of the State contract to add new SmtData struct fields without shifting down
        // storage of upgradable contracts that use this struct as a state variable
        // (see https://docs.openzeppelin.com/upgrades-plugins/1.x/writing-upgradeable#storage-gaps)
        uint256[48] __gap;
    }

    /**
     * @dev event called when a state is updated
     * @param id identity
     * @param blockN Block number when the state has been committed
     * @param timestamp Timestamp when the state has been committed
     * @param state Identity state committed
     */
    event StateUpdated(uint256 id, uint256 blockN, uint256 timestamp, uint256 state);

    /**
     * @dev Revert if identity does not exist in the contract
     * @param id Identity
     */
    modifier onlyExistingId(Data storage self, uint256 id) {
        require(idExists(self, id), "Identity does not exist");
        _;
    }

    /**
     * @dev Revert if state does not exist in the contract
     * @param id Identity
     * @param state State
     */
    modifier onlyExistingState(
        Data storage self,
        uint256 id,
        uint256 state
    ) {
        require(stateExists(self, id, state), "State does not exist");
        _;
    }

    /**
     * @dev Add a state to the contract with transaction timestamp and block number.
     * @param id Identity
     * @param state State
     */
    function addState(Data storage self, uint256 id, uint256 state) external {
        _addState(self, id, state, block.timestamp, block.number);
    }

    /**
     * @dev Add a state to the contract with zero timestamp and block number.
     * @param id Identity
     * @param state State
     */
    function addGenesisState(Data storage self, uint256 id, uint256 state) external {
        require(
            !idExists(self, id),
            "Zero timestamp and block should be only in the first identity state"
        );
        _addState(self, id, state, 0, 0);
    }

    /**
     * @dev Retrieve the last state info for a given identity.
     * @param id Identity.
     * @return State info of the last committed state.
     */
    function getStateInfoById(
        Data storage self,
        uint256 id
    ) external view onlyExistingId(self, id) returns (EntryInfo memory) {
        Entry[] storage stateEntries = self.stateEntries[id];
        Entry memory se = stateEntries[stateEntries.length - 1];

        return
            EntryInfo({
                id: id,
                state: se.state,
                replacedByState: 0,
                createdAtTimestamp: se.timestamp,
                replacedAtTimestamp: 0,
                createdAtBlock: se.block,
                replacedAtBlock: 0
            });
    }

    /**
     * @dev Retrieve states quantity for a given identity
     * @param id identity
     * @return states quantity
     */
    function getStateInfoHistoryLengthById(
        Data storage self,
        uint256 id
    ) external view onlyExistingId(self, id) returns (uint256) {
        return self.stateEntries[id].length;
    }

    /**
     * Retrieve state infos for a given identity
     * @param id Identity
     * @param startIndex Start index of the state history.
     * @param length Max length of the state history retrieved.
     * @return A list of state infos of the identity
     */
    function getStateInfoHistoryById(
        Data storage self,
        uint256 id,
        uint256 startIndex,
        uint256 length
    ) external view onlyExistingId(self, id) returns (EntryInfo[] memory) {
        (uint256 start, uint256 end) = ArrayUtils.calculateBounds(
            self.stateEntries[id].length,
            startIndex,
            length,
            ID_HISTORY_RETURN_LIMIT
        );

        EntryInfo[] memory result = new EntryInfo[](end - start);

        for (uint256 i = start; i < end; i++) {
            result[i - start] = _getStateInfoByIndex(self, id, i);
        }

        return result;
    }

    /**
     * @dev Retrieve state info by id and state.
     * Note, that the latest state info is returned,
     * if the state repeats more that once for the same identity.
     * @param id An identity.
     * @param state A state.
     * @return The state info.
     */
    function getStateInfoByIdAndState(
        Data storage self,
        uint256 id,
        uint256 state
    ) external view onlyExistingState(self, id, state) returns (EntryInfo memory) {
        return _getStateInfoByState(self, id, state);
    }

    /**
     * @dev Retrieve state entries quantity by id and state.
     * If the state repeats more that once for the same identity,
     * the length will be greater than 1.
     * @param id An identity.
     * @param state A state.
     * @return The state info list length.
     */
    function getStateInfoListLengthByIdAndState(
        Data storage self,
        uint256 id,
        uint256 state
    ) external view returns (uint256) {
        return self.stateIndexes[id][state].length;
    }

    /**
     * @dev Retrieve state info list by id and state.
     * If the state repeats more that once for the same identity,
     * the length of the list may be greater than 1.
     * @param id An identity.
     * @param state A state.
     * @param startIndex Start index in the same states list.
     * @param length Max length of the state info list retrieved.
     * @return The state info list.
     */
    function getStateInfoListByIdAndState(
        Data storage self,
        uint256 id,
        uint256 state,
        uint256 startIndex,
        uint256 length
    ) external view onlyExistingState(self, id, state) returns (EntryInfo[] memory) {
        uint256[] storage stateIndexes = self.stateIndexes[id][state];
        (uint256 start, uint256 end) = ArrayUtils.calculateBounds(
            stateIndexes.length,
            startIndex,
            length,
            ID_HISTORY_RETURN_LIMIT
        );

        EntryInfo[] memory result = new EntryInfo[](end - start);
        for (uint256 i = start; i < end; i++) {
            result[i - start] = _getStateInfoByIndex(self, id, stateIndexes[i]);
        }

        return result;
    }

    /**
     * @dev Check if identity exists.
     * @param id Identity
     * @return True if the identity exists
     */
    function idExists(Data storage self, uint256 id) public view returns (bool) {
        return self.stateEntries[id].length > 0;
    }

    /**
     * @dev Check if state exists.
     * @param id Identity
     * @param state State
     * @return True if the state exists
     */
    function stateExists(Data storage self, uint256 id, uint256 state) public view returns (bool) {
        return self.stateIndexes[id][state].length > 0;
    }

    function _addState(
        Data storage self,
        uint256 id,
        uint256 state,
        uint256 _timestamp,
        uint256 _block
    ) internal {
        Entry[] storage stateEntries = self.stateEntries[id];

        stateEntries.push(Entry({state: state, timestamp: _timestamp, block: _block}));
        self.stateIndexes[id][state].push(stateEntries.length - 1);

        emit StateUpdated(id, _block, _timestamp, state);
    }

    /**
     * @dev Get state info by id and state without state existence check.
     * @param id Identity
     * @param state State
     * @return The state info
     */
    function _getStateInfoByState(
        Data storage self,
        uint256 id,
        uint256 state
    ) internal view returns (EntryInfo memory) {
        uint256[] storage indexes = self.stateIndexes[id][state];
        uint256 lastIndex = indexes[indexes.length - 1];
        return _getStateInfoByIndex(self, id, lastIndex);
    }

    function _getStateInfoByIndex(
        Data storage self,
        uint256 id,
        uint256 index
    ) internal view returns (EntryInfo memory) {
        bool isLastState = index == self.stateEntries[id].length - 1;
        Entry storage se = self.stateEntries[id][index];

        return
            EntryInfo({
                id: id,
                state: se.state,
                replacedByState: isLastState ? 0 : self.stateEntries[id][index + 1].state,
                createdAtTimestamp: se.timestamp,
                replacedAtTimestamp: isLastState ? 0 : self.stateEntries[id][index + 1].timestamp,
                createdAtBlock: se.block,
                replacedAtBlock: isLastState ? 0 : self.stateEntries[id][index + 1].block
            });
    }
}
//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// 2019 OKIMS
//      ported to solidity 0.6
//      fixed linter warnings
//      added requiere error messages
//
//
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "../lib/Pairing.sol";

contract VerifierMTP {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G1Point alfa1;
        Pairing.G2Point beta2;
        Pairing.G2Point gamma2;
        Pairing.G2Point delta2;
        Pairing.G1Point[] IC;
    }
    struct Proof {
        Pairing.G1Point A;
        Pairing.G2Point B;
        Pairing.G1Point C;
    }

    function verifyingKey() internal pure returns (VerifyingKey memory vk) {
        vk.alfa1 = Pairing.G1Point(
            20491192805390485299153009773594534940189261866228447918068658471970481763042,
            9383485363053290200918347156157836566562967994039712273449902621266178545958
        );

        vk.beta2 = Pairing.G2Point(
            [
                4252822878758300859123897981450591353533073413197771768651442665752259397132,
                6375614351688725206403948262868962793625744043794305715222011528459656738731
            ],
            [
                21847035105528745403288232691147584728191162732299865338377159692350059136679,
                10505242626370262277552901082094356697409835680220590971873171140371331206856
            ]
        );
        vk.gamma2 = Pairing.G2Point(
            [
                11559732032986387107991004021392285783925812861821192530917403151452391805634,
                10857046999023057135944570762232829481370756359578518086990519993285655852781
            ],
            [
                4082367875863433681332203403145435568316851327593401208105741076214120093531,
                8495653923123431417604973247489272438418190587263600148770280649306958101930
            ]
        );
        vk.delta2 = Pairing.G2Point(
            [
                10069053650952764050770858763214373754669660210324204774418789033662943009749,
                21107007358082136795614874512538836487771939470796762405748007366166733704104
            ],
            [
                4852486786898691455964846082763016922630372558821263656172370355988314898575,
                8559222867245112767064473074858818732424559824983124225374445082554790506808
            ]
        );
        vk.IC = new Pairing.G1Point[](12);

        vk.IC[0] = Pairing.G1Point(
            1313452981527053129337572951247197324361989034671138626745310268341512913566,
            15303507074060980322389491486850010383524156520378503449579570642767442684301
        );

        vk.IC[1] = Pairing.G1Point(
            19469759548582862041953210077461806234755067239635831761330214958262728102210,
            16182855449814336395630220912227600929619756764754084585163045607249874698864
        );

        vk.IC[2] = Pairing.G1Point(
            5328220111696630739082100852965753471276442277347833726730125705096477686086,
            18905255288005092837452154631677141443252188654645540166408868771529766552954
        );

        vk.IC[3] = Pairing.G1Point(
            10933184819912527903586676306361564765563053120720138042486726178048079682568,
            18280626518907496130958526005677563160967544228407334084744886760261543167298
        );

        vk.IC[4] = Pairing.G1Point(
            11558797904750992453617754478260603596631069504995139547656018378652112039786,
            7387560020132856716152855364841368262707029595898949014465420811988605836841
        );

        vk.IC[5] = Pairing.G1Point(
            258345740540242369340676522345540363903777759573849221853370493977314124714,
            8261745575084416750025555445617776886593428107172740509334601364674159098729
        );

        vk.IC[6] = Pairing.G1Point(
            12229618381132244012134195568281704584580345418094236823704672151870483088680,
            19652481126909183227792433955062439643525977794731426347743513078747968248518
        );

        vk.IC[7] = Pairing.G1Point(
            21501269229626602828017941470237394838663343517747470934919163514713566489074,
            10918047203423236169474519778878366520860074771272087858656960949070403283927
        );

        vk.IC[8] = Pairing.G1Point(
            560417708851693272956571111854350209791303214876197214262570647517120871869,
            188344482860559912840076092213437046073780559836275799283864998836054113147
        );

        vk.IC[9] = Pairing.G1Point(
            12941763790218889190383140140219843141955553218417052891852216993045901023120,
            12682291388476462975465775054567905896202239758296039216608811622228355512204
        );

        vk.IC[10] = Pairing.G1Point(
            11112576039136275785110528933884279009037779878785871940581425517795519742410,
            6613377654128709188004788921975143848004552607600543819185067176149822253345
        );

        vk.IC[11] = Pairing.G1Point(
            13613305841160720689914712433320508347546323189059844660259139894452538774575,
            5325101314795154200638690464360192908052407201796948025470533168336651686116
        );
    }

    function verify(uint[] memory input, Proof memory proof) internal view returns (uint) {
        uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.IC.length, "verifier-bad-input");
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++) {
            require(input[i] < snark_scalar_field, "verifier-gte-snark-scalar-field");
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.IC[i + 1], input[i]));
        }
        vk_x = Pairing.addition(vk_x, vk.IC[0]);
        if (
            !Pairing.pairingProd4(
                Pairing.negate(proof.A),
                proof.B,
                vk.alfa1,
                vk.beta2,
                vk_x,
                vk.gamma2,
                proof.C,
                vk.delta2
            )
        ) return 1;
        return 0;
    }

    /// @return r  bool true if proof is valid
    function verifyProof(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[11] memory input
    ) public view returns (bool r) {
        // slither-disable-next-line uninitialized-local
        Proof memory proof;
        proof.A = Pairing.G1Point(a[0], a[1]);
        proof.B = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.C = Pairing.G1Point(c[0], c[1]);
        uint[] memory inputValues = new uint[](input.length);
        for (uint i = 0; i < input.length; i++) {
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            return true;
        } else {
            return false;
        }
    }
}
//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// 2019 OKIMS
//      ported to solidity 0.6
//      fixed linter warnings
//      added requiere error messages
//
//
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "../lib/Pairing.sol";

contract VerifierSig {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G1Point alfa1;
        Pairing.G2Point beta2;
        Pairing.G2Point gamma2;
        Pairing.G2Point delta2;
        Pairing.G1Point[] IC;
    }
    struct Proof {
        Pairing.G1Point A;
        Pairing.G2Point B;
        Pairing.G1Point C;
    }

    function verifyingKey() internal pure returns (VerifyingKey memory vk) {
        vk.alfa1 = Pairing.G1Point(
            20491192805390485299153009773594534940189261866228447918068658471970481763042,
            9383485363053290200918347156157836566562967994039712273449902621266178545958
        );

        vk.beta2 = Pairing.G2Point(
            [
                4252822878758300859123897981450591353533073413197771768651442665752259397132,
                6375614351688725206403948262868962793625744043794305715222011528459656738731
            ],
            [
                21847035105528745403288232691147584728191162732299865338377159692350059136679,
                10505242626370262277552901082094356697409835680220590971873171140371331206856
            ]
        );
        vk.gamma2 = Pairing.G2Point(
            [
                11559732032986387107991004021392285783925812861821192530917403151452391805634,
                10857046999023057135944570762232829481370756359578518086990519993285655852781
            ],
            [
                4082367875863433681332203403145435568316851327593401208105741076214120093531,
                8495653923123431417604973247489272438418190587263600148770280649306958101930
            ]
        );
        vk.delta2 = Pairing.G2Point(
            [
                9233349870741476556654282208992970742179487991957579201151126362431960413225,
                1710121669395829903049554646654548770025644546791991387060028241346751736139
            ],
            [
                19704486125052989683894847401785081114275457166241990059352921424459992638027,
                19046562201477515176875600774989213534306185878886204544239016053798985855692
            ]
        );
        vk.IC = new Pairing.G1Point[](12);

        vk.IC[0] = Pairing.G1Point(
            4329040981391513141295391766415175655220156497739526881302609278948222504970,
            284608453342683033767670137533198892462004759449479316068661948021384180405
        );

        vk.IC[1] = Pairing.G1Point(
            7902292650777562978905160367453874788768779199030594846897219439327408939067,
            10012458713202587447931138874528085940712240664721354058270362630899015322036
        );

        vk.IC[2] = Pairing.G1Point(
            11697814597341170748167341793832824505245257771165671796257313346092824905883,
            5174781854368103007061208391170453909797905136821147372441461132562334328215
        );

        vk.IC[3] = Pairing.G1Point(
            1726927835877229859131056157678822776962440564906076714962505486421376544987,
            7352133740317971386526986860674287355620937922375271614467789385331477610856
        );

        vk.IC[4] = Pairing.G1Point(
            9990035903997574691712818787908054784756674039249764811431700936009293741830,
            4755447104942954158928166153067753327016299728030535979210293681329469052797
        );

        vk.IC[5] = Pairing.G1Point(
            15940583140274302050208676622092202988851114679125808597061574700878232173357,
            7533895757575770389928466511298564722397429905987255823784436733572909906714
        );

        vk.IC[6] = Pairing.G1Point(
            5508259264227278997738923725524430810437674978357251435507761322739607112981,
            14840270001783263053608712412057782257449606192737461326359694374707752442879
        );

        vk.IC[7] = Pairing.G1Point(
            19432593446453142673661052218577694238117210547713431221983638840685247652932,
            16697624670306221047608606229322371623883167253922210155632497282220974839920
        );

        vk.IC[8] = Pairing.G1Point(
            6174854815751106275031120096370935217144939918507999853315484754500615715470,
            3190247589562983462928111436181764721696742385815918920518303351200817921520
        );

        vk.IC[9] = Pairing.G1Point(
            20417210161225663628251386960452026588766551723348342467498648706108529814968,
            13308394646519897771630385644245620946922357621078786238887021263713833144471
        );

        vk.IC[10] = Pairing.G1Point(
            1439721648429120110444974852972369847408183115096685822065827204634576313044,
            7403516047177423709103114106022932360673171438277930001711953991194526055082
        );

        vk.IC[11] = Pairing.G1Point(
            18655728389101903942401016308093091046804775184674794685591712671240928471338,
            15349580464155803523251530156943886363594022485425879189715213626172422717967
        );
    }

    function verify(uint[] memory input, Proof memory proof) internal view returns (uint) {
        uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.IC.length, "verifier-bad-input");
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++) {
            require(input[i] < snark_scalar_field, "verifier-gte-snark-scalar-field");
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.IC[i + 1], input[i]));
        }
        vk_x = Pairing.addition(vk_x, vk.IC[0]);
        if (
            !Pairing.pairingProd4(
                Pairing.negate(proof.A),
                proof.B,
                vk.alfa1,
                vk.beta2,
                vk_x,
                vk.gamma2,
                proof.C,
                vk.delta2
            )
        ) return 1;
        return 0;
    }

    /// @return r  bool true if proof is valid
    function verifyProof(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[11] memory input
    ) public view returns (bool r) {
        // slither-disable-next-line uninitialized-local
        Proof memory proof;
        proof.A = Pairing.G1Point(a[0], a[1]);
        proof.B = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.C = Pairing.G1Point(c[0], c[1]);
        uint[] memory inputValues = new uint[](input.length);
        for (uint i = 0; i < input.length; i++) {
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            return true;
        } else {
            return false;
        }
    }
}
//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// 2019 OKIMS
//      ported to solidity 0.6
//      fixed linter warnings
//      added requiere error messages
//
//
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "../lib/Pairing.sol";
import "../interfaces/IStateTransitionVerifier.sol";

contract VerifierV2 is IStateTransitionVerifier {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G1Point alfa1;
        Pairing.G2Point beta2;
        Pairing.G2Point gamma2;
        Pairing.G2Point delta2;
        Pairing.G1Point[] IC;
    }
    struct Proof {
        Pairing.G1Point A;
        Pairing.G2Point B;
        Pairing.G1Point C;
    }

    function verifyingKey() internal pure returns (VerifyingKey memory vk) {
        vk.alfa1 = Pairing.G1Point(
            20491192805390485299153009773594534940189261866228447918068658471970481763042,
            9383485363053290200918347156157836566562967994039712273449902621266178545958
        );

        vk.beta2 = Pairing.G2Point(
            [
                4252822878758300859123897981450591353533073413197771768651442665752259397132,
                6375614351688725206403948262868962793625744043794305715222011528459656738731
            ],
            [
                21847035105528745403288232691147584728191162732299865338377159692350059136679,
                10505242626370262277552901082094356697409835680220590971873171140371331206856
            ]
        );
        vk.gamma2 = Pairing.G2Point(
            [
                11559732032986387107991004021392285783925812861821192530917403151452391805634,
                10857046999023057135944570762232829481370756359578518086990519993285655852781
            ],
            [
                4082367875863433681332203403145435568316851327593401208105741076214120093531,
                8495653923123431417604973247489272438418190587263600148770280649306958101930
            ]
        );
        vk.delta2 = Pairing.G2Point(
            [
                4246152484702050277565132335408650010216666048103975186858037423667921011245,
                11761106885383518720174451196687963724495127702612880995502231202411849421701
            ],
            [
                20662719780693521898375922787282175696841448037933826627867273008735335783602,
                9540218714987219778576059617464635889429392349728954857252076100095683267633
            ]
        );
        vk.IC = new Pairing.G1Point[](5);

        vk.IC[0] = Pairing.G1Point(
            16043291973889324756617069487195476149512574727363051659112556958735977616725,
            16864605224185193093062266789812233298859884301538621362226822022081041278677
        );

        vk.IC[1] = Pairing.G1Point(
            15935621905201691307201070923038920580506689594547556653696264182846970978554,
            20793947184131761785325026067954699416249353321530615459908048240252442935417
        );

        vk.IC[2] = Pairing.G1Point(
            15873695673932800019757092006642463598109301274410205214955538808836281067900,
            13581010826645089044340117513778871694012835043547906854734814490388643425494
        );

        vk.IC[3] = Pairing.G1Point(
            436067793811322464859758359330968701378288169738014324837094148538366747065,
            5184689509856778472522887232562113210294765146488556347841833551753176606959
        );

        vk.IC[4] = Pairing.G1Point(
            1580946655352989990810599848244095954566838172532565943008224849077018394283,
            8901953775389474246223858845884219088656635610469822712500097959042485592148
        );
    }

    function verify(uint[] memory input, Proof memory proof) internal view returns (uint) {
        uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.IC.length, "verifier-bad-input");
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++) {
            require(input[i] < snark_scalar_field, "verifier-gte-snark-scalar-field");
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.IC[i + 1], input[i]));
        }
        vk_x = Pairing.addition(vk_x, vk.IC[0]);
        if (
            !Pairing.pairingProd4(
                Pairing.negate(proof.A),
                proof.B,
                vk.alfa1,
                vk.beta2,
                vk_x,
                vk.gamma2,
                proof.C,
                vk.delta2
            )
        ) return 1;
        return 0;
    }

    /// @return r  bool true if proof is valid
    function verifyProof(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[4] memory input
    ) public view returns (bool r) {
        // slither-disable-next-line uninitialized-local
        Proof memory proof;
        proof.A = Pairing.G1Point(a[0], a[1]);
        proof.B = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.C = Pairing.G1Point(c[0], c[1]);
        uint[] memory inputValues = new uint[](input.length);
        for (uint i = 0; i < input.length; i++) {
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            return true;
        } else {
            return false;
        }
    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import "../interfaces/IState.sol";
import "../interfaces/IStateTransitionVerifier.sol";
import "../lib/SmtLib.sol";
import "../lib/Poseidon.sol";
import "../lib/StateLib.sol";

/// @title Set and get states for each identity
contract StateV2 is Ownable2StepUpgradeable, IState {
    /**
     * @dev Version of contract
     */
    string public constant VERSION = "2.1.0";

    // This empty reserved space is put in place to allow future versions
    // of the State contract to inherit from other contracts without a risk of
    // breaking the storage layout. This is necessary because the parent contracts in the
    // future may introduce some storage variables, which are placed before the State
    // contract's storage variables.
    // (see https://docs.openzeppelin.com/upgrades-plugins/1.x/writing-upgradeable#storage-gaps)
    // slither-disable-next-line shadowing-state
    // slither-disable-next-line unused-state
    uint256[500] private __gap;

    /**
     * @dev Verifier address
     */
    IStateTransitionVerifier internal verifier;

    /**
     * @dev State data
     */
    StateLib.Data internal _stateData;

    /**
     * @dev Global Identity State Tree (GIST) data
     */
    SmtLib.Data internal _gistData;

    using SmtLib for SmtLib.Data;
    using StateLib for StateLib.Data;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @dev Initialize the contract
     * @param verifierContractAddr Verifier address
     */
    function initialize(IStateTransitionVerifier verifierContractAddr) public initializer {
        verifier = verifierContractAddr;
        _gistData.initialize(MAX_SMT_DEPTH);
        __Ownable_init();
    }

    /**
     * @dev Set ZKP verifier contract address
     * @param newVerifierAddr Verifier contract address
     */
    function setVerifier(address newVerifierAddr) external onlyOwner {
        verifier = IStateTransitionVerifier(newVerifierAddr);
    }

    /**
     * @dev Change the state of an identity (transit to the new state) with ZKP ownership check.
     * @param id Identity
     * @param oldState Previous identity state
     * @param newState New identity state
     * @param isOldStateGenesis Is the previous state genesis?
     * @param a ZKP proof field
     * @param b ZKP proof field
     * @param c ZKP proof field
     */
    function transitState(
        uint256 id,
        uint256 oldState,
        uint256 newState,
        bool isOldStateGenesis,
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c
    ) external {
        require(id != 0, "ID should not be zero");
        require(newState != 0, "New state should not be zero");
        require(!stateExists(id, newState), "New state already exists");

        if (isOldStateGenesis) {
            require(!idExists(id), "Old state is genesis but identity already exists");

            // Push old state to state entries, with zero timestamp and block
            _stateData.addGenesisState(id, oldState);
        } else {
            require(idExists(id), "Old state is not genesis but identity does not yet exist");

            StateLib.EntryInfo memory prevStateInfo = _stateData.getStateInfoById(id);
            require(
                prevStateInfo.createdAtBlock != block.number,
                "No multiple set in the same block"
            );
            require(prevStateInfo.state == oldState, "Old state does not match the latest state");
        }

        uint256[4] memory input = [id, oldState, newState, uint256(isOldStateGenesis ? 1 : 0)];
        require(
            verifier.verifyProof(a, b, c, input),
            "Zero-knowledge proof of state transition is not valid"
        );

        _stateData.addState(id, newState);
        _gistData.addLeaf(PoseidonUnit1L.poseidon([id]), newState);
    }

    /**
     * @dev Get ZKP verifier contract address
     * @return verifier contract address
     */
    function getVerifier() external view returns (address) {
        return address(verifier);
    }

    /**
     * @dev Retrieve the last state info for a given identity
     * @param id identity
     * @return state info of the last committed state
     */
    function getStateInfoById(uint256 id) external view returns (IState.StateInfo memory) {
        return _stateEntryInfoAdapter(_stateData.getStateInfoById(id));
    }

    /**
     * @dev Retrieve states quantity for a given identity
     * @param id identity
     * @return states quantity
     */
    function getStateInfoHistoryLengthById(uint256 id) external view returns (uint256) {
        return _stateData.getStateInfoHistoryLengthById(id);
    }

    /**
     * Retrieve state infos for a given identity
     * @param id identity
     * @param startIndex start index of the state history
     * @param length length of the state history
     * @return A list of state infos of the identity
     */
    function getStateInfoHistoryById(
        uint256 id,
        uint256 startIndex,
        uint256 length
    ) external view returns (IState.StateInfo[] memory) {
        StateLib.EntryInfo[] memory stateInfos = _stateData.getStateInfoHistoryById(
            id,
            startIndex,
            length
        );
        IState.StateInfo[] memory result = new IState.StateInfo[](stateInfos.length);
        for (uint256 i = 0; i < stateInfos.length; i++) {
            result[i] = _stateEntryInfoAdapter(stateInfos[i]);
        }
        return result;
    }

    /**
     * @dev Retrieve state information by id and state.
     * @param id An identity.
     * @param state A state.
     * @return The state info.
     */
    function getStateInfoByIdAndState(
        uint256 id,
        uint256 state
    ) external view returns (IState.StateInfo memory) {
        return _stateEntryInfoAdapter(_stateData.getStateInfoByIdAndState(id, state));
    }

    /**
     * @dev Retrieve GIST inclusion or non-inclusion proof for a given identity.
     * @param id Identity
     * @return The GIST inclusion or non-inclusion proof for the identity
     */
    function getGISTProof(uint256 id) external view returns (IState.GistProof memory) {
        return _smtProofAdapter(_gistData.getProof(PoseidonUnit1L.poseidon([id])));
    }

    /**
     * @dev Retrieve GIST inclusion or non-inclusion proof for a given identity for
     * some GIST root in the past.
     * @param id Identity
     * @param root GIST root
     * @return The GIST inclusion or non-inclusion proof for the identity
     */
    function getGISTProofByRoot(
        uint256 id,
        uint256 root
    ) external view returns (IState.GistProof memory) {
        return _smtProofAdapter(_gistData.getProofByRoot(PoseidonUnit1L.poseidon([id]), root));
    }

    /**
     * @dev Retrieve GIST inclusion or non-inclusion proof for a given identity
     * for GIST latest snapshot by the block number provided.
     * @param id Identity
     * @param blockNumber Blockchain block number
     * @return The GIST inclusion or non-inclusion proof for the identity
     */
    function getGISTProofByBlock(
        uint256 id,
        uint256 blockNumber
    ) external view returns (IState.GistProof memory) {
        return
            _smtProofAdapter(_gistData.getProofByBlock(PoseidonUnit1L.poseidon([id]), blockNumber));
    }

    /**
     * @dev Retrieve GIST inclusion or non-inclusion proof for a given identity
     * for GIST latest snapshot by the blockchain timestamp provided.
     * @param id Identity
     * @param timestamp Blockchain timestamp
     * @return The GIST inclusion or non-inclusion proof for the identity
     */
    function getGISTProofByTime(
        uint256 id,
        uint256 timestamp
    ) external view returns (IState.GistProof memory) {
        return _smtProofAdapter(_gistData.getProofByTime(PoseidonUnit1L.poseidon([id]), timestamp));
    }

    /**
     * @dev Retrieve GIST latest root.
     * @return The latest GIST root
     */
    function getGISTRoot() external view returns (uint256) {
        return _gistData.getRoot();
    }

    /**
     * @dev Retrieve the GIST root history.
     * @param start Start index in the root history
     * @param length Length of the root history
     * @return Array of GIST roots infos
     */
    function getGISTRootHistory(
        uint256 start,
        uint256 length
    ) external view returns (IState.GistRootInfo[] memory) {
        SmtLib.RootEntryInfo[] memory rootInfos = _gistData.getRootHistory(start, length);
        IState.GistRootInfo[] memory result = new IState.GistRootInfo[](rootInfos.length);

        for (uint256 i = 0; i < rootInfos.length; i++) {
            result[i] = _smtRootInfoAdapter(rootInfos[i]);
        }
        return result;
    }

    /**
     * @dev Retrieve the length of the GIST root history.
     * @return The GIST root history length
     */
    function getGISTRootHistoryLength() external view returns (uint256) {
        return _gistData.rootEntries.length;
    }

    /**
     * @dev Retrieve the specific GIST root information.
     * @param root GIST root.
     * @return The GIST root information.
     */
    function getGISTRootInfo(uint256 root) external view returns (IState.GistRootInfo memory) {
        return _smtRootInfoAdapter(_gistData.getRootInfo(root));
    }

    /**
     * @dev Retrieve the GIST root information, which is latest by the block provided.
     * @param blockNumber Blockchain block number
     * @return The GIST root info
     */
    function getGISTRootInfoByBlock(
        uint256 blockNumber
    ) external view returns (IState.GistRootInfo memory) {
        return _smtRootInfoAdapter(_gistData.getRootInfoByBlock(blockNumber));
    }

    /**
     * @dev Retrieve the GIST root information, which is latest by the blockchain timestamp provided.
     * @param timestamp Blockchain timestamp
     * @return The GIST root info
     */
    function getGISTRootInfoByTime(
        uint256 timestamp
    ) external view returns (IState.GistRootInfo memory) {
        return _smtRootInfoAdapter(_gistData.getRootInfoByTime(timestamp));
    }

    /**
     * @dev Check if identity exists.
     * @param id Identity
     * @return True if the identity exists
     */
    function idExists(uint256 id) public view returns (bool) {
        return _stateData.idExists(id);
    }

    /**
     * @dev Check if state exists.
     * @param id Identity
     * @param state State
     * @return True if the state exists
     */
    function stateExists(uint256 id, uint256 state) public view returns (bool) {
        return _stateData.stateExists(id, state);
    }

    function _smtProofAdapter(
        SmtLib.Proof memory proof
    ) internal pure returns (IState.GistProof memory) {
        // slither-disable-next-line uninitialized-local
        uint256[MAX_SMT_DEPTH] memory siblings;
        for (uint256 i = 0; i < MAX_SMT_DEPTH; i++) {
            siblings[i] = proof.siblings[i];
        }

        IState.GistProof memory result = IState.GistProof({
            root: proof.root,
            existence: proof.existence,
            siblings: siblings,
            index: proof.index,
            value: proof.value,
            auxExistence: proof.auxExistence,
            auxIndex: proof.auxIndex,
            auxValue: proof.auxValue
        });

        return result;
    }

    function _smtRootInfoAdapter(
        SmtLib.RootEntryInfo memory rootInfo
    ) internal pure returns (IState.GistRootInfo memory) {
        return
            IState.GistRootInfo({
                root: rootInfo.root,
                replacedByRoot: rootInfo.replacedByRoot,
                createdAtTimestamp: rootInfo.createdAtTimestamp,
                replacedAtTimestamp: rootInfo.replacedAtTimestamp,
                createdAtBlock: rootInfo.createdAtBlock,
                replacedAtBlock: rootInfo.replacedAtBlock
            });
    }

    function _stateEntryInfoAdapter(
        StateLib.EntryInfo memory sei
    ) internal pure returns (IState.StateInfo memory) {
        return
            IState.StateInfo({
                id: sei.id,
                state: sei.state,
                replacedByState: sei.replacedByState,
                createdAtTimestamp: sei.createdAtTimestamp,
                replacedAtTimestamp: sei.replacedAtTimestamp,
                createdAtBlock: sei.createdAtBlock,
                replacedAtBlock: sei.replacedAtBlock
            });
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (access/Ownable2Step.sol)

pragma solidity ^0.8.0;

import "./OwnableUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which provides access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership} and {acceptOwnership}.
 *
 * This module is used through inheritance. It will make available all functions
 * from parent (Ownable).
 */
abstract contract Ownable2StepUpgradeable is Initializable, OwnableUpgradeable {
    function __Ownable2Step_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable2Step_init_unchained() internal onlyInitializing {
    }
    address private _pendingOwner;

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner(), newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`) and deletes any pending owner.
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual override {
        delete _pendingOwner;
        super._transferOwnership(newOwner);
    }

    /**
     * @dev The new owner accepts the ownership transfer.
     */
    function acceptOwnership() external {
        address sender = _msgSender();
        require(pendingOwner() == sender, "Ownable2Step: caller is not the new owner");
        _transferOwnership(sender);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.1) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822Proxiable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.3) (interfaces/IERC1967.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC-1967: Proxy Storage Slots. This interface contains the events defined in the ERC.
 *
 * _Available since v4.9._
 */
interface IERC1967 {
    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Emitted when the beacon is changed.
     */
    event BeaconUpgraded(address indexed beacon);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeacon {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/ERC1967/ERC1967Proxy.sol)

pragma solidity ^0.8.0;

import "../Proxy.sol";
import "./ERC1967Upgrade.sol";

/**
 * @dev This contract implements an upgradeable proxy. It is upgradeable because calls are delegated to an
 * implementation address that can be changed. This address is stored in storage in the location specified by
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967], so that it doesn't conflict with the storage layout of the
 * implementation behind the proxy.
 */
contract ERC1967Proxy is Proxy, ERC1967Upgrade {
    /**
     * @dev Initializes the upgradeable proxy with an initial implementation specified by `_logic`.
     *
     * If `_data` is nonempty, it's used as data in a delegate call to `_logic`. This will typically be an encoded
     * function call, and allows initializing the storage of the proxy like a Solidity constructor.
     */
    constructor(address _logic, bytes memory _data) payable {
        _upgradeToAndCall(_logic, _data, false);
    }

    /**
     * @dev Returns the current implementation address.
     */
    function _implementation() internal view virtual override returns (address impl) {
        return ERC1967Upgrade._getImplementation();
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.3) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeacon.sol";
import "../../interfaces/IERC1967.sol";
import "../../interfaces/draft-IERC1822.sol";
import "../../utils/Address.sol";
import "../../utils/StorageSlot.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967Upgrade is IERC1967 {
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlot.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822Proxiable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(Address.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            Address.isContract(IBeacon(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/Proxy.sol)

pragma solidity ^0.8.0;

/**
 * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM
 * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to
 * be specified by overriding the virtual {_implementation} function.
 *
 * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a
 * different contract through the {_delegate} function.
 *
 * The success and return data of the delegated call will be returned back to the caller of the proxy.
 */
abstract contract Proxy {
    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal virtual {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /**
     * @dev This is a virtual function that should be overridden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    function _implementation() internal view virtual returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable virtual {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive() external payable virtual {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overridden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {}
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.1) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/Address.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!Address.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (proxy/utils/UUPSUpgradeable.sol)

pragma solidity ^0.8.0;

import "../../interfaces/draft-IERC1822.sol";
import "../ERC1967/ERC1967Upgrade.sol";

/**
 * @dev An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
 * {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 *
 * A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
 * reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
 * `UUPSUpgradeable` with a custom implementation of upgrades.
 *
 * The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
 *
 * _Available since v4.1._
 */
abstract contract UUPSUpgradeable is IERC1822Proxiable, ERC1967Upgrade {
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }

    /**
     * @dev Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the
     * implementation. It is used to validate the implementation's compatibility when performing an upgrade.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.
     */
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeTo} and {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal override onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV // Deprecated in v4.8
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Tree proofs.
 *
 * The tree and the proofs can be generated using our
 * https://github.com/OpenZeppelin/merkle-tree[JavaScript library].
 * You will find a quickstart guide in the readme.
 *
 * WARNING: You should avoid using leaf values that are 64 bytes long prior to
 * hashing, or use a hash function other than keccak256 for hashing leaves.
 * This is because the concatenation of a sorted pair of internal nodes in
 * the merkle tree could be reinterpreted as a leaf value.
 * OpenZeppelin's JavaScript library generates merkle trees that are safe
 * against this attack out of the box.
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Calldata version of {verify}
     *
     * _Available since v4.7._
     */
    function verifyCalldata(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProofCalldata(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Calldata version of {processProof}
     *
     * _Available since v4.7._
     */
    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a merkle tree defined by
     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function multiProofVerify(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProof(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Calldata version of {multiProofVerify}
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function multiProofVerifyCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProofCalldata(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Returns the root of a tree reconstructed from `leaves` and sibling nodes in `proof`. The reconstruction
     * proceeds by incrementally reconstructing all inner nodes by combining a leaf/inner node with either another
     * leaf/inner node or a proof sibling node, depending on whether each `proofFlags` item is true or false
     * respectively.
     *
     * CAUTION: Not all merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree
     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the
     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).
     *
     * _Available since v4.7._
     */
    function processMultiProof(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuild the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value for the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i] ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++] : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            return hashes[totalHashes - 1];
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    /**
     * @dev Calldata version of {processMultiProof}.
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function processMultiProofCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuild the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value for the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i] ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++] : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            return hashes[totalHashes - 1];
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/Math.sol";

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";

abstract contract UUPSSignableUpgradeable is UUPSUpgradeable {
    function _authorizeUpgrade(
        address newImplementation_,
        bytes calldata signature_
    ) internal virtual;

    function upgradeToWithSig(
        address newImplementation_,
        bytes calldata signature_
    ) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation_, signature_);
        _upgradeToAndCallUUPS(newImplementation_, new bytes(0), false);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../handlers/IERC20Handler.sol";
import "../handlers/IERC721Handler.sol";
import "../handlers/ISBTHandler.sol";
import "../handlers/IERC1155Handler.sol";
import "../handlers/INativeHandler.sol";
import "../utils/ISigners.sol";

/**
 * @notice The Bridge contract
 *
 * The Bridge contract acts as a permissioned way of transferring assets (ERC20, ERC721, ERC1155, Native) between
 * 2 different blockchains.
 *
 * In order to correctly use the Bridge, one has to deploy both instances of the contract on the base chain and the
 * destination chain, as well as setup a trusted backend that will act as a `signer`.
 *
 * Each Bridge contract can either give or take the user assets when they want to transfer tokens. Both liquidity pool
 * and mint-and-burn way of transferring assets are supported.
 *
 * The bridge enables the transaction bundling feature as well.
 */
interface IBridge is
    IBundler,
    ISigners,
    IERC20Handler,
    IERC721Handler,
    ISBTHandler,
    IERC1155Handler,
    INativeHandler
{
    /**
     * @notice the enum that helps distinguish functions for calling within the signature
     * @param None the special zero type, method types start from 1
     * @param AuthorizeUpgrade the type corresponding to the _authorizeUpgrade function
     * @param ChangeBundleExecutorImplementation the type corresponding to the changeBundleExecutorImplementation function
     * @param ChangeFacade the type corresponding to the changeFacade function
     */
    enum MethodId {
        None,
        AuthorizeUpgrade,
        ChangeBundleExecutorImplementation,
        ChangeFacade
    }

    /**
     * @notice the function to verify merkle leaf
     * @param tokenDataLeaf_ the abi encoded token parameters
     * @param bundle_ the encoded transaction bundle with encoded salt
     * @param originHash_ the keccak256 hash of abi.encodePacked(origin chain name . origin tx hash . event nonce)
     * @param receiver_ the address who will receive tokens
     * @param proof_ the abi encoded merkle path with the signature of a merkle root the signer signed
     */
    function verifyMerkleLeaf(
        bytes memory tokenDataLeaf_,
        IBundler.Bundle calldata bundle_,
        bytes32 originHash_,
        address receiver_,
        bytes calldata proof_
    ) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IBundler {
    /**
     * @notice the struct that stores bundling info
     * @param salt the salt used to determine the proxy address
     * @param bundle the encoded transaction bundle
     */
    struct Bundle {
        bytes32 salt;
        bytes bundle;
    }

    /**
     * @notice function to get the bundle executor proxy address for the given salt and bundle
     * @param salt_ the salt for create2 (origin hash)
     * @return the bundle executor proxy address
     */
    function determineProxyAddress(bytes32 salt_) external view returns (address);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../bundle/IBundler.sol";

interface IERC1155Handler is IBundler {
    /**
     * @notice the event emitted from the depositERC1155 function
     */
    event DepositedERC1155(
        address token,
        uint256 tokenId,
        uint256 amount,
        bytes32 salt,
        bytes bundle,
        string network,
        string receiver,
        bool isWrapped
    );

    /**
     * @notice the struct that represents parameters for the erc1155 deposit
     * @param token the address of deposited tokens
     * @param tokenId the id of deposited tokens
     * @param amount the amount of deposited tokens
     * @param bundle the encoded transaction bundle with salt
     * @param network the network name of destination network, information field for event
     * @param receiver the receiver address in destination network, information field for event
     * @param isWrapped the boolean flag, if true - tokens will burned, false - tokens will transferred
     */
    struct DepositERC1155Parameters {
        address token;
        uint256 tokenId;
        uint256 amount;
        IBundler.Bundle bundle;
        string network;
        string receiver;
        bool isWrapped;
    }

    /**
     * @notice the struct that represents parameters for the erc1155 withdrawal
     * @param token the address of withdrawal tokens
     * @param tokenId the id of withdrawal tokens
     * @param tokenURI the uri of withdrawal tokens
     * @param amount the amount of withdrawal tokens
     * @param bundle the encoded transaction bundle with encoded salt
     * @param originHash the keccak256 hash of abi.encodePacked(origin chain name . origin tx hash . event nonce)
     * @param receiver the address who will receive tokens
     * @param proof the abi encoded merkle path with the signature of a merkle root the signer signed
     * @param isWrapped the boolean flag, if true - tokens will minted, false - tokens will transferred
     */
    struct WithdrawERC1155Parameters {
        address token;
        uint256 tokenId;
        string tokenURI;
        uint256 amount;
        IBundler.Bundle bundle;
        bytes32 originHash;
        address receiver;
        bytes proof;
        bool isWrapped;
    }

    /**
     * @notice the function to deposit erc1155 tokens
     * @param params_ the parameters for the erc1155 deposit
     */
    function depositERC1155(DepositERC1155Parameters calldata params_) external;

    /**
     * @notice the function to withdraw erc1155 tokens
     * @param params_ the parameters for the erc1155 withdrawal
     */
    function withdrawERC1155(WithdrawERC1155Parameters memory params_) external;

    /**
     * @notice the function to withdraw erc1155 tokens with bundle
     * @param params_ the parameters for the erc1155 withdrawal
     */
    function withdrawERC1155Bundle(WithdrawERC1155Parameters memory params_) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../bundle/IBundler.sol";

interface IERC20Handler is IBundler {
    /**
     * @notice the event emitted from the depositERC20 function
     */
    event DepositedERC20(
        address token,
        uint256 amount,
        bytes32 salt,
        bytes bundle,
        string network,
        string receiver,
        bool isWrapped
    );

    /**
     * @notice the struct that represents parameters for the erc20 deposit
     * @param token the address of the deposited token
     * @param amount the amount of deposited tokens
     * @param bundle the encoded transaction bundle with salt
     * @param network the network name of destination network, information field for event
     * @param receiver the receiver address in destination network, information field for event
     * @param isWrapped the boolean flag, if true - tokens will burned, false - tokens will transferred
     */
    struct DepositERC20Parameters {
        address token;
        uint256 amount;
        IBundler.Bundle bundle;
        string network;
        string receiver;
        bool isWrapped;
    }

    /**
     * @notice the struct that represents parameters for the erc20 withdrawal
     * @param token the address of the withdrawal token
     * @param amount the amount of withdrawal tokens
     * @param bundle the encoded transaction bundle with encoded salt
     * @param receiver the address who will receive tokens
     * @param originHash the keccak256 hash of abi.encodePacked(origin chain name . origin tx hash . event nonce)
     * @param proof the abi encoded merkle path with the signature of a merkle root the signer signed
     * @param isWrapped the boolean flag, if true - tokens will minted, false - tokens will transferred
     */
    struct WithdrawERC20Parameters {
        address token;
        uint256 amount;
        IBundler.Bundle bundle;
        bytes32 originHash;
        address receiver;
        bytes proof;
        bool isWrapped;
    }

    /**
     * @notice the function to deposit erc20 tokens
     * @param params_ the parameters for the erc20 deposit
     */
    function depositERC20(DepositERC20Parameters calldata params_) external;

    /**
     * @notice the function to withdraw erc20 tokens
     * @param params_ the parameters for the erc20 withdrawal
     */
    function withdrawERC20(WithdrawERC20Parameters memory params_) external;

    /**
     * @notice the function to withdraw erc20 tokens with bundle
     * @param params_ the parameters for the erc20 withdrawal
     */
    function withdrawERC20Bundle(WithdrawERC20Parameters memory params_) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../bundle/IBundler.sol";

interface IERC721Handler is IBundler {
    /**
     * @notice the event emitted from the depositERC721 function
     */
    event DepositedERC721(
        address token,
        uint256 tokenId,
        bytes32 salt,
        bytes bundle,
        string network,
        string receiver,
        bool isWrapped
    );

    /**
     * @notice the struct that represents parameters for the erc721 deposit
     * @param token the address of the deposited token
     * @param tokenId the id of deposited token
     * @param bundle the encoded transaction bundle with salt
     * @param network the network name of destination network, information field for event
     * @param receiver the receiver address in destination network, information field for event
     * @param isWrapped the boolean flag, if true - token will burned, false - token will transferred
     */
    struct DepositERC721Parameters {
        address token;
        uint256 tokenId;
        IBundler.Bundle bundle;
        string network;
        string receiver;
        bool isWrapped;
    }

    /**
     * @notice the struct that represents parameters for the erc721 withdrawal
     * @param token the address of the withdrawal token
     * @param tokenId the id of the withdrawal token
     * @param tokenURI the uri of the withdrawal token
     * @param bundle the encoded transaction bundle with encoded salt
     * @param originHash the keccak256 hash of abi.encodePacked(origin chain name . origin tx hash . event nonce)
     * @param receiver the address who will receive tokens
     * @param proof the abi encoded merkle path with the signature of a merkle root the signer signed
     * @param isWrapped the boolean flag, if true - tokens will minted, false - tokens will transferred
     */
    struct WithdrawERC721Parameters {
        address token;
        uint256 tokenId;
        string tokenURI;
        IBundler.Bundle bundle;
        bytes32 originHash;
        address receiver;
        bytes proof;
        bool isWrapped;
    }

    /**
     * @notice the function to deposit erc721 tokens
     * @param params_ the parameters for the erc721 deposit
     */
    function depositERC721(DepositERC721Parameters calldata params_) external;

    /**
     * @notice the function to withdraw erc721 tokens
     * @param params_ the parameters for the erc721 withdrawal
     */
    function withdrawERC721(WithdrawERC721Parameters memory params_) external;

    /**
     * @notice the function to withdraw erc721 tokens with bundle
     * @param params_ the parameters for the erc721 withdrawal
     */
    function withdrawERC721Bundle(WithdrawERC721Parameters memory params_) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../bundle/IBundler.sol";

interface INativeHandler is IBundler {
    /**
     * @notice the event emitted from the depositNative function
     */
    event DepositedNative(
        uint256 amount,
        bytes32 salt,
        bytes bundle,
        string network,
        string receiver
    );

    /**
     * @notice the struct that represents parameters for the native deposit
     * @param amount the amount of deposited native tokens
     * @param bundle the encoded transaction bundle with salt
     * @param network the network name of destination network, information field for event
     * @param receiver the receiver address in destination network, information field for event
     */
    struct DepositNativeParameters {
        uint256 amount;
        IBundler.Bundle bundle;
        string network;
        string receiver;
    }

    /**
     * @notice the struct that represents parameters for the native withdrawal
     * @param amount the amount of withdrawal native funds
     * @param bundle the encoded transaction bundle
     * @param originHash the keccak256 hash of abi.encodePacked(origin chain name . origin tx hash . event nonce)
     * @param receiver the address who will receive tokens
     * @param proof the abi encoded merkle path with the signature of a merkle root the signer signed
     */
    struct WithdrawNativeParameters {
        uint256 amount;
        IBundler.Bundle bundle;
        bytes32 originHash;
        address receiver;
        bytes proof;
    }

    /**
     * @notice the function to deposit native tokens
     * @param params_ the parameters for the native deposit
     */
    function depositNative(DepositNativeParameters calldata params_) external payable;

    /**
     * @notice the function to withdraw native tokens
     * @param params_ the parameters for the native withdrawal
     */
    function withdrawNative(WithdrawNativeParameters memory params_) external;

    /**
     * @notice the function to withdraw native tokens with bundle
     * @param params_ the parameters for the native withdrawal
     */
    function withdrawNativeBundle(WithdrawNativeParameters memory params_) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../bundle/IBundler.sol";

interface ISBTHandler is IBundler {
    /**
     * @notice the event emitted from the depositSBT function
     */
    event DepositedSBT(
        address token,
        uint256 tokenId,
        bytes32 salt,
        bytes bundle,
        string network,
        string receiver
    );

    /**
     * @notice the struct that represents parameters for the sbt deposit
     * @param token the address of deposited token
     * @param tokenId the id of deposited token
     * @param bundle the encoded transaction bundle with salt
     * @param network the network name of destination network, information field for event
     * @param receiver the receiver address in destination network, information field for event
     */
    struct DepositSBTParameters {
        address token;
        uint256 tokenId;
        IBundler.Bundle bundle;
        string network;
        string receiver;
    }

    /**
     * @notice the struct that represents parameters for the sbt withdrawal
     * @param token the address of the withdrawal token
     * @param tokenId the id of the withdrawal token
     * @param tokenURI the uri of the withdrawal token
     * @param bundle the encoded transaction bundle with encoded salt
     * @param originHash the keccak256 hash of abi.encodePacked(origin chain name . origin tx hash . event nonce)
     * @param receiver the address who will receive tokens
     * @param proof the abi encoded merkle path with the signature of a merkle root the signer signed
     */
    struct WithdrawSBTParameters {
        address token;
        uint256 tokenId;
        string tokenURI;
        IBundler.Bundle bundle;
        bytes32 originHash;
        address receiver;
        bytes proof;
    }

    /**
     * @notice the function to deposit sbt tokens
     * @param params_ the parameters for the sbt deposit
     */
    function depositSBT(DepositSBTParameters calldata params_) external;

    /**
     * @notice the function to withdraw sbt tokens
     * @param params_ the parameters for the sbt withdrawal
     */
    function withdrawSBT(WithdrawSBTParameters memory params_) external;

    /**
     * @notice the function to withdraw sbt tokens with bundle
     * @param params_ the parameters for the sbt withdrawal
     */
    function withdrawSBTBundle(WithdrawSBTParameters memory params_) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface ISigners {
    /**
     * @notice the function to check the signature and increment the nonce associated with the method selector
     * @param methodId_ the method id
     * @param contractAddress_ the contract address to which the method id belongs
     * @param signHash_ the sign hash to be verified
     * @param signature_ the signature to be checked
     */
    function checkSignatureAndIncrementNonce(
        uint8 methodId_,
        address contractAddress_,
        bytes32 signHash_,
        bytes calldata signature_
    ) external;

    /**
     * @notice the function to validate the address change signature
     * @param methodId_ the method id
     * @param contractAddress_ the contract address to which the method id belongs
     * @param newAddress_ the new signed address
     * @param signature_ the signature to be checked
     */
    function validateChangeAddressSignature(
        uint8 methodId_,
        address contractAddress_,
        address newAddress_,
        bytes calldata signature_
    ) external;

    /**
     * @notice the function to get signature components
     * @param methodId_ the method id
     * @param contractAddress_ the contract address to which the method id belongs
     * @return chainName_ the name of the chain
     * @return nonce_ the current nonce value associated with the method selector
     */
    function getSigComponents(
        uint8 methodId_,
        address contractAddress_
    ) external view returns (string memory chainName_, uint256 nonce_);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

import "../interfaces/bridge/IBridge.sol";

abstract contract Signers is ISigners, Initializable {
    using ECDSA for bytes32;
    using MerkleProof for bytes32[];

    uint256 public constant P = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F;

    address public signer;
    string public chainName;

    mapping(address => mapping(uint8 => uint256)) public nonces;

    function __Signers_init(address signer_, string calldata chainName_) public onlyInitializing {
        signer = signer_;
        chainName = chainName_;
    }

    function checkSignatureAndIncrementNonce(
        uint8 methodId_,
        address contractAddress_,
        bytes32 signHash_,
        bytes calldata signature_
    ) public {
        _checkSignature(signHash_, signature_);
        ++nonces[contractAddress_][methodId_];
    }

    function validateChangeAddressSignature(
        uint8 methodId_,
        address contractAddress_,
        address newAddress_,
        bytes calldata signature_
    ) public {
        (string memory chainName_, uint256 nonce_) = getSigComponents(methodId_, contractAddress_);

        bytes32 signHash_ = keccak256(
            abi.encodePacked(methodId_, newAddress_, chainName_, nonce_, contractAddress_)
        );

        checkSignatureAndIncrementNonce(methodId_, contractAddress_, signHash_, signature_);
    }

    function getSigComponents(
        uint8 methodId_,
        address contractAddress_
    ) public view returns (string memory chainName_, uint256 nonce_) {
        return (chainName, nonces[contractAddress_][methodId_]);
    }

    function _checkSignature(bytes32 signHash_, bytes memory signature_) internal view {
        address signer_ = signHash_.recover(signature_);

        require(signer == signer_, "Signers: invalid signature");
    }

    function _checkMerkleSignature(bytes32 merkleLeaf_, bytes calldata proof_) internal view {
        (bytes32[] memory merklePath_, bytes memory signature_) = abi.decode(
            proof_,
            (bytes32[], bytes)
        );

        bytes32 merkleRoot_ = merklePath_.processProof(merkleLeaf_);

        _checkSignature(merkleRoot_, signature_);
    }

    function _convertPubKeyToAddress(bytes calldata pubKey_) internal pure returns (address) {
        require(pubKey_.length == 64, "Signers: wrong pubKey length");

        (uint256 x_, uint256 y_) = abi.decode(pubKey_, (uint256, uint256));

        // @dev y^2 = x^3 + 7, x != 0, y != 0 (mod P)
        require(x_ != 0 && y_ != 0 && x_ != P && y_ != P, "Signers: zero pubKey");
        require(
            mulmod(y_, y_, P) == addmod(mulmod(mulmod(x_, x_, P), x_, P), 7, P),
            "Signers: pubKey not on the curve"
        );

        return address(uint160(uint256(keccak256(pubKey_))));
    }

    uint256[47] private _gap;
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "@dlsl/dev-modules/libs/arrays/SetHelper.sol";

import "@iden3/contracts/lib/GenesisUtils.sol";

import "./interfaces/IIdentityVerifier.sol";
import "./interfaces/IZKPQueriesStorage.sol";
import "./interfaces/IQueryValidator.sol";

contract IdentityVerifier is IIdentityVerifier, OwnableUpgradeable {
    using EnumerableSet for EnumerableSet.UintSet;
    using SetHelper for EnumerableSet.UintSet;

    IZKPQueriesStorage public override zkpQueriesStorage;

    mapping(address => uint256) public override addressToIdentityId;

    mapping(uint256 => IdentityProofInfo) internal _identitiesProofInfo;

    // schema => allowed issuers
    mapping(uint256 => EnumerableSet.UintSet) internal _allowedIssuers;

    function __IdentityVerifier_init(IZKPQueriesStorage zkpQueriesStorage_) external initializer {
        __Ownable_init();

        zkpQueriesStorage = zkpQueriesStorage_;
    }

    function setZKPQueriesStorage(
        IZKPQueriesStorage newZKPQueriesStorage_
    ) external override onlyOwner {
        zkpQueriesStorage = newZKPQueriesStorage_;
    }

    function updateAllowedIssuers(
        uint256 schema_,
        uint256[] calldata issuerIds_,
        bool isAdding_
    ) external override onlyOwner {
        if (isAdding_) {
            _allowedIssuers[schema_].add(issuerIds_);
        } else {
            _allowedIssuers[schema_].remove(issuerIds_);
        }
    }

    function proveIdentity(
        ILightweightState.StatesMerkleData calldata statesMerkleData_,
        uint256[] calldata inputs_,
        uint256[2] calldata a_,
        uint256[2][2] calldata b_,
        uint256[2] calldata c_
    ) external override {
        require(
            zkpQueriesStorage.isQueryExists(IDENTITY_PROOF_QUERY_ID),
            "IdentityVerifier: ZKP Query does not exist for passed query id."
        );

        IQueryValidator queryValidator_ = IQueryValidator(
            zkpQueriesStorage.getQueryValidator(IDENTITY_PROOF_QUERY_ID)
        );

        queryValidator_.verify(
            statesMerkleData_,
            inputs_,
            a_,
            b_,
            c_,
            zkpQueriesStorage.getStoredQueryHash(IDENTITY_PROOF_QUERY_ID)
        );

        require(
            isAllowedIssuer(
                zkpQueriesStorage.getStoredSchema(IDENTITY_PROOF_QUERY_ID),
                statesMerkleData_.issuerId
            ),
            "IdentityVerifier: Issuer is not on the list of allowed issuers"
        );

        require(
            addressToIdentityId[msg.sender] == 0,
            "IdentityVerifier: Msg sender address has already been used to prove the another identity."
        );

        uint256 identityId_ = inputs_[queryValidator_.getUserIdIndex()];

        require(
            !isIdentityProved(identityId_),
            "IdentityVerifier: Identity has already been proven."
        );
        require(
            msg.sender ==
                GenesisUtils.int256ToAddress(inputs_[queryValidator_.getChallengeInputIndex()]),
            "IdentityVerifier: Address in proof is not a sender address."
        );

        addressToIdentityId[msg.sender] = identityId_;
        _identitiesProofInfo[identityId_] = IdentityProofInfo(msg.sender, true);

        emit IdentityProved(identityId_, msg.sender);
    }

    function getAllowedIssuers(uint256 schema_) external view override returns (uint256[] memory) {
        return _allowedIssuers[schema_].values();
    }

    function getIdentityProofInfo(
        uint256 identityId_
    ) external view override returns (IdentityProofInfo memory) {
        return _identitiesProofInfo[identityId_];
    }

    function isIdentityProved(address userAddr_) external view override returns (bool) {
        return _identitiesProofInfo[addressToIdentityId[userAddr_]].isProved;
    }

    function isIdentityProved(uint256 identityId_) public view override returns (bool) {
        return _identitiesProofInfo[identityId_].isProved;
    }

    function isAllowedIssuer(
        uint256 schema_,
        uint256 issuerId_
    ) public view override returns (bool) {
        return _allowedIssuers[schema_].contains(issuerId_);
    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "./IZKPQueriesStorage.sol";
import "./ILightweightState.sol";

string constant IDENTITY_PROOF_QUERY_ID = "IDENTITY_PROOF";

interface IIdentityVerifier {
    struct IdentityProofInfo {
        address senderAddr;
        bool isProved;
    }

    event IdentityProved(uint256 indexed identityId, address senderAddr);

    function setZKPQueriesStorage(IZKPQueriesStorage newZKPQueriesStorage_) external;

    function updateAllowedIssuers(
        uint256 schema_,
        uint256[] calldata issuerIds_,
        bool isAdding_
    ) external;

    function proveIdentity(
        ILightweightState.StatesMerkleData calldata statesMerkleData_,
        uint256[] calldata inputs_,
        uint256[2] calldata a_,
        uint256[2][2] calldata b_,
        uint256[2] calldata c_
    ) external;

    function zkpQueriesStorage() external view returns (IZKPQueriesStorage);

    function addressToIdentityId(address senderAddr_) external view returns (uint256);

    function getAllowedIssuers(uint256 schema_) external view returns (uint256[] memory);

    function getIdentityProofInfo(
        uint256 identityId_
    ) external view returns (IdentityProofInfo memory);

    function isIdentityProved(address userAddr_) external view returns (bool);

    function isIdentityProved(uint256 identityId_) external view returns (bool);

    function isAllowedIssuer(uint256 schema_, uint256 issuerId_) external view returns (bool);
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "@iden3/contracts/interfaces/IState.sol";

interface ILightweightState {
    enum MethodId {
        None,
        AuthorizeUpgrade,
        ChangeSourceStateContract
    }

    struct GistRootData {
        uint256 root;
        uint256 createdAtTimestamp;
    }

    struct IdentitiesStatesRootData {
        bytes32 root;
        uint256 setTimestamp;
    }

    struct StatesMerkleData {
        uint256 issuerId;
        uint256 issuerState;
        uint256 createdAtTimestamp;
        bytes32[] merkleProof;
    }

    event SignedStateTransited(uint256 newGistRoot, bytes32 newIdentitesStatesRoot);

    function changeSourceStateContract(
        address newSourceStateContract_,
        bytes calldata signature_
    ) external;

    function changeSigner(bytes calldata newSignerPubKey_, bytes calldata signature_) external;

    function signedTransitState(
        bytes32 newIdentitiesStatesRoot_,
        GistRootData calldata gistData_,
        bytes calldata proof_
    ) external;

    function sourceStateContract() external view returns (address);

    function sourceChainName() external view returns (string memory);

    function identitiesStatesRoot() external view returns (bytes32);

    function isIdentitiesStatesRootExists(bytes32 root_) external view returns (bool);

    function getIdentitiesStatesRootData(
        bytes32 root_
    ) external view returns (IdentitiesStatesRootData memory);

    function getGISTRoot() external view returns (uint256);

    function getCurrentGISTRootInfo() external view returns (GistRootData memory);

    function geGISTRootData(uint256 root_) external view returns (GistRootData memory);

    function verifyStatesMerkleData(
        StatesMerkleData calldata statesMerkleData_
    ) external view returns (bool, bytes32);
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "./ILightweightState.sol";

interface IQueryValidator {
    struct ValidationParams {
        uint256 queryHash;
        uint256 gistRoot;
        uint256 issuerId;
        uint256 issuerClaimAuthState;
        uint256 issuerClaimNonRevState;
    }

    function setVerifier(address newVerifier_) external;

    function setIdentitesStatesUpdateTime(uint256 newIdentitesStatesUpdateTime_) external;

    function verify(
        ILightweightState.StatesMerkleData calldata statesMerkleData_,
        uint256[] memory inputs_,
        uint256[2] memory a_,
        uint256[2][2] memory b_,
        uint256[2] memory c_,
        uint256 queryHash_
    ) external view returns (bool);

    function lightweightState() external view returns (ILightweightState);

    function verifier() external view returns (address);

    function identitesStatesUpdateTime() external view returns (uint256);

    function getCircuitId() external pure returns (string memory);

    function getUserIdIndex() external pure returns (uint256);

    function getChallengeInputIndex() external pure returns (uint256);
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "@iden3/contracts/interfaces/ICircuitValidator.sol";

/**
 * @title IZKPQueriesStorage
 * @notice The IZKPQueriesStorage interface represents a contract that is responsible for storing and managing zero-knowledge proof (ZKP) queries.
 * It provides functions to set, retrieve, and remove ZKP queries from the storage.
 */
interface IZKPQueriesStorage {
    /**
     * @notice Contains the query information, including the circuit query and query validator
     * @param circuitQuery The circuit query
     * @param queryValidator The query validator
     */
    struct QueryInfo {
        ICircuitValidator.CircuitQuery circuitQuery;
        address queryValidator;
    }

    /**
     * @notice Event emitted when a ZKP query is set
     * @param queryId The ID of the query
     * @param queryValidator The address of the query validator
     * @param newCircuitQuery The new circuit query
     */
    event ZKPQuerySet(
        string indexed queryId,
        address queryValidator,
        ICircuitValidator.CircuitQuery newCircuitQuery
    );

    /**
     * @notice Event emitted when a ZKP query is removed
     * @param queryId The ID of the query
     */
    event ZKPQueryRemoved(string indexed queryId);

    /**
     * @notice Function that set a ZKP query with the provided query ID and query information
     * @param queryId_ The query ID
     * @param queryInfo_ The query information
     */
    function setZKPQuery(string memory queryId_, QueryInfo memory queryInfo_) external;

    /**
     * @notice Function that remove a ZKP query with the specified query ID
     * @param queryId_ The query ID
     */
    function removeZKPQuery(string memory queryId_) external;

    /**
     * @notice Function to get the supported query IDs
     * @return The array of supported query IDs
     */
    function getSupportedQueryIDs() external view returns (string[] memory);

    /**
     * @notice Function to get the query information for a given query ID
     * @param queryId_ The query ID
     * @return The QueryInfo structure with query information
     */
    function getQueryInfo(string calldata queryId_) external view returns (QueryInfo memory);

    /**
     * @notice Function to get the query validator for a given query ID
     * @param queryId_ The query ID
     * @return The query validator contract address
     */
    function getQueryValidator(string calldata queryId_) external view returns (address);

    /**
     * @notice Function to get the stored circuit query for a given query ID
     * @param queryId_ The query ID
     * @return The stored CircuitQuery structure
     */
    function getStoredCircuitQuery(
        string memory queryId_
    ) external view returns (ICircuitValidator.CircuitQuery memory);

    /**
     * @notice Function to get the stored query hash for a given query ID
     * @param queryId_ The query ID
     * @return The stored query hash
     */
    function getStoredQueryHash(string memory queryId_) external view returns (uint256);

    /**
     * @notice Function to get the stored schema for a given query ID
     * @param queryId_ The query ID
     * @return The stored schema id
     */
    function getStoredSchema(string memory queryId_) external view returns (uint256);

    /**
     * @notice Function to check if a query exists for the given query ID
     * @param queryId_ The query ID
     * @return A boolean indicating whether the query exists
     */
    function isQueryExists(string memory queryId_) external view returns (bool);

    /**
     * @notice Function to get the query hash for the provided circuit query
     * @param circuitQuery_ The circuit query
     * @return The query hash
     */
    function getQueryHash(
        ICircuitValidator.CircuitQuery memory circuitQuery_
    ) external view returns (uint256);

    /**
     * @notice Function to get the query hash for the raw values
     * @param schema_ The schema id
     * @param operator_ The query operator
     * @param claimPathKey_ The claim path key
     * @param values_ The values array
     * @return The query hash
     */
    function getQueryHashRaw(
        uint256 schema_,
        uint256 operator_,
        uint256 claimPathKey_,
        uint256[] memory values_
    ) external view returns (uint256);
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import "@rarimo/evm-bridge/bridge/proxy/UUPSSignableUpgradeable.sol";
import "@rarimo/evm-bridge/utils/Signers.sol";

import "./interfaces/ILightweightState.sol";

contract LightweightState is ILightweightState, UUPSSignableUpgradeable, Signers {
    address public override sourceStateContract;
    string public override sourceChainName;

    bytes32 public override identitiesStatesRoot;

    uint256 internal _currentGistRoot;

    // gist root => GistRootData
    mapping(uint256 => GistRootData) internal _gistsRootData;

    // identities states root => identities states root data
    mapping(bytes32 => IdentitiesStatesRootData) internal _identitiesStatesRootsData;

    function __LightweightState_init(
        address signer_,
        address sourceStateContract_,
        string calldata sourceChainName_,
        string calldata chainName_
    ) external initializer {
        __Signers_init(signer_, chainName_);

        sourceStateContract = sourceStateContract_;
        sourceChainName = sourceChainName_;
    }

    function changeSigner(
        bytes calldata newSignerPubKey_,
        bytes calldata signature_
    ) external override {
        _checkSignature(keccak256(newSignerPubKey_), signature_);

        signer = _convertPubKeyToAddress(newSignerPubKey_);
    }

    function changeSourceStateContract(
        address newSourceStateContract_,
        bytes calldata signature_
    ) external override {
        require(newSourceStateContract_ != address(0), "LightweightState: Zero address");

        validateChangeAddressSignature(
            uint8(MethodId.ChangeSourceStateContract),
            address(this),
            newSourceStateContract_,
            signature_
        );

        sourceStateContract = newSourceStateContract_;
    }

    function signedTransitState(
        bytes32 newIdentitiesStatesRoot_,
        GistRootData calldata gistData_,
        bytes calldata proof_
    ) external override {
        _checkMerkleSignature(_getSignHash(gistData_, newIdentitiesStatesRoot_), proof_);

        require(
            !isIdentitiesStatesRootExists(newIdentitiesStatesRoot_),
            "LightweightState: Identities states root already exists"
        );
        require(
            gistData_.createdAtTimestamp > _gistsRootData[_currentGistRoot].createdAtTimestamp,
            "LightweightState: Invalid GIST root data"
        );

        _gistsRootData[gistData_.root] = gistData_;
        _currentGistRoot = gistData_.root;

        identitiesStatesRoot = newIdentitiesStatesRoot_;
        _identitiesStatesRootsData[newIdentitiesStatesRoot_] = IdentitiesStatesRootData(
            newIdentitiesStatesRoot_,
            block.timestamp
        );

        emit SignedStateTransited(gistData_.root, newIdentitiesStatesRoot_);
    }

    function isIdentitiesStatesRootExists(bytes32 root_) public view returns (bool) {
        return _identitiesStatesRootsData[root_].setTimestamp != 0;
    }

    function getIdentitiesStatesRootData(
        bytes32 root_
    ) external view returns (IdentitiesStatesRootData memory) {
        return _identitiesStatesRootsData[root_];
    }

    function getGISTRoot() external view override returns (uint256) {
        return _currentGistRoot;
    }

    function getCurrentGISTRootInfo() external view override returns (GistRootData memory) {
        return _gistsRootData[_currentGistRoot];
    }

    function geGISTRootData(uint256 root_) external view override returns (GistRootData memory) {
        return _gistsRootData[root_];
    }

    function verifyStatesMerkleData(
        StatesMerkleData calldata statesMerkleData_
    ) external view override returns (bool, bytes32) {
        bytes32 merkleLeaf_ = keccak256(
            abi.encodePacked(
                statesMerkleData_.issuerId,
                statesMerkleData_.issuerState,
                statesMerkleData_.createdAtTimestamp
            )
        );
        bytes32 computedRoot_ = MerkleProof.processProofCalldata(
            statesMerkleData_.merkleProof,
            merkleLeaf_
        );

        return (isIdentitiesStatesRootExists(computedRoot_), computedRoot_);
    }

    function _authorizeUpgrade(
        address newImplementation_,
        bytes calldata signature_
    ) internal override {
        require(newImplementation_ != address(0), "LightweightState: Zero address");

        validateChangeAddressSignature(
            uint8(MethodId.AuthorizeUpgrade),
            address(this),
            newImplementation_,
            signature_
        );
    }

    function _authorizeUpgrade(address) internal pure virtual override {
        revert("LightweightState: This upgrade method is off");
    }

    function _getSignHash(
        GistRootData calldata gistData_,
        bytes32 identitiesStatesRoot_
    ) internal view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    gistData_.root,
                    gistData_.createdAtTimestamp,
                    identitiesStatesRoot_,
                    sourceStateContract,
                    sourceChainName
                )
            );
    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import "@iden3/contracts/lib/verifierSig.sol";
import "@iden3/contracts/lib/verifierMTP.sol";
import "@iden3/contracts/lib/verifierV2.sol";
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "../LightweightState.sol";

contract LightweightStateMock is LightweightState {
    function setSigner(address newSigner_) external {
        signer = newSigner_;
    }

    function setSourceStateContract(address newSourceStateContract_) external {
        sourceStateContract = newSourceStateContract_;
    }

    function _authorizeUpgrade(address) internal pure override {}
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";

import "@iden3/contracts/interfaces/IState.sol";
import "@iden3/contracts/interfaces/IStateTransitionVerifier.sol";
import "@iden3/contracts/lib/SmtLib.sol";
import "@iden3/contracts/lib/Poseidon.sol";
import "@iden3/contracts/lib/StateLib.sol";

/**
 * @dev This contract is a copy of the [StateV2](https://github.com/iden3/contracts/blob/5f6569bc2f942e3cf1c6032c05228046b3f3f5d5/contracts/state/StateV2.sol) contract from iden3 with the addition of an auxiliary event in the transitState function
 */
contract State is Ownable2StepUpgradeable, IState {
    using SmtLib for SmtLib.Data;
    using StateLib for StateLib.Data;

    /**
     * @dev Version of contract
     */
    string public constant VERSION = "2.1.0";

    // This empty reserved space is put in place to allow future versions
    // of the State contract to inherit from other contracts without a risk of
    // breaking the storage layout. This is necessary because the parent contracts in the
    // future may introduce some storage variables, which are placed before the State
    // contract's storage variables.
    // (see https://docs.openzeppelin.com/upgrades-plugins/1.x/writing-upgradeable#storage-gaps)
    // slither-disable-next-line shadowing-state
    // slither-disable-next-line unused-state
    uint256[500] private __gap;

    /**
     * @dev Verifier address
     */
    IStateTransitionVerifier internal verifier;

    /**
     * @dev State data
     */
    StateLib.Data internal _stateData;

    /**
     * @dev Global Identity State Tree (GIST) data
     */
    SmtLib.Data internal _gistData;

    event StateTransited(
        uint256 gistRoot,
        uint256 indexed id,
        uint256 state,
        uint256 timestamp,
        uint256 blockNumber
    );

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @dev Initialize the contract
     * @param verifierContractAddr_ Verifier address
     */
    function __State_init(IStateTransitionVerifier verifierContractAddr_) public initializer {
        __Ownable_init();

        _gistData.initialize(MAX_SMT_DEPTH);

        verifier = verifierContractAddr_;
    }

    /**
     * @dev Set ZKP verifier contract address
     * @param newVerifierAddr_ Verifier contract address
     */
    function setVerifier(address newVerifierAddr_) external onlyOwner {
        verifier = IStateTransitionVerifier(newVerifierAddr_);
    }

    /**
     * @dev Change the state of an identity (transit to the new state) with ZKP ownership check.
     * @param id_ Identity
     * @param oldState_ Previous identity state
     * @param newState_ New identity state
     * @param isOldStateGenesis_ Is the previous state genesis?
     * @param a_ ZKP proof field
     * @param b_ ZKP proof field
     * @param c_ ZKP proof field
     */
    function transitState(
        uint256 id_,
        uint256 oldState_,
        uint256 newState_,
        bool isOldStateGenesis_,
        uint256[2] memory a_,
        uint256[2][2] memory b_,
        uint256[2] memory c_
    ) external {
        require(id_ != 0, "ID should not be zero");
        require(newState_ != 0, "New state should not be zero");
        require(!stateExists(id_, newState_), "New state already exists");

        if (isOldStateGenesis_) {
            require(!idExists(id_), "Old state is genesis but identity already exists");

            // Push old state to state entries, with zero timestamp and block
            _stateData.addGenesisState(id_, oldState_);
        } else {
            require(idExists(id_), "Old state is not genesis but identity does not yet exist");

            StateLib.EntryInfo memory prevStateInfo_ = _stateData.getStateInfoById(id_);

            require(
                prevStateInfo_.createdAtBlock != block.number,
                "No multiple set in the same block"
            );
            require(
                prevStateInfo_.state == oldState_,
                "Old state does not match the latest state"
            );
        }

        uint256[4] memory inputs_ = [
            id_,
            oldState_,
            newState_,
            uint256(isOldStateGenesis_ ? 1 : 0)
        ];

        require(
            verifier.verifyProof(a_, b_, c_, inputs_),
            "Zero-knowledge proof of state transition is not valid"
        );

        _stateData.addState(id_, newState_);
        _gistData.addLeaf(PoseidonUnit1L.poseidon([id_]), newState_);

        emit StateTransited(_gistData.getRoot(), id_, newState_, block.timestamp, block.number);
    }

    /**
     * @dev Get ZKP verifier contract address
     * @return verifier contract address
     */
    function getVerifier() external view returns (address) {
        return address(verifier);
    }

    /**
     * @dev Retrieve the last state info for a given identity
     * @param id_ identity
     * @return state info of the last committed state
     */
    function getStateInfoById(uint256 id_) external view returns (IState.StateInfo memory) {
        return _stateEntryInfoAdapter(_stateData.getStateInfoById(id_));
    }

    /**
     * @dev Retrieve states quantity for a given identity
     * @param id_ identity
     * @return states quantity
     */
    function getStateInfoHistoryLengthById(uint256 id_) external view returns (uint256) {
        return _stateData.getStateInfoHistoryLengthById(id_);
    }

    /**
     * Retrieve state infos for a given identity
     * @param id_ identity
     * @param startIndex_ start index of the state history
     * @param length_ length of the state history
     * @return A list of state infos of the identity
     */
    function getStateInfoHistoryById(
        uint256 id_,
        uint256 startIndex_,
        uint256 length_
    ) external view returns (IState.StateInfo[] memory) {
        StateLib.EntryInfo[] memory stateInfos_ = _stateData.getStateInfoHistoryById(
            id_,
            startIndex_,
            length_
        );
        IState.StateInfo[] memory result_ = new IState.StateInfo[](stateInfos_.length);

        for (uint256 i = 0; i < stateInfos_.length; i++) {
            result_[i] = _stateEntryInfoAdapter(stateInfos_[i]);
        }

        return result_;
    }

    /**
     * @dev Retrieve state information by id and state.
     * @param id_ An identity.
     * @param state_ A state.
     * @return The state info.
     */
    function getStateInfoByIdAndState(
        uint256 id_,
        uint256 state_
    ) external view returns (IState.StateInfo memory) {
        return _stateEntryInfoAdapter(_stateData.getStateInfoByIdAndState(id_, state_));
    }

    /**
     * @dev Retrieve GIST inclusion or non-inclusion proof for a given identity.
     * @param id_ Identity
     * @return The GIST inclusion or non-inclusion proof for the identity
     */
    function getGISTProof(uint256 id_) external view returns (IState.GistProof memory) {
        return _smtProofAdapter(_gistData.getProof(PoseidonUnit1L.poseidon([id_])));
    }

    /**
     * @dev Retrieve GIST inclusion or non-inclusion proof for a given identity for
     * some GIST root in the past.
     * @param id_ Identity
     * @param root_ GIST root
     * @return The GIST inclusion or non-inclusion proof for the identity
     */
    function getGISTProofByRoot(
        uint256 id_,
        uint256 root_
    ) external view returns (IState.GistProof memory) {
        return _smtProofAdapter(_gistData.getProofByRoot(PoseidonUnit1L.poseidon([id_]), root_));
    }

    /**
     * @dev Retrieve GIST inclusion or non-inclusion proof for a given identity
     * for GIST latest snapshot by the block number provided.
     * @param id_ Identity
     * @param blockNumber_ Blockchain block number
     * @return The GIST inclusion or non-inclusion proof for the identity
     */
    function getGISTProofByBlock(
        uint256 id_,
        uint256 blockNumber_
    ) external view returns (IState.GistProof memory) {
        return
            _smtProofAdapter(
                _gistData.getProofByBlock(PoseidonUnit1L.poseidon([id_]), blockNumber_)
            );
    }

    /**
     * @dev Retrieve GIST inclusion or non-inclusion proof for a given identity
     * for GIST latest snapshot by the blockchain timestamp provided.
     * @param id_ Identity
     * @param timestamp_ Blockchain timestamp
     * @return The GIST inclusion or non-inclusion proof for the identity
     */
    function getGISTProofByTime(
        uint256 id_,
        uint256 timestamp_
    ) external view returns (IState.GistProof memory) {
        return
            _smtProofAdapter(_gistData.getProofByTime(PoseidonUnit1L.poseidon([id_]), timestamp_));
    }

    /**
     * @dev Retrieve GIST latest root.
     * @return The latest GIST root
     */
    function getGISTRoot() external view returns (uint256) {
        return _gistData.getRoot();
    }

    /**
     * @dev Retrieve the GIST root history.
     * @param start_ Start index in the root history
     * @param length_ Length of the root history
     * @return Array of GIST roots infos
     */
    function getGISTRootHistory(
        uint256 start_,
        uint256 length_
    ) external view returns (IState.GistRootInfo[] memory) {
        SmtLib.RootEntryInfo[] memory rootInfos_ = _gistData.getRootHistory(start_, length_);
        IState.GistRootInfo[] memory result_ = new IState.GistRootInfo[](rootInfos_.length);

        for (uint256 i = 0; i < rootInfos_.length; i++) {
            result_[i] = _smtRootInfoAdapter(rootInfos_[i]);
        }

        return result_;
    }

    /**
     * @dev Retrieve the length of the GIST root history.
     * @return The GIST root history length
     */
    function getGISTRootHistoryLength() external view returns (uint256) {
        return _gistData.rootEntries.length;
    }

    /**
     * @dev Retrieve the specific GIST root information.
     * @param root_ GIST root.
     * @return The GIST root information.
     */
    function getGISTRootInfo(uint256 root_) external view returns (IState.GistRootInfo memory) {
        return _smtRootInfoAdapter(_gistData.getRootInfo(root_));
    }

    /**
     * @dev Retrieve the GIST root information, which is latest by the block provided.
     * @param blockNumber_ Blockchain block number
     * @return The GIST root info
     */
    function getGISTRootInfoByBlock(
        uint256 blockNumber_
    ) external view returns (IState.GistRootInfo memory) {
        return _smtRootInfoAdapter(_gistData.getRootInfoByBlock(blockNumber_));
    }

    /**
     * @dev Retrieve the GIST root information, which is latest by the blockchain timestamp provided.
     * @param timestamp_ Blockchain timestamp
     * @return The GIST root info
     */
    function getGISTRootInfoByTime(
        uint256 timestamp_
    ) external view returns (IState.GistRootInfo memory) {
        return _smtRootInfoAdapter(_gistData.getRootInfoByTime(timestamp_));
    }

    /**
     * @dev Check if identity exists.
     * @param id_ Identity
     * @return True if the identity exists
     */
    function idExists(uint256 id_) public view returns (bool) {
        return _stateData.idExists(id_);
    }

    /**
     * @dev Check if state exists.
     * @param id_ Identity
     * @param state_ State
     * @return True if the state exists
     */
    function stateExists(uint256 id_, uint256 state_) public view returns (bool) {
        return _stateData.stateExists(id_, state_);
    }

    function _smtProofAdapter(
        SmtLib.Proof memory proof_
    ) internal pure returns (IState.GistProof memory) {
        // slither-disable-next-line uninitialized-local
        uint256[MAX_SMT_DEPTH] memory siblings_;

        for (uint256 i = 0; i < MAX_SMT_DEPTH; i++) {
            siblings_[i] = proof_.siblings[i];
        }

        IState.GistProof memory result = IState.GistProof({
            root: proof_.root,
            existence: proof_.existence,
            siblings: siblings_,
            index: proof_.index,
            value: proof_.value,
            auxExistence: proof_.auxExistence,
            auxIndex: proof_.auxIndex,
            auxValue: proof_.auxValue
        });

        return result;
    }

    function _smtRootInfoAdapter(
        SmtLib.RootEntryInfo memory rootInfo_
    ) internal pure returns (IState.GistRootInfo memory) {
        return
            IState.GistRootInfo({
                root: rootInfo_.root,
                replacedByRoot: rootInfo_.replacedByRoot,
                createdAtTimestamp: rootInfo_.createdAtTimestamp,
                replacedAtTimestamp: rootInfo_.replacedAtTimestamp,
                createdAtBlock: rootInfo_.createdAtBlock,
                replacedAtBlock: rootInfo_.replacedAtBlock
            });
    }

    function _stateEntryInfoAdapter(
        StateLib.EntryInfo memory sei_
    ) internal pure returns (IState.StateInfo memory) {
        return
            IState.StateInfo({
                id: sei_.id,
                state: sei_.state,
                replacedByState: sei_.replacedByState,
                createdAtTimestamp: sei_.createdAtTimestamp,
                replacedAtTimestamp: sei_.replacedAtTimestamp,
                createdAtBlock: sei_.createdAtBlock,
                replacedAtBlock: sei_.replacedAtBlock
            });
    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "./QueryValidator.sol";

contract QueryMTPValidator is QueryValidator {
    string internal constant CIRCUIT_ID = "credentialAtomicQueryMTPV2OnChain";
    uint256 internal constant USER_ID_INDEX = 1;
    uint256 internal constant CHALLENGE_INDEX = 4;

    function __QueryMTPValidator_init(
        address verifierContractAddr_,
        address stateContractAddr_,
        uint256 identitesStatesUpdateTime_
    ) public initializer {
        __QueryValidator_init(
            verifierContractAddr_,
            stateContractAddr_,
            identitesStatesUpdateTime_
        );
    }

    function getCircuitId() external pure override returns (string memory id) {
        return CIRCUIT_ID;
    }

    function getUserIdIndex() external pure override returns (uint256) {
        return USER_ID_INDEX;
    }

    function getChallengeInputIndex() external pure override returns (uint256 index) {
        return CHALLENGE_INDEX;
    }

    function _getInputValidationParameters(
        uint256[] calldata inputs_
    ) internal pure override returns (ValidationParams memory) {
        return ValidationParams(inputs_[2], inputs_[5], inputs_[6], inputs_[7], inputs_[9]);
    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "./QueryValidator.sol";

contract QuerySigValidator is QueryValidator {
    string internal constant CIRCUIT_ID = "credentialAtomicQuerySigV2OnChain";
    uint256 internal constant USER_ID_INDEX = 1;
    uint256 internal constant CHALLENGE_INDEX = 5;

    function __QuerySigValidator_init(
        address verifierContractAddr_,
        address stateContractAddr_,
        uint256 identitesStatesUpdateTime_
    ) public initializer {
        __QueryValidator_init(
            verifierContractAddr_,
            stateContractAddr_,
            identitesStatesUpdateTime_
        );
    }

    function getCircuitId() external pure override returns (string memory id) {
        return CIRCUIT_ID;
    }

    function getUserIdIndex() external pure override returns (uint256) {
        return USER_ID_INDEX;
    }

    function getChallengeInputIndex() external pure override returns (uint256 index) {
        return CHALLENGE_INDEX;
    }

    function _getInputValidationParameters(
        uint256[] calldata inputs_
    ) internal pure override returns (ValidationParams memory) {
        return ValidationParams(inputs_[2], inputs_[6], inputs_[7], inputs_[3], inputs_[9]);
    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "@dlsl/dev-modules/libs/zkp/snarkjs/VerifierHelper.sol";

import "@iden3/contracts/lib/GenesisUtils.sol";

import "../interfaces/ILightweightState.sol";
import "../interfaces/IQueryValidator.sol";

abstract contract QueryValidator is OwnableUpgradeable, IQueryValidator {
    using VerifierHelper for address;

    ILightweightState public override lightweightState;
    address public override verifier;

    uint256 public override identitesStatesUpdateTime;

    function __QueryValidator_init(
        address verifierContractAddr_,
        address stateContractAddr_,
        uint256 identitesStatesUpdateTime_
    ) public onlyInitializing {
        __Ownable_init();

        lightweightState = ILightweightState(stateContractAddr_);
        verifier = verifierContractAddr_;

        identitesStatesUpdateTime = identitesStatesUpdateTime_;
    }

    function setVerifier(address newVerifier_) external override onlyOwner {
        verifier = newVerifier_;
    }

    function setIdentitesStatesUpdateTime(
        uint256 newIdentitesStatesUpdateTime_
    ) public virtual override onlyOwner {
        identitesStatesUpdateTime = newIdentitesStatesUpdateTime_;
    }

    function verify(
        ILightweightState.StatesMerkleData calldata statesMerkleData_,
        uint256[] calldata inputs_,
        uint256[2] calldata a_,
        uint256[2][2] calldata b_,
        uint256[2] calldata c_,
        uint256 queryHash_
    ) external view virtual override returns (bool) {
        require(verifier.verifyProof(inputs_, a_, b_, c_), "QueryValidator: proof is not valid");

        ValidationParams memory validationParams_ = _getInputValidationParameters(inputs_);

        require(
            validationParams_.queryHash == queryHash_,
            "QueryValidator: query hash does not match the requested one"
        );

        require(
            validationParams_.issuerClaimAuthState == validationParams_.issuerClaimNonRevState,
            "QueryValidator: only actual states must be used"
        );
        require(
            validationParams_.issuerId == statesMerkleData_.issuerId &&
                validationParams_.issuerClaimNonRevState == statesMerkleData_.issuerState,
            "QueryValidator: invalid issuer data in the states merkle data struct"
        );

        _checkGistRoot(validationParams_.gistRoot);
        _verifyStatesMerkleData(statesMerkleData_);

        return true;
    }

    function getCircuitId() external pure virtual returns (string memory);

    function getUserIdIndex() external pure virtual returns (uint256);

    function getChallengeInputIndex() external pure virtual returns (uint256);

    function _getInputValidationParameters(
        uint256[] calldata inputs_
    ) internal pure virtual returns (ValidationParams memory);

    function _checkGistRoot(uint256 gistRoot_) internal view {
        ILightweightState.GistRootData memory rootData_ = lightweightState.geGISTRootData(
            gistRoot_
        );

        require(
            rootData_.root == gistRoot_,
            "QueryValidator: gist root state isn't in state contract"
        );
    }

    function _verifyStatesMerkleData(
        ILightweightState.StatesMerkleData calldata statesMerkleData_
    ) internal view {
        (bool isRootExists_, bytes32 computedRoot_) = lightweightState.verifyStatesMerkleData(
            statesMerkleData_
        );

        if (!isRootExists_) {
            require(
                GenesisUtils.isGenesisState(
                    statesMerkleData_.issuerId,
                    statesMerkleData_.issuerState
                ),
                "QueryValidator: issuer state isn't in state contract and not genesis"
            );
            require(
                statesMerkleData_.createdAtTimestamp == 0,
                "QueryValidator: it isn't possible to have a state creation time at genesis state"
            );
        } else if (computedRoot_ != lightweightState.identitiesStatesRoot()) {
            ILightweightState.IdentitiesStatesRootData
                memory _identitiesStatesRootData = lightweightState.getIdentitiesStatesRootData(
                    computedRoot_
                );

            require(
                _identitiesStatesRootData.setTimestamp + identitesStatesUpdateTime >
                    block.timestamp,
                "QueryValidator: identites states update time has expired"
            );
        }
    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "@dlsl/dev-modules/libs/data-structures/StringSet.sol";
import "@dlsl/dev-modules/libs/utils/TypeCaster.sol";

import "@iden3/contracts/interfaces/ICircuitValidator.sol";
import "@iden3/contracts/lib/Poseidon.sol";

import "./interfaces/IZKPQueriesStorage.sol";

contract ZKPQueriesStorage is IZKPQueriesStorage, OwnableUpgradeable {
    using StringSet for StringSet.Set;
    using TypeCaster for uint256;

    mapping(string => QueryInfo) internal _queriesInfo;

    StringSet.Set internal _supportedQueryIds;

    function __ZKPQueriesStorage_init() external initializer {
        __Ownable_init();
    }

    function setZKPQuery(
        string memory queryId_,
        QueryInfo memory queryInfo_
    ) external override onlyOwner {
        require(
            address(queryInfo_.queryValidator) != address(0),
            "ZKPQueriesStorage: Zero queryValidator address."
        );

        queryInfo_.circuitQuery.queryHash = getQueryHash(queryInfo_.circuitQuery);

        _queriesInfo[queryId_] = queryInfo_;

        _supportedQueryIds.add(queryId_);

        emit ZKPQuerySet(queryId_, address(queryInfo_.queryValidator), queryInfo_.circuitQuery);
    }

    function removeZKPQuery(string memory queryId_) external override onlyOwner {
        require(isQueryExists(queryId_), "ZKPQueriesStorage: ZKP Query does not exist.");

        _supportedQueryIds.remove(queryId_);

        delete _queriesInfo[queryId_];

        emit ZKPQueryRemoved(queryId_);
    }

    function getSupportedQueryIDs() external view override returns (string[] memory) {
        return _supportedQueryIds.values();
    }

    function getQueryInfo(
        string calldata queryId_
    ) external view override returns (QueryInfo memory) {
        return _queriesInfo[queryId_];
    }

    function getQueryValidator(string calldata queryId_) external view override returns (address) {
        return _queriesInfo[queryId_].queryValidator;
    }

    function getStoredCircuitQuery(
        string memory queryId_
    ) external view override returns (ICircuitValidator.CircuitQuery memory) {
        return _queriesInfo[queryId_].circuitQuery;
    }

    function getStoredQueryHash(string memory queryId_) external view override returns (uint256) {
        return _queriesInfo[queryId_].circuitQuery.queryHash;
    }

    function getStoredSchema(string memory queryId_) external view override returns (uint256) {
        return _queriesInfo[queryId_].circuitQuery.schema;
    }

    function isQueryExists(string memory queryId_) public view override returns (bool) {
        return _supportedQueryIds.contains(queryId_);
    }

    function getQueryHash(
        ICircuitValidator.CircuitQuery memory circuitQuery_
    ) public pure override returns (uint256) {
        return
            getQueryHashRaw(
                circuitQuery_.schema,
                circuitQuery_.operator,
                circuitQuery_.claimPathKey,
                circuitQuery_.value
            );
    }

    function getQueryHashRaw(
        uint256 schema_,
        uint256 operator_,
        uint256 claimPathKey_,
        uint256[] memory values_
    ) public pure override returns (uint256) {
        uint256 valueHash_ = PoseidonFacade.poseidonSponge(values_);

        // only merklized claims are supported (claimPathNotExists is false, slot index is set to 0 )
        return
            PoseidonFacade.poseidon6(
                [
                    schema_,
                    0, // slot index
                    operator_,
                    claimPathKey_,
                    0, // claimPathNotExists: 0 for inclusion, 1 for non-inclusion
                    valueHash_
                ]
            );
    }
}
// SPDX-License-Identifier: Unlicense
/*
 * @title Solidity Bytes Arrays Utils
 * @author Gonçalo Sá <goncalo.sa@consensys.net>
 *
 * @dev Bytes tightly packed arrays utility library for ethereum contracts written in Solidity.
 *      The library lets you concatenate, slice and type cast bytes arrays both in memory and storage.
 */
pragma solidity >=0.8.0 <0.9.0;


library BytesLib {
    function concat(
        bytes memory _preBytes,
        bytes memory _postBytes
    )
        internal
        pure
        returns (bytes memory)
    {
        bytes memory tempBytes;

        assembly {
            // Get a location of some free memory and store it in tempBytes as
            // Solidity does for memory variables.
            tempBytes := mload(0x40)

            // Store the length of the first bytes array at the beginning of
            // the memory for tempBytes.
            let length := mload(_preBytes)
            mstore(tempBytes, length)

            // Maintain a memory counter for the current write location in the
            // temp bytes array by adding the 32 bytes for the array length to
            // the starting location.
            let mc := add(tempBytes, 0x20)
            // Stop copying when the memory counter reaches the length of the
            // first bytes array.
            let end := add(mc, length)

            for {
                // Initialize a copy counter to the start of the _preBytes data,
                // 32 bytes into its memory.
                let cc := add(_preBytes, 0x20)
            } lt(mc, end) {
                // Increase both counters by 32 bytes each iteration.
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                // Write the _preBytes data into the tempBytes memory 32 bytes
                // at a time.
                mstore(mc, mload(cc))
            }

            // Add the length of _postBytes to the current length of tempBytes
            // and store it as the new length in the first 32 bytes of the
            // tempBytes memory.
            length := mload(_postBytes)
            mstore(tempBytes, add(length, mload(tempBytes)))

            // Move the memory counter back from a multiple of 0x20 to the
            // actual end of the _preBytes data.
            mc := end
            // Stop copying when the memory counter reaches the new combined
            // length of the arrays.
            end := add(mc, length)

            for {
                let cc := add(_postBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            // Update the free-memory pointer by padding our last write location
            // to 32 bytes: add 31 bytes to the end of tempBytes to move to the
            // next 32 byte block, then round down to the nearest multiple of
            // 32. If the sum of the length of the two arrays is zero then add
            // one before rounding down to leave a blank 32 bytes (the length block with 0).
            mstore(0x40, and(
              add(add(end, iszero(add(length, mload(_preBytes)))), 31),
              not(31) // Round down to the nearest 32 bytes.
            ))
        }

        return tempBytes;
    }

    function concatStorage(bytes storage _preBytes, bytes memory _postBytes) internal {
        assembly {
            // Read the first 32 bytes of _preBytes storage, which is the length
            // of the array. (We don't need to use the offset into the slot
            // because arrays use the entire slot.)
            let fslot := sload(_preBytes.slot)
            // Arrays of 31 bytes or less have an even value in their slot,
            // while longer arrays have an odd value. The actual length is
            // the slot divided by two for odd values, and the lowest order
            // byte divided by two for even values.
            // If the slot is even, bitwise and the slot with 255 and divide by
            // two to get the length. If the slot is odd, bitwise and the slot
            // with -1 and divide by two.
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)
            let newlength := add(slength, mlength)
            // slength can contain both the length and contents of the array
            // if length < 32 bytes so let's prepare for that
            // v. http://solidity.readthedocs.io/en/latest/miscellaneous.html#layout-of-state-variables-in-storage
            switch add(lt(slength, 32), lt(newlength, 32))
            case 2 {
                // Since the new array still fits in the slot, we just need to
                // update the contents of the slot.
                // uint256(bytes_storage) = uint256(bytes_storage) + uint256(bytes_memory) + new_length
                sstore(
                    _preBytes.slot,
                    // all the modifications to the slot are inside this
                    // next block
                    add(
                        // we can just add to the slot contents because the
                        // bytes we want to change are the LSBs
                        fslot,
                        add(
                            mul(
                                div(
                                    // load the bytes from memory
                                    mload(add(_postBytes, 0x20)),
                                    // zero all bytes to the right
                                    exp(0x100, sub(32, mlength))
                                ),
                                // and now shift left the number of bytes to
                                // leave space for the length in the slot
                                exp(0x100, sub(32, newlength))
                            ),
                            // increase length by the double of the memory
                            // bytes length
                            mul(mlength, 2)
                        )
                    )
                )
            }
            case 1 {
                // The stored value fits in the slot, but the combined value
                // will exceed it.
                // get the keccak hash to get the contents of the array
                mstore(0x0, _preBytes.slot)
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                // save new length
                sstore(_preBytes.slot, add(mul(newlength, 2), 1))

                // The contents of the _postBytes array start 32 bytes into
                // the structure. Our first read should obtain the `submod`
                // bytes that can fit into the unused space in the last word
                // of the stored array. To get this, we read 32 bytes starting
                // from `submod`, so the data we read overlaps with the array
                // contents by `submod` bytes. Masking the lowest-order
                // `submod` bytes allows us to add that value directly to the
                // stored value.

                let submod := sub(32, slength)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(
                    sc,
                    add(
                        and(
                            fslot,
                            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00
                        ),
                        and(mload(mc), mask)
                    )
                )

                for {
                    mc := add(mc, 0x20)
                    sc := add(sc, 1)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
            default {
                // get the keccak hash to get the contents of the array
                mstore(0x0, _preBytes.slot)
                // Start copying to the last used word of the stored array.
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                // save new length
                sstore(_preBytes.slot, add(mul(newlength, 2), 1))

                // Copy over the first `submod` bytes of the new data as in
                // case 1 above.
                let slengthmod := mod(slength, 32)
                let mlengthmod := mod(mlength, 32)
                let submod := sub(32, slengthmod)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(sc, add(sload(sc), and(mload(mc), mask)))

                for {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
        }
    }

    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    )
        internal
        pure
        returns (bytes memory)
    {
        require(_length + 31 >= _length, "slice_overflow");
        require(_bytes.length >= _start + _length, "slice_outOfBounds");

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                // Get a location of some free memory and store it in tempBytes as
                // Solidity does for memory variables.
                tempBytes := mload(0x40)

                // The first word of the slice result is potentially a partial
                // word read from the original array. To read it, we calculate
                // the length of that partial word and start copying that many
                // bytes into the array. The first word we copy will start with
                // data we don't care about, but the last `lengthmod` bytes will
                // land at the beginning of the contents of the new array. When
                // we're done copying, we overwrite the full first word with
                // the actual length of the slice.
                let lengthmod := and(_length, 31)

                // The multiplication in the next line is necessary
                // because when slicing multiples of 32 bytes (lengthmod == 0)
                // the following copy loop was copying the origin's length
                // and then ending prematurely not copying everything it should.
                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                    // The multiplication in the next line has the same exact purpose
                    // as the one above.
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                //update free-memory pointer
                //allocating the array padded to 32 bytes like the compiler does now
                mstore(0x40, and(add(mc, 31), not(31)))
            }
            //if we want a zero-length slice let's just return a zero-length array
            default {
                tempBytes := mload(0x40)
                //zero out the 32 bytes slice we are about to return
                //we need to do it because Solidity does not garbage collect
                mstore(tempBytes, 0)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {
        require(_bytes.length >= _start + 20, "toAddress_outOfBounds");
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toUint8(bytes memory _bytes, uint256 _start) internal pure returns (uint8) {
        require(_bytes.length >= _start + 1 , "toUint8_outOfBounds");
        uint8 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x1), _start))
        }

        return tempUint;
    }

    function toUint16(bytes memory _bytes, uint256 _start) internal pure returns (uint16) {
        require(_bytes.length >= _start + 2, "toUint16_outOfBounds");
        uint16 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x2), _start))
        }

        return tempUint;
    }

    function toUint32(bytes memory _bytes, uint256 _start) internal pure returns (uint32) {
        require(_bytes.length >= _start + 4, "toUint32_outOfBounds");
        uint32 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x4), _start))
        }

        return tempUint;
    }

    function toUint64(bytes memory _bytes, uint256 _start) internal pure returns (uint64) {
        require(_bytes.length >= _start + 8, "toUint64_outOfBounds");
        uint64 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x8), _start))
        }

        return tempUint;
    }

    function toUint96(bytes memory _bytes, uint256 _start) internal pure returns (uint96) {
        require(_bytes.length >= _start + 12, "toUint96_outOfBounds");
        uint96 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0xc), _start))
        }

        return tempUint;
    }

    function toUint128(bytes memory _bytes, uint256 _start) internal pure returns (uint128) {
        require(_bytes.length >= _start + 16, "toUint128_outOfBounds");
        uint128 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x10), _start))
        }

        return tempUint;
    }

    function toUint256(bytes memory _bytes, uint256 _start) internal pure returns (uint256) {
        require(_bytes.length >= _start + 32, "toUint256_outOfBounds");
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }

    function toBytes32(bytes memory _bytes, uint256 _start) internal pure returns (bytes32) {
        require(_bytes.length >= _start + 32, "toBytes32_outOfBounds");
        bytes32 tempBytes32;

        assembly {
            tempBytes32 := mload(add(add(_bytes, 0x20), _start))
        }

        return tempBytes32;
    }

    function equal(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bool) {
        bool success = true;

        assembly {
            let length := mload(_preBytes)

            // if lengths don't match the arrays are not equal
            switch eq(length, mload(_postBytes))
            case 1 {
                // cb is a circuit breaker in the for loop since there's
                //  no said feature for inline assembly loops
                // cb = 1 - don't breaker
                // cb = 0 - break
                let cb := 1

                let mc := add(_preBytes, 0x20)
                let end := add(mc, length)

                for {
                    let cc := add(_postBytes, 0x20)
                // the next line is the loop condition:
                // while(uint256(mc < end) + cb == 2)
                } eq(add(lt(mc, end), cb), 2) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    // if any of these checks fails then arrays are not equal
                    if iszero(eq(mload(mc), mload(cc))) {
                        // unsuccess:
                        success := 0
                        cb := 0
                    }
                }
            }
            default {
                // unsuccess:
                success := 0
            }
        }

        return success;
    }

    function equalStorage(
        bytes storage _preBytes,
        bytes memory _postBytes
    )
        internal
        view
        returns (bool)
    {
        bool success = true;

        assembly {
            // we know _preBytes_offset is 0
            let fslot := sload(_preBytes.slot)
            // Decode the length of the stored array like in concatStorage().
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)

            // if lengths don't match the arrays are not equal
            switch eq(slength, mlength)
            case 1 {
                // slength can contain both the length and contents of the array
                // if length < 32 bytes so let's prepare for that
                // v. http://solidity.readthedocs.io/en/latest/miscellaneous.html#layout-of-state-variables-in-storage
                if iszero(iszero(slength)) {
                    switch lt(slength, 32)
                    case 1 {
                        // blank the last byte which is the length
                        fslot := mul(div(fslot, 0x100), 0x100)

                        if iszero(eq(fslot, mload(add(_postBytes, 0x20)))) {
                            // unsuccess:
                            success := 0
                        }
                    }
                    default {
                        // cb is a circuit breaker in the for loop since there's
                        //  no said feature for inline assembly loops
                        // cb = 1 - don't breaker
                        // cb = 0 - break
                        let cb := 1

                        // get the keccak hash to get the contents of the array
                        mstore(0x0, _preBytes.slot)
                        let sc := keccak256(0x0, 0x20)

                        let mc := add(_postBytes, 0x20)
                        let end := add(mc, mlength)

                        // the next line is the loop condition:
                        // while(uint256(mc < end) + cb == 2)
                        for {} eq(add(lt(mc, end), cb), 2) {
                            sc := add(sc, 1)
                            mc := add(mc, 0x20)
                        } {
                            if iszero(eq(sload(sc), mload(mc))) {
                                // unsuccess:
                                success := 0
                                cb := 0
                            }
                        }
                    }
                }
            }
            default {
                // unsuccess:
                success := 0
            }
        }

        return success;
    }
}
