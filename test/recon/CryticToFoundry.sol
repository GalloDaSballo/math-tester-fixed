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

    function testDemo() public {
        vm.warp(17868248);
        TwTAP_participate(0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF, 61918091110726083752813338766276191038263083433366584018688591674621790705619, 2361016);
        vm.warp(31590648);
        TwTAP_participate(0x4200000000000000000000000000000000000000, 32172841401752504929929596747405730936747446706072364556831924065220547509282, 10400);
        vm.warp(31590648);
        TwTAP_exitPosition(11155120, 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF);
        console2.log("twTap.getCumulative()", twTap.getCumulative());

        // if (magnitude >= pool.cumulative * 4) revert NotValid();
        // We permanently disabled twTap
        vm.expectRevert(); // revert NotValid();
        twTap.participate(0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF, 1234, 14 days);
    }
}
