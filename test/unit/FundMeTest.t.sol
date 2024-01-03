// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {FundMeDeploy} from "../../script/FundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address User = makeAddr("3illbaby");
    uint256 StartingFunds = 100 ether;
    uint256 constant gasPrice = 1;

    modifier funded() {
        vm.prank(User);
        fundMe.fund{value: 60e18}();
        _;
    }

    function setUp() external {
        FundMeDeploy deployFundMe = new FundMeDeploy();
        fundMe = deployFundMe.run();
        vm.deal(User, StartingFunds);
    }

    function testMinimumUSDValue() external {
        uint minUsd = fundMe.minimumUsd();
        console.log(minUsd);
        assertEq(minUsd, 50e18);
    }

    function testOwnerIsMsgSender() external {
        assertEq(fundMe.Owner(), msg.sender);
    }

    function testPriceFeedVersion() external {
        uint version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughEth() external {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundIsSuccessful() external funded {
        assertEq(fundMe.amountFunded(User), 60e18);
    }

    function testFundFromMultipleAddresses() external {
        uint256 contractStartingBalance = address(fundMe).balance;
        console.log(contractStartingBalance);

        uint160 numberOfAddresses = 10;
        uint160 index = 2;

        //? The hoax method can be used tp create a user and fund the user
        for (uint160 i = index; i < numberOfAddresses; i++) {
            hoax(address(i), 100e18);
            fundMe.fund{value: 60e18}();
        }

        uint256 contractEndBalance = address(fundMe).balance;

        console.log(contractEndBalance);

        assertEq(
            address(fundMe).balance,
            contractStartingBalance + contractEndBalance
        );
    }

    function testFundersArray() external funded {
        address firstAddress = fundMe.funders(0);

        assertEq(firstAddress, User);
    }

    function testEnsureFundersArray() external funded {
        address firstAddress = fundMe.funders(0);

        assertNotEq(firstAddress, msg.sender);
    }

    function testEnsureOnlyOwnerCanWithdraw() external funded {
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdraw() external funded {
        console.log(fundMe.Owner().balance);
        console.log(address(fundMe).balance);

        vm.prank(msg.sender);
        fundMe.withdraw();

        console.log(address(fundMe).balance);
        console.log(fundMe.Owner().balance);
        assertEq(fundMe.amountFunded(msg.sender), 0);
    }

    function testWithdrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 index = 2;

        for (uint160 i = index; i < numberOfFunders; i++) {
            hoax(address(i), 100e18);
            fundMe.fund{value: 60e18}();
        }

        uint256 startingOwnerBalance = fundMe.Owner().balance;
        uint256 startingContractBalance = address(fundMe).balance;

        vm.startPrank(fundMe.Owner());
        fundMe.withdraw();
        vm.stopPrank();

        assertEq(address(fundMe).balance, 0);
        assertEq(
            fundMe.Owner().balance,
            startingOwnerBalance + startingContractBalance
        );
    }
}
