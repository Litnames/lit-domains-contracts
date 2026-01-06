// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Test.sol";
import "../src/registrar/Registrar.sol";
import "../src/registry/Registry.sol";

contract RegistrationFlowTest is Test {
    RegistrarController registrar;

    address deployer = 0x89437f024077342925Ec2D60bCC2FD6f9780E6DA;
    address testUser = address(0x1234);

    function setUp() public {
        // Fork mainnet at latest block
        vm.createSelectFork(
            "https://eth-mainnet.g.alchemy.com/v2/0hSlTk0-XTrMCE6dpe1VkoGCDlIYaGku"
        );

        // Use deployed contract address
        registrar = RegistrarController(
            0xA4059B3f409F02FEAA4976bc130F47D535A76028
        );

        // Give testUser some ETH
        vm.deal(testUser, 10 ether);

        // Impersonate deployer for admin actions if needed
        vm.startPrank(deployer);
        // Set launchTime to now or slightly in the future
        registrar.setLaunchTime(block.timestamp + 1);
        vm.stopPrank();
    }

    function testRegisterName() public {
        vm.startPrank(testUser);

        string memory name = "testname";
        address owner = testUser;
        uint256 duration = 366 days;
        address resolver = address(0x7aa4c77EE8a76a91c0ea18a1D7fc118Eb63Ef1fB);
        bytes[] memory data = new bytes[](0);
        bool reverseRecord = false;
        address referrer = address(0);

        uint256 price = registrar.registerPrice(name, duration);

        RegistrarController.RegisterRequest memory req = RegistrarController
            .RegisterRequest({
                name: name,
                owner: owner,
                duration: duration,
                resolver: resolver,
                data: data,
                reverseRecord: reverseRecord,
                referrer: referrer
            });

        // Advance time to after launchTime
        vm.warp(block.timestamp + 2);

        registrar.register{value: price}(req);

        // Assert name is not available anymore
        bool available = registrar.available(name);
        assertFalse(
            available,
            "Name should not be available after registration"
        );

        vm.stopPrank();
    }

    function testCannotRegisterBeforeLaunch() public {
        vm.startPrank(testUser);

        string memory name = "earlybird";
        address owner = testUser;
        uint256 duration = 366 days;
        address resolver = address(0x7aa4c77EE8a76a91c0ea18a1D7fc118Eb63Ef1fB);
        bytes[] memory data = new bytes[](0);
        bool reverseRecord = false;
        address referrer = address(0);

        uint256 price = registrar.registerPrice(name, duration);

        RegistrarController.RegisterRequest memory req = RegistrarController
            .RegisterRequest({
                name: name,
                owner: owner,
                duration: duration,
                resolver: resolver,
                data: data,
                reverseRecord: reverseRecord,
                referrer: referrer
            });

        // Do NOT advance time
        vm.expectRevert(RegistrarController.PublicSaleNotLive.selector);
        registrar.register{value: price}(req);

        vm.stopPrank();
    }

    function testCannotRegisterShortDuration() public {
        vm.startPrank(testUser);

        string memory name = "shortduration";
        address owner = testUser;
        uint256 duration = 1 days; // Too short
        address resolver = address(0x7aa4c77EE8a76a91c0ea18a1D7fc118Eb63Ef1fB);
        bytes[] memory data = new bytes[](0);
        bool reverseRecord = false;
        address referrer = address(0);

        uint256 price = registrar.registerPrice(name, duration);

        RegistrarController.RegisterRequest memory req = RegistrarController
            .RegisterRequest({
                name: name,
                owner: owner,
                duration: duration,
                resolver: resolver,
                data: data,
                reverseRecord: reverseRecord,
                referrer: referrer
            });

        // Advance time to after launchTime
        vm.warp(block.timestamp + 2);

        vm.expectRevert(
            abi.encodeWithSelector(
                RegistrarController.DurationTooShort.selector,
                duration
            )
        );
        registrar.register{value: price}(req);

        vm.stopPrank();
    }

    function testCannotRegisterReservedName() public {
        // Assume "reserved" is a reserved name in your ReservedRegistry
        string memory name = "lit";
        address owner = testUser;
        uint256 duration = 366 days;
        address resolver = address(0x7aa4c77EE8a76a91c0ea18a1D7fc118Eb63Ef1fB);
        bytes[] memory data = new bytes[](0);
        bool reverseRecord = false;
        address referrer = address(0);

        uint256 price = registrar.registerPrice(name, duration);

        RegistrarController.RegisterRequest memory req = RegistrarController
            .RegisterRequest({
                name: name,
                owner: owner,
                duration: duration,
                resolver: resolver,
                data: data,
                reverseRecord: reverseRecord,
                referrer: referrer
            });

        // Advance time to after launchTime
        vm.warp(block.timestamp + 2);

        vm.startPrank(testUser);
        vm.expectRevert(RegistrarController.NameReserved.selector);
        registrar.register{value: price}(req);
        vm.stopPrank();
    }

    function testCannotRegisterWithInsufficientValue() public {
        vm.startPrank(testUser);

        string memory name = "notenough";
        address owner = testUser;
        uint256 duration = 366 days;
        address resolver = address(0x7aa4c77EE8a76a91c0ea18a1D7fc118Eb63Ef1fB);
        bytes[] memory data = new bytes[](0);
        bool reverseRecord = false;
        address referrer = address(0);

        uint256 price = registrar.registerPrice(name, duration);

        RegistrarController.RegisterRequest memory req = RegistrarController
            .RegisterRequest({
                name: name,
                owner: owner,
                duration: duration,
                resolver: resolver,
                data: data,
                reverseRecord: reverseRecord,
                referrer: referrer
            });

        // Advance time to after launchTime
        vm.warp(block.timestamp + 2);

        vm.expectRevert(RegistrarController.InsufficientValue.selector);
        registrar.register{value: price - 1}(req);

        vm.stopPrank();
    }

    function testCannotRegisterSameNameTwice() public {
        vm.startPrank(testUser);

        string memory name = "unique";
        address owner = testUser;
        uint256 duration = 366 days;
        address resolver = address(0x7aa4c77EE8a76a91c0ea18a1D7fc118Eb63Ef1fB);
        bytes[] memory data = new bytes[](0);
        bool reverseRecord = false;
        address referrer = address(0);

        uint256 price = registrar.registerPrice(name, duration);

        RegistrarController.RegisterRequest memory req = RegistrarController
            .RegisterRequest({
                name: name,
                owner: owner,
                duration: duration,
                resolver: resolver,
                data: data,
                reverseRecord: reverseRecord,
                referrer: referrer
            });

        // Advance time to after launchTime
        vm.warp(block.timestamp + 2);

        registrar.register{value: price}(req);

        // Try to register again
        vm.expectRevert(
            abi.encodeWithSelector(
                RegistrarController.NameNotAvailable.selector,
                name
            )
        );
        registrar.register{value: price}(req);

        vm.stopPrank();
    }

    function testRegisterWithResolverDataFailsIfNoResolver() public {
        vm.startPrank(testUser);

        string memory name = "faildata";
        address owner = testUser;
        uint256 duration = 366 days;
        address resolver = address(0); // No resolver
        bytes[] memory data = new bytes[](1);
        data[0] = hex"1234";
        bool reverseRecord = false;
        address referrer = address(0);

        uint256 price = registrar.registerPrice(name, duration);

        RegistrarController.RegisterRequest memory req = RegistrarController
            .RegisterRequest({
                name: name,
                owner: owner,
                duration: duration,
                resolver: resolver,
                data: data,
                reverseRecord: reverseRecord,
                referrer: referrer
            });

        vm.warp(block.timestamp + 2);

        vm.expectRevert(
            RegistrarController.ResolverRequiredWhenDataSupplied.selector
        );
        registrar.register{value: price}(req);

        vm.stopPrank();
    }

    function testReverseRecordNotAllowedForReservedNames() public {
        string memory name = "lit"; // Reserved name
        address owner = testUser;
        uint256 duration = 366 days;
        address resolver = address(0x7aa4c77EE8a76a91c0ea18a1D7fc118Eb63Ef1fB);
        bytes[] memory data = new bytes[](0);
        bool reverseRecord = true; // Try to set reverse record
        address referrer = address(0);

        uint256 price = registrar.registerPrice(name, duration);

        RegistrarController.RegisterRequest memory req = RegistrarController
            .RegisterRequest({
                name: name,
                owner: owner,
                duration: duration,
                resolver: resolver,
                data: data,
                reverseRecord: reverseRecord,
                referrer: referrer
            });

        vm.warp(block.timestamp + 2);

        vm.startPrank(testUser);
        vm.expectRevert(RegistrarController.NameReserved.selector);
        registrar.register{value: price}(req);
        vm.stopPrank();
    }

    function testWithdrawETH() public {
        address receiver = address(0xdeadbeef);
        vm.startPrank(deployer);
        registrar.setPaymentReceiver(receiver);
        vm.stopPrank();

        vm.startPrank(testUser);
        string memory name = "withdrawtest";
        uint256 duration = 366 days;
        address resolver = address(0x7aa4c77EE8a76a91c0ea18a1D7fc118Eb63Ef1fB);
        bytes[] memory data = new bytes[](0);
        bool reverseRecord = false;
        address referrer = address(0);

        uint256 price = registrar.registerPrice(name, duration);

        RegistrarController.RegisterRequest memory req = RegistrarController
            .RegisterRequest({
                name: name,
                owner: testUser,
                duration: duration,
                resolver: resolver,
                data: data,
                reverseRecord: reverseRecord,
                referrer: referrer
            });

        vm.warp(block.timestamp + 2);

        registrar.register{value: price}(req);
        vm.stopPrank();

        uint256 receiverBalanceBefore = receiver.balance;

        vm.startPrank(testUser);
        registrar.withdrawETH();
        vm.stopPrank();

        uint256 receiverBalanceAfter = receiver.balance;
        assertGt(
            receiverBalanceAfter,
            receiverBalanceBefore,
            "Receiver should get ETH"
        );
    }

    function testRenewName() public {
        vm.startPrank(testUser);

        string memory name = "renewme";
        uint256 duration = 366 days;
        address resolver = address(0x7aa4c77EE8a76a91c0ea18a1D7fc118Eb63Ef1fB);
        bytes[] memory data = new bytes[](0);
        bool reverseRecord = false;
        address referrer = address(0);

        uint256 price = registrar.registerPrice(name, duration);

        RegistrarController.RegisterRequest memory req = RegistrarController
            .RegisterRequest({
                name: name,
                owner: testUser,
                duration: duration,
                resolver: resolver,
                data: data,
                reverseRecord: reverseRecord,
                referrer: referrer
            });

        vm.warp(block.timestamp + 2);

        registrar.register{value: price}(req);

        uint256 renewPrice = registrar.registerPrice(name, duration);

        registrar.renew{value: renewPrice}(name, duration);

        vm.stopPrank();
    }

    function testSetPaymentReceiverZeroAddressReverts() public {
        vm.startPrank(deployer);
        vm.expectRevert(RegistrarController.InvalidPaymentReceiver.selector);
        registrar.setPaymentReceiver(address(0));
        vm.stopPrank();
    }




function testSetAndGetSubnodeRecord() public {
    LitNamesRegistry registry = LitNamesRegistry(0xdf9f3F869BAE8E6Dc183bfADcC36Da126f515a18);

    // Setup: create a parent node
    bytes32 parentNode = keccak256(abi.encodePacked("parent"));
    registry.setRecord(parentNode, testUser, address(0), 0);

    // Only owner can set subnode
    vm.startPrank(testUser);

    bytes32 label = keccak256(abi.encodePacked("child"));
    address subOwner = address(0x5678);
    address subResolver = address(0x1111111111111111111111111111111111111111);
    uint64 subTTL = 3600;

    registry.setSubnodeRecord(parentNode, label, subOwner, subResolver, subTTL);

    bytes32 subnode = keccak256(abi.encodePacked(parentNode, label));
    assertEq(registry.owner(subnode), subOwner, "Subnode owner mismatch");
    assertEq(registry.resolver(subnode), subResolver, "Subnode resolver mismatch");
    assertEq(registry.ttl(subnode), subTTL, "Subnode TTL mismatch");

    vm.stopPrank();
}

function testOnlyOwnerCanModifyNode() public {
    LitNamesRegistry registry = LitNamesRegistry(0xdf9f3F869BAE8E6Dc183bfADcC36Da126f515a18);

    bytes32 node = keccak256(abi.encodePacked("secure"));
    registry.setRecord(node, testUser, address(0), 0);

    // Try to modify as non-owner
    address attacker = address(0x9999);
    vm.startPrank(attacker);
    vm.expectRevert();
    registry.setOwner(node, attacker);
    vm.stopPrank();
}

function testOperatorCanModifyNode() public {
    LitNamesRegistry registry = LitNamesRegistry(0xdf9f3F869BAE8E6Dc183bfADcC36Da126f515a18);

    bytes32 node = keccak256(abi.encodePacked("delegated"));
    registry.setRecord(node, testUser, address(0), 0);

    address operator = address(0x8888);
    vm.startPrank(testUser);
    registry.setApprovalForAll(operator, true);
    vm.stopPrank();

    // Operator modifies node
    vm.startPrank(operator);
    registry.setResolver(node, address(0x2222222222222222222222222222222222222222));
    vm.stopPrank();
}

function testRecordExists() public {
    LitNamesRegistry registry = LitNamesRegistry(0xdf9f3F869BAE8E6Dc183bfADcC36Da126f515a18);

    bytes32 node = keccak256(abi.encodePacked("exists"));
    assertFalse(registry.recordExists(node), "Record should not exist yet");

    registry.setRecord(node, testUser, address(0), 0);
    assertTrue(registry.recordExists(node), "Record should exist after creation");
}
}
