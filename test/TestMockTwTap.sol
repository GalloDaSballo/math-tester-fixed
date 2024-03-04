// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";

contract TwTap {
    uint256 public EPOCH_DURATION = 7 days;
    uint256 public constant MIN_WEIGHT_FACTOR = 1000; // In BPS, 0.1%

    uint256 public cumulative = EPOCH_DURATION;
    uint256 public totalDeposited = 0;
    uint256 public averageMagnitude = 0;
    uint256 private VIRTUAL_TOTAL_AMOUNT = 10_000 ether;

    uint256 public constant MAX_LOCK_DURATION = 100 * 365 days; // 100 years

    uint256 public totalParticipants;

    uint256 public spent = 0;

    function setCumulative(uint256 amt) external {
        cumulative = amt;
    }

    function setaAverageMagnitude(uint256 amt) external {
        averageMagnitude = amt;
    }

    function setTotalParticipants(uint256 amt) external {
        totalParticipants = amt;
    }

    function participate(uint256 duration, uint256 amount) external returns (uint256) {
        require(duration > EPOCH_DURATION, "LockNotAWeek");
        require(duration < MAX_LOCK_DURATION, "LockTooLong");

        // Transfer TAP to this contract
        spent += amount;

        uint256 magnitude = computeMagnitude(duration, cumulative); // This is just duration and prev
        // Revert if the lock 4x the cumulative||| But the impact of locking different weight should be counted in some way
        require(magnitude < cumulative * 4, "Magnitude too big");
        uint256 multiplier = computeTarget( // magnitude * dMax / cumulative | clamp(dMAX, dMin)
            0,
            1_000_000,
            magnitude,
            /// NOTE: Basically based on duration
            cumulative
        );

        // Calculate twAML voting weight
        bool divergenceForce;
        bool hasVotingPower = amount >= computeMinWeight(totalDeposited + VIRTUAL_TOTAL_AMOUNT, MIN_WEIGHT_FACTOR);
        if (hasVotingPower) {
            totalParticipants++; // Save participation
            averageMagnitude = (averageMagnitude + magnitude) / totalParticipants;

            // Compute and save new cumulative
            divergenceForce = duration >= cumulative;
            /// if duration > SUM(prev_durations)

            if (divergenceForce) {
                cumulative += averageMagnitude;
            } else {
                // TODO: Strongly suspect this is never less. Prove it.
                if (cumulative > averageMagnitude) {
                    cumulative -= averageMagnitude;
                } else {
                    cumulative = 0;
                }
            }

            // Save new weight
            totalDeposited += amount;
        }

        return duration * multiplier;
    }

    function getMinWeight() external view returns (uint256) {
        return computeMinWeight(totalDeposited + VIRTUAL_TOTAL_AMOUNT, MIN_WEIGHT_FACTOR);
    }

    function computeMinWeight(uint256 _totalWeight, uint256 _minWeightFactor) public pure returns (uint256) {
        uint256 mul = (_totalWeight * _minWeightFactor);
        return mul >= 1e4 ? mul / 1e4 : _totalWeight;
    } // 10_000 e18 * 1000 / 1e4 | 1k TAP to vote

    function computeMagnitude(uint256 _timeWeight, uint256 _cumulative) public pure returns (uint256) {
        return sqrt(_timeWeight * _timeWeight + _cumulative * _cumulative) - _cumulative;
    }

    function computeTarget(uint256 _dMin, uint256 _dMax, uint256 _magnitude, uint256 _cumulative)
        public
        pure
        returns (uint256)
    {
        if (_cumulative == 0) {
            return _dMax;
        }
        uint256 target = (_magnitude * _dMax) / _cumulative;
        /// @audit To get Max, I only need 1
        target = target > _dMax ? _dMax : target < _dMin ? _dMin : target;
        return target;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) public pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

contract CryticToFoundry is Test {

  function _logTwTap(TwTap t) internal {
    console2.log("averageMagnitude", t.averageMagnitude());
    console2.log("cumulative", t.cumulative());
  }


    function test_twapWithHardocodedValues_smallDuration_hasNoImpact() public {
        TwTap twtap = new TwTap();

        // Set twTAP to have some participation
        // To force lockers for 4 years for max
        // 100 people
        twtap.setTotalParticipants(100);
        // 4 years
        twtap.setaAverageMagnitude(365.25 days * 4);
        twtap.setCumulative(365.25 days * 4 * 100); // assume that each new add pushes by up to 100 times, massive
        _logTwTap(twtap);

        // Can we write one operation that causes this to go to zero?
        twtap.participate(twtap.EPOCH_DURATION() + 1, twtap.getMinWeight());
        _logTwTap(twtap);
    }

    function test_twapWithHardocodedValues_closeButNotSigar_hasMassiveImpact() public {
        TwTap twtap = new TwTap();

        // Set twTAP to have some participation
        // To force lockers for 4 years for max
        // 100 people
        twtap.setTotalParticipants(10);
        // 4 years
        twtap.setaAverageMagnitude(365.25 days * 4);
        twtap.setCumulative(365.25 days * 4 + 1); // Set to smaller for convenience
        _logTwTap(twtap);

        // Can we write one operation that causes this to go to zero?
        twtap.participate(365.25 days * 4, twtap.getMinWeight());
        _logTwTap(twtap);
        twtap.participate(365.25 days * 4, twtap.getMinWeight());
        _logTwTap(twtap);
        twtap.participate(365.25 days * 4, twtap.getMinWeight());
        _logTwTap(twtap);
        twtap.participate(365.25 days * 4, twtap.getMinWeight());
        _logTwTap(twtap);
        twtap.participate(365.25 days * 4, twtap.getMinWeight());
        _logTwTap(twtap);
        twtap.participate(365.25 days * 4, twtap.getMinWeight());
        _logTwTap(twtap);
        twtap.participate(365.25 days * 4, twtap.getMinWeight());
        _logTwTap(twtap);
        twtap.participate(365.25 days * 4, twtap.getMinWeight());
        _logTwTap(twtap);

        // Decreases slowly af
        twtap.participate(twtap.EPOCH_DURATION() + 1, twtap.getMinWeight());
        _logTwTap(twtap);
        twtap.participate(twtap.EPOCH_DURATION() + 1, twtap.getMinWeight());
        _logTwTap(twtap);
        twtap.participate(twtap.EPOCH_DURATION() + 1, twtap.getMinWeight());
        _logTwTap(twtap);
        twtap.participate(twtap.EPOCH_DURATION() + 1, twtap.getMinWeight());
        _logTwTap(twtap);
        twtap.participate(twtap.EPOCH_DURATION() + 1, twtap.getMinWeight());
        _logTwTap(twtap);
        twtap.participate(twtap.EPOCH_DURATION() + 1, twtap.getMinWeight());
        _logTwTap(twtap);
        twtap.participate(twtap.EPOCH_DURATION() + 1, twtap.getMinWeight());
        _logTwTap(twtap);
        twtap.participate(twtap.EPOCH_DURATION() + 1, twtap.getMinWeight());
        _logTwTap(twtap);
        twtap.participate(twtap.EPOCH_DURATION() + 1, twtap.getMinWeight());
        _logTwTap(twtap);
    }



    // Shitton of small short locks = we fucked the magnitude math for a long time
    // A lot of small locks with small duration = nobody can lock for a high time
}
