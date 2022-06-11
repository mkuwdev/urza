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
    event GroupCreated(
        uint256 indexed groupId, 
        address indexed groupManager, 
        bytes32 contentId, 
    );

    event ContentAdded(
        bytes32 indexed contentId, 
        string contentUri
    );

    // STRUCTS
    // type of a single group chat
    struct Group {
        address groupManager;
        uint256 groupId;
        bytes32 contentId;
        uint allowance;
        uint messageCount;
        bool active;
        mapping(uint256 => uint256[]) groupIdentityCommitments;
        mapping(uint256 => uint256[]) groupMessageList;
        // merkle of allowed members
    }
    // type of a single message in a group
    struct Message {
        uint256 messageId;
        bytes32 contentId;
        uint256 likes;
        // .. add time here?
    }

    // MAPPINGS
    mapping(uint256 => Group) public groupRegistry;
    mapping(bytes32 => string) public contentRegistry;

    // CONSTANTS
    // minimum fee
    uint256 minimumFee = 10000000000000000000;

    // the external verifier used to verify Semaphore proofs.
    IVerifier public verifier;
    
    constructor(address _verifier) {
        verifier = IVerifier(_verifier);
    }

    // MODIFIERS
    

    // FUNCTIONS
    function createGroup(uint256 _groupId, string calldata _contentUri) external payable {
        require(
            msg.value >= minimumFee, 
            "Must be above the minimum fee!"
        );

        address _groupManager = msg.sender;
        bytes32 _contentId = keccak256(abi.encode(_contentUri));

        _createGroup(_groupId, 20, 0);

        contentRegistry[_contentId] = _contentUri;
        groupRegistry[_groupId].groupManager = _groupManager;
        groupRegistry[_groupId].groupId = _groupId;
        groupRegistry[_groupId].contentId = _contentId;
        groupRegistry[_groupId].active = true;

        emit ContentAdded(_contentId, _contentUri);
        emit GroupCreated(_groupId, _groupManager, _contentId);
    }

    
}