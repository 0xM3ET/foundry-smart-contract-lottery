// SPDX-License-Identifier:MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

abstract contract CodeConstants {
    uint256 public constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant LOCAL_CHAIN_ID = 31337;
}

contract HelperConfig is CodeConstants, Script {
    /**Errors */
    error HelperConfig__InvalidChainId();

    /** VRF mock values */
    uint96 public constant MOCK_BASE_FEE = 0.25 ether;
    uint96 public constant MOCK_GAS_PRICE_LINK = 1e9;
    // LINK/ETH Price
    int256 public constant MOCK_WEI_PER_UNIT_LINK = 4e15;

    /** State variables */
    struct NetworkConfig {
        uint256 _entranceFee;
        uint256 _interval;
        address _vrfCoordiantor;
        bytes32 _gasLane;
        uint32 _callbackGasLimit;
        uint256 _subscriptionId;
    }

    NetworkConfig public localNetworkConfig;
    mapping(uint256 chainId => NetworkConfig) public networkConfigs;

    constructor() {
        networkConfigs[ETH_SEPOLIA_CHAIN_ID] = getSepoliaEthConfig();
    }

    function getConfigByChainId(
        uint256 _chainId
    ) public returns (NetworkConfig memory) {
        if (networkConfigs[_chainId]._vrfCoordiantor != address(0)) {
            return networkConfigs[_chainId];
        } else if (_chainId == LOCAL_CHAIN_ID) {
            return getOrCreateAnvilEthConfig();
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }

    function getConfig() public returns (NetworkConfig memory) {
        return getConfigByChainId(block.chainid);
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                _entranceFee: 0.01 ether,
                _interval: 30, //seconds
                _vrfCoordiantor: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
                _gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
                _callbackGasLimit: 500000, //500,000
                _subscriptionId: 0
            });
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        //check to see if we set an active network config
        if (localNetworkConfig._vrfCoordiantor != address(0)) {
            return localNetworkConfig;
        }

        //Deploy Mocks and such
        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfCoordinatorMock = new VRFCoordinatorV2_5Mock(
            MOCK_BASE_FEE,
            MOCK_GAS_PRICE_LINK,
            MOCK_WEI_PER_UNIT_LINK
        );
        vm.stopBroadcast();

        localNetworkConfig = NetworkConfig({
            _entranceFee: 0.01 ether,
            _interval: 30, //seconds
            _vrfCoordiantor: address(vrfCoordinatorMock),
            // Doesn't matter
            _gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            _callbackGasLimit: 500000, //500,000
            _subscriptionId: 0
        });

        return localNetworkConfig;
    }
}
