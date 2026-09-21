/* SQL generated to create new entity Legal Authorities */

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
         '4c07018c-418e-409c-958a-2b39f9baf36b',
         'Legal Authorities',
         NULL,
         'One titled legal-authority document or edition -- an Indiana Code article, a 50 IAC article, the Real Property Assessment Manual, a specific DLGF Guidelines edition, IBTR or Tax Court Rules of Procedure, a specific DLGF Form, a DLGF memo, or one county''s ratio-study narrative. Current text only; no historical versioning.',
         NULL,
         'LegalAuthority',
         'vwLegalAuthorities',
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

/* SQL generated to add new entity Legal Authorities to application ID: '49E87630-494F-460F-8CF4-724B96F0F8B3' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('49E87630-494F-460F-8CF4-724B96F0F8B3', '4c07018c-418e-409c-958a-2b39f9baf36b', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '49E87630-494F-460F-8CF4-724B96F0F8B3'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Legal Authorities for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('4c07018c-418e-409c-958a-2b39f9baf36b', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Legal Authorities for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('4c07018c-418e-409c-958a-2b39f9baf36b', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Legal Authorities for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('4c07018c-418e-409c-958a-2b39f9baf36b', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to create new entity Legal Authority Sections */

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
         '9cd2ff63-3eda-4b18-b7a8-51a2f717e90b',
         'Legal Authority Sections',
         NULL,
         'One hierarchical unit within a LegalAuthority document -- an article, chapter, or leaf section/part/rule/form. Grouping rows (Article, Chapter) typically have NULL FullText; leaf rows carry the actual text.',
         NULL,
         'LegalAuthoritySection',
         'vwLegalAuthoritySections',
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

/* SQL generated to add new entity Legal Authority Sections to application ID: '49E87630-494F-460F-8CF4-724B96F0F8B3' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('49E87630-494F-460F-8CF4-724B96F0F8B3', '9cd2ff63-3eda-4b18-b7a8-51a2f717e90b', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '49E87630-494F-460F-8CF4-724B96F0F8B3'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Legal Authority Sections for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('9cd2ff63-3eda-4b18-b7a8-51a2f717e90b', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Legal Authority Sections for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('9cd2ff63-3eda-4b18-b7a8-51a2f717e90b', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Legal Authority Sections for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('9cd2ff63-3eda-4b18-b7a8-51a2f717e90b', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to create new entity Legal Authority Chunks */

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
         '6f48da55-0427-49e7-878a-70d15c020f9c',
         'Legal Authority Chunks',
         NULL,
         'A passage of a LegalAuthoritySection''s text for retrieval. The Search Scope for legal-authority search points here.',
         NULL,
         'LegalAuthorityChunk',
         'vwLegalAuthorityChunks',
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

