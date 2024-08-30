// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "lib/forge-std/src/Script.sol";
import {CytricStaking} from "../src/CytricStaking.sol";

contract DeployCytricStaking is Script {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    address cytricToken = 0xF9178b484D2f8956ebC5d2730397E53213A544A7;
    uint256 baseRate = 3170000000000000; // see README

    function run() external {
        vm.startBroadcast(deployerPrivateKey);
        CytricStaking cytricStaking = new CytricStaking(cytricToken, baseRate);
        vm.stopBroadcast();
        console.log("Cytric Staking Address: ", address(cytricStaking));
    }
}
