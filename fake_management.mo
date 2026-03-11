import Principal "mo:base/Principal";

persistent actor class FakeManagement() {

  public query func canister_info(arg : { canister_id : Principal; num_requested_changes : ?Nat64 }) : async ({
    info : Text;
  }) {
    { info = debug_show arg };
  };

};
