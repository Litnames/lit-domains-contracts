// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Script.sol";

import {LitNamesRegistry} from "../src/registry/Registry.sol";
import {LitAuctionHouse} from "../src/auction/LitAuctionHouse.sol";
import {ReverseRegistrar} from "../src/registrar/ReverseRegistrar.sol";
import {PriceOracle} from "../src/registrar/types/PriceOracle.sol";
import {ReservedRegistry} from "../src/registrar/types/ReservedRegistry.sol";
import {bArtioPriceOracle} from "../src/registrar/types/bArtioPriceOracle.sol";
import {RegistrarController} from "../src/registrar/Registrar.sol";
import {BaseRegistrar} from "../src/registrar/types/BaseRegistrar.sol";
import {UniversalResolver} from "../src/resolver/UniversalResolver.sol";
import {LitDefaultResolver} from "../src/resolver/Resolver.sol";
import {LNS} from "../src/registry/interfaces/LNS.sol";
import {IWETH} from "../src/auction/interfaces/IWETH.sol";
import {
    IReservedRegistry
} from "../src/registrar/interfaces/IReservedRegistry.sol";
import {
    IReverseRegistrar
} from "../src/registrar/interfaces/IReverseRegistrar.sol";

import {
    LIT_NODE,
    ADDR_REVERSE_NODE,
    REVERSE_NODE
} from "../src/utils/Constants.sol";

