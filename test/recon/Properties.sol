// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {Asserts} from "@chimera/Asserts.sol";
import {Setup} from "./Setup.sol";

abstract contract Properties is Setup, Asserts {
    // - See if we can get the cumulative to get to 0 - Check spot value -> High Severity DOS

    // function crytic_cumulativeIsNeverZero() public returns (bool) {
    //     return twTap.getCumulative() > 1000; // And the amt needs to be super small
    // }
    function crytic_cumulative_three() public returns (bool) {
        if(twTap.getCumulative() < 1000 && moves <= 2) {
            return false; // Found it
        }
        return true;
    }
}
