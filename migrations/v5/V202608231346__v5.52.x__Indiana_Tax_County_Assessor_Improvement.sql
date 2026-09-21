/* ============================================================================
   Indiana Property Tax Expert — Marion County Property Record Card (PRC)
   ingestion: improvement/floor-segment detail, PRC document-type support,
   and a SourceDocument link on CountyAssessorRecord.
   v5.52.x

   Adds structured storage for two tables carried on the PRC PDF that nothing
   in this schema captures yet:
     - CountyAssessorImprovement: one row per structure line from the card's
       "Summary of Improvements" table (Building / Paving / Skyway / etc.).
     - CountyAssessorImprovementSegment: one row per floor/use-segment column
       from the card's dense per-floor pricing table (e.g. "Gen Office",
       21,263 sqft/floor x 10 floors). TotalSqFt is a computed column
       (SqFtPerFloor * FloorCount) so it can never drift from its own inputs --
       this is the exact multiplication that was missed earlier and produced a
       3x-undercounted building total for a real parcel (8050459).

   Also:
     - Adds 'PropertyRecordCard' to SourceDocument.DocumentType so the PDF
       itself can be persisted through the existing SourceDocument paper-trail
       pattern (ContentHash dedup, RawFilePath, RetrievedAt, DocumentDate).
     - Adds CountyAssessorRecord.SourceDocumentID linking a parcel's row back
       to the SourceDocument row for its most recently fetched PRC PDF.
   ============================================================================ */

ALTER TABLE indiana_tax.SourceDocument DROP CONSTRAINT CK_SourceDocument_DocumentType;
GO

ALTER TABLE indiana_tax.SourceDocument ADD CONSTRAINT CK_SourceDocument_DocumentType CHECK (DocumentType IN (
    N'BoardDecision', N'Statute', N'Form', N'ReferenceText', N'PTABOAAgenda', N'Memo', N'Regulation', N'PropertyRecordCard', N'Other'));
GO

EXEC sp_updateextendedproperty
    @name = N'MS_Description',
    @value = N'What kind of document this is: BoardDecision (an IBTR ruling PDF), Statute (an Indiana Code article), Form (a DLGF form such as Form 130), ReferenceText (an appraisal/USPAP reference book or the DLGF Assessment Manual), PTABOAAgenda (a county appeals-board meeting agenda), Memo (a DLGF guidance memo), Regulation (an administrative rule, e.g. 50 IAC), PropertyRecordCard (a county assessor Property Record Card PDF, e.g. Marion County''s maps.indy.gov report), or Other.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'SourceDocument',
    @level2type = N'COLUMN', @level2name = N'DocumentType';
GO

ALTER TABLE indiana_tax.CountyAssessorRecord
ADD SourceDocumentID UNIQUEIDENTIFIER NULL
    CONSTRAINT FK_CountyAssessorRecord_SourceDocument FOREIGN KEY REFERENCES indiana_tax.SourceDocument(ID);
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The SourceDocument row for this parcel''s most recently fetched Property Record Card PDF. NULL until a PRC has been fetched for this parcel. Distinct from ReportRetrievedAt (a plain timestamp on this row) -- this links to the actual persisted PDF, its content hash, and its ExtractedText.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorRecord',
    @level2type = N'COLUMN', @level2name = N'SourceDocumentID';
GO

-- ============================================================================
-- CountyAssessorImprovement — structure-level rows from "Summary of Improvements"
-- ============================================================================

