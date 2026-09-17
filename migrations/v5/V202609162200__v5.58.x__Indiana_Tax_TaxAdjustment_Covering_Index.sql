-- Performance-only migration: no schema or data change.
--
-- The taxbill-bridge integrity check (indiana_tax.TaxBill OUTER APPLY-ing a per-bill SUM over
-- indiana_tax.TaxAdjustment, filtered to AdjustmentType='C') began timing out (>120s) once the
-- statewide TaxBill/TaxAdjustment build-out landed 2026-09-16 (~20M TaxBill rows, ~34M
-- TaxAdjustment rows across pay 2022-2025 -- previously Marion-only, ~1.4M/1.4M). The existing
-- FK index on TaxAdjustment(TaxBillID) lets SQL Server seek to the right bill, but still needs a
-- key lookup per matching row to read AdjustmentType and TotalAdjustmentAmount; at this volume
-- that lookup cost, multiplied across ~14M outer TaxBill rows, is what pushed the query over the
-- timeout. A covering index (TaxBillID, AdjustmentType) INCLUDE (TotalAdjustmentAmount) lets the
-- whole correlated subquery resolve from the index alone.
CREATE INDEX IX_TaxAdjustment_TaxBillID_AdjustmentType_Covering
    ON indiana_tax.TaxAdjustment (TaxBillID, AdjustmentType)
    INCLUDE (TotalAdjustmentAmount);
GO
