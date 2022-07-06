// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import { IPool } from "../../base/interfaces/IPool.sol";


import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/**
 * @title Ajna ERC721 Pool
 */
interface IERC721Pool is IPool {

    /**************/
    /*** Events ***/
    /**************/

    /**
     *  @notice Emitted when borrower locks collateral in the pool.
     *  @param  borrower_ `msg.sender`.
     *  @param  tokenIds_ Array of tokenIds to be added to the pool.
     */
    event AddNFTCollateral(address indexed borrower_, uint256[] tokenIds_);

    /**
     *  @notice Emitted when lender claims multiple unencumbered NFT collateral.
     *  @param  claimer_  Recipient that claimed collateral.
     *  @param  price_    Price at which unencumbered collateral was claimed.
     *  @param  tokenIds_ Array of unencumbered tokenIds claimed as collateral.
     *  @param  lps_      The amount of LP tokens burned in the claim.
     */
    event ClaimNFTCollateral(address indexed claimer_, uint256 indexed price_, uint256[] tokenIds_, uint256 lps_);

    /**
     *  @notice Emitted when NFT collateral is exchanged for quote tokens.
     *  @param  bidder_     `msg.sender`.
     *  @param  price_      Price at which collateral was exchanged for quote tokens.
     *  @param  amount_     Amount of quote tokens purchased.
     *  @param  tokenIds_   Array of tokenIds used as collateral for the exchange.
     */
    event PurchaseWithNFTs(address indexed bidder_, uint256 indexed price_, uint256 amount_, uint256[] tokenIds_);

    /**
     *  @notice Emitted when borrower removes multiple collateral from the pool.
     *  @param  borrower_ `msg.sender`.
     *  @param  tokenIds_ Array of tokenIds removed from the pool.
     */
    event RemoveNFTCollateral(address indexed borrower_, uint256[] tokenIds_);

    /***************/
    /*** Structs ***/
    /***************/

     /**
     *  @notice Struct holding borrower related info per price bucket, for borrowers using NFTs as collateral.
     *  @param  debt                Borrower debt, WAD units.
     *  @param  collateralDeposited OZ Enumberable Set tracking the tokenIds of collateral that have been deposited
     *  @param  inflatorSnapshot    Current borrower inflator snapshot, RAY units.
     */
    struct NFTBorrowerInfo {
        uint256   debt;
        EnumerableSet.UintSet collateralDeposited;
        uint256   inflatorSnapshot;
    }

    /*****************************/
    /*** Inititalize Functions ***/
    /*****************************/

    /**
     *  @notice Called by deployNFTSubsetPool()
     *  @dev Used to initialize pools that only support a subset of tokenIds
     */
    function initializeSubset(uint256[] memory tokenIds_, uint256 interestRate_) external;

    /***********************************/
    /*** Borrower External Functions ***/
    /***********************************/

    /**
     *  @notice Called by borrowers to add multiple NFTs to the pool.
     *  @param  tokenIds_ NFT token ids to be deposited as collateral in the pool.
     */
    function addCollateral(uint256[] calldata tokenIds_) external;

    /**
     *  @notice Called by borrowers to remove multiple NFTs from the pool.
     *  @param  tokenIds_ NFT token ids to be removed as collateral from the pool.
     */
    function removeCollateral(uint256[] calldata tokenIds_) external;

    /***********************************/
    /*** Borrower View Functions ***/
    /***********************************/

    /**
     *  @notice Returns a tuple of information about a given NFT borrower.
     *  @param  borrower_                 Address of the borrower.
     *  @return debt_                     Amount of debt that the borrower has, in quote token.
     *  @return pendingDebt_              Amount of unaccrued debt that the borrower has, in quote token.
     *  @return collateralDeposited_      Amount of collateral that tne borrower has deposited, in NFT tokens.
     *  @return collateralEncumbered_     Amount of collateral that the borrower has encumbered, in NFT token.
     *  @return collateralization_        Collateral ratio of the borrower's pool position.
     *  @return borrowerInflatorSnapshot_ Snapshot of the borrower's inflator value.
     *  @return inflatorSnapshot_         Snapshot of the pool's inflator value.
     */
    function getBorrowerInfo(address borrower_) external view returns (
        uint256 debt_,
        uint256 pendingDebt_,
        uint256[] memory collateralDeposited_,
        uint256 collateralEncumbered_,
        uint256 collateralization_,
        uint256 borrowerInflatorSnapshot_,
        uint256 inflatorSnapshot_
    );

    /*********************************/
    /*** Lender External Functions ***/
    /*********************************/

    /**
     *  @notice Called by lenders to claim multiple unencumbered collateral from a price bucket.
     *  @param  recipient_ The recipient claiming collateral.
     *  @param  tokenIds_  NFT token ids to be claimed from the pool.
     *  @param  price_     The bucket from which unencumbered collateral will be claimed.
     */
    function claimCollateral(address recipient_, uint256[] calldata tokenIds_, uint256 price_) external;

    /*******************************/
    /*** Pool External Functions ***/
    /*******************************/

    /**
     *  @notice Exchanges NFT collateral for quote token.
     *  @dev Can be called for multiple units of collateral at a time.
     *  @dev Tokens will be used for purchase based upon their order in the array, FIFO.
     *  @param  amount_   WAD The amount of quote token to purchase.
     *  @param  price_    The purchasing price of quote token.
     *  @param  tokenIds_ NFT token ids to be purchased from the pool.
     */
    function purchaseBid(uint256 amount_, uint256 price_, uint256[] calldata tokenIds_) external;
}