/* SQL generated to add new entity Legal Authority Chunks to application ID: '49E87630-494F-460F-8CF4-724B96F0F8B3' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('49E87630-494F-460F-8CF4-724B96F0F8B3', '6f48da55-0427-49e7-878a-70d15c020f9c', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '49E87630-494F-460F-8CF4-724B96F0F8B3'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Legal Authority Chunks for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('6f48da55-0427-49e7-878a-70d15c020f9c', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Legal Authority Chunks for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('6f48da55-0427-49e7-878a-70d15c020f9c', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Legal Authority Chunks for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('6f48da55-0427-49e7-878a-70d15c020f9c', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.LegalAuthority */
ALTER TABLE [indiana_tax].[LegalAuthority] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.LegalAuthority */
UPDATE [indiana_tax].[LegalAuthority] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.LegalAuthority */
ALTER TABLE [indiana_tax].[LegalAuthority] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.LegalAuthority */
ALTER TABLE [indiana_tax].[LegalAuthority] ADD CONSTRAINT [DF_indiana_tax_LegalAuthority___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.LegalAuthority */
ALTER TABLE [indiana_tax].[LegalAuthority] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.LegalAuthority */
UPDATE [indiana_tax].[LegalAuthority] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.LegalAuthority */
ALTER TABLE [indiana_tax].[LegalAuthority] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.LegalAuthority */
ALTER TABLE [indiana_tax].[LegalAuthority] ADD CONSTRAINT [DF_indiana_tax_LegalAuthority___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.LegalAuthoritySection */
ALTER TABLE [indiana_tax].[LegalAuthoritySection] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.LegalAuthoritySection */
UPDATE [indiana_tax].[LegalAuthoritySection] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.LegalAuthoritySection */
ALTER TABLE [indiana_tax].[LegalAuthoritySection] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.LegalAuthoritySection */
ALTER TABLE [indiana_tax].[LegalAuthoritySection] ADD CONSTRAINT [DF_indiana_tax_LegalAuthoritySection___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.LegalAuthoritySection */
ALTER TABLE [indiana_tax].[LegalAuthoritySection] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.LegalAuthoritySection */
UPDATE [indiana_tax].[LegalAuthoritySection] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.LegalAuthoritySection */
ALTER TABLE [indiana_tax].[LegalAuthoritySection] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.LegalAuthoritySection */
ALTER TABLE [indiana_tax].[LegalAuthoritySection] ADD CONSTRAINT [DF_indiana_tax_LegalAuthoritySection___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.LegalAuthorityChunk */
ALTER TABLE [indiana_tax].[LegalAuthorityChunk] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.LegalAuthorityChunk */
UPDATE [indiana_tax].[LegalAuthorityChunk] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.LegalAuthorityChunk */
ALTER TABLE [indiana_tax].[LegalAuthorityChunk] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.LegalAuthorityChunk */
ALTER TABLE [indiana_tax].[LegalAuthorityChunk] ADD CONSTRAINT [DF_indiana_tax_LegalAuthorityChunk___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.LegalAuthorityChunk */
ALTER TABLE [indiana_tax].[LegalAuthorityChunk] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.LegalAuthorityChunk */
UPDATE [indiana_tax].[LegalAuthorityChunk] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.LegalAuthorityChunk */
ALTER TABLE [indiana_tax].[LegalAuthorityChunk] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.LegalAuthorityChunk */
ALTER TABLE [indiana_tax].[LegalAuthorityChunk] ADD CONSTRAINT [DF_indiana_tax_LegalAuthorityChunk___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to insert 29 new entity field(s) */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'c38040c4-e32b-4d64-bbad-c22c0a114934' OR (EntityID = '4C07018C-418E-409C-958A-2B39F9BAF36B' AND Name = 'ID')) BEGIN
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
            'c38040c4-e32b-4d64-bbad-c22c0a114934',
            '4C07018C-418E-409C-958A-2B39F9BAF36B', -- Entity: Legal Authorities
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'cde21b89-1dbd-420f-829a-b4660a1efec7' OR (EntityID = '4C07018C-418E-409C-958A-2B39F9BAF36B' AND Name = 'SourceType')) BEGIN
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
            'cde21b89-1dbd-420f-829a-b4660a1efec7',
            '4C07018C-418E-409C-958A-2B39F9BAF36B', -- Entity: Legal Authorities
            100002,
            'SourceType',
            'Source Type',
            'Statute | AdminRule | Manual | Guideline | ProceduralRule | Form | Memo | RatioStudyNarrative.',
            'nvarchar',
            60,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '37cfa710-842a-4e51-a470-0eb266ee76ae' OR (EntityID = '4C07018C-418E-409C-958A-2B39F9BAF36B' AND Name = 'Forum')) BEGIN
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
            '37cfa710-842a-4e51-a470-0eb266ee76ae',
            '4C07018C-418E-409C-958A-2B39F9BAF36B', -- Entity: Legal Authorities
            100003,
            'Forum',
            'Forum',
            'IBTR or TaxCourt, set only when SourceType = ProceduralRule.',
            'nvarchar',
            40,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '5a3d7f44-a74a-45fe-bddb-b7baffe493f1' OR (EntityID = '4C07018C-418E-409C-958A-2B39F9BAF36B' AND Name = 'Title')) BEGIN
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
            '5a3d7f44-a74a-45fe-bddb-b7baffe493f1',
            '4C07018C-418E-409C-958A-2B39F9BAF36B', -- Entity: Legal Authorities
            100004,
            'Title',
            'Title',
            'Human-readable title, e.g. "Indiana Code Title 6, Article 1.1 -- Property Taxation" or "Real Property Assessment Manual".',
            'nvarchar',
            600,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'a7f7c755-be3a-47e7-bfca-852e374a42a1' OR (EntityID = '4C07018C-418E-409C-958A-2B39F9BAF36B' AND Name = 'AsOfDate')) BEGIN
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
            'a7f7c755-be3a-47e7-bfca-852e374a42a1',
            '4C07018C-418E-409C-958A-2B39F9BAF36B', -- Entity: Legal Authorities
            100005,
            'AsOfDate',
            'As Of Date',
            'The edition/publication date this text is current as of; NULL when unknown.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'dbbfce6b-d5dc-459a-9c43-a4e1dc82b04d' OR (EntityID = '4C07018C-418E-409C-958A-2B39F9BAF36B' AND Name = 'SourceDocumentID')) BEGIN
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
            'dbbfce6b-d5dc-459a-9c43-a4e1dc82b04d',
            '4C07018C-418E-409C-958A-2B39F9BAF36B', -- Entity: Legal Authorities
            100006,
            'SourceDocumentID',
            'Source Document ID',
            'The fetched source file (PDF/HTML) this document was parsed from, for provenance.',
            'uniqueidentifier',
            16,
            0,
            0,
            1,
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
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '60d9d984-fa9b-4da1-b0df-e608f6ce908c' OR (EntityID = '4C07018C-418E-409C-958A-2B39F9BAF36B' AND Name = 'SourceURL')) BEGIN
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
            '60d9d984-fa9b-4da1-b0df-e608f6ce908c',
            '4C07018C-418E-409C-958A-2B39F9BAF36B', -- Entity: Legal Authorities
            100007,
            'SourceURL',
            'Source URL',
            'The authoritative URL this document was retrieved from, for direct citation linking.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '2d6d3c63-3d6b-46fb-a8c1-e23a6d5dc4ab' OR (EntityID = '4C07018C-418E-409C-958A-2B39F9BAF36B' AND Name = '__mj_CreatedAt')) BEGIN
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
            '2d6d3c63-3d6b-46fb-a8c1-e23a6d5dc4ab',
            '4C07018C-418E-409C-958A-2B39F9BAF36B', -- Entity: Legal Authorities
            100008,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'bedc11de-649d-47ba-8722-7308252ee05a' OR (EntityID = '4C07018C-418E-409C-958A-2B39F9BAF36B' AND Name = '__mj_UpdatedAt')) BEGIN
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
            'bedc11de-649d-47ba-8722-7308252ee05a',
            '4C07018C-418E-409C-958A-2B39F9BAF36B', -- Entity: Legal Authorities
            100009,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'cab111a4-4f49-4588-a3b3-387c605bf653' OR (EntityID = '8FCB213B-2FCE-4DE0-AEEA-3CDA0D4D641B' AND Name = 'ResolvedLegalAuthoritySectionID')) BEGIN
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
            'cab111a4-4f49-4588-a3b3-387c605bf653',
            '8FCB213B-2FCE-4DE0-AEEA-3CDA0D4D641B', -- Entity: IBTR Decision Citations
            100023,
            'ResolvedLegalAuthoritySectionID',
            'Resolved Legal Authority Section ID',
            'The LegalAuthoritySection this citation''s CiteKey resolves to, where a match exists (statute/rule cites only -- case citations are out of scope for this column).',
            'uniqueidentifier',
            16,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            '9CD2FF63-3EDA-4B18-B7A8-51A2F717E90B',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '590f9407-89f6-42d8-842b-fa2865a35bbc' OR (EntityID = '9CD2FF63-3EDA-4B18-B7A8-51A2F717E90B' AND Name = 'ID')) BEGIN
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
            '590f9407-89f6-42d8-842b-fa2865a35bbc',
            '9CD2FF63-3EDA-4B18-B7A8-51A2F717E90B', -- Entity: Legal Authority Sections
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '51e9984f-70f8-4693-9b55-dd009ce01b63' OR (EntityID = '9CD2FF63-3EDA-4B18-B7A8-51A2F717E90B' AND Name = 'LegalAuthorityID')) BEGIN
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
            '51e9984f-70f8-4693-9b55-dd009ce01b63',
            '9CD2FF63-3EDA-4B18-B7A8-51A2F717E90B', -- Entity: Legal Authority Sections
            100002,
            'LegalAuthorityID',
            'Legal Authority ID',
            'The parent LegalAuthority document this section belongs to.',
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
            '4C07018C-418E-409C-958A-2B39F9BAF36B',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '1f773562-e6d9-4578-ad13-1dc38e2a0587' OR (EntityID = '9CD2FF63-3EDA-4B18-B7A8-51A2F717E90B' AND Name = 'ParentSectionID')) BEGIN
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
            '1f773562-e6d9-4578-ad13-1dc38e2a0587',
            '9CD2FF63-3EDA-4B18-B7A8-51A2F717E90B', -- Entity: Legal Authority Sections
            100003,
            'ParentSectionID',
            'Parent Section ID',
            'The enclosing section (a Section''s parent is a Chapter, a Chapter''s parent is an Article); NULL for a top-level Article/Form/Rule.',
            'uniqueidentifier',
            16,
            0,
            0,
            1,
            NULL,
            0,
            1,
            0,
            0,
            '9CD2FF63-3EDA-4B18-B7A8-51A2F717E90B',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'e7616296-c5ee-4b6d-8cea-74a099b04343' OR (EntityID = '9CD2FF63-3EDA-4B18-B7A8-51A2F717E90B' AND Name = 'SectionLevel')) BEGIN
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
            'e7616296-c5ee-4b6d-8cea-74a099b04343',
            '9CD2FF63-3EDA-4B18-B7A8-51A2F717E90B', -- Entity: Legal Authority Sections
            100004,
            'SectionLevel',
            'Section Level',
            'Article | Chapter | Section | Part | Rule | Form -- what kind of hierarchical unit this row is.',
            'nvarchar',
            40,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'dd6992ee-8630-4a22-8dc6-618bb79fd0aa' OR (EntityID = '9CD2FF63-3EDA-4B18-B7A8-51A2F717E90B' AND Name = 'SectionNumber')) BEGIN
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
            'dd6992ee-8630-4a22-8dc6-618bb79fd0aa',
            '9CD2FF63-3EDA-4B18-B7A8-51A2F717E90B', -- Entity: Legal Authority Sections
            100005,
            'SectionNumber',
            'Section Number',
            'The source''s own numbering, e.g. "1.1", "6-1.1-1", "6-1.1-1-1", "27-2-2", "Rule 3".',
            'nvarchar',
            120,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '6896c84e-e775-435f-b115-5c193dabb334' OR (EntityID = '9CD2FF63-3EDA-4B18-B7A8-51A2F717E90B' AND Name = 'CitationKey')) BEGIN
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
            '6896c84e-e775-435f-b115-5c193dabb334',
            '9CD2FF63-3EDA-4B18-B7A8-51A2F717E90B', -- Entity: Legal Authority Sections
            100006,
            'CitationKey',
            'Citation Key',
            'Normalized full citation, e.g. "IC 6-1.1-15-17.2" or "50 IAC 26-2-2" -- matches IBTRDecisionCitation.CiteKey''s format so a decision''s citation resolves by string equality.',
            'nvarchar',
            240,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'c940c810-3ef5-4f69-924c-6ff8b9aa0bd8' OR (EntityID = '9CD2FF63-3EDA-4B18-B7A8-51A2F717E90B' AND Name = 'Heading')) BEGIN
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
            'c940c810-3ef5-4f69-924c-6ff8b9aa0bd8',
            '9CD2FF63-3EDA-4B18-B7A8-51A2F717E90B', -- Entity: Legal Authority Sections
            100007,
            'Heading',
            'Heading',
            'The section''s short title/caption, e.g. "Applicability".',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ce56d199-630e-4b61-9b65-ffef32f549c0' OR (EntityID = '9CD2FF63-3EDA-4B18-B7A8-51A2F717E90B' AND Name = 'FullText')) BEGIN
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
            'ce56d199-630e-4b61-9b65-ffef32f549c0',
            '9CD2FF63-3EDA-4B18-B7A8-51A2F717E90B', -- Entity: Legal Authority Sections
            100008,
            'FullText',
            'Full Text',
            'The section''s full text, verbatim. NULL for grouping-only rows (Article/Chapter).',
            'nvarchar',
            -1,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '3e6d600d-1a02-4bd9-84f1-967a7be5750a' OR (EntityID = '9CD2FF63-3EDA-4B18-B7A8-51A2F717E90B' AND Name = 'SourceDocumentID')) BEGIN
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
            '3e6d600d-1a02-4bd9-84f1-967a7be5750a',
            '9CD2FF63-3EDA-4B18-B7A8-51A2F717E90B', -- Entity: Legal Authority Sections
            100009,
            'SourceDocumentID',
            'Source Document ID',
            'The fetched source file this section was parsed from, for provenance.',
            'uniqueidentifier',
            16,
            0,
            0,
            1,
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
            0,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'a1425283-5efd-4593-bba2-5f7600ea40ba' OR (EntityID = '9CD2FF63-3EDA-4B18-B7A8-51A2F717E90B' AND Name = 'SourceURL')) BEGIN
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
            'a1425283-5efd-4593-bba2-5f7600ea40ba',
            '9CD2FF63-3EDA-4B18-B7A8-51A2F717E90B', -- Entity: Legal Authority Sections
            100010,
            'SourceURL',
            'Source URL',
            'A deep link to this specific section at its source, where the source supports anchors.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'c2ec7e99-a2e0-4ae7-b642-4aa7f12ee0eb' OR (EntityID = '9CD2FF63-3EDA-4B18-B7A8-51A2F717E90B' AND Name = '__mj_CreatedAt')) BEGIN
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
            'c2ec7e99-a2e0-4ae7-b642-4aa7f12ee0eb',
            '9CD2FF63-3EDA-4B18-B7A8-51A2F717E90B', -- Entity: Legal Authority Sections
            100011,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'c3cf2f82-3b5a-4b72-8891-630777cb5f0a' OR (EntityID = '9CD2FF63-3EDA-4B18-B7A8-51A2F717E90B' AND Name = '__mj_UpdatedAt')) BEGIN
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
            'c3cf2f82-3b5a-4b72-8891-630777cb5f0a',
            '9CD2FF63-3EDA-4B18-B7A8-51A2F717E90B', -- Entity: Legal Authority Sections
            100012,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'f64bd575-9c5c-4af1-ba4a-6efe8644e8bc' OR (EntityID = '6F48DA55-0427-49E7-878A-70D15C020F9C' AND Name = 'ID')) BEGIN
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
            'f64bd575-9c5c-4af1-ba4a-6efe8644e8bc',
            '6F48DA55-0427-49E7-878A-70D15C020F9C', -- Entity: Legal Authority Chunks
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '187e096c-3875-4cdb-9ded-e6aa3e5ed4d9' OR (EntityID = '6F48DA55-0427-49E7-878A-70D15C020F9C' AND Name = 'LegalAuthoritySectionID')) BEGIN
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
            '187e096c-3875-4cdb-9ded-e6aa3e5ed4d9',
            '6F48DA55-0427-49E7-878A-70D15C020F9C', -- Entity: Legal Authority Chunks
            100002,
            'LegalAuthoritySectionID',
            'Legal Authority Section ID',
            'The section this chunk was cut from.',
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
            '9CD2FF63-3EDA-4B18-B7A8-51A2F717E90B',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'eec7306d-ba21-4333-a923-ce79e0e6a367' OR (EntityID = '6F48DA55-0427-49E7-878A-70D15C020F9C' AND Name = 'Ordinal')) BEGIN
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
            'eec7306d-ba21-4333-a923-ce79e0e6a367',
            '6F48DA55-0427-49E7-878A-70D15C020F9C', -- Entity: Legal Authority Chunks
            100003,
            'Ordinal',
            'Ordinal',
            '0-based order of this chunk within its section.',
            'int',
            4,
            10,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '1f0b698b-fc6c-4839-bf4f-548fdabeb6c4' OR (EntityID = '6F48DA55-0427-49E7-878A-70D15C020F9C' AND Name = 'ChunkText')) BEGIN
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
            '1f0b698b-fc6c-4839-bf4f-548fdabeb6c4',
            '6F48DA55-0427-49E7-878A-70D15C020F9C', -- Entity: Legal Authority Chunks
            100004,
            'ChunkText',
            'Chunk Text',
            'The chunk''s text.',
            'nvarchar',
            -1,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '01bc9001-3209-4cb8-8b04-8e25b12a045e' OR (EntityID = '6F48DA55-0427-49E7-878A-70D15C020F9C' AND Name = 'TokenCount')) BEGIN
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
            '01bc9001-3209-4cb8-8b04-8e25b12a045e',
            '6F48DA55-0427-49E7-878A-70D15C020F9C', -- Entity: Legal Authority Chunks
            100005,
            'TokenCount',
            'Token Count',
            'Approximate token count (chars / 4), matching IBTRDecisionChunk''s convention.',
            'int',
            4,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'c47a8ba3-f4a0-4b49-a118-db29ed88311e' OR (EntityID = '6F48DA55-0427-49E7-878A-70D15C020F9C' AND Name = '__mj_CreatedAt')) BEGIN
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
            'c47a8ba3-f4a0-4b49-a118-db29ed88311e',
            '6F48DA55-0427-49E7-878A-70D15C020F9C', -- Entity: Legal Authority Chunks
            100006,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '0778e927-76b5-4452-ae8e-6d6dc50e58c9' OR (EntityID = '6F48DA55-0427-49E7-878A-70D15C020F9C' AND Name = '__mj_UpdatedAt')) BEGIN
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
            '0778e927-76b5-4452-ae8e-6d6dc50e58c9',
            '6F48DA55-0427-49E7-878A-70D15C020F9C', -- Entity: Legal Authority Chunks
            100007,
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

