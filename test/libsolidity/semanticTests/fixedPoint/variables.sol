contract C {
    function f1() public pure returns (fixed32x1) {
        return 1.3;
    }
    function f2() public pure returns (fixed32x2) {
        return 1.3;
    }
    function f4() public pure returns (fixed32x4) {
        return 1.3;
    }
    function f8() public pure returns (fixed32x8) {
        return 1.3;
    }
    function f16() public pure returns (fixed64x16) {
        return 1.3;
    }
    function f18() public pure returns (fixed64x18) {
        return 1.3;
    }
    function f() public pure returns (fixed) {
        return 1.3;
    }
    function g(fixed f1, fixed f2) public pure returns (fixed, fixed, fixed) {
        return (f2, 3.3, f1);
    }
}
// ====
// compileViaYul: also
// ----
// f1() -> 13
// f2() -> 130
// f4() -> 13000
// f8() -> 130000000
// f16() -> 13000000000000000
// f18() -> 1300000000000000000
// f1() -> 1.3
// f2() -> 1.3
// f4() -> 1.3
// f8() -> 1.3
// f16() -> 1.3
// f18() -> 1.3
// g(fixed128x18,fixed128x18): 1.1, 2.2 -> 2200000000000000000, 3300000000000000000, 1100000000000000000
// g(fixed128x18,fixed128x18): 1.1, 2.2 -> 2.2, 3.3, 1.1
