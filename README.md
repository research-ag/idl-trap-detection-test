# idl-trap-detection-test

Run

```
icp network start -d
icp deploy test --mode reinstall
icp canister call test run '()'
icp canister call test state '()'
icp canister logs test
```

Then comment out the line

```
await async {}; // spend some time
```

and repeat.
