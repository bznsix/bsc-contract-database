// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Sign.sol";
import "./Fallback.sol";

contract InscriptionReceive is Ownable , EIP712Decoder, Fallback{
    
    event CallData(address indexed caller, bytes data);

    Info public info;
    mapping(address => uint) public userCliam;
    
    bytes32 DOMAIN_SEPARATOR;

    struct Info {
        bytes addressHash;
        uint index;
        address signer;
    }
    
    constructor() {
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                eip712domainTypehash,
                keccak256("InscriptionReceive"),
                keccak256("1"),
                block.chainid,
                address(this)
            )
        );
    }
    function intToBytes8 (uint i) internal pure returns(bytes8 m){
        bytes memory b = new bytes(32);
        assembly {mstore(add(b, 32), i)}
        (,,,m) = bar(bytes32(b));
    }

    function bar(bytes32 r) internal pure returns (bytes8 i, bytes8 j, bytes8 k, bytes8 m) {
        i = bytes8(r);
        j = bytes8(r << 64*1);
        k = bytes8(r << 64*2);
        m = bytes8(r << 64*3);
    }

    function callData(address caller, bytes memory data) internal {
        (bool sent, ) = caller.call(data);
        emit CallData(caller, data);
        require(sent, "Failed to send");
    }
    

    function getDomainHash () public view override returns (bytes32) {
        return DOMAIN_SEPARATOR;
    }

    function mint(uint count) external onlyOwner {
        for (uint i = 0; i < count; i++) {
            bytes memory inscription = bytes(
                'data:,{"p":"brc-20","op":"mint","tick":"wowo","amt":"10"}'
            );
            (bool sent, ) = address(this).call(inscription);
            require(sent, "Failed to send");
        }
    }

    function setInfo (Info calldata info_) external onlyOwner{
        info = info_;
    }

    function retrievalIns(uint start, uint end) external onlyOwner {
        while (start <= end) {
           callData(msg.sender, abi.encodePacked(info.addressHash, intToBytes8(start++))); 
        }
    }

    function claim(address to, uint num, bytes calldata signature) external {
        require(info.signer == verifySignedClaim(SignedClaim(Claim(to, num, userCliam[msg.sender]), signature, address(0))));
        uint end = info.index + num;
        for (uint i = info.index; i < end; i++) {
            callData(to, abi.encodePacked(info.addressHash, intToBytes8(i))); 
            info.index++;
            userCliam[msg.sender]++;
        }
    }  

    function claimBatch(address[] calldata accounts) external onlyOwner {
        uint index = info.index;
        for (uint i; i < accounts.length; i++) {
            callData(accounts[i], abi.encodePacked(info.addressHash, intToBytes8(index + i))); 
        }
        info.index += (accounts.length - 1);
    }
}pragma solidity ^0.8.13;
// SPDX-License-Identifier: MIT


struct SignedClaim {
  Claim message;
  bytes signature;
  address signer;
}

bytes32 constant signedclaimTypehash = keccak256("SignedClaim(Claim message,bytes signature,address signer)Claim(address to,uint256 num,uint256 index)");

struct EIP712Domain {
  string name;
  string version;
  uint256 chainId;
  address verifyingContract;
}

bytes32 constant eip712domainTypehash = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

struct Claim {
  address to;
  uint256 num;
  uint256 index;
}

bytes32 constant claimTypehash = keccak256("Claim(address to,uint256 num,uint256 index)");


abstract contract ERC1271Contract {
  /**
   * @dev Should return whether the signature provided is valid for the provided hash
   * @param _hash      Hash of the data to be signed
   * @param _signature Signature byte array associated with _hash
   *
   * MUST return the bytes4 magic value 0x1626ba7e when function passes.
   * MUST NOT modify state (using STATICCALL for solc < 0.5, view modifier for solc > 0.5)
   * MUST allow external calls
   */ 
  function isValidSignature(
    bytes32 _hash, 
    bytes memory _signature)
    public
    view 
    virtual
    returns (bytes4 magicValue);
}

abstract contract EIP712Decoder {
  function getDomainHash () public view virtual returns (bytes32);


  /**
  * @dev Recover signer address from a message by using their signature
  * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
  * @param sig bytes signature, the signature is generated using web3.eth.sign()
  */
  function recover(bytes32 hash, bytes memory sig) internal pure returns (address) {
    bytes32 r;
    bytes32 s;
    uint8 v;

    // Check the signature length
    if (sig.length != 65) {
      return (address(0));
    }

    // Divide the signature in r, s and v variables
    assembly {
      r := mload(add(sig, 32))
      s := mload(add(sig, 64))
      v := byte(0, mload(add(sig, 96)))
    }
    // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
    if (v < 27) {
      v += 27;
    }

    // If the version is correct return the signer address
    if (v != 27 && v != 28) {
      return (address(0));
    } else {
      return ecrecover(hash, v, r, s);
    }
  }

function getSignedclaimPacketHash (SignedClaim memory _input) public pure returns (bytes32) {
  bytes memory encoded = abi.encode(
    signedclaimTypehash,
    getClaimPacketHash(_input.message),
      keccak256(_input.signature),
      _input.signer
  );
  return keccak256(encoded);
}


function getEip712DomainPacketHash (EIP712Domain memory _input) public pure returns (bytes32) {
  bytes memory encoded = abi.encode(
    eip712domainTypehash,
    keccak256(bytes(_input.name)),
      keccak256(bytes(_input.version)),
      _input.chainId,
      _input.verifyingContract
  );
  return keccak256(encoded);
}


function getClaimPacketHash (Claim memory _input) public pure returns (bytes32) {
  bytes memory encoded = abi.encode(
    claimTypehash,
    _input.to,
      _input.num,
      _input.index
  );
  return keccak256(encoded);
}


  function verifySignedClaim(SignedClaim memory _input) public view returns (address) {
    bytes32 packetHash = getClaimPacketHash(_input.message);
    bytes32 digest = keccak256(
      abi.encodePacked(
        "\x19\x01",
        getDomainHash(),
        packetHash
      )
    );

    if (_input.signer == 0x0000000000000000000000000000000000000000) {
      address recoveredSigner = recover(
        digest,
        _input.signature
      );
      return recoveredSigner;
    } else {
      // EIP-1271 signature verification
      bytes4 result = ERC1271Contract(_input.signer).isValidSignature(digest, _input.signature);
      require(result == 0x1626ba7e, "INVALID_SIGNATURE");
      return _input.signer;
    }
  }
  

}


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Fallback {
    event Log(string func, uint gas);

    // Fallback function must be declared as external.
    fallback() external payable {
        // send / transfer (forwards 2300 gas to this fallback function)
        // call (forwards all of the gas)
        emit Log("fallback", gasleft());
    }

    // Receive is a variant of fallback that is triggered when msg.data is empty
    receive() external payable {
        emit Log("receive", gasleft());
    }

    // Helper function to check the balance of this contract
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}
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
