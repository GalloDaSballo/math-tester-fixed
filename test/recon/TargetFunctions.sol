// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {BeforeAfter} from "./BeforeAfter.sol";
import {Properties} from "./Properties.sol";
import {vm} from "@chimera/Hevm.sol";
import {SymTest} from "halmos-cheatcodes/SymTest.sol";
abstract contract TargetFunctions is BaseTargetFunctions, Properties, BeforeAfter, SymTest {
    uint256 highestTokenId;

    function TwTAP_advanceWeek(uint256 _limit) public {
        try twTap.advanceWeek(_limit) {}
        catch {
            t(false, "Advance Week Should never revert");
        }
    }

    function TwTAP_exitPosition(uint256 _tokenId, address _to) public {
        _tokenId = between(_tokenId, 0, highestTokenId);

        twTap.exitPosition(_tokenId, _to);
    }


    function TwTAP_participate(address _participant, uint256 _amount, uint256 _duration) public {
        _duration = between(_duration, twTap.EPOCH_DURATION(), twTap.MAX_LOCK_DURATION());
        _amount = between(_amount, 0, tap.balanceOf(address(this)));
        uint256 newTokenId = twTap.participate(_participant, _amount, _duration);

        if (newTokenId > highestTokenId) {
            highestTokenId = newTokenId;
        }
    }

    struct Data {
        // TwTAP_exitPosition
        uint256 _tokenId;
        address _to;

        // TwTAP_participate
        address _participant;
        uint256 _amount; 
        uint256 _duration;
    }

    function check_counter_symbolic(
        bytes4[] memory selector,
        Data[] memory data
    ) public {
        vm.assume(selector.length == data.length);
        for (uint256 i = 0; i < selector.length; ++i) {
            // validate b4 after
            assumeValidSelector(selector[i]);
            // b4
            assumeSuccessfulCall(address(this), calldataFor(selector[i], data[i]));
            // after
        }

        // assert(0 > 1);
    }
    
    function assumeSuccessfulCall(address target, bytes memory data) internal {
        (bool success, ) = target.call(data);
        vm.assume(success);
    }

        ///@notice utility for returning the target functions selectors from the Counter contract
    function assumeValidSelector(bytes4 selector) internal {
        vm.assume(
            selector == this.TwTAP_participate.selector
        );
    }
    // https://github.com/a16z/halmos/wiki/errors#symbolic-calldataload-offset

    ///@notice utility for making calls to the target contract
    // function assumeSuccessfulCall(address target, bytes memory data) internal {
    //     (bool success, ) = target.call(data);
    //     vm.assume(success);
    // }

    ///@notice utility for getting calldata for a given function's arguments
    function calldataFor(
        bytes4 selector,
        Data memory theData
    ) internal view returns (bytes memory) {
        if(selector == this.TwTAP_participate.selector) {
            return abi.encodeWithSelector(selector, theData._participant, theData._amount, theData._duration);
        }
    }

    // function assumeValidSelector(bytes4 selector) internal {
    //     vm.assume(
    //         selector == counter.setNumber.selector ||
    //             selector == counter.increment.selector
    //     );
    // }

    // How do I write an halmos test
    // To find the DOS, without going to the next week


    // function TapToken_mintToSelf(uint256 amt) public {
    //   tap.mintToSelf(amt);
    // }

    // function TapToken_transfer(address to, uint256 amount) public {
    //   tap.transfer(to, amount);
    // }

    // function TapToken_transferFrom(address from, address to, uint256 amount) public {
    //   tap.transferFrom(from, to, amount);
    // }

    // TODO: Rewards
    // function TwTAP_addRewardToken(address _token) public {
    //   twTap.addRewardToken(IERC20(_token));
    // }

    // function TwTAP_approve(address to, uint256 tokenId) public {
    //   twTap.approve(to, tokenId);
    // }

    // function TwTAP_claimRewards(uint256 _tokenId, address _to) public {
    //   _tokenId = between(_tokenId, 0, Tap.mintedTWTap());
    //   twTap.claimRewards(_tokenId, _to);
    // }

    // function TwTAP_distributeReward(uint256 _rewardTokenId, uint256 _amount) public {
    //   twTap.distributeReward(_rewardTokenId, _amount);
    // }

    // function TwTAP_renounceOwnership() public {
    //   twTap.renounceOwnership();
    // }

    // function TwTAP_safeTransferFrom(address from, address to, uint256 tokenId) public {
    //   twTap.safeTransferFrom(from, to, tokenId);
    // }

    // function TwTAP_safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) public {
    //   twTap.safeTransferFrom(from, to, tokenId, data);
    // }

    // function TwTAP_setApprovalForAll(address operator, bool approved) public {
    //   twTap.setApprovalForAll(operator, approved);
    // }

    // function TwTAP_setMaxRewardTokensLength(uint256 _length) public {
    //   twTap.setMaxRewardTokensLength(_length);
    // }

    // function TwTAP_setMinWeightFactor(uint256 _minWeightFactor) public {
    //   twTap.setMinWeightFactor(_minWeightFactor);
    // }

    // function TwTAP_setVirtualTotalAmount(uint256 _virtualTotalAmount) public {
    //   twTap.setVirtualTotalAmount(_virtualTotalAmount);
    // }

    // function TwTAP_transferFrom(address from, address to, uint256 tokenId) public {
    //   twTap.transferFrom(from, to, tokenId);
    // }

    // function TwTAP_transferOwnership(address newOwner) public {
    //   twTap.transferOwnership(newOwner);
    // }
}
