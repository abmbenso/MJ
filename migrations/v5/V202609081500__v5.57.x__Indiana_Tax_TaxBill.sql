/* ============================================================================
   Indiana Property Tax Expert — DLGF Gateway tax bill + adjustment data
   v5.57.x

   Every existing source in this schema stops at ASSESSED VALUE. Assessment,
   CountyAssessorRecord, TaxHistoryYear -- all describe the numerator of an
   appeal. None describe what the taxpayer actually PAYS.

   That gap had a concrete consequence: the Tax Budget Projection engine
   computed tax as GrossAssessedValue x TaxRate, which is wrong twice over.
   The bill is computed on NET assessed value, and roughly half of Marion
   parcels then have the result reduced by the circuit-breaker cap. Measured
   on parcel 9003241, six consecutive years billed at ~61% of AV x rate --
   the projection overstated its taxes by ~64%.

   These tables close it, sourced from the DLGF Gateway 50 IAC 26 (PTMS)
   bulk exports in ~/Projects/Indiana_Tax_Bill_Data/. Marion County only for
   now; the loader's county filter is a parameter, not an assumption.

   Design: docs/proposals/tax-bill-projection-design.md
   Schema origin: docs/proposals/gateway-tax-and-adjustment-entities.md

   TWO ARITHMETIC IDENTITIES govern this data and are enforced as integrity
   checks (scripts/integrity/):
     1. NetAssessedValue x LocalTaxRate / 100 = GrossTaxDue
        (exact on 172,720/172,720 records)
     2. GrossTaxDue - SUM(TaxAdjustment where AdjustmentType='C')
          = TotalPropertyTaxDue
        (exact on 740,000 records across Marion, Lake and Allen)

   Identity 2 is THE bridge. Do NOT compute the total as
   GrossTax - LocalTaxRelief - PropertyTaxCapSavings: those two are TS-1
   *reporting* fields, not independently subtractable terms. That subtraction
   holds on only 57.8% of records and goes negative on real ones.
   ============================================================================ */

CREATE TABLE indiana_tax.AdjustmentCode (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),

    Code NVARCHAR(2) NOT NULL,
    AdjustmentType NVARCHAR(1) NOT NULL
        CONSTRAINT CK_AdjustmentCode_AdjustmentType CHECK (AdjustmentType IN ('C', 'D', 'E')),
    Name NVARCHAR(200) NOT NULL,
    StatuteCite NVARCHAR(100) NULL,
    SunsetPayYear INT NULL,
    IsCircuitBreaker BIT NOT NULL
        CONSTRAINT DF_AdjustmentCode_IsCircuitBreaker DEFAULT (0),

    CONSTRAINT PK_AdjustmentCode PRIMARY KEY (ID),
    CONSTRAINT UQ_AdjustmentCode UNIQUE (Code, AdjustmentType)
);
GO

CREATE TABLE indiana_tax.TaxBill (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),

    ParcelID UNIQUEIDENTIFIER NULL,
    SourceDocumentID UNIQUEIDENTIFIER NOT NULL,

    StateParcelNumber NVARCHAR(25) NOT NULL,
    AuditorTaxID NVARCHAR(25) NULL,
    PropertyTypeCode NVARCHAR(1) NULL,
    CountyNumber INT NOT NULL,
    PayYear INT NOT NULL,

    TaxpayerName NVARCHAR(80) NULL,
    LocalTaxDistrictNumber NVARCHAR(3) NULL,

    GrossAssessedValue DECIMAL(14, 2) NULL,
    NetAssessedValue DECIMAL(14, 2) NULL,
    LocalTaxRate DECIMAL(9, 6) NULL,
    GrossTaxDue DECIMAL(14, 2) NULL,
    LocalTaxRelief DECIMAL(14, 2) NULL,
    PropertyTaxCapSavings DECIMAL(14, 2) NULL,
    TotalPropertyTaxDue DECIMAL(14, 2) NULL,
    TotalOtherCharges DECIMAL(14, 2) NULL,

    AVSubjectTo1Pct DECIMAL(14, 2) NULL,
    AVSubjectTo2Pct DECIMAL(14, 2) NULL,
    AVSubjectTo3Pct DECIMAL(14, 2) NULL,
    AVTIF DECIMAL(14, 2) NULL,

    CONSTRAINT PK_TaxBill PRIMARY KEY (ID),
    CONSTRAINT FK_TaxBill_Parcel FOREIGN KEY (ParcelID) REFERENCES indiana_tax.Parcel (ID),
    CONSTRAINT FK_TaxBill_SourceDocument FOREIGN KEY (SourceDocumentID) REFERENCES indiana_tax.SourceDocument (ID),
    CONSTRAINT UQ_TaxBill UNIQUE (StateParcelNumber, PayYear, PropertyTypeCode)
);
GO

