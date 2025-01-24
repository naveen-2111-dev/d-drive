// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/// @title A Decentralized File Storage Contract
/// @author naveen_rajan m
/// @notice This contract allows users to store files on Arweave and manage metadata with burning and access control features.
contract Storage {
    /// @dev Event emitted when a file is successfully stored.
    /// @param file, The transaction ID of the stored file on Arweave.
    /// @param sender The address that uploaded the file.
    /// @param count The ID of the file in the mapping or head of the stack kinda thing.
    event Success(string file, address sender, uint256 count);

    /// @dev Event emitted when a file is burned (removed from access).
    /// @param file_Tx_id The transaction ID of the burned file.
    /// @param burner The address that burned the file.
    event Isburned(string file_Tx_id, address burner);

    /// @dev Event emitted when a file access procided to some address.
    /// @param user The address which added other peer access holders.
    /// @param file_Tx_id The transaction ID of the file.
    event IsAccess_accepted(address user, string file_Tx_id);

    /// @dev dead_state ivalid address which is used for burn simulation.
    address private dead_state = 0x000000000000000000000000000000000000dEaD;

    struct Files {
        uint256 id;
        address user;
        string arweaveTxId;
        address[] access_holders;
        bool hasAccess;
    }

    mapping(uint256 => Files) public stored_files;
    uint256 private count = 0;
    uint256 private limit = 0;

    /// @notice Stores metadata for a file on Arweave.
    /// @dev This function adds the caller as the first access holder for the file.
    /// @param _arweaveTxId The transaction ID from Arweave.
    function SaveFile_metadata(string memory _arweaveTxId) external {
        require(bytes(_arweaveTxId).length > 0, "required a file Tx_id.../");
        count++;

        Files storage newFile = stored_files[count];
        newFile.id = count;
        newFile.user = msg.sender;
        newFile.arweaveTxId = _arweaveTxId;
        newFile.access_holders.push(msg.sender);
        newFile.hasAccess = true;

        emit Success(_arweaveTxId, msg.sender, count);
    }

    /// @notice Retrieves metadata for a stored file.
    /// @param file_id The ID of the file to retrieve.
    /// @return arweaveTxId The Arweave transaction ID of the file.
    /// @return user The owner address of the file.
    function Retrieve_files(uint256 file_id) external view returns (string memory, address) {
        require(file_id > 0, "required file_id greater than zero.../");
        require(file_id <= count, "File ID does not exist");
        Files storage files = stored_files[file_id];
        require(files.user != dead_state, "File has been burned");

        bool IsAccess = false;
        for (uint256 i = 0; i < files.access_holders.length; i++) {
            if (files.access_holders[i] == msg.sender) {
                IsAccess = true;
                break;
            }
        }
        require(IsAccess, "Access denied");
        return (files.arweaveTxId, files.user);
    }

    /// @notice Burns a file, making it inaccessible to anyone through ui.
    /// @dev The file owner can burn the file, removing all access holders.
    /// @param file_id The ID of the file to burn.
    function Burn_file(uint256 file_id) external {
        require(file_id > 0, "required file_id greater than zero.../");
        require(file_id <= count, "File ID does not exist");
        Files storage burn = stored_files[file_id];

        require(burn.user == msg.sender, "Only the file_owner can burn file");

        burn.user = dead_state;
        burn.hasAccess = false;
        delete burn.access_holders;
        emit Isburned(burn.arweaveTxId, msg.sender);
    }

    /// @notice accessHolders, to facilitate and allow authorized users to access.
    /// @dev The file owner can only add other peer_users of the file.
    /// @param file_id The ID of the file to add access persons/address.
    /// @param user address of the person who need access to this file.
    function Addaccess_holders(uint256 file_id, address user) external {
        require(file_id > 0, "required file_id greater than zero.../");
        require(file_id <= count, "File ID does not exist");
        Files storage file = stored_files[file_id];

        require(file.user == msg.sender, "Only the file_owner can grant access");

        file.access_holders.push(user);
        file.hasAccess = true;
        emit IsAccess_accepted(user, file.arweaveTxId);
    }
}
