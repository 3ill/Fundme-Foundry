// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundingFundMe is Script {
    uint256 constant FUND_AMOUNT = 0.05 ether;

    function fundFundMe(address _mostRecentDeployment) public {
        vm.startBroadcast();
        FundMe(payable(_mostRecentDeployment)).fund{value: FUND_AMOUNT}();
        vm.stopBroadcast();

        console.log("Funded fundme contract with %s", FUND_AMOUNT);
    }

    function run() external {
        address mostRecentDeployment = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        vm.startBroadcast();
        fundFundMe(mostRecentDeployment);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    uint256 constant FUND_AMOUNT = 0.05 ether;

    function fundFundMe(address _mostRecentDeployment) public {
        vm.startBroadcast();
        FundMe(payable(_mostRecentDeployment)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentDeployment = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        vm.startBroadcast();
        fundFundMe(mostRecentDeployment);
        vm.stopBroadcast();
    }
}
