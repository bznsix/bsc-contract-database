// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {SupraGeneratorContract} from "./SupraGeneratorContract.sol";

/// @title VRF Generator Contract for L1 chains
/// @author Supra Developer
/// @notice This contract will generate random number based on the router contract request
/// @dev All function calls are currently implemented without side effects

contract SupraGeneratorContractL1 is
    SupraGeneratorContract
{
    constructor(
        bytes32 _domain,
        address _supraRouterContract,
        uint256[4] memory _publicKey,
        uint256 _instanceId,
        uint256 _blsPreCompileGasCost,
        uint256 _gasAfterPaymentCalculation
    ) public SupraGeneratorContract(_domain, _supraRouterContract, _publicKey, _instanceId, _blsPreCompileGasCost,_gasAfterPaymentCalculation) {}

    /// @dev Calculate the transaction fee for the callback transaction for Arbitrum
    /// @param _startGas The gas at the start of the transaction
    /// @param _gasAfterPaymentCalculation calculated gas value to be used based on iterative tests
    /// @return paymentWithoutFee The total estimated transaction fee for callback
    function calculatePaymentAmount(
        uint256 _startGas,
        uint256 _gasAfterPaymentCalculation
    ) internal override view returns (uint256) {
        // TransactionFee =  ChainGasCost  * ( gasAfterPaymentCalculation + gasUsedL1)
        uint256 paymentWithoutFee = tx.gasprice *
            (_gasAfterPaymentCalculation + _startGas - gasleft());
        return paymentWithoutFee;
    }

}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./BLS.sol";
import {ReentrancyGuard} from "./ReentrancyGuard.sol";
import {Ownable2Step} from "./Ownable2Step.sol";
import {CheckContractAddress} from "./CheckContractAddress.sol";
import {EnumerableSet} from "./EnumerableSet.sol";
import {ISupraRouterContract} from "./ISupraRouterContract.sol";
import {IDepositContract} from "./IDepositContract.sol";


/// @title VRF Generator Contract
/// @author Supra Developer
/// @notice This contract will generate random number based on the router contract request
/// @dev All function calls are currently implemented without side effects

