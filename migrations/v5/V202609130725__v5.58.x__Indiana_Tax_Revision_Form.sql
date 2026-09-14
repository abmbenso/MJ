/* ============================================================================
   Indiana Property Tax Expert — the form behind a revision, as a column
   v5.58.x (companion to V202609121958 Indiana_Tax_Card_History)

   A county record card names the form behind a changed value in its Reason
   For Change cell ('Rev. 134', 'Reval/134', 'Det/115', 'F113') and in its
   notes ('PER PRIOR FORM 133 CORRECTION', a code 'F113'). The forms mean
   different things -- 134 is the preliminary informal-conference agreement
   (the stage that produces most reductions), 115 a PTABOA determination,
   133 a correction of error, 130 a petition, 131 an IBTR appeal, 113 a notice
   of assessment change (not an appeal), 136 an exemption application -- and
   one form is spelled several ways, so a filter on the text is fragile. These
   columns carry the form number itself, and carry the revising column's form,
   reason and date onto the parcel-year (Assessment) and the current row
   (CountyAssessorRecord), where a user filters.

   Also decided with it: for a county-card source CountyAssessorRecord's
   Assessed*AV is the OPERATIVE value of the newest year (the later certified
   column where one exists), not the notice; the loader change is in
   Indiana_Tax_Expert (Plan C Task 14). No data change here.
   ============================================================================ */

ALTER TABLE indiana_tax.CardValuationColumn ADD
    ReasonForm SMALLINT NULL;
GO

ALTER TABLE indiana_tax.CardNote ADD
    NoteForm SMALLINT NULL;
GO

ALTER TABLE indiana_tax.Assessment ADD
    RevisionForm SMALLINT NULL,
    RevisionReason NVARCHAR(50) NULL,
    RevisionAsOfDate DATE NULL;
GO

ALTER TABLE indiana_tax.CountyAssessorRecord ADD
    RevisionForm SMALLINT NULL,
    RevisionReason NVARCHAR(50) NULL,
    RevisionAsOfDate DATE NULL;
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The Indiana form named in this column''s Reason For Change cell, as a number: 134 preliminary informal-conference agreement, 115 PTABOA determination, 133 correction of error, 130 petition to the county board, 131 IBTR appeal, 113 notice of assessment change, 136 exemption application. NULL when the cell names none (AA, GenReval, WIP, blank). The cell itself is ReasonForChange.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardValuationColumn', @level2type = N'COLUMN', @level2name = N'ReasonForm';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The Indiana form the note cites (its code ''F113'', or ''FORM 133'' / ''F-115'' in the text), as a number -- the same set as CardValuationColumn.ReasonForm. NULL when the note cites none. Lake''s appeal history older than the card''s five columns lives in these notes.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CardNote', @level2type = N'COLUMN', @level2name = N'NoteForm';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'County-card sources only. The form behind the PTABOA*AV revision (CardValuationColumn.ReasonForm of the later column): 134, 115, 133, 130, 131, 113 or NULL. NULL when nothing revised the year, or the revising column names no form (a re-trend, a split).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'Assessment', @level2type = N'COLUMN', @level2name = N'RevisionForm';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'County-card sources only. The Reason For Change cell of the column that supplied PTABOA*AV, verbatim (''Rev. 134'', ''F113'', ''AA''). NULL when nothing revised the year.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'Assessment', @level2type = N'COLUMN', @level2name = N'RevisionReason';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'County-card sources only. The As Of Date of the column that supplied PTABOA*AV. NULL when nothing revised the year.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'Assessment', @level2type = N'COLUMN', @level2name = N'RevisionAsOfDate';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'County-card sources only. For the current year (TaxYear): the form behind the revision the Assessed*AV reflects -- 134, 115, 133, 130, 131, 113 -- or NULL when the value is the original notice or the revising column names no form. The as-noticed value is Assessment.Original*AV for that year.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CountyAssessorRecord', @level2type = N'COLUMN', @level2name = N'RevisionForm';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'County-card sources only. The Reason For Change cell of the column the current Assessed*AV came from, when it is a revision; NULL when the value is the original notice.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CountyAssessorRecord', @level2type = N'COLUMN', @level2name = N'RevisionReason';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'County-card sources only. The As Of Date of the revision the current Assessed*AV reflects; NULL when the value is the original notice.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'CountyAssessorRecord', @level2type = N'COLUMN', @level2name = N'RevisionAsOfDate';
GO


















































/* ============================================================================
   EVERYTHING BELOW WAS GENERATED BY THE MEMBERJUNCTION CODEGEN TOOL.
   It contains the EntityField inserts for the eight new columns, the
   regenerated views (vwAssessments, vwCardNotes, vwCardValuationColumns,
   vwCountyAssessorRecords), the spCreate/spUpdate/spDelete procedures and
   update triggers for those four entities, the FK index checks, and the
   permission grants. Do NOT edit by hand -- if the hand DDL above changes,
   re-run CodeGen and replace this entire section.
   Excluded as unrelated: an EntityField sequence update for Big_Box_Retail's
   "Store Analysis" virtual entity, a pre-existing CodeGen error on that entity.
   ============================================================================ */

/* SQL text to insert 8 new entity field(s) */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'c5b2ae84-6530-4c6f-89d3-0bdc0d8d48fb' OR (EntityID = '4AB7D5DF-8D95-4897-BC26-1FEA542669EF' AND Name = 'RevisionForm')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'c5b2ae84-6530-4c6f-89d3-0bdc0d8d48fb',
            '4AB7D5DF-8D95-4897-BC26-1FEA542669EF', -- Entity: Assessments
            100033,
            'RevisionForm',
            'Revision Form',
            'County-card sources only. The form behind the PTABOA*AV revision (CardValuationColumn.ReasonForm of the later column): 134, 115, 133, 130, 131, 113 or NULL. NULL when nothing revised the year, or the revising column names no form (a re-trend, a split).',
            'smallint',
            2,
            5,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd6e272a2-b3a1-4bd4-a57c-936bed03ae33' OR (EntityID = '4AB7D5DF-8D95-4897-BC26-1FEA542669EF' AND Name = 'RevisionReason')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'd6e272a2-b3a1-4bd4-a57c-936bed03ae33',
            '4AB7D5DF-8D95-4897-BC26-1FEA542669EF', -- Entity: Assessments
            100034,
            'RevisionReason',
            'Revision Reason',
            'County-card sources only. The Reason For Change cell of the column that supplied PTABOA*AV, verbatim (''Rev. 134'', ''F113'', ''AA''). NULL when nothing revised the year.',
            'nvarchar',
            100,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'b75aeabe-1348-4097-9094-bb3f87370dce' OR (EntityID = '4AB7D5DF-8D95-4897-BC26-1FEA542669EF' AND Name = 'RevisionAsOfDate')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'b75aeabe-1348-4097-9094-bb3f87370dce',
            '4AB7D5DF-8D95-4897-BC26-1FEA542669EF', -- Entity: Assessments
            100035,
            'RevisionAsOfDate',
            'Revision As Of Date',
            'County-card sources only. The As Of Date of the column that supplied PTABOA*AV. NULL when nothing revised the year.',
            'date',
            3,
            10,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '94c6db31-498a-4c83-abbe-e3dcbda51f59' OR (EntityID = '43815D48-5A63-4FF9-BC25-232DBFB790FE' AND Name = 'RevisionForm')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '94c6db31-498a-4c83-abbe-e3dcbda51f59',
            '43815D48-5A63-4FF9-BC25-232DBFB790FE', -- Entity: County Assessor Records
            100098,
            'RevisionForm',
            'Revision Form',
            'County-card sources only. For the current year (TaxYear): the form behind the revision the Assessed*AV reflects -- 134, 115, 133, 130, 131, 113 -- or NULL when the value is the original notice or the revising column names no form. The as-noticed value is Assessment.Original*AV for that year.',
            'smallint',
            2,
            5,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '529f5bc9-979f-4163-80ca-f1b5b13966b6' OR (EntityID = '43815D48-5A63-4FF9-BC25-232DBFB790FE' AND Name = 'RevisionReason')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '529f5bc9-979f-4163-80ca-f1b5b13966b6',
            '43815D48-5A63-4FF9-BC25-232DBFB790FE', -- Entity: County Assessor Records
            100099,
            'RevisionReason',
            'Revision Reason',
            'County-card sources only. The Reason For Change cell of the column the current Assessed*AV came from, when it is a revision; NULL when the value is the original notice.',
            'nvarchar',
            100,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ca7d4cb5-cddb-4ffc-b163-02aa097c0a1e' OR (EntityID = '43815D48-5A63-4FF9-BC25-232DBFB790FE' AND Name = 'RevisionAsOfDate')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            'ca7d4cb5-cddb-4ffc-b163-02aa097c0a1e',
            '43815D48-5A63-4FF9-BC25-232DBFB790FE', -- Entity: County Assessor Records
            100100,
            'RevisionAsOfDate',
            'Revision As Of Date',
            'County-card sources only. The As Of Date of the revision the current Assessed*AV reflects; NULL when the value is the original notice.',
            'date',
            3,
            10,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '2b56e20e-50dc-48d5-9638-cb5a174b73bf' OR (EntityID = '2A7BD138-666D-4835-B591-256380F7775B' AND Name = 'NoteForm')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '2b56e20e-50dc-48d5-9638-cb5a174b73bf',
            '2A7BD138-666D-4835-B591-256380F7775B', -- Entity: Card Notes
            100027,
            'NoteForm',
            'Note Form',
            'The Indiana form the note cites (its code ''F113'', or ''FORM 133'' / ''F-115'' in the text), as a number -- the same set as CardValuationColumn.ReasonForm. NULL when the note cites none. Lake''s appeal history older than the card''s five columns lives in these notes.',
            'smallint',
            2,
            5,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '3ac9dee0-03be-4ce6-9cda-b1d0e788176f' OR (EntityID = '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7' AND Name = 'ReasonForm')) BEGIN
         INSERT INTO [${flyway:defaultSchema}].[EntityField]
         (
            [ID],
            [EntityID],
            [Sequence],
            [Name],
            [DisplayName],
            [Description],
            [Type],
            [Length],
            [Precision],
            [Scale],
            [AllowsNull],
            [DefaultValue],
            [AutoIncrement],
            [AllowUpdateAPI],
            [IsVirtual],
            [IsComputed],
            [RelatedEntityID],
            [RelatedEntityFieldName],
            [IsNameField],
            [IncludeInUserSearchAPI],
            [IncludeRelatedEntityNameFieldInBaseView],
            [DefaultInView],
            [IsPrimaryKey],
            [IsUnique],
            [RelatedEntityDisplayType],
            [__mj_CreatedAt],
            [__mj_UpdatedAt]
         )
         VALUES
         (
            '3ac9dee0-03be-4ce6-9cda-b1d0e788176f',
            '74ECE0A0-CFC9-4850-AB7F-DCF3A3D9DDC7', -- Entity: Card Valuation Columns
            100053,
            'ReasonForm',
            'Reason Form',
            'The Indiana form named in this column''s Reason For Change cell, as a number: 134 preliminary informal-conference agreement, 115 PTABOA determination, 133 correction of error, 130 petition to the county board, 131 IBTR appeal, 113 notice of assessment change, 136 exemption application. NULL when the cell names none (AA, GenReval, WIP, blank). The cell itself is ReasonForChange.',
            'smallint',
            2,
            5,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            NULL,
            NULL,
            0,
            0,
            0,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;


/* Index for Foreign Keys for Assessment */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Assessments
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key ParcelID in table Assessment
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Assessment_ParcelID' 
    AND object_id = OBJECT_ID('[indiana_tax].[Assessment]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Assessment_ParcelID ON [indiana_tax].[Assessment] ([ParcelID]);

-- Index for foreign key SourceDocumentID in table Assessment
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Assessment_SourceDocumentID' 
    AND object_id = OBJECT_ID('[indiana_tax].[Assessment]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Assessment_SourceDocumentID ON [indiana_tax].[Assessment] ([SourceDocumentID]);

/* Index for Foreign Keys for CardNote */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Notes
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key SourceDocumentID in table CardNote
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_CardNote_SourceDocumentID' 
    AND object_id = OBJECT_ID('[indiana_tax].[CardNote]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_CardNote_SourceDocumentID ON [indiana_tax].[CardNote] ([SourceDocumentID]);

-- Index for foreign key ParcelID in table CardNote
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_CardNote_ParcelID' 
    AND object_id = OBJECT_ID('[indiana_tax].[CardNote]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_CardNote_ParcelID ON [indiana_tax].[CardNote] ([ParcelID]);

/* Base View SQL for Assessments */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Assessments
-- Item: vwAssessments
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Assessments
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  Assessment
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwAssessments]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwAssessments];
GO

CREATE VIEW [indiana_tax].[vwAssessments]
AS
SELECT
    a.*,
    indianataxParcel_ParcelID.[ParcelNumber] AS [Parcel]
FROM
    [indiana_tax].[Assessment] AS a
INNER JOIN
    [indiana_tax].[Parcel] AS indianataxParcel_ParcelID
  ON
    [a].[ParcelID] = indianataxParcel_ParcelID.[ID]
GO
GRANT SELECT ON [indiana_tax].[vwAssessments] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for Assessments */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Assessments
-- Item: Permissions for vwAssessments
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwAssessments] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for Assessments */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Assessments
-- Item: spCreateAssessment
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR Assessment
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateAssessment]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateAssessment];
GO

