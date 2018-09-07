pragma solidity ^0.4.0;

import "./ECRecovery.sol";
import "./ByteUtils.sol";


/**
 * @title PlasmaUtils
 * @dev Utilities for working with and decoding Plasma MVP transactions.
 */
library PlasmaUtils {
    /*
     * Storage
     */

    uint256 constant internal BLOCK_OFFSET = 1000000000;
    uint256 constant internal TX_OFFSET = 10000;


    /*
     * Internal functions
     */

    /**
     * @dev Given a UTXO position, returns the block number.
     * @param _utxoPosition UTXO position to decode.
     * @return The output's block number.
     */
    function getBlockNumber(uint256 _utxoPosition) internal pure returns (uint256) {
        return _utxoPosition / BLOCK_OFFSET;
    }

    /**
     * @dev Given a UTXO position, returns the transaction index.
     * @param _utxoPosition UTXO position to decode.s
     * @return The output's transaction index.
     */
    function getTxIndex(uint256 _utxoPosition) internal pure returns (uint256) {
        return (_utxoPosition % BLOCK_OFFSET) / TX_OFFSET;
    }

    /**
     * @dev Given a UTXO position, returns the output index.
     * @param _utxoPosition UTXO position to decode.
     * @return The output's index.
     */
    function getOutputIndex(uint256 _utxoPosition) internal pure returns (uint8) {
        return uint8(_utxoPosition % TX_OFFSET);
    }

    /**
     * @dev Encodes a UTXO position.
     * @param _blockNumber Block in which the transaction was created.
     * @param _txIndex Index of the transaction inside the block.
     * @param _outputIndex Which output is being referenced.
     * @return The encoded UTXO position.
     */
    function encodeUtxoPosition(
        uint256 _blockNumber,
        uint256 _txIndex,
        uint256 _outputIndex
    ) internal pure returns (uint256) {
        return (_blockNumber * BLOCK_OFFSET) + (_txIndex * TX_OFFSET) + (_outputIndex * 1);
    }

    /**
     * @dev Calculates the confirmation hash.
     * @param _txBytes RLP encoded transaction.
     * @param _sigs Signatures on the transaction.
     * @return The transaction's confirmation hash.
     */
    function getMerkleHash(bytes _txBytes, bytes _sigs) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(keccak256(_txBytes), _sigs));
    }

    /**
     * @dev Validates signatures on a transaction.
     * @param _txHash Hash of the transaction to be validated.
     * @param _signatures Signatures over the hash of the transaction.
     * @param _confirmationSignatures Signatures attesting that the transaction is in a valid block.
     * @return True if the signatures are valid, false otherwise.
     */
    function validateSignatures(
        bytes32 _txHash,
        bytes _signatures,
        bytes _confirmationSignatures
    ) internal pure returns (bool) {
        // Check that the signature lengths are correct.
        require(_signatures.length % 65 == 0, "Invalid signature length.");
        require(_signatures.length == _confirmationSignatures.length, "Mismatched signature count.");

        for (uint256 offset = 0; offset < _signatures.length; offset += 65) {
            // Slice off one signature at a time.
            bytes memory signature = ByteUtils.slice(_signatures, offset, 65);
            bytes memory confirmationSigature = ByteUtils.slice(_confirmationSignatures, offset, 65);

            // Check that the signatures match.
            bytes32 confirmationHash = keccak256(abi.encodePacked(_txHash));
            if (ECRecovery.recover(_txHash, signature) != ECRecovery.recover(confirmationHash, confirmationSigature)) {
                return false;
            }
        }

        return true;
    }
}
