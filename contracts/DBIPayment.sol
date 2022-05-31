// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.7.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IDBIToken.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract DBIPayment is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;
        
    uint256 public paymentAmount;
    Counters.Counter public cycleId;

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param Documents a parameter just like in doxygen (must be followed by parameter name)
    struct DBIRecipient {
        address walletId;
        uint256 amount;
        string data;
    }

    mapping(address => bool) private admins; 
    mapping(uint256 => mapping(address => bool)) public hasWithdrawn;

    event DBIWithdrawn(
        address indexed walletAddress,
        uint256 amount
    );

    // address of the payment token
    IERC20 private immutable _token;

    // address of the DBI token
    IDBIToken private immutable _dbi;

    /**
     * @dev Creates a payment contract.
     */
    modifier onlyAdmin() {
        require(admins[msg.sender] == true);
        _;
    }

    /**
     * @dev Creates a payment contract.
     * @param token_ address of the ERC20 token contract for DBIs
     */
    constructor(address token_, address dbi_, uint256 paymentAmount_) {
        require(token_ != address(0x0));
        
        admins[msg.sender] = true;
        _token = IERC20(token_);
        _dbi = IDBIToken(dbi_);
        paymentAmount = paymentAmount_;
        cycleId.increment();
    }

    receive() external payable {}

    fallback() external payable {}

    /**
    * @notice Withdraw the specified amount if possible.
    */
    function withdraw() public nonReentrant {
        require(
            _dbi.getTokenCount() > 0,
            "No DBI tokens to enable withdrawal");
        
        require(
            hasWithdrawn[cycleId.current()][msg.sender] == false,
            "You have already withdrawn from this cycle"
        );

        require(
            _dbi.isMemberBlacklisted(msg.sender) == false,
            "You are suspended from DBI payments"
        );

        uint256 amount = getWithdrawableAmount();
        hasWithdrawn[cycleId.current()][msg.sender] = true;

        _token.safeTransfer(msg.sender, amount);
    }

    /**
    * @dev Returns the amount of tokens that can be withdrawn by the member.
    * @return the amount of tokens
    */
    function getWithdrawableAmount()
        public
        view
        returns(uint256){
        uint256 tokenCount = _dbi.getTokenCount();
        uint256 totalTokens;
        for (uint256 i = 1; i <= tokenCount; i++) {
            uint256 token = _dbi.balanceOf(msg.sender, i);
            totalTokens += token;
        }

        return totalTokens * paymentAmount;
    }

    // This function allows an existing admin to add new admins
    function updateAdmin(address _admin, bool isAdmin) external onlyAdmin {
        admins[_admin] = isAdmin;
    }

    // This function allows an admin to create a new cycle
    function createNewCycle() external onlyAdmin {
        cycleId.increment();
    }
    
    // This function returns the token balance of the DBI Payment contract
    function getTokenBalance() external view returns(uint256) {
        return _token.balanceOf(address(this));
    }
}