CREATE PROCEDURE [indiana_tax].[spCreateAssessment]
    @ID uniqueidentifier = NULL,
    @ParcelID uniqueidentifier,
    @AssessmentYear smallint,
    @Source nvarchar(50),
    @PropertyClassCode_Clear bit = 0,
    @PropertyClassCode nvarchar(10) = NULL,
    @OriginalLandAV_Clear bit = 0,
    @OriginalLandAV decimal(14, 2) = NULL,
    @OriginalImprovementAV_Clear bit = 0,
    @OriginalImprovementAV decimal(14, 2) = NULL,
    @OriginalTotalAV_Clear bit = 0,
    @OriginalTotalAV decimal(14, 2) = NULL,
    @PTABOALandAV_Clear bit = 0,
    @PTABOALandAV decimal(14, 2) = NULL,
    @PTABOAImprovementAV_Clear bit = 0,
    @PTABOAImprovementAV decimal(14, 2) = NULL,
    @PTABOATotalAV_Clear bit = 0,
    @PTABOATotalAV decimal(14, 2) = NULL,
    @SourceDocumentID_Clear bit = 0,
    @SourceDocumentID uniqueidentifier = NULL,
    @RevisionForm_Clear bit = 0,
    @RevisionForm smallint = NULL,
    @RevisionReason_Clear bit = 0,
    @RevisionReason nvarchar(50) = NULL,
    @RevisionAsOfDate_Clear bit = 0,
    @RevisionAsOfDate date = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[Assessment]
            (
                [ID],
                [ParcelID],
                [AssessmentYear],
                [Source],
                [PropertyClassCode],
                [OriginalLandAV],
                [OriginalImprovementAV],
                [OriginalTotalAV],
                [PTABOALandAV],
                [PTABOAImprovementAV],
                [PTABOATotalAV],
                [SourceDocumentID],
                [RevisionForm],
                [RevisionReason],
                [RevisionAsOfDate]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @ParcelID,
                @AssessmentYear,
                @Source,
                CASE WHEN @PropertyClassCode_Clear = 1 THEN NULL ELSE ISNULL(@PropertyClassCode, NULL) END,
                CASE WHEN @OriginalLandAV_Clear = 1 THEN NULL ELSE ISNULL(@OriginalLandAV, NULL) END,
                CASE WHEN @OriginalImprovementAV_Clear = 1 THEN NULL ELSE ISNULL(@OriginalImprovementAV, NULL) END,
                CASE WHEN @OriginalTotalAV_Clear = 1 THEN NULL ELSE ISNULL(@OriginalTotalAV, NULL) END,
                CASE WHEN @PTABOALandAV_Clear = 1 THEN NULL ELSE ISNULL(@PTABOALandAV, NULL) END,
                CASE WHEN @PTABOAImprovementAV_Clear = 1 THEN NULL ELSE ISNULL(@PTABOAImprovementAV, NULL) END,
                CASE WHEN @PTABOATotalAV_Clear = 1 THEN NULL ELSE ISNULL(@PTABOATotalAV, NULL) END,
                CASE WHEN @SourceDocumentID_Clear = 1 THEN NULL ELSE ISNULL(@SourceDocumentID, NULL) END,
                CASE WHEN @RevisionForm_Clear = 1 THEN NULL ELSE ISNULL(@RevisionForm, NULL) END,
                CASE WHEN @RevisionReason_Clear = 1 THEN NULL ELSE ISNULL(@RevisionReason, NULL) END,
                CASE WHEN @RevisionAsOfDate_Clear = 1 THEN NULL ELSE ISNULL(@RevisionAsOfDate, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[Assessment]
            (
                [ParcelID],
                [AssessmentYear],
                [Source],
                [PropertyClassCode],
                [OriginalLandAV],
                [OriginalImprovementAV],
                [OriginalTotalAV],
                [PTABOALandAV],
                [PTABOAImprovementAV],
                [PTABOATotalAV],
                [SourceDocumentID],
                [RevisionForm],
                [RevisionReason],
                [RevisionAsOfDate]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ParcelID,
                @AssessmentYear,
                @Source,
                CASE WHEN @PropertyClassCode_Clear = 1 THEN NULL ELSE ISNULL(@PropertyClassCode, NULL) END,
                CASE WHEN @OriginalLandAV_Clear = 1 THEN NULL ELSE ISNULL(@OriginalLandAV, NULL) END,
                CASE WHEN @OriginalImprovementAV_Clear = 1 THEN NULL ELSE ISNULL(@OriginalImprovementAV, NULL) END,
                CASE WHEN @OriginalTotalAV_Clear = 1 THEN NULL ELSE ISNULL(@OriginalTotalAV, NULL) END,
                CASE WHEN @PTABOALandAV_Clear = 1 THEN NULL ELSE ISNULL(@PTABOALandAV, NULL) END,
                CASE WHEN @PTABOAImprovementAV_Clear = 1 THEN NULL ELSE ISNULL(@PTABOAImprovementAV, NULL) END,
                CASE WHEN @PTABOATotalAV_Clear = 1 THEN NULL ELSE ISNULL(@PTABOATotalAV, NULL) END,
                CASE WHEN @SourceDocumentID_Clear = 1 THEN NULL ELSE ISNULL(@SourceDocumentID, NULL) END,
                CASE WHEN @RevisionForm_Clear = 1 THEN NULL ELSE ISNULL(@RevisionForm, NULL) END,
                CASE WHEN @RevisionReason_Clear = 1 THEN NULL ELSE ISNULL(@RevisionReason, NULL) END,
                CASE WHEN @RevisionAsOfDate_Clear = 1 THEN NULL ELSE ISNULL(@RevisionAsOfDate, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwAssessments] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateAssessment] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for Assessments */

GRANT EXECUTE ON [indiana_tax].[spCreateAssessment] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for Assessments */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Assessments
-- Item: spUpdateAssessment
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR Assessment
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateAssessment]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateAssessment];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateAssessment]
    @ID uniqueidentifier,
    @ParcelID uniqueidentifier = NULL,
    @AssessmentYear smallint = NULL,
    @Source nvarchar(50) = NULL,
    @PropertyClassCode_Clear bit = 0,
    @PropertyClassCode nvarchar(10) = NULL,
    @OriginalLandAV_Clear bit = 0,
    @OriginalLandAV decimal(14, 2) = NULL,
    @OriginalImprovementAV_Clear bit = 0,
    @OriginalImprovementAV decimal(14, 2) = NULL,
    @OriginalTotalAV_Clear bit = 0,
    @OriginalTotalAV decimal(14, 2) = NULL,
    @PTABOALandAV_Clear bit = 0,
    @PTABOALandAV decimal(14, 2) = NULL,
    @PTABOAImprovementAV_Clear bit = 0,
    @PTABOAImprovementAV decimal(14, 2) = NULL,
    @PTABOATotalAV_Clear bit = 0,
    @PTABOATotalAV decimal(14, 2) = NULL,
    @SourceDocumentID_Clear bit = 0,
    @SourceDocumentID uniqueidentifier = NULL,
    @RevisionForm_Clear bit = 0,
    @RevisionForm smallint = NULL,
    @RevisionReason_Clear bit = 0,
    @RevisionReason nvarchar(50) = NULL,
    @RevisionAsOfDate_Clear bit = 0,
    @RevisionAsOfDate date = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[Assessment]
    SET
        [ParcelID] = ISNULL(@ParcelID, [ParcelID]),
        [AssessmentYear] = ISNULL(@AssessmentYear, [AssessmentYear]),
        [Source] = ISNULL(@Source, [Source]),
        [PropertyClassCode] = CASE WHEN @PropertyClassCode_Clear = 1 THEN NULL ELSE ISNULL(@PropertyClassCode, [PropertyClassCode]) END,
        [OriginalLandAV] = CASE WHEN @OriginalLandAV_Clear = 1 THEN NULL ELSE ISNULL(@OriginalLandAV, [OriginalLandAV]) END,
        [OriginalImprovementAV] = CASE WHEN @OriginalImprovementAV_Clear = 1 THEN NULL ELSE ISNULL(@OriginalImprovementAV, [OriginalImprovementAV]) END,
        [OriginalTotalAV] = CASE WHEN @OriginalTotalAV_Clear = 1 THEN NULL ELSE ISNULL(@OriginalTotalAV, [OriginalTotalAV]) END,
        [PTABOALandAV] = CASE WHEN @PTABOALandAV_Clear = 1 THEN NULL ELSE ISNULL(@PTABOALandAV, [PTABOALandAV]) END,
        [PTABOAImprovementAV] = CASE WHEN @PTABOAImprovementAV_Clear = 1 THEN NULL ELSE ISNULL(@PTABOAImprovementAV, [PTABOAImprovementAV]) END,
        [PTABOATotalAV] = CASE WHEN @PTABOATotalAV_Clear = 1 THEN NULL ELSE ISNULL(@PTABOATotalAV, [PTABOATotalAV]) END,
        [SourceDocumentID] = CASE WHEN @SourceDocumentID_Clear = 1 THEN NULL ELSE ISNULL(@SourceDocumentID, [SourceDocumentID]) END,
        [RevisionForm] = CASE WHEN @RevisionForm_Clear = 1 THEN NULL ELSE ISNULL(@RevisionForm, [RevisionForm]) END,
        [RevisionReason] = CASE WHEN @RevisionReason_Clear = 1 THEN NULL ELSE ISNULL(@RevisionReason, [RevisionReason]) END,
        [RevisionAsOfDate] = CASE WHEN @RevisionAsOfDate_Clear = 1 THEN NULL ELSE ISNULL(@RevisionAsOfDate, [RevisionAsOfDate]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwAssessments] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwAssessments]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateAssessment] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the Assessment table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateAssessment]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateAssessment];
GO
CREATE TRIGGER [indiana_tax].trgUpdateAssessment
ON [indiana_tax].[Assessment]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[Assessment]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[Assessment] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for Assessments */

GRANT EXECUTE ON [indiana_tax].[spUpdateAssessment] TO [cdp_Developer], [cdp_Integration];

/* Base View SQL for Card Notes */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Notes
-- Item: vwCardNotes
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Card Notes
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  CardNote
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwCardNotes]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwCardNotes];
GO

CREATE VIEW [indiana_tax].[vwCardNotes]
AS
SELECT
    c.*,
    indianataxParcel_ParcelID.[ParcelNumber] AS [Parcel]
FROM
    [indiana_tax].[CardNote] AS c
INNER JOIN
    [indiana_tax].[Parcel] AS indianataxParcel_ParcelID
  ON
    [c].[ParcelID] = indianataxParcel_ParcelID.[ID]
GO
GRANT SELECT ON [indiana_tax].[vwCardNotes] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for Card Notes */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Notes
-- Item: Permissions for vwCardNotes
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwCardNotes] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for Card Notes */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Notes
-- Item: spCreateCardNote
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR CardNote
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateCardNote]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateCardNote];
GO

