import Debug "mo:core/Debug";
import Principal "mo:core/Principal";
import Nat "mo:core/Nat";

persistent actor Test {

  type T = { x : Nat };
  type T2 = { x2 : Nat };

  public query func foo() : async T2 {
    { x2 = 0 };
  };

  let self = Principal.fromActor(Test).toText();

  transient let remote = (
    actor (self) : actor {
      foo : query () -> async T;
    }
  );

  var state_ : Bool = false;

  public func run() : async () {
    let fut = remote.foo();
    await async {}; // spend some time
    try {
      Debug.print("try entered");
      ignore await fut;
      Debug.print("fut awaited");
    } finally {
      Debug.print("finally entered");
      state_ := true;
    };
  };

  public query func state() : async Bool { state_ };

};
