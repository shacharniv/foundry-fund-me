// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract DeployFundMe is Script {
    address priceFeed = 0x694AA1769357215DE4FAC081bf1f309aDC325306; // Sepolia ETH/USD datafeed

    function run() external returns (FundMe) {
        // Before startBroadcast -> Not a "real" transaction
        HelperConfig helperConfig = new HelperConfig(); // before boradcast because we don't want to broadcast this.
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();

        // After startBroadcast -> a "real" transaction!
        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}

// forge script script/DeployFundMe.s.sol