CREATE PROCEDURE [indiana_tax].[spCreateCardNote]
    @ID uniqueidentifier = NULL,
    @SourceDocumentID uniqueidentifier,
    @ParcelID uniqueidentifier,
    @CardAssessmentYear smallint,
    @EntryIndex smallint,
    @NoteDate_Clear bit = 0,
    @NoteDate date = NULL,
    @NoteCode_Clear bit = 0,
    @NoteCode nvarchar(20) = NULL,
    @NoteKind nvarchar(10),
    @NoteText nvarchar(MAX),
    @NoteKey char(64),
    @NoteForm_Clear bit = 0,
    @NoteForm smallint = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[CardNote]
            (
                [ID],
                [SourceDocumentID],
                [ParcelID],
                [CardAssessmentYear],
                [EntryIndex],
                [NoteDate],
                [NoteCode],
                [NoteKind],
                [NoteText],
                [NoteKey],
                [NoteForm]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @SourceDocumentID,
                @ParcelID,
                @CardAssessmentYear,
                @EntryIndex,
                CASE WHEN @NoteDate_Clear = 1 THEN NULL ELSE ISNULL(@NoteDate, NULL) END,
                CASE WHEN @NoteCode_Clear = 1 THEN NULL ELSE ISNULL(@NoteCode, NULL) END,
                @NoteKind,
                @NoteText,
                @NoteKey,
                CASE WHEN @NoteForm_Clear = 1 THEN NULL ELSE ISNULL(@NoteForm, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[CardNote]
            (
                [SourceDocumentID],
                [ParcelID],
                [CardAssessmentYear],
                [EntryIndex],
                [NoteDate],
                [NoteCode],
                [NoteKind],
                [NoteText],
                [NoteKey],
                [NoteForm]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @SourceDocumentID,
                @ParcelID,
                @CardAssessmentYear,
                @EntryIndex,
                CASE WHEN @NoteDate_Clear = 1 THEN NULL ELSE ISNULL(@NoteDate, NULL) END,
                CASE WHEN @NoteCode_Clear = 1 THEN NULL ELSE ISNULL(@NoteCode, NULL) END,
                @NoteKind,
                @NoteText,
                @NoteKey,
                CASE WHEN @NoteForm_Clear = 1 THEN NULL ELSE ISNULL(@NoteForm, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwCardNotes] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateCardNote] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for Card Notes */

GRANT EXECUTE ON [indiana_tax].[spCreateCardNote] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for Card Notes */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Notes
-- Item: spUpdateCardNote
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR CardNote
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateCardNote]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateCardNote];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateCardNote]
    @ID uniqueidentifier,
    @SourceDocumentID uniqueidentifier = NULL,
    @ParcelID uniqueidentifier = NULL,
    @CardAssessmentYear smallint = NULL,
    @EntryIndex smallint = NULL,
    @NoteDate_Clear bit = 0,
    @NoteDate date = NULL,
    @NoteCode_Clear bit = 0,
    @NoteCode nvarchar(20) = NULL,
    @NoteKind nvarchar(10) = NULL,
    @NoteText nvarchar(MAX) = NULL,
    @NoteKey char(64) = NULL,
    @NoteForm_Clear bit = 0,
    @NoteForm smallint = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[CardNote]
    SET
        [SourceDocumentID] = ISNULL(@SourceDocumentID, [SourceDocumentID]),
        [ParcelID] = ISNULL(@ParcelID, [ParcelID]),
        [CardAssessmentYear] = ISNULL(@CardAssessmentYear, [CardAssessmentYear]),
        [EntryIndex] = ISNULL(@EntryIndex, [EntryIndex]),
        [NoteDate] = CASE WHEN @NoteDate_Clear = 1 THEN NULL ELSE ISNULL(@NoteDate, [NoteDate]) END,
        [NoteCode] = CASE WHEN @NoteCode_Clear = 1 THEN NULL ELSE ISNULL(@NoteCode, [NoteCode]) END,
        [NoteKind] = ISNULL(@NoteKind, [NoteKind]),
        [NoteText] = ISNULL(@NoteText, [NoteText]),
        [NoteKey] = ISNULL(@NoteKey, [NoteKey]),
        [NoteForm] = CASE WHEN @NoteForm_Clear = 1 THEN NULL ELSE ISNULL(@NoteForm, [NoteForm]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwCardNotes] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwCardNotes]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateCardNote] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the CardNote table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateCardNote]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateCardNote];
GO
CREATE TRIGGER [indiana_tax].trgUpdateCardNote
ON [indiana_tax].[CardNote]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[CardNote]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[CardNote] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for Card Notes */

GRANT EXECUTE ON [indiana_tax].[spUpdateCardNote] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for Assessments */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Assessments
-- Item: spDeleteAssessment
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR Assessment
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteAssessment]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteAssessment];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteAssessment]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[Assessment]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteAssessment] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for Assessments */

GRANT EXECUTE ON [indiana_tax].[spDeleteAssessment] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for Card Notes */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Notes
-- Item: spDeleteCardNote
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR CardNote
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteCardNote]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteCardNote];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteCardNote]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[CardNote]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteCardNote] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for Card Notes */

GRANT EXECUTE ON [indiana_tax].[spDeleteCardNote] TO [cdp_Developer], [cdp_Integration];

/* Index for Foreign Keys for CardValuationColumn */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Valuation Columns
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key SourceDocumentID in table CardValuationColumn
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_CardValuationColumn_SourceDocumentID' 
    AND object_id = OBJECT_ID('[indiana_tax].[CardValuationColumn]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_CardValuationColumn_SourceDocumentID ON [indiana_tax].[CardValuationColumn] ([SourceDocumentID]);

-- Index for foreign key ParcelID in table CardValuationColumn
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_CardValuationColumn_ParcelID' 
    AND object_id = OBJECT_ID('[indiana_tax].[CardValuationColumn]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_CardValuationColumn_ParcelID ON [indiana_tax].[CardValuationColumn] ([ParcelID]);

/* Base View SQL for Card Valuation Columns */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Valuation Columns
-- Item: vwCardValuationColumns
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Card Valuation Columns
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  CardValuationColumn
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwCardValuationColumns]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwCardValuationColumns];
GO

CREATE VIEW [indiana_tax].[vwCardValuationColumns]
AS
SELECT
    c.*,
    indianataxParcel_ParcelID.[ParcelNumber] AS [Parcel]
FROM
    [indiana_tax].[CardValuationColumn] AS c
INNER JOIN
    [indiana_tax].[Parcel] AS indianataxParcel_ParcelID
  ON
    [c].[ParcelID] = indianataxParcel_ParcelID.[ID]
GO
GRANT SELECT ON [indiana_tax].[vwCardValuationColumns] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for Card Valuation Columns */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Valuation Columns
-- Item: Permissions for vwCardValuationColumns
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwCardValuationColumns] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for Card Valuation Columns */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Valuation Columns
-- Item: spCreateCardValuationColumn
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR CardValuationColumn
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateCardValuationColumn]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateCardValuationColumn];
GO

