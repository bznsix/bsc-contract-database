// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
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
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
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
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
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
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address, RecoverError) {
        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
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
    function tryRecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address, RecoverError) {
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
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
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
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
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

// This is the ETH/ERC20/NFT multisig contract for Ownbit.
//
// For 2-of-3 multisig, to authorize a spend, two signtures must be provided by 2 of the 3 owners.
// To generate the message to be signed, provide the destination address and
// spend amount (in wei) to the generateMessageToSign method.
// The signatures must be provided as the (v, r, s) hex-encoded coordinates.
// The S coordinate must be 0x00 or 0x01 corresponding to 0x1b and 0x1c, respectively.
//
// WARNING: The generated message is only valid until the next spend is executed.
//          after that, a new message will need to be calculated.
//
//
// Accident Protection MultiSig, rules:
//
// Participants must keep themselves active by submitting transactions.
// Not submitting any transaction within 3,000,000 ETH blocks (roughly 416 days) will be treated as wallet lost (i.e. accident happened),
// other participants can still spend the assets as along as: valid signing count >= Min(mininual required count, active owners).
//
// INFO: This contract is ERC20/ERC721/ERC1155 compatible.
// This contract can both receive ETH, ERC20 and NFT (ERC721/ERC1155) tokens.
// Last update time: 2023-06-04.
// copyright@ownbit.io

contract MultiSign {
    address owner;
    uint public constant MAX_OWNER_COUNT = 9;
    uint public constant MAX_INACTIVE_TIME = 416 days;
    uint public constant CHAINID = 56; //chainId for BNB Smart Chain

    // The N addresses which control the funds in this contract. The
    // owners of M of these addresses will need to both sign a message
    // allowing the funds in this contract to be spent.
    mapping(address => uint256) private ownerActiveTimeMap; //uint256 is the active timestamp(in secs) of this owner
    address[] private owners;
    uint private required;

    // The contract nonce is not accessible to the contract so we
    // implement a nonce-like variable for replay protection.
    uint256 private spendNonce = 0;

    // An event sent when funds are received.
    event Funded(address from, uint value);

    // An event sent when an spendAny is executed.
    event Spent(address to);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    receive() external payable {}

    // The fallback function for this contract.
    fallback() external payable {
        if (msg.value > 0) {
            emit Funded(msg.sender, msg.value);
        }
    }

    function setValidRequirement(address[] memory _owners, uint _required) external onlyOwner {
        require(_owners.length <= MAX_OWNER_COUNT && _required <= _owners.length && _required >= 1);
        for (uint i = 0; i < _owners.length; i++) {
            //onwer should be distinct, and non-zero
            if (ownerActiveTimeMap[_owners[i]] > 0 || _owners[i] == address(0x0)) {
                revert();
            }
            ownerActiveTimeMap[_owners[i]] = block.timestamp;
        }
        owners = _owners;
        required = _required;
    }

    // @dev Returns list of owners.
    // @return List of owner addresses.
    function getOwners() public view returns (address[] memory) {
        return owners;
    }

    function getSpendNonce() public view returns (uint256) {
        return spendNonce;
    }

    function getRequired() public view returns (uint) {
        return required;
    }

    //return the active timestamp of this owner
    function getOwnerActiveTime(address addr) public view returns (uint256) {
        return ownerActiveTimeMap[addr];
    }

    // Generates the message to sign given the output destination address and amount.
    // includes this contract's address and a nonce for replay protection.
    // One option to independently verify: https://leventozturk.com/engineering/sha3/ and select keccak
    function generateMessageToSign(address destination, bytes memory data) private view returns (bytes32) {
        //the sequence must match generateMultiSigV3 in JS
        bytes32 message = keccak256(abi.encodePacked(address(this), destination, data, spendNonce, CHAINID));
        return message;
    }

    function _messageToRecover(address destination, bytes memory data) private view returns (bytes32) {
        bytes32 hashedUnsignedMessage = generateMessageToSign(destination, data);
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        return keccak256(abi.encodePacked(prefix, hashedUnsignedMessage));
    }

    //destination can be a normal address or a contract address, such as ERC20 contract address.
    //value is the wei transferred to the destination.
    //data for transfer ether: 0x
    //data for transfer erc20 example: 0xa9059cbb000000000000000000000000ac6342a7efb995d63cc91db49f6023e95873d25000000000000000000000000000000000000000000000000000000000000003e8
    //data for transfer erc721 example: 0x42842e0e00000000000000000000000097b65ad59c8c96f2dd786751e6279a1a6d34a4810000000000000000000000006cb33e7179860d24635c66850f1f6a5d4f8eee6d0000000000000000000000000000000000000000000000000000000000042134
    //data can contain any data to be executed.
    function spend(address destination, bytes[] memory signature, bytes calldata data) external {
        require(destination != address(this), "Not allow sending to yourself");
        require(_validSignature(destination, signature, data), "invalid signatures");
        spendNonce = spendNonce + 1;
        //transfer tokens from this contract to the destination address
        (bool sent, ) = destination.call(data);
        if (sent) {
            emit Spent(destination);
        }
    }

    //send a tx from the owner address to active the owner
    //Allow the owner to transfer some ETH, although this is not necessary.
    function active() external payable {
        require(ownerActiveTimeMap[msg.sender] > 0, "Not an owner");
        ownerActiveTimeMap[msg.sender] = block.timestamp;
    }

    function getRequiredWithoutInactive() public view returns (uint) {
        uint activeOwner = 0;
        for (uint i = 0; i < owners.length; i++) {
            //if the owner is active
            if (ownerActiveTimeMap[owners[i]] + MAX_INACTIVE_TIME >= block.timestamp) {
                activeOwner++;
            }
        }
        //active owners still equal or greater then required
        if (activeOwner >= required) {
            return required;
        }
        //active less than required, all active must sign
        if (activeOwner >= 1) {
            return activeOwner;
        }
        //at least one sign.
        return 1;
    }

    function valid(address destination, bytes[] memory signature, bytes memory data) public view returns (address[] memory) {
        address[] memory addrs = new address[](signature.length);
        for (uint i = 0; i < signature.length; i++) {
            //recover the address associated with the public key from elliptic curve signature or return zero on error
            bytes32 message = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(address(this), destination, data, spendNonce, CHAINID)));
            addrs[i] = ECDSA.recover(message, signature[i]);
        }
        return addrs;
    }

    // Confirm that the signature triplets (v1, r1, s1) (v2, r2, s2) ...
    // authorize a spend of this contract's funds to the given destination address.
    function _validSignature(address destination, bytes[] memory signature, bytes memory data) private returns (bool) {
        address[] memory addrs = new address[](signature.length);
        for (uint i = 0; i < signature.length; i++) {
            //recover the address associated with the public key from elliptic curve signature or return zero on error
            bytes32 message = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(address(this), destination, data, spendNonce, CHAINID)));
            addrs[i] = ECDSA.recover(message, signature[i]);
        }
        require(_distinctOwners(addrs));
        _updateActiveTime(addrs); //update addrs' active timestamp

        //check again, this is important to prevent inactive owners from stealing the money.
        require(signature.length >= getRequiredWithoutInactive(), "Active owners updated after the call, please call active() before calling spend.");

        return true;
    }

    // Confirm the addresses as distinct owners of this contract.
    function _distinctOwners(address[] memory addrs) private view returns (bool) {
        if (addrs.length > owners.length) {
            return false;
        }
        for (uint i = 0; i < addrs.length; i++) {
            //> 0 means one of the owner
            if (ownerActiveTimeMap[addrs[i]] == 0) {
                return false;
            }
            //address should be distinct
            for (uint j = 0; j < i; j++) {
                if (addrs[i] == addrs[j]) {
                    return false;
                }
            }
        }
        return true;
    }

    //update the active block number for those owners
    function _updateActiveTime(address[] memory addrs) private {
        for (uint i = 0; i < addrs.length; i++) {
            //only update active timestamp for owners
            if (ownerActiveTimeMap[addrs[i]] > 0) {
                ownerActiveTimeMap[addrs[i]] = block.timestamp;
            }
        }
    }
}
