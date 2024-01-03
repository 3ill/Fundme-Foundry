// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract FundMeDeploy is Script {
    //? every function not below the startBroadcasts gets simulated
    HelperConfig helperConfig = new HelperConfig();
    address priceFeedAddress = helperConfig.activeNetworkConfig();

    /**
     * ?note: vm.startBroadcast enables that the deployer is msg.sender
     */
    function run() external returns (FundMe) {
        vm.startBroadcast();
        FundMe fundMe = new FundMe(priceFeedAddress);
        vm.stopBroadcast();

        return fundMe;
    }
}