CREATE PROCEDURE [indiana_tax].[spCreateCardValuationColumn]
    @ID uniqueidentifier = NULL,
    @SourceDocumentID uniqueidentifier,
    @ParcelID uniqueidentifier,
    @CardAssessmentYear smallint,
    @ColumnIndex smallint,
    @AssessmentYear smallint,
    @IsCertified bit,
    @ReasonForChange_Clear bit = 0,
    @ReasonForChange nvarchar(50) = NULL,
    @ReasonKind nvarchar(10),
    @AsOfDate_Clear bit = 0,
    @AsOfDate date = NULL,
    @ValuationMethod_Clear bit = 0,
    @ValuationMethod nvarchar(50) = NULL,
    @LandAV_Clear bit = 0,
    @LandAV decimal(14, 2) = NULL,
    @ImprovementAV_Clear bit = 0,
    @ImprovementAV decimal(14, 2) = NULL,
    @TotalAV_Clear bit = 0,
    @TotalAV decimal(14, 2) = NULL,
    @LandRes1AV_Clear bit = 0,
    @LandRes1AV decimal(14, 2) = NULL,
    @LandNonRes2AV_Clear bit = 0,
    @LandNonRes2AV decimal(14, 2) = NULL,
    @LandNonRes3AV_Clear bit = 0,
    @LandNonRes3AV decimal(14, 2) = NULL,
    @ImprovementRes1AV_Clear bit = 0,
    @ImprovementRes1AV decimal(14, 2) = NULL,
    @ImprovementNonRes2AV_Clear bit = 0,
    @ImprovementNonRes2AV decimal(14, 2) = NULL,
    @ImprovementNonRes3AV_Clear bit = 0,
    @ImprovementNonRes3AV decimal(14, 2) = NULL,
    @TotalRes1AV_Clear bit = 0,
    @TotalRes1AV decimal(14, 2) = NULL,
    @TotalNonRes2AV_Clear bit = 0,
    @TotalNonRes2AV decimal(14, 2) = NULL,
    @TotalNonRes3AV_Clear bit = 0,
    @TotalNonRes3AV decimal(14, 2) = NULL,
    @ReasonForm_Clear bit = 0,
    @ReasonForm smallint = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[CardValuationColumn]
            (
                [ID],
                [SourceDocumentID],
                [ParcelID],
                [CardAssessmentYear],
                [ColumnIndex],
                [AssessmentYear],
                [IsCertified],
                [ReasonForChange],
                [ReasonKind],
                [AsOfDate],
                [ValuationMethod],
                [LandAV],
                [ImprovementAV],
                [TotalAV],
                [LandRes1AV],
                [LandNonRes2AV],
                [LandNonRes3AV],
                [ImprovementRes1AV],
                [ImprovementNonRes2AV],
                [ImprovementNonRes3AV],
                [TotalRes1AV],
                [TotalNonRes2AV],
                [TotalNonRes3AV],
                [ReasonForm]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @SourceDocumentID,
                @ParcelID,
                @CardAssessmentYear,
                @ColumnIndex,
                @AssessmentYear,
                @IsCertified,
                CASE WHEN @ReasonForChange_Clear = 1 THEN NULL ELSE ISNULL(@ReasonForChange, NULL) END,
                @ReasonKind,
                CASE WHEN @AsOfDate_Clear = 1 THEN NULL ELSE ISNULL(@AsOfDate, NULL) END,
                CASE WHEN @ValuationMethod_Clear = 1 THEN NULL ELSE ISNULL(@ValuationMethod, NULL) END,
                CASE WHEN @LandAV_Clear = 1 THEN NULL ELSE ISNULL(@LandAV, NULL) END,
                CASE WHEN @ImprovementAV_Clear = 1 THEN NULL ELSE ISNULL(@ImprovementAV, NULL) END,
                CASE WHEN @TotalAV_Clear = 1 THEN NULL ELSE ISNULL(@TotalAV, NULL) END,
                CASE WHEN @LandRes1AV_Clear = 1 THEN NULL ELSE ISNULL(@LandRes1AV, NULL) END,
                CASE WHEN @LandNonRes2AV_Clear = 1 THEN NULL ELSE ISNULL(@LandNonRes2AV, NULL) END,
                CASE WHEN @LandNonRes3AV_Clear = 1 THEN NULL ELSE ISNULL(@LandNonRes3AV, NULL) END,
                CASE WHEN @ImprovementRes1AV_Clear = 1 THEN NULL ELSE ISNULL(@ImprovementRes1AV, NULL) END,
                CASE WHEN @ImprovementNonRes2AV_Clear = 1 THEN NULL ELSE ISNULL(@ImprovementNonRes2AV, NULL) END,
                CASE WHEN @ImprovementNonRes3AV_Clear = 1 THEN NULL ELSE ISNULL(@ImprovementNonRes3AV, NULL) END,
                CASE WHEN @TotalRes1AV_Clear = 1 THEN NULL ELSE ISNULL(@TotalRes1AV, NULL) END,
                CASE WHEN @TotalNonRes2AV_Clear = 1 THEN NULL ELSE ISNULL(@TotalNonRes2AV, NULL) END,
                CASE WHEN @TotalNonRes3AV_Clear = 1 THEN NULL ELSE ISNULL(@TotalNonRes3AV, NULL) END,
                CASE WHEN @ReasonForm_Clear = 1 THEN NULL ELSE ISNULL(@ReasonForm, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[CardValuationColumn]
            (
                [SourceDocumentID],
                [ParcelID],
                [CardAssessmentYear],
                [ColumnIndex],
                [AssessmentYear],
                [IsCertified],
                [ReasonForChange],
                [ReasonKind],
                [AsOfDate],
                [ValuationMethod],
                [LandAV],
                [ImprovementAV],
                [TotalAV],
                [LandRes1AV],
                [LandNonRes2AV],
                [LandNonRes3AV],
                [ImprovementRes1AV],
                [ImprovementNonRes2AV],
                [ImprovementNonRes3AV],
                [TotalRes1AV],
                [TotalNonRes2AV],
                [TotalNonRes3AV],
                [ReasonForm]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @SourceDocumentID,
                @ParcelID,
                @CardAssessmentYear,
                @ColumnIndex,
                @AssessmentYear,
                @IsCertified,
                CASE WHEN @ReasonForChange_Clear = 1 THEN NULL ELSE ISNULL(@ReasonForChange, NULL) END,
                @ReasonKind,
                CASE WHEN @AsOfDate_Clear = 1 THEN NULL ELSE ISNULL(@AsOfDate, NULL) END,
                CASE WHEN @ValuationMethod_Clear = 1 THEN NULL ELSE ISNULL(@ValuationMethod, NULL) END,
                CASE WHEN @LandAV_Clear = 1 THEN NULL ELSE ISNULL(@LandAV, NULL) END,
                CASE WHEN @ImprovementAV_Clear = 1 THEN NULL ELSE ISNULL(@ImprovementAV, NULL) END,
                CASE WHEN @TotalAV_Clear = 1 THEN NULL ELSE ISNULL(@TotalAV, NULL) END,
                CASE WHEN @LandRes1AV_Clear = 1 THEN NULL ELSE ISNULL(@LandRes1AV, NULL) END,
                CASE WHEN @LandNonRes2AV_Clear = 1 THEN NULL ELSE ISNULL(@LandNonRes2AV, NULL) END,
                CASE WHEN @LandNonRes3AV_Clear = 1 THEN NULL ELSE ISNULL(@LandNonRes3AV, NULL) END,
                CASE WHEN @ImprovementRes1AV_Clear = 1 THEN NULL ELSE ISNULL(@ImprovementRes1AV, NULL) END,
                CASE WHEN @ImprovementNonRes2AV_Clear = 1 THEN NULL ELSE ISNULL(@ImprovementNonRes2AV, NULL) END,
                CASE WHEN @ImprovementNonRes3AV_Clear = 1 THEN NULL ELSE ISNULL(@ImprovementNonRes3AV, NULL) END,
                CASE WHEN @TotalRes1AV_Clear = 1 THEN NULL ELSE ISNULL(@TotalRes1AV, NULL) END,
                CASE WHEN @TotalNonRes2AV_Clear = 1 THEN NULL ELSE ISNULL(@TotalNonRes2AV, NULL) END,
                CASE WHEN @TotalNonRes3AV_Clear = 1 THEN NULL ELSE ISNULL(@TotalNonRes3AV, NULL) END,
                CASE WHEN @ReasonForm_Clear = 1 THEN NULL ELSE ISNULL(@ReasonForm, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwCardValuationColumns] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateCardValuationColumn] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for Card Valuation Columns */

GRANT EXECUTE ON [indiana_tax].[spCreateCardValuationColumn] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for Card Valuation Columns */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Valuation Columns
-- Item: spUpdateCardValuationColumn
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR CardValuationColumn
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateCardValuationColumn]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateCardValuationColumn];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateCardValuationColumn]
    @ID uniqueidentifier,
    @SourceDocumentID uniqueidentifier = NULL,
    @ParcelID uniqueidentifier = NULL,
    @CardAssessmentYear smallint = NULL,
    @ColumnIndex smallint = NULL,
    @AssessmentYear smallint = NULL,
    @IsCertified bit = NULL,
    @ReasonForChange_Clear bit = 0,
    @ReasonForChange nvarchar(50) = NULL,
    @ReasonKind nvarchar(10) = NULL,
    @AsOfDate_Clear bit = 0,
    @AsOfDate date = NULL,
    @ValuationMethod_Clear bit = 0,
    @ValuationMethod nvarchar(50) = NULL,
    @LandAV_Clear bit = 0,
    @LandAV decimal(14, 2) = NULL,
    @ImprovementAV_Clear bit = 0,
    @ImprovementAV decimal(14, 2) = NULL,
    @TotalAV_Clear bit = 0,
    @TotalAV decimal(14, 2) = NULL,
    @LandRes1AV_Clear bit = 0,
    @LandRes1AV decimal(14, 2) = NULL,
    @LandNonRes2AV_Clear bit = 0,
    @LandNonRes2AV decimal(14, 2) = NULL,
    @LandNonRes3AV_Clear bit = 0,
    @LandNonRes3AV decimal(14, 2) = NULL,
    @ImprovementRes1AV_Clear bit = 0,
    @ImprovementRes1AV decimal(14, 2) = NULL,
    @ImprovementNonRes2AV_Clear bit = 0,
    @ImprovementNonRes2AV decimal(14, 2) = NULL,
    @ImprovementNonRes3AV_Clear bit = 0,
    @ImprovementNonRes3AV decimal(14, 2) = NULL,
    @TotalRes1AV_Clear bit = 0,
    @TotalRes1AV decimal(14, 2) = NULL,
    @TotalNonRes2AV_Clear bit = 0,
    @TotalNonRes2AV decimal(14, 2) = NULL,
    @TotalNonRes3AV_Clear bit = 0,
    @TotalNonRes3AV decimal(14, 2) = NULL,
    @ReasonForm_Clear bit = 0,
    @ReasonForm smallint = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[CardValuationColumn]
    SET
        [SourceDocumentID] = ISNULL(@SourceDocumentID, [SourceDocumentID]),
        [ParcelID] = ISNULL(@ParcelID, [ParcelID]),
        [CardAssessmentYear] = ISNULL(@CardAssessmentYear, [CardAssessmentYear]),
        [ColumnIndex] = ISNULL(@ColumnIndex, [ColumnIndex]),
        [AssessmentYear] = ISNULL(@AssessmentYear, [AssessmentYear]),
        [IsCertified] = ISNULL(@IsCertified, [IsCertified]),
        [ReasonForChange] = CASE WHEN @ReasonForChange_Clear = 1 THEN NULL ELSE ISNULL(@ReasonForChange, [ReasonForChange]) END,
        [ReasonKind] = ISNULL(@ReasonKind, [ReasonKind]),
        [AsOfDate] = CASE WHEN @AsOfDate_Clear = 1 THEN NULL ELSE ISNULL(@AsOfDate, [AsOfDate]) END,
        [ValuationMethod] = CASE WHEN @ValuationMethod_Clear = 1 THEN NULL ELSE ISNULL(@ValuationMethod, [ValuationMethod]) END,
        [LandAV] = CASE WHEN @LandAV_Clear = 1 THEN NULL ELSE ISNULL(@LandAV, [LandAV]) END,
        [ImprovementAV] = CASE WHEN @ImprovementAV_Clear = 1 THEN NULL ELSE ISNULL(@ImprovementAV, [ImprovementAV]) END,
        [TotalAV] = CASE WHEN @TotalAV_Clear = 1 THEN NULL ELSE ISNULL(@TotalAV, [TotalAV]) END,
        [LandRes1AV] = CASE WHEN @LandRes1AV_Clear = 1 THEN NULL ELSE ISNULL(@LandRes1AV, [LandRes1AV]) END,
        [LandNonRes2AV] = CASE WHEN @LandNonRes2AV_Clear = 1 THEN NULL ELSE ISNULL(@LandNonRes2AV, [LandNonRes2AV]) END,
        [LandNonRes3AV] = CASE WHEN @LandNonRes3AV_Clear = 1 THEN NULL ELSE ISNULL(@LandNonRes3AV, [LandNonRes3AV]) END,
        [ImprovementRes1AV] = CASE WHEN @ImprovementRes1AV_Clear = 1 THEN NULL ELSE ISNULL(@ImprovementRes1AV, [ImprovementRes1AV]) END,
        [ImprovementNonRes2AV] = CASE WHEN @ImprovementNonRes2AV_Clear = 1 THEN NULL ELSE ISNULL(@ImprovementNonRes2AV, [ImprovementNonRes2AV]) END,
        [ImprovementNonRes3AV] = CASE WHEN @ImprovementNonRes3AV_Clear = 1 THEN NULL ELSE ISNULL(@ImprovementNonRes3AV, [ImprovementNonRes3AV]) END,
        [TotalRes1AV] = CASE WHEN @TotalRes1AV_Clear = 1 THEN NULL ELSE ISNULL(@TotalRes1AV, [TotalRes1AV]) END,
        [TotalNonRes2AV] = CASE WHEN @TotalNonRes2AV_Clear = 1 THEN NULL ELSE ISNULL(@TotalNonRes2AV, [TotalNonRes2AV]) END,
        [TotalNonRes3AV] = CASE WHEN @TotalNonRes3AV_Clear = 1 THEN NULL ELSE ISNULL(@TotalNonRes3AV, [TotalNonRes3AV]) END,
        [ReasonForm] = CASE WHEN @ReasonForm_Clear = 1 THEN NULL ELSE ISNULL(@ReasonForm, [ReasonForm]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwCardValuationColumns] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwCardValuationColumns]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateCardValuationColumn] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the CardValuationColumn table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateCardValuationColumn]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateCardValuationColumn];
GO
CREATE TRIGGER [indiana_tax].trgUpdateCardValuationColumn
ON [indiana_tax].[CardValuationColumn]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[CardValuationColumn]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[CardValuationColumn] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for Card Valuation Columns */

GRANT EXECUTE ON [indiana_tax].[spUpdateCardValuationColumn] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for Card Valuation Columns */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Card Valuation Columns
-- Item: spDeleteCardValuationColumn
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR CardValuationColumn
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteCardValuationColumn]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteCardValuationColumn];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteCardValuationColumn]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[CardValuationColumn]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteCardValuationColumn] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for Card Valuation Columns */

GRANT EXECUTE ON [indiana_tax].[spDeleteCardValuationColumn] TO [cdp_Developer], [cdp_Integration];

/* Index for Foreign Keys for CountyAssessorRecord */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: County Assessor Records
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key ParcelID in table CountyAssessorRecord
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_CountyAssessorRecord_ParcelID' 
    AND object_id = OBJECT_ID('[indiana_tax].[CountyAssessorRecord]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_CountyAssessorRecord_ParcelID ON [indiana_tax].[CountyAssessorRecord] ([ParcelID]);

-- Index for foreign key SourceRegistryID in table CountyAssessorRecord
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_CountyAssessorRecord_SourceRegistryID' 
    AND object_id = OBJECT_ID('[indiana_tax].[CountyAssessorRecord]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_CountyAssessorRecord_SourceRegistryID ON [indiana_tax].[CountyAssessorRecord] ([SourceRegistryID]);

-- Index for foreign key SourceDocumentID in table CountyAssessorRecord
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_CountyAssessorRecord_SourceDocumentID' 
    AND object_id = OBJECT_ID('[indiana_tax].[CountyAssessorRecord]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_CountyAssessorRecord_SourceDocumentID ON [indiana_tax].[CountyAssessorRecord] ([SourceDocumentID]);

-- Index for foreign key TaxHistorySourceDocumentID in table CountyAssessorRecord
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_CountyAssessorRecord_TaxHistorySourceDocumentID' 
    AND object_id = OBJECT_ID('[indiana_tax].[CountyAssessorRecord]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_CountyAssessorRecord_TaxHistorySourceDocumentID ON [indiana_tax].[CountyAssessorRecord] ([TaxHistorySourceDocumentID]);

/* Base View SQL for County Assessor Records */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: County Assessor Records
-- Item: vwCountyAssessorRecords
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      County Assessor Records
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  CountyAssessorRecord
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwCountyAssessorRecords]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwCountyAssessorRecords];
GO

CREATE VIEW [indiana_tax].[vwCountyAssessorRecords]
AS
SELECT
    c.*,
    indianataxParcel_ParcelID.[ParcelNumber] AS [Parcel],
    indianataxSourceRegistry_SourceRegistryID.[Name] AS [SourceRegistry],
    ${flyway:defaultSchema}_rgc.[Latitude] AS [${flyway:defaultSchema}_Latitude],
    ${flyway:defaultSchema}_rgc.[Longitude] AS [${flyway:defaultSchema}_Longitude]
FROM
    [indiana_tax].[CountyAssessorRecord] AS c
INNER JOIN
    [indiana_tax].[Parcel] AS indianataxParcel_ParcelID
  ON
    [c].[ParcelID] = indianataxParcel_ParcelID.[ID]
LEFT OUTER JOIN
    [indiana_tax].[SourceRegistry] AS indianataxSourceRegistry_SourceRegistryID
  ON
    [c].[SourceRegistryID] = indianataxSourceRegistry_SourceRegistryID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[vwRecordGeoCodes] AS ${flyway:defaultSchema}_rgc
  ON
    ${flyway:defaultSchema}_rgc.[EntityID] = '43815D48-5A63-4FF9-BC25-232DBFB790FE'
    AND ${flyway:defaultSchema}_rgc.[RecordID] = CAST([c].[ID] AS NVARCHAR(450))
    AND ${flyway:defaultSchema}_rgc.[LocationType] = 'Primary'
GO
GRANT SELECT ON [indiana_tax].[vwCountyAssessorRecords] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for County Assessor Records */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: County Assessor Records
-- Item: Permissions for vwCountyAssessorRecords
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwCountyAssessorRecords] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for County Assessor Records */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: County Assessor Records
-- Item: spCreateCountyAssessorRecord
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR CountyAssessorRecord
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateCountyAssessorRecord]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateCountyAssessorRecord];
GO

