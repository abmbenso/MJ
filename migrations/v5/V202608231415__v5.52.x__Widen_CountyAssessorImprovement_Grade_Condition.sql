-- Widens indiana_tax.CountyAssessorImprovement.Grade and .Condition from
-- NVARCHAR(10) to NVARCHAR(50).
--
-- Hit during the first PRC pilot run: the "Summary of Improvements" table's
-- row/column reconstruction (nearest-x-position column assignment) is not yet
-- fully clean for every column on every row -- confirmed on a real pilot parcel,
-- the Paving/Skyway rows' Condition cell sometimes captured extra adjacent text
-- (e.g. "A 2.62 0 2.62" instead of just "A"), and NVARCHAR(10) is too small to
-- even hold that, causing a hard TDS protocol error on insert (the exact same
-- failure class as the PeerGroupBasis overflow from migration V202608220828 --
-- a client-side/DB column too small for a real parsed value, not a clean
-- truncation). Widening is a safety margin, not a fix for the parser itself --
-- the per-floor CountyAssessorImprovementSegment table (a different, more
-- reliable extraction path) has clean, validated Condition/Grade values; this
-- table's non-Building rows (Paving, Skyway, etc.) may still carry noisier data
-- until the column-reconstruction logic in scripts/lib/prc-parser.js is refined.

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('indiana_tax.CountyAssessorImprovement')
           AND minor_id = (SELECT column_id FROM sys.columns
                          WHERE object_id = OBJECT_ID('indiana_tax.CountyAssessorImprovement')
                          AND name = 'Grade')
           AND name = 'MS_Description')
BEGIN
    EXEC sp_dropextendedproperty
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = 'indiana_tax',
        @level1type = N'TABLE', @level1name = 'CountyAssessorImprovement',
        @level2type = N'COLUMN', @level2name = 'Grade';
END
IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('indiana_tax.CountyAssessorImprovement')
           AND minor_id = (SELECT column_id FROM sys.columns
                          WHERE object_id = OBJECT_ID('indiana_tax.CountyAssessorImprovement')
                          AND name = 'Condition')
           AND name = 'MS_Description')
BEGIN
    EXEC sp_dropextendedproperty
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = 'indiana_tax',
        @level1type = N'TABLE', @level1name = 'CountyAssessorImprovement',
        @level2type = N'COLUMN', @level2name = 'Condition';
END

ALTER TABLE indiana_tax.CountyAssessorImprovement
ALTER COLUMN Grade NVARCHAR(50) NULL;
ALTER TABLE indiana_tax.CountyAssessorImprovement
ALTER COLUMN Condition NVARCHAR(50) NULL;

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Construction grade rating (e.g. "C", "B+"). Widened to NVARCHAR(50) after the parser''s row/column reconstruction occasionally captured extra adjacent text for non-Building structure rows (Paving, Skyway) -- treat this field as less reliable than the same field on CountyAssessorImprovementSegment for those rows.',
    @level0type = N'SCHEMA', @level0name = 'indiana_tax',
    @level1type = N'TABLE', @level1name = 'CountyAssessorImprovement',
    @level2type = N'COLUMN', @level2name = 'Grade';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Condition rating letter (e.g. "A"). Widened to NVARCHAR(50) after the parser''s row/column reconstruction occasionally captured extra adjacent text for non-Building structure rows (Paving, Skyway) -- treat this field as less reliable than the same field on CountyAssessorImprovementSegment for those rows.',
    @level0type = N'SCHEMA', @level0name = 'indiana_tax',
    @level1type = N'TABLE', @level1name = 'CountyAssessorImprovement',
    @level2type = N'COLUMN', @level2name = 'Condition';
