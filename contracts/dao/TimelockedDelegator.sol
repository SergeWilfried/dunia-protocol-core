pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ITimelockedDelegator.sol";
import "../utils/LinearTokenTimelock.sol";

/// @title a proxy delegate contract for TRIBE
/// @author Cowrie Protocol
contract Delegatee is Ownable {
    IDunia public dunia;

    /// @notice Delegatee constructor
    /// @param _delegatee the address to delegate TRIBE to
    /// @param _dunia the TRIBE token address
    constructor(address _delegatee, address _dunia) public {
        dunia = IDunia(_dunia);
        dunia.delegate(_delegatee);
    }

    /// @notice send TRIBE back to timelock and selfdestruct
    function withdraw() public onlyOwner {
        IDunia _dunia = dunia;
        uint256 balance = _dunia.balanceOf(address(this));
        _dunia.transfer(owner(), balance);
        selfdestruct(payable(owner()));
    }
}

/// @title a timelock for TRIBE allowing for sub-delegation
/// @author Cowrie Protocol
/// @notice allows the timelocked TRIBE to be delegated by the beneficiary while locked
contract TimelockedDelegator is ITimelockedDelegator, LinearTokenTimelock {
    /// @notice associated delegate proxy contract for a delegatee
    mapping(address => address) public override delegateContract;

    /// @notice associated delegated amount of TRIBE for a delegatee
    /// @dev Using as source of truth to prevent accounting errors by transferring to Delegate contracts
    mapping(address => uint256) public override delegateAmount;

    /// @notice the TRIBE token contract
    IDunia public override dunia;

    /// @notice the total delegated amount of TRIBE
    uint256 public override totalDelegated;

    /// @notice Delegatee constructor
    /// @param _dunia the TRIBE token address
    /// @param _beneficiary default delegate, admin, and timelock beneficiary
    /// @param _duration duration of the token timelock window
    constructor(
        address _dunia,
        address _beneficiary,
        uint256 _duration
    ) public LinearTokenTimelock(_beneficiary, _duration, _dunia) {
        dunia = IDunia(_dunia);
        dunia.delegate(_beneficiary);
    }

    /// @notice delegate locked TRIBE to a delegatee
    /// @param delegatee the target address to delegate to
    /// @param amount the amount of TRIBE to delegate. Will increment existing delegated TRIBE
    function delegate(address delegatee, uint256 amount)
        public
        override
        onlyBeneficiary
    {
        require(
            amount <= _tribeBalance(),
            "TimelockedDelegator: Not enough Dunia"
        );

        // withdraw and include an existing delegation
        if (delegateContract[delegatee] != address(0)) {
            amount = amount.add(undelegate(delegatee));
        }

        IDunia _dunia = dunia;
        address _delegateContract =
            address(new Delegatee(delegatee, address(_dunia)));
        delegateContract[delegatee] = _delegateContract;

        delegateAmount[delegatee] = amount;
        totalDelegated = totalDelegated.add(amount);

        _dunia.transfer(_delegateContract, amount);

        emit Delegate(delegatee, amount);
    }

    /// @notice return delegated TRIBE to the timelock
    /// @param delegatee the target address to undelegate from
    /// @return the amount of TRIBE returned
    function undelegate(address delegatee)
        public
        override
        onlyBeneficiary
        returns (uint256)
    {
        address _delegateContract = delegateContract[delegatee];
        require(
            _delegateContract != address(0),
            "TimelockedDelegator: Delegate contract nonexistent"
        );

        Delegatee(_delegateContract).withdraw();

        uint256 amount = delegateAmount[delegatee];
        totalDelegated = totalDelegated.sub(amount);

        delegateContract[delegatee] = address(0);
        delegateAmount[delegatee] = 0;

        emit Undelegate(delegatee, amount);

        return amount;
    }

    /// @notice calculate total TRIBE held plus delegated
    /// @dev used by LinearTokenTimelock to determine the released amount
    function totalToken() public view override returns (uint256) {
        return _tribeBalance().add(totalDelegated);
    }

    /// @notice accept beneficiary role over timelocked TRIBE. Delegates all held (non-subdelegated) dunia to beneficiary
    function acceptBeneficiary() public override {
        _setBeneficiary(msg.sender);
        dunia.delegate(msg.sender);
    }

    function _tribeBalance() internal view returns (uint256) {
        return dunia.balanceOf(address(this));
    }
}