/* SQL text to insert entity field value with ID dde77f6b-ff85-4d85-a20c-410233545f45 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('dde77f6b-ff85-4d85-a20c-410233545f45', 'CDE21B89-1DBD-420F-829A-B4660A1EFEC7', 1, 'AdminRule', 'AdminRule', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 971b121f-6962-4e40-8f1d-cd202658ba54 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('971b121f-6962-4e40-8f1d-cd202658ba54', 'CDE21B89-1DBD-420F-829A-B4660A1EFEC7', 2, 'Form', 'Form', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID b846a81c-a896-420e-affc-314e325c87b2 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('b846a81c-a896-420e-affc-314e325c87b2', 'CDE21B89-1DBD-420F-829A-B4660A1EFEC7', 3, 'Guideline', 'Guideline', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID a378284e-a875-4fa2-923d-7961a4b380da */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('a378284e-a875-4fa2-923d-7961a4b380da', 'CDE21B89-1DBD-420F-829A-B4660A1EFEC7', 4, 'Manual', 'Manual', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 222bcfd3-3362-4ce7-ae74-d845240cef75 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('222bcfd3-3362-4ce7-ae74-d845240cef75', 'CDE21B89-1DBD-420F-829A-B4660A1EFEC7', 5, 'Memo', 'Memo', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID bb9fc2cf-31e4-4200-aa60-3e9b2b7e046d */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('bb9fc2cf-31e4-4200-aa60-3e9b2b7e046d', 'CDE21B89-1DBD-420F-829A-B4660A1EFEC7', 6, 'ProceduralRule', 'ProceduralRule', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 92f653fc-5165-4244-be98-4ba6cc8e35ce */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('92f653fc-5165-4244-be98-4ba6cc8e35ce', 'CDE21B89-1DBD-420F-829A-B4660A1EFEC7', 7, 'RatioStudyNarrative', 'RatioStudyNarrative', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID d2620a3e-5597-45ab-b144-d108eb5c22ad */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('d2620a3e-5597-45ab-b144-d108eb5c22ad', 'CDE21B89-1DBD-420F-829A-B4660A1EFEC7', 8, 'Statute', 'Statute', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID CDE21B89-1DBD-420F-829A-B4660A1EFEC7 */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='CDE21B89-1DBD-420F-829A-B4660A1EFEC7';

/* SQL text to insert entity field value with ID 26332f58-969b-4cae-b755-96c4ca119dff */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('26332f58-969b-4cae-b755-96c4ca119dff', '37CFA710-842A-4E51-A470-0EB266EE76AE', 1, 'IBTR', 'IBTR', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID ef6c07b0-784a-4d80-92d8-63cc76fdb5a9 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('ef6c07b0-784a-4d80-92d8-63cc76fdb5a9', '37CFA710-842A-4E51-A470-0EB266EE76AE', 2, 'TaxCourt', 'TaxCourt', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 37CFA710-842A-4E51-A470-0EB266EE76AE */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='37CFA710-842A-4E51-A470-0EB266EE76AE';

/* SQL text to insert entity field value with ID 0c707685-4660-40ba-9b85-1a73f7ec42b9 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('0c707685-4660-40ba-9b85-1a73f7ec42b9', 'E7616296-C5EE-4B6D-8CEA-74A099B04343', 1, 'Article', 'Article', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID dc9bc09f-2b67-480a-9a53-268c2031634a */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('dc9bc09f-2b67-480a-9a53-268c2031634a', 'E7616296-C5EE-4B6D-8CEA-74A099B04343', 2, 'Chapter', 'Chapter', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 8ec14122-8aa2-4795-a27d-3ab800a9a127 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('8ec14122-8aa2-4795-a27d-3ab800a9a127', 'E7616296-C5EE-4B6D-8CEA-74A099B04343', 3, 'Form', 'Form', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID c36618d2-00d9-40c6-a79a-81155800cee6 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('c36618d2-00d9-40c6-a79a-81155800cee6', 'E7616296-C5EE-4B6D-8CEA-74A099B04343', 4, 'Part', 'Part', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 14c1fd5c-2797-441d-8480-b2e85a4a6fa9 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('14c1fd5c-2797-441d-8480-b2e85a4a6fa9', 'E7616296-C5EE-4B6D-8CEA-74A099B04343', 5, 'Rule', 'Rule', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 14dfb0c5-c7de-4ed7-9907-d116488c3287 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('14dfb0c5-c7de-4ed7-9907-d116488c3287', 'E7616296-C5EE-4B6D-8CEA-74A099B04343', 6, 'Section', 'Section', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID E7616296-C5EE-4B6D-8CEA-74A099B04343 */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='E7616296-C5EE-4B6D-8CEA-74A099B04343';


/* Create Entity Relationship: Source Documents -> Legal Authorities (One To Many via SourceDocumentID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'a9eb1cc9-cd6b-4cae-b46f-9f29c6dc5905'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('a9eb1cc9-cd6b-4cae-b46f-9f29c6dc5905', '30AF9254-9D7A-442A-A064-0B4448E21AB1', '4C07018C-418E-409C-958A-2B39F9BAF36B', 'SourceDocumentID', 'One To Many', 1, 1, 37, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: Source Documents -> Legal Authority Sections (One To Many via SourceDocumentID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '37300d1c-2057-42b3-84b4-3fe4caf5693e'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('37300d1c-2057-42b3-84b4-3fe4caf5693e', '30AF9254-9D7A-442A-A064-0B4448E21AB1', '9CD2FF63-3EDA-4B18-B7A8-51A2F717E90B', 'SourceDocumentID', 'One To Many', 1, 1, 38, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: Legal Authorities -> Legal Authority Sections (One To Many via LegalAuthorityID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '86bdb0e7-8acf-4ac8-953d-db901f35a2c1'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('86bdb0e7-8acf-4ac8-953d-db901f35a2c1', '4C07018C-418E-409C-958A-2B39F9BAF36B', '9CD2FF63-3EDA-4B18-B7A8-51A2F717E90B', 'LegalAuthorityID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: Legal Authority Sections -> Legal Authority Chunks (One To Many via LegalAuthoritySectionID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '9dd1fb5b-2916-4666-994b-741e51e439b9'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('9dd1fb5b-2916-4666-994b-741e51e439b9', '9CD2FF63-3EDA-4B18-B7A8-51A2F717E90B', '6F48DA55-0427-49E7-878A-70D15C020F9C', 'LegalAuthoritySectionID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: Legal Authority Sections -> IBTR Decision Citations (One To Many via ResolvedLegalAuthoritySectionID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'e89738ad-0a7c-45e8-872a-b46ec9e77e77'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('e89738ad-0a7c-45e8-872a-b46ec9e77e77', '9CD2FF63-3EDA-4B18-B7A8-51A2F717E90B', '8FCB213B-2FCE-4DE0-AEEA-3CDA0D4D641B', 'ResolvedLegalAuthoritySectionID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: Legal Authority Sections -> Legal Authority Sections (One To Many via ParentSectionID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '08a3cb21-a907-4ec1-8cb1-0796f80fe245'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('08a3cb21-a907-4ec1-8cb1-0796f80fe245', '9CD2FF63-3EDA-4B18-B7A8-51A2F717E90B', '9CD2FF63-3EDA-4B18-B7A8-51A2F717E90B', 'ParentSectionID', 'One To Many', 1, 1, 3, GETUTCDATE(), GETUTCDATE())
   END;

/* SQL text to update virtual entity field UnverifiedCompCount for entity Store Analysis */
UPDATE
                                    [${flyway:defaultSchema}].[EntityField]
                                  SET
                                    Sequence=70,
                                    Type='int',
                                    AllowsNull=1,
                                    
                                    Length=4,
                                    Precision=10,
                                    Scale=0
                                  WHERE
                                    ID = '377D324C-20CB-4A76-AB06-CB439830F01E';

/* Index for Foreign Keys for IBTRDecisionCitation */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: IBTR Decision Citations
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key IBTRAppealID in table IBTRDecisionCitation
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_IBTRDecisionCitation_IBTRAppealID' 
    AND object_id = OBJECT_ID('[indiana_tax].[IBTRDecisionCitation]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_IBTRDecisionCitation_IBTRAppealID ON [indiana_tax].[IBTRDecisionCitation] ([IBTRAppealID]);

-- Index for foreign key ResolvedLegalAuthoritySectionID in table IBTRDecisionCitation
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_IBTRDecisionCitation_ResolvedLegalAuthoritySectionID' 
    AND object_id = OBJECT_ID('[indiana_tax].[IBTRDecisionCitation]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_IBTRDecisionCitation_ResolvedLegalAuthoritySectionID ON [indiana_tax].[IBTRDecisionCitation] ([ResolvedLegalAuthoritySectionID]);

/* Base View SQL for IBTR Decision Citations */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: IBTR Decision Citations
-- Item: vwIBTRDecisionCitations
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      IBTR Decision Citations
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  IBTRDecisionCitation
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwIBTRDecisionCitations]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwIBTRDecisionCitations];
GO

CREATE VIEW [indiana_tax].[vwIBTRDecisionCitations]
AS
SELECT
    i.*
FROM
    [indiana_tax].[IBTRDecisionCitation] AS i
GO
GRANT SELECT ON [indiana_tax].[vwIBTRDecisionCitations] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for IBTR Decision Citations */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: IBTR Decision Citations
-- Item: Permissions for vwIBTRDecisionCitations
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwIBTRDecisionCitations] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for IBTR Decision Citations */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: IBTR Decision Citations
-- Item: spCreateIBTRDecisionCitation
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR IBTRDecisionCitation
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateIBTRDecisionCitation]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateIBTRDecisionCitation];
GO

CREATE PROCEDURE [indiana_tax].[spCreateIBTRDecisionCitation]
    @ID uniqueidentifier = NULL,
    @IBTRAppealID uniqueidentifier,
    @AuthorityType nvarchar(20),
    @CiteKey nvarchar(200),
    @CaseName_Clear bit = 0,
    @CaseName nvarchar(300) = NULL,
    @Court_Clear bit = 0,
    @Court nvarchar(30) = NULL,
    @Year_Clear bit = 0,
    @Year smallint = NULL,
    @Subsection_Clear bit = 0,
    @Subsection nvarchar(100) = NULL,
    @MentionCount int,
    @ResolvedLegalAuthoritySectionID_Clear bit = 0,
    @ResolvedLegalAuthoritySectionID uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[IBTRDecisionCitation]
            (
                [ID],
                [IBTRAppealID],
                [AuthorityType],
                [CiteKey],
                [CaseName],
                [Court],
                [Year],
                [Subsection],
                [MentionCount],
                [ResolvedLegalAuthoritySectionID]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @IBTRAppealID,
                @AuthorityType,
                @CiteKey,
                CASE WHEN @CaseName_Clear = 1 THEN NULL ELSE ISNULL(@CaseName, NULL) END,
                CASE WHEN @Court_Clear = 1 THEN NULL ELSE ISNULL(@Court, NULL) END,
                CASE WHEN @Year_Clear = 1 THEN NULL ELSE ISNULL(@Year, NULL) END,
                CASE WHEN @Subsection_Clear = 1 THEN NULL ELSE ISNULL(@Subsection, NULL) END,
                @MentionCount,
                CASE WHEN @ResolvedLegalAuthoritySectionID_Clear = 1 THEN NULL ELSE ISNULL(@ResolvedLegalAuthoritySectionID, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[IBTRDecisionCitation]
            (
                [IBTRAppealID],
                [AuthorityType],
                [CiteKey],
                [CaseName],
                [Court],
                [Year],
                [Subsection],
                [MentionCount],
                [ResolvedLegalAuthoritySectionID]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @IBTRAppealID,
                @AuthorityType,
                @CiteKey,
                CASE WHEN @CaseName_Clear = 1 THEN NULL ELSE ISNULL(@CaseName, NULL) END,
                CASE WHEN @Court_Clear = 1 THEN NULL ELSE ISNULL(@Court, NULL) END,
                CASE WHEN @Year_Clear = 1 THEN NULL ELSE ISNULL(@Year, NULL) END,
                CASE WHEN @Subsection_Clear = 1 THEN NULL ELSE ISNULL(@Subsection, NULL) END,
                @MentionCount,
                CASE WHEN @ResolvedLegalAuthoritySectionID_Clear = 1 THEN NULL ELSE ISNULL(@ResolvedLegalAuthoritySectionID, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwIBTRDecisionCitations] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateIBTRDecisionCitation] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for IBTR Decision Citations */

GRANT EXECUTE ON [indiana_tax].[spCreateIBTRDecisionCitation] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for IBTR Decision Citations */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: IBTR Decision Citations
-- Item: spUpdateIBTRDecisionCitation
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR IBTRDecisionCitation
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateIBTRDecisionCitation]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateIBTRDecisionCitation];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateIBTRDecisionCitation]
    @ID uniqueidentifier,
    @IBTRAppealID uniqueidentifier = NULL,
    @AuthorityType nvarchar(20) = NULL,
    @CiteKey nvarchar(200) = NULL,
    @CaseName_Clear bit = 0,
    @CaseName nvarchar(300) = NULL,
    @Court_Clear bit = 0,
    @Court nvarchar(30) = NULL,
    @Year_Clear bit = 0,
    @Year smallint = NULL,
    @Subsection_Clear bit = 0,
    @Subsection nvarchar(100) = NULL,
    @MentionCount int = NULL,
    @ResolvedLegalAuthoritySectionID_Clear bit = 0,
    @ResolvedLegalAuthoritySectionID uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[IBTRDecisionCitation]
    SET
        [IBTRAppealID] = ISNULL(@IBTRAppealID, [IBTRAppealID]),
        [AuthorityType] = ISNULL(@AuthorityType, [AuthorityType]),
        [CiteKey] = ISNULL(@CiteKey, [CiteKey]),
        [CaseName] = CASE WHEN @CaseName_Clear = 1 THEN NULL ELSE ISNULL(@CaseName, [CaseName]) END,
        [Court] = CASE WHEN @Court_Clear = 1 THEN NULL ELSE ISNULL(@Court, [Court]) END,
        [Year] = CASE WHEN @Year_Clear = 1 THEN NULL ELSE ISNULL(@Year, [Year]) END,
        [Subsection] = CASE WHEN @Subsection_Clear = 1 THEN NULL ELSE ISNULL(@Subsection, [Subsection]) END,
        [MentionCount] = ISNULL(@MentionCount, [MentionCount]),
        [ResolvedLegalAuthoritySectionID] = CASE WHEN @ResolvedLegalAuthoritySectionID_Clear = 1 THEN NULL ELSE ISNULL(@ResolvedLegalAuthoritySectionID, [ResolvedLegalAuthoritySectionID]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwIBTRDecisionCitations] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwIBTRDecisionCitations]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateIBTRDecisionCitation] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the IBTRDecisionCitation table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateIBTRDecisionCitation]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateIBTRDecisionCitation];
GO
CREATE TRIGGER [indiana_tax].trgUpdateIBTRDecisionCitation
ON [indiana_tax].[IBTRDecisionCitation]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[IBTRDecisionCitation]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[IBTRDecisionCitation] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for IBTR Decision Citations */

GRANT EXECUTE ON [indiana_tax].[spUpdateIBTRDecisionCitation] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for IBTR Decision Citations */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: IBTR Decision Citations
-- Item: spDeleteIBTRDecisionCitation
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR IBTRDecisionCitation
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteIBTRDecisionCitation]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteIBTRDecisionCitation];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteIBTRDecisionCitation]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[IBTRDecisionCitation]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteIBTRDecisionCitation] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for IBTR Decision Citations */

