// SPDX-License-Identifier:MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "./Interactions.s.sol";

contract DeployRaffle is Script {
    function run() public {
        deployContract();
    }

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

            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(
                netConfig._vrfCoordiantor,
                netConfig._subscriptionId,
                netConfig._link
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

        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(
            address(raffle),
            netConfig._vrfCoordiantor,
            netConfig._subscriptionId
        );

        return (raffle, helperConfig);
    }
}
