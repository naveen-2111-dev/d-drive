// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Storage} from "../src/file.sol";

contract CounterTest is Test {
    Storage public counter;

    // function setUp() public {
    //     counter = new Storage();
    //     counter.setNumber(1);
    // }

    // function test_Increment() public {
    //     counter.increment();
    //     assertEq(counter.number(), 2);
    // }

    // function testFuzz_SetNumber(uint256 x) public {
    //     counter.setNumber(x);
    //     assertEq(counter.number(), x);
    // }
}