GRANT EXECUTE ON [indiana_tax].[spDeleteIBTRDecisionCitation] TO [cdp_Developer], [cdp_Integration];

/* Index for Foreign Keys for LegalAuthority */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Legal Authorities
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key SourceDocumentID in table LegalAuthority
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_LegalAuthority_SourceDocumentID' 
    AND object_id = OBJECT_ID('[indiana_tax].[LegalAuthority]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_LegalAuthority_SourceDocumentID ON [indiana_tax].[LegalAuthority] ([SourceDocumentID]);

/* Index for Foreign Keys for LegalAuthorityChunk */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Legal Authority Chunks
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key LegalAuthoritySectionID in table LegalAuthorityChunk
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_LegalAuthorityChunk_LegalAuthoritySectionID' 
    AND object_id = OBJECT_ID('[indiana_tax].[LegalAuthorityChunk]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_LegalAuthorityChunk_LegalAuthoritySectionID ON [indiana_tax].[LegalAuthorityChunk] ([LegalAuthoritySectionID]);

/* Base View SQL for Legal Authorities */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Legal Authorities
-- Item: vwLegalAuthorities
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Legal Authorities
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  LegalAuthority
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwLegalAuthorities]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwLegalAuthorities];
GO

CREATE VIEW [indiana_tax].[vwLegalAuthorities]
AS
SELECT
    l.*
FROM
    [indiana_tax].[LegalAuthority] AS l
GO
GRANT SELECT ON [indiana_tax].[vwLegalAuthorities] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for Legal Authorities */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Legal Authorities
-- Item: Permissions for vwLegalAuthorities
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwLegalAuthorities] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for Legal Authorities */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Legal Authorities
-- Item: spCreateLegalAuthority
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR LegalAuthority
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateLegalAuthority]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateLegalAuthority];
GO