CREATE TABLE indiana_tax.TaxAdjustment (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),

    TaxBillID UNIQUEIDENTIFIER NOT NULL,
    SourceDocumentID UNIQUEIDENTIFIER NOT NULL,

    AdjustmentInstanceNumber INT NOT NULL,
    AdjustmentType NVARCHAR(1) NOT NULL
        CONSTRAINT CK_TaxAdjustment_AdjustmentType CHECK (AdjustmentType IN ('C', 'D', 'E')),
    AdjustmentCode NVARCHAR(2) NOT NULL,

    TotalAdjustmentAmount DECIMAL(14, 2) NULL,
    AmountSubjectTo1Pct DECIMAL(14, 2) NULL,
    AmountSubjectTo2Pct DECIMAL(14, 2) NULL,
    AmountSubjectTo3Pct DECIMAL(14, 2) NULL,
    StartingYear INT NULL,
    NumberOfYears INT NULL,

    CONSTRAINT PK_TaxAdjustment PRIMARY KEY (ID),
    CONSTRAINT FK_TaxAdjustment_TaxBill FOREIGN KEY (TaxBillID) REFERENCES indiana_tax.TaxBill (ID),
    CONSTRAINT FK_TaxAdjustment_SourceDocument FOREIGN KEY (SourceDocumentID) REFERENCES indiana_tax.SourceDocument (ID),
    CONSTRAINT UQ_TaxAdjustment UNIQUE (TaxBillID, AdjustmentInstanceNumber)
);
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'What a taxpayer was actually BILLED for a pay year, from the DLGF Gateway TAXDATA/TAXBILL export (50 IAC 26). Distinct from TaxHistoryYear, which is PRC-sourced assessment detail: this table is the billing authority. Marion County only at present. One row per parcel per pay year per property type (a taxpayer may have both a real-property and a personal-property bill).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'TaxBill';
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nullable by design. A TAXDATA row may describe PERSONAL property, which has no row in Parcel. The loader records the unmatched count rather than failing -- an unmatched bill is expected, not an error.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'TaxBill', @level2type = N'COLUMN', @level2name = N'ParcelID';
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Net assessed value AFTER deductions and exemptions. GrossTaxDue is computed on THIS, not on GrossAssessedValue -- NetAssessedValue x LocalTaxRate / 100 = GrossTaxDue, exact on 172,720/172,720 records. Using gross here is one of the two ways the pre-2026-09 projection engine overstated tax.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'TaxBill', @level2type = N'COLUMN', @level2name = N'NetAssessedValue';
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'The circuit-breaker cap SAVINGS reported on TS-1 line 4b -- NOT the cap ceiling, and NOT an independently subtractable term. Do NOT compute TotalPropertyTaxDue as GrossTaxDue - LocalTaxRelief - PropertyTaxCapSavings: that holds on only 57.8% of records and goes negative on real ones. The bridge is GrossTaxDue - SUM(TaxAdjustment where AdjustmentType = ''C''). The cap CEILING is derived from AVSubjectTo1Pct/2Pct/3Pct at the statutory 1/2/3 percent.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'TaxBill', @level2type = N'COLUMN', @level2name = N'PropertyTaxCapSavings';
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Gross AV rolled into the three statutory circuit-breaker classes, summed from the eleven cap-bucket fields at positions 485-652 (TS-1 lines 1a / 1b / 1c). These are what the cap CEILING is computed from. NULL, never 0, when every contributing source field is blank.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'TaxBill', @level2type = N'COLUMN', @level2name = N'AVSubjectTo1Pct';
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Total of the bill''s Table 4 (Other Charges/Adjustments -- storm water, special assessments). DLGF carries the TOTAL only; the itemisation is not in the export and requires the county bill.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'TaxBill', @level2type = N'COLUMN', @level2name = N'TotalOtherCharges';
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'One row per adjustment per tax bill, from the DLGF ADJMENTS export. Type ''D''/''E'' (deductions/exemptions) reduce ASSESSED VALUE and are already reflected in TaxBill.NetAssessedValue. Type ''C'' (credits) reduce TAX and are what bridges GrossTaxDue to TotalPropertyTaxDue. Linked to the tax bill, not directly to the parcel -- DLGF''s own wording is "by tax bill".',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'TaxAdjustment';
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Starting pay year of the adjustment. Load-bearing with NumberOfYears for abatements (code 16) and TIF (code 17): a known start and term is what makes burn-off PROJECTABLE rather than assumed permanent, which is the single highest-value behaviour the bill-shaped projection unlocks.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'TaxAdjustment', @level2type = N'COLUMN', @level2name = N'StartingYear';
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'DLGF Code List 37. Codes 61/62/63 are the circuit-breaker credits (homestead residential / non-homestead residential / other real and personal) and are how a CAPPED parcel is identified. A capped parcel still saves on an AV reduction -- referendum debt levies sit outside the cap (IC 6-1.1-20.6), so the cap is a rate MODIFIER, not a gate. SunsetPayYear matters: without it, year-over-year net-AV movement across vintages looks like assessment change when it is statutory change.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AdjustmentCode';
GO
