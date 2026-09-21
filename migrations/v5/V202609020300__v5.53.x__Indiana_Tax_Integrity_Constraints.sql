/* ============================================================================
   Indiana Property Tax Expert — integrity constraints  (OPP-35)
   v5.53.x

   Promotes the absolute invariants from the data-integrity check suite
   (docs/DATA_INTEGRITY.md) into the schema, so the database itself refuses a
   bad write instead of only detecting it after the fact.

   All constraints verified to have ZERO existing violations before this
   migration (2026-09-01), so every ALTER is WITH CHECK.

     - non-negativity on money / square-foot / count columns
     - Assessment land + improvement = total for the AUTHORITATIVE sources
       (MarionPRC / marion_foia_2026), +/- $1 rounding; the statewide
       dlgf_gdb_2025 slice is deliberately exempt (its own ~$100 rounding is a
       DLGF data-quality matter, covered by reconcile-dlgf-vs-prc.js)

   NOTE: making Assessment.SourceDocumentID NOT NULL is deferred to its own
   migration -- it requires dropping + recreating the FK and the MJ auto-index,
   plus a codegen pass to refresh AllowsNull metadata. The suite's
   `assessment-missing-source` ERROR check enforces mandatory provenance in the
   meantime.
   ============================================================================ */

/* -- CountyAssessorRecord: non-negative money / SF ------------------------- */
ALTER TABLE indiana_tax.CountyAssessorRecord WITH CHECK
  ADD CONSTRAINT CK_CountyAssessorRecord_NonNeg CHECK (
        ISNULL(AssessedTotalAV, 0)       >= 0
    AND ISNULL(AssessedLandAV, 0)        >= 0
    AND ISNULL(AssessedImprovementAV, 0) >= 0
    AND ISNULL(GrossAssessment, 0)       >= 0
    AND ISNULL(NetAssessment, 0)         >= 0
    AND ISNULL(EstimatedSqFt, 0)         >= 0
  );
GO

/* -- Assessment: non-negative + component sum (authoritative sources) ---- */
ALTER TABLE indiana_tax.Assessment WITH CHECK
  ADD CONSTRAINT CK_Assessment_NonNeg CHECK (
        ISNULL(OriginalTotalAV, 0)       >= 0
    AND ISNULL(OriginalLandAV, 0)        >= 0
    AND ISNULL(OriginalImprovementAV, 0) >= 0
  );
GO

ALTER TABLE indiana_tax.Assessment WITH CHECK
  ADD CONSTRAINT CK_Assessment_ComponentSum CHECK (
        Source NOT IN ('MarionPRC', 'marion_foia_2026')
     OR OriginalLandAV IS NULL OR OriginalImprovementAV IS NULL OR OriginalTotalAV IS NULL
     OR ABS(OriginalLandAV + OriginalImprovementAV - OriginalTotalAV) <= 1
  );
GO

/* -- SaleTransaction: non-negative -------------------------------------- */
ALTER TABLE indiana_tax.SaleTransaction WITH CHECK
  ADD CONSTRAINT CK_SaleTransaction_NonNeg CHECK (
        ISNULL(SalePrice, 0)    >= 0
    AND ISNULL(BuildingSqFt, 0) >= 0
    AND ISNULL(UnitCount, 0)    >= 0
    AND ISNULL(Acres, 0)        >= 0
  );
GO

/* -- ValuationAnalysis: non-negative ---------------------------------- */
ALTER TABLE indiana_tax.ValuationAnalysis WITH CHECK
  ADD CONSTRAINT CK_ValuationAnalysis_NonNeg CHECK (
        ISNULL(CurrentTotalAV, 0)        >= 0
    AND ISNULL(ReconciledTargetValue, 0) >= 0
    AND ISNULL(EstimatedTaxSavings, 0)   >= 0
    AND ISNULL(LowestSupportedValue, 0)  >= 0
  );
GO

/* -- Prospect CRM snapshots / parcels: non-negative ------------------ */
ALTER TABLE indiana_tax.ProspectSnapshot WITH CHECK
  ADD CONSTRAINT CK_ProspectSnapshot_NonNeg CHECK (
        ISNULL(TotalAV, 0)          >= 0
    AND ISNULL(OpportunityAtAsk, 0) >= 0
    AND ISNULL(ParcelCount, 0)      >= 0
  );
GO

ALTER TABLE indiana_tax.ProspectParcel WITH CHECK
  ADD CONSTRAINT CK_ProspectParcel_NonNeg CHECK (
        ISNULL(SnapshotAV, 0)                 >= 0
    AND ISNULL(SnapshotOpportunityAtAsk, 0)   >= 0
    AND ISNULL(SnapshotOpportunityAtFloor, 0) >= 0
  );
GO