CREATE PROCEDURE [indiana_tax].[spCreateLegalAuthority]
    @ID uniqueidentifier = NULL,
    @SourceType nvarchar(30),
    @Forum_Clear bit = 0,
    @Forum nvarchar(20) = NULL,
    @Title nvarchar(300),
    @AsOfDate_Clear bit = 0,
    @AsOfDate date = NULL,
    @SourceDocumentID_Clear bit = 0,
    @SourceDocumentID uniqueidentifier = NULL,
    @SourceURL_Clear bit = 0,
    @SourceURL nvarchar(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[LegalAuthority]
            (
                [ID],
                [SourceType],
                [Forum],
                [Title],
                [AsOfDate],
                [SourceDocumentID],
                [SourceURL]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @SourceType,
                CASE WHEN @Forum_Clear = 1 THEN NULL ELSE ISNULL(@Forum, NULL) END,
                @Title,
                CASE WHEN @AsOfDate_Clear = 1 THEN NULL ELSE ISNULL(@AsOfDate, NULL) END,
                CASE WHEN @SourceDocumentID_Clear = 1 THEN NULL ELSE ISNULL(@SourceDocumentID, NULL) END,
                CASE WHEN @SourceURL_Clear = 1 THEN NULL ELSE ISNULL(@SourceURL, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[LegalAuthority]
            (
                [SourceType],
                [Forum],
                [Title],
                [AsOfDate],
                [SourceDocumentID],
                [SourceURL]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @SourceType,
                CASE WHEN @Forum_Clear = 1 THEN NULL ELSE ISNULL(@Forum, NULL) END,
                @Title,
                CASE WHEN @AsOfDate_Clear = 1 THEN NULL ELSE ISNULL(@AsOfDate, NULL) END,
                CASE WHEN @SourceDocumentID_Clear = 1 THEN NULL ELSE ISNULL(@SourceDocumentID, NULL) END,
                CASE WHEN @SourceURL_Clear = 1 THEN NULL ELSE ISNULL(@SourceURL, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwLegalAuthorities] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateLegalAuthority] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for Legal Authorities */

GRANT EXECUTE ON [indiana_tax].[spCreateLegalAuthority] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for Legal Authorities */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Legal Authorities
-- Item: spUpdateLegalAuthority
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR LegalAuthority
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateLegalAuthority]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateLegalAuthority];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateLegalAuthority]
    @ID uniqueidentifier,
    @SourceType nvarchar(30) = NULL,
    @Forum_Clear bit = 0,
    @Forum nvarchar(20) = NULL,
    @Title nvarchar(300) = NULL,
    @AsOfDate_Clear bit = 0,
    @AsOfDate date = NULL,
    @SourceDocumentID_Clear bit = 0,
    @SourceDocumentID uniqueidentifier = NULL,
    @SourceURL_Clear bit = 0,
    @SourceURL nvarchar(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[LegalAuthority]
    SET
        [SourceType] = ISNULL(@SourceType, [SourceType]),
        [Forum] = CASE WHEN @Forum_Clear = 1 THEN NULL ELSE ISNULL(@Forum, [Forum]) END,
        [Title] = ISNULL(@Title, [Title]),
        [AsOfDate] = CASE WHEN @AsOfDate_Clear = 1 THEN NULL ELSE ISNULL(@AsOfDate, [AsOfDate]) END,
        [SourceDocumentID] = CASE WHEN @SourceDocumentID_Clear = 1 THEN NULL ELSE ISNULL(@SourceDocumentID, [SourceDocumentID]) END,
        [SourceURL] = CASE WHEN @SourceURL_Clear = 1 THEN NULL ELSE ISNULL(@SourceURL, [SourceURL]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwLegalAuthorities] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwLegalAuthorities]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateLegalAuthority] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the LegalAuthority table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateLegalAuthority]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateLegalAuthority];
GO
CREATE TRIGGER [indiana_tax].trgUpdateLegalAuthority
ON [indiana_tax].[LegalAuthority]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[LegalAuthority]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[LegalAuthority] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for Legal Authorities */

GRANT EXECUTE ON [indiana_tax].[spUpdateLegalAuthority] TO [cdp_Developer], [cdp_Integration];

/* Base View SQL for Legal Authority Chunks */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Legal Authority Chunks
-- Item: vwLegalAuthorityChunks
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Legal Authority Chunks
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  LegalAuthorityChunk
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwLegalAuthorityChunks]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwLegalAuthorityChunks];
GO

CREATE VIEW [indiana_tax].[vwLegalAuthorityChunks]
AS
SELECT
    l.*
FROM
    [indiana_tax].[LegalAuthorityChunk] AS l
GO
GRANT SELECT ON [indiana_tax].[vwLegalAuthorityChunks] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for Legal Authority Chunks */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Legal Authority Chunks
-- Item: Permissions for vwLegalAuthorityChunks
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwLegalAuthorityChunks] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for Legal Authority Chunks */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Legal Authority Chunks
-- Item: spCreateLegalAuthorityChunk
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR LegalAuthorityChunk
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateLegalAuthorityChunk]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateLegalAuthorityChunk];
GO

CREATE PROCEDURE [indiana_tax].[spCreateLegalAuthorityChunk]
    @ID uniqueidentifier = NULL,
    @LegalAuthoritySectionID uniqueidentifier,
    @Ordinal int,
    @ChunkText nvarchar(MAX),
    @TokenCount_Clear bit = 0,
    @TokenCount int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[LegalAuthorityChunk]
            (
                [ID],
                [LegalAuthoritySectionID],
                [Ordinal],
                [ChunkText],
                [TokenCount]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @LegalAuthoritySectionID,
                @Ordinal,
                @ChunkText,
                CASE WHEN @TokenCount_Clear = 1 THEN NULL ELSE ISNULL(@TokenCount, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[LegalAuthorityChunk]
            (
                [LegalAuthoritySectionID],
                [Ordinal],
                [ChunkText],
                [TokenCount]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @LegalAuthoritySectionID,
                @Ordinal,
                @ChunkText,
                CASE WHEN @TokenCount_Clear = 1 THEN NULL ELSE ISNULL(@TokenCount, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwLegalAuthorityChunks] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateLegalAuthorityChunk] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for Legal Authority Chunks */

GRANT EXECUTE ON [indiana_tax].[spCreateLegalAuthorityChunk] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for Legal Authority Chunks */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Legal Authority Chunks
-- Item: spUpdateLegalAuthorityChunk
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR LegalAuthorityChunk
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateLegalAuthorityChunk]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateLegalAuthorityChunk];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateLegalAuthorityChunk]
    @ID uniqueidentifier,
    @LegalAuthoritySectionID uniqueidentifier = NULL,
    @Ordinal int = NULL,
    @ChunkText nvarchar(MAX) = NULL,
    @TokenCount_Clear bit = 0,
    @TokenCount int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[LegalAuthorityChunk]
    SET
        [LegalAuthoritySectionID] = ISNULL(@LegalAuthoritySectionID, [LegalAuthoritySectionID]),
        [Ordinal] = ISNULL(@Ordinal, [Ordinal]),
        [ChunkText] = ISNULL(@ChunkText, [ChunkText]),
        [TokenCount] = CASE WHEN @TokenCount_Clear = 1 THEN NULL ELSE ISNULL(@TokenCount, [TokenCount]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwLegalAuthorityChunks] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwLegalAuthorityChunks]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateLegalAuthorityChunk] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the LegalAuthorityChunk table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateLegalAuthorityChunk]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateLegalAuthorityChunk];
GO
CREATE TRIGGER [indiana_tax].trgUpdateLegalAuthorityChunk
ON [indiana_tax].[LegalAuthorityChunk]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[LegalAuthorityChunk]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[LegalAuthorityChunk] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for Legal Authority Chunks */

GRANT EXECUTE ON [indiana_tax].[spUpdateLegalAuthorityChunk] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for Legal Authorities */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Legal Authorities
-- Item: spDeleteLegalAuthority
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR LegalAuthority
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteLegalAuthority]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteLegalAuthority];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteLegalAuthority]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[LegalAuthority]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteLegalAuthority] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for Legal Authorities */

GRANT EXECUTE ON [indiana_tax].[spDeleteLegalAuthority] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for Legal Authority Chunks */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Legal Authority Chunks
-- Item: spDeleteLegalAuthorityChunk
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR LegalAuthorityChunk
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteLegalAuthorityChunk]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteLegalAuthorityChunk];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteLegalAuthorityChunk]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[LegalAuthorityChunk]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteLegalAuthorityChunk] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for Legal Authority Chunks */

GRANT EXECUTE ON [indiana_tax].[spDeleteLegalAuthorityChunk] TO [cdp_Developer], [cdp_Integration];

/* Index for Foreign Keys for LegalAuthoritySection */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Legal Authority Sections
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key LegalAuthorityID in table LegalAuthoritySection
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_LegalAuthoritySection_LegalAuthorityID' 
    AND object_id = OBJECT_ID('[indiana_tax].[LegalAuthoritySection]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_LegalAuthoritySection_LegalAuthorityID ON [indiana_tax].[LegalAuthoritySection] ([LegalAuthorityID]);

-- Index for foreign key ParentSectionID in table LegalAuthoritySection
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_LegalAuthoritySection_ParentSectionID' 
    AND object_id = OBJECT_ID('[indiana_tax].[LegalAuthoritySection]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_LegalAuthoritySection_ParentSectionID ON [indiana_tax].[LegalAuthoritySection] ([ParentSectionID]);

-- Index for foreign key SourceDocumentID in table LegalAuthoritySection
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_LegalAuthoritySection_SourceDocumentID' 
    AND object_id = OBJECT_ID('[indiana_tax].[LegalAuthoritySection]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_LegalAuthoritySection_SourceDocumentID ON [indiana_tax].[LegalAuthoritySection] ([SourceDocumentID]);

/* Root ID Function SQL for Legal Authority Sections.ParentSectionID */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Legal Authority Sections
-- Item: fnLegalAuthoritySectionParentSectionID_GetRootID
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
------------------------------------------------------------
----- ROOT ID FUNCTION FOR: [LegalAuthoritySection].[ParentSectionID]
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[fnLegalAuthoritySectionParentSectionID_GetRootID]', 'IF') IS NOT NULL
    DROP FUNCTION [indiana_tax].[fnLegalAuthoritySectionParentSectionID_GetRootID];
GO

CREATE FUNCTION [indiana_tax].[fnLegalAuthoritySectionParentSectionID_GetRootID]
(
    @RecordID uniqueidentifier,
    @ParentID uniqueidentifier
)
RETURNS TABLE
AS
RETURN
(
    WITH CTE_RootParent AS (
        SELECT
            [ID],
            [ParentSectionID],
            [ID] AS [RootParentID],
            0 AS [Depth]
        FROM
            [indiana_tax].[LegalAuthoritySection]
        WHERE
            [ID] = COALESCE(@ParentID, @RecordID)

        UNION ALL

        SELECT
            c.[ID],
            c.[ParentSectionID],
            c.[ID] AS [RootParentID],
            p.[Depth] + 1 AS [Depth]
        FROM
            [indiana_tax].[LegalAuthoritySection] c
        INNER JOIN
            CTE_RootParent p ON c.[ID] = p.[ParentSectionID]
        WHERE
            p.[Depth] < 100
    )
    SELECT TOP 1
        [RootParentID] AS RootID
    FROM
        CTE_RootParent
    WHERE
        [ParentSectionID] IS NULL
    ORDER BY
        [RootParentID]
);
GO

/* Base View SQL for Legal Authority Sections */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Legal Authority Sections
-- Item: vwLegalAuthoritySections
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Legal Authority Sections
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  LegalAuthoritySection
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwLegalAuthoritySections]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwLegalAuthoritySections];
GO

CREATE VIEW [indiana_tax].[vwLegalAuthoritySections]
AS
SELECT
    l.*,
    root_ParentSectionID.RootID AS [RootParentSectionID]
FROM
    [indiana_tax].[LegalAuthoritySection] AS l
OUTER APPLY
    [indiana_tax].[fnLegalAuthoritySectionParentSectionID_GetRootID]([l].[ID], [l].[ParentSectionID]) AS root_ParentSectionID
GO
GRANT SELECT ON [indiana_tax].[vwLegalAuthoritySections] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for Legal Authority Sections */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Legal Authority Sections
-- Item: Permissions for vwLegalAuthoritySections
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwLegalAuthoritySections] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for Legal Authority Sections */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Legal Authority Sections
-- Item: spCreateLegalAuthoritySection
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR LegalAuthoritySection
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateLegalAuthoritySection]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateLegalAuthoritySection];
GO