contract DeployScript is Script {
    // Deployment addresses
    LitNamesRegistry public registry;
    BaseRegistrar public baseRegistrar;
    RegistrarController public registrar;
    ReverseRegistrar public reverseRegistrar;
    LitDefaultResolver public resolver;
    UniversalResolver public universalResolver;
    PriceOracle public priceOracle;
    ReservedRegistry public reservedRegistry;
    LitAuctionHouse public auctionHouse;

    // Configuration
    address public weth; // Set based on network
    address public pythContract; // For PriceOracle
    bytes32 public litUsdPriceFeedId; // For PriceOracle
    uint256 public minRegistrationDuration = 28 days;
    uint256 public minCommitmentAge = 60 seconds;
    uint256 public maxCommitmentAge = 86400 seconds;
    uint256 public auctionDuration = 7 days;
    uint192 public reservePrice = 0.01 ether;
    uint56 public timeBuffer = 5 minutes;
    uint8 public minBidIncrementPercentage = 5;

    // NFT metadata URIs
    string public tokenURI = "https://metadata.litnames.io/nft/";
    string public collectionURI =
        "https://metadata.litnames.io/collection.json";

    // Universal Resolver gateway URLs
    string[] public gatewayURLs;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Deploying contracts with deployer:", deployer);

        vm.startBroadcast(deployerPrivateKey);

        // Set WETH address based on chain
        if (block.chainid == 1) {
            weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // Mainnet
            pythContract = 0x4305FB66699C3B2702D4d05CF36551390A4c69C6; // Mainnet Pyth
        } else if (block.chainid == 5) {
            weth = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6; // Goerli
            pythContract = 0xff1a0f4744e8582DF1aE09D5611b887B6a12925C; // Goerli Pyth
        } else if (block.chainid == 11155111) {
            weth = 0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9; // Sepolia
            pythContract = 0xDd24F84d36BF92C65F92307595335bdFab5Bbd21; // Sepolia Pyth
        } else if (block.chainid == 80084) {
            // bArtio testnet
            weth = address(0); // Set bArtio WETH address
        } else {
            // Deploy mock WETH for local testing
            weth = address(0);
            pythContract = address(0);
        }

        // Set gateway URLs for Universal Resolver
        gatewayURLs = new string[](1);
        gatewayURLs[0] = "https://gateway.litnames.io/";

        // 1. Deploy Registry (core contract, no dependencies)
        console.log("Deploying Registry...");
        registry = new LitNamesRegistry();
        console.log("Registry deployed at:", address(registry));

        // 2. Deploy BaseRegistrar (depends on Registry)
        // Constructor: LNS registry_, address owner_, bytes32 baseNode_, string memory tokenURI_, string memory collectionURI_
        console.log("Deploying BaseRegistrar...");
        baseRegistrar = new BaseRegistrar(
            registry,
            deployer, // owner
            LIT_NODE, // baseNode (.lit)
            tokenURI,
            collectionURI
        );
        console.log("BaseRegistrar deployed at:", address(baseRegistrar));

        // 3. Deploy ReverseRegistrar (depends on Registry)
        console.log("Deploying ReverseRegistrar...");
        // Constructor: LNS registry_
        reverseRegistrar = new ReverseRegistrar(registry);
        console.log("ReverseRegistrar deployed at:", address(reverseRegistrar));

        // 4. Set up .reverse and addr.reverse nodes
        console.log("Setting up reverse nodes...");

        // Set up .reverse node
        registry.setSubnodeRecord(
            bytes32(0),
            keccak256(abi.encodePacked("reverse")),
            deployer,
            address(0),
            0
        );
        console.log("Created .reverse node");

        // Set up addr.reverse node and transfer to ReverseRegistrar
        registry.setSubnodeRecord(
            REVERSE_NODE,
            keccak256(abi.encodePacked("addr")),
            address(reverseRegistrar),
            address(0),
            0
        );
        console.log(
            "Created addr.reverse node and transferred to ReverseRegistrar"
        );

        // 5. Deploy Resolver with correct addresses
        console.log("Deploying Resolver...");
        // Constructor: LNS lns_, address registrarController_, address reverseRegistrar_, address owner_
        // Note: We deploy with zero address for registrarController first, then set it after
        resolver = new LitDefaultResolver(
            registry,
            address(baseRegistrar),
            address(reverseRegistrar),
            deployer // owner
        );
        console.log("Resolver deployed at:", address(resolver));

        // 6. Set resolver for root and REVERSE_NODE
        console.log("Setting resolvers for root and REVERSE_NODE...");
        registry.setResolver(bytes32(0), address(resolver));
        registry.setResolver(REVERSE_NODE, address(resolver));
        reverseRegistrar.setDefaultResolver(address(resolver));
        console.log("Resolvers set");

        // 7. Deploy PriceOracle (or bArtioPriceOracle based on network)
        console.log("Deploying PriceOracle...");
        if (block.chainid == 80084) {
            // bArtio testnet - no constructor args
            priceOracle = PriceOracle(address(new bArtioPriceOracle()));
        } else {
            // Constructor: address pyth_, bytes32 litUsdPythPriceFeedId_
            if (litUsdPriceFeedId == bytes32(0)) {
                // Set a default or get from env
                litUsdPriceFeedId = 0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace; // TODO: Set proper price feed ID
            }
            priceOracle = new PriceOracle(pythContract, litUsdPriceFeedId);
        }
        console.log("PriceOracle deployed at:", address(priceOracle));

        // 8. Deploy ReservedRegistry (no dependencies)
        console.log("Deploying ReservedRegistry...");
        reservedRegistry = new ReservedRegistry(deployer);
        console.log("ReservedRegistry deployed at:", address(reservedRegistry));

        // 9. Deploy Registrar Controller (now reverse nodes are set up)
        console.log("Deploying Registrar Controller...");
        // 8. Deploy Registrar (10 arguments)
        registrar = new RegistrarController(
            baseRegistrar,
            priceOracle,
            reverseRegistrar,
            deployer, // whitelistSigner
            deployer, // freeWhitelistSigner
            reservedRegistry,
            deployer,
            LIT_NODE,
            ".lit",
            deployer // paymentReceiver
        );

        console.log("Registrar deployed at:", address(registrar));

        // 10. Deploy UniversalResolver (depends on Registry)
        console.log("Deploying UniversalResolver...");
        // Constructor: address _registry, string[] memory _urls
        universalResolver = new UniversalResolver(
            address(registry),
            gatewayURLs
        );
        console.log(
            "UniversalResolver deployed at:",
            address(universalResolver)
        );

        // 11. Deploy LitAuctionHouse (IWETH type)
        auctionHouse = new LitAuctionHouse(
            baseRegistrar,
            resolver,
            IWETH(weth),
            auctionDuration,
            minRegistrationDuration,
            reservePrice,
            timeBuffer,
            minBidIncrementPercentage,
            deployer
        );
        console.log("LitAuctionHouse deployed at:", address(auctionHouse));

        // 12. Set permissions and ownerships
        console.log("\nSetting up permissions...");

        // Set registrar controller in resolver
        resolver.setRegistrarController(address(registrar));
        console.log("Set Registrar as controller in Resolver");

        // Add Registrar as controller to BaseRegistrar
        baseRegistrar.addController(address(registrar));
        console.log("Added Registrar as controller to BaseRegistrar");

        // Add AuctionHouse as controller to BaseRegistrar
        baseRegistrar.addController(address(auctionHouse));
        console.log("Added AuctionHouse as controller to BaseRegistrar");

        // Set up .lit node
        registry.setSubnodeOwner(bytes32(0), keccak256("lit"), deployer);
        registry.setResolver(LIT_NODE, address(resolver));
        console.log("Set resolver for .lit node in Registry");

        // Transfer ownership of .lit node to BaseRegistrar
        registry.setOwner(LIT_NODE, address(baseRegistrar));
        console.log("Transferred .lit node ownership to BaseRegistrar");

        // Set ReverseRegistrar controller permissions
        reverseRegistrar.setController(address(registrar), true);
        console.log("Added Registrar as controller to ReverseRegistrar");

        // Set default resolver for ReverseRegistrar
        reverseRegistrar.setDefaultResolver(address(resolver));
        console.log("Set default resolver for ReverseRegistrar");

        vm.stopBroadcast();

        // Log all deployed addresses
        console.log("\n=== Deployment Summary ===");
        console.log("Registry:", address(registry));
        console.log("BaseRegistrar:", address(baseRegistrar));
        console.log("Registrar:", address(registrar));
        console.log("ReverseRegistrar:", address(reverseRegistrar));
        console.log("Resolver:", address(resolver));
        console.log("UniversalResolver:", address(universalResolver));
        console.log("PriceOracle:", address(priceOracle));
        console.log("ReservedRegistry:", address(reservedRegistry));
        console.log("AuctionHouse:", address(auctionHouse));
        console.log("WETH:", weth);
        console.log("=========================");
    }
}
