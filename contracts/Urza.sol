//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

import "@semaphore-protocol/contracts/interfaces/IVerifier.sol";
import "@semaphore-protocol/contracts/base/SemaphoreCore.sol";
import "@semaphore-protocol/contracts/base/SemaphoreGroups.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Urza is SemaphoreCore, SemaphoreGroups, Ownable {

    string public name = "Urza";

    // EVENTS


    // STRUCTS
    // type of a single group chat
    struct Group {
        address groupManager;
        bytes32 groupId;
        bytes32 contentId;
        uint allowance;
        uint messageCount;
        // merkle of allowed members
    }
    // type of a single message in a group
    struct Message {
        bytes32 messageId;
        bytes32 contentId;
        uint256 likes;
        // .. add time here?
    }

    // MAPPINGS
    mapping(bytes32 => uint256[]) public groupIdentityCommitments;
    mapping(bytes32 => string) public contentRegistry;
    mapping(bytes32 => Group) public groupRegistry;
    mapping(bytes32 => bytes32[]) public groupQuestionList;

    // CONSTANTS
    // groups can either be active accepting messages or be on pause
    uint256 constant PAUSED = 1;
    uint256 constant ACTIVE = 2;
    // minimum fee
    uint256 fee = 10000000000000000000;

    // the external verifier used to verify Semaphore proofs.
    IVerifier public verifier;
    
    constructor(address _verifier) {
        verifier = IVerifier(_verifier);
    }

    // MODIFIERS
    

    // FUNCTIONS
    
}