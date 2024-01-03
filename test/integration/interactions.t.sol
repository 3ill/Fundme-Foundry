// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {FundMeDeploy} from "../../script/FundMe.s.sol";
import {FundingFundMe} from "../../script/Interaction.s.sol";

contract Interaction is Test {
    FundMe fundMe;

    address User = makeAddr("3illbaby");
    uint256 StartingFunds = 100 ether;
    uint256 constant gasPrice = 1;

    function setUp() external {
        vm.deal(User, StartingFunds);
        FundMeDeploy fundMeDeploy = new FundMeDeploy();
        fundMe = fundMeDeploy.run();
    }

    function testUserCanFund() public {
        FundingFundMe fundingFundMe = new FundingFundMe();

        fundingFundMe.fundFundMe(address(fundMe));

        uint256 fundMeBalance = address(fundMe).balance;
        assertEq(fundMeBalance, 0.05 ether);
    }
}
