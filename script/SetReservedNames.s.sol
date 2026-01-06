// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Script.sol";
import "../src/registrar/types/ReservedRegistry.sol";

contract SetReservedNamesScript is Script {
    function run() external {
        // Mainnet fork
        vm.createSelectFork(
            "https://eth-mainnet.g.alchemy.com/v2/0hSlTk0-XTrMCE6dpe1VkoGCDlIYaGku"
        );

        // Use your private key
        uint256 pk = uint256(
            0xe9574fbd49d86bbc493bb23f98768c0e96f17d0a9c0ae951454f72aa80df31c5
        );
        address owner = vm.addr(pk);

        // Start broadcasting
        vm.startBroadcast(pk);

        ReservedRegistry registry = ReservedRegistry(
            0x96Ee312ad819A4BbD9ef6412cF05988c63e2851A
        );

        registry.setReservedName("lit");
        registry.setReservedName("litnames");
        registry.setReservedName("main");
        registry.setReservedName("litdomain");

        vm.stopBroadcast();
    }
}