abstract contract SupraGeneratorContract is
    ReentrancyGuard,
    Ownable2Step,
    CheckContractAddress
{
    /// @dev Public key
    uint256[4] public publicKey;

    /// @dev Domain
    bytes32 public domain;

    /// @dev Address of VRF Router contract
    address public supraRouterContract;

    address public depositContract;

    /// @dev BlockNumber
    uint256 internal blockNum = 0;

    /// @dev Instance Identification Number
    uint256 public instanceId;

    /// @dev Gas to be used for callback transaction fee
    uint256 public gasAfterPaymentCalculation;

    /// @dev Pre Compile Gas cost estimation value
    uint256 blsPreCompileGasCost;

    /// @dev A mapping that will keep track of all the nonces used, true means used and false means not used
    mapping(uint256 => bool) internal nonceUsed;

    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet private whitelistedFreeNodes;

    /// @notice It will put the logs for the Generated request with necessary parameters
    /// @dev This event will be emitted when random number request generated
    /// @param nonce nonce is an incremental counter which is associated with request
    /// @param instanceId Instance Identification Number
    /// @param callerContract Contract address from which request has been generated
    /// @param functionName Function which we have to callback to fulfill request
    /// @param rngCount Number of random numbers requested
    /// @param numConfirmations Number of Confirmations
    /// @param clientSeed Client seed is used to add extra randomness
    /// @param clientWalletAddress is the wallet to which the request is associated
    event RequestGenerated(
        uint256 nonce,
        uint256 instanceId,
        address callerContract,
        string functionName,
        uint8 rngCount,
        uint256 numConfirmations,
        uint256 clientSeed,
        address clientWalletAddress
    );

    /// @notice To put log regarding updation of Public key
    /// @dev This event will be emmitted in whenever there is a request to update Public Key
    /// @param _timestamp epoch time when Public key has been updated
    event PublicKeyUpdated(uint256 _timestamp);

    /// @notice It will put log for the nonce value for which request has been fulfilled
    /// @dev It will be emitted when callback to the Router contract has been made
    /// @param nonce nonce is an incremental counter which is associated with request
    /// @param clientWalletAddress is the address through which the request is generated and the nonce is associated
    /// @param timestamp epoch time when a particular nonce was processed
    /// @param rngSuccess status for the callback transaction
    event NonceProcessed(
        uint256 nonce,
        address clientWalletAddress,
        uint256 timestamp,
        bool rngSuccess
    );

    /// @notice It will put log to the individual free node wallets those added to the whitelist
    /// @dev It will be emitted once the free node is added to the whitelist
    /// @param freeNodeWalletAddress is the address through which free node wallet is to be whitelisted
    event FreeNodeWhitelisted(address freeNodeWalletAddress);

    /// @notice It will put log to the multiple free node wallets those added to the whitelist in bulk
    /// @dev It will be emitted once multiple free nodes are added to the whitelist
    /// @param freeNodeWallets is the array of address through which is multiple free nodes are to be whitelisted
    event MultipleFreeNodesWhitelisted(address[] freeNodeWallets);

    /// @notice It will put log to the individual free node wallets those removed from the whitelist
    /// @dev It will be emitted once the free node is removed from the whitelist
    /// @param freeNodeWallet is the address which to be removed from the whitelist
    event FreeNodeRemovedFromWhitelist(address freeNodeWallet);

    constructor(
        bytes32 _domain,
        address _supraRouterContract,
        uint256[4] memory _publicKey,
        uint256 _instanceId,
        uint256 _blsPreCompileGasCost,
        uint256 _gasAfterPaymentCalculation
    ) {
        publicKey = _publicKey;
        domain = _domain;
        supraRouterContract = _supraRouterContract;
        instanceId = _instanceId;
        blsPreCompileGasCost = _blsPreCompileGasCost;
        gasAfterPaymentCalculation = _gasAfterPaymentCalculation;
    }

    /// @dev Set the gas required for callback transaction based on calculations
    /// @param _newGas The gas at the start of the transaction
    // Need to be setup in advance
    function setGasAfterPaymentCalculation(uint256 _newGas) external onlyOwner {
        gasAfterPaymentCalculation = _newGas;
    }

    /// @dev Generates a random number and initiates an RNG callback while handling payment processing.
    /// @param _nonce Nonce for the RNG request.
    /// @param _bhash Hash of the block where the request was made.
    /// @param _message Hash of the encoded data.
    /// @param _signature Signature of the message.
    /// @param _rngCount Number of random numbers to generate.
    /// @param _clientSeed Seed provided by the client.
    /// @param _callerContract Address of the calling contract.
    /// @param _func Name of the calling function.
    /// @param _clientWalletAddress Address of the client's wallet.
    /// @return _rngSuccess Indicates if the RNG callback was successful.
    /// @return paymentSuccess Indicates if the payment processing was successful.
    /// @return data Additional data returned from the RNG callback.
    function generateRngCallback(
        uint256 _nonce,
        bytes32 _bhash,
        bytes memory _message,
        uint256[2] calldata _signature,
        uint8 _rngCount,
        uint256 _clientSeed,
        address _callerContract,
        string calldata _func,
        address _clientWalletAddress
    )
        public
        nonReentrant
        returns (
            bool,
            bool,
            bytes memory
        )
    {
        uint256 startGas = gasleft();
        require(
            gasAfterPaymentCalculation != 0,
            "Generator_SC: Gas payment after calculation must be set!"
        );

        (bool _rngSuccess, bytes memory data) = _generateRngCallback(
            _nonce,
            _bhash,
            _message,
            _signature,
            _rngCount,
            _clientSeed,
            _callerContract,
            _func
        );
        uint256 _txnFee;
        _txnFee = calculatePaymentAmount(
                startGas,
                gasAfterPaymentCalculation
            );
        

        /** 
            :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
                Method will call deposit contract and collect the fund from client's deposits to Supra fund.
            :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
        */
        
        bytes memory encodedMethodWithParam = abi.encodeCall(
            IDepositContract.collectFund,
            (_clientWalletAddress,
            _txnFee)
        );

        (bool paymentSuccess, ) = address(depositContract).call(encodedMethodWithParam);
        require(paymentSuccess,"Payment Failed");
        emit NonceProcessed(_nonce, _clientWalletAddress, block.timestamp, _rngSuccess);

        return (_rngSuccess, paymentSuccess, data);
        
    }

    /// @dev Calculate the transaction fee for the callback transaction for Arbitrum
    /// @param _startGas The gas at the start of the transaction
    /// @param _gasAfterPaymentCalculation calculated gas value to be used based on iterative tests
    /// @return paymentWithoutFee The total estimated transaction fee for callback
    function calculatePaymentAmount(
        uint256 _startGas,
        uint256 _gasAfterPaymentCalculation
    ) internal virtual view returns (uint256) {}

    /// @dev Generates a random number internally.
    /// @param _nonce Nonce for the RNG request.
    /// @param _bhash Hash of the block where the request was made.
    /// @param _message Hash of the encoded data.
    /// @param _signature Signature of the message.
    /// @param _rngCount Number of random numbers to generate.
    /// @param _clientSeed Seed provided by the client.
    /// @param _callerContract Address of the calling contract.
    /// @param _func Name of the calling function.
    /// @return success Indicates if the processing was successful.
    /// @return data Additional data returned from the RNG callback.
    function _generateRngCallback(
        uint256 _nonce,
        bytes32 _bhash,
        bytes memory _message,
        uint256[2] calldata _signature,
        uint8 _rngCount,
        uint256 _clientSeed,
        address _callerContract,
        string calldata _func
    ) internal returns (bool, bytes memory) {
        require(
            isFreeNodeWhitelisted(msg.sender),
            "Free node is not whitelisted"
        );
        require(!nonceUsed[_nonce], "Nonce has already been processed");

        // Verify that the passed parameters do indeed hash to _message to ensure that the params
        // are not spoofed
        bytes memory encoded_data = abi.encode(
            _bhash,
            _nonce,
            _rngCount,
            instanceId,
            _callerContract,
            _func,
            _clientSeed
        );
        bytes32 keccak_encoded = keccak256(encoded_data);
        require(
            keccak_encoded == bytes32(_message),
            "Cannot verify the message"
        );
        // Verify the signature using the public key
        verify(_message, _signature);
        // Generate a random number
        // Use the signature as a seed and some transaction parameters, generate hash and convert to uint for random number
        uint256[] memory rngList = new uint256[](_rngCount);
        for (uint256 loop = 0; loop < _rngCount; ++loop) {
            rngList[loop] = uint256(
                keccak256(abi.encodePacked(_signature, loop + 1))
            );
        }
        (bool success, bytes memory data) = supraRouterContract.call(
            abi.encodeCall(
                ISupraRouterContract.rngCallback,
                (_nonce,
                rngList,
                _callerContract,
                _func)
            )
        );

        nonceUsed[_nonce] = true;
        return (success, data);
    }

    /// @notice This function is used to generate random number request
    /// @dev This function will be called from router contract which is for the random number generation request
    /// @param _nonce nonce is an incremental counter which is associated with request
    /// @param _callerContract Actual client contract address from which request has been generated
    /// @param _functionName A combination of a function and the types of parameters it takes, combined together as a string with no spaces
    /// @param _rngCount Number of random numbers requested
    /// @param _numConfirmations Number of Confirmations
    /// @param _clientSeed Use of this is to add some extra randomness
    function rngRequest(
        uint256 _nonce,
        string memory _functionName,
        uint8 _rngCount,
        address _callerContract,
        uint256 _numConfirmations,
        uint256 _clientSeed,
        address _clientWalletAddress
    ) external {
        require(
            msg.sender == supraRouterContract,
            "Only router contract can execute this function"
        );
        emit RequestGenerated(
            _nonce,
            instanceId,
            _callerContract,
            _functionName,
            _rngCount,
            _numConfirmations,
            _clientSeed,
            _clientWalletAddress
        );
    }

    /// @notice The function will whitelist a single free node wallet
    /// @dev The function will whitelist a single free node at a time and will only be updated by the owner
    /// @param _freeNodeWallet this is the wallet address to be whitelisted
    function addFreeNodeToWhitelistSingle(address _freeNodeWallet)
        external
        onlyOwner
    {
        require(
            !isFreeNodeWhitelisted(_freeNodeWallet),
            "Free Node is already whitelisted"
        );
        whitelistedFreeNodes.add(_freeNodeWallet);
        emit FreeNodeWhitelisted(_freeNodeWallet);
    }

    /// @notice The function will whitelist multiple free node wallets
    /// @dev The function will whitelist multiple free node addresses passed altogether in an array
    /// @param _freeNodeWallets it is an array of address type, which accepts all the addresses to whitelist altogether
    function addFreeNodeToWhitelistBulk(address[] memory _freeNodeWallets)
        external
        onlyOwner
    {   
        address[] memory freeNodeWallets = new address[](_freeNodeWallets.length);
        for (uint256 loop = 0; loop < _freeNodeWallets.length; ++loop) {
            if(!isFreeNodeWhitelisted(_freeNodeWallets[loop])){
                whitelistedFreeNodes.add(_freeNodeWallets[loop]);
                freeNodeWallets[loop] = _freeNodeWallets[loop];
            }           
        }
        emit MultipleFreeNodesWhitelisted(freeNodeWallets);
    }

    /// @notice The function will remove the address from the whitelist
    /// @dev The function will remove the already whitelisted free node wallet
    /// @param _freeNodeWallet this is the wallet address that is to be removed from the list of whitelisted free node
    function removeFreeNodeFromWhitelist(address _freeNodeWallet)
        external
        onlyOwner
    {
        bool result = whitelistedFreeNodes.remove(_freeNodeWallet);
        require(result, "Free Node not whitelisted or already removed");
        emit FreeNodeRemovedFromWhitelist(_freeNodeWallet);
    }

    /// @notice The function will check if an address is whitelisted or not
    /// @dev The function will check if a particular free node is whitelisted or not and will return a boolean value accordingly
    /// @param _freeNodeWallet this is the wallet address to check if it is whitelisted or not
    function isFreeNodeWhitelisted(address _freeNodeWallet)
        public
        view
        returns (bool)
    {
        return whitelistedFreeNodes.contains(_freeNodeWallet);
    }

    /// @notice The function will return the list of whitelisted free nodes
    /// @dev The function will check for all the whitelisted free node wallets and return the list
    function listAllWhitelistedFreeNodes()
        external
        view
        onlyOwner
        returns (address[] memory)
    {
        address[] memory freenodes = new address[](
            whitelistedFreeNodes.length()
        );
        for (uint256 loop = 0; loop < whitelistedFreeNodes.length(); ++loop) {
            address value = whitelistedFreeNodes.at(loop);
            freenodes[loop] = value;
        }
        return freenodes;
    }

    /// @notice This function will be used to update public key
    /// @dev Update the public key state variable
    /// @param _publicKey New Public key which will update the old one
    /// @return bool It returns the status of updation of public key
    function updatePublicKey(uint256[4] memory _publicKey)
        external
        onlyOwner
        returns (bool)
    {
        publicKey = _publicKey;
        emit PublicKeyUpdated(block.timestamp);
        return true;
    }

    /// @notice This function is for updating the Deposit Contract Address
    /// @dev To update deposit contract address
    /// @param _newDepositSC contract address of the deposit/new deposit contract
    function updateDepositContract(address _newDepositSC) external onlyOwner {
        require(
            isContract(_newDepositSC),
            "Deposit contract address cannot be EOA"
        );
        require(
            _newDepositSC != address(0),
            "Deposit contract address cannot be a zero address"
        );
        depositContract = _newDepositSC;
    }

    function verify(bytes memory _message, uint256[2] calldata _signature)
        internal
        view
    {
        bool callSuccess;
        bool checkSuccess;
        (checkSuccess, callSuccess) = BLS.verifySingle(
            _signature,
            publicKey,
            BLS.hashToPoint(domain, _message),
            blsPreCompileGasCost
        );

        require(
            callSuccess,
            "Verify : Incorrect Public key or Signature Points"
        );
        require(checkSuccess, "Verify : Incorrect Input Message");
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ModexpInverse, ModexpSqrt} from "./ModExp.sol";
import {BNPairingPrecompileCostEstimator} from "./BNPairingPrecompileCostEstimator.sol";

library BLS {
    uint256 private constant N = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
    uint256 private constant N_G2_X1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 private constant N_G2_X0 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 private constant N_G2_Y1 = 17805874995975841540914202342111839520379459829704422454583296818431106115052;
    uint256 private constant N_G2_Y0 = 13392588948715843804641432497768002650278120570034223513918757245338268106653;
    uint256 private constant Z0 = 0x0000000000000000b3c4d79d41a91759a9e4c7e359b6b89eaec68e62effffffd;
    uint256 private constant Z1 = 0x000000000000000059e26bcea0d48bacd4f263f1acdb5c4f5763473177fffffe;
    uint256 private constant T24 = 0x1000000000000000000000000000000000000000000000000;
    uint256 private constant MASK24 = 0xffffffffffffffffffffffffffffffffffffffffffffffff;

    address private constant COST_ESTIMATOR_ADDRESS = 0x079d8077C465BD0BF0FC502aD2B846757e415661;

    function verifySingle(
        uint256[2] memory signature,
        uint256[4] memory pubkey,
        uint256[2] memory message,
        uint256 precompileGasCost
    ) internal view returns (bool, bool) {
        uint256[12] memory input = [
            signature[0],
            signature[1],
            N_G2_X1,
            N_G2_X0,
            N_G2_Y1,
            N_G2_Y0,
            message[0],
            message[1],
            pubkey[1],
            pubkey[0],
            pubkey[3],
            pubkey[2]
        ];
        uint256[1] memory out;
        bool callSuccess;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            callSuccess := staticcall(precompileGasCost, 8, input, 384, out, 0x20)
        }
        if (!callSuccess) {
            return (false, false);
        }
        return (out[0] != 0, true);
    }

    function verifyMultiple(uint256[2] memory signature, uint256[4][] memory pubkeys, uint256[2][] memory messages)
        internal
        view
        returns (bool checkResult, bool callSuccess)
    {
        uint256 size = pubkeys.length;
        require(size > 0, "BLS: number of public key is zero");
        require(size == messages.length, "BLS: number of public keys and messages must be equal");
        uint256 inputSize = (size + 1) * 6;
        uint256[] memory input = new uint256[](inputSize);
        input[0] = signature[0];
        input[1] = signature[1];
        input[2] = N_G2_X1;
        input[3] = N_G2_X0;
        input[4] = N_G2_Y1;
        input[5] = N_G2_Y0;
        for (uint256 i = 0; i < size; i++) {
            input[i * 6 + 6] = messages[i][0];
            input[i * 6 + 7] = messages[i][1];
            input[i * 6 + 8] = pubkeys[i][1];
            input[i * 6 + 9] = pubkeys[i][0];
            input[i * 6 + 10] = pubkeys[i][3];
            input[i * 6 + 11] = pubkeys[i][2];
        }
        uint256[1] memory out;

        uint256 precompileGasCost = BNPairingPrecompileCostEstimator(COST_ESTIMATOR_ADDRESS).getGasCost(size + 1);
        assembly {
            callSuccess := staticcall(precompileGasCost, 8, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
        }
        if (!callSuccess) {
            return (false, false);
        }
        return (out[0] != 0, true);
    }

    function hashToPoint(bytes32 domain, bytes memory message) internal view returns (uint256[2] memory) {
        uint256[2] memory u = hashToField(domain, message);
        uint256[2] memory p0 = mapToPoint(u[0]);
        uint256[2] memory p1 = mapToPoint(u[1]);
        uint256[4] memory bnAddInput;
        bnAddInput[0] = p0[0];
        bnAddInput[1] = p0[1];
        bnAddInput[2] = p1[0];
        bnAddInput[3] = p1[1];
        bool success;

        assembly {
            success := staticcall(sub(gas(), 2000), 6, bnAddInput, 128, p0, 64)
            switch success
            case 0 { invalid() }
        }
        require(success, "BLS: bn add call failed");
        return p0;
    }

    function mapToPoint(uint256 _x) internal pure returns (uint256[2] memory p) {
        require(_x < N, "mapToPointFT: invalid field element");
        uint256 x = _x;

        (, bool decision) = sqrt(x);

        uint256 a0 = mulmod(x, x, N);
        a0 = addmod(a0, 4, N);
        uint256 a1 = mulmod(x, Z0, N);
        uint256 a2 = mulmod(a1, a0, N);
        a2 = inverse(a2);
        a1 = mulmod(a1, a1, N);
        a1 = mulmod(a1, a2, N);

        // x1
        a1 = mulmod(x, a1, N);
        x = addmod(Z1, N - a1, N);
        // check curve
        a1 = mulmod(x, x, N);
        a1 = mulmod(a1, x, N);
        a1 = addmod(a1, 3, N);
        bool found;
        (a1, found) = sqrt(a1);
        if (found) {
            if (!decision) {
                a1 = N - a1;
            }
            return [x, a1];
        }

        // x2
        x = N - addmod(x, 1, N);
        // check curve
        a1 = mulmod(x, x, N);
        a1 = mulmod(a1, x, N);
        a1 = addmod(a1, 3, N);
        (a1, found) = sqrt(a1);
        if (found) {
            if (!decision) {
                a1 = N - a1;
            }
            return [x, a1];
        }

        // x3
        x = mulmod(a0, a0, N);
        x = mulmod(x, x, N);
        x = mulmod(x, a2, N);
        x = mulmod(x, a2, N);
        x = addmod(x, 1, N);
        // must be on curve
        a1 = mulmod(x, x, N);
        a1 = mulmod(a1, x, N);
        a1 = addmod(a1, 3, N);
        (a1, found) = sqrt(a1);
        require(found, "BLS: bad ft mapping implementation");
        if (!decision) {
            a1 = N - a1;
        }
        return [x, a1];
    }

    function isValidSignature(uint256[2] memory signature) internal pure returns (bool) {
        if ((signature[0] >= N) || (signature[1] >= N)) {
            return false;
        } else {
            return isOnCurveG1(signature);
        }
    }

    function isOnCurveG1(uint256[2] memory point) internal pure returns (bool _isOnCurve) {
        assembly {
            let t0 := mload(point)
            let t1 := mload(add(point, 32))
            let t2 := mulmod(t0, t0, N)
            t2 := mulmod(t2, t0, N)
            t2 := addmod(t2, 3, N)
            t1 := mulmod(t1, t1, N)
            _isOnCurve := eq(t1, t2)
        }
    }

    function isOnCurveG2(uint256[4] memory point) internal pure returns (bool _isOnCurve) {
        assembly {
            // x0, x1
            let t0 := mload(point)
            let t1 := mload(add(point, 32))
            // x0 ^ 2
            let t2 := mulmod(t0, t0, N)
            // x1 ^ 2
            let t3 := mulmod(t1, t1, N)
            // 3 * x0 ^ 2
            let t4 := add(add(t2, t2), t2)
            // 3 * x1 ^ 2
            let t5 := addmod(add(t3, t3), t3, N)
            // x0 * (x0 ^ 2 - 3 * x1 ^ 2)
            t2 := mulmod(add(t2, sub(N, t5)), t0, N)
            // x1 * (3 * x0 ^ 2 - x1 ^ 2)
            t3 := mulmod(add(t4, sub(N, t3)), t1, N)

            // x ^ 3 + b
            t0 := addmod(t2, 0x2b149d40ceb8aaae81be18991be06ac3b5b4c5e559dbefa33267e6dc24a138e5, N)
            t1 := addmod(t3, 0x009713b03af0fed4cd2cafadeed8fdf4a74fa084e52d1852e4a2bd0685c315d2, N)

            // y0, y1
            t2 := mload(add(point, 64))
            t3 := mload(add(point, 96))

            t4 := mulmod(addmod(t2, t3, N), addmod(t2, sub(N, t3), N), N)
            t3 := mulmod(shl(1, t2), t3, N)

            _isOnCurve := and(eq(t0, t4), eq(t1, t3))
        }
    }

    function sqrt(uint256 xx) internal pure returns (uint256 x, bool hasRoot) {
        x = ModexpSqrt.run(xx);
        hasRoot = mulmod(x, x, N) == xx;
    }

    function inverse(uint256 a) internal pure returns (uint256) {
        return ModexpInverse.run(a);
    }

    function hashToField(bytes32 domain, bytes memory messages) internal pure returns (uint256[2] memory) {
        bytes memory _msg = expandMsgTo96(domain, messages);
        uint256 u0;
        uint256 u1;
        uint256 a0;
        uint256 a1;
        assembly {
            let p := add(_msg, 24)
            u1 := and(mload(p), MASK24)
            p := add(_msg, 48)
            u0 := and(mload(p), MASK24)
            a0 := addmod(mulmod(u1, T24, N), u0, N)
            p := add(_msg, 72)
            u1 := and(mload(p), MASK24)
            p := add(_msg, 96)
            u0 := and(mload(p), MASK24)
            a1 := addmod(mulmod(u1, T24, N), u0, N)
        }
        return [a0, a1];
    }

    function expandMsgTo96(bytes32 domain, bytes memory message) internal pure returns (bytes memory) {
        uint256 t0 = message.length;
        bytes memory msg0 = new bytes(32 + t0 + 64 + 4);
        bytes memory out = new bytes(96);

        assembly {
            let p := add(msg0, 96)
            for { let z := 0 } lt(z, t0) { z := add(z, 32) } { mstore(add(p, z), mload(add(message, add(z, 32)))) }
            p := add(p, t0)

            mstore8(p, 0)
            p := add(p, 1)
            mstore8(p, 96)
            p := add(p, 1)
            mstore8(p, 0)
            p := add(p, 1)

            mstore(p, domain)
            p := add(p, 32)
            mstore8(p, 32)
        }
        bytes32 b0 = sha256(msg0);
        bytes32 bi;
        t0 = 32 + 34;

        assembly {
            mstore(msg0, t0)
        }
        assembly {
            mstore(add(msg0, 32), b0)
            mstore8(add(msg0, 64), 1)
            mstore(add(msg0, 65), domain)
            mstore8(add(msg0, add(32, 65)), 32)
        }

        bi = sha256(msg0);

        assembly {
            mstore(add(out, 32), bi)
        }
        assembly {
            let t := xor(b0, bi)
            mstore(add(msg0, 32), t)
            mstore8(add(msg0, 64), 2)
            mstore(add(msg0, 65), domain)
            mstore8(add(msg0, add(32, 65)), 32)
        }

        bi = sha256(msg0);

        assembly {
            mstore(add(out, 64), bi)
        }
        assembly {
            let t := xor(b0, bi)
            mstore(add(msg0, 32), t)
            mstore8(add(msg0, 64), 3)
            mstore(add(msg0, 65), domain)
            mstore8(add(msg0, add(32, 65)), 32)
        }

        bi = sha256(msg0);

        assembly {
            mstore(add(out, 96), bi)
        }

        return out;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity 0.8.19;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (access/Ownable2Step.sol)

pragma solidity 0.8.19;

import "./Ownable.sol";

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
abstract contract Ownable2Step is Ownable {
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
    function acceptOwnership() public virtual {
        address sender = _msgSender();
        require(pendingOwner() == sender, "Ownable2Step: caller is not the new owner");
        _transferOwnership(sender);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract CheckContractAddress {
    /// @dev Returns a boolean indicating whether the given address is a contract or not.
    /// @param _addr The address to be checked.
    /// @return A boolean indicating whether the given address is a contract or not.
    function isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
}
/**
 * ###############################################################
 *         this is not exact replica of OpenZepplin implementation
 *     ###############################################################
 */

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity 0.8.19;

library EnumerableSet {
    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

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
     * ###################################################################################
     *         :::: this is the new method added on top of openzepplin implementation ::::
     *     ###################################################################################
     */
    function _clear(Set storage set) private returns (bool) {
        for (uint256 i = 0; i < set._values.length; i++) {
            delete set._indexes[set._values[i]];
        }
        delete set._values;
        return true;
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
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

    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function clear(AddressSet storage set) internal returns (bool) {
        return _clear(set._inner);
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

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

    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

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
pragma solidity 0.8.19;

interface ISupraRouterContract {
    function generateRequest(
        string memory _functionSig,
        uint8 _rngCount,
        uint256 _numConfirmations,
        uint256 _clientSeed,
        address _clientWalletAddress
    ) external returns (uint256);

    function generateRequest(
        string memory _functionSig,
        uint8 _rngCount,
        uint256 _numConfirmations,
        address _clientWalletAddress
    ) external returns (uint256);

    function rngCallback(
        uint256 nonce,
        uint256[] memory rngList,
        address _clientContractAddress,
        string memory _functionSig
    ) external returns (bool, bytes memory) ;
}
// INSTRUCTIONS : Contains methods that will be used by the ROUTER and GENERATOR contracts.
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IDepositContract {
    function isContractEligible(address _clientAddress, address _contractAddress) external view returns (bool);

    function isMinimumBalanceReached(address _clientAddress) external view returns (bool);

    function checkMinBalance(address _clientAddress) external view returns (uint256);

    function checkClientFund(address _clientAddress) external view returns (uint256);

    function collectFund(address _clientAddress, uint256 _amount) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

library ModexpInverse {
    function run(uint256 t2) internal pure returns (uint256 t0) {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            let n := 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47
            t0 := mulmod(t2, t2, n)
            let t5 := mulmod(t0, t2, n)
            let t1 := mulmod(t5, t0, n)
            let t3 := mulmod(t5, t5, n)
            let t8 := mulmod(t1, t0, n)
            let t4 := mulmod(t3, t5, n)
            let t6 := mulmod(t3, t1, n)
            t0 := mulmod(t3, t3, n)
            let t7 := mulmod(t8, t3, n)
            t3 := mulmod(t4, t3, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t5, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t2, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t2, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t8, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t8, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t2, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t8, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t2, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t5, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t7, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t1, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t5, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t8, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t1, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t2, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t6, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t7, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t1, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t5, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t1, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t5, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t6, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t6, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t1, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t8, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t6, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t1, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t4, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t6, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t2, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t8, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t8, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t1, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t2, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t7, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t3, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t2, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t2, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t5, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t6, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t5, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t5, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t3, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t4, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t3, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t1, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t2, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t1, n)
        }
    }
}

library ModexpSqrt {
    function run(uint256 t6) internal pure returns (uint256 t0) {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            let n := 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47

            t0 := mulmod(t6, t6, n)
            let t4 := mulmod(t0, t6, n)
            let t2 := mulmod(t4, t0, n)
            let t3 := mulmod(t4, t4, n)
            let t8 := mulmod(t2, t0, n)
            let t1 := mulmod(t3, t4, n)
            let t5 := mulmod(t3, t2, n)
            t0 := mulmod(t3, t3, n)
            let t7 := mulmod(t8, t3, n)
            t3 := mulmod(t1, t3, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t4, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t6, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t6, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t8, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t8, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t6, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t8, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t6, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t4, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t7, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t2, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t4, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t8, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t2, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t6, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t5, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t7, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t2, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t4, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t2, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t4, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t5, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t5, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t2, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t8, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t5, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t2, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t1, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t5, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t6, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t8, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t8, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t2, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t6, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t7, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t3, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t6, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t6, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t4, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t5, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t4, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t4, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t3, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t1, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t3, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t2, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t0, n)
            t0 := mulmod(t0, t1, n)
            t0 := mulmod(t0, t0, n)
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract BNPairingPrecompileCostEstimator {
    uint256 public baseCost;
    uint256 public perPairCost;

    uint256 private constant G1_X = 1;
    uint256 private constant G1_Y = 2;

    uint256 private constant G2_X0 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 private constant G2_X1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 private constant G2_Y0 = 8495653923123431417604973247489272438418190587263600148770280649306958101930;
    uint256 private constant G2_Y1 = 4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 private constant N_G2_Y0 = 13392588948715843804641432497768002650278120570034223513918757245338268106653;
    uint256 private constant N_G2_Y1 = 17805874995975841540914202342111839520379459829704422454583296818431106115052;

    function run() external {
        _run();
    }

    function getGasCost(uint256 pairCount) external view returns (uint256) {
        return pairCount * perPairCost + baseCost;
    }

    function _run() internal {
        uint256 gasCost1Pair = _gasCost1Pair();
        uint256 gasCost2Pair = _gasCost2Pair();
        perPairCost = gasCost2Pair - gasCost1Pair;
        baseCost = gasCost1Pair - perPairCost;
    }

    function _gasCost1Pair() internal view returns (uint256) {
        uint256[6] memory input = [G1_X, G1_Y, G2_X1, G2_X0, G2_Y1, G2_Y0];
        uint256[1] memory out;
        bool callSuccess;
        uint256 suppliedGas = gasleft() - 2000;
        require(gasleft() > 2000, "BNPairingPrecompileCostEstimator: not enough gas, single pair");
        uint256 gasT0 = gasleft();

        assembly {
            callSuccess := staticcall(suppliedGas, 8, input, 192, out, 0x20)
        }
        uint256 gasCost = gasT0 - gasleft();
        require(callSuccess, "BNPairingPrecompileCostEstimator: single pair call is failed");
        require(out[0] == 0, "BNPairingPrecompileCostEstimator: single pair call result must be 0");
        return gasCost;
    }

    function _gasCost2Pair() internal view returns (uint256) {
        uint256[12] memory input = [G1_X, G1_Y, G2_X1, G2_X0, G2_Y1, G2_Y0, G1_X, G1_Y, G2_X1, G2_X0, N_G2_Y1, N_G2_Y0];
        uint256[1] memory out;
        bool callSuccess;
        uint256 suppliedGas = gasleft() - 2000;
        require(gasleft() > 2000, "BNPairingPrecompileCostEstimator: not enough gas, couple pair");
        uint256 gasT0 = gasleft();

        assembly {
            callSuccess := staticcall(suppliedGas, 8, input, 384, out, 0x20)
        }
        uint256 gasCost = gasT0 - gasleft();
        require(callSuccess, "BNPairingPrecompileCostEstimator: couple pair call is failed");
        require(out[0] == 1, "BNPairingPrecompileCostEstimator: couple pair call result must be 1");
        return gasCost;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity 0.8.19;

import "./Context.sol";

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
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity 0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
