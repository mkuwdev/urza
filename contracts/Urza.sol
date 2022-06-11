//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

import "./semaphore/interfaces/IVerifier.sol";
import "./semaphore/SemaphoreCore.sol";
import "./semaphore/SemaphoreGroups.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// For production, contract will later be upgraded and split to main contract, proxy contract, storage contract
// https://cryptomarketpool.com/multiple-ways-to-upgrade-a-solidity-smart-contract/

contract Urza is SemaphoreCore, SemaphoreGroups, Ownable {

    string public name = "Urza";

    // EVENTS
    event GroupCreated(
        uint256 indexed groupId, 
        address indexed groupManager, 
        bytes32 indexed contentId
    );

    event ContentAdded(
        bytes32 indexed contentId, 
        string contentUri
    );

    event GroupStatusChange(
        uint256 indexed groupId, 
        bool indexed newState
    );

    event UserJoinedGroup(
        uint256 indexed groupid,
        uint256 indexed identityCommitment
    );

    event MessageSent(
        bytes32 indexed signal,
        uint256 indexed groupId,
        bytes32 indexed messageId
    );

    // STRUCTS
    // type of a single group chat
    struct Group {
        address groupManager;
        uint256 groupId;
        bytes32 contentId;
        uint messageCount;
        bool active;
        uint256[] identityCommitments;
        Message[] messageList;
        bool restricted;
        // merkle of allowed members
        // add allowance?
    }
    // type of a single message in a group
    struct Message {
        bytes32 messageId;
        bytes32 contentId;
        // .. add time, likes here?
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
    modifier groupValid(uint256 _groupId) {
        require(
            groupRegistry[_groupId].groupId != 0,
            "Group is not valid!"
        );
        _;
    }

    modifier onlyGroupManager(uint256 _groupId) {
        require(
            groupRegistry[_groupId].groupManager == msg.sender,
            "Only group managers are allowed to acces this function!"
        );
        _;
    }

    modifier groupPaused(uint256 _groupId) {
        require(
            groupRegistry[_groupId].active == false,
            "Group is paused!"
        );
        _;
    }

    modifier groupActive(uint256 _groupId) {
        require(
            groupRegistry[_groupId].active == true,
            "Group is active!"
        );
        _;
    }

    // FUNCTIONS
    function createGroup(
        uint256 _groupId, 
        string calldata _contentUri
    ) external payable {
        require(
            msg.value >= minimumFee, 
            "Must be above the minimum fee!"
        );

        address _groupManager = msg.sender;
        bytes32 _contentId = keccak256(abi.encodePacked(_groupId, _contentUri));

        _createGroup(_groupId, 20, 0);

        contentRegistry[_contentId] = _contentUri;
        groupRegistry[_groupId].groupManager = _groupManager;
        groupRegistry[_groupId].groupId = _groupId;
        groupRegistry[_groupId].contentId = _contentId;
        groupRegistry[_groupId].active = true;
        groupRegistry[_groupId].restricted = false;

        emit ContentAdded(_contentId, _contentUri);
        emit GroupCreated(_groupId, _groupManager, _contentId);
    }

    function startGroup(
        uint256 _groupId
    ) external groupValid(_groupId) onlyGroupManager(_groupId) groupPaused(_groupId) {
        groupRegistry[_groupId].active = true;
        emit GroupStatusChange(_groupId, true);
    }

    function pauseGroup(
        uint256 _groupId
    ) external groupValid(_groupId) onlyGroupManager(_groupId) groupActive(_groupId) {
        groupRegistry[_groupId].active = false;
        emit GroupStatusChange(_groupId, false);
    }

    function joinGroup(
        uint256 _groupId,
        uint256 _identityCommitment
    ) external groupValid(_groupId) {
        // TO DO: CHECK IF MEMBER IS LISTED IN WHITELIST THROUGH MERKLE CHECK
        
        _addMember(_groupId, _identityCommitment);
        groupRegistry[_groupId].identityCommitments.push(_identityCommitment);

        emit UserJoinedGroup(_groupId, _identityCommitment);
    }

    function sendMessage(
        bytes32 _signal,
        uint256 _root,
        uint256 _nullifierHash,
        uint256 _externalNullifier,
        uint256[8] calldata _proof,
        uint256 _groupId,
        string calldata _messageContentUri
    ) external groupValid(_groupId) {
        _verifyProof(_signal, _root, _nullifierHash, _externalNullifier, _proof, verifier);
        _saveNullifierHash(_nullifierHash);

        bytes32 _contentId = keccak256(abi.encodePacked(_groupId, _contentUri));
        contentRegistry[_contentId] = _contentUri;
        groupRegistry[_groupId].messageList.push(
            Message({
                messageId: _contentId,
                contentId: _messageContentUri
            });
        );

        emit ContentAdded(_contentId, _contentUri);
        emit MessageSent(_signal, _groupid, _contentId);
    }

    // TODO MAKE GET FUINCTIONS

}