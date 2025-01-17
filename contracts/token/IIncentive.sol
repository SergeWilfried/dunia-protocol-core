pragma solidity ^0.6.2;

/// @title incentive contract interface
/// @author Cowrie Protocol
/// @notice Called by COWRIE token contract when transferring with an incentivized address
/// @dev should be appointed as a Minter or Burner as needed
interface IIncentive {
    // ----------- Cowrie only state changing api -----------

    /// @notice apply incentives on transfer
    /// @param sender the sender address of the COWRIE
    /// @param receiver the receiver address of the COWRIE
    /// @param operator the operator (msg.sender) of the transfer
    /// @param amount the amount of COWRIE transferred
    function incentivize(
        address sender,
        address receiver,
        address operator,
        uint256 amount
    ) external;
}
