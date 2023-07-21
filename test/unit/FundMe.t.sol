// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {FundMeScript} from "../../script/FundMe.s.sol";

contract FundMeTest is Test {
    FundMe private s_fundMe;
    FundMeScript private s_fundMeScript;
    address private immutable i_testUser = makeAddr("Alice");
    uint256 private constant MINIMUM_USD = 5e18; // 5 USD
    uint256 private constant TEST_USER_BALANCE = 1 ether;
    uint256 private constant TX_AMOUNT = 1e17;

    modifier funded() {
        vm.prank(i_testUser);
        s_fundMe.fund{value: TX_AMOUNT}();
        _;
    }

    function setUp() external {
        s_fundMeScript = new FundMeScript();
        s_fundMe = s_fundMeScript.run();
        vm.deal(i_testUser, TEST_USER_BALANCE);
    }

    function test_MinimumUsdIsAccurate() public {
        assertEq(s_fundMe.getMinimumUSD(), MINIMUM_USD);
    }

    function test_OwnerIsDeployer() public {
        assertEq(s_fundMe.getContractOwner(), msg.sender);
    }

    function test_PriceFeedIsAccurate() public {
        address ethUsdPriceFeed = s_fundMeScript.getHelperConfig().activeNetworkConfig();
        assertEq(s_fundMe.getPriceFeedContract(), ethUsdPriceFeed);
    }

    function test_PriceFeedVersionIsAccurate() public {
        uint256 version = s_fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFail_FundNotEnoughtETH() public {
        s_fundMe.fund();
    }

    function test_AddrAmountFunded() public funded {
        uint256 amountFunded = s_fundMe.getAddressToAmountFunded(i_testUser);
        assertEq(amountFunded, TX_AMOUNT);
    }

    function test_FunderAddrInsideArrayOfFunders() public funded {
        address funder = s_fundMe.getFunder(0);
        assertEq(funder, i_testUser);
    }

    function test_DirectSendEthToAddr() public {
        vm.deal(address(s_fundMe), TX_AMOUNT);
        assertEq(address(s_fundMe).balance, TX_AMOUNT);
    }

    function testFail_NonOwnerWithdraw() public {
        vm.prank(i_testUser);
        s_fundMe.withdraw();
    }

    function test_OwnerWithdraw() public funded {
        vm.prank(s_fundMe.getContractOwner());
        s_fundMe.withdraw();
    }

    function test_WithdrawWithSingleFunder() public funded {
        uint256 ownerBalance = s_fundMe.getContractOwner().balance;
        uint256 contractBalance = address(s_fundMe).balance;

        vm.prank(s_fundMe.getContractOwner());
        s_fundMe.withdraw();

        uint256 newOwnerBalance = s_fundMe.getContractOwner().balance;
        uint256 newContractBalance = address(s_fundMe).balance;

        assertEq(newContractBalance, 0);
        assertEq(ownerBalance + contractBalance, newOwnerBalance);
    }

    function test_WithdrawWithMultipleFunder() public funded {
        uint160 numberOfFunders = 6;
        for (uint160 i = 1; i < numberOfFunders; i++) {
            hoax(address(i), TEST_USER_BALANCE);
            s_fundMe.fund{value: TX_AMOUNT}();
        }

        uint256 ownerBalance = s_fundMe.getContractOwner().balance;
        uint256 contractBalance = address(s_fundMe).balance;

        vm.prank(s_fundMe.getContractOwner());
        s_fundMe.withdraw();

        uint256 newOwnerBalance = s_fundMe.getContractOwner().balance;
        uint256 newContractBalance = address(s_fundMe).balance;

        assertEq(newContractBalance, 0);
        assertEq(ownerBalance + contractBalance, newOwnerBalance);
    }
}