CREATE TABLE indiana_tax.CountyAssessorImprovement (
    ID                       UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    CountyAssessorRecordID   UNIQUEIDENTIFIER NOT NULL,
    CardNumber               NVARCHAR(10)     NULL,
    [Use]                    NVARCHAR(50)     NULL,
    Grade                    NVARCHAR(10)     NULL,
    YearConstructed          SMALLINT         NULL,
    EffectiveYear            SMALLINT         NULL,
    Condition                NVARCHAR(10)     NULL,
    SizeOrArea               DECIMAL(14,2)    NULL,
    ReproductionCost         DECIMAL(14,2)    NULL,
    DepreciationObsolescence DECIMAL(14,2)    NULL,
    RemainderValue           DECIMAL(14,2)    NULL,
    PctComplete              DECIMAL(5,2)     NULL,
    TrendFactor              DECIMAL(9,4)     NULL,
    TrueTaxValue             DECIMAL(14,2)    NULL,
    CONSTRAINT PK_CountyAssessorImprovement PRIMARY KEY (ID),
    CONSTRAINT FK_CountyAssessorImprovement_CountyAssessorRecord FOREIGN KEY (CountyAssessorRecordID) REFERENCES indiana_tax.CountyAssessorRecord(ID)
);
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'One row per structure line from a Property Record Card''s "Summary of Improvements" table (e.g. Building, Paving-Asph, Skyway enclosed). A parcel with multiple structures/cards has multiple rows. The Building row''s SizeOrArea is the reliable, already-unit-multiplied total building square footage -- use it as a cross-check against the sum of this parcel''s CountyAssessorImprovementSegment rows.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorImprovement';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The parcel record this improvement belongs to.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorImprovement',
    @level2type = N'COLUMN', @level2name = N'CountyAssessorRecordID';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The card page this row was reported on (e.g. "1", "1A"). A parcel can have multiple cards for complex properties.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorImprovement',
    @level2type = N'COLUMN', @level2name = N'CardNumber';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The structure type, e.g. "Building", "Paving -Asph", "Skyway enclosed walkway".',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorImprovement',
    @level2type = N'COLUMN', @level2name = N'Use';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Construction grade rating (e.g. "C", "B+").',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorImprovement',
    @level2type = N'COLUMN', @level2name = N'Grade';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The year this structure was originally constructed, per the card.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorImprovement',
    @level2type = N'COLUMN', @level2name = N'YearConstructed';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The effective year used for depreciation purposes (can differ from YearConstructed after a renovation).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorImprovement',
    @level2type = N'COLUMN', @level2name = N'EffectiveYear';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Condition rating letter (e.g. "A").',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorImprovement',
    @level2type = N'COLUMN', @level2name = N'Condition';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The "Size or Area" figure on this structure''s summary row. For the Building row, this is the true total building square footage (already accounts for multi-floor segments) -- more reliable than CountyAssessorRecord.EstimatedSqFt sourced any other way.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorImprovement',
    @level2type = N'COLUMN', @level2name = N'SizeOrArea';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The assessor''s estimated replacement cost for this structure, per the card''s cost-model computation.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorImprovement',
    @level2type = N'COLUMN', @level2name = N'ReproductionCost';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The "Dep/Obs" figure on the summary row -- combined physical depreciation and obsolescence deduction from reproduction cost. See CountyAssessorImprovementSegment for the per-floor breakdown of physical depreciation and obsolescence separately.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorImprovement',
    @level2type = N'COLUMN', @level2name = N'DepreciationObsolescence';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The "REM Val" (remainder value) figure -- reproduction cost less depreciation/obsolescence, before the trend factor is applied.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorImprovement',
    @level2type = N'COLUMN', @level2name = N'RemainderValue';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The "% Cmp" (percent complete) figure, for structures under construction. 100 for a finished structure.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorImprovement',
    @level2type = N'COLUMN', @level2name = N'PctComplete';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The trend factor applied to remainder value to reach true tax value.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorImprovement',
    @level2type = N'COLUMN', @level2name = N'TrendFactor';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The "True Tax Value" figure -- this structure''s contribution to the parcel''s assessed improvement value.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorImprovement',
    @level2type = N'COLUMN', @level2name = N'TrueTaxValue';
GO

-- ============================================================================
-- CountyAssessorImprovementSegment — floor/use-segment level detail from the
-- dense per-card pricing table.
-- ============================================================================