CREATE PROCEDURE [indiana_tax].[spCreateLegalAuthoritySection]
    @ID uniqueidentifier = NULL,
    @LegalAuthorityID uniqueidentifier,
    @ParentSectionID_Clear bit = 0,
    @ParentSectionID uniqueidentifier = NULL,
    @SectionLevel nvarchar(20),
    @SectionNumber nvarchar(60),
    @CitationKey nvarchar(120),
    @Heading_Clear bit = 0,
    @Heading nvarchar(500) = NULL,
    @FullText_Clear bit = 0,
    @FullText nvarchar(MAX) = NULL,
    @SourceDocumentID_Clear bit = 0,
    @SourceDocumentID uniqueidentifier = NULL,
    @SourceURL_Clear bit = 0,
    @SourceURL nvarchar(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[LegalAuthoritySection]
            (
                [ID],
                [LegalAuthorityID],
                [ParentSectionID],
                [SectionLevel],
                [SectionNumber],
                [CitationKey],
                [Heading],
                [FullText],
                [SourceDocumentID],
                [SourceURL]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @LegalAuthorityID,
                CASE WHEN @ParentSectionID_Clear = 1 THEN NULL ELSE ISNULL(@ParentSectionID, NULL) END,
                @SectionLevel,
                @SectionNumber,
                @CitationKey,
                CASE WHEN @Heading_Clear = 1 THEN NULL ELSE ISNULL(@Heading, NULL) END,
                CASE WHEN @FullText_Clear = 1 THEN NULL ELSE ISNULL(@FullText, NULL) END,
                CASE WHEN @SourceDocumentID_Clear = 1 THEN NULL ELSE ISNULL(@SourceDocumentID, NULL) END,
                CASE WHEN @SourceURL_Clear = 1 THEN NULL ELSE ISNULL(@SourceURL, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[LegalAuthoritySection]
            (
                [LegalAuthorityID],
                [ParentSectionID],
                [SectionLevel],
                [SectionNumber],
                [CitationKey],
                [Heading],
                [FullText],
                [SourceDocumentID],
                [SourceURL]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @LegalAuthorityID,
                CASE WHEN @ParentSectionID_Clear = 1 THEN NULL ELSE ISNULL(@ParentSectionID, NULL) END,
                @SectionLevel,
                @SectionNumber,
                @CitationKey,
                CASE WHEN @Heading_Clear = 1 THEN NULL ELSE ISNULL(@Heading, NULL) END,
                CASE WHEN @FullText_Clear = 1 THEN NULL ELSE ISNULL(@FullText, NULL) END,
                CASE WHEN @SourceDocumentID_Clear = 1 THEN NULL ELSE ISNULL(@SourceDocumentID, NULL) END,
                CASE WHEN @SourceURL_Clear = 1 THEN NULL ELSE ISNULL(@SourceURL, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwLegalAuthoritySections] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateLegalAuthoritySection] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for Legal Authority Sections */

GRANT EXECUTE ON [indiana_tax].[spCreateLegalAuthoritySection] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for Legal Authority Sections */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Legal Authority Sections
-- Item: spUpdateLegalAuthoritySection
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR LegalAuthoritySection
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateLegalAuthoritySection]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateLegalAuthoritySection];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateLegalAuthoritySection]
    @ID uniqueidentifier,
    @LegalAuthorityID uniqueidentifier = NULL,
    @ParentSectionID_Clear bit = 0,
    @ParentSectionID uniqueidentifier = NULL,
    @SectionLevel nvarchar(20) = NULL,
    @SectionNumber nvarchar(60) = NULL,
    @CitationKey nvarchar(120) = NULL,
    @Heading_Clear bit = 0,
    @Heading nvarchar(500) = NULL,
    @FullText_Clear bit = 0,
    @FullText nvarchar(MAX) = NULL,
    @SourceDocumentID_Clear bit = 0,
    @SourceDocumentID uniqueidentifier = NULL,
    @SourceURL_Clear bit = 0,
    @SourceURL nvarchar(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[LegalAuthoritySection]
    SET
        [LegalAuthorityID] = ISNULL(@LegalAuthorityID, [LegalAuthorityID]),
        [ParentSectionID] = CASE WHEN @ParentSectionID_Clear = 1 THEN NULL ELSE ISNULL(@ParentSectionID, [ParentSectionID]) END,
        [SectionLevel] = ISNULL(@SectionLevel, [SectionLevel]),
        [SectionNumber] = ISNULL(@SectionNumber, [SectionNumber]),
        [CitationKey] = ISNULL(@CitationKey, [CitationKey]),
        [Heading] = CASE WHEN @Heading_Clear = 1 THEN NULL ELSE ISNULL(@Heading, [Heading]) END,
        [FullText] = CASE WHEN @FullText_Clear = 1 THEN NULL ELSE ISNULL(@FullText, [FullText]) END,
        [SourceDocumentID] = CASE WHEN @SourceDocumentID_Clear = 1 THEN NULL ELSE ISNULL(@SourceDocumentID, [SourceDocumentID]) END,
        [SourceURL] = CASE WHEN @SourceURL_Clear = 1 THEN NULL ELSE ISNULL(@SourceURL, [SourceURL]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwLegalAuthoritySections] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwLegalAuthoritySections]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateLegalAuthoritySection] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the LegalAuthoritySection table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateLegalAuthoritySection]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateLegalAuthoritySection];
GO
CREATE TRIGGER [indiana_tax].trgUpdateLegalAuthoritySection
ON [indiana_tax].[LegalAuthoritySection]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[LegalAuthoritySection]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[LegalAuthoritySection] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for Legal Authority Sections */

GRANT EXECUTE ON [indiana_tax].[spUpdateLegalAuthoritySection] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for Legal Authority Sections */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Legal Authority Sections
-- Item: spDeleteLegalAuthoritySection
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR LegalAuthoritySection
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteLegalAuthoritySection]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteLegalAuthoritySection];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteLegalAuthoritySection]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[LegalAuthoritySection]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteLegalAuthoritySection] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for Legal Authority Sections */

GRANT EXECUTE ON [indiana_tax].[spDeleteLegalAuthoritySection] TO [cdp_Developer], [cdp_Integration];

/* SQL text to insert 1 new entity field(s) */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '042c6718-3a49-4888-893a-b255c286095a' OR (EntityID = '9CD2FF63-3EDA-4B18-B7A8-51A2F717E90B' AND Name = 'RootParentSectionID')) BEGIN
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
            '042c6718-3a49-4888-893a-b255c286095a',
            '9CD2FF63-3EDA-4B18-B7A8-51A2F717E90B', -- Entity: Legal Authority Sections
            100025,
            'RootParentSectionID',
            'Root Parent Section ID',
            NULL,
            'uniqueidentifier',
            16,
            0,
            0,
            1,
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

/* Set field properties for entity */

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'EEC7306D-BA21-4333-A923-CE79E0E6A367'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '1F0B698B-FC6C-4839-BF4F-548FDABEB6C4'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '01BC9001-3209-4CB8-8B04-8E25B12A045E'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '1F0B698B-FC6C-4839-BF4F-548FDABEB6C4'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

/* Set field properties for entity */

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IsNameField = 1
               WHERE ID = 'FFF0A61C-58F3-4E42-B0F5-05CC6EC384EB'
               AND AutoUpdateIsNameField = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '3CEEA54D-23AD-438F-9DAB-F1BA7B9DA618'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'FFF0A61C-58F3-4E42-B0F5-05CC6EC384EB'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '23BFF797-467A-4647-B694-B8A3F81BB472'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'E53B6427-E0B0-49CC-B695-A1A82204934D'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = 'FFF0A61C-58F3-4E42-B0F5-05CC6EC384EB'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '23BFF797-467A-4647-B694-B8A3F81BB472'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = 'FFF0A61C-58F3-4E42-B0F5-05CC6EC384EB'
               AND AutoUpdateUserSearchPredicate = 1;

