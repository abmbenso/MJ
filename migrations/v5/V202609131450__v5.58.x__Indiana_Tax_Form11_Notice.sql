/* ============================================================================
   Indiana Property Tax Expert — the Form 11 / 11-A notice of assessment
   v5.58.x (companion to V202609121958 Indiana_Tax_Card_History)

   xSoft Engage publishes, beside a county's record cards, the DLGF notice of
   assessment for each parcel and year: Form 11 (State Form 21366) for most
   property, Form 11-A (State Form 57328) for apartments. The notice is the
   document that opens the appeal window -- it prints the previous and the
   new assessment, the reason for revision, the date of notice (the Form 130
   filing deadline runs from it, IC 6-1.1-15-1.1) and the appeal deadline;
   the 11-A also prints the three approaches to value the assessor must
   report under IC 6-1.1-4-39 and whether the taxpayer submitted income and
   expense data. One AssessmentNotice row per notice, hanging off a
   SourceDocument of the new type 'Form11'. DocumentAcquisition learns the
   same type. Design: Indiana_Tax_Expert/docs/proposals/multi-county-ci-intake.md
   §11 (Form 11 addendum); plan docs/plans/2026-09-13-form11-notice.md.
   ============================================================================ */

CREATE TABLE indiana_tax.AssessmentNotice (
    ID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    SourceDocumentID UNIQUEIDENTIFIER NOT NULL,
    ParcelID UNIQUEIDENTIFIER NOT NULL,
    AssessmentYear SMALLINT NOT NULL,
    FormType NVARCHAR(5) NOT NULL,
    StateForm NVARCHAR(40) NULL,
    NoticeDate DATE NULL,
    AppealDeadline DATE NULL,
    PreviousLandAV DECIMAL(14,2) NULL,
    PreviousImprovementAV DECIMAL(14,2) NULL,
    PreviousTotalAV DECIMAL(14,2) NULL,
    NewLandAV DECIMAL(14,2) NULL,
    NewImprovementAV DECIMAL(14,2) NULL,
    NewTotalAV DECIMAL(14,2) NULL,
    Reason NVARCHAR(200) NULL,
    SalesComparisonValue DECIMAL(14,2) NULL,
    CostApproachValue DECIMAL(14,2) NULL,
    IncomeApproachValue DECIMAL(14,2) NULL,
    IncomeExpenseSubmitted BIT NULL,
    IncomeExpenseUsed BIT NULL,
    Township NVARCHAR(100) NULL,
    OwnerName NVARCHAR(500) NULL,
    MailingAddress NVARCHAR(500) NULL,
    PropertyAddress NVARCHAR(200) NULL,
    AssessingOfficial NVARCHAR(200) NULL,
    ParseNotes NVARCHAR(1000) NULL,
    CONSTRAINT PK_AssessmentNotice PRIMARY KEY (ID),
    CONSTRAINT FK_AssessmentNotice_SourceDocument FOREIGN KEY (SourceDocumentID) REFERENCES indiana_tax.SourceDocument (ID),
    CONSTRAINT FK_AssessmentNotice_Parcel FOREIGN KEY (ParcelID) REFERENCES indiana_tax.Parcel (ID),
    CONSTRAINT UQ_AssessmentNotice UNIQUE (SourceDocumentID),
    CONSTRAINT CK_AssessmentNotice_FormType CHECK (FormType IN ('11', '11-A'))
);
GO

ALTER TABLE indiana_tax.SourceDocument DROP CONSTRAINT CK_SourceDocument_DocumentType;
GO
ALTER TABLE indiana_tax.SourceDocument ADD CONSTRAINT CK_SourceDocument_DocumentType CHECK (DocumentType IN (
    'APRAResponse', 'APRARequest', 'PropertyRecordCard', 'TaxHistoryReport', 'PTABOAAgenda', 'PTABOAFinalDeterminationApproval',
    'PTABOAFinalDeterminationWithdrawal', 'BoardDecision', 'IBTRDecision', 'Form', 'Statute', 'Regulation', 'ReferenceText', 'Memo',
    'StatewideParcelDataset', 'CountyParcelList', 'MarketDataExport', 'Other', 'Form11'));
GO

ALTER TABLE indiana_tax.DocumentAcquisition DROP CONSTRAINT CK_DocumentAcquisition_DocumentType;
GO
ALTER TABLE indiana_tax.DocumentAcquisition ADD CONSTRAINT CK_DocumentAcquisition_DocumentType CHECK (DocumentType IN ('TaxHistoryReport', 'PropertyRecordCard', 'Form11'));
GO

EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'One DLGF notice of assessment as the county published it for this parcel: Form 11 (State Form 21366) for most property, Form 11-A (State Form 57328) for apartments. The document that opens the appeal window: previous vs new assessment, the reason for revision, the date of notice and the appeal deadline; the 11-A adds the three approaches to value (IC 6-1.1-4-39). Read from the PDF by word position (scripts/lib/form11.py); one row per SourceDocument of type Form11.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AssessmentNotice';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The assessment year the notice is effective for ("NEW ASSESSMENT EFFECTIVE JANUARY 1, <year>"), read from the page; the fetcher''s year folder is checked against it (ParseNotes on disagreement).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AssessmentNotice', @level2type = N'COLUMN', @level2name = N'AssessmentYear';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'''11'' (State Form 21366, most property) or ''11-A'' (State Form 57328, apartments -- carries the three approaches and the income/expense questions).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AssessmentNotice', @level2type = N'COLUMN', @level2name = N'FormType';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The state form and revision printed under the title, verbatim (e.g. ''State Form 21366 (R23 / 11-25)'').',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AssessmentNotice', @level2type = N'COLUMN', @level2name = N'StateForm';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The Date of Notice printed on the form. The Form 130 filing window runs from it (IC 6-1.1-15-1.1): mailed before May 1 of the assessment year, the deadline is June 15 of that year; on or after May 1, June 15 of the year the tax statements are mailed.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AssessmentNotice', @level2type = N'COLUMN', @level2name = N'NoticeDate';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The date in the form''s "APPEAL DEADLINE IS:" box, as the county printed it.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AssessmentNotice', @level2type = N'COLUMN', @level2name = N'AppealDeadline';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'PREVIOUS ASSESSMENT column, LAND row -- the prior year''s value as the county states it on the notice.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AssessmentNotice', @level2type = N'COLUMN', @level2name = N'PreviousLandAV';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'PREVIOUS ASSESSMENT column, STRUCTURES row.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AssessmentNotice', @level2type = N'COLUMN', @level2name = N'PreviousImprovementAV';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'PREVIOUS ASSESSMENT column, TOTAL row.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AssessmentNotice', @level2type = N'COLUMN', @level2name = N'PreviousTotalAV';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'NEW ASSESSMENT EFFECTIVE JANUARY 1 column, LAND row -- the noticed value. The record card''s as-noticed column for the same year (Assessment.OriginalLandAV) should equal it; the notice-vs-card check says when it does not.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AssessmentNotice', @level2type = N'COLUMN', @level2name = N'NewLandAV';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'NEW ASSESSMENT column, STRUCTURES row -- the noticed improvement value.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AssessmentNotice', @level2type = N'COLUMN', @level2name = N'NewImprovementAV';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'NEW ASSESSMENT column, TOTAL row -- the noticed total. On a Form 11-A this is the lowest of the three approaches when the assessor applied IC 6-1.1-4-39 as written.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AssessmentNotice', @level2type = N'COLUMN', @level2name = N'NewTotalAV';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'"Reason for Revision of Assessment" (Form 11 only; e.g. Annual Adjustment). NULL on a Form 11-A, which prints no reason block.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AssessmentNotice', @level2type = N'COLUMN', @level2name = N'Reason';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Form 11-A only: SALES COMPARISON APPROACH VALUATION, one of the three values the assessor reports for an apartment property under IC 6-1.1-4-39.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AssessmentNotice', @level2type = N'COLUMN', @level2name = N'SalesComparisonValue';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Form 11-A only: COST APPROACH VALUATION.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AssessmentNotice', @level2type = N'COLUMN', @level2name = N'CostApproachValue';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Form 11-A only: INCOME CAPITALIZATION APPROACH VALUATION.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AssessmentNotice', @level2type = N'COLUMN', @level2name = N'IncomeApproachValue';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Form 11-A only: "Did the taxpayer submit specific income and expense information for development of the income capitalization approach by January 1 as required by IC 6-1.1-4-39(d)?" -- 1 Yes, 0 No, NULL when the box is unmarked or the form is a Form 11.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AssessmentNotice', @level2type = N'COLUMN', @level2name = N'IncomeExpenseSubmitted';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Form 11-A only: "If information was submitted, was it used to determine the value under the Income Capitalization Approach above?" -- 1 Yes, 0 No, NULL when unmarked or not a Form 11-A.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AssessmentNotice', @level2type = N'COLUMN', @level2name = N'IncomeExpenseUsed';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Township printed in the notice''s footer.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AssessmentNotice', @level2type = N'COLUMN', @level2name = N'Township';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'First line of the addressee block (the owner as the county mails it).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AssessmentNotice', @level2type = N'COLUMN', @level2name = N'OwnerName';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The remaining lines of the addressee block, joined with " / " -- the mailing address the county used.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AssessmentNotice', @level2type = N'COLUMN', @level2name = N'MailingAddress';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'"Property Address" line as printed.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AssessmentNotice', @level2type = N'COLUMN', @level2name = N'PropertyAddress';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'"Assessing Official" line as printed (name and office).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AssessmentNotice', @level2type = N'COLUMN', @level2name = N'AssessingOfficial';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'What the parser could not read or found inconsistent (e.g. the page year disagrees with the file year); NULL when clean.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'AssessmentNotice', @level2type = N'COLUMN', @level2name = N'ParseNotes';
GO


















































