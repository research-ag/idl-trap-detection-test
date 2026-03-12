import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Debug "mo:base/Debug";

persistent actor class TestActor() {

  transient var openCalls : Nat = 0;

  type CallStats = {
    openCalls : Nat;
    callSent : Nat;
    successes : Nat;
    failures : Nat;
    traps : Nat;
  };

  type Management = actor {
    canister_info : query ({
      canister_id : Principal;
      num_requested_changes : ?Nat64;
    }) -> async {
      total_num_changes : Nat64;
    };
  };

  public query func queryOpenCalls() : async Nat = async openCalls;

  public func call(arg : { callsAmount : Nat; idlErrorsRate : Nat; failuresRate : Nat }) : async CallStats {
    // rate 3 means that error is simulated at indexes 2,5,8,11,....
    // rate 5 - 4,9,14,19,....
    var callSent : Nat = 0;
    var successes : Nat = 0;
    var failures : Nat = 0;
    var traps : Nat = 0;

    let futures = Buffer.Buffer<async ({ total_num_changes : Nat64 })>(arg.callsAmount);

    label L for (i in Iter.range(0, arg.callsAmount - 1)) {
      let canister_id = if (arg.failuresRate > 0 and (i % arg.failuresRate) == arg.failuresRate - 1) {
        Principal.fromText("2vxsx-fae");
      } else {
        Principal.fromText("7v7ju-sqaaa-aaaao-a7yvq-cai");
      };
      let management = if (arg.idlErrorsRate > 0 and (i % arg.idlErrorsRate) == arg.idlErrorsRate - 1) {
        (actor "7v7ju-sqaaa-aaaao-a7yvq-cai" : Management);
      } else {
        (actor "aaaaa-aa" : Management);
      };
      try {
        futures.add(management.canister_info({ canister_id; num_requested_changes = ?(20 : Nat64) }));
        //register_call cb
        openCalls += 1;
        callSent += 1;
      } catch _ {
        // stop scheduling more calls
        break L;
      };
    };

    // now process the responses
    for (i in Iter.range(0, futures.size() - 1)) {
      let fut = futures.get(i);
      var trapDetected = true;
      try {
        let resp = await? fut;
        Debug.print(debug_show resp);
        successes += 1;
        openCalls -= 1;
        trapDetected := false;
      } catch _ {
        failures += 1;
        openCalls -= 1;
        trapDetected := false;
      } finally if (trapDetected) {
        Debug.print("Trap detected!");
        traps += 1;
      };
    };

    { openCalls; callSent; successes; failures; traps };
  };

};