/* Set field properties for entity */

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IsNameField = 1
               WHERE ID = '5A3D7F44-A74A-45FE-BDDB-B7BAFFE493F1'
               AND AutoUpdateIsNameField = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'CDE21B89-1DBD-420F-829A-B4660A1EFEC7'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '5A3D7F44-A74A-45FE-BDDB-B7BAFFE493F1'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'A7F7C755-BE3A-47E7-BFCA-852E374A42A1'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = 'CDE21B89-1DBD-420F-829A-B4660A1EFEC7'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '5A3D7F44-A74A-45FE-BDDB-B7BAFFE493F1'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = '5A3D7F44-A74A-45FE-BDDB-B7BAFFE493F1'
               AND AutoUpdateUserSearchPredicate = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = 'CDE21B89-1DBD-420F-829A-B4660A1EFEC7'
               AND AutoUpdateUserSearchPredicate = 1;

/* Set field properties for entity */

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IsNameField = 1
               WHERE ID = '6896C84E-E775-435F-B115-5C193DABB334'
               AND AutoUpdateIsNameField = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'E7616296-C5EE-4B6D-8CEA-74A099B04343'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'DD6992EE-8630-4A22-8DC6-618BB79FD0AA'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '6896C84E-E775-435F-B115-5C193DABB334'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'C940C810-3EF5-4F69-924C-6FF8B9AA0BD8'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = 'DD6992EE-8630-4A22-8DC6-618BB79FD0AA'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '6896C84E-E775-435F-B115-5C193DABB334'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = 'C940C810-3EF5-4F69-924C-6FF8B9AA0BD8'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'Exact'
               WHERE ID = '6896C84E-E775-435F-B115-5C193DABB334'
               AND AutoUpdateUserSearchPredicate = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = 'DD6992EE-8630-4A22-8DC6-618BB79FD0AA'
               AND AutoUpdateUserSearchPredicate = 1;

/* Set categories for 7 fields */

-- UPDATE Entity Field Category Info Legal Authority Chunks.ID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'F64BD575-9C5C-4AF1-BA4A-6EFE8644E8BC' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Legal Authority Chunks.LegalAuthoritySectionID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Chunk Source',
   GeneratedFormSection = 'Category',
   DisplayName = 'Legal Authority Section',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '187E096C-3875-4CDB-9DED-E6AA3E5ED4D9' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Legal Authority Chunks.Ordinal 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Chunk Source',
   GeneratedFormSection = 'Category',
   DisplayName = 'Ordinal Position',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'EEC7306D-BA21-4333-A923-CE79E0E6A367' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Legal Authority Chunks.ChunkText 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Chunk Content',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '1F0B698B-FC6C-4839-BF4F-548FDABEB6C4' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Legal Authority Chunks.TokenCount 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Chunk Content',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '01BC9001-3209-4CB8-8B04-8E25B12A045E' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Legal Authority Chunks.__mj_CreatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'C47A8BA3-F4A0-4B49-A118-DB29ED88311E' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Legal Authority Chunks.__mj_UpdatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '0778E927-76B5-4452-AE8E-6D6DC50E58C9' AND AutoUpdateCategory = 1;

/* Set entity icon to fa fa-file-alt */

               UPDATE [${flyway:defaultSchema}].[Entity]
               SET [Icon] = 'fa fa-file-alt', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = '6F48DA55-0427-49E7-878A-70D15C020F9C';

/* Insert FieldCategoryInfo setting for entity */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('7b511df2-3f1a-461b-929b-60c8a619e03b', '6F48DA55-0427-49E7-878A-70D15C020F9C', 'FieldCategoryInfo', '{"Chunk Source":{"icon":"fa fa-link","description":"Reference to the parent legal authority section and chunk position"},"Chunk Content":{"icon":"fa fa-align-left","description":"The text content of the legal passage and its metrics"},"System Metadata":{"icon":"fa fa-cog","description":"System-managed audit and tracking fields"}}', GETUTCDATE(), GETUTCDATE());

/* Insert FieldCategoryIcons setting (legacy) */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('28b3ee25-02d6-4548-9851-572972d157f4', '6F48DA55-0427-49E7-878A-70D15C020F9C', 'FieldCategoryIcons', '{"Chunk Source":"fa fa-link","Chunk Content":"fa fa-align-left","System Metadata":"fa fa-cog"}', GETUTCDATE(), GETUTCDATE());

/* Set DefaultForNewUser=false for NEW entity (category: supporting, confidence: high) */

         UPDATE [${flyway:defaultSchema}].[ApplicationEntity]
         SET [DefaultForNewUser] = 0, [__mj_UpdatedAt] = GETUTCDATE()
         WHERE [EntityID] = '6F48DA55-0427-49E7-878A-70D15C020F9C';

/* Set categories for 12 fields */

-- UPDATE Entity Field Category Info IBTR Decision Citations.ID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Citation Identification',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'F6DBEA80-FE9C-4912-9165-63AEFF31C166' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Decision Citations.IBTRAppealID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Citation Identification',
   GeneratedFormSection = 'Category',
   DisplayName = 'IBTR Appeal',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'F518DD2F-BFE5-4038-81A5-7A5EA423DFB0' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Decision Citations.AuthorityType 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Authority Details',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '3CEEA54D-23AD-438F-9DAB-F1BA7B9DA618' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Decision Citations.CiteKey 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Authority Details',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'FFF0A61C-58F3-4E42-B0F5-05CC6EC384EB' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Decision Citations.CaseName 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Authority Details',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '23BFF797-467A-4647-B694-B8A3F81BB472' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Decision Citations.Court 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Authority Details',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'B1CF603C-A682-4DF4-9120-7C70C487FAC0' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Decision Citations.Year 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Authority Details',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '4F9C2AC6-F3AF-4F8A-B5C0-89F683F0BE1A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Decision Citations.Subsection 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Authority Details',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'CB71BF87-F320-4B7C-955B-0D686A1931DB' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Decision Citations.MentionCount 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Citation Metrics',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'E53B6427-E0B0-49CC-B695-A1A82204934D' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Decision Citations.ResolvedLegalAuthoritySectionID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Citation Metrics',
   GeneratedFormSection = 'Category',
   DisplayName = 'Resolved Legal Authority Section',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'CAB111A4-4F49-4588-A3B3-387C605BF653' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Decision Citations.__mj_CreatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'C06CCDB2-2835-4AA1-9AD9-5481E0C83397' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info IBTR Decision Citations.__mj_UpdatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '6BA54B22-967B-40DD-8CA5-C3D8D311CD94' AND AutoUpdateCategory = 1;

/* Set entity icon to fa fa-balance-scale */

               UPDATE [${flyway:defaultSchema}].[Entity]
               SET [Icon] = 'fa fa-balance-scale', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = '8FCB213B-2FCE-4DE0-AEEA-3CDA0D4D641B';

/* Insert FieldCategoryInfo setting for entity */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('e4188505-4ae3-44fe-a03a-ef9bf5059a19', '8FCB213B-2FCE-4DE0-AEEA-3CDA0D4D641B', 'FieldCategoryInfo', '{"Citation Identification":{"icon":"fa fa-fingerprint","description":"Unique identifier and reference to the IBTR decision containing this citation"},"Authority Details":{"icon":"fa fa-gavel","description":"Type and details of the legal authority cited including statute, rule, case name, court, year, and subsections"},"Citation Metrics":{"icon":"fa fa-chart-bar","description":"Frequency metrics and legal authority section reference for the citation"},"System Metadata":{"icon":"fa fa-cog","description":"System-managed audit and tracking fields"}}', GETUTCDATE(), GETUTCDATE());

/* Insert FieldCategoryIcons setting (legacy) */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('8aefa554-743a-46f0-bf31-56a3d0717d50', '8FCB213B-2FCE-4DE0-AEEA-3CDA0D4D641B', 'FieldCategoryIcons', '{"Citation Identification":"fa fa-fingerprint","Authority Details":"fa fa-gavel","Citation Metrics":"fa fa-chart-bar","System Metadata":"fa fa-cog"}', GETUTCDATE(), GETUTCDATE());

/* Set categories for 13 fields */

-- UPDATE Entity Field Category Info Legal Authority Sections.ID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '590F9407-89F6-42D8-842B-FA2865A35BBC' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Legal Authority Sections.LegalAuthorityID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Document Hierarchy',
   GeneratedFormSection = 'Category',
   DisplayName = 'Legal Authority',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '51E9984F-70F8-4693-9B55-DD009CE01B63' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Legal Authority Sections.ParentSectionID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Document Hierarchy',
   GeneratedFormSection = 'Category',
   DisplayName = 'Parent Section',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '1F773562-E6D9-4578-AD13-1DC38E2A0587' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Legal Authority Sections.RootParentSectionID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Document Hierarchy',
   GeneratedFormSection = 'Category',
   DisplayName = 'Root Parent Section',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '042C6718-3A49-4888-893A-B255C286095A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Legal Authority Sections.SectionLevel 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Section Classification',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'E7616296-C5EE-4B6D-8CEA-74A099B04343' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Legal Authority Sections.SectionNumber 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Section Classification',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'DD6992EE-8630-4A22-8DC6-618BB79FD0AA' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Legal Authority Sections.CitationKey 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Section Classification',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '6896C84E-E775-435F-B115-5C193DABB334' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Legal Authority Sections.Heading 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Section Content',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'C940C810-3EF5-4F69-924C-6FF8B9AA0BD8' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Legal Authority Sections.FullText 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Section Content',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'CE56D199-630E-4B61-9B65-FFEF32F549C0' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Legal Authority Sections.SourceDocumentID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Source Information',
   GeneratedFormSection = 'Category',
   DisplayName = 'Source Document',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '3E6D600D-1A02-4BD9-84F1-967A7BE5750A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Legal Authority Sections.SourceURL 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Source Information',
   GeneratedFormSection = 'Category',
   ExtendedType = 'URL',
   CodeType = NULL
WHERE 
   ID = 'A1425283-5EFD-4593-BBA2-5F7600EA40BA' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Legal Authority Sections.__mj_CreatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'C2EC7E99-A2E0-4AE7-B642-4AA7F12EE0EB' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Legal Authority Sections.__mj_UpdatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'C3CF2F82-3B5A-4B72-8891-630777CB5F0A' AND AutoUpdateCategory = 1;