CREATE PROCEDURE [indiana_tax].[spCreateCountyAssessorRecord]
    @ID uniqueidentifier = NULL,
    @ParcelID uniqueidentifier,
    @CountyNumber smallint,
    @OwnerName_Clear bit = 0,
    @OwnerName nvarchar(500) = NULL,
    @OwnerAddress_Clear bit = 0,
    @OwnerAddress nvarchar(200) = NULL,
    @OwnerCity_Clear bit = 0,
    @OwnerCity nvarchar(100) = NULL,
    @OwnerState_Clear bit = 0,
    @OwnerState nvarchar(10) = NULL,
    @OwnerZip_Clear bit = 0,
    @OwnerZip nvarchar(20) = NULL,
    @PropertyClass_Clear bit = 0,
    @PropertyClass nvarchar(32) = NULL,
    @PropertySubClassDescription_Clear bit = 0,
    @PropertySubClassDescription nvarchar(64) = NULL,
    @AssessedLandAV_Clear bit = 0,
    @AssessedLandAV decimal(14, 2) = NULL,
    @AssessedImprovementAV_Clear bit = 0,
    @AssessedImprovementAV decimal(14, 2) = NULL,
    @AssessedTotalAV_Clear bit = 0,
    @AssessedTotalAV decimal(14, 2) = NULL,
    @CountyParcelID_Clear bit = 0,
    @CountyParcelID nvarchar(50) = NULL,
    @Neighborhood_Clear bit = 0,
    @Neighborhood nvarchar(32) = NULL,
    @TaxDistrictID_Clear bit = 0,
    @TaxDistrictID nvarchar(5) = NULL,
    @LegalDescription_Clear bit = 0,
    @LegalDescription nvarchar(1500) = NULL,
    @Acreage_Clear bit = 0,
    @Acreage nvarchar(10) = NULL,
    @EstimatedSqFt_Clear bit = 0,
    @EstimatedSqFt int = NULL,
    @Status_Clear bit = 0,
    @Status nvarchar(8) = NULL,
    @SourceModDate_Clear bit = 0,
    @SourceModDate datetimeoffset = NULL,
    @RetrievedAt datetimeoffset = NULL,
    @SourceRegistryID_Clear bit = 0,
    @SourceRegistryID uniqueidentifier = NULL,
    @YearBuilt_Clear bit = 0,
    @YearBuilt smallint = NULL,
    @LastAssessmentChangeDate_Clear bit = 0,
    @LastAssessmentChangeDate date = NULL,
    @TaxYear_Clear bit = 0,
    @TaxYear smallint = NULL,
    @GrossAssessment_Clear bit = 0,
    @GrossAssessment decimal(14, 2) = NULL,
    @DeductionsExemptionsTotal_Clear bit = 0,
    @DeductionsExemptionsTotal decimal(14, 2) = NULL,
    @NetAssessment_Clear bit = 0,
    @NetAssessment decimal(14, 2) = NULL,
    @TaxRate_Clear bit = 0,
    @TaxRate decimal(9, 6) = NULL,
    @NetAnnualTax_Clear bit = 0,
    @NetAnnualTax decimal(14, 2) = NULL,
    @CurrentTaxDue_Clear bit = 0,
    @CurrentTaxDue decimal(14, 2) = NULL,
    @DeedType_Clear bit = 0,
    @DeedType nvarchar(50) = NULL,
    @DeedDate_Clear bit = 0,
    @DeedDate date = NULL,
    @FileDate_Clear bit = 0,
    @FileDate date = NULL,
    @ReportRetrievedAt_Clear bit = 0,
    @ReportRetrievedAt datetimeoffset = NULL,
    @SqFtSource_Clear bit = 0,
    @SqFtSource nvarchar(20) = NULL,
    @SourceDocumentID_Clear bit = 0,
    @SourceDocumentID uniqueidentifier = NULL,
    @TaxHistorySourceDocumentID_Clear bit = 0,
    @TaxHistorySourceDocumentID uniqueidentifier = NULL,
    @ComparisonUnitType_Clear bit = 0,
    @ComparisonUnitType nvarchar(20) = NULL,
    @ComparisonUnitCount_Clear bit = 0,
    @ComparisonUnitCount decimal(10, 2) = NULL,
    @CoStarYearBuilt_Clear bit = 0,
    @CoStarYearBuilt smallint = NULL,
    @CoStarRBA_Clear bit = 0,
    @CoStarRBA int = NULL,
    @RevisionForm_Clear bit = 0,
    @RevisionForm smallint = NULL,
    @RevisionReason_Clear bit = 0,
    @RevisionReason nvarchar(50) = NULL,
    @RevisionAsOfDate_Clear bit = 0,
    @RevisionAsOfDate date = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[CountyAssessorRecord]
            (
                [ID],
                [ParcelID],
                [CountyNumber],
                [OwnerName],
                [OwnerAddress],
                [OwnerCity],
                [OwnerState],
                [OwnerZip],
                [PropertyClass],
                [PropertySubClassDescription],
                [AssessedLandAV],
                [AssessedImprovementAV],
                [AssessedTotalAV],
                [CountyParcelID],
                [Neighborhood],
                [TaxDistrictID],
                [LegalDescription],
                [Acreage],
                [EstimatedSqFt],
                [Status],
                [SourceModDate],
                [RetrievedAt],
                [SourceRegistryID],
                [YearBuilt],
                [LastAssessmentChangeDate],
                [TaxYear],
                [GrossAssessment],
                [DeductionsExemptionsTotal],
                [NetAssessment],
                [TaxRate],
                [NetAnnualTax],
                [CurrentTaxDue],
                [DeedType],
                [DeedDate],
                [FileDate],
                [ReportRetrievedAt],
                [SqFtSource],
                [SourceDocumentID],
                [TaxHistorySourceDocumentID],
                [ComparisonUnitType],
                [ComparisonUnitCount],
                [CoStarYearBuilt],
                [CoStarRBA],
                [RevisionForm],
                [RevisionReason],
                [RevisionAsOfDate]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @ParcelID,
                @CountyNumber,
                CASE WHEN @OwnerName_Clear = 1 THEN NULL ELSE ISNULL(@OwnerName, NULL) END,
                CASE WHEN @OwnerAddress_Clear = 1 THEN NULL ELSE ISNULL(@OwnerAddress, NULL) END,
                CASE WHEN @OwnerCity_Clear = 1 THEN NULL ELSE ISNULL(@OwnerCity, NULL) END,
                CASE WHEN @OwnerState_Clear = 1 THEN NULL ELSE ISNULL(@OwnerState, NULL) END,
                CASE WHEN @OwnerZip_Clear = 1 THEN NULL ELSE ISNULL(@OwnerZip, NULL) END,
                CASE WHEN @PropertyClass_Clear = 1 THEN NULL ELSE ISNULL(@PropertyClass, NULL) END,
                CASE WHEN @PropertySubClassDescription_Clear = 1 THEN NULL ELSE ISNULL(@PropertySubClassDescription, NULL) END,
                CASE WHEN @AssessedLandAV_Clear = 1 THEN NULL ELSE ISNULL(@AssessedLandAV, NULL) END,
                CASE WHEN @AssessedImprovementAV_Clear = 1 THEN NULL ELSE ISNULL(@AssessedImprovementAV, NULL) END,
                CASE WHEN @AssessedTotalAV_Clear = 1 THEN NULL ELSE ISNULL(@AssessedTotalAV, NULL) END,
                CASE WHEN @CountyParcelID_Clear = 1 THEN NULL ELSE ISNULL(@CountyParcelID, NULL) END,
                CASE WHEN @Neighborhood_Clear = 1 THEN NULL ELSE ISNULL(@Neighborhood, NULL) END,
                CASE WHEN @TaxDistrictID_Clear = 1 THEN NULL ELSE ISNULL(@TaxDistrictID, NULL) END,
                CASE WHEN @LegalDescription_Clear = 1 THEN NULL ELSE ISNULL(@LegalDescription, NULL) END,
                CASE WHEN @Acreage_Clear = 1 THEN NULL ELSE ISNULL(@Acreage, NULL) END,
                CASE WHEN @EstimatedSqFt_Clear = 1 THEN NULL ELSE ISNULL(@EstimatedSqFt, NULL) END,
                CASE WHEN @Status_Clear = 1 THEN NULL ELSE ISNULL(@Status, NULL) END,
                CASE WHEN @SourceModDate_Clear = 1 THEN NULL ELSE ISNULL(@SourceModDate, NULL) END,
                ISNULL(@RetrievedAt, sysdatetimeoffset()),
                CASE WHEN @SourceRegistryID_Clear = 1 THEN NULL ELSE ISNULL(@SourceRegistryID, NULL) END,
                CASE WHEN @YearBuilt_Clear = 1 THEN NULL ELSE ISNULL(@YearBuilt, NULL) END,
                CASE WHEN @LastAssessmentChangeDate_Clear = 1 THEN NULL ELSE ISNULL(@LastAssessmentChangeDate, NULL) END,
                CASE WHEN @TaxYear_Clear = 1 THEN NULL ELSE ISNULL(@TaxYear, NULL) END,
                CASE WHEN @GrossAssessment_Clear = 1 THEN NULL ELSE ISNULL(@GrossAssessment, NULL) END,
                CASE WHEN @DeductionsExemptionsTotal_Clear = 1 THEN NULL ELSE ISNULL(@DeductionsExemptionsTotal, NULL) END,
                CASE WHEN @NetAssessment_Clear = 1 THEN NULL ELSE ISNULL(@NetAssessment, NULL) END,
                CASE WHEN @TaxRate_Clear = 1 THEN NULL ELSE ISNULL(@TaxRate, NULL) END,
                CASE WHEN @NetAnnualTax_Clear = 1 THEN NULL ELSE ISNULL(@NetAnnualTax, NULL) END,
                CASE WHEN @CurrentTaxDue_Clear = 1 THEN NULL ELSE ISNULL(@CurrentTaxDue, NULL) END,
                CASE WHEN @DeedType_Clear = 1 THEN NULL ELSE ISNULL(@DeedType, NULL) END,
                CASE WHEN @DeedDate_Clear = 1 THEN NULL ELSE ISNULL(@DeedDate, NULL) END,
                CASE WHEN @FileDate_Clear = 1 THEN NULL ELSE ISNULL(@FileDate, NULL) END,
                CASE WHEN @ReportRetrievedAt_Clear = 1 THEN NULL ELSE ISNULL(@ReportRetrievedAt, NULL) END,
                CASE WHEN @SqFtSource_Clear = 1 THEN NULL ELSE ISNULL(@SqFtSource, NULL) END,
                CASE WHEN @SourceDocumentID_Clear = 1 THEN NULL ELSE ISNULL(@SourceDocumentID, NULL) END,
                CASE WHEN @TaxHistorySourceDocumentID_Clear = 1 THEN NULL ELSE ISNULL(@TaxHistorySourceDocumentID, NULL) END,
                CASE WHEN @ComparisonUnitType_Clear = 1 THEN NULL ELSE ISNULL(@ComparisonUnitType, NULL) END,
                CASE WHEN @ComparisonUnitCount_Clear = 1 THEN NULL ELSE ISNULL(@ComparisonUnitCount, NULL) END,
                CASE WHEN @CoStarYearBuilt_Clear = 1 THEN NULL ELSE ISNULL(@CoStarYearBuilt, NULL) END,
                CASE WHEN @CoStarRBA_Clear = 1 THEN NULL ELSE ISNULL(@CoStarRBA, NULL) END,
                CASE WHEN @RevisionForm_Clear = 1 THEN NULL ELSE ISNULL(@RevisionForm, NULL) END,
                CASE WHEN @RevisionReason_Clear = 1 THEN NULL ELSE ISNULL(@RevisionReason, NULL) END,
                CASE WHEN @RevisionAsOfDate_Clear = 1 THEN NULL ELSE ISNULL(@RevisionAsOfDate, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[CountyAssessorRecord]
            (
                [ParcelID],
                [CountyNumber],
                [OwnerName],
                [OwnerAddress],
                [OwnerCity],
                [OwnerState],
                [OwnerZip],
                [PropertyClass],
                [PropertySubClassDescription],
                [AssessedLandAV],
                [AssessedImprovementAV],
                [AssessedTotalAV],
                [CountyParcelID],
                [Neighborhood],
                [TaxDistrictID],
                [LegalDescription],
                [Acreage],
                [EstimatedSqFt],
                [Status],
                [SourceModDate],
                [RetrievedAt],
                [SourceRegistryID],
                [YearBuilt],
                [LastAssessmentChangeDate],
                [TaxYear],
                [GrossAssessment],
                [DeductionsExemptionsTotal],
                [NetAssessment],
                [TaxRate],
                [NetAnnualTax],
                [CurrentTaxDue],
                [DeedType],
                [DeedDate],
                [FileDate],
                [ReportRetrievedAt],
                [SqFtSource],
                [SourceDocumentID],
                [TaxHistorySourceDocumentID],
                [ComparisonUnitType],
                [ComparisonUnitCount],
                [CoStarYearBuilt],
                [CoStarRBA],
                [RevisionForm],
                [RevisionReason],
                [RevisionAsOfDate]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ParcelID,
                @CountyNumber,
                CASE WHEN @OwnerName_Clear = 1 THEN NULL ELSE ISNULL(@OwnerName, NULL) END,
                CASE WHEN @OwnerAddress_Clear = 1 THEN NULL ELSE ISNULL(@OwnerAddress, NULL) END,
                CASE WHEN @OwnerCity_Clear = 1 THEN NULL ELSE ISNULL(@OwnerCity, NULL) END,
                CASE WHEN @OwnerState_Clear = 1 THEN NULL ELSE ISNULL(@OwnerState, NULL) END,
                CASE WHEN @OwnerZip_Clear = 1 THEN NULL ELSE ISNULL(@OwnerZip, NULL) END,
                CASE WHEN @PropertyClass_Clear = 1 THEN NULL ELSE ISNULL(@PropertyClass, NULL) END,
                CASE WHEN @PropertySubClassDescription_Clear = 1 THEN NULL ELSE ISNULL(@PropertySubClassDescription, NULL) END,
                CASE WHEN @AssessedLandAV_Clear = 1 THEN NULL ELSE ISNULL(@AssessedLandAV, NULL) END,
                CASE WHEN @AssessedImprovementAV_Clear = 1 THEN NULL ELSE ISNULL(@AssessedImprovementAV, NULL) END,
                CASE WHEN @AssessedTotalAV_Clear = 1 THEN NULL ELSE ISNULL(@AssessedTotalAV, NULL) END,
                CASE WHEN @CountyParcelID_Clear = 1 THEN NULL ELSE ISNULL(@CountyParcelID, NULL) END,
                CASE WHEN @Neighborhood_Clear = 1 THEN NULL ELSE ISNULL(@Neighborhood, NULL) END,
                CASE WHEN @TaxDistrictID_Clear = 1 THEN NULL ELSE ISNULL(@TaxDistrictID, NULL) END,
                CASE WHEN @LegalDescription_Clear = 1 THEN NULL ELSE ISNULL(@LegalDescription, NULL) END,
                CASE WHEN @Acreage_Clear = 1 THEN NULL ELSE ISNULL(@Acreage, NULL) END,
                CASE WHEN @EstimatedSqFt_Clear = 1 THEN NULL ELSE ISNULL(@EstimatedSqFt, NULL) END,
                CASE WHEN @Status_Clear = 1 THEN NULL ELSE ISNULL(@Status, NULL) END,
                CASE WHEN @SourceModDate_Clear = 1 THEN NULL ELSE ISNULL(@SourceModDate, NULL) END,
                ISNULL(@RetrievedAt, sysdatetimeoffset()),
                CASE WHEN @SourceRegistryID_Clear = 1 THEN NULL ELSE ISNULL(@SourceRegistryID, NULL) END,
                CASE WHEN @YearBuilt_Clear = 1 THEN NULL ELSE ISNULL(@YearBuilt, NULL) END,
                CASE WHEN @LastAssessmentChangeDate_Clear = 1 THEN NULL ELSE ISNULL(@LastAssessmentChangeDate, NULL) END,
                CASE WHEN @TaxYear_Clear = 1 THEN NULL ELSE ISNULL(@TaxYear, NULL) END,
                CASE WHEN @GrossAssessment_Clear = 1 THEN NULL ELSE ISNULL(@GrossAssessment, NULL) END,
                CASE WHEN @DeductionsExemptionsTotal_Clear = 1 THEN NULL ELSE ISNULL(@DeductionsExemptionsTotal, NULL) END,
                CASE WHEN @NetAssessment_Clear = 1 THEN NULL ELSE ISNULL(@NetAssessment, NULL) END,
                CASE WHEN @TaxRate_Clear = 1 THEN NULL ELSE ISNULL(@TaxRate, NULL) END,
                CASE WHEN @NetAnnualTax_Clear = 1 THEN NULL ELSE ISNULL(@NetAnnualTax, NULL) END,
                CASE WHEN @CurrentTaxDue_Clear = 1 THEN NULL ELSE ISNULL(@CurrentTaxDue, NULL) END,
                CASE WHEN @DeedType_Clear = 1 THEN NULL ELSE ISNULL(@DeedType, NULL) END,
                CASE WHEN @DeedDate_Clear = 1 THEN NULL ELSE ISNULL(@DeedDate, NULL) END,
                CASE WHEN @FileDate_Clear = 1 THEN NULL ELSE ISNULL(@FileDate, NULL) END,
                CASE WHEN @ReportRetrievedAt_Clear = 1 THEN NULL ELSE ISNULL(@ReportRetrievedAt, NULL) END,
                CASE WHEN @SqFtSource_Clear = 1 THEN NULL ELSE ISNULL(@SqFtSource, NULL) END,
                CASE WHEN @SourceDocumentID_Clear = 1 THEN NULL ELSE ISNULL(@SourceDocumentID, NULL) END,
                CASE WHEN @TaxHistorySourceDocumentID_Clear = 1 THEN NULL ELSE ISNULL(@TaxHistorySourceDocumentID, NULL) END,
                CASE WHEN @ComparisonUnitType_Clear = 1 THEN NULL ELSE ISNULL(@ComparisonUnitType, NULL) END,
                CASE WHEN @ComparisonUnitCount_Clear = 1 THEN NULL ELSE ISNULL(@ComparisonUnitCount, NULL) END,
                CASE WHEN @CoStarYearBuilt_Clear = 1 THEN NULL ELSE ISNULL(@CoStarYearBuilt, NULL) END,
                CASE WHEN @CoStarRBA_Clear = 1 THEN NULL ELSE ISNULL(@CoStarRBA, NULL) END,
                CASE WHEN @RevisionForm_Clear = 1 THEN NULL ELSE ISNULL(@RevisionForm, NULL) END,
                CASE WHEN @RevisionReason_Clear = 1 THEN NULL ELSE ISNULL(@RevisionReason, NULL) END,
                CASE WHEN @RevisionAsOfDate_Clear = 1 THEN NULL ELSE ISNULL(@RevisionAsOfDate, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwCountyAssessorRecords] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateCountyAssessorRecord] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for County Assessor Records */

GRANT EXECUTE ON [indiana_tax].[spCreateCountyAssessorRecord] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for County Assessor Records */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: County Assessor Records
-- Item: spUpdateCountyAssessorRecord
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR CountyAssessorRecord
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateCountyAssessorRecord]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateCountyAssessorRecord];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateCountyAssessorRecord]
    @ID uniqueidentifier,
    @ParcelID uniqueidentifier = NULL,
    @CountyNumber smallint = NULL,
    @OwnerName_Clear bit = 0,
    @OwnerName nvarchar(500) = NULL,
    @OwnerAddress_Clear bit = 0,
    @OwnerAddress nvarchar(200) = NULL,
    @OwnerCity_Clear bit = 0,
    @OwnerCity nvarchar(100) = NULL,
    @OwnerState_Clear bit = 0,
    @OwnerState nvarchar(10) = NULL,
    @OwnerZip_Clear bit = 0,
    @OwnerZip nvarchar(20) = NULL,
    @PropertyClass_Clear bit = 0,
    @PropertyClass nvarchar(32) = NULL,
    @PropertySubClassDescription_Clear bit = 0,
    @PropertySubClassDescription nvarchar(64) = NULL,
    @AssessedLandAV_Clear bit = 0,
    @AssessedLandAV decimal(14, 2) = NULL,
    @AssessedImprovementAV_Clear bit = 0,
    @AssessedImprovementAV decimal(14, 2) = NULL,
    @AssessedTotalAV_Clear bit = 0,
    @AssessedTotalAV decimal(14, 2) = NULL,
    @CountyParcelID_Clear bit = 0,
    @CountyParcelID nvarchar(50) = NULL,
    @Neighborhood_Clear bit = 0,
    @Neighborhood nvarchar(32) = NULL,
    @TaxDistrictID_Clear bit = 0,
    @TaxDistrictID nvarchar(5) = NULL,
    @LegalDescription_Clear bit = 0,
    @LegalDescription nvarchar(1500) = NULL,
    @Acreage_Clear bit = 0,
    @Acreage nvarchar(10) = NULL,
    @EstimatedSqFt_Clear bit = 0,
    @EstimatedSqFt int = NULL,
    @Status_Clear bit = 0,
    @Status nvarchar(8) = NULL,
    @SourceModDate_Clear bit = 0,
    @SourceModDate datetimeoffset = NULL,
    @RetrievedAt datetimeoffset = NULL,
    @SourceRegistryID_Clear bit = 0,
    @SourceRegistryID uniqueidentifier = NULL,
    @YearBuilt_Clear bit = 0,
    @YearBuilt smallint = NULL,
    @LastAssessmentChangeDate_Clear bit = 0,
    @LastAssessmentChangeDate date = NULL,
    @TaxYear_Clear bit = 0,
    @TaxYear smallint = NULL,
    @GrossAssessment_Clear bit = 0,
    @GrossAssessment decimal(14, 2) = NULL,
    @DeductionsExemptionsTotal_Clear bit = 0,
    @DeductionsExemptionsTotal decimal(14, 2) = NULL,
    @NetAssessment_Clear bit = 0,
    @NetAssessment decimal(14, 2) = NULL,
    @TaxRate_Clear bit = 0,
    @TaxRate decimal(9, 6) = NULL,
    @NetAnnualTax_Clear bit = 0,
    @NetAnnualTax decimal(14, 2) = NULL,
    @CurrentTaxDue_Clear bit = 0,
    @CurrentTaxDue decimal(14, 2) = NULL,
    @DeedType_Clear bit = 0,
    @DeedType nvarchar(50) = NULL,
    @DeedDate_Clear bit = 0,
    @DeedDate date = NULL,
    @FileDate_Clear bit = 0,
    @FileDate date = NULL,
    @ReportRetrievedAt_Clear bit = 0,
    @ReportRetrievedAt datetimeoffset = NULL,
    @SqFtSource_Clear bit = 0,
    @SqFtSource nvarchar(20) = NULL,
    @SourceDocumentID_Clear bit = 0,
    @SourceDocumentID uniqueidentifier = NULL,
    @TaxHistorySourceDocumentID_Clear bit = 0,
    @TaxHistorySourceDocumentID uniqueidentifier = NULL,
    @ComparisonUnitType_Clear bit = 0,
    @ComparisonUnitType nvarchar(20) = NULL,
    @ComparisonUnitCount_Clear bit = 0,
    @ComparisonUnitCount decimal(10, 2) = NULL,
    @CoStarYearBuilt_Clear bit = 0,
    @CoStarYearBuilt smallint = NULL,
    @CoStarRBA_Clear bit = 0,
    @CoStarRBA int = NULL,
    @RevisionForm_Clear bit = 0,
    @RevisionForm smallint = NULL,
    @RevisionReason_Clear bit = 0,
    @RevisionReason nvarchar(50) = NULL,
    @RevisionAsOfDate_Clear bit = 0,
    @RevisionAsOfDate date = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[CountyAssessorRecord]
    SET
        [ParcelID] = ISNULL(@ParcelID, [ParcelID]),
        [CountyNumber] = ISNULL(@CountyNumber, [CountyNumber]),
        [OwnerName] = CASE WHEN @OwnerName_Clear = 1 THEN NULL ELSE ISNULL(@OwnerName, [OwnerName]) END,
        [OwnerAddress] = CASE WHEN @OwnerAddress_Clear = 1 THEN NULL ELSE ISNULL(@OwnerAddress, [OwnerAddress]) END,
        [OwnerCity] = CASE WHEN @OwnerCity_Clear = 1 THEN NULL ELSE ISNULL(@OwnerCity, [OwnerCity]) END,
        [OwnerState] = CASE WHEN @OwnerState_Clear = 1 THEN NULL ELSE ISNULL(@OwnerState, [OwnerState]) END,
        [OwnerZip] = CASE WHEN @OwnerZip_Clear = 1 THEN NULL ELSE ISNULL(@OwnerZip, [OwnerZip]) END,
        [PropertyClass] = CASE WHEN @PropertyClass_Clear = 1 THEN NULL ELSE ISNULL(@PropertyClass, [PropertyClass]) END,
        [PropertySubClassDescription] = CASE WHEN @PropertySubClassDescription_Clear = 1 THEN NULL ELSE ISNULL(@PropertySubClassDescription, [PropertySubClassDescription]) END,
        [AssessedLandAV] = CASE WHEN @AssessedLandAV_Clear = 1 THEN NULL ELSE ISNULL(@AssessedLandAV, [AssessedLandAV]) END,
        [AssessedImprovementAV] = CASE WHEN @AssessedImprovementAV_Clear = 1 THEN NULL ELSE ISNULL(@AssessedImprovementAV, [AssessedImprovementAV]) END,
        [AssessedTotalAV] = CASE WHEN @AssessedTotalAV_Clear = 1 THEN NULL ELSE ISNULL(@AssessedTotalAV, [AssessedTotalAV]) END,
        [CountyParcelID] = CASE WHEN @CountyParcelID_Clear = 1 THEN NULL ELSE ISNULL(@CountyParcelID, [CountyParcelID]) END,
        [Neighborhood] = CASE WHEN @Neighborhood_Clear = 1 THEN NULL ELSE ISNULL(@Neighborhood, [Neighborhood]) END,
        [TaxDistrictID] = CASE WHEN @TaxDistrictID_Clear = 1 THEN NULL ELSE ISNULL(@TaxDistrictID, [TaxDistrictID]) END,
        [LegalDescription] = CASE WHEN @LegalDescription_Clear = 1 THEN NULL ELSE ISNULL(@LegalDescription, [LegalDescription]) END,
        [Acreage] = CASE WHEN @Acreage_Clear = 1 THEN NULL ELSE ISNULL(@Acreage, [Acreage]) END,
        [EstimatedSqFt] = CASE WHEN @EstimatedSqFt_Clear = 1 THEN NULL ELSE ISNULL(@EstimatedSqFt, [EstimatedSqFt]) END,
        [Status] = CASE WHEN @Status_Clear = 1 THEN NULL ELSE ISNULL(@Status, [Status]) END,
        [SourceModDate] = CASE WHEN @SourceModDate_Clear = 1 THEN NULL ELSE ISNULL(@SourceModDate, [SourceModDate]) END,
        [RetrievedAt] = ISNULL(@RetrievedAt, [RetrievedAt]),
        [SourceRegistryID] = CASE WHEN @SourceRegistryID_Clear = 1 THEN NULL ELSE ISNULL(@SourceRegistryID, [SourceRegistryID]) END,
        [YearBuilt] = CASE WHEN @YearBuilt_Clear = 1 THEN NULL ELSE ISNULL(@YearBuilt, [YearBuilt]) END,
        [LastAssessmentChangeDate] = CASE WHEN @LastAssessmentChangeDate_Clear = 1 THEN NULL ELSE ISNULL(@LastAssessmentChangeDate, [LastAssessmentChangeDate]) END,
        [TaxYear] = CASE WHEN @TaxYear_Clear = 1 THEN NULL ELSE ISNULL(@TaxYear, [TaxYear]) END,
        [GrossAssessment] = CASE WHEN @GrossAssessment_Clear = 1 THEN NULL ELSE ISNULL(@GrossAssessment, [GrossAssessment]) END,
        [DeductionsExemptionsTotal] = CASE WHEN @DeductionsExemptionsTotal_Clear = 1 THEN NULL ELSE ISNULL(@DeductionsExemptionsTotal, [DeductionsExemptionsTotal]) END,
        [NetAssessment] = CASE WHEN @NetAssessment_Clear = 1 THEN NULL ELSE ISNULL(@NetAssessment, [NetAssessment]) END,
        [TaxRate] = CASE WHEN @TaxRate_Clear = 1 THEN NULL ELSE ISNULL(@TaxRate, [TaxRate]) END,
        [NetAnnualTax] = CASE WHEN @NetAnnualTax_Clear = 1 THEN NULL ELSE ISNULL(@NetAnnualTax, [NetAnnualTax]) END,
        [CurrentTaxDue] = CASE WHEN @CurrentTaxDue_Clear = 1 THEN NULL ELSE ISNULL(@CurrentTaxDue, [CurrentTaxDue]) END,
        [DeedType] = CASE WHEN @DeedType_Clear = 1 THEN NULL ELSE ISNULL(@DeedType, [DeedType]) END,
        [DeedDate] = CASE WHEN @DeedDate_Clear = 1 THEN NULL ELSE ISNULL(@DeedDate, [DeedDate]) END,
        [FileDate] = CASE WHEN @FileDate_Clear = 1 THEN NULL ELSE ISNULL(@FileDate, [FileDate]) END,
        [ReportRetrievedAt] = CASE WHEN @ReportRetrievedAt_Clear = 1 THEN NULL ELSE ISNULL(@ReportRetrievedAt, [ReportRetrievedAt]) END,
        [SqFtSource] = CASE WHEN @SqFtSource_Clear = 1 THEN NULL ELSE ISNULL(@SqFtSource, [SqFtSource]) END,
        [SourceDocumentID] = CASE WHEN @SourceDocumentID_Clear = 1 THEN NULL ELSE ISNULL(@SourceDocumentID, [SourceDocumentID]) END,
        [TaxHistorySourceDocumentID] = CASE WHEN @TaxHistorySourceDocumentID_Clear = 1 THEN NULL ELSE ISNULL(@TaxHistorySourceDocumentID, [TaxHistorySourceDocumentID]) END,
        [ComparisonUnitType] = CASE WHEN @ComparisonUnitType_Clear = 1 THEN NULL ELSE ISNULL(@ComparisonUnitType, [ComparisonUnitType]) END,
        [ComparisonUnitCount] = CASE WHEN @ComparisonUnitCount_Clear = 1 THEN NULL ELSE ISNULL(@ComparisonUnitCount, [ComparisonUnitCount]) END,
        [CoStarYearBuilt] = CASE WHEN @CoStarYearBuilt_Clear = 1 THEN NULL ELSE ISNULL(@CoStarYearBuilt, [CoStarYearBuilt]) END,
        [CoStarRBA] = CASE WHEN @CoStarRBA_Clear = 1 THEN NULL ELSE ISNULL(@CoStarRBA, [CoStarRBA]) END,
        [RevisionForm] = CASE WHEN @RevisionForm_Clear = 1 THEN NULL ELSE ISNULL(@RevisionForm, [RevisionForm]) END,
        [RevisionReason] = CASE WHEN @RevisionReason_Clear = 1 THEN NULL ELSE ISNULL(@RevisionReason, [RevisionReason]) END,
        [RevisionAsOfDate] = CASE WHEN @RevisionAsOfDate_Clear = 1 THEN NULL ELSE ISNULL(@RevisionAsOfDate, [RevisionAsOfDate]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwCountyAssessorRecords] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwCountyAssessorRecords]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateCountyAssessorRecord] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the CountyAssessorRecord table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateCountyAssessorRecord]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateCountyAssessorRecord];