/* ============================================================================
   EVERYTHING BELOW WAS GENERATED BY THE MEMBERJUNCTION CODEGEN TOOL.
   It contains the Entity row for "Assessment Notices", its application and
   role permissions, the __mj_CreatedAt/__mj_UpdatedAt columns, the 28
   EntityField inserts, the FormType value list ('11', '11-A'), the 'Form11'
   value added to SourceDocument.DocumentType and DocumentAcquisition.DocumentType,
   the view vwAssessmentNotices, the spCreate/spUpdate/spDelete procedures,
   the update trigger, the FK index checks and the permission grants. Do NOT
   edit by hand -- if the hand DDL above changes, re-run CodeGen and replace
   this entire section. Excluded as unrelated: the pre-existing "Store
   Analysis" EntityField sequence update (a CodeGen error on that virtual
   entity that appears on every run).
   ============================================================================ */

/* SQL generated to create new entity Assessment Notices */

      INSERT INTO [${flyway:defaultSchema}].[Entity] (
         [ID],
         [Name],
         [DisplayName],
         [Description],
         [NameSuffix],
         [BaseTable],
         [BaseView],
         [SchemaName],
         [IncludeInAPI],
         [AllowUserSearchAPI],
         [AllowCaching]
         , [TrackRecordChanges]
         , [AuditRecordAccess]
         , [AuditViewRuns]
         , [AllowAllRowsAPI]
         , [AllowCreateAPI]
         , [AllowUpdateAPI]
         , [AllowDeleteAPI]
         , [UserViewMaxRows]
         , [__mj_CreatedAt]
         , [__mj_UpdatedAt]
      )
      VALUES (
         '3a750bc9-0034-47fe-bd90-aa41e6ebaceb',
         'Assessment Notices',
         NULL,
         'One DLGF notice of assessment as the county published it for this parcel: Form 11 (State Form 21366) for most property, Form 11-A (State Form 57328) for apartments. The document that opens the appeal window: previous vs new assessment, the reason for revision, the date of notice and the appeal deadline; the 11-A adds the three approaches to value (IC 6-1.1-4-39). Read from the PDF by word position (scripts/lib/form11.py); one row per SourceDocument of type Form11.',
         NULL,
         'AssessmentNotice',
         'vwAssessmentNotices',
         'indiana_tax',
         1,
         1,
         0
         , 1
         , 0
         , 0
         , 0
         , 1
         , 1
         , 1
         , 1000
         , GETUTCDATE()
         , GETUTCDATE()
      );

