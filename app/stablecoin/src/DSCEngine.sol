// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.22;

/**
 * @title DSCEngine
 * @author Vaibhav Bhardwaj
 * 
 * Pegged to 1$. 1 DSC = 1$.
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
contract DSCEngine {
    // Threshold for liquidation = 150%
    // 100$ ETH -> 75$ ETH 
    // 50$ DSC

    // If the value of the collateral drops below 150% of the value of the DSC, the DSC can be liquidated.
    // If someone pays the liquidator fee, they can liquidate the DSC and get the collateral.
    
    function depositCollateralAndMintDSC() external {
    }

    function depositCollateral() external {
    }

    function redeemCollateralForDSC() external {
    }

    function redeemCollateral() external {
    }

    function burnDSC() external {
    }

    function mintDSC() external {
    }

    function liquidate() external {
    }
    
    function getHealthFactor() external view returns (uint256) {
        // Calculate the health factor
    }
}