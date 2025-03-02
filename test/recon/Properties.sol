// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {Asserts} from "@chimera/Asserts.sol";
import {Setup} from "./Setup.sol";

abstract contract Properties is Setup, Asserts {
    // - See if we can get the cumulative to get to 0 - Check spot value -> High Severity DOS

    function crytic_cumulativeIsNeverZero() public returns (bool) {
        return twTap.getCumulative() > 0;
    }

    // - Prove that `averageMagnitude` is not average at all, it grows over time - Monotonic test -> QA / M maybe even known
    /// NEED B4 After

    // - Can we make multiplier overflow? multiplier -> High Severity / Med
    function crytic_checkDurationOverflow() public returns (bool) {
        uint256 max = twTap.mintedTWTap();

        uint256 counter;
        while (counter < max) {
            if (twTap.getParticipantMultiplierMatchesUnpacked(counter++) != true) {
                return false;
            }
        }

        return true;
    }

    // - Total Accounting (good property to test)
    // For each nft
    // Chekc if release
    // If released skip
    // If not release add
    // Ensure balance is exactly the sum of those
    function crytic_totalAccounting() public returns (bool) {
        uint256 max = twTap.mintedTWTap();

        uint256 counter;
        uint256 acc;
        while (counter < max) {
            // Always returns 0 on expired
            acc += twTap.getParticipationAmount(counter++);
        }

        // NOTE gte cause we can get a ton of tokens that are expired
        return tap.balanceOf(address(twTap)) >= acc;
    }

    function crytic_neverNegativeOnCurrent() public view returns (bool) {
        // Don't check if we have yet to synch to future
        if (twTap.currentWeek() > twTap.lastProcessedWeek()) {
            return true;
        }

        return twTap.getNetActiveVotes(twTap.currentWeek()) >= 0;
    }
}
