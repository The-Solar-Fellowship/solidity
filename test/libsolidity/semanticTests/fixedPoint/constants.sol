contract C {
       function f() public pure returns (fixed) {
        return 99.101 * 3.1;
    }
}
// ====
// compileViaYul: also
// ----
// f() -> 307213100000000000000
