// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract FundMeScript is Script {
    bool private constant USE_ANVIL = true;
    HelperConfig private helperConfig;

    constructor() {
        if (!USE_ANVIL) {
            string memory url = vm.rpcUrl("sepolia");
            vm.createSelectFork(url); // Fork network
        }
    }

    function run() external returns (FundMe) {
        helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }

    function getHelperConfig() external view returns (HelperConfig) {
        return helperConfig;
    }
}
