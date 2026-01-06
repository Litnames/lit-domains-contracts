// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17 <0.9.0;

import {Test} from "forge-std/Test.sol";
import {PriceOracle} from "src/registrar/types/PriceOracle.sol";
import {IPriceOracle} from "src/registrar/interfaces/IPriceOracle.sol";
import {IPyth} from "@pythnetwork/pyth-sdk-solidity/IPyth.sol";
import {PythErrors} from "@pythnetwork/pyth-sdk-solidity/PythErrors.sol";
import {MockPyth} from "@pythnetwork/pyth-sdk-solidity/MockPyth.sol";
import {IPyth} from "@pythnetwork/pyth-sdk-solidity/IPyth.sol";

contract PriceOracleTest is Test {
    IPyth pyth;
    bytes32 constant LIT_USD_PYTH_PRICE_FEED_ID = 0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace ;

    PriceOracle priceOracle;
    address user = 0x89437f024077342925Ec2D60bCC2FD6f9780E6DA; // your address


    function setUp() public {
        vm.startPrank(user);
        pyth = IPyth(0x4305FB66699C3B2702D4d05CF36551390A4c69C6); // 0 as fee, adjust if needed
        priceOracle = new PriceOracle(
            address(pyth),
            LIT_USD_PYTH_PRICE_FEED_ID
        );
        emit log("setUp complete");
        vm.stopPrank();
    }

    // ETH
    function test_priceStable_oneCharOneYear() public {
        vm.startPrank(user);
        emit log("test_priceStable_oneCharOneYear");
        IPriceOracle.Price memory price = priceOracle.price(
            "a",
            0,
            365 days,
            IPriceOracle.Payment.ETH
        );
        emit log_named_uint("base", price.base);
        emit log_named_uint("discount", price.discount);
        vm.stopPrank();
    }

    function test_priceStable_oneCharTwoYears() public {
        vm.startPrank(user);
        emit log("test_priceStable_oneCharTwoYears");
        IPriceOracle.Price memory price = priceOracle.price(
            "a",
            0,
            365 days * 2,
            IPriceOracle.Payment.ETH
        );
        emit log_named_uint("base", price.base);
        emit log_named_uint("discount", price.discount);
        vm.stopPrank();
    }

    function test_priceStable_oneCharThreeYears() public {
        vm.startPrank(user);
        emit log("test_priceStable_oneCharThreeYears");
        IPriceOracle.Price memory price = priceOracle.price(
            "a",
            0,
            365 days * 3,
            IPriceOracle.Payment.ETH
        );
        emit log_named_uint("base", price.base);
        emit log_named_uint("discount", price.discount);
        vm.stopPrank();
    }

    function test_priceStable_oneCharFourYears() public {
        vm.startPrank(user);
        emit log("test_priceStable_oneCharFourYears");
        IPriceOracle.Price memory price = priceOracle.price(
            "a",
            0,
            365 days * 4,
            IPriceOracle.Payment.ETH
        );
        emit log_named_uint("base", price.base);
        emit log_named_uint("discount", price.discount);
        vm.stopPrank();
    }

    function test_priceStable_oneCharFiveYears() public {
        vm.startPrank(user);
        emit log("test_priceStable_oneCharFiveYears");
        IPriceOracle.Price memory price = priceOracle.price(
            "a",
            0,
            365 days * 5,
            IPriceOracle.Payment.ETH
        );
        emit log_named_uint("base", price.base);
        emit log_named_uint("discount", price.discount);
        vm.stopPrank();
    }

    function test_priceStable_twoCharOneYear() public {
        vm.startPrank(user);
        emit log("test_priceStable_twoCharOneYear");
        IPriceOracle.Price memory price = priceOracle.price(
            "ab",
            0,
            365 days,
            IPriceOracle.Payment.ETH
        );

        emit log_named_uint("base", price.base);
        emit log_named_uint("discount", price.discount);
        vm.stopPrank();
    }

    function test_priceStable_twoCharTwoYears() public {
        vm.startPrank(user);
        emit log("test_priceStable_twoCharTwoYears");
        IPriceOracle.Price memory price = priceOracle.price(
            "ab",
            0,
            365 days * 2,
            IPriceOracle.Payment.ETH
        );

        emit log_named_uint("base", price.base);
        emit log_named_uint("discount", price.discount);
        vm.stopPrank();
    }

    function test_priceStable_twoCharThreeYears() public {
        vm.startPrank(user);
        emit log("test_priceStable_twoCharThreeYears");
        IPriceOracle.Price memory price = priceOracle.price(
            "ab",
            0,
            365 days * 3,
            IPriceOracle.Payment.ETH
        );

        emit log_named_uint("base", price.base);
        emit log_named_uint("discount", price.discount);
        vm.stopPrank();
    }

    function test_priceStable_twoCharFourYears() public {
        vm.startPrank(user);
        emit log("test_priceStable_twoCharFourYears");
        IPriceOracle.Price memory price = priceOracle.price(
            "ab",
            0,
            365 days * 4,
            IPriceOracle.Payment.ETH
        );

        emit log_named_uint("base", price.base);
        emit log_named_uint("discount", price.discount);
        vm.stopPrank();
    }

    function test_priceStable_twoCharFiveYears() public {
        vm.startPrank(user);
        emit log("test_priceStable_twoCharFiveYears");
        IPriceOracle.Price memory price = priceOracle.price(
            "ab",
            0,
            365 days * 5,
            IPriceOracle.Payment.ETH
        );

        emit log_named_uint("base", price.base);
        emit log_named_uint("discount", price.discount);
        vm.stopPrank();
    }

    function test_priceStable_threeCharOneYear() public {
        vm.startPrank(user);
        emit log("test_priceStable_threeCharOneYear");
        IPriceOracle.Price memory price = priceOracle.price(
            "abc",
            0,
            365 days,
            IPriceOracle.Payment.ETH
        );

        emit log_named_uint("base", price.base);
        emit log_named_uint("discount", price.discount);
        vm.stopPrank();
    }

    function test_priceStable_threeCharTwoYears() public {
        vm.startPrank(user);
        emit log("test_priceStable_threeCharTwoYears");
        IPriceOracle.Price memory price = priceOracle.price(
            "abc",
            0,
            365 days * 2,
            IPriceOracle.Payment.ETH
        );

        emit log_named_uint("base", price.base);
        emit log_named_uint("discount", price.discount);
        vm.stopPrank();
    }

    function test_priceStable_threeCharThreeYears() public {
        vm.startPrank(user);
        emit log("test_priceStable_threeCharThreeYears");
        IPriceOracle.Price memory price = priceOracle.price(
            "abc",
            0,
            365 days * 3,
            IPriceOracle.Payment.ETH
        );

        emit log_named_uint("base", price.base);
        emit log_named_uint("discount", price.discount);
        vm.stopPrank();

    }

    function test_priceStable_threeCharFourYears() public {
        vm.startPrank(user);
        emit log("test_priceStable_threeCharFourYears");
        IPriceOracle.Price memory price = priceOracle.price(
            "abc",
            0,
            365 days * 4,
            IPriceOracle.Payment.ETH
        );

        emit log_named_uint("base", price.base);
        emit log_named_uint("discount", price.discount);
        vm.stopPrank();
    }

    function test_priceStable_threeCharFiveYears() public {
        vm.startPrank(user);
        emit log("test_priceStable_threeCharFiveYears");
        IPriceOracle.Price memory price = priceOracle.price(
            "abc",
            0,
            365 days * 5,
            IPriceOracle.Payment.ETH
        );

        emit log_named_uint("base", price.base);
        emit log_named_uint("discount", price.discount);
        vm.stopPrank();
    }

    function test_priceStable_fourCharOneYear() public {
        vm.startPrank(user);
        emit log("test_priceStable_fourCharOneYear");
        IPriceOracle.Price memory price = priceOracle.price(
            "abcd",
            0,
            365 days,
            IPriceOracle.Payment.ETH
        );

        emit log_named_uint("base", price.base);
        emit log_named_uint("discount", price.discount);
        vm.stopPrank();
    }

    function test_priceStable_fourCharTwoYears() public {
        vm.startPrank(user);
        emit log("test_priceStable_fourCharTwoYears");
        IPriceOracle.Price memory price = priceOracle.price(
            "abcd",
            0,
            365 days * 2,
            IPriceOracle.Payment.ETH
        );

        emit log_named_uint("base", price.base);
        emit log_named_uint("discount", price.discount);
        vm.stopPrank();
    }

    function test_priceStable_fourCharThreeYears() public {
        vm.startPrank(user);
        emit log("test_priceStable_fourCharThreeYears");
        IPriceOracle.Price memory price = priceOracle.price(
            "abcd",
            0,
            365 days * 3,
            IPriceOracle.Payment.ETH
        );

        emit log_named_uint("base", price.base);
        emit log_named_uint("discount", price.discount);
        vm.stopPrank();
    }

    function test_priceStable_fourCharFourYears() public {
        vm.startPrank(user);
        emit log("test_priceStable_fourCharFourYears");
        IPriceOracle.Price memory price = priceOracle.price(
            "abcd",
            0,
            365 days * 4,
            IPriceOracle.Payment.ETH
        );

        assertEq(price.base, 69_000_000 * 4);
        assertEq(price.discount, (price.base * 30) / 100);
        vm.stopPrank();
    }

    function test_priceStable_fourCharFiveYears() public {
        vm.startPrank(user);
        emit log("test_priceStable_fourCharFiveYears");
        IPriceOracle.Price memory price = priceOracle.price(
            "abcd",
            0,
            365 days * 5,
            IPriceOracle.Payment.ETH
        );
        emit log_named_uint("base", price.base);
        emit log_named_uint("discount", price.discount);
        vm.stopPrank();
    }

    function test_priceStable_fiveCharOneYear() public {
        vm.startPrank(user);
        emit log("test_priceStable_fiveCharOneYear");
        IPriceOracle.Price memory price = priceOracle.price(
            "abcde",
            0,
            365 days,
            IPriceOracle.Payment.ETH
        );

        emit log_named_uint("base", price.base);
        emit log_named_uint("discount", price.discount);


        vm.stopPrank();
    }

    function test_priceStable_fiveCharTwoYears() public {
        vm.startPrank(user);
        emit log("test_priceStable_fiveCharTwoYears");
        IPriceOracle.Price memory price = priceOracle.price(
            "abcde",
            0,
            365 days * 2,
            IPriceOracle.Payment.ETH
        );

        emit log_named_uint("base", price.base);
        emit log_named_uint("discount", price.discount);
        vm.stopPrank();
    }

    function test_priceStable_fiveCharThreeYears() public {
        vm.startPrank(user);
        emit log("test_priceStable_fiveCharThreeYears");
        IPriceOracle.Price memory price = priceOracle.price(
            "abcde",
            0,
            365 days * 3,
            IPriceOracle.Payment.ETH
        );

        emit log_named_uint("base", price.base);
        emit log_named_uint("discount", price.discount);
        vm.stopPrank();
    }

    function test_priceStable_fiveCharFourYears() public {
        vm.startPrank(user);
        emit log("test_priceStable_fiveCharFourYears");
        IPriceOracle.Price memory price = priceOracle.price(
            "abcde",
            0,
            365 days * 4,
            IPriceOracle.Payment.ETH
        );

        emit log_named_uint("base", price.base);
        emit log_named_uint("discount", price.discount);
        vm.stopPrank();
    }

    function test_priceStable_fiveCharFiveYears() public {
        vm.startPrank(user);
        emit log("test_priceStable_fiveCharFiveYears");
        IPriceOracle.Price memory price = priceOracle.price(
            "abcde",
            0,
            365 days * 5,
            IPriceOracle.Payment.ETH
        );
        emit log_named_uint("base", price.base);
        emit log_named_uint("discount", price.discount);
        vm.stopPrank();
    }

    // // LIT
    // // https://docs.pyth.network/price-feeds/create-your-first-pyth-app/evm/part-1
    // function createLitUpdate(
    //     int64 litPrice
    // ) private returns (bytes[] memory) {
    //     bytes[] memory updateData = new bytes[](1);
    //     updateData[0] = pyth.createPriceFeedUpdateData(
    //         LIT_USD_PYTH_PRICE_FEED_ID,
    //         litPrice * 100_000, // price
    //         10 * 100_000, // confidence
    //         -5, // exponent
    //         litPrice * 100_000, // emaPrice
    //         10 * 100_000, // emaConfidence
    //         uint64(block.timestamp), // publishTime
    //         uint64(block.timestamp) // prevPublishTime
    //     );

    //     return updateData;
    // }

    // function setLitPrice(int64 litPrice) private {
    //     emit log_named_int("setLitPrice", litPrice);
    //     bytes[] memory updateData = createLitUpdate(litPrice);
    //     uint256 value = pyth.getUpdateFee(updateData);
    //     emit log_named_uint("updateFee", value);
    //     vm.deal(address(this), value);
    //     pyth.updatePriceFeeds{value: value}(updateData);
    // }

    function test_priceLit_oneCharOneYear() public {
        vm.startPrank(user);
        emit log("test_priceLit_oneCharOneYear");
        // setLitPrice(1);

        IPriceOracle.Price memory price = priceOracle.price(
            "a",
            0,
            365 days,
            IPriceOracle.Payment.ETH
        );

        emit log_named_uint("base", price.base);
        emit log_named_uint("discount", price.discount);
        vm.stopPrank();
    }

    function test_priceLit_oneCharTwoYears() public {
        emit log("test_priceLit_oneCharTwoYears");
        // setLitPrice(1);
        vm.startPrank(user);
        IPriceOracle.Price memory price = priceOracle.price(
            "a",
            0,
            365 days * 2,
            IPriceOracle.Payment.ETH
        );

        emit log_named_uint("base", price.base);
        emit log_named_uint("discount", price.discount);
        vm.stopPrank();
    }

    function test_priceLit_oneCharStale() public {

        skip(120);
        vm.expectRevert(abi.encodeWithSelector(PythErrors.StalePrice.selector));
        priceOracle.price("a", 0, 365 days * 2, IPriceOracle.Payment.ETH);
    }

    function test_priceLit_oneCharLessThanThreshold() public {
        vm.startPrank(user);
        priceOracle.setMinPriceInWei(10 ** 18);
        // setLitPrice(1);
        vm.expectRevert(
            abi.encodeWithSelector(PriceOracle.PriceTooLow.selector)
        );
        priceOracle.price("a", 0, 365 days * 2, IPriceOracle.Payment.ETH);
        vm.stopPrank();
    }

    function test_register_price_for_2_years_minus_1_day() public {
        vm.startPrank(user);
        emit log("test_register_price_for_2_years_minus_1_day");
        // setLitPrice(1);

        uint256 duration = 365 days * 2 - 1 days;
        emit log_named_uint("duration", duration);

        IPriceOracle.Price memory price = priceOracle.price(
            "more_than_5_chars",
            0,
            duration,
            IPriceOracle.Payment.ETH
        );
        emit log_named_uint("base", price.base);
        emit log_named_uint("discount", price.discount);

        uint256 expectedBase = ((25_00_0000 * duration) / 365 days);
        uint256 expectedDiscount = (expectedBase * 5) / 100;
        emit log_named_uint("expectedBase", expectedBase);
        emit log_named_uint("expectedDiscount", expectedDiscount);
        vm.stopPrank();

    }
}
