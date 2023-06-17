// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant INITIAL_FUNDING_AMOUNT = 1 ether;
    uint256 constant VALUE_TO_SEND = 0.1 ether;

    function fundFundMe(address mostRecentDeployed) public {
        vm.startBroadcast();

        FundMe(mostRecentDeployed).fund{value: VALUE_TO_SEND}();
        console.log("Funded FundMe with %s", VALUE_TO_SEND);
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        fundFundMe(mostRecentDeployed);
    }
}

contract WithdrawFundMe is Script {
    uint256 constant INITIAL_FUNDING_AMOUNT = 1 ether;
    uint256 constant VALUE_TO_SEND = 0.1 ether;

    function withdrawFundMe(address mostRecentDeployed) public {
        vm.startBroadcast();
        FundMe(mostRecentDeployed).cheaperWithdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        withdrawFundMe(mostRecentDeployed);
    }
}
