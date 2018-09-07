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
}
