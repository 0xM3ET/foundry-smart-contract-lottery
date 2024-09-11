// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure functions

// SPDX-License-Identifier:MIT
pragma solidity 0.8.19;

/**
 * @title  Raffle Contract
 * @author 0xM3ET
 * @notice This contract creates a sample raffle
 * @dev    Impliments Chainlink VRF-v2.5
 */

contract Raffle {
    /** Errors */
    error Raffle__SendMoreToEnterRaffle();

    /** State Variables */
    uint256 private immutable i_entranceFee;
    address payable[] private s_players;

    /** Functions */
    constructor(uint256 _entranceFee) {
        i_entranceFee = _entranceFee;
    }

    function enterRaffle() public payable {
        // require(msg.value >= i_entranceFee, "Not Enough ETH sent!");
        if (msg.value < i_entranceFee) {
            revert Raffle__SendMoreToEnterRaffle();
        }
        s_players.push(payable(msg.sender));
    }

    function pickWinner() public {}

    /** Getter functions */
    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}

// events make migrations easier , also making frontend 'indexing' easier