GO
CREATE TRIGGER [indiana_tax].trgUpdateCountyAssessorRecord
ON [indiana_tax].[CountyAssessorRecord]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[CountyAssessorRecord]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[CountyAssessorRecord] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for County Assessor Records */

GRANT EXECUTE ON [indiana_tax].[spUpdateCountyAssessorRecord] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for County Assessor Records */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: County Assessor Records
-- Item: spDeleteCountyAssessorRecord
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR CountyAssessorRecord
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteCountyAssessorRecord]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteCountyAssessorRecord];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteCountyAssessorRecord]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[CountyAssessorRecord]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteCountyAssessorRecord] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for County Assessor Records */

GRANT EXECUTE ON [indiana_tax].[spDeleteCountyAssessorRecord] TO [cdp_Developer], [cdp_Integration];

/* Set field properties for entity */

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '2A35024D-EA9C-4755-814D-7D6C59538464'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'Exact'
               WHERE ID = '430DC138-34FF-44D8-B896-E858E3C249E9'
               AND AutoUpdateUserSearchPredicate = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'Exact'
               WHERE ID = 'B8DBBE0B-0F67-42C1-9E17-849B92D479BD'
               AND AutoUpdateUserSearchPredicate = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = '2A35024D-EA9C-4755-814D-7D6C59538464'
               AND AutoUpdateUserSearchPredicate = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'Exact'
               WHERE ID = '0A3F512D-169B-4B7F-912A-2E9FA2F8C356'
               AND AutoUpdateUserSearchPredicate = 1;

