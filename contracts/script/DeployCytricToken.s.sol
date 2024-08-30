// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "lib/forge-std/src/Script.sol";
import {CytricToken} from "../src/CytricToken.sol";

contract DeployCytricToken is Script {

    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    function run() external {
        vm.startBroadcast(deployerPrivateKey);
        CytricToken cytricToken = new CytricToken();
        vm.stopBroadcast();
        console.log("Cytric Token Address: ", address(cytricToken));
    }
}