CREATE TABLE indiana_tax.CountyAssessorImprovementSegment (
    ID                       UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    CountyAssessorRecordID   UNIQUEIDENTIFIER NOT NULL,
    CardNumber               NVARCHAR(10)     NULL,
    SegmentIndex             INT              NULL,
    [Use]                    NVARCHAR(50)     NULL,
    SqFtPerFloor             DECIMAL(12,2)    NULL,
    FloorCount               INT              NULL,
    TotalSqFt                AS (SqFtPerFloor * FloorCount) PERSISTED,
    ReproductionCost         DECIMAL(14,2)    NULL,
    PhysicalDepreciationPct  DECIMAL(9,4)     NULL,
    YearConstructed          SMALLINT         NULL,
    EffectiveYear            SMALLINT         NULL,
    Condition                NVARCHAR(10)     NULL,
    ObsolescencePct          DECIMAL(9,4)     NULL,
    RemainderValue           DECIMAL(14,2)    NULL,
    CONSTRAINT PK_CountyAssessorImprovementSegment PRIMARY KEY (ID),
    CONSTRAINT FK_CountyAssessorImprovementSegment_CountyAssessorRecord FOREIGN KEY (CountyAssessorRecordID) REFERENCES indiana_tax.CountyAssessorRecord(ID)
);
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'One row per floor/use-segment column from a Property Record Card''s dense per-card pricing table (the "Average Size / Units" grid). CRITICAL: a segment''s printed size is PER FLOOR, not the segment total -- e.g. "21,263 / 10" means 21,263 sqft on each of 10 floors (212,630 sqft total). TotalSqFt is a computed column so this multiplication can never be silently skipped or dropped. Summing TotalSqFt across all of a parcel''s segments should match the Building row''s SizeOrArea in CountyAssessorImprovement -- root-caused against parcel 8050459 on 2026-08-23 (see the closed ResearchTask), where plain-text PDF extraction had previously dropped a leading digit and silently undercounted a segment by a factor of ~17.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorImprovementSegment';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The parcel record this improvement segment belongs to. Segments are implicitly part of the "Building" structure line -- Paving/Skyway/etc. don''t carry their own per-floor breakdown, so there is no direct link to a specific CountyAssessorImprovement row.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorImprovementSegment',
    @level2type = N'COLUMN', @level2name = N'CountyAssessorRecordID';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The card page this segment was reported on (e.g. "1", "1A").',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorImprovementSegment',
    @level2type = N'COLUMN', @level2name = N'CardNumber';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The segment''s column position within its card (left to right), used to preserve the original ordering and as a stable identity within a card when re-parsing.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorImprovementSegment',
    @level2type = N'COLUMN', @level2name = N'SegmentIndex';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The use classification for this segment, e.g. "Gen Office", "Utility".',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorImprovementSegment',
    @level2type = N'COLUMN', @level2name = N'Use';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The "S.F. Area" / "Average Size" value for this segment -- the size of ONE floor of this type, not the segment total. See TotalSqFt.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorImprovementSegment',
    @level2type = N'COLUMN', @level2name = N'SqFtPerFloor';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The "Units" value from "Average Size / Units" -- how many floors carry this segment''s SqFtPerFloor. 1 for a single-floor segment.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorImprovementSegment',
    @level2type = N'COLUMN', @level2name = N'FloorCount';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Computed as SqFtPerFloor * FloorCount -- the true total square footage this segment contributes to the building. Always use this, never SqFtPerFloor alone, for any building-size or per-square-foot analysis.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorImprovementSegment',
    @level2type = N'COLUMN', @level2name = N'TotalSqFt';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The assessor''s estimated replacement cost for this segment, per the card''s cost-model computation.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorImprovementSegment',
    @level2type = N'COLUMN', @level2name = N'ReproductionCost';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The "Phys Dep" percentage from the "Phys Dep/ Yr Blt /Cond" field -- physical depreciation applied to this segment''s reproduction cost.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorImprovementSegment',
    @level2type = N'COLUMN', @level2name = N'PhysicalDepreciationPct';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The "Yr Blt" (year built) component of "Phys Dep/ Yr Blt /Cond" for this specific segment -- can differ segment-to-segment within the same structure (e.g. an addition).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorImprovementSegment',
    @level2type = N'COLUMN', @level2name = N'YearConstructed';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The effective year used for this segment''s depreciation calculation.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorImprovementSegment',
    @level2type = N'COLUMN', @level2name = N'EffectiveYear';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The "Cond" (condition) component of "Phys Dep/ Yr Blt /Cond" -- a letter rating (e.g. "A") for this segment.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorImprovementSegment',
    @level2type = N'COLUMN', @level2name = N'Condition';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The "Obsolescence" figure for this segment -- a cost-model adjustment the county can apply to align reproduction-cost-based value with market value-in-use. NOTE (2026-08-23): the sample parcel used to design this table had Obsolescence=0 throughout, so the real-world format (percentage vs. dollar amount) of a non-zero value has not yet been directly confirmed -- verify against a parcel with an actual adjustment before relying on this column''s units. A parcel receiving this adjustment while comparable parcels don''t is a potential appeal-lead signal (see the related ResearchTask), but that scoring logic is not implemented by this column alone.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorImprovementSegment',
    @level2type = N'COLUMN', @level2name = N'ObsolescencePct';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The "Remainder Value" for this segment -- reproduction cost after physical depreciation and obsolescence.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'CountyAssessorImprovementSegment',
    @level2type = N'COLUMN', @level2name = N'RemainderValue';
GO

-- ============================================================================
-- Document the new, more-reliable SqFtSource value this ingestion will produce.
-- ============================================================================

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('indiana_tax.CountyAssessorRecord')
           AND minor_id = (SELECT column_id FROM sys.columns
                          WHERE object_id = OBJECT_ID('indiana_tax.CountyAssessorRecord')
                          AND name = 'SqFtSource')
           AND name = 'MS_Description')
BEGIN
    EXEC sp_dropextendedproperty
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = 'indiana_tax',
        @level1type = N'TABLE', @level1name = 'CountyAssessorRecord',
        @level2type = N'COLUMN', @level2name = 'SqFtSource';
END

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'How EstimatedSqFt was sourced/verified, in descending order of reliability: ''PropertyRecordCard'' = computed from CountyAssessorImprovementSegment (SqFtPerFloor * FloorCount, summed and cross-checked against the card''s own Building total) -- the most reliable source, correctly accounts for multi-floor segments. ''BuildingDetail'' = summed from itemized per-floor building_detail data WITHOUT a floor-count multiplier -- confirmed 2026-08-23 to systematically undercount multi-floor buildings (e.g. a 10-floor segment counted as 1 floor), superseded by ''PropertyRecordCard'' wherever available. NULL = original ArcGIS ESTSQFT value (unverified, may be land-area-derived) or cleared after being proven land-derived with no replacement source available.',
    @level0type = N'SCHEMA', @level0name = 'indiana_tax',
    @level1type = N'TABLE', @level1name = 'CountyAssessorRecord',
    @level2type = N'COLUMN', @level2name = 'SqFtSource';
GO
