    pragma solidity ^0.6.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../staking/DuniaRewardsDistributor.sol";
import "../staking/DuniaStakingRewards.sol";
import "./IOrchestrator.sol";

contract StakingOrchestrator is IStakingOrchestrator, Ownable {
    function init(
        address core,
        address duniaCowriePair,
        address dunia,
        uint stakingDuration,
        uint dripFrequency,
        uint incentiveAmount
    ) public override onlyOwner returns (address stakingRewards, address distributor) {

        distributor = address(
            new DuniaRewardsDistributor(
                core,
                address(0), // to be set by governor
                stakingDuration,
                dripFrequency,
                incentiveAmount
            )
        );

        stakingRewards = address(
            new DuniaStakingRewards(
                distributor,
                dunia,
                duniaCowriePair,
                dripFrequency
            )
        );
        return (stakingRewards, distributor);
    }

    function detonate() public override onlyOwner {
        selfdestruct(payable(owner()));
    }
}