/* Set field properties for entity */

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = '53EDF39B-AC09-436A-8019-43453AE834AD'
               AND AutoUpdateUserSearchPredicate = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'Contains'
               WHERE ID = '57AE271B-AF4B-4719-A650-D447A7E1BEA7'
               AND AutoUpdateUserSearchPredicate = 1;

/* Set categories for 18 fields */

-- UPDATE Entity Field Category Info Assessments.ID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '0A314C29-9B09-4EB9-9E18-23B84233C466' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Assessments.ParcelID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '5F02DE23-CF10-4E19-8D6A-A82A9FAC4B31' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Assessments.AssessmentYear 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '7E8E850B-72BF-4D60-8462-779002D508C8' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Assessments.Source 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '1A46666D-128B-4BC1-93E1-D6202CB98FB2' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Assessments.PropertyClassCode 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = 'Code',
   CodeType = 'Other'
WHERE 
   ID = '25A302BE-7E20-4718-913F-97C217E3783C' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Assessments.SourceDocumentID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'FFB91F5D-C618-4699-91A4-279F1CC9AEE4' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Assessments.Parcel 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   DisplayName = 'Parcel Number',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'AF12952F-7B35-412C-9FE0-BAA520C32FB5' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Assessments.OriginalLandAV 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   DisplayName = 'Original Land Value',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'FF2B4F02-C4D9-44AB-B760-D9F0E2256028' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Assessments.OriginalImprovementAV 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   DisplayName = 'Original Improvement Value',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '4B3199DE-B8D9-4FDE-A92E-619F2542B880' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Assessments.OriginalTotalAV 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   DisplayName = 'Original Total Value',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'BE4304E6-4F94-451D-A3D5-4E2FAD20253C' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Assessments.PTABOALandAV 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   DisplayName = 'PTABOA Land Value',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '1E289D9B-C584-444D-BD26-8BAAA6DDB48E' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Assessments.PTABOAImprovementAV 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   DisplayName = 'PTABOA Improvement Value',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'BC9AA655-7C40-4CD9-B7F5-97127A2D8BA1' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Assessments.PTABOATotalAV 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   DisplayName = 'PTABOA Total Value',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '1328EFFB-2C80-4993-84EE-373FAB4C41A0' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Assessments.RevisionForm 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Appeal Revision Details',
   GeneratedFormSection = 'Category',
   ExtendedType = 'Code',
   CodeType = 'Other'
WHERE 
   ID = 'C5B2AE84-6530-4C6F-89D3-0BDC0D8D48FB' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Assessments.RevisionReason 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Appeal Revision Details',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'D6E272A2-B3A1-4BD4-A57C-936BED03AE33' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Assessments.RevisionAsOfDate 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Appeal Revision Details',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'B75AEABE-1348-4097-9094-BB3F87370DCE' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Assessments.__mj_CreatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'BA09727C-312C-44B6-828B-EA8ABA30FE4A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Assessments.__mj_UpdatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '268F4ED1-44F5-4028-91B4-A5A907C932D0' AND AutoUpdateCategory = 1;

/* Update FieldCategoryInfo setting for entity */

               UPDATE [${flyway:defaultSchema}].[EntitySetting]
               SET [Value] = '{"Appeal Revision Details":{"icon":"fa fa-edit","description":"Details about PTABOA appeal revisions including form type, reason, and effective date"}}', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [EntityID] = '4AB7D5DF-8D95-4897-BC26-1FEA542669EF' AND [Name] = 'FieldCategoryInfo';

/* Update FieldCategoryIcons setting (legacy) */

               UPDATE [${flyway:defaultSchema}].[EntitySetting]
               SET [Value] = '{"Appeal Revision Details":"fa fa-edit"}', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [EntityID] = '4AB7D5DF-8D95-4897-BC26-1FEA542669EF' AND [Name] = 'FieldCategoryIcons';

/* Set categories for 14 fields */

