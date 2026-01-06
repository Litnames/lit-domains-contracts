// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17 <0.9.0;

import {IPriceOracle} from "src/registrar/interfaces/IPriceOracle.sol";
import {IPyth} from "@pythnetwork/pyth-sdk-solidity/IPyth.sol";
import {PythStructs} from "@pythnetwork/pyth-sdk-solidity/PythStructs.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {StringUtils} from "src/utils/StringUtils.sol";
import {console} from "forge-std/console.sol";

contract PriceOracle is IPriceOracle, Ownable {
    using StringUtils for string;

    IPyth pyth;
    bytes32 EthUsdPythPriceFeedId;

    /// @notice The minimum price in wei. If conversion is less than this, revert. Editable by admin
    uint256 minPriceInWei;

    /// @notice Price per year for different name lengths (in USD with 6 decimals)
    uint256 public priceFor1Char = 420_00_0000; // 420$
    uint256 public priceFor2Char = 269_00_0000; // 269$
    uint256 public priceFor3Char = 169_00_0000; // 169$
    uint256 public priceFor4Char = 69_00_0000;  // 69$
    uint256 public priceFor5PlusChar = 25_00_0000; // 25$

    /// @notice Discount percentages based on duration
    uint256 public discount1Year = 0;   // 0%
    uint256 public discount2Years = 5;  // 5%
    uint256 public discount3Years = 15; // 15%
    uint256 public discount4Years = 30; // 30%
    uint256 public discount5PlusYears = 40; // 40%

    /// @notice Thrown when the price is too low.
    error PriceTooLow();

    /// @notice Thrown when the Pyth contract is invalid.
    error InvalidPyth();

    /// @notice Thrown when discount is invalid (> 100%).
    error InvalidDiscount();

    /// @notice Emitted when the minimum price in wei is set.
    event MinPriceInWeiSet(uint256 minPriceInWei_);

    /// @notice Emitted when the Pyth price feed id is set.
    event EthUsdPythPriceFeedIdSet(bytes32 EthUsdPythPriceFeedId_);

    /// @notice Emitted when the Pyth contract is set.
    event PythSet(address pyth_);

    /// @notice Emitted when prices are updated.
    event PricesUpdated(uint256 char1, uint256 char2, uint256 char3, uint256 char4, uint256 char5Plus);

    /// @notice Emitted when discounts are updated.
    event DiscountsUpdated(uint256 year1, uint256 year2, uint256 year3, uint256 year4, uint256 year5Plus);

    constructor(address pyth_, bytes32 EthUsdPythPriceFeedId_) Ownable(msg.sender) {
        if (pyth_ == address(0)) revert InvalidPyth();

        pyth = IPyth(pyth_);
        EthUsdPythPriceFeedId = EthUsdPythPriceFeedId_;
    }

    function setMinPriceInWei(uint256 minPriceInWei_) external onlyOwner {
        minPriceInWei = minPriceInWei_;
        emit MinPriceInWeiSet(minPriceInWei_);
    }

    function setEthUsdPythPriceFeedId(bytes32 EthUsdPythPriceFeedId_) external onlyOwner {
        EthUsdPythPriceFeedId = EthUsdPythPriceFeedId_;
        emit EthUsdPythPriceFeedIdSet(EthUsdPythPriceFeedId_);
    }

    function setPyth(address pyth_) external onlyOwner {
        pyth = IPyth(pyth_);
        emit PythSet(pyth_);
    }

    /// @notice Set prices for different name lengths
    /// @param char1 Price for 1 character names
    /// @param char2 Price for 2 character names
    /// @param char3 Price for 3 character names
    /// @param char4 Price for 4 character names
    /// @param char5Plus Price for 5+ character names
    function setPrices(
        uint256 char1,
        uint256 char2,
        uint256 char3,
        uint256 char4,
        uint256 char5Plus
    ) external onlyOwner {
        priceFor1Char = char1;
        priceFor2Char = char2;
        priceFor3Char = char3;
        priceFor4Char = char4;
        priceFor5PlusChar = char5Plus;
        emit PricesUpdated(char1, char2, char3, char4, char5Plus);
    }

    /// @notice Set discount percentages for different durations
    /// @param year1 Discount for 1 year (0-100)
    /// @param year2 Discount for 2 years (0-100)
    /// @param year3 Discount for 3 years (0-100)
    /// @param year4 Discount for 4 years (0-100)
    /// @param year5Plus Discount for 5+ years (0-100)
    function setDiscounts(
        uint256 year1,
        uint256 year2,
        uint256 year3,
        uint256 year4,
        uint256 year5Plus
    ) external onlyOwner {
        if (year1 > 100 || year2 > 100 || year3 > 100 || year4 > 100 || year5Plus > 100) {
            revert InvalidDiscount();
        }
        discount1Year = year1;
        discount2Years = year2;
        discount3Years = year3;
        discount4Years = year4;
        discount5PlusYears = year5Plus;
        emit DiscountsUpdated(year1, year2, year3, year4, year5Plus);
    }

    /// @notice Get all price configurations
    /// @return char1 char2 char3 char4 char5Plus The prices for different name lengths
    function getPrices() external view returns (uint256 char1, uint256 char2, uint256 char3, uint256 char4, uint256 char5Plus) {
        return (priceFor1Char, priceFor2Char, priceFor3Char, priceFor4Char, priceFor5PlusChar);
    }

    /// @notice Get all discount configurations
    /// @return year1 year2 year3 year4 year5Plus The discounts for different durations
    function getDiscounts() external view returns (uint256 year1, uint256 year2, uint256 year3, uint256 year4, uint256 year5Plus) {
        return (discount1Year, discount2Years, discount3Years, discount4Years, discount5PlusYears);
    }

    /// @notice Calculates the price for a given label with a default payment method of ETH.
    /// @param label The label to query.
    /// @param expires The expiry of the label.
    /// @param duration The duration of the registration in seconds.
    /// @return The price of the label.
    function price(string calldata label, uint256 expires, uint256 duration) external view returns (Price memory) {
        return price(label, expires, duration, Payment.ETH);
    }

    /// @notice Calculates the price for a given label with a specified payment method.
    /// @param label The label to query.
    /// param expiry The expiry of the label. Not used atm
    /// @param duration The duration of the registration in seconds.
    /// @param payment The payment method.
    /// @return The price of the label.
    function price(string calldata label, uint256, uint256 duration, Payment payment)
        public
        view
        returns (Price memory)
    {
        // Implement your logic to calculate the base and premium price
        (uint256 basePrice, uint256 discount) = calculateBasePrice(label, duration);

        // Adjust the price based on the payment method if necessary
        if (payment == Payment.ETH) {
            basePrice = convertToToken(basePrice);
            discount = convertToToken(discount);
        }

        return Price(basePrice, discount);
    }

    /// @notice Calculates the base price for a given label and duration.
    /// @param label The label to query.
    /// @param duration The duration of the registration.
    /// @return base The base price before discount.
    /// @return discount The discount.
    function calculateBasePrice(string calldata label, uint256 duration)
        internal
        view
        returns (uint256 base, uint256 discount)
    {
        uint256 nameLength = label.strlen();

        uint256 pricePerYear;
        if (nameLength == 1) {
            pricePerYear = priceFor1Char;
        } else if (nameLength == 2) {
            pricePerYear = priceFor2Char;
        } else if (nameLength == 3) {
            pricePerYear = priceFor3Char;
        } else if (nameLength == 4) {
            pricePerYear = priceFor4Char;
        } else {
            pricePerYear = priceFor5PlusChar;
        }

        uint256 discount_;
        if (duration <= 365 days) {
            discount_ = discount1Year;
        } else if (duration <= 2 * 365 days) {
            discount_ = discount2Years;
        } else if (duration <= 3 * 365 days) {
            discount_ = discount3Years;
        } else if (duration <= 4 * 365 days) {
            discount_ = discount4Years;
        } else {
            discount_ = discount5PlusYears;
        }

        uint256 totalPrice = (pricePerYear * duration) / 365 days;
        uint256 discountAmount = (totalPrice * discount_) / 100;
        return (totalPrice, discountAmount);
    }

    /// @notice Converts a price from a stablecoin equivalent to ETH.
    /// @dev This function can revert with StalePrice
    /// @param price_ The price in stablecoin.
    /// @return The price in ETH.
    function convertToToken(uint256 price_) internal view returns (uint256) {
        // Get ETH/USD price from Pyth
        PythStructs.Price memory conversionRate = pyth.getPriceNoOlderThan(EthUsdPythPriceFeedId, 1000000000);
        
        // Convert to 18 decimals
        uint256 EthPrice18Decimals = (uint256(uint64(conversionRate.price)) * (10 ** 18)) / (10 ** uint8(uint32(-1 * conversionRate.expo)));
        
        // Calculate how much wei equals $1
        uint256 oneDollarInWei = ((10 ** 12) * (10 ** 18)) / EthPrice18Decimals;
        
        // Convert USD price to wei
        return price_ * oneDollarInWei;
    }
}