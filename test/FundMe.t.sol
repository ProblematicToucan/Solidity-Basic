// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {FundMeScript} from "../script/FundMe.s.sol";

contract FundMeTest is Test {
    FundMe public fundMe;

    function setUp() external {
        string memory url = vm.rpcUrl("https://rpc.sepolia.org/");
        vm.createSelectFork(url); // Fork sepolia testnet
        FundMeScript fundMeScript = new FundMeScript();
        fundMe = fundMeScript.run();
    }

    function testMinimumUsd() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsDeployer() public {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }
}
