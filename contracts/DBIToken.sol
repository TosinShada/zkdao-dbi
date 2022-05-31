// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.7.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DBIToken is ERC1155, Ownable {
    uint256 public constant MILESTONE_ONE = 1;
    uint256 public constant MILESTONE_TWO = 2;
    uint256 public constant MILESTONE_THREE = 3;
    uint256 public constant MILESTONE_FOUR = 4;
    uint256 public constant MILESTONE_FIVE = 5;

    uint256 private _currentTokenId = 6;

    address private constant ZKDAO_MULTISIG_WALLET = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);

    mapping(address => mapping(string => uint256)) public claimed;
    mapping(address => bool) private admins;
    mapping(address => bool) private blacklisted;

    bool allowsTransfers = false;

    constructor()
        ERC1155("")
    {
        admins[msg.sender] = true;
        admins[ZKDAO_MULTISIG_WALLET] = true;

        _mint(ZKDAO_MULTISIG_WALLET, MILESTONE_ONE, 10**4, "");
        _mint(ZKDAO_MULTISIG_WALLET, MILESTONE_TWO, 10**4, "");
        _mint(ZKDAO_MULTISIG_WALLET, MILESTONE_THREE, 10**4, "");
        _mint(ZKDAO_MULTISIG_WALLET, MILESTONE_FOUR, 10**4, "");
        _mint(ZKDAO_MULTISIG_WALLET, MILESTONE_FIVE, 10**4, "");
    }

    modifier onlyAdmin() {
        require(admins[msg.sender] == true);
        _;
    }

    // Right now the tokens are non-transferrable. However, in the event that we want to make it transferrable, this function will allow us do that.
    function setAllowsTransfers(bool _allowsTransfers) external onlyAdmin {
        allowsTransfers = _allowsTransfers;
    }

    // This function allows an existing admin to add new admins
    function updateAdmin(address _admin, bool isAdmin) external onlyAdmin {
        admins[_admin] = isAdmin;
    }

    function mint(uint256 amount, bytes memory data) external onlyAdmin {
        _mint(ZKDAO_MULTISIG_WALLET, _currentTokenId, amount, data);
        _currentTokenId++;
    }

    // This function allows an admin to blacklist a member from DBI payment
    function blacklistMember(address _member, bool isBlacklisted) external onlyAdmin {
        blacklisted[_member] = isBlacklisted;
    }

    // This function allows an admin to blacklist a member from DBI payment
    function getTokenCount() external view returns(uint256) {
        return _currentTokenId - 1;
    }

    // An override function to prevent token transfer
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        require(
            from == address(0) || from == ZKDAO_MULTISIG_WALLET || to == address(0) || allowsTransfers,
            "Not allowed to transfer"
        );

        if (from != ZKDAO_MULTISIG_WALLET) {
            require(
                to == ZKDAO_MULTISIG_WALLET, 
                "Not allowed to transfer to another address other than the zkDAO multisig wallet"
            );
        }

        return super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}