# MED twTAP Cumulative Math is still broken for scenarios in which the math leads exactly to 0 cumulative

While a mitigation to [55](https://github.com/code-423n4/2024-02-tapioca-findings/issues/55) was provided

As shown in 55, if we can drive the `pool.cumulative` to a value that would cause it to be zero, we can prevent all future `participates`

https://github.com/hats-finance/Tapioca-0xe0b920d38a0900af3bab7ff0ca0af554129f54ad/blob/baddafc15616a5674e73c2f5a920b92bf9b21888/contracts/governance/twTAP.sol#L365

```solidity
        if (magnitude >= pool.cumulative * 4) revert NotValid(); // All magnitude revert if pool.cumulative == 0
```

The math can still be manipulated to lead to a 0 which would cause a DOS

I updated the Math Tester to retry the same attack and as you can see it's broken via the following sequence

### POC


### Logs


### Mitigation

The value for Cumulative should be floored, the subtraction should be changed to ensure that no value can bring the cumulative to 0