-- UPDATE Entity Field Category Info Card Notes.ID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '05079A7B-8AEF-4EC6-8751-975763AA280A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Notes.SourceDocumentID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   DisplayName = 'Source Document',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '0FD11AB2-F6D4-4940-8037-3E8A88C1386E' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Notes.__mj_CreatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '7A27B4D3-432A-4FBC-8031-BE19DC42A6C0' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Notes.__mj_UpdatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '3B62DB10-FA52-41BC-A386-53DE6D511584' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Notes.NoteKey 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'A6FF0D12-6E4D-4EF5-AB40-DFB4FB9C7B24' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Notes.ParcelID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'D6D5C679-C93C-492A-BA98-9B9DAD50B7C3' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Notes.CardAssessmentYear 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   DisplayName = 'Card Assessment Year',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'FCE9A16E-8252-496B-AB45-FD001BA93B91' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Notes.Parcel 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '17B0EA6D-BCB1-4329-9492-6E2792C7AC82' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Notes.EntryIndex 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'D7467401-3359-4E82-AACF-DBF7043DF75B' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Notes.NoteDate 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '8B9C49F1-FC25-4EAD-AB63-64165F38A557' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Notes.NoteCode 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = 'Code',
   CodeType = 'Other'
WHERE 
   ID = '623E8CA7-C500-4516-A3B2-910F9065B163' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Notes.NoteKind 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '4AFE50C1-CD14-4BFB-897C-8076B5CF3F85' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Notes.NoteText 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '58578383-699C-4259-908A-6857C59BD146' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Notes.NoteForm 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Note Content',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '2B56E20E-50DC-48D5-9638-CB5A174B73BF' AND AutoUpdateCategory = 1;

/* Update FieldCategoryInfo setting for entity */

               UPDATE [${flyway:defaultSchema}].[EntitySetting]
               SET [Value] = '{"Note Content":{"icon":"fa fa-align-left","description":"Note text content, date, classification codes, and referenced tax forms"}}', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [EntityID] = '2A7BD138-666D-4835-B591-256380F7775B' AND [Name] = 'FieldCategoryInfo';

/* Update FieldCategoryIcons setting (legacy) */

               UPDATE [${flyway:defaultSchema}].[EntitySetting]
               SET [Value] = '{"Note Content":"fa fa-align-left"}', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [EntityID] = '2A7BD138-666D-4835-B591-256380F7775B' AND [Name] = 'FieldCategoryIcons';

/* Set categories for 27 fields */

-- UPDATE Entity Field Category Info Card Valuation Columns.ID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '7B56E5B2-7E28-4B70-8A35-85DA9EE85C0F' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.SourceDocumentID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '2861EBD4-57C4-4C8D-B289-6A11F438E714' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.ParcelID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   DisplayName = 'Parcel ID',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '0A3F512D-169B-4B7F-912A-2E9FA2F8C356' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.Parcel 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   DisplayName = 'Parcel',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '9D46942D-0C28-4596-A605-B733E422271A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.CardAssessmentYear 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '430DC138-34FF-44D8-B896-E858E3C249E9' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.ColumnIndex 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'F4F23FD4-04A3-4C38-937D-EA51E5595B7A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.AssessmentYear 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'B8DBBE0B-0F67-42C1-9E17-849B92D479BD' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.IsCertified 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   DisplayName = 'Certified',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '70E4A8E8-5A30-4172-8774-81DBCAE4384B' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.AsOfDate 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'AE5E1636-3D66-4F13-847E-4006EBEE5DF0' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.ReasonForChange 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   DisplayName = 'Reason For Change',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '2A35024D-EA9C-4755-814D-7D6C59538464' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.ReasonKind 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'B4E841AA-EF47-46F8-8601-32E789DCEC45' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.ReasonForm 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Valuation Changes',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '3AC9DEE0-03BE-4CE6-9CDA-B1D0E788176F' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.ValuationMethod 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '73926FC0-9F95-4BFF-8B48-534240956C96' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.LandAV 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   DisplayName = 'Land AV',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '2E17E63A-92ED-4FD7-B1C9-3F323C8E8246' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.LandRes1AV 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   DisplayName = 'Land Res (1) AV',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '5D3CF08B-3716-4210-A421-7A9826F2E5FA' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.LandNonRes2AV 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   DisplayName = 'Land Non Res (2) AV',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'F43EF7FB-CCFA-46C9-8BFA-823421A363DA' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.LandNonRes3AV 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   DisplayName = 'Land Non Res (3) AV',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '59DA306A-8CC6-49E1-85E9-ED1EF2047FF7' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.ImprovementAV 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   DisplayName = 'Improvement AV',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '9D48DD89-DD16-482B-9E6A-7707365EE133' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.ImprovementRes1AV 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   DisplayName = 'Improvement Res (1) AV',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '3F0AA5D3-EE74-40BC-BA45-7D3CFCC84938' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.ImprovementNonRes2AV 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   DisplayName = 'Improvement Non Res (2) AV',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '04B7EAB2-7972-4D15-8CD8-930BD9D48087' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.ImprovementNonRes3AV 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   DisplayName = 'Improvement Non Res (3) AV',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'E9EA8F1A-DC8B-415B-B35E-EF9BE39F9B53' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.TotalAV 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   DisplayName = 'Total AV',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'FC948138-AF9A-45F9-9D38-8000F7F30BA7' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.TotalRes1AV 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   DisplayName = 'Total Res (1) AV',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'A68CF354-DCC5-492E-9351-5E2C6EB8C437' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.TotalNonRes2AV 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   DisplayName = 'Total Non Res (2) AV',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '3A0B0650-DA05-40CF-BF35-2E05289E74D9' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.TotalNonRes3AV 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   DisplayName = 'Total Non Res (3) AV',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '3832C55B-5869-4D13-8C01-1D3E432075C5' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.__mj_CreatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '49184452-1ECE-4B0A-A024-FCB21F37515E' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Card Valuation Columns.__mj_UpdatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '62025DE0-1057-47E4-A9A1-9B35855CBA17' AND AutoUpdateCategory = 1;

/* Set categories for 52 fields */

-- UPDATE Entity Field Category Info County Assessor Records.ID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'DD51C417-EBBC-487C-A05B-6D2C6D00700B' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.ParcelID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '194EF8B1-9C31-47EB-AD0A-2D3A0C37A263' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.CountyNumber 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '23D122B6-FB91-40BC-8B0F-022A898F57A3' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.CountyParcelID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '53EDF39B-AC09-436A-8019-43453AE834AD' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.SourceRegistryID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'F6CD79C7-FE9D-46B3-B8D4-9EFF39C23DF6' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.OwnerName 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '57AE271B-AF4B-4719-A650-D447A7E1BEA7' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.OwnerAddress 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = 'GeoAddress',
   CodeType = NULL
WHERE 
   ID = '3BAC1919-5C39-4E29-9B2F-ED4FB1B880C2' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.OwnerCity 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = 'GeoCity',
   CodeType = NULL
WHERE 
   ID = '56690BB9-DACF-4A46-81AF-3AA95F283E06' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.OwnerState 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = 'GeoStateProvince',
   CodeType = NULL
WHERE 
   ID = '50A1EECD-D0EA-4141-9742-26944141C4C7' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.OwnerZip 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = 'GeoPostalCode',
   CodeType = NULL
WHERE 
   ID = 'FD22DDBF-DF66-4925-B653-21657F8AE174' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.PropertyClass 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '30E498DB-FA9C-4A2D-9DF8-7B64AA21AAB7' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.PropertySubClassDescription 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   DisplayName = 'Property Subclass Description',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '53BDB1CC-5888-4353-8127-8B953D17BBA7' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.Neighborhood 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'B27FE1DB-4312-4F0A-A3E3-A79F05939209' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.TaxDistrictID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '93473612-8B46-4A54-996A-E263FFA61067' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.LegalDescription 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '09B4786E-CE22-4BB6-8AC0-BA4DBB8C16A5' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.Acreage 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '536593F3-F6A8-4D91-AAA6-A3FDF6052460' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.EstimatedSqFt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   DisplayName = 'Estimated Square Feet',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'F60AA594-B74D-4C6A-96F9-EED47A6E13E6' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.SqFtSource 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'AE00A369-7914-494B-8C84-9306BC2F3844' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.Status 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'E2325162-DF08-46F5-B677-8C9188719C3C' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.YearBuilt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'CFD0FAF2-441D-44BD-AFB2-26FAE9F95DAD' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.CoStarYearBuilt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '7B6D093F-5E09-4AF6-8431-3E1215AE1C9A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.AssessedLandAV 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '89666441-C26B-41FA-B11A-0DD8B7CC6534' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.AssessedImprovementAV 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '8E4B39BF-CBDA-46A1-8313-3B63E405A7A5' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.AssessedTotalAV 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'B6B555DF-07FE-4B07-A928-FE62A56A0DA9' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.SourceModDate 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'F2F8A630-5272-4053-8B7B-BD8C59EA2325' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.RetrievedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '9CA4BD8D-7B48-463D-895C-F6EEB8A1165D' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.LastAssessmentChangeDate 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '78C0D405-E2F3-4B36-8B4C-06B1C2BFD865' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.ReportRetrievedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '75DAE713-17D4-4707-9201-2C8E4D6B6B18' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.TaxYear 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '9B8D25BA-912A-477A-9C64-13DA22293CDC' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.GrossAssessment 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '26C65A1B-27DD-4652-B22A-3E32C6826249' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.DeductionsExemptionsTotal 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'A3A83D90-FC2E-4CC9-BAAB-13C17489C495' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.NetAssessment 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '918D4BEA-B7F0-42C9-B64B-32DA83D2E136' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.TaxRate 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '10CBF6C8-92F0-451A-891D-37A31F5794B8' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.NetAnnualTax 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'B0785BB5-BE9B-4548-976F-6E9B32F89225' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.CurrentTaxDue 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '3215AAC4-A1AD-46F2-81A1-20FCFED3C15E' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.DeedType 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '06D62BBF-5E86-4997-9141-86F5005B6049' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.DeedDate 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'B45FFEB3-CA05-4DFC-8939-9F38752C252D' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.FileDate 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '8318AEC7-FEAE-4C04-8918-30CCC433D69F' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.SourceDocumentID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '9E34B634-D66C-4425-A55E-B3C8CCA194FF' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.TaxHistorySourceDocumentID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '50D12797-E7B0-4D31-A906-F527B3BD1362' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.ComparisonUnitType 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '8FEA0E92-D7C4-47C7-8525-C90C9F317A8B' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.ComparisonUnitCount 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '3114520A-1114-4BB9-BFAB-2E843B0BC5ED' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.CoStarRBA 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Property Details',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'BA2E8C5F-7B25-4529-9925-924A811562E4' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.RevisionForm 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessment Revision',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '94C6DB31-498A-4C83-ABBE-E3DCBDA51F59' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.RevisionReason 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessment Revision',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '529F5BC9-979F-4163-80CA-F1B5B13966B6' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.RevisionAsOfDate 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessment Revision',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'CA7D4CB5-CDDB-4FFC-B163-02AA097C0A1E' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.__mj_CreatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '348ACAEB-56DF-4662-808D-17E3E40EB851' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.__mj_UpdatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '9BBB043A-91D5-4512-9FE9-79E6BAA3286D' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.Parcel 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '9074B95F-478B-4607-A95A-6E0E5F471604' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.SourceRegistry 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'C75DBD1B-A825-4C94-B7C2-32ED88D88E88' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.${flyway:defaultSchema}_Latitude 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = 'GeoLatitude',
   CodeType = NULL
WHERE 
   ID = '6B59A92E-022F-4994-86CB-CBC4A186E4F6' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info County Assessor Records.${flyway:defaultSchema}_Longitude 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = 'GeoLongitude',
   CodeType = NULL
WHERE 
   ID = 'DE75612B-4F1A-4529-8C33-AFDF5CBD63B7' AND AutoUpdateCategory = 1;

/* Update FieldCategoryInfo setting for entity */

               UPDATE [${flyway:defaultSchema}].[EntitySetting]
               SET [Value] = '{"Assessment Revision":{"icon":"fa fa-file-alt","description":"Assessment revision details including form type, reason, and effective date"}}', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [EntityID] = '43815D48-5A63-4FF9-BC25-232DBFB790FE' AND [Name] = 'FieldCategoryInfo';

/* Update FieldCategoryIcons setting (legacy) */

               UPDATE [${flyway:defaultSchema}].[EntitySetting]
               SET [Value] = '{"Assessment Revision":"fa fa-file-alt"}', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [EntityID] = '43815D48-5A63-4FF9-BC25-232DBFB790FE' AND [Name] = 'FieldCategoryIcons';

