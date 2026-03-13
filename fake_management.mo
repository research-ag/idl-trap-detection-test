import Principal "mo:core/Principal";
import Error "mo:core/Error";

persistent actor class FakeManagement() {

  public query func canister_info_correct(arg : { canister_id : Principal; num_requested_changes : ?Nat64 }) : async ({
    total_num_changes : Nat64;
  }) {
    if (Principal.isAnonymous(arg.canister_id)) {
      throw Error.reject("");
    };
    { total_num_changes = 123 };
  };

  public query func canister_info_incorrect(arg : { canister_id : Principal; num_requested_changes : ?Nat64 }) : async ({
    info : Text;
  }) {
    if (Principal.isAnonymous(arg.canister_id)) {
      throw Error.reject("");
    };
    { info = debug_show arg };
  };

};
