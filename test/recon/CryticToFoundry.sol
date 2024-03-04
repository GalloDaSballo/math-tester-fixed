// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {TargetFunctions} from "./TargetFunctions.sol";
import {FoundryAsserts} from "@chimera/FoundryAsserts.sol";

contract CryticToFoundry is Test, TargetFunctions, FoundryAsserts {
    function setUp() public {
        setup();
    }

    // function testDemo() public {
    //     vm.warp(17868248);
    //     TwTAP_participate(
    //         0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF,
    //         61918091110726083752813338766276191038263083433366584018688591674621790705619,
    //         2361016
    //     );
    //     vm.warp(31590648);
    //     TwTAP_participate(
    //         0x4200000000000000000000000000000000000000,
    //         32172841401752504929929596747405730936747446706072364556831924065220547509282,
    //         10400
    //     );
    //     vm.warp(31590648);
    //     TwTAP_exitPosition(11155120, 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF);
    //     console2.log("twTap.getCumulative()", twTap.getCumulative());

    //     // if (magnitude >= pool.cumulative * 4) revert NotValid();
    //     // We permanently disabled twTap
    //     vm.expectRevert(); // revert NotValid();
    //     twTap.participate(0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF, 1234, 14 days);
    // }

    function _getAndLogMagnitude(uint256 time) internal returns (uint256) {
        console2.log("_logMagnitude time", time);
        console2.log("_logMagnitude in weeks", time / 1 weeks);
        console2.log("_logMagnitude in months", time / 4 weeks);

        uint256 mag = twTap.computeMagnitude(time, twTap.getCumulative());
        console2.log(mag);

        return mag;
    }

    //  forge test --match-test testTheMagnitude -vv
    function testTheMagnitude() public {
        // Lock for 4 weeks
        // TwTAP_participate(0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF, 61918091110726083752813338766276191038263083433366584018688591674621790705619, 2361016);
        console2.log("twTap.getCumulative()", twTap.getCumulative());
        uint256 currentValue = twTap.getCumulative();

        uint256 asWeek = 1 weeks;
        while (_getAndLogMagnitude(asWeek) < currentValue) {
            asWeek += 1 weeks;
        }
    }

    //  forge test --match-test testTheMagnitudeWithSetter -vv
    // Given X Values -> Perhaps 1 week at a time until 100 years
    // Show me how long to lock to get the same
    // That's because that's how you unlock max multiple
    // Marginal extra lock duration has no impact on multiplier but has impact on rewards
    // TARUN: Price of marginal extra lock for no growth
    function testTheMagnitudeWithSetter() public {
        // 20 years, requires another 40 years to get to match the magnitude
        // 1 Year -> 37 months
        // 4x?
        // 20 days -> 9 weeks
        // 10 days -> 5 weeks
        uint256 currentValue = 20 days;
        twTap.setCumulative(currentValue);

        uint256 asWeek = 1 weeks;
        while (_getAndLogMagnitude(asWeek) < currentValue) {
            asWeek += 1 weeks;
            /// @audit Proof that once a magnitude is reached, we need 2x to 4x to get the new value
        }
    }

    // You can make it super small to influence avg?
    // Pretty sure that normal users get scammed
    // They are forced to lock at 2 / 4x the time
    // You instead sacrifice some thousands on smaller locks
    // and then get a boost on the rest
    // The smaller locks end up dragging the counter down

    // Set cumulative to a shitton

    // pool.averageMagnitude = (pool.averageMagnitude + magnitude) / pool.totalParticipants;

    // Averages vs Average Math
    function test_averagesVsAverageMath() public {
        uint256[] memory magnitudes = new uint256[](10);
        magnitudes[0] = 1e18;
        magnitudes[1] = 2e18;
        magnitudes[2] = 3e18;
        magnitudes[3] = 4e18;
        magnitudes[4] = 5e18;
        magnitudes[5] = 6e18;
        magnitudes[6] = 7e18;
        magnitudes[7] = 8e18;
        magnitudes[8] = 9e18;
        magnitudes[9] = 10e18;

        uint256 averageMagnitude;
        uint256 counterSofar;

        for (uint256 i; i < magnitudes.length; i++) {
            uint256 totalParticipants = i + 1;
            averageMagnitude = (averageMagnitude + magnitudes[i]) / totalParticipants;
        }

        uint256 properSum;
        for (uint256 i; i < magnitudes.length; i++) {
            properSum += magnitudes[i];
        }

        console2.log("averageMagnitude", averageMagnitude);
        console2.log("proper mean", properSum / magnitudes.length);

        /**
         * averageMagnitude 1112740575396825396 // 1/5 of Proper Mean
         *         proper mean 5500000000000000000
         */
    }

    // TODO: Mock twTAP with setter for averageMagnitude, cumulative, totalParticipans
    // Min magnitude is
}
