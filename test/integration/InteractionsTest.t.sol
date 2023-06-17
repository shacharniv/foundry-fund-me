// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe;
    uint256 constant INITIAL_FUNDING_AMOUNT = 1 ether;
    uint256 constant VALUE_TO_SEND = 0.1 ether;
    uint256 constant GAS_PRICE = 1;
    address immutable USER = makeAddr("user");

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        console.log("deployFundMe", address(deployFundMe));
        console.log("deployFundMe - balance", address(deployFundMe).balance);

        fundMe = deployFundMe.run();
        console.log("fundMe", address(fundMe));
        console.log("fundMe - balance", address(fundMe).balance);

        //vm.deal(USER, INITIAL_FUNDING_AMOUNT);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        console.log("fundFundMe", address(fundFundMe));
        console.log("fundFundMe - balance", address(fundFundMe).balance);

        fundFundMe.fundFundMe(address(fundMe));

        address funder = fundMe.getFunder(0);
        assertEq(funder, msg.sender);

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
}
