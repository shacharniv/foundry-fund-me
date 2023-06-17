// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    DeployFundMe deployFundMe;
    uint256 constant INITIAL_FUNDING_AMOUNT = 1 ether;
    uint256 constant GAS_PRICE = 1;

    address immutable USER = makeAddr("user");

    //address priceFeed = 0x694AA1769357215DE4FAC081bf1f309aDC325306; // Sepolia ETH/USD datafeed
    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: INITIAL_FUNDING_AMOUNT}();
        _;
    }

    function setUp() external {
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, 10 ether);
    }

    function testGetOwner() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.fund{value: 1 wei}();
    }

    function testFundUpdatesSenderFunding() public funded {
        assertEq(fundMe.getAddressToAmountFunded(USER), INITIAL_FUNDING_AMOUNT);
    }

    function testFundUpdatesFunder() public funded {
        assertEq(fundMe.getFunder(0), USER);
    }

    function testOnlyOwnerCanWithdraw() public {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        address owner = fundMe.getOwner();
        uint256 startOwnerBalance = owner.balance;
        uint256 startFundMeBalance = address(fundMe).balance;

        vm.prank(owner);
        fundMe.withdraw();

        uint256 endOwnerBalance = owner.balance;
        assertEq(startOwnerBalance + startFundMeBalance, endOwnerBalance);

        uint256 endFundMeBalance = address(fundMe).balance;
        assertEq(endFundMeBalance, 0);
    }

    function testWithdrawWithMultipleFunders_Cheaper() public funded {
        uint256 numFunders = 10;
        uint256 initialFundersIndex = 1;

        for (uint256 i = initialFundersIndex; i < numFunders; i++) {
            // vm.hoax = vm.prank + vm.deal
            hoax(address(uint160(i)), INITIAL_FUNDING_AMOUNT);
            fundMe.fund{value: INITIAL_FUNDING_AMOUNT}();
        }

        address owner = fundMe.getOwner();
        uint256 startOwnerBalance = owner.balance;
        uint256 startFundMeBalance = address(fundMe).balance;

        //uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(owner);
        fundMe.cheaperWithdraw();
        //uint256 gasEnd = gasleft();
        //uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        //console.log(gasUsed);

        uint256 endOwnerBalance = owner.balance;
        assertEq(startOwnerBalance + startFundMeBalance, endOwnerBalance);

        uint256 endFundMeBalance = address(fundMe).balance;
        assertEq(endFundMeBalance, 0);
    }

    function testWithdrawWithMultipleFunders() public funded {
        uint256 numFunders = 10;
        uint256 initialFundersIndex = 1;

        for (uint256 i = initialFundersIndex; i < numFunders; i++) {
            // vm.hoax = vm.prank + vm.deal
            hoax(address(uint160(i)), INITIAL_FUNDING_AMOUNT);
            fundMe.fund{value: INITIAL_FUNDING_AMOUNT}();
        }

        address owner = fundMe.getOwner();
        uint256 startOwnerBalance = owner.balance;
        uint256 startFundMeBalance = address(fundMe).balance;

        //uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(owner);
        fundMe.withdraw();
        //uint256 gasEnd = gasleft();
        //uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        //console.log(gasUsed);

        uint256 endOwnerBalance = owner.balance;
        assertEq(startOwnerBalance + startFundMeBalance, endOwnerBalance);

        uint256 endFundMeBalance = address(fundMe).balance;
        assertEq(endFundMeBalance, 0);
    }
}

// forge test -vvvv --match-test testPriceFeedVersionIsAccurate --rpc-url $SEPOLIA_RPC_URL --private-key=$PRIVATE_KEY
