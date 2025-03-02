// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {BeforeAfter} from "./BeforeAfter.sol";
import {Properties} from "./Properties.sol";
import {vm} from "@chimera/Hevm.sol";

abstract contract TargetFunctions is BaseTargetFunctions, Properties, BeforeAfter {
    uint256 highestTokenId;

    function TwTAP_advanceWeek(uint256 _limit) public {
        try twTap.advanceWeek(_limit) {}
        catch {
            t(false, "Advance Week Should never revert");
        }
    }

    // function TwTAP_exitPosition(uint256 _tokenId, address _to) public {
    //     _tokenId = between(_tokenId, 0, highestTokenId);

    //     twTap.exitPosition(_tokenId, _to);
    // }

    // /// @dev so we can check for unexpected reverts
    // function TwTAP_exitPositionSelf(uint256 _tokenId, address _to) public {
    //     _tokenId = between(_tokenId, 0, highestTokenId);

    //     //
    //     bool checkRelease = twTap.canReleaseTap(_tokenId) && twTap.isApprovedOrOwner(address(this), _tokenId);

    //     try twTap.exitPosition(_tokenId, address(this)) {}
    //     catch {
    //         // Only claim to self else the check below is not valid
    //         if (checkRelease) {
    //             t(false, "Should never revert on true");
    //         }
    //     }
    // }

    function TwTAP_participate(address _participant, uint256 _amount, uint256 _duration) public {
        _duration = between(_duration, twTap.EPOCH_DURATION(), twTap.MAX_LOCK_DURATION());
        _amount = between(_amount, 0, tap.balanceOf(address(this)));
        uint256 newTokenId = twTap.participate(_participant, _amount, _duration);

        if (newTokenId > highestTokenId) {
            highestTokenId = newTokenId;
        }
    }

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
