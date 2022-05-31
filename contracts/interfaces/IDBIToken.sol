// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

interface IDBIToken {
    function setAllowsTransfers(bool _allowsTransfers) external;

    // This function allows an existing admin to add new admins
    function updateAdmin(address _admin, bool isAdmin) external;

    function mint(uint256 id, uint256 amount, bytes memory data) external;

    // This function allows an admin to blacklist a member from DBI payment
    function blacklistMember(address _member, bool isBlacklisted) external;

    function balanceOf(address account, uint256 id) external view returns (uint256);

    function getTokenCount() external view returns (uint256);

    // function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);

    // function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;
}