/* Set entity icon to fa fa-file-alt */

               UPDATE [${flyway:defaultSchema}].[Entity]
               SET [Icon] = 'fa fa-file-alt', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = '9CD2FF63-3EDA-4B18-B7A8-51A2F717E90B';

/* Insert FieldCategoryInfo setting for entity */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('a0f40744-8ca3-43cd-8cd7-5aed9719f532', '9CD2FF63-3EDA-4B18-B7A8-51A2F717E90B', 'FieldCategoryInfo', '{"Document Hierarchy":{"icon":"fa fa-project-diagram","description":"References to parent authority document and hierarchical section structure"},"Section Classification":{"icon":"fa fa-list-ol","description":"Section type, numbering scheme, and normalized legal citation for identification"},"Section Content":{"icon":"fa fa-align-left","description":"Heading and full text content of the legal section"},"Source Information":{"icon":"fa fa-link","description":"Provenance tracking and source reference links"},"System Metadata":{"icon":"fa fa-cog","description":"System-managed audit and tracking fields"}}', GETUTCDATE(), GETUTCDATE());

/* Insert FieldCategoryIcons setting (legacy) */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('d3e6aca3-5430-461e-a1bc-87ff9b437fe8', '9CD2FF63-3EDA-4B18-B7A8-51A2F717E90B', 'FieldCategoryIcons', '{"Document Hierarchy":"fa fa-project-diagram","Section Classification":"fa fa-list-ol","Section Content":"fa fa-align-left","Source Information":"fa fa-link","System Metadata":"fa fa-cog"}', GETUTCDATE(), GETUTCDATE());

/* Set DefaultForNewUser=true for NEW entity (category: primary, confidence: high) */

         UPDATE [${flyway:defaultSchema}].[ApplicationEntity]
         SET [DefaultForNewUser] = 1, [__mj_UpdatedAt] = GETUTCDATE()
         WHERE [EntityID] = '9CD2FF63-3EDA-4B18-B7A8-51A2F717E90B';

/* Set categories for 9 fields */

-- UPDATE Entity Field Category Info Legal Authorities.ID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Document Identity',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'C38040C4-E32B-4D64-BBAD-C22C0A114934' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Legal Authorities.SourceType 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Document Identity',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'CDE21B89-1DBD-420F-829A-B4660A1EFEC7' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Legal Authorities.Title 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Document Identity',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '5A3D7F44-A74A-45FE-BDDB-B7BAFFE493F1' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Legal Authorities.Forum 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Document Classification',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '37CFA710-842A-4E51-A470-0EB266EE76AE' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Legal Authorities.AsOfDate 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Document Version',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'A7F7C755-BE3A-47E7-BFCA-852E374A42A1' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Legal Authorities.SourceDocumentID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Document Source',
   GeneratedFormSection = 'Category',
   DisplayName = 'Source Document',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'DBBFCE6B-D5DC-459A-9C43-A4E1DC82B04D' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Legal Authorities.SourceURL 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Document Source',
   GeneratedFormSection = 'Category',
   ExtendedType = 'URL',
   CodeType = NULL
WHERE 
   ID = '60D9D984-FA9B-4DA1-B0DF-E608F6CE908C' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Legal Authorities.__mj_CreatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '2D6D3C63-3D6B-46FB-A8C1-E23A6D5DC4AB' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Legal Authorities.__mj_UpdatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'BEDC11DE-649D-47BA-8722-7308252EE05A' AND AutoUpdateCategory = 1;

/* Set entity icon to fa fa-gavel */

               UPDATE [${flyway:defaultSchema}].[Entity]
               SET [Icon] = 'fa fa-gavel', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = '4C07018C-418E-409C-958A-2B39F9BAF36B';

/* Insert FieldCategoryInfo setting for entity */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('473c26b5-37ba-4474-8972-a073d0ce21ef', '4C07018C-418E-409C-958A-2B39F9BAF36B', 'FieldCategoryInfo', '{"Document Identity":{"icon":"fa fa-file-alt","description":"Core identification and classification of the legal authority document"},"Document Classification":{"icon":"fa fa-list","description":"Additional classification details for specialized document types"},"Document Version":{"icon":"fa fa-calendar","description":"Edition and effective date information for document versioning"},"Document Source":{"icon":"fa fa-link","description":"Source file and URL references for document provenance and access"},"System Metadata":{"icon":"fa fa-cog","description":"System-managed audit and tracking fields"}}', GETUTCDATE(), GETUTCDATE());

/* Insert FieldCategoryIcons setting (legacy) */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('e0a17154-c49f-488b-9afe-9bd807a3e30a', '4C07018C-418E-409C-958A-2B39F9BAF36B', 'FieldCategoryIcons', '{"Document Identity":"fa fa-file-alt","Document Classification":"fa fa-list","Document Version":"fa fa-calendar","Document Source":"fa fa-link","System Metadata":"fa fa-cog"}', GETUTCDATE(), GETUTCDATE());

/* Set DefaultForNewUser=true for NEW entity (category: primary, confidence: high) */

         UPDATE [${flyway:defaultSchema}].[ApplicationEntity]
         SET [DefaultForNewUser] = 1, [__mj_UpdatedAt] = GETUTCDATE()
         WHERE [EntityID] = '4C07018C-418E-409C-958A-2B39F9BAF36B';

/* Generated Validation Functions for Assessments */
-- CHECK constraint for Assessments @ Table Level was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
INSERT INTO [${flyway:defaultSchema}].[GeneratedCode] ([CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
                      VALUES ((SELECT [ID] FROM [${flyway:defaultSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4FD92457-0BA8-486F-978A-E5947154F4F4', GETUTCDATE(), 'TypeScript', 'Approved', '(NOT ([Source]=''ElkhartPRC'' OR [Source]=''FountainPRC'' OR [Source]=''PoseyPRC'' OR [Source]=''RandolphPRC'' OR [Source]=''DaviessPRC'' OR [Source]=''ShelbyPRC'' OR [Source]=''KnoxPRC'' OR [Source]=''WarrickPRC'' OR [Source]=''DeKalbPRC'' OR [Source]=''HendricksPRC'' OR [Source]=''PorterPRC'' OR [Source]=''ClarkPRC'' OR [Source]=''VanderburghPRC'' OR [Source]=''AllenPRC'' OR [Source]=''StJosephPRC'' OR [Source]=''LakePRC'' OR [Source]=''marion_foia_2026'' OR [Source]=''MarionPRC'') OR [OriginalLandAV] IS NULL OR [OriginalImprovementAV] IS NULL OR [OriginalTotalAV] IS NULL OR abs(([OriginalLandAV]+[OriginalImprovementAV])-[OriginalTotalAV])<=(1))', 'public ValidateOriginalAssessmentValuesForApprovedSources(result: ValidationResult) {
	const approvedSources = ["ElkhartPRC", "FountainPRC", "PoseyPRC", "RandolphPRC", "DaviessPRC", "ShelbyPRC", "KnoxPRC", "WarrickPRC", "DeKalbPRC", "HendricksPRC", "PorterPRC", "ClarkPRC", "VanderburghPRC", "AllenPRC", "StJosephPRC", "LakePRC", "marion_foia_2026", "MarionPRC"];
	const isApprovedSource = approvedSources.indexOf(this.Source) >= 0;
	
	if (isApprovedSource) {
		if (this.OriginalLandAV == null) {
			result.Errors.push(new ValidationErrorInfo(
				"OriginalLandAV",
				"Original Land Assessed Value is required for approved sources.",
				this.OriginalLandAV,
				ValidationErrorType.Failure
			));
		}
		
		if (this.OriginalImprovementAV == null) {
			result.Errors.push(new ValidationErrorInfo(
				"OriginalImprovementAV",
				"Original Improvement Assessed Value is required for approved sources.",
				this.OriginalImprovementAV,
				ValidationErrorType.Failure
			));
		}
		
		if (this.OriginalTotalAV == null) {
			result.Errors.push(new ValidationErrorInfo(
				"OriginalTotalAV",
				"Original Total Assessed Value is required for approved sources.",
				this.OriginalTotalAV,
				ValidationErrorType.Failure
			));
		}
		
		if (this.OriginalLandAV != null && this.OriginalImprovementAV != null && this.OriginalTotalAV != null) {
			const difference = Math.abs((this.OriginalLandAV + this.OriginalImprovementAV) - this.OriginalTotalAV);
			if (difference > 1) {
				result.Errors.push(new ValidationErrorInfo(
					"OriginalTotalAV",
					"Sum of Original Land and Improvement Assessed Values must equal Original Total Assessed Value within a tolerance of $1.",
					this.OriginalTotalAV,
					ValidationErrorType.Failure
				));
			}
		}
	}
}', 'Assessment records from approved sources (Indiana county PRC offices and Marion FOIA 2026) must have all three original assessed values (Land, Improvement, and Total) populated, and the sum of Land and Improvement values must equal the Total value within a tolerance of $1. Records from other sources or with missing values are permitted to bypass this validation.', 'ValidateOriginalAssessmentValuesForApprovedSources', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', '4AB7D5DF-8D95-4897-BC26-1FEA542669EF');

/* Generated Validation Functions for Legal Authority Chunks */
-- CHECK constraint for Legal Authority Chunks: Field: Ordinal was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
INSERT INTO [${flyway:defaultSchema}].[GeneratedCode] ([CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
                      VALUES ((SELECT [ID] FROM [${flyway:defaultSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4FD92457-0BA8-486F-978A-E5947154F4F4', GETUTCDATE(), 'TypeScript', 'Approved', '([Ordinal]>=(0))', 'public ValidateOrdinalIsNonNegative(result: ValidationResult) {
	if (this.Ordinal < 0) {
		result.Errors.push(new ValidationErrorInfo(
			"Ordinal",
			"Ordinal position must be zero or greater",
			this.Ordinal,
			ValidationErrorType.Failure
		));
	}
}', 'The ordinal position must be zero or greater. This ensures that sequence numbers for text chunks are non-negative, maintaining proper ordering and preventing invalid negative position values in the document structure.', 'ValidateOrdinalIsNonNegative', 'DF238F34-2837-EF11-86D4-6045BDEE16E6', 'EEC7306D-BA21-4333-A923-CE79E0E6A367');

