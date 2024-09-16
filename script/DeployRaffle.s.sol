// SPDX-License-Identifier:MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubscription} from "./Interactions.s.sol";

contract DeployRaffle is Script {
    function run() public {}

    function deployContract() public returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();

        //local ->deploy micks , get local config
        //Sepolia -> get sepolia config
        HelperConfig.NetworkConfig memory netConfig = helperConfig.getConfig();

        if (netConfig._subscriptionId == 0) {
            CreateSubscription createSubscription = new CreateSubscription();
            (
                netConfig._subscriptionId,
                netConfig._vrfCoordiantor
            ) = createSubscription.createSubscription(
                netConfig._vrfCoordiantor
            );
        }

        vm.startBroadcast();
        Raffle raffle = new Raffle(
            netConfig._entranceFee,
            netConfig._interval,
            netConfig._vrfCoordiantor,
            netConfig._gasLane,
            netConfig._subscriptionId,
            netConfig._callbackGasLimit
        );
        vm.stopBroadcast();
        return (raffle, helperConfig);
    }
}
