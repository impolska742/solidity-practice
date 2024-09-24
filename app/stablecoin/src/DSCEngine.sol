// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.22;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./DecentralizedStableCoin.sol";

/**
 * @title DSCEngine
 * @author Vaibhav Bhardwaj
 *
 * Pegged to 1$ i.e. 1 DSC = 1$.
 * - Exogenous Collateral: wETH & wBTC
 * - Dollar Pegged
 * - Algorithmic Stable
 *
 * Our DSC system should always be over-collateralized.
 * At no point should the value of the collateral be less than the value of the DSC.
 * I.e. the value of the collateral should always be greater than the value of the $ minted.
 *
 * This contract is meant to be the governance contract for the DSC.
 * This contract will be responsible for the minting and burning of the DSC.
 * The depositing and withdrawing of the token will also be determined by this contract.
 *
 * It is similar to DAI if DAI had no governance, no fees, and was only backed by wETH and wBTC.
 *
 * @notice This contract is VERY loosely based on the based on the MakerDAO DSS (DAI) system.
 */
contract DSCEngine is ReentrancyGuard {
    //////////////////
    // Errors       //
    //////////////////
    error DSCEngine__NeedsMoreThanZero();
    error DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength();
    error DSCEngine__TokenNotAllowed();
    error DSCEngine__TransferFailed();

    //////////////////////
    // State Variables  //
    //////////////////////
    DecentralizedStableCoin private immutable i_DSCToken;

    mapping(address token => address priceFeed) private s_priceFeeds; // tokenToPriceFeeds
    mapping(address user => mapping(address token => uint256 amount)) private s_collateralDeposited;

    //////////////////
    // Events       //
    //////////////////
    event CollateralDeposited(address indexed user, address indexed token, uint256 amount);


    ////////////////
    // Modifiers  //
    ////////////////
    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert DSCEngine__NeedsMoreThanZero();
        }
        _;
    }

    modifier isAllowedToken(address token) {
        if (s_priceFeeds[token] == address(0)) {
            revert DSCEngine__TokenNotAllowed();
        }
        _;
    }

    //////////////////
    // Functions    //
    //////////////////
    constructor(address[] memory tokenAddresses, address[] memory priceFeedAddresses, address dscAddress) {
        // USD Price Feeds
        if (tokenAddresses.length != priceFeedAddresses.length) {
            revert DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength();
        }

        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            s_priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
        }

        i_DSCToken = DecentralizedStableCoin(dscAddress);
    }

    /////////////////////////
    // External Functions  //
    /////////////////////////
    function depositCollateralAndMintDSC() external {}

    /**
     * @notice follows CEI (checks, effects, interactions) pattern
     * @param tokenCollateralAddress The address of the token to deposit as collateral
     * @param _collateralAmount The amount of collateral to deposit
     */
    function depositCollateral(address tokenCollateralAddress, uint256 _collateralAmount)
        external
        // Checks
        moreThanZero(_collateralAmount)
        isAllowedToken(tokenCollateralAddress)
        nonReentrant
    {
        // Effects
        s_collateralDeposited[msg.sender][tokenCollateralAddress] += _collateralAmount;
        emit CollateralDeposited(msg.sender, tokenCollateralAddress, _collateralAmount);

        // (External) Interactions
        bool success = IERC20(tokenCollateralAddress).transferFrom(msg.sender, address(this), _collateralAmount);

        if (!success) {
            revert DSCEngine__TransferFailed();
        }
    }

    function redeemCollateralForDSC() external {}

    function redeemCollateral() external {}

    function burnDSC() external {}

    // Check if the collateral value is > DSC amount
    // Price Feeds for value
    function mintDSC() external {

    }

    function liquidate() external {}

    function getHealthFactor() external view returns (uint256) {
        // Calculate the health factor
    }
}
