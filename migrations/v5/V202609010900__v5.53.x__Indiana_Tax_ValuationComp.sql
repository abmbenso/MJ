/* ============================================================================
   Indiana Property Tax Expert — ValuationComp  (OPP-17 Stage 6)
   v5.53.x

   Per-subject sales-comparable selection + adjustment grid. v1 of the sales
   lane took a flat P25 of the property-type-group $/unit or $/SF x subject
   size -- no per-subject comparability adjustment, so large / Class-A assets
   were over-reduced. Stage 6 selects a real cluster from SaleTransaction and
   adjusts each comp to the subject on size / effective age / grade / time,
   AoRE-style, with caps (net +/-25%, gross 50% -> comp dropped).

   One row per comp considered for a ValuationAnalysis subject. The adjusted
   cluster produces the subject's market-value (sales) indication; where < 3
   usable comps exist the P25-group value is kept as a fallback.

   Built by scripts/build-valuation-comps.js (an UPDATE pass over the existing
   ValuationAnalysis rows -- same pattern as the income / cost loaders).
   ============================================================================ */

CREATE TABLE indiana_tax.ValuationComp (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    ValuationAnalysisID UNIQUEIDENTIFIER NOT NULL,
    SaleTransactionID UNIQUEIDENTIFIER NULL,
    SourceDocumentID UNIQUEIDENTIFIER NULL,

    UnitOfComparison NVARCHAR(10) NOT NULL,      -- '$/SF' | '$/unit'
    CompAddress NVARCHAR(300) NULL,
    CompSubmarket NVARCHAR(80) NULL,
    SaleDate DATE NULL,
    SalePrice DECIMAL(14, 2) NULL,
    CompDenominator DECIMAL(14, 2) NULL,         -- comp SF or units used for $/unit
    CompYearBuilt SMALLINT NULL,
    CompGradeOrdinal DECIMAL(4, 2) NULL,         -- A=6 .. F=1 (approx for CoStar class)
    RawPerUnit DECIMAL(14, 2) NULL,              -- unadjusted sale $/unit or $/SF

    SizeAdjPct DECIMAL(6, 4) NULL,               -- signed, e.g. 0.0690
    AgeAdjPct DECIMAL(6, 4) NULL,
    GradeAdjPct DECIMAL(6, 4) NULL,
    TimeAdjPct DECIMAL(6, 4) NULL,
    NetAdjPct DECIMAL(6, 4) NULL,
    GrossAdjPct DECIMAL(6, 4) NULL,
    AdjustedPerUnit DECIMAL(14, 2) NULL,
    SubjectIndicatedValue DECIMAL(14, 2) NULL,   -- AdjustedPerUnit x subject denominator

    SimilarityRank INT NULL,                     -- 1 = least-adjusted / most comparable
    IsSelected BIT NOT NULL CONSTRAINT DF_ValuationComp_Sel DEFAULT (0),
    DropReason NVARCHAR(40) NULL,                -- NULL = kept; else 'gross-adj>50%' / 'net-adj>25%' / 'implausible-$/unit'

    __mj_CreatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_ValuationComp_C DEFAULT (SYSDATETIMEOFFSET()),
    __mj_UpdatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_ValuationComp_U DEFAULT (SYSDATETIMEOFFSET()),

    CONSTRAINT PK_ValuationComp PRIMARY KEY (ID),
    CONSTRAINT FK_ValuationComp_ValuationAnalysis FOREIGN KEY (ValuationAnalysisID)
        REFERENCES indiana_tax.ValuationAnalysis (ID),
    CONSTRAINT FK_ValuationComp_SaleTransaction FOREIGN KEY (SaleTransactionID)
        REFERENCES indiana_tax.SaleTransaction (ID),
    CONSTRAINT FK_ValuationComp_SourceDocument FOREIGN KEY (SourceDocumentID)
        REFERENCES indiana_tax.SourceDocument (ID),
    CONSTRAINT CK_ValuationComp_UoC CHECK (UnitOfComparison IN ('$/SF', '$/unit'))
);
GO
CREATE INDEX IX_ValuationComp_VA ON indiana_tax.ValuationComp (ValuationAnalysisID);
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'One row per sales comparable considered for a ValuationAnalysis subject (OPP-17 Stage 6). Each comp is adjusted to the subject on size (economies of scale), effective age, grade, and time-to-lien-date; caps net +/-25% / gross 50% (beyond -> DropReason). The median SubjectIndicatedValue over the selected cluster is the subject market-value (sales) indication; a P25-group fallback is used where < 3 comps survive. Built by scripts/build-valuation-comps.js.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ValuationComp';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Signed size adjustment (economies of scale): +0.10 x ln(compDenominator / subjectDenominator), clamped +/-15%. Positive raises the comp $/unit toward a smaller subject.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ValuationComp', @level2type = N'COLUMN', @level2name = N'SizeAdjPct';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Signed time adjustment: annual CRE appreciation (3%) x years from sale date to the 1/1/2026 lien date, clamped [-5%, +30%].',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ValuationComp', @level2type = N'COLUMN', @level2name = N'TimeAdjPct';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'AdjustedPerUnit x the subject''s denominator (SF or units) -- this comp''s indication of the subject''s total value.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'ValuationComp', @level2type = N'COLUMN', @level2name = N'SubjectIndicatedValue';
GO