/* SQL generated to add new entity Assessment Notices to application ID: '49E87630-494F-460F-8CF4-724B96F0F8B3' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('49E87630-494F-460F-8CF4-724B96F0F8B3', '3a750bc9-0034-47fe-bd90-aa41e6ebaceb', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '49E87630-494F-460F-8CF4-724B96F0F8B3'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Assessment Notices for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('3a750bc9-0034-47fe-bd90-aa41e6ebaceb', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Assessment Notices for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('3a750bc9-0034-47fe-bd90-aa41e6ebaceb', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Assessment Notices for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('3a750bc9-0034-47fe-bd90-aa41e6ebaceb', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.AssessmentNotice */
ALTER TABLE [indiana_tax].[AssessmentNotice] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.AssessmentNotice */
UPDATE [indiana_tax].[AssessmentNotice] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.AssessmentNotice */
ALTER TABLE [indiana_tax].[AssessmentNotice] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.AssessmentNotice */
ALTER TABLE [indiana_tax].[AssessmentNotice] ADD CONSTRAINT [DF_indiana_tax_AssessmentNotice___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.AssessmentNotice */
ALTER TABLE [indiana_tax].[AssessmentNotice] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.AssessmentNotice */
UPDATE [indiana_tax].[AssessmentNotice] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.AssessmentNotice */
ALTER TABLE [indiana_tax].[AssessmentNotice] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.AssessmentNotice */
ALTER TABLE [indiana_tax].[AssessmentNotice] ADD CONSTRAINT [DF_indiana_tax_AssessmentNotice___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to insert 28 new entity field(s) */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '37dfffc5-9f9c-4ce9-8912-a92c62a272c2' OR (EntityID = '3A750BC9-0034-47FE-BD90-AA41E6EBACEB' AND Name = 'ID')) BEGIN
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
            '37dfffc5-9f9c-4ce9-8912-a92c62a272c2',
            '3A750BC9-0034-47FE-BD90-AA41E6EBACEB', -- Entity: Assessment Notices
            100001,
            'ID',
            'ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            'newsequentialid()',
            0,
            0,
            0,
            0,
            NULL,
            NULL,
            0,
            1,
            0,
            0,
            1,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'bfd8acd3-4e7a-4cad-a843-12c45cb51515' OR (EntityID = '3A750BC9-0034-47FE-BD90-AA41E6EBACEB' AND Name = 'SourceDocumentID')) BEGIN
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
            'bfd8acd3-4e7a-4cad-a843-12c45cb51515',
            '3A750BC9-0034-47FE-BD90-AA41E6EBACEB', -- Entity: Assessment Notices
            100002,
            'SourceDocumentID',
            'Source Document ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            '30AF9254-9D7A-442A-A064-0B4448E21AB1',
            'ID',
            0,
            0,
            1,
            0,
            0,
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '087e9211-3a6d-428a-8d1b-64ef30a0a4ad' OR (EntityID = '3A750BC9-0034-47FE-BD90-AA41E6EBACEB' AND Name = 'ParcelID')) BEGIN
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
            '087e9211-3a6d-428a-8d1b-64ef30a0a4ad',
            '3A750BC9-0034-47FE-BD90-AA41E6EBACEB', -- Entity: Assessment Notices
            100003,
            'ParcelID',
            'Parcel ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            0,
            NULL,
            0,
            1,
            0,
            0,
            'D0F9D3D3-2E68-4ABA-8891-8DEC85F300FB',
            'ID',
            0,
            0,
            1,
            0,
            0,
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '1ff74eb7-e1f6-41c8-bccc-36e4e983632e' OR (EntityID = '3A750BC9-0034-47FE-BD90-AA41E6EBACEB' AND Name = 'AssessmentYear')) BEGIN
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
            '1ff74eb7-e1f6-41c8-bccc-36e4e983632e',
            '3A750BC9-0034-47FE-BD90-AA41E6EBACEB', -- Entity: Assessment Notices
            100004,
            'AssessmentYear',
            'Assessment Year',
            'The assessment year the notice is effective for ("NEW ASSESSMENT EFFECTIVE JANUARY 1, <year>"), read from the page; the fetcher''s year folder is checked against it (ParseNotes on disagreement).',
            'smallint',
            2,
            5,
            0,
            0,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '0fc427fe-b6a1-4395-8a90-7b9e9c2d7a3b' OR (EntityID = '3A750BC9-0034-47FE-BD90-AA41E6EBACEB' AND Name = 'FormType')) BEGIN
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
            '0fc427fe-b6a1-4395-8a90-7b9e9c2d7a3b',
            '3A750BC9-0034-47FE-BD90-AA41E6EBACEB', -- Entity: Assessment Notices
            100005,
            'FormType',
            'Form Type',
            '''11'' (State Form 21366, most property) or ''11-A'' (State Form 57328, apartments -- carries the three approaches and the income/expense questions).',
            'nvarchar',
            10,
            0,
            0,
            0,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '41f55bf3-d161-4d44-8152-d5d1a503df9b' OR (EntityID = '3A750BC9-0034-47FE-BD90-AA41E6EBACEB' AND Name = 'StateForm')) BEGIN
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
            '41f55bf3-d161-4d44-8152-d5d1a503df9b',
            '3A750BC9-0034-47FE-BD90-AA41E6EBACEB', -- Entity: Assessment Notices
            100006,
            'StateForm',
            'State Form',
            'The state form and revision printed under the title, verbatim (e.g. ''State Form 21366 (R23 / 11-25)'').',
            'nvarchar',
            80,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '3d0fb076-ba0d-4043-bc88-37c4a636ff80' OR (EntityID = '3A750BC9-0034-47FE-BD90-AA41E6EBACEB' AND Name = 'NoticeDate')) BEGIN
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
            '3d0fb076-ba0d-4043-bc88-37c4a636ff80',
            '3A750BC9-0034-47FE-BD90-AA41E6EBACEB', -- Entity: Assessment Notices
            100007,
            'NoticeDate',
            'Notice Date',
            'The Date of Notice printed on the form. The Form 130 filing window runs from it (IC 6-1.1-15-1.1): mailed before May 1 of the assessment year, the deadline is June 15 of that year; on or after May 1, June 15 of the year the tax statements are mailed.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'cfceedb8-afc8-4a0c-bfc0-1e8de77da33d' OR (EntityID = '3A750BC9-0034-47FE-BD90-AA41E6EBACEB' AND Name = 'AppealDeadline')) BEGIN
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
            'cfceedb8-afc8-4a0c-bfc0-1e8de77da33d',
            '3A750BC9-0034-47FE-BD90-AA41E6EBACEB', -- Entity: Assessment Notices
            100008,
            'AppealDeadline',
            'Appeal Deadline',
            'The date in the form''s "APPEAL DEADLINE IS:" box, as the county printed it.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'c7ca1911-9c0f-4731-94eb-703ef9fcb73f' OR (EntityID = '3A750BC9-0034-47FE-BD90-AA41E6EBACEB' AND Name = 'PreviousLandAV')) BEGIN
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
            'c7ca1911-9c0f-4731-94eb-703ef9fcb73f',
            '3A750BC9-0034-47FE-BD90-AA41E6EBACEB', -- Entity: Assessment Notices
            100009,
            'PreviousLandAV',
            'Previous Land AV',
            'PREVIOUS ASSESSMENT column, LAND row -- the prior year''s value as the county states it on the notice.',
            'decimal',
            9,
            14,
            2,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '6dd8a1c4-ffc6-43d8-9463-0bd75799adc8' OR (EntityID = '3A750BC9-0034-47FE-BD90-AA41E6EBACEB' AND Name = 'PreviousImprovementAV')) BEGIN
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
            '6dd8a1c4-ffc6-43d8-9463-0bd75799adc8',
            '3A750BC9-0034-47FE-BD90-AA41E6EBACEB', -- Entity: Assessment Notices
            100010,
            'PreviousImprovementAV',
            'Previous Improvement AV',
            'PREVIOUS ASSESSMENT column, STRUCTURES row.',
            'decimal',
            9,
            14,
            2,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '05e126b9-aee2-4ba4-a040-514600c061e4' OR (EntityID = '3A750BC9-0034-47FE-BD90-AA41E6EBACEB' AND Name = 'PreviousTotalAV')) BEGIN
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
            '05e126b9-aee2-4ba4-a040-514600c061e4',
            '3A750BC9-0034-47FE-BD90-AA41E6EBACEB', -- Entity: Assessment Notices
            100011,
            'PreviousTotalAV',
            'Previous Total AV',
            'PREVIOUS ASSESSMENT column, TOTAL row.',
            'decimal',
            9,
            14,
            2,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'c91043df-2063-439c-b1eb-864a74a38b48' OR (EntityID = '3A750BC9-0034-47FE-BD90-AA41E6EBACEB' AND Name = 'NewLandAV')) BEGIN
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
            'c91043df-2063-439c-b1eb-864a74a38b48',
            '3A750BC9-0034-47FE-BD90-AA41E6EBACEB', -- Entity: Assessment Notices
            100012,
            'NewLandAV',
            'New Land AV',
            'NEW ASSESSMENT EFFECTIVE JANUARY 1 column, LAND row -- the noticed value. The record card''s as-noticed column for the same year (Assessment.OriginalLandAV) should equal it; the notice-vs-card check says when it does not.',
            'decimal',
            9,
            14,
            2,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'f2593695-f2e6-47b2-8bf1-e373cb2a3578' OR (EntityID = '3A750BC9-0034-47FE-BD90-AA41E6EBACEB' AND Name = 'NewImprovementAV')) BEGIN
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
            'f2593695-f2e6-47b2-8bf1-e373cb2a3578',
            '3A750BC9-0034-47FE-BD90-AA41E6EBACEB', -- Entity: Assessment Notices
            100013,
            'NewImprovementAV',
            'New Improvement AV',
            'NEW ASSESSMENT column, STRUCTURES row -- the noticed improvement value.',
            'decimal',
            9,
            14,
            2,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ce042f2e-ad41-4557-b5d0-fa67fe162f7e' OR (EntityID = '3A750BC9-0034-47FE-BD90-AA41E6EBACEB' AND Name = 'NewTotalAV')) BEGIN
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
            'ce042f2e-ad41-4557-b5d0-fa67fe162f7e',
            '3A750BC9-0034-47FE-BD90-AA41E6EBACEB', -- Entity: Assessment Notices
            100014,
            'NewTotalAV',
            'New Total AV',
            'NEW ASSESSMENT column, TOTAL row -- the noticed total. On a Form 11-A this is the lowest of the three approaches when the assessor applied IC 6-1.1-4-39 as written.',
            'decimal',
            9,
            14,
            2,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'bb7684bb-dc52-4364-a88f-4fd8a0eecb2a' OR (EntityID = '3A750BC9-0034-47FE-BD90-AA41E6EBACEB' AND Name = 'Reason')) BEGIN
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
            'bb7684bb-dc52-4364-a88f-4fd8a0eecb2a',
            '3A750BC9-0034-47FE-BD90-AA41E6EBACEB', -- Entity: Assessment Notices
            100015,
            'Reason',
            'Reason',
            '"Reason for Revision of Assessment" (Form 11 only; e.g. Annual Adjustment). NULL on a Form 11-A, which prints no reason block.',
            'nvarchar',
            400,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '87d282e4-0daa-49cc-9530-b0168b3408f7' OR (EntityID = '3A750BC9-0034-47FE-BD90-AA41E6EBACEB' AND Name = 'SalesComparisonValue')) BEGIN
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
            '87d282e4-0daa-49cc-9530-b0168b3408f7',
            '3A750BC9-0034-47FE-BD90-AA41E6EBACEB', -- Entity: Assessment Notices
            100016,
            'SalesComparisonValue',
            'Sales Comparison Value',
            'Form 11-A only: SALES COMPARISON APPROACH VALUATION, one of the three values the assessor reports for an apartment property under IC 6-1.1-4-39.',
            'decimal',
            9,
            14,
            2,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'de87a48e-ff7d-4d7d-92ef-de9b597e34e8' OR (EntityID = '3A750BC9-0034-47FE-BD90-AA41E6EBACEB' AND Name = 'CostApproachValue')) BEGIN
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
            'de87a48e-ff7d-4d7d-92ef-de9b597e34e8',
            '3A750BC9-0034-47FE-BD90-AA41E6EBACEB', -- Entity: Assessment Notices
            100017,
            'CostApproachValue',
            'Cost Approach Value',
            'Form 11-A only: COST APPROACH VALUATION.',
            'decimal',
            9,
            14,
            2,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '17024c8d-354c-4841-9f3c-cb7976107a62' OR (EntityID = '3A750BC9-0034-47FE-BD90-AA41E6EBACEB' AND Name = 'IncomeApproachValue')) BEGIN
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
            '17024c8d-354c-4841-9f3c-cb7976107a62',
            '3A750BC9-0034-47FE-BD90-AA41E6EBACEB', -- Entity: Assessment Notices
            100018,
            'IncomeApproachValue',
            'Income Approach Value',
            'Form 11-A only: INCOME CAPITALIZATION APPROACH VALUATION.',
            'decimal',
            9,
            14,
            2,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7135e15d-c164-4a9e-a228-86e60f07f790' OR (EntityID = '3A750BC9-0034-47FE-BD90-AA41E6EBACEB' AND Name = 'IncomeExpenseSubmitted')) BEGIN
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
            '7135e15d-c164-4a9e-a228-86e60f07f790',
            '3A750BC9-0034-47FE-BD90-AA41E6EBACEB', -- Entity: Assessment Notices
            100019,
            'IncomeExpenseSubmitted',
            'Income Expense Submitted',
            'Form 11-A only: "Did the taxpayer submit specific income and expense information for development of the income capitalization approach by January 1 as required by IC 6-1.1-4-39(d)?" -- 1 Yes, 0 No, NULL when the box is unmarked or the form is a Form 11.',
            'bit',
            1,
            1,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'b644430e-047d-4f7a-96b3-19e6df69cac9' OR (EntityID = '3A750BC9-0034-47FE-BD90-AA41E6EBACEB' AND Name = 'IncomeExpenseUsed')) BEGIN
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
            'b644430e-047d-4f7a-96b3-19e6df69cac9',
            '3A750BC9-0034-47FE-BD90-AA41E6EBACEB', -- Entity: Assessment Notices
            100020,
            'IncomeExpenseUsed',
            'Income Expense Used',
            'Form 11-A only: "If information was submitted, was it used to determine the value under the Income Capitalization Approach above?" -- 1 Yes, 0 No, NULL when unmarked or not a Form 11-A.',
            'bit',
            1,
            1,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '5e6f85c8-aa3f-4719-96df-fd6cd1cd6e7a' OR (EntityID = '3A750BC9-0034-47FE-BD90-AA41E6EBACEB' AND Name = 'Township')) BEGIN
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
            '5e6f85c8-aa3f-4719-96df-fd6cd1cd6e7a',
            '3A750BC9-0034-47FE-BD90-AA41E6EBACEB', -- Entity: Assessment Notices
            100021,
            'Township',
            'Township',
            'Township printed in the notice''s footer.',
            'nvarchar',
            200,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'eed2b35b-e44b-4323-8d94-6f68bad43b29' OR (EntityID = '3A750BC9-0034-47FE-BD90-AA41E6EBACEB' AND Name = 'OwnerName')) BEGIN
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
            'eed2b35b-e44b-4323-8d94-6f68bad43b29',
            '3A750BC9-0034-47FE-BD90-AA41E6EBACEB', -- Entity: Assessment Notices
            100022,
            'OwnerName',
            'Owner Name',
            'First line of the addressee block (the owner as the county mails it).',
            'nvarchar',
            1000,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '512ae501-06a3-41e4-ac17-11f44e50168f' OR (EntityID = '3A750BC9-0034-47FE-BD90-AA41E6EBACEB' AND Name = 'MailingAddress')) BEGIN
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
            '512ae501-06a3-41e4-ac17-11f44e50168f',
            '3A750BC9-0034-47FE-BD90-AA41E6EBACEB', -- Entity: Assessment Notices
            100023,
            'MailingAddress',
            'Mailing Address',
            'The remaining lines of the addressee block, joined with " / " -- the mailing address the county used.',
            'nvarchar',
            1000,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'cdab42c7-12d6-47e9-a33a-51b51d8f74b7' OR (EntityID = '3A750BC9-0034-47FE-BD90-AA41E6EBACEB' AND Name = 'PropertyAddress')) BEGIN
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
            'cdab42c7-12d6-47e9-a33a-51b51d8f74b7',
            '3A750BC9-0034-47FE-BD90-AA41E6EBACEB', -- Entity: Assessment Notices
            100024,
            'PropertyAddress',
            'Property Address',
            '"Property Address" line as printed.',
            'nvarchar',
            400,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '5bf0e3e8-cfe4-4284-8c33-171b3ba2267e' OR (EntityID = '3A750BC9-0034-47FE-BD90-AA41E6EBACEB' AND Name = 'AssessingOfficial')) BEGIN
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
            '5bf0e3e8-cfe4-4284-8c33-171b3ba2267e',
            '3A750BC9-0034-47FE-BD90-AA41E6EBACEB', -- Entity: Assessment Notices
            100025,
            'AssessingOfficial',
            'Assessing Official',
            '"Assessing Official" line as printed (name and office).',
            'nvarchar',
            400,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd9081afb-7431-49ae-98ce-daececa1773d' OR (EntityID = '3A750BC9-0034-47FE-BD90-AA41E6EBACEB' AND Name = 'ParseNotes')) BEGIN
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
            'd9081afb-7431-49ae-98ce-daececa1773d',
            '3A750BC9-0034-47FE-BD90-AA41E6EBACEB', -- Entity: Assessment Notices
            100026,
            'ParseNotes',
            'Parse Notes',
            'What the parser could not read or found inconsistent (e.g. the page year disagrees with the file year); NULL when clean.',
            'nvarchar',
            2000,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '8615a497-dbad-4dfe-b4f5-edbc53ceef85' OR (EntityID = '3A750BC9-0034-47FE-BD90-AA41E6EBACEB' AND Name = '__mj_CreatedAt')) BEGIN
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
            '8615a497-dbad-4dfe-b4f5-edbc53ceef85',
            '3A750BC9-0034-47FE-BD90-AA41E6EBACEB', -- Entity: Assessment Notices
            100027,
            '__mj_CreatedAt',
            'Created At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'e66d23ff-9a6a-4535-b1bb-f78976914f5c' OR (EntityID = '3A750BC9-0034-47FE-BD90-AA41E6EBACEB' AND Name = '__mj_UpdatedAt')) BEGIN
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
            'e66d23ff-9a6a-4535-b1bb-f78976914f5c',
            '3A750BC9-0034-47FE-BD90-AA41E6EBACEB', -- Entity: Assessment Notices
            100028,
            '__mj_UpdatedAt',
            'Updated At',
            NULL,
            'datetimeoffset',
            10,
            34,
            7,
            0,
            'getutcdate()',
            0,
            0,
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

/* SQL text to insert entity field value with ID 4639d01d-2324-40af-904f-89b2de8f47e3 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('4639d01d-2324-40af-904f-89b2de8f47e3', '0FC427FE-B6A1-4395-8A90-7B9E9C2D7A3B', 1, '11', '11', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID dc040517-d458-4e6c-a1d8-c91a7e1cb752 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('dc040517-d458-4e6c-a1d8-c91a7e1cb752', '0FC427FE-B6A1-4395-8A90-7B9E9C2D7A3B', 2, '11-A', '11-A', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 0FC427FE-B6A1-4395-8A90-7B9E9C2D7A3B */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='0FC427FE-B6A1-4395-8A90-7B9E9C2D7A3B';

/* SQL text to insert entity field value with ID e9e08d62-80ec-4fd0-9823-f985f822cb03 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('e9e08d62-80ec-4fd0-9823-f985f822cb03', '87A89E7B-9AF6-4231-B9BC-CED6EFAB3A89', 6, 'Form11', 'Form11', GETUTCDATE(), GETUTCDATE());

/* SQL text to update entity field value sequence */
UPDATE [${flyway:defaultSchema}].[EntityFieldValue] SET Sequence=7 WHERE ID='FE4C646A-7D7E-44BF-AD82-94200E61F9F2';

/* SQL text to update entity field value sequence */
UPDATE [${flyway:defaultSchema}].[EntityFieldValue] SET Sequence=8 WHERE ID='FC0812A9-CE82-49EC-817B-CD47EF66E33B';

/* SQL text to update entity field value sequence */
UPDATE [${flyway:defaultSchema}].[EntityFieldValue] SET Sequence=9 WHERE ID='50199183-966D-48EC-9C44-AF20BE0ECE7F';

/* SQL text to update entity field value sequence */
UPDATE [${flyway:defaultSchema}].[EntityFieldValue] SET Sequence=10 WHERE ID='300F56F6-E740-41FB-B6D9-DAC6EB6961AC';

/* SQL text to update entity field value sequence */
UPDATE [${flyway:defaultSchema}].[EntityFieldValue] SET Sequence=11 WHERE ID='FB69C6AE-C7D3-4222-9525-C82784868686';

/* SQL text to update entity field value sequence */
UPDATE [${flyway:defaultSchema}].[EntityFieldValue] SET Sequence=12 WHERE ID='71E6EA9D-7CF6-4032-8C80-A148EF6597A5';

/* SQL text to update entity field value sequence */
UPDATE [${flyway:defaultSchema}].[EntityFieldValue] SET Sequence=13 WHERE ID='1BCEDE69-90C7-4160-B48F-B419BA156448';

/* SQL text to update entity field value sequence */
UPDATE [${flyway:defaultSchema}].[EntityFieldValue] SET Sequence=14 WHERE ID='59F7518E-4B47-4445-BEE0-44EC6024CEA5';

/* SQL text to update entity field value sequence */
UPDATE [${flyway:defaultSchema}].[EntityFieldValue] SET Sequence=15 WHERE ID='665D9FB7-5DDD-4DB1-816C-5A9043FA286F';

/* SQL text to update entity field value sequence */
UPDATE [${flyway:defaultSchema}].[EntityFieldValue] SET Sequence=16 WHERE ID='B035527C-561F-4884-8C1F-943ECBD7D1EE';

/* SQL text to update entity field value sequence */
UPDATE [${flyway:defaultSchema}].[EntityFieldValue] SET Sequence=17 WHERE ID='1CD799F8-E71B-48D8-8BAC-8ADFEA01A441';

/* SQL text to update entity field value sequence */
UPDATE [${flyway:defaultSchema}].[EntityFieldValue] SET Sequence=18 WHERE ID='906F415E-A30F-4349-81BE-C9D85C14A5FD';

/* SQL text to update entity field value sequence */
UPDATE [${flyway:defaultSchema}].[EntityFieldValue] SET Sequence=19 WHERE ID='E858C2C5-EB97-41AE-933C-FCA80E47D19F';

/* SQL text to insert entity field value with ID c10a7d5d-0b77-433b-8d4e-96550dc87875 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('c10a7d5d-0b77-433b-8d4e-96550dc87875', 'A9AFA3D5-BC3B-47D6-B35E-7E95B6B72802', 1, 'Form11', 'Form11', GETUTCDATE(), GETUTCDATE());

/* SQL text to update entity field value sequence */
UPDATE [${flyway:defaultSchema}].[EntityFieldValue] SET Sequence=2 WHERE ID='731C9456-14F6-4F1C-927D-20A3CAD75864';

/* SQL text to update entity field value sequence */
UPDATE [${flyway:defaultSchema}].[EntityFieldValue] SET Sequence=3 WHERE ID='BC54950F-8F93-4E57-A098-62753974F1F4';


/* Create Entity Relationship: Source Documents -> Assessment Notices (One To Many via SourceDocumentID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '2cf8547d-e289-4a7f-8ade-0f41b3dcd7c5'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('2cf8547d-e289-4a7f-8ade-0f41b3dcd7c5', '30AF9254-9D7A-442A-A064-0B4448E21AB1', '3A750BC9-0034-47FE-BD90-AA41E6EBACEB', 'SourceDocumentID', 'One To Many', 1, 1, 36, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: Parcels -> Assessment Notices (One To Many via ParcelID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '5db8b3af-4c26-4b81-943f-0e219c2869b5'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('5db8b3af-4c26-4b81-943f-0e219c2869b5', 'D0F9D3D3-2E68-4ABA-8891-8DEC85F300FB', '3A750BC9-0034-47FE-BD90-AA41E6EBACEB', 'ParcelID', 'One To Many', 1, 1, 27, GETUTCDATE(), GETUTCDATE())
   END;


/* Index for Foreign Keys for AssessmentNotice */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Assessment Notices
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key SourceDocumentID in table AssessmentNotice
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_AssessmentNotice_SourceDocumentID' 
    AND object_id = OBJECT_ID('[indiana_tax].[AssessmentNotice]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_AssessmentNotice_SourceDocumentID ON [indiana_tax].[AssessmentNotice] ([SourceDocumentID]);

-- Index for foreign key ParcelID in table AssessmentNotice
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_AssessmentNotice_ParcelID' 
    AND object_id = OBJECT_ID('[indiana_tax].[AssessmentNotice]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_AssessmentNotice_ParcelID ON [indiana_tax].[AssessmentNotice] ([ParcelID]);

/* SQL text to update entity field related entity name field map for entity field ID 087E9211-3A6D-428A-8D1B-64EF30A0A4AD */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='087E9211-3A6D-428A-8D1B-64EF30A0A4AD', @RelatedEntityNameFieldMap='Parcel';

/* Base View SQL for Assessment Notices */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Assessment Notices
-- Item: vwAssessmentNotices
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Assessment Notices
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  AssessmentNotice
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwAssessmentNotices]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwAssessmentNotices];
GO

CREATE VIEW [indiana_tax].[vwAssessmentNotices]
AS
SELECT
    a.*,
    indianataxParcel_ParcelID.[ParcelNumber] AS [Parcel]
FROM
    [indiana_tax].[AssessmentNotice] AS a
INNER JOIN
    [indiana_tax].[Parcel] AS indianataxParcel_ParcelID
  ON
    [a].[ParcelID] = indianataxParcel_ParcelID.[ID]
GO
GRANT SELECT ON [indiana_tax].[vwAssessmentNotices] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for Assessment Notices */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Assessment Notices
-- Item: Permissions for vwAssessmentNotices
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwAssessmentNotices] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for Assessment Notices */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Assessment Notices
-- Item: spCreateAssessmentNotice
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR AssessmentNotice
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateAssessmentNotice]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateAssessmentNotice];
GO

CREATE PROCEDURE [indiana_tax].[spCreateAssessmentNotice]
    @ID uniqueidentifier = NULL,
    @SourceDocumentID uniqueidentifier,
    @ParcelID uniqueidentifier,
    @AssessmentYear smallint,
    @FormType nvarchar(5),
    @StateForm_Clear bit = 0,
    @StateForm nvarchar(40) = NULL,
    @NoticeDate_Clear bit = 0,
    @NoticeDate date = NULL,
    @AppealDeadline_Clear bit = 0,
    @AppealDeadline date = NULL,
    @PreviousLandAV_Clear bit = 0,
    @PreviousLandAV decimal(14, 2) = NULL,
    @PreviousImprovementAV_Clear bit = 0,
    @PreviousImprovementAV decimal(14, 2) = NULL,
    @PreviousTotalAV_Clear bit = 0,
    @PreviousTotalAV decimal(14, 2) = NULL,
    @NewLandAV_Clear bit = 0,
    @NewLandAV decimal(14, 2) = NULL,
    @NewImprovementAV_Clear bit = 0,
    @NewImprovementAV decimal(14, 2) = NULL,
    @NewTotalAV_Clear bit = 0,
    @NewTotalAV decimal(14, 2) = NULL,
    @Reason_Clear bit = 0,
    @Reason nvarchar(200) = NULL,
    @SalesComparisonValue_Clear bit = 0,
    @SalesComparisonValue decimal(14, 2) = NULL,
    @CostApproachValue_Clear bit = 0,
    @CostApproachValue decimal(14, 2) = NULL,
    @IncomeApproachValue_Clear bit = 0,
    @IncomeApproachValue decimal(14, 2) = NULL,
    @IncomeExpenseSubmitted_Clear bit = 0,
    @IncomeExpenseSubmitted bit = NULL,
    @IncomeExpenseUsed_Clear bit = 0,
    @IncomeExpenseUsed bit = NULL,
    @Township_Clear bit = 0,
    @Township nvarchar(100) = NULL,
    @OwnerName_Clear bit = 0,
    @OwnerName nvarchar(500) = NULL,
    @MailingAddress_Clear bit = 0,
    @MailingAddress nvarchar(500) = NULL,
    @PropertyAddress_Clear bit = 0,
    @PropertyAddress nvarchar(200) = NULL,
    @AssessingOfficial_Clear bit = 0,
    @AssessingOfficial nvarchar(200) = NULL,
    @ParseNotes_Clear bit = 0,
    @ParseNotes nvarchar(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[AssessmentNotice]
            (
                [ID],
                [SourceDocumentID],
                [ParcelID],
                [AssessmentYear],
                [FormType],
                [StateForm],
                [NoticeDate],
                [AppealDeadline],
                [PreviousLandAV],
                [PreviousImprovementAV],
                [PreviousTotalAV],
                [NewLandAV],
                [NewImprovementAV],
                [NewTotalAV],
                [Reason],
                [SalesComparisonValue],
                [CostApproachValue],
                [IncomeApproachValue],
                [IncomeExpenseSubmitted],
                [IncomeExpenseUsed],
                [Township],
                [OwnerName],
                [MailingAddress],
                [PropertyAddress],
                [AssessingOfficial],
                [ParseNotes]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @SourceDocumentID,
                @ParcelID,
                @AssessmentYear,
                @FormType,
                CASE WHEN @StateForm_Clear = 1 THEN NULL ELSE ISNULL(@StateForm, NULL) END,
                CASE WHEN @NoticeDate_Clear = 1 THEN NULL ELSE ISNULL(@NoticeDate, NULL) END,
                CASE WHEN @AppealDeadline_Clear = 1 THEN NULL ELSE ISNULL(@AppealDeadline, NULL) END,
                CASE WHEN @PreviousLandAV_Clear = 1 THEN NULL ELSE ISNULL(@PreviousLandAV, NULL) END,
                CASE WHEN @PreviousImprovementAV_Clear = 1 THEN NULL ELSE ISNULL(@PreviousImprovementAV, NULL) END,
                CASE WHEN @PreviousTotalAV_Clear = 1 THEN NULL ELSE ISNULL(@PreviousTotalAV, NULL) END,
                CASE WHEN @NewLandAV_Clear = 1 THEN NULL ELSE ISNULL(@NewLandAV, NULL) END,
                CASE WHEN @NewImprovementAV_Clear = 1 THEN NULL ELSE ISNULL(@NewImprovementAV, NULL) END,
                CASE WHEN @NewTotalAV_Clear = 1 THEN NULL ELSE ISNULL(@NewTotalAV, NULL) END,
                CASE WHEN @Reason_Clear = 1 THEN NULL ELSE ISNULL(@Reason, NULL) END,
                CASE WHEN @SalesComparisonValue_Clear = 1 THEN NULL ELSE ISNULL(@SalesComparisonValue, NULL) END,
                CASE WHEN @CostApproachValue_Clear = 1 THEN NULL ELSE ISNULL(@CostApproachValue, NULL) END,
                CASE WHEN @IncomeApproachValue_Clear = 1 THEN NULL ELSE ISNULL(@IncomeApproachValue, NULL) END,
                CASE WHEN @IncomeExpenseSubmitted_Clear = 1 THEN NULL ELSE ISNULL(@IncomeExpenseSubmitted, NULL) END,
                CASE WHEN @IncomeExpenseUsed_Clear = 1 THEN NULL ELSE ISNULL(@IncomeExpenseUsed, NULL) END,
                CASE WHEN @Township_Clear = 1 THEN NULL ELSE ISNULL(@Township, NULL) END,
                CASE WHEN @OwnerName_Clear = 1 THEN NULL ELSE ISNULL(@OwnerName, NULL) END,
                CASE WHEN @MailingAddress_Clear = 1 THEN NULL ELSE ISNULL(@MailingAddress, NULL) END,
                CASE WHEN @PropertyAddress_Clear = 1 THEN NULL ELSE ISNULL(@PropertyAddress, NULL) END,
                CASE WHEN @AssessingOfficial_Clear = 1 THEN NULL ELSE ISNULL(@AssessingOfficial, NULL) END,
                CASE WHEN @ParseNotes_Clear = 1 THEN NULL ELSE ISNULL(@ParseNotes, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[AssessmentNotice]
            (
                [SourceDocumentID],
                [ParcelID],
                [AssessmentYear],
                [FormType],
                [StateForm],
                [NoticeDate],
                [AppealDeadline],
                [PreviousLandAV],
                [PreviousImprovementAV],
                [PreviousTotalAV],
                [NewLandAV],
                [NewImprovementAV],
                [NewTotalAV],
                [Reason],
                [SalesComparisonValue],
                [CostApproachValue],
                [IncomeApproachValue],
                [IncomeExpenseSubmitted],
                [IncomeExpenseUsed],
                [Township],
                [OwnerName],
                [MailingAddress],
                [PropertyAddress],
                [AssessingOfficial],
                [ParseNotes]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @SourceDocumentID,
                @ParcelID,
                @AssessmentYear,
                @FormType,
                CASE WHEN @StateForm_Clear = 1 THEN NULL ELSE ISNULL(@StateForm, NULL) END,
                CASE WHEN @NoticeDate_Clear = 1 THEN NULL ELSE ISNULL(@NoticeDate, NULL) END,
                CASE WHEN @AppealDeadline_Clear = 1 THEN NULL ELSE ISNULL(@AppealDeadline, NULL) END,
                CASE WHEN @PreviousLandAV_Clear = 1 THEN NULL ELSE ISNULL(@PreviousLandAV, NULL) END,
                CASE WHEN @PreviousImprovementAV_Clear = 1 THEN NULL ELSE ISNULL(@PreviousImprovementAV, NULL) END,
                CASE WHEN @PreviousTotalAV_Clear = 1 THEN NULL ELSE ISNULL(@PreviousTotalAV, NULL) END,
                CASE WHEN @NewLandAV_Clear = 1 THEN NULL ELSE ISNULL(@NewLandAV, NULL) END,
                CASE WHEN @NewImprovementAV_Clear = 1 THEN NULL ELSE ISNULL(@NewImprovementAV, NULL) END,
                CASE WHEN @NewTotalAV_Clear = 1 THEN NULL ELSE ISNULL(@NewTotalAV, NULL) END,
                CASE WHEN @Reason_Clear = 1 THEN NULL ELSE ISNULL(@Reason, NULL) END,
                CASE WHEN @SalesComparisonValue_Clear = 1 THEN NULL ELSE ISNULL(@SalesComparisonValue, NULL) END,
                CASE WHEN @CostApproachValue_Clear = 1 THEN NULL ELSE ISNULL(@CostApproachValue, NULL) END,
                CASE WHEN @IncomeApproachValue_Clear = 1 THEN NULL ELSE ISNULL(@IncomeApproachValue, NULL) END,
                CASE WHEN @IncomeExpenseSubmitted_Clear = 1 THEN NULL ELSE ISNULL(@IncomeExpenseSubmitted, NULL) END,
                CASE WHEN @IncomeExpenseUsed_Clear = 1 THEN NULL ELSE ISNULL(@IncomeExpenseUsed, NULL) END,
                CASE WHEN @Township_Clear = 1 THEN NULL ELSE ISNULL(@Township, NULL) END,
                CASE WHEN @OwnerName_Clear = 1 THEN NULL ELSE ISNULL(@OwnerName, NULL) END,
                CASE WHEN @MailingAddress_Clear = 1 THEN NULL ELSE ISNULL(@MailingAddress, NULL) END,
                CASE WHEN @PropertyAddress_Clear = 1 THEN NULL ELSE ISNULL(@PropertyAddress, NULL) END,
                CASE WHEN @AssessingOfficial_Clear = 1 THEN NULL ELSE ISNULL(@AssessingOfficial, NULL) END,
                CASE WHEN @ParseNotes_Clear = 1 THEN NULL ELSE ISNULL(@ParseNotes, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwAssessmentNotices] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateAssessmentNotice] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for Assessment Notices */

GRANT EXECUTE ON [indiana_tax].[spCreateAssessmentNotice] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for Assessment Notices */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Assessment Notices
-- Item: spUpdateAssessmentNotice
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR AssessmentNotice
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateAssessmentNotice]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateAssessmentNotice];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateAssessmentNotice]
    @ID uniqueidentifier,
    @SourceDocumentID uniqueidentifier = NULL,
    @ParcelID uniqueidentifier = NULL,
    @AssessmentYear smallint = NULL,
    @FormType nvarchar(5) = NULL,
    @StateForm_Clear bit = 0,
    @StateForm nvarchar(40) = NULL,
    @NoticeDate_Clear bit = 0,
    @NoticeDate date = NULL,
    @AppealDeadline_Clear bit = 0,
    @AppealDeadline date = NULL,
    @PreviousLandAV_Clear bit = 0,
    @PreviousLandAV decimal(14, 2) = NULL,
    @PreviousImprovementAV_Clear bit = 0,
    @PreviousImprovementAV decimal(14, 2) = NULL,
    @PreviousTotalAV_Clear bit = 0,
    @PreviousTotalAV decimal(14, 2) = NULL,
    @NewLandAV_Clear bit = 0,
    @NewLandAV decimal(14, 2) = NULL,
    @NewImprovementAV_Clear bit = 0,
    @NewImprovementAV decimal(14, 2) = NULL,
    @NewTotalAV_Clear bit = 0,
    @NewTotalAV decimal(14, 2) = NULL,
    @Reason_Clear bit = 0,
    @Reason nvarchar(200) = NULL,
    @SalesComparisonValue_Clear bit = 0,
    @SalesComparisonValue decimal(14, 2) = NULL,
    @CostApproachValue_Clear bit = 0,
    @CostApproachValue decimal(14, 2) = NULL,
    @IncomeApproachValue_Clear bit = 0,
    @IncomeApproachValue decimal(14, 2) = NULL,
    @IncomeExpenseSubmitted_Clear bit = 0,
    @IncomeExpenseSubmitted bit = NULL,
    @IncomeExpenseUsed_Clear bit = 0,
    @IncomeExpenseUsed bit = NULL,
    @Township_Clear bit = 0,
    @Township nvarchar(100) = NULL,
    @OwnerName_Clear bit = 0,
    @OwnerName nvarchar(500) = NULL,
    @MailingAddress_Clear bit = 0,
    @MailingAddress nvarchar(500) = NULL,
    @PropertyAddress_Clear bit = 0,
    @PropertyAddress nvarchar(200) = NULL,
    @AssessingOfficial_Clear bit = 0,
    @AssessingOfficial nvarchar(200) = NULL,
    @ParseNotes_Clear bit = 0,
    @ParseNotes nvarchar(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[AssessmentNotice]
    SET
        [SourceDocumentID] = ISNULL(@SourceDocumentID, [SourceDocumentID]),
        [ParcelID] = ISNULL(@ParcelID, [ParcelID]),
        [AssessmentYear] = ISNULL(@AssessmentYear, [AssessmentYear]),
        [FormType] = ISNULL(@FormType, [FormType]),
        [StateForm] = CASE WHEN @StateForm_Clear = 1 THEN NULL ELSE ISNULL(@StateForm, [StateForm]) END,
        [NoticeDate] = CASE WHEN @NoticeDate_Clear = 1 THEN NULL ELSE ISNULL(@NoticeDate, [NoticeDate]) END,
        [AppealDeadline] = CASE WHEN @AppealDeadline_Clear = 1 THEN NULL ELSE ISNULL(@AppealDeadline, [AppealDeadline]) END,
        [PreviousLandAV] = CASE WHEN @PreviousLandAV_Clear = 1 THEN NULL ELSE ISNULL(@PreviousLandAV, [PreviousLandAV]) END,
        [PreviousImprovementAV] = CASE WHEN @PreviousImprovementAV_Clear = 1 THEN NULL ELSE ISNULL(@PreviousImprovementAV, [PreviousImprovementAV]) END,
        [PreviousTotalAV] = CASE WHEN @PreviousTotalAV_Clear = 1 THEN NULL ELSE ISNULL(@PreviousTotalAV, [PreviousTotalAV]) END,
        [NewLandAV] = CASE WHEN @NewLandAV_Clear = 1 THEN NULL ELSE ISNULL(@NewLandAV, [NewLandAV]) END,
        [NewImprovementAV] = CASE WHEN @NewImprovementAV_Clear = 1 THEN NULL ELSE ISNULL(@NewImprovementAV, [NewImprovementAV]) END,
        [NewTotalAV] = CASE WHEN @NewTotalAV_Clear = 1 THEN NULL ELSE ISNULL(@NewTotalAV, [NewTotalAV]) END,
        [Reason] = CASE WHEN @Reason_Clear = 1 THEN NULL ELSE ISNULL(@Reason, [Reason]) END,
        [SalesComparisonValue] = CASE WHEN @SalesComparisonValue_Clear = 1 THEN NULL ELSE ISNULL(@SalesComparisonValue, [SalesComparisonValue]) END,
        [CostApproachValue] = CASE WHEN @CostApproachValue_Clear = 1 THEN NULL ELSE ISNULL(@CostApproachValue, [CostApproachValue]) END,
        [IncomeApproachValue] = CASE WHEN @IncomeApproachValue_Clear = 1 THEN NULL ELSE ISNULL(@IncomeApproachValue, [IncomeApproachValue]) END,
        [IncomeExpenseSubmitted] = CASE WHEN @IncomeExpenseSubmitted_Clear = 1 THEN NULL ELSE ISNULL(@IncomeExpenseSubmitted, [IncomeExpenseSubmitted]) END,
        [IncomeExpenseUsed] = CASE WHEN @IncomeExpenseUsed_Clear = 1 THEN NULL ELSE ISNULL(@IncomeExpenseUsed, [IncomeExpenseUsed]) END,
        [Township] = CASE WHEN @Township_Clear = 1 THEN NULL ELSE ISNULL(@Township, [Township]) END,
        [OwnerName] = CASE WHEN @OwnerName_Clear = 1 THEN NULL ELSE ISNULL(@OwnerName, [OwnerName]) END,
        [MailingAddress] = CASE WHEN @MailingAddress_Clear = 1 THEN NULL ELSE ISNULL(@MailingAddress, [MailingAddress]) END,
        [PropertyAddress] = CASE WHEN @PropertyAddress_Clear = 1 THEN NULL ELSE ISNULL(@PropertyAddress, [PropertyAddress]) END,
        [AssessingOfficial] = CASE WHEN @AssessingOfficial_Clear = 1 THEN NULL ELSE ISNULL(@AssessingOfficial, [AssessingOfficial]) END,
        [ParseNotes] = CASE WHEN @ParseNotes_Clear = 1 THEN NULL ELSE ISNULL(@ParseNotes, [ParseNotes]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwAssessmentNotices] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwAssessmentNotices]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateAssessmentNotice] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the AssessmentNotice table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateAssessmentNotice]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateAssessmentNotice];
GO
CREATE TRIGGER [indiana_tax].trgUpdateAssessmentNotice
ON [indiana_tax].[AssessmentNotice]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[AssessmentNotice]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[AssessmentNotice] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for Assessment Notices */

GRANT EXECUTE ON [indiana_tax].[spUpdateAssessmentNotice] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for Assessment Notices */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Assessment Notices
-- Item: spDeleteAssessmentNotice
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR AssessmentNotice
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteAssessmentNotice]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteAssessmentNotice];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteAssessmentNotice]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[AssessmentNotice]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteAssessmentNotice] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for Assessment Notices */

GRANT EXECUTE ON [indiana_tax].[spDeleteAssessmentNotice] TO [cdp_Developer], [cdp_Integration];

/* SQL text to insert 1 new entity field(s) */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '1e88f571-847b-4224-b475-737175a8d7f6' OR (EntityID = '3A750BC9-0034-47FE-BD90-AA41E6EBACEB' AND Name = 'Parcel')) BEGIN
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
            '1e88f571-847b-4224-b475-737175a8d7f6',
            '3A750BC9-0034-47FE-BD90-AA41E6EBACEB', -- Entity: Assessment Notices
            100057,
            'Parcel',
            'Parcel',
            NULL,
            'nvarchar',
            60,
            0,
            0,
            0,
            NULL,
            0,
            0,
            1,
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

