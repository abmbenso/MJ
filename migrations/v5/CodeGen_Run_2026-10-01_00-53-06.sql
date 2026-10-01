/* SQL generated to create new entity Sale Conveyances */

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
         'ada5a377-dca6-440a-9c28-a7f354223568',
         'Sale Conveyances',
         NULL,
         'One deed transfer, grouping the SaleTransaction rows (one per parcel) it conveyed. Rebuilt by scripts/rebuild-sale-conveyances.js from county, sale date, price and the normalized grantee (KeyBasis grantee), or date+price corroborated by a shared owner on the roll today where no grantee is recorded (owner-corroborated); a lone row is its own conveyance (single). PricePerUnit is the whole price over the members'' summed denominator -- the figure every comp grid must use; the per-row PricePerSqFt on SaleTransaction is wrong for a multi-parcel conveyance (2026-09-29: 8,740 selected comps came from such rows).',
         NULL,
         'SaleConveyance',
         'vwSaleConveyances',
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

/* SQL generated to add new entity Sale Conveyances to application ID: '49E87630-494F-460F-8CF4-724B96F0F8B3' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('49E87630-494F-460F-8CF4-724B96F0F8B3', 'ada5a377-dca6-440a-9c28-a7f354223568', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '49E87630-494F-460F-8CF4-724B96F0F8B3'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Sale Conveyances for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('ada5a377-dca6-440a-9c28-a7f354223568', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Sale Conveyances for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('ada5a377-dca6-440a-9c28-a7f354223568', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Sale Conveyances for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('ada5a377-dca6-440a-9c28-a7f354223568', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to create new entity Sale Conveyance Members */

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
         '04e37d72-b573-4b81-b1e1-a501f1372851',
         'Sale Conveyance Members',
         NULL,
         'Which SaleTransaction rows belong to a conveyance. A same-parcel duplicate row (two cards, one sale) is kept as a member with IsDuplicateCard = 1 and contributes nothing to the sums.',
         NULL,
         'SaleConveyanceMember',
         'vwSaleConveyanceMembers',
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

/* SQL generated to add new entity Sale Conveyance Members to application ID: '49E87630-494F-460F-8CF4-724B96F0F8B3' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('49E87630-494F-460F-8CF4-724B96F0F8B3', '04e37d72-b573-4b81-b1e1-a501f1372851', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '49E87630-494F-460F-8CF4-724B96F0F8B3'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Sale Conveyance Members for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('04e37d72-b573-4b81-b1e1-a501f1372851', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Sale Conveyance Members for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('04e37d72-b573-4b81-b1e1-a501f1372851', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Sale Conveyance Members for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('04e37d72-b573-4b81-b1e1-a501f1372851', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to create new entity Appeal Recommendations */

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
         '39dd9aec-f3c1-425c-85ea-3261c47173d2',
         'Appeal Recommendations',
         NULL,
         'One current recommendation per subject (a parcel, or a Confirmed/Provisional property) per assessment year per methodology version, from scripts/build-appeal-recommendations.js. The verdict is the count of agreeing value signals (S1-S5, S7, S9, S10) with the increase (S6) and peer (S8) flags: Appeal at two, or one plus a flag; Consider at one; No otherwise. Practitioner-facing only. Every indicated value is in AppealRecommendationSignal; a property subject''s ask and savings are allocated to its parcels in AppealRecommendationParcel, never copied.',
         NULL,
         'AppealRecommendation',
         'vwAppealRecommendations',
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

/* SQL generated to add new entity Appeal Recommendations to application ID: '49E87630-494F-460F-8CF4-724B96F0F8B3' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('49E87630-494F-460F-8CF4-724B96F0F8B3', '39dd9aec-f3c1-425c-85ea-3261c47173d2', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '49E87630-494F-460F-8CF4-724B96F0F8B3'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Appeal Recommendations for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('39dd9aec-f3c1-425c-85ea-3261c47173d2', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Appeal Recommendations for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('39dd9aec-f3c1-425c-85ea-3261c47173d2', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Appeal Recommendations for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('39dd9aec-f3c1-425c-85ea-3261c47173d2', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to create new entity Appeal Recommendation Signals */

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
         '27770192-813f-4e84-a3fa-a856f29920ee',
         'Appeal Recommendation Signals',
         NULL,
         'One row per signal S1-S10 per recommendation, exactly ten (integrity signal-rows-ten-per-recommendation): whether it supports, why not, and its indicated value in its unit of comparison, with the evidence count and note a reviewer needs to see why.',
         NULL,
         'AppealRecommendationSignal',
         'vwAppealRecommendationSignals',
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

/* SQL generated to add new entity Appeal Recommendation Signals to application ID: '49E87630-494F-460F-8CF4-724B96F0F8B3' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('49E87630-494F-460F-8CF4-724B96F0F8B3', '27770192-813f-4e84-a3fa-a856f29920ee', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '49E87630-494F-460F-8CF4-724B96F0F8B3'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Appeal Recommendation Signals for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('27770192-813f-4e84-a3fa-a856f29920ee', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Appeal Recommendation Signals for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('27770192-813f-4e84-a3fa-a856f29920ee', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Appeal Recommendation Signals for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('27770192-813f-4e84-a3fa-a856f29920ee', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to create new entity Appeal Recommendation Parcels */

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
         '785d1eca-0ee2-40c8-b1ee-c5afed5c5c6a',
         'Appeal Recommendation Parcels',
         NULL,
         'A property subject''s result allocated to each member parcel (Form 130 is per parcel; Owner Prospects sums per parcel): proportional to the member''s current AV, overridable by the practitioner. Allocations sum to the property total within $1 (integrity allocation-sums-to-total).',
         NULL,
         'AppealRecommendationParcel',
         'vwAppealRecommendationParcels',
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

/* SQL generated to add new entity Appeal Recommendation Parcels to application ID: '49E87630-494F-460F-8CF4-724B96F0F8B3' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('49E87630-494F-460F-8CF4-724B96F0F8B3', '785d1eca-0ee2-40c8-b1ee-c5afed5c5c6a', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '49E87630-494F-460F-8CF4-724B96F0F8B3'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Appeal Recommendation Parcels for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('785d1eca-0ee2-40c8-b1ee-c5afed5c5c6a', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Appeal Recommendation Parcels for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('785d1eca-0ee2-40c8-b1ee-c5afed5c5c6a', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Appeal Recommendation Parcels for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('785d1eca-0ee2-40c8-b1ee-c5afed5c5c6a', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to create new entity Property Suggestion Evidences */

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
         '903f0793-42d9-4eaf-8bb8-3eebf8fff70a',
         'Property Suggestion Evidences',
         NULL,
         'One row per signal that suggested a Property (GroupingStatus Suggested), written by scripts/suggest-properties.js: the evidence a practitioner reads before confirming. The system suggests; it never regroups on its own.',
         NULL,
         'PropertySuggestionEvidence',
         'vwPropertySuggestionEvidences',
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

/* SQL generated to add new entity Property Suggestion Evidences to application ID: '49E87630-494F-460F-8CF4-724B96F0F8B3' */
INSERT INTO [${flyway:defaultSchema}].[ApplicationEntity]
                                       ([ApplicationID], [EntityID], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                       ('49E87630-494F-460F-8CF4-724B96F0F8B3', '903f0793-42d9-4eaf-8bb8-3eebf8fff70a', (SELECT COALESCE(MAX([Sequence]),0)+1 FROM [${flyway:defaultSchema}].[ApplicationEntity] WHERE [ApplicationID] = '49E87630-494F-460F-8CF4-724B96F0F8B3'), GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Property Suggestion Evidences for role UI */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('903f0793-42d9-4eaf-8bb8-3eebf8fff70a', 'E0AFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 0, 0, 0, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Property Suggestion Evidences for role Developer */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('903f0793-42d9-4eaf-8bb8-3eebf8fff70a', 'DEAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL generated to add new permission for entity Property Suggestion Evidences for role Integration */
INSERT INTO [${flyway:defaultSchema}].[EntityPermission]
                                                   ([EntityID], [RoleID], [CanRead], [CanCreate], [CanUpdate], [CanDelete], [__mj_CreatedAt], [__mj_UpdatedAt]) VALUES
                                                   ('903f0793-42d9-4eaf-8bb8-3eebf8fff70a', 'DFAFCCEC-6A37-EF11-86D4-000D3A4E707E', 1, 1, 1, 1, GETUTCDATE(), GETUTCDATE());

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.AppealRecommendation */
ALTER TABLE [indiana_tax].[AppealRecommendation] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.AppealRecommendation */
UPDATE [indiana_tax].[AppealRecommendation] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.AppealRecommendation */
ALTER TABLE [indiana_tax].[AppealRecommendation] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.AppealRecommendation */
ALTER TABLE [indiana_tax].[AppealRecommendation] ADD CONSTRAINT [DF_indiana_tax_AppealRecommendation___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.AppealRecommendation */
ALTER TABLE [indiana_tax].[AppealRecommendation] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.AppealRecommendation */
UPDATE [indiana_tax].[AppealRecommendation] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.AppealRecommendation */
ALTER TABLE [indiana_tax].[AppealRecommendation] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.AppealRecommendation */
ALTER TABLE [indiana_tax].[AppealRecommendation] ADD CONSTRAINT [DF_indiana_tax_AppealRecommendation___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.PropertySuggestionEvidence */
ALTER TABLE [indiana_tax].[PropertySuggestionEvidence] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.PropertySuggestionEvidence */
UPDATE [indiana_tax].[PropertySuggestionEvidence] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.PropertySuggestionEvidence */
ALTER TABLE [indiana_tax].[PropertySuggestionEvidence] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.PropertySuggestionEvidence */
ALTER TABLE [indiana_tax].[PropertySuggestionEvidence] ADD CONSTRAINT [DF_indiana_tax_PropertySuggestionEvidence___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.PropertySuggestionEvidence */
ALTER TABLE [indiana_tax].[PropertySuggestionEvidence] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.PropertySuggestionEvidence */
UPDATE [indiana_tax].[PropertySuggestionEvidence] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.PropertySuggestionEvidence */
ALTER TABLE [indiana_tax].[PropertySuggestionEvidence] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.PropertySuggestionEvidence */
ALTER TABLE [indiana_tax].[PropertySuggestionEvidence] ADD CONSTRAINT [DF_indiana_tax_PropertySuggestionEvidence___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.SaleConveyanceMember */
ALTER TABLE [indiana_tax].[SaleConveyanceMember] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.SaleConveyanceMember */
UPDATE [indiana_tax].[SaleConveyanceMember] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.SaleConveyanceMember */
ALTER TABLE [indiana_tax].[SaleConveyanceMember] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.SaleConveyanceMember */
ALTER TABLE [indiana_tax].[SaleConveyanceMember] ADD CONSTRAINT [DF_indiana_tax_SaleConveyanceMember___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.SaleConveyanceMember */
ALTER TABLE [indiana_tax].[SaleConveyanceMember] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.SaleConveyanceMember */
UPDATE [indiana_tax].[SaleConveyanceMember] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.SaleConveyanceMember */
ALTER TABLE [indiana_tax].[SaleConveyanceMember] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.SaleConveyanceMember */
ALTER TABLE [indiana_tax].[SaleConveyanceMember] ADD CONSTRAINT [DF_indiana_tax_SaleConveyanceMember___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.SaleConveyance */
ALTER TABLE [indiana_tax].[SaleConveyance] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.SaleConveyance */
UPDATE [indiana_tax].[SaleConveyance] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.SaleConveyance */
ALTER TABLE [indiana_tax].[SaleConveyance] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.SaleConveyance */
ALTER TABLE [indiana_tax].[SaleConveyance] ADD CONSTRAINT [DF_indiana_tax_SaleConveyance___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.SaleConveyance */
ALTER TABLE [indiana_tax].[SaleConveyance] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.SaleConveyance */
UPDATE [indiana_tax].[SaleConveyance] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.SaleConveyance */
ALTER TABLE [indiana_tax].[SaleConveyance] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.SaleConveyance */
ALTER TABLE [indiana_tax].[SaleConveyance] ADD CONSTRAINT [DF_indiana_tax_SaleConveyance___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.AppealRecommendationSignal */
ALTER TABLE [indiana_tax].[AppealRecommendationSignal] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.AppealRecommendationSignal */
UPDATE [indiana_tax].[AppealRecommendationSignal] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.AppealRecommendationSignal */
ALTER TABLE [indiana_tax].[AppealRecommendationSignal] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.AppealRecommendationSignal */
ALTER TABLE [indiana_tax].[AppealRecommendationSignal] ADD CONSTRAINT [DF_indiana_tax_AppealRecommendationSignal___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.AppealRecommendationSignal */
ALTER TABLE [indiana_tax].[AppealRecommendationSignal] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.AppealRecommendationSignal */
UPDATE [indiana_tax].[AppealRecommendationSignal] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.AppealRecommendationSignal */
ALTER TABLE [indiana_tax].[AppealRecommendationSignal] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.AppealRecommendationSignal */
ALTER TABLE [indiana_tax].[AppealRecommendationSignal] ADD CONSTRAINT [DF_indiana_tax_AppealRecommendationSignal___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.AppealRecommendationParcel */
ALTER TABLE [indiana_tax].[AppealRecommendationParcel] ADD [__mj_CreatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.AppealRecommendationParcel */
UPDATE [indiana_tax].[AppealRecommendationParcel] SET [__mj_CreatedAt] = GETUTCDATE() WHERE [__mj_CreatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.AppealRecommendationParcel */
ALTER TABLE [indiana_tax].[AppealRecommendationParcel] ALTER COLUMN [__mj_CreatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_CreatedAt to entity indiana_tax.AppealRecommendationParcel */
ALTER TABLE [indiana_tax].[AppealRecommendationParcel] ADD CONSTRAINT [DF_indiana_tax_AppealRecommendationParcel___mj_CreatedAt] DEFAULT GETUTCDATE() FOR [__mj_CreatedAt];
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.AppealRecommendationParcel */
ALTER TABLE [indiana_tax].[AppealRecommendationParcel] ADD [__mj_UpdatedAt] DATETIMEOFFSET NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.AppealRecommendationParcel */
UPDATE [indiana_tax].[AppealRecommendationParcel] SET [__mj_UpdatedAt] = GETUTCDATE() WHERE [__mj_UpdatedAt] IS NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.AppealRecommendationParcel */
ALTER TABLE [indiana_tax].[AppealRecommendationParcel] ALTER COLUMN [__mj_UpdatedAt] DATETIMEOFFSET NOT NULL;
GO

/* SQL text to add special date field __mj_UpdatedAt to entity indiana_tax.AppealRecommendationParcel */
ALTER TABLE [indiana_tax].[AppealRecommendationParcel] ADD CONSTRAINT [DF_indiana_tax_AppealRecommendationParcel___mj_UpdatedAt] DEFAULT GETUTCDATE() FOR [__mj_UpdatedAt];
GO

/* SQL text to insert 106 new entity field(s) */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd36178a9-be15-41e3-8aba-994d654f9286' OR (EntityID = '39DD9AEC-F3C1-425C-85EA-3261C47173D2' AND Name = 'ID')) BEGIN
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
            'd36178a9-be15-41e3-8aba-994d654f9286',
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2', -- Entity: Appeal Recommendations
            100001,
            'ID',
            'ID',
            'Primary key.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '82566216-36b5-486a-87c4-8ea944d1eee0' OR (EntityID = '39DD9AEC-F3C1-425C-85EA-3261C47173D2' AND Name = 'SubjectKind')) BEGIN
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
            '82566216-36b5-486a-87c4-8ea944d1eee0',
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2', -- Entity: Appeal Recommendations
            100002,
            'SubjectKind',
            'Subject Kind',
            'Parcel or Property: what was analysed. Exactly one of ParcelID and PropertyID is set to match (CHECK).',
            'nvarchar',
            20,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '5da3fb6b-c2bb-4631-b84a-86eb339008f4' OR (EntityID = '39DD9AEC-F3C1-425C-85EA-3261C47173D2' AND Name = 'ParcelID')) BEGIN
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
            '5da3fb6b-c2bb-4631-b84a-86eb339008f4',
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2', -- Entity: Appeal Recommendations
            100003,
            'ParcelID',
            'Parcel ID',
            'The subject parcel when SubjectKind = Parcel (a Standalone or Suggested-unrolled parcel); NULL for a property subject.',
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
            'D0F9D3D3-2E68-4ABA-8891-8DEC85F300FB',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7b7bd624-2819-4c0d-acdc-d0d9fad5a244' OR (EntityID = '39DD9AEC-F3C1-425C-85EA-3261C47173D2' AND Name = 'PropertyID')) BEGIN
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
            '7b7bd624-2819-4c0d-acdc-d0d9fad5a244',
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2', -- Entity: Appeal Recommendations
            100004,
            'PropertyID',
            'Property ID',
            'The subject property when SubjectKind = Property (a Confirmed property, or the Suggested property rolled up as Provisional); NULL for a parcel subject.',
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
            '60CE2DDA-DDB0-4445-BE61-4303D0174B8C',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '3b447c2f-2045-4307-8fd7-708da6946928' OR (EntityID = '39DD9AEC-F3C1-425C-85EA-3261C47173D2' AND Name = 'AssessmentYear')) BEGIN
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
            '3b447c2f-2045-4307-8fd7-708da6946928',
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2', -- Entity: Appeal Recommendations
            100005,
            'AssessmentYear',
            'Assessment Year',
            'The assessment year the recommendation is for (AY2026 in the first run).',
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
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '3b268226-3411-4d95-ac21-eabb8974894e' OR (EntityID = '39DD9AEC-F3C1-425C-85EA-3261C47173D2' AND Name = 'MethodologyVersion')) BEGIN
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
            '3b268226-3411-4d95-ac21-eabb8974894e',
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2', -- Entity: Appeal Recommendations
            100006,
            'MethodologyVersion',
            'Methodology Version',
            'The methodology the row was computed under (first: signals-v2-2026-09-29). A version is not marked current until its back-test report exists (integrity recommendation-version-has-backtest).',
            'nvarchar',
            80,
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
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '3a8c743f-f243-405c-af16-5d87ac57de6d' OR (EntityID = '39DD9AEC-F3C1-425C-85EA-3261C47173D2' AND Name = 'IsCurrent')) BEGIN
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
            '3a8c743f-f243-405c-af16-5d87ac57de6d',
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2', -- Entity: Appeal Recommendations
            100007,
            'IsCurrent',
            'Is Current',
            '1 for the one current row per subject, year and methodology version (filtered unique indexes); older rows are kept as history with 0.',
            'bit',
            1,
            1,
            0,
            0,
            '(1)',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'c8f1055a-89cb-4af5-84cf-eae449b656fe' OR (EntityID = '39DD9AEC-F3C1-425C-85EA-3261C47173D2' AND Name = 'CurrentAV')) BEGIN
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
            'c8f1055a-89cb-4af5-84cf-eae449b656fe',
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2', -- Entity: Appeal Recommendations
            100008,
            'CurrentAV',
            'Current AV',
            'The subject''s assessed value for AssessmentYear; for a property, the sum over members, NULL when any member lacks the year (member-missing-year).',
            'decimal',
            9,
            18,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '488e00a0-4dfe-45e7-94c2-8f393c092989' OR (EntityID = '39DD9AEC-F3C1-425C-85EA-3261C47173D2' AND Name = 'PriorAVAsDetermined')) BEGIN
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
            '488e00a0-4dfe-45e7-94c2-8f393c092989',
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2', -- Entity: Appeal Recommendations
            100009,
            'PriorAVAsDetermined',
            'Prior AV As Determined',
            'The prior year''s assessed value as determined (after any appeal), as core burden-shift reads it for S6 and S8; NULL when there is no prior year.',
            'decimal',
            9,
            18,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '0de0d626-bb9a-4ef1-ae8c-9fbbcef658c5' OR (EntityID = '39DD9AEC-F3C1-425C-85EA-3261C47173D2' AND Name = 'UnitOfComparison')) BEGIN
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
            '0de0d626-bb9a-4ef1-ae8c-9fbbcef658c5',
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2', -- Entity: Appeal Recommendations
            100010,
            'UnitOfComparison',
            'Unit Of Comparison',
            'The unit every per-unit figure on this row and its signals is shown in: $/SF, $/unit, $/key or $/acre (rules/unit-of-comparison.json, spec §4.3).',
            'nvarchar',
            20,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '8c167e71-b35f-4e9d-8bad-03b8e738faf9' OR (EntityID = '39DD9AEC-F3C1-425C-85EA-3261C47173D2' AND Name = 'Denominator')) BEGIN
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
            '8c167e71-b35f-4e9d-8bad-03b8e738faf9',
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2', -- Entity: Appeal Recommendations
            100011,
            'Denominator',
            'Denominator',
            'The subject''s denominator in UnitOfComparison (building SF ex-parking, units, keys or acres; summed over members for a property). NULL means every per-unit figure is withheld.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '71a6088b-8382-4eef-99f2-beeabebf19ad' OR (EntityID = '39DD9AEC-F3C1-425C-85EA-3261C47173D2' AND Name = 'DenominatorSource')) BEGIN
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
            '71a6088b-8382-4eef-99f2-beeabebf19ad',
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2', -- Entity: Appeal Recommendations
            100012,
            'DenominatorSource',
            'Denominator Source',
            'Where the denominator came from: Client, Practitioner, PRC, CoStar, Web or a DLGF segment sum; for a property, the weakest member source (rank PRC > CoStar > Web > DLGF segment).',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'a858cfa6-14b1-49ff-9380-6490c3ba2848' OR (EntityID = '39DD9AEC-F3C1-425C-85EA-3261C47173D2' AND Name = 'DenominatorIsFallback')) BEGIN
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
            'a858cfa6-14b1-49ff-9380-6490c3ba2848',
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2', -- Entity: Appeal Recommendations
            100013,
            'DenominatorIsFallback',
            'Denominator Is Fallback',
            '1 when the class''s own unit had no denominator and $/SF was used instead (Multifamily without units, Hospitality without keys); labelled fallback on every screen.',
            'bit',
            1,
            1,
            0,
            0,
            '(0)',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '5e7e00dd-e6dd-456b-af33-9b03e3989476' OR (EntityID = '39DD9AEC-F3C1-425C-85EA-3261C47173D2' AND Name = 'ValueSignalCount')) BEGIN
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
            '5e7e00dd-e6dd-456b-af33-9b03e3989476',
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2', -- Entity: Appeal Recommendations
            100014,
            'ValueSignalCount',
            'Value Signal Count',
            'The count of agreeing value signals: S1, S2, S3, S4, S5, S7, S9 and S10 when it supports. The verdict and the confidence tier both read it.',
            'tinyint',
            1,
            3,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7c719951-1441-4233-94e7-704c4014e712' OR (EntityID = '39DD9AEC-F3C1-425C-85EA-3261C47173D2' AND Name = 'IncreaseFlag')) BEGIN
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
            '7c719951-1441-4233-94e7-704c4014e712',
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2', -- Entity: Appeal Recommendations
            100015,
            'IncreaseFlag',
            'Increase Flag',
            'S6: the assessment rose more than 5% over the prior year as determined (IC 6-1.1-15-20, core burden-shift). A context flag, not a value signal.',
            'bit',
            1,
            1,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '6bea06c4-1320-4605-a4b4-17c81883060b' OR (EntityID = '39DD9AEC-F3C1-425C-85EA-3261C47173D2' AND Name = 'FloorSupport')) BEGIN
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
            '6bea06c4-1320-4605-a4b4-17c81883060b',
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2', -- Entity: Appeal Recommendations
            100016,
            'FloorSupport',
            'Floor Support',
            '1 when S6 holds and any of S1-S5''s indicated values is within 10% of the prior-year as-determined AV: the prior year is shown reasonable, so the ask is floored at it (AskBasis prior-year-floor).',
            'bit',
            1,
            1,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '4c265896-3883-4043-8ed2-e24948c2126d' OR (EntityID = '39DD9AEC-F3C1-425C-85EA-3261C47173D2' AND Name = 'PeerOutOfLine')) BEGIN
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
            '4c265896-3883-4043-8ed2-e24948c2126d',
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2', -- Entity: Appeal Recommendations
            100017,
            'PeerOutOfLine',
            'Peer Out Of Line',
            'S8: the subject''s year-over-year increase exceeds the median of its neighborhood and type group (at least 5 parcels; else county and type group) by 5 points or more. A context flag.',
            'bit',
            1,
            1,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ae38e36a-eb87-4972-bb15-cb4442068757' OR (EntityID = '39DD9AEC-F3C1-425C-85EA-3261C47173D2' AND Name = 'OwnSaleContrary')) BEGIN
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
            'ae38e36a-eb87-4972-bb15-cb4442068757',
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2', -- Entity: Appeal Recommendations
            100018,
            'OwnSaleContrary',
            'Own Sale Contrary',
            'S10 contrary: a qualifying own sale within 24 months of the valuation date at or above AV. Caps the verdict at Consider and the ask is never below that price.',
            'bit',
            1,
            1,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'dd149791-d02e-43d5-a9ad-7628d5da6dc4' OR (EntityID = '39DD9AEC-F3C1-425C-85EA-3261C47173D2' AND Name = 'Verdict')) BEGIN
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
            'dd149791-d02e-43d5-a9ad-7628d5da6dc4',
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2', -- Entity: Appeal Recommendations
            100019,
            'Verdict',
            'Verdict',
            'Appeal: two or more value signals, or one plus the increase or peer flag unless the one is S9. Consider: one value signal, or none with both flags. No: otherwise. not-available: AV missing, or a property subject with member-missing-year. OwnSaleContrary caps it at Consider.',
            'nvarchar',
            32,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd3b30128-6b07-47b3-96ae-068c22ead751' OR (EntityID = '39DD9AEC-F3C1-425C-85EA-3261C47173D2' AND Name = 'NotAvailableReason')) BEGIN
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
            'd3b30128-6b07-47b3-96ae-068c22ead751',
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2', -- Entity: Appeal Recommendations
            100020,
            'NotAvailableReason',
            'Not Available Reason',
            'Why the verdict is not-available (for example member-missing-year, or AV missing); NULL otherwise.',
            'nvarchar',
            120,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd412626f-751f-44f7-a1b7-12bf6e980514' OR (EntityID = '39DD9AEC-F3C1-425C-85EA-3261C47173D2' AND Name = 'ConfidenceTier')) BEGIN
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
            'd412626f-751f-44f7-a1b7-12bf6e980514',
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2', -- Entity: Appeal Recommendations
            100021,
            'ConfidenceTier',
            'Confidence Tier',
            'The back-tested hit rate of the value-signal count: High, Medium or Low by the cuts in rules/appeal-signals.json (initially k >= 3, k = 2, k <= 1), shown with the measured recall and false-alarm rate for that k. NULL when not-available.',
            'nvarchar',
            16,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'f2fba8ff-0c41-48ae-9ddc-58adacc7a7aa' OR (EntityID = '39DD9AEC-F3C1-425C-85EA-3261C47173D2' AND Name = 'FloorValue')) BEGIN
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
            'f2fba8ff-0c41-48ae-9ddc-58adacc7a7aa',
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2', -- Entity: Appeal Recommendations
            100022,
            'FloorValue',
            'Floor Value',
            'The lowest supporting indication: S3, S4, S5, S10 within [0.5, 1.2] x AV, then S1, S2, S7, S9 indicated values at or below 0.95 x AV. NULL when none supports.',
            'decimal',
            9,
            18,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'a48578e1-2b65-4240-aad9-38c126cb744a' OR (EntityID = '39DD9AEC-F3C1-425C-85EA-3261C47173D2' AND Name = 'AskValue')) BEGIN
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
            'a48578e1-2b65-4240-aad9-38c126cb744a',
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2', -- Entity: Appeal Recommendations
            100023,
            'AskValue',
            'Ask Value',
            'The value to ask for, by AskPolicy, then floored at the prior-year as-determined AV when FloorSupport holds, and never below the own-sale price when OwnSaleContrary. For a property, allocated to members in AppealRecommendationParcel.',
            'decimal',
            9,
            18,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '1826970a-ae2b-4f20-ad92-6df87139f37b' OR (EntityID = '39DD9AEC-F3C1-425C-85EA-3261C47173D2' AND Name = 'AskPolicy')) BEGIN
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
            '1826970a-ae2b-4f20-ad92-6df87139f37b',
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2', -- Entity: Appeal Recommendations
            100024,
            'AskPolicy',
            'Ask Policy',
            'Lowest (the floor) or SecondLowest (the second-lowest supporting indication when two or more exist, else the floor; the default, as the Appeal Workbench does). A rule value in rules/appeal-signals.json.',
            'nvarchar',
            32,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'e894ccfb-c162-47e3-9762-3310825bc8f4' OR (EntityID = '39DD9AEC-F3C1-425C-85EA-3261C47173D2' AND Name = 'AskBasis')) BEGIN
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
            'e894ccfb-c162-47e3-9762-3310825bc8f4',
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2', -- Entity: Appeal Recommendations
            100025,
            'AskBasis',
            'Ask Basis',
            'What set AskValue: lowest-supported (the AskPolicy pick), prior-year-floor (S6 with floor support), or own-sale-cap (raised to the S10 contrary sale price). NULL when there is no ask.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7beaf931-37a6-46b3-8f68-770ad339d06d' OR (EntityID = '39DD9AEC-F3C1-425C-85EA-3261C47173D2' AND Name = 'EstSavingsAtAsk')) BEGIN
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
            '7beaf931-37a6-46b3-8f68-770ad339d06d',
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2', -- Entity: Appeal Recommendations
            100026,
            'EstSavingsAtAsk',
            'Est Savings At Ask',
            '(CurrentAV - AskValue) x EffectiveTaxRate, as savings.ts computes it; for a property, the total, allocated per member in AppealRecommendationParcel. Below $1,000 sets BelowSavingsFloor.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '5787b0c7-94e9-4615-a6d3-275ad1870efe' OR (EntityID = '39DD9AEC-F3C1-425C-85EA-3261C47173D2' AND Name = 'EstSavingsAtFloor')) BEGIN
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
            '5787b0c7-94e9-4615-a6d3-275ad1870efe',
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2', -- Entity: Appeal Recommendations
            100027,
            'EstSavingsAtFloor',
            'Est Savings At Floor',
            '(CurrentAV - FloorValue) x EffectiveTaxRate; for a property, the total, allocated per member in AppealRecommendationParcel.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'c7af0316-5a1e-4abd-9ceb-0f8f317c5404' OR (EntityID = '39DD9AEC-F3C1-425C-85EA-3261C47173D2' AND Name = 'EffectiveTaxRate')) BEGIN
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
            'c7af0316-5a1e-4abd-9ceb-0f8f317c5404',
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2', -- Entity: Appeal Recommendations
            100028,
            'EffectiveTaxRate',
            'Effective Tax Rate',
            'The 6-place effective tax rate the savings were computed with (as savings.ts).',
            'decimal',
            5,
            9,
            6,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '3cf4424d-82f5-44f7-8bac-0d64ae748e0e' OR (EntityID = '39DD9AEC-F3C1-425C-85EA-3261C47173D2' AND Name = 'GroupingStatus')) BEGIN
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
            '3cf4424d-82f5-44f7-8bac-0d64ae748e0e',
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2', -- Entity: Appeal Recommendations
            100029,
            'GroupingStatus',
            'Grouping Status',
            'Standalone = a parcel in no property; Confirmed = a practitioner-confirmed property (Client Setup); Provisional = a multi-parcel conveyance whose members share an owner today, rolled up before confirmation and marked so; Suggested-unrolled = a parcel that sits in a Suggested property and was analysed alone, per-unit figures withheld.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '58ae8ffe-cd3c-45c6-8f1d-f3ac83298a9f' OR (EntityID = '39DD9AEC-F3C1-425C-85EA-3261C47173D2' AND Name = 'GroupingVersion')) BEGIN
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
            '58ae8ffe-cd3c-45c6-8f1d-f3ac83298a9f',
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2', -- Entity: Appeal Recommendations
            100030,
            'GroupingVersion',
            'Grouping Version',
            'Property.GroupingVersion of the subject property when this row was computed. A row whose version is older than the property''s current one is stale (a confirm or split since). NULL for a parcel subject.',
            'datetime2',
            8,
            27,
            7,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '55e9cd80-1d4d-43f9-b0f7-7369a7acb144' OR (EntityID = '39DD9AEC-F3C1-425C-85EA-3261C47173D2' AND Name = 'AlreadyAppealed')) BEGIN
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
            '55e9cd80-1d4d-43f9-b0f7-7369a7acb144',
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2', -- Entity: Appeal Recommendations
            100031,
            'AlreadyAppealed',
            'Already Appealed',
            'Gate: an AppealOutcome or PTABOAAppeal row exists for AssessmentYear (for a property, on any member). Shown beside the verdict, never changes it; used for prospect ranking.',
            'bit',
            1,
            1,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '9add4883-e629-4ea1-9905-185560bc19be' OR (EntityID = '39DD9AEC-F3C1-425C-85EA-3261C47173D2' AND Name = 'ExistingRep')) BEGIN
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
            '9add4883-e629-4ea1-9905-185560bc19be',
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2', -- Entity: Appeal Recommendations
            100032,
            'ExistingRep',
            'Existing Rep',
            'Gate: the representative already on file for the subject (Owner Prospects; for a property, any member); NULL when none. Shown beside the verdict, never changes it.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '8127fe50-3a5b-4264-b436-6650b0dcbb6b' OR (EntityID = '39DD9AEC-F3C1-425C-85EA-3261C47173D2' AND Name = 'Exempt')) BEGIN
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
            '8127fe50-3a5b-4264-b436-6650b0dcbb6b',
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2', -- Entity: Appeal Recommendations
            100033,
            'Exempt',
            'Exempt',
            'Gate: an Exemption outcome current for AssessmentYear, or deductions and exemptions at or above AV on the assessor record (for a property, any member). Shown beside the verdict, never changes it.',
            'bit',
            1,
            1,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '359ea202-0222-4576-9efa-71f0b411afa8' OR (EntityID = '39DD9AEC-F3C1-425C-85EA-3261C47173D2' AND Name = 'BelowSavingsFloor')) BEGIN
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
            '359ea202-0222-4576-9efa-71f0b411afa8',
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2', -- Entity: Appeal Recommendations
            100034,
            'BelowSavingsFloor',
            'Below Savings Floor',
            'Gate: EstSavingsAtAsk is below the savings floor ($1,000, rules/appeal-signals.json). Shown beside the verdict, never changes it.',
            'bit',
            1,
            1,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'e940d1e6-8099-4b68-bee2-ac8fa3332080' OR (EntityID = '39DD9AEC-F3C1-425C-85EA-3261C47173D2' AND Name = 'RunStamp')) BEGIN
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
            'e940d1e6-8099-4b68-bee2-ac8fa3332080',
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2', -- Entity: Appeal Recommendations
            100035,
            'RunStamp',
            'Run Stamp',
            'The run that wrote this row (scripts/build-appeal-recommendations.js). Each run writes one stamp; rows of an older stamp are swept.',
            'datetime2',
            8,
            27,
            7,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'b939adc8-da98-4dc3-b655-05747611041a' OR (EntityID = '39DD9AEC-F3C1-425C-85EA-3261C47173D2' AND Name = 'GeneratedAt')) BEGIN
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
            'b939adc8-da98-4dc3-b655-05747611041a',
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2', -- Entity: Appeal Recommendations
            100036,
            'GeneratedAt',
            'Generated At',
            'When this row was written.',
            'datetime2',
            8,
            27,
            7,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd9ad157c-3bdb-4f7a-b0b8-5d2eab2aef62' OR (EntityID = '39DD9AEC-F3C1-425C-85EA-3261C47173D2' AND Name = '__mj_CreatedAt')) BEGIN
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
            'd9ad157c-3bdb-4f7a-b0b8-5d2eab2aef62',
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2', -- Entity: Appeal Recommendations
            100037,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd1bae6bf-2fa0-45ae-96c8-2dc44f15560e' OR (EntityID = '39DD9AEC-F3C1-425C-85EA-3261C47173D2' AND Name = '__mj_UpdatedAt')) BEGIN
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
            'd1bae6bf-2fa0-45ae-96c8-2dc44f15560e',
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2', -- Entity: Appeal Recommendations
            100038,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd5c54dec-3a41-4f4e-af47-d8e1bfb80679' OR (EntityID = '903F0793-42D9-4EAF-8BB8-3EEBF8FFF70A' AND Name = 'ID')) BEGIN
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
            'd5c54dec-3a41-4f4e-af47-d8e1bfb80679',
            '903F0793-42D9-4EAF-8BB8-3EEBF8FFF70A', -- Entity: Property Suggestion Evidences
            100001,
            'ID',
            'ID',
            'Primary key.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'c2bc649b-187c-4e2e-be4e-d825f67f042e' OR (EntityID = '903F0793-42D9-4EAF-8BB8-3EEBF8FFF70A' AND Name = 'PropertyID')) BEGIN
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
            'c2bc649b-187c-4e2e-be4e-d825f67f042e',
            '903F0793-42D9-4EAF-8BB8-3EEBF8FFF70A', -- Entity: Property Suggestion Evidences
            100002,
            'PropertyID',
            'Property ID',
            'The suggested property.',
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
            '60CE2DDA-DDB0-4445-BE61-4303D0174B8C',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '36aa022e-cb91-4a2d-8bb9-1f26a75a0dd5' OR (EntityID = '903F0793-42D9-4EAF-8BB8-3EEBF8FFF70A' AND Name = 'SignalCode')) BEGIN
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
            '36aa022e-cb91-4a2d-8bb9-1f26a75a0dd5',
            '903F0793-42D9-4EAF-8BB8-3EEBF8FFF70A', -- Entity: Property Suggestion Evidences
            100003,
            'SignalCode',
            'Signal Code',
            'A same owner and adjacency; B improved parcel with land-only neighbours; C conveyed together (shared ConveyanceKey, same owner today); D CoStar multi-parcel; E card cross-reference (spec §3.2).',
            'nvarchar',
            4,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '710a2cc4-90b4-49a1-9125-fded0d9a9995' OR (EntityID = '903F0793-42D9-4EAF-8BB8-3EEBF8FFF70A' AND Name = 'Grade')) BEGIN
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
            '710a2cc4-90b4-49a1-9125-fded0d9a9995',
            '903F0793-42D9-4EAF-8BB8-3EEBF8FFF70A', -- Entity: Property Suggestion Evidences
            100004,
            'Grade',
            'Grade',
            'The grade of this signal: A for signals B and C; B for A and E, and for D when the parcels also satisfy A; C for D without A. A candidate resting on a single grade-C signal is not written.',
            'nvarchar',
            2,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '3038d933-337a-4213-9cef-b303db55afda' OR (EntityID = '903F0793-42D9-4EAF-8BB8-3EEBF8FFF70A' AND Name = 'Evidence')) BEGIN
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
            '3038d933-337a-4213-9cef-b303db55afda',
            '903F0793-42D9-4EAF-8BB8-3EEBF8FFF70A', -- Entity: Property Suggestion Evidences
            100005,
            'Evidence',
            'Evidence',
            'Plain text of the evidence: the conveyance key, the owner, the card note.',
            'nvarchar',
            800,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '8cbcbc5d-0b9b-4a5c-9588-ccc88ce0377d' OR (EntityID = '903F0793-42D9-4EAF-8BB8-3EEBF8FFF70A' AND Name = 'SuggestedAt')) BEGIN
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
            '8cbcbc5d-0b9b-4a5c-9588-ccc88ce0377d',
            '903F0793-42D9-4EAF-8BB8-3EEBF8FFF70A', -- Entity: Property Suggestion Evidences
            100006,
            'SuggestedAt',
            'Suggested At',
            'When the suggestion engine wrote this evidence.',
            'datetime2',
            8,
            27,
            7,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '6203f263-d628-4d06-bff4-fa15743cde6a' OR (EntityID = '903F0793-42D9-4EAF-8BB8-3EEBF8FFF70A' AND Name = '__mj_CreatedAt')) BEGIN
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
            '6203f263-d628-4d06-bff4-fa15743cde6a',
            '903F0793-42D9-4EAF-8BB8-3EEBF8FFF70A', -- Entity: Property Suggestion Evidences
            100007,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'c60d42ed-a9fc-4c37-985c-5ecb51614241' OR (EntityID = '903F0793-42D9-4EAF-8BB8-3EEBF8FFF70A' AND Name = '__mj_UpdatedAt')) BEGIN
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
            'c60d42ed-a9fc-4c37-985c-5ecb51614241',
            '903F0793-42D9-4EAF-8BB8-3EEBF8FFF70A', -- Entity: Property Suggestion Evidences
            100008,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ff2b03c2-2faf-4a0b-8c25-f60573760161' OR (EntityID = '60CE2DDA-DDB0-4445-BE61-4303D0174B8C' AND Name = 'GroupingVersion')) BEGIN
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
            'ff2b03c2-2faf-4a0b-8c25-f60573760161',
            '60CE2DDA-DDB0-4445-BE61-4303D0174B8C', -- Entity: Properties
            100027,
            'GroupingVersion',
            'Grouping Version',
            'Set to ConfirmedAt on every confirm or split of this property. Recommendation rows computed on an older version are stale (AppealRecommendation.GroupingVersion).',
            'datetime2',
            8,
            27,
            7,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '8484331b-9a44-4113-8d26-e3cbbafc4956' OR (EntityID = '60CE2DDA-DDB0-4445-BE61-4303D0174B8C' AND Name = 'SplitAt')) BEGIN
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
            '8484331b-9a44-4113-8d26-e3cbbafc4956',
            '60CE2DDA-DDB0-4445-BE61-4303D0174B8C', -- Entity: Properties
            100028,
            'SplitAt',
            'Split At',
            'When a practitioner split this property. Blocks re-suggestion of the same member set by scripts/suggest-properties.js.',
            'datetime2',
            8,
            27,
            7,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '899fd6ae-f819-4e3a-a5d6-b490087011bb' OR (EntityID = '60CE2DDA-DDB0-4445-BE61-4303D0174B8C' AND Name = 'UnitCountSourceURL')) BEGIN
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
            '899fd6ae-f819-4e3a-a5d6-b490087011bb',
            '60CE2DDA-DDB0-4445-BE61-4303D0174B8C', -- Entity: Properties
            100029,
            'UnitCountSourceURL',
            'Unit Count Source URL',
            'The page a Web unit count was read from (operator site, then Visit Indy / Cvent for hotels, then Apartments.com / Apartment Finder; never a units-available count). NULL unless UnitCountSource = Web.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd1bc5e6d-fe5f-4592-b2c2-0b11a5601abd' OR (EntityID = '60CE2DDA-DDB0-4445-BE61-4303D0174B8C' AND Name = 'UnitCountRetrievedAt')) BEGIN
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
            'd1bc5e6d-fe5f-4592-b2c2-0b11a5601abd',
            '60CE2DDA-DDB0-4445-BE61-4303D0174B8C', -- Entity: Properties
            100030,
            'UnitCountRetrievedAt',
            'Unit Count Retrieved At',
            'When the Web unit count was read from UnitCountSourceURL. NULL unless UnitCountSource = Web.',
            'datetime2',
            8,
            27,
            7,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'cabcfe03-7d3f-4fce-a7bb-5e5a6609b84e' OR (EntityID = '04E37D72-B573-4B81-B1E1-A501F1372851' AND Name = 'ID')) BEGIN
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
            'cabcfe03-7d3f-4fce-a7bb-5e5a6609b84e',
            '04E37D72-B573-4B81-B1E1-A501F1372851', -- Entity: Sale Conveyance Members
            100001,
            'ID',
            'ID',
            'Primary key.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'be39c785-0998-4b06-b8fd-4ecff71b2172' OR (EntityID = '04E37D72-B573-4B81-B1E1-A501F1372851' AND Name = 'SaleConveyanceID')) BEGIN
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
            'be39c785-0998-4b06-b8fd-4ecff71b2172',
            '04E37D72-B573-4B81-B1E1-A501F1372851', -- Entity: Sale Conveyance Members
            100002,
            'SaleConveyanceID',
            'Sale Conveyance ID',
            'The conveyance this SaleTransaction row belongs to.',
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
            'ADA5A377-DCA6-440A-9C28-A7F354223568',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'fafa9f38-6d24-4e0a-a38a-c6c072bd43a0' OR (EntityID = '04E37D72-B573-4B81-B1E1-A501F1372851' AND Name = 'SaleTransactionID')) BEGIN
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
            'fafa9f38-6d24-4e0a-a38a-c6c072bd43a0',
            '04E37D72-B573-4B81-B1E1-A501F1372851', -- Entity: Sale Conveyance Members
            100003,
            'SaleTransactionID',
            'Sale Transaction ID',
            'The SaleTransaction row (one parcel''s record of the sale). Unique: a sale row belongs to exactly one conveyance.',
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
            'A4BC54C2-AF4C-44B4-B7F2-39E480BA5485',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '2890853e-689f-4b7b-b352-39ce4597acc5' OR (EntityID = '04E37D72-B573-4B81-B1E1-A501F1372851' AND Name = 'ParcelID')) BEGIN
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
            '2890853e-689f-4b7b-b352-39ce4597acc5',
            '04E37D72-B573-4B81-B1E1-A501F1372851', -- Entity: Sale Conveyance Members
            100004,
            'ParcelID',
            'Parcel ID',
            'The parcel the SaleTransaction row is for, copied from it at rebuild. NULL when the sale row is not matched to a parcel.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'fbde08c2-e482-4da5-8206-9f68b8aa38a8' OR (EntityID = '04E37D72-B573-4B81-B1E1-A501F1372851' AND Name = 'MemberBuildingSqFt')) BEGIN
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
            'fbde08c2-e482-4da5-8206-9f68b8aa38a8',
            '04E37D72-B573-4B81-B1E1-A501F1372851', -- Entity: Sale Conveyance Members
            100005,
            'MemberBuildingSqFt',
            'Member Building Sq Ft',
            'This member''s building SF ex-parking at rebuild. NULL when none is held; an improved member (type group other than Parking or Land) without it makes the conveyance incomplete (IsComplete = 0).',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ec4fbcc2-c39d-49aa-928d-1d07aef936d7' OR (EntityID = '04E37D72-B573-4B81-B1E1-A501F1372851' AND Name = 'MemberUnits')) BEGIN
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
            'ec4fbcc2-c39d-49aa-928d-1d07aef936d7',
            '04E37D72-B573-4B81-B1E1-A501F1372851', -- Entity: Sale Conveyance Members
            100006,
            'MemberUnits',
            'Member Units',
            'This member''s unit or key count at rebuild; NULL when none is held.',
            'decimal',
            9,
            12,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'b06ea103-384f-47db-bb04-0c4d7c75bb1d' OR (EntityID = '04E37D72-B573-4B81-B1E1-A501F1372851' AND Name = 'MemberAcres')) BEGIN
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
            'b06ea103-384f-47db-bb04-0c4d7c75bb1d',
            '04E37D72-B573-4B81-B1E1-A501F1372851', -- Entity: Sale Conveyance Members
            100007,
            'MemberAcres',
            'Member Acres',
            'This member''s acres at rebuild; NULL when none is held.',
            'decimal',
            9,
            12,
            4,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'a73373e3-7d43-4364-8c72-e1ee9a953245' OR (EntityID = '04E37D72-B573-4B81-B1E1-A501F1372851' AND Name = 'ContributesSqFt')) BEGIN
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
            'a73373e3-7d43-4364-8c72-e1ee9a953245',
            '04E37D72-B573-4B81-B1E1-A501F1372851', -- Entity: Sale Conveyance Members
            100008,
            'ContributesSqFt',
            'Contributes Sq Ft',
            'Whether this member''s building SF is part of BuildingSqFtSum: 1 for an improved member with SF, 0 for Parking/Land members (they contribute acres) and for duplicates.',
            'bit',
            1,
            1,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '8fc53a0e-32f3-42ad-8ca0-840bb7a39b43' OR (EntityID = '04E37D72-B573-4B81-B1E1-A501F1372851' AND Name = 'IsDuplicateCard')) BEGIN
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
            '8fc53a0e-32f3-42ad-8ca0-840bb7a39b43',
            '04E37D72-B573-4B81-B1E1-A501F1372851', -- Entity: Sale Conveyance Members
            100009,
            'IsDuplicateCard',
            'Is Duplicate Card',
            '1 when this row is a second card of a parcel already a member of the same conveyance (same parcel, same date, same price). Kept for the record; contributes nothing to the sums.',
            'bit',
            1,
            1,
            0,
            0,
            '(0)',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '19d9ae20-7b2d-4aec-8adf-cf226e77974b' OR (EntityID = '04E37D72-B573-4B81-B1E1-A501F1372851' AND Name = '__mj_CreatedAt')) BEGIN
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
            '19d9ae20-7b2d-4aec-8adf-cf226e77974b',
            '04E37D72-B573-4B81-B1E1-A501F1372851', -- Entity: Sale Conveyance Members
            100010,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7f7387bd-2f34-486c-98ca-61470f013ca9' OR (EntityID = '04E37D72-B573-4B81-B1E1-A501F1372851' AND Name = '__mj_UpdatedAt')) BEGIN
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
            '7f7387bd-2f34-486c-98ca-61470f013ca9',
            '04E37D72-B573-4B81-B1E1-A501F1372851', -- Entity: Sale Conveyance Members
            100011,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '1a45f338-95b3-42a0-b841-e5f9ad44cd91' OR (EntityID = 'ADA5A377-DCA6-440A-9C28-A7F354223568' AND Name = 'ID')) BEGIN
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
            '1a45f338-95b3-42a0-b841-e5f9ad44cd91',
            'ADA5A377-DCA6-440A-9C28-A7F354223568', -- Entity: Sale Conveyances
            100001,
            'ID',
            'ID',
            'Primary key.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '883f7f65-e677-4e8d-81f5-6b9dad51d408' OR (EntityID = 'ADA5A377-DCA6-440A-9C28-A7F354223568' AND Name = 'ConveyanceKey')) BEGIN
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
            '883f7f65-e677-4e8d-81f5-6b9dad51d408',
            'ADA5A377-DCA6-440A-9C28-A7F354223568', -- Entity: Sale Conveyances
            100002,
            'ConveyanceKey',
            'Conveyance Key',
            'The grouping key (spec §2.1): CountyNumber|SaleDate|SalePrice|normOwner(Grantee), using the owner normaliser of build-owner-portfolios.js; where every row of the group lacks a grantee, CountyNumber|SaleDate|SalePrice, accepted only when the members share an owner on the roll today. One row per key.',
            'nvarchar',
            400,
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
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd647c0a5-95a2-494b-8fe2-701fdebe404f' OR (EntityID = 'ADA5A377-DCA6-440A-9C28-A7F354223568' AND Name = 'CountyNumber')) BEGIN
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
            'd647c0a5-95a2-494b-8fe2-701fdebe404f',
            'ADA5A377-DCA6-440A-9C28-A7F354223568', -- Entity: Sale Conveyances
            100003,
            'CountyNumber',
            'County Number',
            'Indiana county number of the conveyed parcels. Part of the key, so a conveyance never spans two counties.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '24d030ce-268d-48fe-8069-a63fa9067c88' OR (EntityID = 'ADA5A377-DCA6-440A-9C28-A7F354223568' AND Name = 'SaleDate')) BEGIN
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
            '24d030ce-268d-48fe-8069-a63fa9067c88',
            'ADA5A377-DCA6-440A-9C28-A7F354223568', -- Entity: Sale Conveyances
            100004,
            'SaleDate',
            'Sale Date',
            'The sale date every member SaleTransaction row carries.',
            'date',
            3,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '523080e4-c626-4f30-bbec-83ddd622258c' OR (EntityID = 'ADA5A377-DCA6-440A-9C28-A7F354223568' AND Name = 'SalePrice')) BEGIN
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
            '523080e4-c626-4f30-bbec-83ddd622258c',
            'ADA5A377-DCA6-440A-9C28-A7F354223568', -- Entity: Sale Conveyances
            100005,
            'SalePrice',
            'Sale Price',
            'The whole conveyance price. SaleTransaction repeats it on every member row; it is counted once here.',
            'decimal',
            9,
            18,
            2,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'b0a486cb-90dd-4467-8d77-b07592558724' OR (EntityID = 'ADA5A377-DCA6-440A-9C28-A7F354223568' AND Name = 'GranteeNormalized')) BEGIN
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
            'b0a486cb-90dd-4467-8d77-b07592558724',
            'ADA5A377-DCA6-440A-9C28-A7F354223568', -- Entity: Sale Conveyances
            100006,
            'GranteeNormalized',
            'Grantee Normalized',
            'The grantee after the owner normaliser of build-owner-portfolios.js. NULL when no member row records a grantee.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '6936f407-8c7f-43fb-ac98-a6db7d386ae6' OR (EntityID = 'ADA5A377-DCA6-440A-9C28-A7F354223568' AND Name = 'KeyBasis')) BEGIN
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
            '6936f407-8c7f-43fb-ac98-a6db7d386ae6',
            'ADA5A377-DCA6-440A-9C28-A7F354223568', -- Entity: Sale Conveyances
            100007,
            'KeyBasis',
            'Key Basis',
            'How the members were grouped: grantee (date, price and normalized grantee agree); owner-corroborated (no grantee recorded, date and price agree, and the members share an owner on the roll today); single (a lone row).',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ff7cfa14-fa59-4a1c-91a8-bb9eb9ffb5b4' OR (EntityID = 'ADA5A377-DCA6-440A-9C28-A7F354223568' AND Name = 'ParcelCount')) BEGIN
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
            'ff7cfa14-fa59-4a1c-91a8-bb9eb9ffb5b4',
            'ADA5A377-DCA6-440A-9C28-A7F354223568', -- Entity: Sale Conveyances
            100008,
            'ParcelCount',
            'Parcel Count',
            'Number of distinct parcels conveyed. Duplicate cards of one parcel (IsDuplicateCard) count once.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '4c398783-5fda-4ede-b1e4-3b6c5e24068c' OR (EntityID = 'ADA5A377-DCA6-440A-9C28-A7F354223568' AND Name = 'DominantTypeGroup')) BEGIN
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
            '4c398783-5fda-4ede-b1e4-3b6c5e24068c',
            'ADA5A377-DCA6-440A-9C28-A7F354223568', -- Entity: Sale Conveyances
            100009,
            'DominantTypeGroup',
            'Dominant Type Group',
            'The type group with the largest summed assessed value among the members; decides UnitOfComparison.',
            'nvarchar',
            60,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '083dcc75-b7eb-4e7e-b53d-2d5652eec553' OR (EntityID = 'ADA5A377-DCA6-440A-9C28-A7F354223568' AND Name = 'UnitOfComparison')) BEGIN
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
            '083dcc75-b7eb-4e7e-b53d-2d5652eec553',
            'ADA5A377-DCA6-440A-9C28-A7F354223568', -- Entity: Sale Conveyances
            100010,
            'UnitOfComparison',
            'Unit Of Comparison',
            'The unit PricePerUnit is in: $/SF, $/unit, $/key or $/acre, decided by DominantTypeGroup through rules/unit-of-comparison.json (spec §4.3). NULL when no unit applies.',
            'nvarchar',
            20,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'e16b4040-df3f-45ca-9d41-3eeac095e55a' OR (EntityID = 'ADA5A377-DCA6-440A-9C28-A7F354223568' AND Name = 'BuildingSqFtSum')) BEGIN
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
            'e16b4040-df3f-45ca-9d41-3eeac095e55a',
            'ADA5A377-DCA6-440A-9C28-A7F354223568', -- Entity: Sale Conveyances
            100011,
            'BuildingSqFtSum',
            'Building Sq Ft Sum',
            'Sum of the members'' building SF ex-parking over members with ContributesSqFt = 1. Parking and Land members and duplicate cards add 0. The $/SF denominator.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '556a5b37-a243-4dfc-848b-6cad0199894d' OR (EntityID = 'ADA5A377-DCA6-440A-9C28-A7F354223568' AND Name = 'UnitSum')) BEGIN
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
            '556a5b37-a243-4dfc-848b-6cad0199894d',
            'ADA5A377-DCA6-440A-9C28-A7F354223568', -- Entity: Sale Conveyances
            100012,
            'UnitSum',
            'Unit Sum',
            'Sum of the members'' unit (multifamily) or key (hospitality) counts, duplicate cards excluded. The $/unit or $/key denominator.',
            'decimal',
            9,
            12,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '4e5cc97d-c930-43dd-8166-27fb7a7c6075' OR (EntityID = 'ADA5A377-DCA6-440A-9C28-A7F354223568' AND Name = 'AcreSum')) BEGIN
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
            '4e5cc97d-c930-43dd-8166-27fb7a7c6075',
            'ADA5A377-DCA6-440A-9C28-A7F354223568', -- Entity: Sale Conveyances
            100013,
            'AcreSum',
            'Acre Sum',
            'Sum of the members'' acres, duplicate cards excluded. The $/acre denominator.',
            'decimal',
            9,
            12,
            4,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '727be856-9814-4c05-8c3c-f2f39e5bb590' OR (EntityID = 'ADA5A377-DCA6-440A-9C28-A7F354223568' AND Name = 'IsComplete')) BEGIN
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
            '727be856-9814-4c05-8c3c-f2f39e5bb590',
            'ADA5A377-DCA6-440A-9C28-A7F354223568', -- Entity: Sale Conveyances
            100014,
            'IsComplete',
            'Is Complete',
            'True when every improved member (type group other than Parking or Land) carries building SF, so PricePerUnit is a whole-property figure. False = the conveyance leaves the comp pool with DropReason multi-parcel-denominator-incomplete.',
            'bit',
            1,
            1,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'cc3b7736-0b2b-49a4-b767-70a78a0ea100' OR (EntityID = 'ADA5A377-DCA6-440A-9C28-A7F354223568' AND Name = 'PricePerUnit')) BEGIN
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
            'cc3b7736-0b2b-49a4-b767-70a78a0ea100',
            'ADA5A377-DCA6-440A-9C28-A7F354223568', -- Entity: Sale Conveyances
            100015,
            'PricePerUnit',
            'Price Per Unit',
            'Whole price over the summed denominator in UnitOfComparison ($/SF over BuildingSqFtSum, $/unit or $/key over UnitSum, $/acre over AcreSum). Null when IsComplete = 0 or the denominator sum is zero.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '810cdc15-2ecf-42ff-9bb1-52be1d6f64c6' OR (EntityID = 'ADA5A377-DCA6-440A-9C28-A7F354223568' AND Name = 'AssessedAtSaleSum')) BEGIN
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
            '810cdc15-2ecf-42ff-9bb1-52be1d6f64c6',
            'ADA5A377-DCA6-440A-9C28-A7F354223568', -- Entity: Sale Conveyances
            100016,
            'AssessedAtSaleSum',
            'Assessed At Sale Sum',
            'Sum of the members'' AssessedValueAtSale, duplicate cards excluded; NULL when any member lacks one. The denominator of SaleToAssessedRatio.',
            'decimal',
            9,
            18,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '4e671af1-1012-4992-bffb-3b8b49f0dc50' OR (EntityID = 'ADA5A377-DCA6-440A-9C28-A7F354223568' AND Name = 'SaleToAssessedRatio')) BEGIN
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
            '4e671af1-1012-4992-bffb-3b8b49f0dc50',
            'ADA5A377-DCA6-440A-9C28-A7F354223568', -- Entity: Sale Conveyances
            100017,
            'SaleToAssessedRatio',
            'Sale To Assessed Ratio',
            'SalePrice over the members'' summed AssessedValueAtSale; null when any member lacks one. Read by signal S10 (own sale).',
            'decimal',
            5,
            9,
            4,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '04cf56e4-9694-4714-b527-175cc621f4c4' OR (EntityID = 'ADA5A377-DCA6-440A-9C28-A7F354223568' AND Name = 'RebuiltAt')) BEGIN
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
            '04cf56e4-9694-4714-b527-175cc621f4c4',
            'ADA5A377-DCA6-440A-9C28-A7F354223568', -- Entity: Sale Conveyances
            100018,
            'RebuiltAt',
            'Rebuilt At',
            'When scripts/rebuild-sale-conveyances.js wrote this row. Conveyances are rebuilt whole from SaleTransaction, never edited by hand.',
            'datetime2',
            8,
            27,
            7,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '04c86ff7-11ec-4ddc-884f-99ff0f86ee58' OR (EntityID = 'ADA5A377-DCA6-440A-9C28-A7F354223568' AND Name = '__mj_CreatedAt')) BEGIN
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
            '04c86ff7-11ec-4ddc-884f-99ff0f86ee58',
            'ADA5A377-DCA6-440A-9C28-A7F354223568', -- Entity: Sale Conveyances
            100019,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ffc5e690-7d43-4f24-9c57-8db19bd0c6f5' OR (EntityID = 'ADA5A377-DCA6-440A-9C28-A7F354223568' AND Name = '__mj_UpdatedAt')) BEGIN
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
            'ffc5e690-7d43-4f24-9c57-8db19bd0c6f5',
            'ADA5A377-DCA6-440A-9C28-A7F354223568', -- Entity: Sale Conveyances
            100020,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'be14804d-3f82-43e3-89e0-e8c4cae421fd' OR (EntityID = '27770192-813F-4E84-A3FA-A856F29920EE' AND Name = 'ID')) BEGIN
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
            'be14804d-3f82-43e3-89e0-e8c4cae421fd',
            '27770192-813F-4E84-A3FA-A856F29920EE', -- Entity: Appeal Recommendation Signals
            100001,
            'ID',
            'ID',
            'Primary key.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ac9f12b3-0c56-4bf1-8064-7dec7c1e36bd' OR (EntityID = '27770192-813F-4E84-A3FA-A856F29920EE' AND Name = 'AppealRecommendationID')) BEGIN
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
            'ac9f12b3-0c56-4bf1-8064-7dec7c1e36bd',
            '27770192-813F-4E84-A3FA-A856F29920EE', -- Entity: Appeal Recommendation Signals
            100002,
            'AppealRecommendationID',
            'Appeal Recommendation ID',
            'The recommendation this signal belongs to.',
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
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '87ff5bf2-7a33-49dd-a2f9-ecc759c1c9f5' OR (EntityID = '27770192-813F-4E84-A3FA-A856F29920EE' AND Name = 'SignalCode')) BEGIN
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
            '87ff5bf2-7a33-49dd-a2f9-ecc759c1c9f5',
            '27770192-813F-4E84-A3FA-A856F29920EE', -- Entity: Appeal Recommendation Signals
            100003,
            'SignalCode',
            'Signal Code',
            'S1 assessment comps (neighborhood); S2 assessment comps (county); S3 sales unadjusted; S4 sales adjusted; S5 income; S6 increase over 5% (flag); S7 PTABOA record; S8 out of line with peers (flag); S9 class threshold; S10 own sale (spec §5).',
            'nvarchar',
            8,
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
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'b5d1a3cf-6e50-4248-adc9-d2ef231f1ef0' OR (EntityID = '27770192-813F-4E84-A3FA-A856F29920EE' AND Name = 'Supports')) BEGIN
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
            'b5d1a3cf-6e50-4248-adc9-d2ef231f1ef0',
            '27770192-813F-4E84-A3FA-A856F29920EE', -- Entity: Appeal Recommendation Signals
            100004,
            'Supports',
            'Supports',
            'Yes: the signal points to an appeal by its rule in rules/appeal-signals.json; No: it does not; NA: it cannot be evaluated (NAReason says why); Contrary: S10 only, an own sale at or above AV.',
            'nvarchar',
            20,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'b91bf5a2-84b3-4d39-9b5d-dcd36be9436f' OR (EntityID = '27770192-813F-4E84-A3FA-A856F29920EE' AND Name = 'NAReason')) BEGIN
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
            'b91bf5a2-84b3-4d39-9b5d-dcd36be9436f',
            '27770192-813F-4E84-A3FA-A856F29920EE', -- Entity: Appeal Recommendation Signals
            100005,
            'NAReason',
            'NA Reason',
            'Why the signal is NA, for example fewer than 3 comps, decisions < 5, no pro forma, no prior year, member-missing-year, member-exception-<code>; NULL otherwise.',
            'nvarchar',
            120,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '75012c65-fd3e-4cb6-98c9-dffc181b224a' OR (EntityID = '27770192-813F-4E84-A3FA-A856F29920EE' AND Name = 'IndicatedValue')) BEGIN
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
            '75012c65-fd3e-4cb6-98c9-dffc181b224a',
            '27770192-813F-4E84-A3FA-A856F29920EE', -- Entity: Appeal Recommendation Signals
            100006,
            'IndicatedValue',
            'Indicated Value',
            'The total value this signal indicates for the subject (indicated per unit x the subject denominator, or the lane''s value); NULL when it gives none.',
            'decimal',
            9,
            18,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'f2dfa4c0-486a-4158-b6d7-9bad7aa6a91b' OR (EntityID = '27770192-813F-4E84-A3FA-A856F29920EE' AND Name = 'IndicatedPerUnit')) BEGIN
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
            'f2dfa4c0-486a-4158-b6d7-9bad7aa6a91b',
            '27770192-813F-4E84-A3FA-A856F29920EE', -- Entity: Appeal Recommendation Signals
            100007,
            'IndicatedPerUnit',
            'Indicated Per Unit',
            'The signal''s per-unit figure in UnitOfComparison; never shown or stored without a denominator (integrity per-unit-never-without-denominator).',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '8bb3ecc6-c479-4fe8-808d-2a309db1ba27' OR (EntityID = '27770192-813F-4E84-A3FA-A856F29920EE' AND Name = 'UnitOfComparison')) BEGIN
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
            '8bb3ecc6-c479-4fe8-808d-2a309db1ba27',
            '27770192-813F-4E84-A3FA-A856F29920EE', -- Entity: Appeal Recommendation Signals
            100008,
            'UnitOfComparison',
            'Unit Of Comparison',
            'The unit IndicatedPerUnit is in: $/SF, $/unit, $/key or $/acre.',
            'nvarchar',
            20,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '625c1d93-1619-4390-8d74-50571e52436c' OR (EntityID = '27770192-813F-4E84-A3FA-A856F29920EE' AND Name = 'EvidenceCount')) BEGIN
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
            '625c1d93-1619-4390-8d74-50571e52436c',
            '27770192-813F-4E84-A3FA-A856F29920EE', -- Entity: Appeal Recommendation Signals
            100009,
            'EvidenceCount',
            'Evidence Count',
            'How many records the signal rests on (comps, selected sales, decisions, peers); NULL where a count does not apply.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'be464190-4864-44d4-acfb-337766379ccf' OR (EntityID = '27770192-813F-4E84-A3FA-A856F29920EE' AND Name = 'EvidenceNote')) BEGIN
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
            'be464190-4864-44d4-acfb-337766379ccf',
            '27770192-813F-4E84-A3FA-A856F29920EE', -- Entity: Appeal Recommendation Signals
            100010,
            'EvidenceNote',
            'Evidence Note',
            'Plain text of what the signal read and found, for the reviewer (for example which side of a split land and improvement comparison carried the indication).',
            'nvarchar',
            800,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'e4195d28-2e65-46b2-b48b-5309b8773903' OR (EntityID = '27770192-813F-4E84-A3FA-A856F29920EE' AND Name = 'RuleVersion')) BEGIN
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
            'e4195d28-2e65-46b2-b48b-5309b8773903',
            '27770192-813F-4E84-A3FA-A856F29920EE', -- Entity: Appeal Recommendation Signals
            100011,
            'RuleVersion',
            'Rule Version',
            'The version of the rule file the signal''s thresholds came from (rules/appeal-signals.json, class-thresholds.json, unit-of-comparison.json); every threshold change is a new version.',
            'nvarchar',
            80,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '9493c56c-3d80-4195-a213-fc5654e8ad82' OR (EntityID = '27770192-813F-4E84-A3FA-A856F29920EE' AND Name = '__mj_CreatedAt')) BEGIN
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
            '9493c56c-3d80-4195-a213-fc5654e8ad82',
            '27770192-813F-4E84-A3FA-A856F29920EE', -- Entity: Appeal Recommendation Signals
            100012,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd173b378-d189-4eb1-a813-ae49c69655d5' OR (EntityID = '27770192-813F-4E84-A3FA-A856F29920EE' AND Name = '__mj_UpdatedAt')) BEGIN
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
            'd173b378-d189-4eb1-a813-ae49c69655d5',
            '27770192-813F-4E84-A3FA-A856F29920EE', -- Entity: Appeal Recommendation Signals
            100013,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ce96492d-f2a5-4203-b472-2b0502d95223' OR (EntityID = '785D1ECA-0EE2-40C8-B1EE-C5AFED5C5C6A' AND Name = 'ID')) BEGIN
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
            'ce96492d-f2a5-4203-b472-2b0502d95223',
            '785D1ECA-0EE2-40C8-B1EE-C5AFED5C5C6A', -- Entity: Appeal Recommendation Parcels
            100001,
            'ID',
            'ID',
            'Primary key.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '872b314f-0667-4420-bdc5-1e07158b0d83' OR (EntityID = '785D1ECA-0EE2-40C8-B1EE-C5AFED5C5C6A' AND Name = 'AppealRecommendationID')) BEGIN
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
            '872b314f-0667-4420-bdc5-1e07158b0d83',
            '785D1ECA-0EE2-40C8-B1EE-C5AFED5C5C6A', -- Entity: Appeal Recommendation Parcels
            100002,
            'AppealRecommendationID',
            'Appeal Recommendation ID',
            'The property-subject recommendation being allocated.',
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
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '54542e53-7cbb-4dcd-b4a7-3dd98eaf6f47' OR (EntityID = '785D1ECA-0EE2-40C8-B1EE-C5AFED5C5C6A' AND Name = 'ParcelID')) BEGIN
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
            '54542e53-7cbb-4dcd-b4a7-3dd98eaf6f47',
            '785D1ECA-0EE2-40C8-B1EE-C5AFED5C5C6A', -- Entity: Appeal Recommendation Parcels
            100003,
            'ParcelID',
            'Parcel ID',
            'The member parcel.',
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
            1,
            'Search',
            GETUTCDATE(),
            GETUTCDATE()
         )
      END;

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '4f89a64c-403e-4e7a-898b-f02c045f9986' OR (EntityID = '785D1ECA-0EE2-40C8-B1EE-C5AFED5C5C6A' AND Name = 'MemberCurrentAV')) BEGIN
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
            '4f89a64c-403e-4e7a-898b-f02c045f9986',
            '785D1ECA-0EE2-40C8-B1EE-C5AFED5C5C6A', -- Entity: Appeal Recommendation Parcels
            100004,
            'MemberCurrentAV',
            'Member Current AV',
            'The member''s current AV for the assessment year, the basis of AllocationShare.',
            'decimal',
            9,
            18,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ca3c64b6-d710-40ad-8e9e-c45a27f62186' OR (EntityID = '785D1ECA-0EE2-40C8-B1EE-C5AFED5C5C6A' AND Name = 'AllocationShare')) BEGIN
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
            'ca3c64b6-d710-40ad-8e9e-c45a27f62186',
            '785D1ECA-0EE2-40C8-B1EE-C5AFED5C5C6A', -- Entity: Appeal Recommendation Parcels
            100005,
            'AllocationShare',
            'Allocation Share',
            'The member''s share of the property total: MemberCurrentAV over the summed CurrentAV, unless AllocationOverride. Shares sum to 1.',
            'decimal',
            5,
            9,
            6,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '4f350815-368b-4f90-a9ea-745243432c50' OR (EntityID = '785D1ECA-0EE2-40C8-B1EE-C5AFED5C5C6A' AND Name = 'AllocatedFloor')) BEGIN
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
            '4f350815-368b-4f90-a9ea-745243432c50',
            '785D1ECA-0EE2-40C8-B1EE-C5AFED5C5C6A', -- Entity: Appeal Recommendation Parcels
            100006,
            'AllocatedFloor',
            'Allocated Floor',
            'FloorValue x AllocationShare.',
            'decimal',
            9,
            18,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'ed60f832-3b24-408f-a25a-2d2f0fea8cff' OR (EntityID = '785D1ECA-0EE2-40C8-B1EE-C5AFED5C5C6A' AND Name = 'AllocatedAsk')) BEGIN
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
            'ed60f832-3b24-408f-a25a-2d2f0fea8cff',
            '785D1ECA-0EE2-40C8-B1EE-C5AFED5C5C6A', -- Entity: Appeal Recommendation Parcels
            100007,
            'AllocatedAsk',
            'Allocated Ask',
            'AskValue x AllocationShare: the value to ask for on this parcel''s Form 130.',
            'decimal',
            9,
            18,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'dac2ced7-a348-4aa2-a9bf-083f5fca5d74' OR (EntityID = '785D1ECA-0EE2-40C8-B1EE-C5AFED5C5C6A' AND Name = 'AllocatedSavingsAtAsk')) BEGIN
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
            'dac2ced7-a348-4aa2-a9bf-083f5fca5d74',
            '785D1ECA-0EE2-40C8-B1EE-C5AFED5C5C6A', -- Entity: Appeal Recommendation Parcels
            100008,
            'AllocatedSavingsAtAsk',
            'Allocated Savings At Ask',
            'EstSavingsAtAsk allocated to this parcel; Owner Prospects reads it.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '61dfb5f7-c99c-451e-addd-2db9005440cd' OR (EntityID = '785D1ECA-0EE2-40C8-B1EE-C5AFED5C5C6A' AND Name = 'AllocatedSavingsAtFloor')) BEGIN
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
            '61dfb5f7-c99c-451e-addd-2db9005440cd',
            '785D1ECA-0EE2-40C8-B1EE-C5AFED5C5C6A', -- Entity: Appeal Recommendation Parcels
            100009,
            'AllocatedSavingsAtFloor',
            'Allocated Savings At Floor',
            'EstSavingsAtFloor allocated to this parcel.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '9d617367-4023-45a8-aa4a-c01a426b0829' OR (EntityID = '785D1ECA-0EE2-40C8-B1EE-C5AFED5C5C6A' AND Name = 'AllocationOverride')) BEGIN
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
            '9d617367-4023-45a8-aa4a-c01a426b0829',
            '785D1ECA-0EE2-40C8-B1EE-C5AFED5C5C6A', -- Entity: Appeal Recommendation Parcels
            100010,
            'AllocationOverride',
            'Allocation Override',
            '1 when the practitioner set this member''s share by hand instead of by current AV.',
            'bit',
            1,
            1,
            0,
            0,
            '(0)',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '2b58707d-c291-4b94-a106-07a9b240cb14' OR (EntityID = '785D1ECA-0EE2-40C8-B1EE-C5AFED5C5C6A' AND Name = '__mj_CreatedAt')) BEGIN
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
            '2b58707d-c291-4b94-a106-07a9b240cb14',
            '785D1ECA-0EE2-40C8-B1EE-C5AFED5C5C6A', -- Entity: Appeal Recommendation Parcels
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'fc6a2bab-53f1-4875-8831-04b647dab380' OR (EntityID = '785D1ECA-0EE2-40C8-B1EE-C5AFED5C5C6A' AND Name = '__mj_UpdatedAt')) BEGIN
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
            'fc6a2bab-53f1-4875-8831-04b647dab380',
            '785D1ECA-0EE2-40C8-B1EE-C5AFED5C5C6A', -- Entity: Appeal Recommendation Parcels
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

/* SQL text to insert entity field value with ID 9f766aad-8cdb-450d-ae38-e7502cc1ce5b */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('9f766aad-8cdb-450d-ae38-e7502cc1ce5b', '6936F407-8C7F-43FB-AC98-A6DB7D386AE6', 1, 'grantee', 'grantee', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 234f17cb-dbed-4a3a-a9b9-1acb2911eef7 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('234f17cb-dbed-4a3a-a9b9-1acb2911eef7', '6936F407-8C7F-43FB-AC98-A6DB7D386AE6', 2, 'owner-corroborated', 'owner-corroborated', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 36c935b7-25ed-4ab6-bb01-37699c186a54 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('36c935b7-25ed-4ab6-bb01-37699c186a54', '6936F407-8C7F-43FB-AC98-A6DB7D386AE6', 3, 'single', 'single', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 6936F407-8C7F-43FB-AC98-A6DB7D386AE6 */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='6936F407-8C7F-43FB-AC98-A6DB7D386AE6';

/* SQL text to insert entity field value with ID 6a4432f4-fcf6-4617-8341-26ad35c4a776 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('6a4432f4-fcf6-4617-8341-26ad35c4a776', '083DCC75-B7EB-4E7E-B53D-2D5652EEC553', 1, '$/SF', '$/SF', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 358b7de2-2449-4b4d-8eb3-da2c9dcda67c */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('358b7de2-2449-4b4d-8eb3-da2c9dcda67c', '083DCC75-B7EB-4E7E-B53D-2D5652EEC553', 2, '$/acre', '$/acre', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 3443a827-94af-43c0-9352-2a2cbaa005be */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('3443a827-94af-43c0-9352-2a2cbaa005be', '083DCC75-B7EB-4E7E-B53D-2D5652EEC553', 3, '$/key', '$/key', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID a0a2a947-4895-49b1-b4d9-a567674d2a46 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('a0a2a947-4895-49b1-b4d9-a567674d2a46', '083DCC75-B7EB-4E7E-B53D-2D5652EEC553', 4, '$/unit', '$/unit', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 083DCC75-B7EB-4E7E-B53D-2D5652EEC553 */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='083DCC75-B7EB-4E7E-B53D-2D5652EEC553';

/* SQL text to insert entity field value with ID a4919d53-4d38-48e5-8f1c-06c4cbea18f5 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('a4919d53-4d38-48e5-8f1c-06c4cbea18f5', 'DD149791-D02E-43D5-A9AD-7628D5DA6DC4', 1, 'Appeal', 'Appeal', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID cd441ab1-4638-49a3-ad6f-60b4547a50d6 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('cd441ab1-4638-49a3-ad6f-60b4547a50d6', 'DD149791-D02E-43D5-A9AD-7628D5DA6DC4', 2, 'Consider', 'Consider', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 4879a1d9-af09-46a6-a081-15815794b3e9 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('4879a1d9-af09-46a6-a081-15815794b3e9', 'DD149791-D02E-43D5-A9AD-7628D5DA6DC4', 3, 'No', 'No', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 81fd54ab-34ea-4c06-a2dd-2baa0c5ee698 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('81fd54ab-34ea-4c06-a2dd-2baa0c5ee698', 'DD149791-D02E-43D5-A9AD-7628D5DA6DC4', 4, 'not-available', 'not-available', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID DD149791-D02E-43D5-A9AD-7628D5DA6DC4 */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='DD149791-D02E-43D5-A9AD-7628D5DA6DC4';

/* SQL text to insert entity field value with ID e6e0b53b-9ab1-4c9d-b7b4-22fdd696b408 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('e6e0b53b-9ab1-4c9d-b7b4-22fdd696b408', 'D412626F-751F-44F7-A1B7-12BF6E980514', 1, 'High', 'High', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID ac1a4015-2de7-4aa5-9c69-677625b3f731 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('ac1a4015-2de7-4aa5-9c69-677625b3f731', 'D412626F-751F-44F7-A1B7-12BF6E980514', 2, 'Low', 'Low', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 5118242a-2a84-4163-8561-170eed40bcf3 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('5118242a-2a84-4163-8561-170eed40bcf3', 'D412626F-751F-44F7-A1B7-12BF6E980514', 3, 'Medium', 'Medium', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID D412626F-751F-44F7-A1B7-12BF6E980514 */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='D412626F-751F-44F7-A1B7-12BF6E980514';

/* SQL text to insert entity field value with ID 950ab60f-68c7-46f3-94fa-047169cf8e58 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('950ab60f-68c7-46f3-94fa-047169cf8e58', '1826970A-AE2B-4F20-AD92-6DF87139F37B', 1, 'Lowest', 'Lowest', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 746c51c2-2a31-4fe4-afff-af2081214108 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('746c51c2-2a31-4fe4-afff-af2081214108', '1826970A-AE2B-4F20-AD92-6DF87139F37B', 2, 'SecondLowest', 'SecondLowest', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 1826970A-AE2B-4F20-AD92-6DF87139F37B */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='1826970A-AE2B-4F20-AD92-6DF87139F37B';

/* SQL text to insert entity field value with ID 13810bc2-da02-42f0-aa75-c4c325610e2c */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('13810bc2-da02-42f0-aa75-c4c325610e2c', 'E894CCFB-C162-47E3-9762-3310825BC8F4', 1, 'lowest-supported', 'lowest-supported', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 91d760e3-0449-417c-a996-855dcb25d0ff */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('91d760e3-0449-417c-a996-855dcb25d0ff', 'E894CCFB-C162-47E3-9762-3310825BC8F4', 2, 'own-sale-cap', 'own-sale-cap', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID b414d409-d0f2-470f-8cda-beb98d0c282d */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('b414d409-d0f2-470f-8cda-beb98d0c282d', 'E894CCFB-C162-47E3-9762-3310825BC8F4', 3, 'prior-year-floor', 'prior-year-floor', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID E894CCFB-C162-47E3-9762-3310825BC8F4 */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='E894CCFB-C162-47E3-9762-3310825BC8F4';

/* SQL text to insert entity field value with ID 9b9633dd-a18c-49ae-9122-80ee9c7a39f2 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('9b9633dd-a18c-49ae-9122-80ee9c7a39f2', '3CF4424D-82F5-44F7-8BAC-0D64AE748E0E', 1, 'Confirmed', 'Confirmed', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 6427c537-6cfa-4c37-957e-9eea8d263c16 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('6427c537-6cfa-4c37-957e-9eea8d263c16', '3CF4424D-82F5-44F7-8BAC-0D64AE748E0E', 2, 'Provisional', 'Provisional', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID e78fbc37-1a34-433b-8d4e-08fdcaa8c9a1 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('e78fbc37-1a34-433b-8d4e-08fdcaa8c9a1', '3CF4424D-82F5-44F7-8BAC-0D64AE748E0E', 3, 'Standalone', 'Standalone', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 0d7fd111-f619-4b7a-ac19-c457bfa499fc */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('0d7fd111-f619-4b7a-ac19-c457bfa499fc', '3CF4424D-82F5-44F7-8BAC-0D64AE748E0E', 4, 'Suggested-unrolled', 'Suggested-unrolled', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 3CF4424D-82F5-44F7-8BAC-0D64AE748E0E */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='3CF4424D-82F5-44F7-8BAC-0D64AE748E0E';

/* SQL text to insert entity field value with ID 33d3a389-a88d-4b4b-bd1c-23326f355b41 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('33d3a389-a88d-4b4b-bd1c-23326f355b41', '87FF5BF2-7A33-49DD-A2F9-ECC759C1C9F5', 1, 'S1', 'S1', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 202e09bc-63f1-4ded-924a-33c174401169 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('202e09bc-63f1-4ded-924a-33c174401169', '87FF5BF2-7A33-49DD-A2F9-ECC759C1C9F5', 2, 'S10', 'S10', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 274695fa-4e85-492b-9dcf-6c782e956858 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('274695fa-4e85-492b-9dcf-6c782e956858', '87FF5BF2-7A33-49DD-A2F9-ECC759C1C9F5', 3, 'S2', 'S2', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 8cf364c0-16f5-4696-b327-918da6b3d125 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('8cf364c0-16f5-4696-b327-918da6b3d125', '87FF5BF2-7A33-49DD-A2F9-ECC759C1C9F5', 4, 'S3', 'S3', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 189424bf-549e-425a-a5ae-540bf6543a6a */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('189424bf-549e-425a-a5ae-540bf6543a6a', '87FF5BF2-7A33-49DD-A2F9-ECC759C1C9F5', 5, 'S4', 'S4', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 47e22781-0483-40b2-827c-bf7770e56288 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('47e22781-0483-40b2-827c-bf7770e56288', '87FF5BF2-7A33-49DD-A2F9-ECC759C1C9F5', 6, 'S5', 'S5', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID f6e41aae-32f7-492d-8cab-30bee1a271c5 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('f6e41aae-32f7-492d-8cab-30bee1a271c5', '87FF5BF2-7A33-49DD-A2F9-ECC759C1C9F5', 7, 'S6', 'S6', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 06caa1b5-ab00-459e-96dc-3ac89bd41e4c */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('06caa1b5-ab00-459e-96dc-3ac89bd41e4c', '87FF5BF2-7A33-49DD-A2F9-ECC759C1C9F5', 8, 'S7', 'S7', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID f04f016b-8929-4aca-8bd5-4e5cb676ef66 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('f04f016b-8929-4aca-8bd5-4e5cb676ef66', '87FF5BF2-7A33-49DD-A2F9-ECC759C1C9F5', 9, 'S8', 'S8', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 709072c0-8ee5-4640-9734-9ba0c43bb015 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('709072c0-8ee5-4640-9734-9ba0c43bb015', '87FF5BF2-7A33-49DD-A2F9-ECC759C1C9F5', 10, 'S9', 'S9', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 87FF5BF2-7A33-49DD-A2F9-ECC759C1C9F5 */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='87FF5BF2-7A33-49DD-A2F9-ECC759C1C9F5';

/* SQL text to insert entity field value with ID bd5c7075-1dfc-46d5-9e06-9b67d4cdd1c4 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('bd5c7075-1dfc-46d5-9e06-9b67d4cdd1c4', 'B5D1A3CF-6E50-4248-ADC9-D2EF231F1EF0', 1, 'Contrary', 'Contrary', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 0c88283b-35f5-4d9b-9b51-96aeb7a74066 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('0c88283b-35f5-4d9b-9b51-96aeb7a74066', 'B5D1A3CF-6E50-4248-ADC9-D2EF231F1EF0', 2, 'NA', 'NA', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID e995f83e-a521-4d77-aedc-7fefce79ead7 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('e995f83e-a521-4d77-aedc-7fefce79ead7', 'B5D1A3CF-6E50-4248-ADC9-D2EF231F1EF0', 3, 'No', 'No', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID c2ad4dad-b35f-48d5-ba4e-23a09a9d8731 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('c2ad4dad-b35f-48d5-ba4e-23a09a9d8731', 'B5D1A3CF-6E50-4248-ADC9-D2EF231F1EF0', 4, 'Yes', 'Yes', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID B5D1A3CF-6E50-4248-ADC9-D2EF231F1EF0 */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='B5D1A3CF-6E50-4248-ADC9-D2EF231F1EF0';

/* SQL text to insert entity field value with ID a2f1cf1c-a968-4742-b80f-ecb67fe16cbd */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('a2f1cf1c-a968-4742-b80f-ecb67fe16cbd', '36AA022E-CB91-4A2D-8BB9-1F26A75A0DD5', 1, 'A', 'A', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 3edd3ae7-92e2-4b84-bbcb-da1f3bba9699 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('3edd3ae7-92e2-4b84-bbcb-da1f3bba9699', '36AA022E-CB91-4A2D-8BB9-1F26A75A0DD5', 2, 'B', 'B', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 999a4325-0b27-492a-b0ec-c913bc2b74b4 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('999a4325-0b27-492a-b0ec-c913bc2b74b4', '36AA022E-CB91-4A2D-8BB9-1F26A75A0DD5', 3, 'C', 'C', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 554d08f4-f06a-43cf-9a02-d1c64714f776 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('554d08f4-f06a-43cf-9a02-d1c64714f776', '36AA022E-CB91-4A2D-8BB9-1F26A75A0DD5', 4, 'D', 'D', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID 3b31f82a-65ae-4522-bc40-815a15fcd2bd */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('3b31f82a-65ae-4522-bc40-815a15fcd2bd', '36AA022E-CB91-4A2D-8BB9-1F26A75A0DD5', 5, 'E', 'E', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 36AA022E-CB91-4A2D-8BB9-1F26A75A0DD5 */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='36AA022E-CB91-4A2D-8BB9-1F26A75A0DD5';

/* SQL text to insert entity field value with ID 2f0b3ff3-f42f-412e-b6d6-c066da439b82 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('2f0b3ff3-f42f-412e-b6d6-c066da439b82', '710A2CC4-90B4-49A1-9125-FDED0D9A9995', 1, 'A', 'A', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID dbd886d9-5e95-4830-aea6-959e49fdf70f */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('dbd886d9-5e95-4830-aea6-959e49fdf70f', '710A2CC4-90B4-49A1-9125-FDED0D9A9995', 2, 'B', 'B', GETUTCDATE(), GETUTCDATE());

/* SQL text to insert entity field value with ID ac554122-6fda-4a67-bb4e-c8fa574ae506 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('ac554122-6fda-4a67-bb4e-c8fa574ae506', '710A2CC4-90B4-49A1-9125-FDED0D9A9995', 3, 'C', 'C', GETUTCDATE(), GETUTCDATE());

/* SQL text to update ValueListType for entity field ID 710A2CC4-90B4-49A1-9125-FDED0D9A9995 */
UPDATE [${flyway:defaultSchema}].[EntityField] SET ValueListType='List' WHERE ID='710A2CC4-90B4-49A1-9125-FDED0D9A9995';

/* SQL text to insert entity field value with ID 6bc44d94-b012-4e81-ac1e-ddbe94945cd3 */
INSERT INTO [${flyway:defaultSchema}].[EntityFieldValue]
                                       ([ID], [EntityFieldID], [Sequence], [Value], [Code], [__mj_CreatedAt], [__mj_UpdatedAt])
                                    VALUES
                                       ('6bc44d94-b012-4e81-ac1e-ddbe94945cd3', 'B3D211D1-C386-402E-BEEE-2B4F82D5F6BF', 5, 'Web', 'Web', GETUTCDATE(), GETUTCDATE());


/* Create Entity Relationship: Appeal Recommendations -> Appeal Recommendation Parcels (One To Many via AppealRecommendationID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '22d7609d-ae4b-49a8-9266-691b3d312b64'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('22d7609d-ae4b-49a8-9266-691b3d312b64', '39DD9AEC-F3C1-425C-85EA-3261C47173D2', '785D1ECA-0EE2-40C8-B1EE-C5AFED5C5C6A', 'AppealRecommendationID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: Appeal Recommendations -> Appeal Recommendation Signals (One To Many via AppealRecommendationID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '3f787b0d-c478-4295-b8ac-2d91021b8fe6'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('3f787b0d-c478-4295-b8ac-2d91021b8fe6', '39DD9AEC-F3C1-425C-85EA-3261C47173D2', '27770192-813F-4E84-A3FA-A856F29920EE', 'AppealRecommendationID', 'One To Many', 1, 1, 2, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: Sale Transactions -> Sale Conveyance Members (One To Many via SaleTransactionID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '29ae7026-f181-4055-b6a8-4a947f69c26e'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('29ae7026-f181-4055-b6a8-4a947f69c26e', 'A4BC54C2-AF4C-44B4-B7F2-39E480BA5485', '04E37D72-B573-4B81-B1E1-A501F1372851', 'SaleTransactionID', 'One To Many', 1, 1, 3, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: Properties -> Appeal Recommendations (One To Many via PropertyID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '51343862-5504-402e-a1ee-5a9154c49936'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('51343862-5504-402e-a1ee-5a9154c49936', '60CE2DDA-DDB0-4445-BE61-4303D0174B8C', '39DD9AEC-F3C1-425C-85EA-3261C47173D2', 'PropertyID', 'One To Many', 1, 1, 3, GETUTCDATE(), GETUTCDATE())
   END;
                    
/* Create Entity Relationship: Properties -> Property Suggestion Evidences (One To Many via PropertyID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = 'e8200890-7a4f-44db-b995-aa636bb43472'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('e8200890-7a4f-44db-b995-aa636bb43472', '60CE2DDA-DDB0-4445-BE61-4303D0174B8C', '903F0793-42D9-4EAF-8BB8-3EEBF8FFF70A', 'PropertyID', 'One To Many', 1, 1, 4, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: Parcels -> Appeal Recommendations (One To Many via ParcelID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '69e361cb-eada-48ce-832b-77a295727cb6'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('69e361cb-eada-48ce-832b-77a295727cb6', 'D0F9D3D3-2E68-4ABA-8891-8DEC85F300FB', '39DD9AEC-F3C1-425C-85EA-3261C47173D2', 'ParcelID', 'One To Many', 1, 1, 35, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: Parcels -> Appeal Recommendation Parcels (One To Many via ParcelID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '128c06c7-cd63-4acc-8343-88e49ca15646'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('128c06c7-cd63-4acc-8343-88e49ca15646', 'D0F9D3D3-2E68-4ABA-8891-8DEC85F300FB', '785D1ECA-0EE2-40C8-B1EE-C5AFED5C5C6A', 'ParcelID', 'One To Many', 1, 1, 36, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: Parcels -> Sale Conveyance Members (One To Many via ParcelID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '91425afd-edf4-46e0-bce0-334f38db62d1'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('91425afd-edf4-46e0-bce0-334f38db62d1', 'D0F9D3D3-2E68-4ABA-8891-8DEC85F300FB', '04E37D72-B573-4B81-B1E1-A501F1372851', 'ParcelID', 'One To Many', 1, 1, 37, GETUTCDATE(), GETUTCDATE())
   END;


/* Create Entity Relationship: Sale Conveyances -> Sale Conveyance Members (One To Many via SaleConveyanceID) */
   IF NOT EXISTS (
      SELECT 1 FROM [${flyway:defaultSchema}].[EntityRelationship] WHERE [ID] = '291d08a2-3f55-49e4-a2e7-a5a46ef5284b'
   )
   BEGIN
      INSERT INTO [${flyway:defaultSchema}].[EntityRelationship] ([ID], [EntityID], [RelatedEntityID], [RelatedEntityJoinField], [Type], [BundleInAPI], [DisplayInForm], [Sequence], [__mj_CreatedAt], [__mj_UpdatedAt])
                    VALUES ('291d08a2-3f55-49e4-a2e7-a5a46ef5284b', 'ADA5A377-DCA6-440A-9C28-A7F354223568', '04E37D72-B573-4B81-B1E1-A501F1372851', 'SaleConveyanceID', 'One To Many', 1, 1, 1, GETUTCDATE(), GETUTCDATE())
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

/* Index for Foreign Keys for AppealRecommendationParcel */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Appeal Recommendation Parcels
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key AppealRecommendationID in table AppealRecommendationParcel
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_AppealRecommendationParcel_AppealRecommendationID' 
    AND object_id = OBJECT_ID('[indiana_tax].[AppealRecommendationParcel]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_AppealRecommendationParcel_AppealRecommendationID ON [indiana_tax].[AppealRecommendationParcel] ([AppealRecommendationID]);

-- Index for foreign key ParcelID in table AppealRecommendationParcel
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_AppealRecommendationParcel_ParcelID' 
    AND object_id = OBJECT_ID('[indiana_tax].[AppealRecommendationParcel]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_AppealRecommendationParcel_ParcelID ON [indiana_tax].[AppealRecommendationParcel] ([ParcelID]);

/* SQL text to update entity field related entity name field map for entity field ID 54542E53-7CBB-4DCD-B4A7-3DD98EAF6F47 */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='54542E53-7CBB-4DCD-B4A7-3DD98EAF6F47', @RelatedEntityNameFieldMap='Parcel';

/* Index for Foreign Keys for AppealRecommendationSignal */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Appeal Recommendation Signals
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key AppealRecommendationID in table AppealRecommendationSignal
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_AppealRecommendationSignal_AppealRecommendationID' 
    AND object_id = OBJECT_ID('[indiana_tax].[AppealRecommendationSignal]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_AppealRecommendationSignal_AppealRecommendationID ON [indiana_tax].[AppealRecommendationSignal] ([AppealRecommendationID]);

/* Index for Foreign Keys for AppealRecommendation */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Appeal Recommendations
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key ParcelID in table AppealRecommendation
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_AppealRecommendation_ParcelID' 
    AND object_id = OBJECT_ID('[indiana_tax].[AppealRecommendation]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_AppealRecommendation_ParcelID ON [indiana_tax].[AppealRecommendation] ([ParcelID]);

-- Index for foreign key PropertyID in table AppealRecommendation
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_AppealRecommendation_PropertyID' 
    AND object_id = OBJECT_ID('[indiana_tax].[AppealRecommendation]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_AppealRecommendation_PropertyID ON [indiana_tax].[AppealRecommendation] ([PropertyID]);

/* SQL text to update entity field related entity name field map for entity field ID 5DA3FB6B-C2BB-4631-B84A-86EB339008F4 */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='5DA3FB6B-C2BB-4631-B84A-86EB339008F4', @RelatedEntityNameFieldMap='Parcel';

/* Base View SQL for Appeal Recommendation Signals */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Appeal Recommendation Signals
-- Item: vwAppealRecommendationSignals
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Appeal Recommendation Signals
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  AppealRecommendationSignal
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwAppealRecommendationSignals]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwAppealRecommendationSignals];
GO

CREATE VIEW [indiana_tax].[vwAppealRecommendationSignals]
AS
SELECT
    a.*
FROM
    [indiana_tax].[AppealRecommendationSignal] AS a
GO
GRANT SELECT ON [indiana_tax].[vwAppealRecommendationSignals] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for Appeal Recommendation Signals */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Appeal Recommendation Signals
-- Item: Permissions for vwAppealRecommendationSignals
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwAppealRecommendationSignals] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for Appeal Recommendation Signals */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Appeal Recommendation Signals
-- Item: spCreateAppealRecommendationSignal
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR AppealRecommendationSignal
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateAppealRecommendationSignal]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateAppealRecommendationSignal];
GO

CREATE PROCEDURE [indiana_tax].[spCreateAppealRecommendationSignal]
    @ID uniqueidentifier = NULL,
    @AppealRecommendationID uniqueidentifier,
    @SignalCode nvarchar(4),
    @Supports nvarchar(10),
    @NAReason_Clear bit = 0,
    @NAReason nvarchar(60) = NULL,
    @IndicatedValue_Clear bit = 0,
    @IndicatedValue decimal(18, 2) = NULL,
    @IndicatedPerUnit_Clear bit = 0,
    @IndicatedPerUnit decimal(14, 2) = NULL,
    @UnitOfComparison_Clear bit = 0,
    @UnitOfComparison nvarchar(10) = NULL,
    @EvidenceCount_Clear bit = 0,
    @EvidenceCount int = NULL,
    @EvidenceNote_Clear bit = 0,
    @EvidenceNote nvarchar(400) = NULL,
    @RuleVersion nvarchar(40)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[AppealRecommendationSignal]
            (
                [ID],
                [AppealRecommendationID],
                [SignalCode],
                [Supports],
                [NAReason],
                [IndicatedValue],
                [IndicatedPerUnit],
                [UnitOfComparison],
                [EvidenceCount],
                [EvidenceNote],
                [RuleVersion]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @AppealRecommendationID,
                @SignalCode,
                @Supports,
                CASE WHEN @NAReason_Clear = 1 THEN NULL ELSE ISNULL(@NAReason, NULL) END,
                CASE WHEN @IndicatedValue_Clear = 1 THEN NULL ELSE ISNULL(@IndicatedValue, NULL) END,
                CASE WHEN @IndicatedPerUnit_Clear = 1 THEN NULL ELSE ISNULL(@IndicatedPerUnit, NULL) END,
                CASE WHEN @UnitOfComparison_Clear = 1 THEN NULL ELSE ISNULL(@UnitOfComparison, NULL) END,
                CASE WHEN @EvidenceCount_Clear = 1 THEN NULL ELSE ISNULL(@EvidenceCount, NULL) END,
                CASE WHEN @EvidenceNote_Clear = 1 THEN NULL ELSE ISNULL(@EvidenceNote, NULL) END,
                @RuleVersion
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[AppealRecommendationSignal]
            (
                [AppealRecommendationID],
                [SignalCode],
                [Supports],
                [NAReason],
                [IndicatedValue],
                [IndicatedPerUnit],
                [UnitOfComparison],
                [EvidenceCount],
                [EvidenceNote],
                [RuleVersion]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @AppealRecommendationID,
                @SignalCode,
                @Supports,
                CASE WHEN @NAReason_Clear = 1 THEN NULL ELSE ISNULL(@NAReason, NULL) END,
                CASE WHEN @IndicatedValue_Clear = 1 THEN NULL ELSE ISNULL(@IndicatedValue, NULL) END,
                CASE WHEN @IndicatedPerUnit_Clear = 1 THEN NULL ELSE ISNULL(@IndicatedPerUnit, NULL) END,
                CASE WHEN @UnitOfComparison_Clear = 1 THEN NULL ELSE ISNULL(@UnitOfComparison, NULL) END,
                CASE WHEN @EvidenceCount_Clear = 1 THEN NULL ELSE ISNULL(@EvidenceCount, NULL) END,
                CASE WHEN @EvidenceNote_Clear = 1 THEN NULL ELSE ISNULL(@EvidenceNote, NULL) END,
                @RuleVersion
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwAppealRecommendationSignals] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateAppealRecommendationSignal] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for Appeal Recommendation Signals */

GRANT EXECUTE ON [indiana_tax].[spCreateAppealRecommendationSignal] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for Appeal Recommendation Signals */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Appeal Recommendation Signals
-- Item: spUpdateAppealRecommendationSignal
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR AppealRecommendationSignal
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateAppealRecommendationSignal]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateAppealRecommendationSignal];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateAppealRecommendationSignal]
    @ID uniqueidentifier,
    @AppealRecommendationID uniqueidentifier = NULL,
    @SignalCode nvarchar(4) = NULL,
    @Supports nvarchar(10) = NULL,
    @NAReason_Clear bit = 0,
    @NAReason nvarchar(60) = NULL,
    @IndicatedValue_Clear bit = 0,
    @IndicatedValue decimal(18, 2) = NULL,
    @IndicatedPerUnit_Clear bit = 0,
    @IndicatedPerUnit decimal(14, 2) = NULL,
    @UnitOfComparison_Clear bit = 0,
    @UnitOfComparison nvarchar(10) = NULL,
    @EvidenceCount_Clear bit = 0,
    @EvidenceCount int = NULL,
    @EvidenceNote_Clear bit = 0,
    @EvidenceNote nvarchar(400) = NULL,
    @RuleVersion nvarchar(40) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[AppealRecommendationSignal]
    SET
        [AppealRecommendationID] = ISNULL(@AppealRecommendationID, [AppealRecommendationID]),
        [SignalCode] = ISNULL(@SignalCode, [SignalCode]),
        [Supports] = ISNULL(@Supports, [Supports]),
        [NAReason] = CASE WHEN @NAReason_Clear = 1 THEN NULL ELSE ISNULL(@NAReason, [NAReason]) END,
        [IndicatedValue] = CASE WHEN @IndicatedValue_Clear = 1 THEN NULL ELSE ISNULL(@IndicatedValue, [IndicatedValue]) END,
        [IndicatedPerUnit] = CASE WHEN @IndicatedPerUnit_Clear = 1 THEN NULL ELSE ISNULL(@IndicatedPerUnit, [IndicatedPerUnit]) END,
        [UnitOfComparison] = CASE WHEN @UnitOfComparison_Clear = 1 THEN NULL ELSE ISNULL(@UnitOfComparison, [UnitOfComparison]) END,
        [EvidenceCount] = CASE WHEN @EvidenceCount_Clear = 1 THEN NULL ELSE ISNULL(@EvidenceCount, [EvidenceCount]) END,
        [EvidenceNote] = CASE WHEN @EvidenceNote_Clear = 1 THEN NULL ELSE ISNULL(@EvidenceNote, [EvidenceNote]) END,
        [RuleVersion] = ISNULL(@RuleVersion, [RuleVersion])
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwAppealRecommendationSignals] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwAppealRecommendationSignals]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateAppealRecommendationSignal] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the AppealRecommendationSignal table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateAppealRecommendationSignal]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateAppealRecommendationSignal];
GO
CREATE TRIGGER [indiana_tax].trgUpdateAppealRecommendationSignal
ON [indiana_tax].[AppealRecommendationSignal]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[AppealRecommendationSignal]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[AppealRecommendationSignal] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for Appeal Recommendation Signals */

GRANT EXECUTE ON [indiana_tax].[spUpdateAppealRecommendationSignal] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for Appeal Recommendation Signals */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Appeal Recommendation Signals
-- Item: spDeleteAppealRecommendationSignal
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR AppealRecommendationSignal
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteAppealRecommendationSignal]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteAppealRecommendationSignal];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteAppealRecommendationSignal]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[AppealRecommendationSignal]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteAppealRecommendationSignal] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for Appeal Recommendation Signals */

GRANT EXECUTE ON [indiana_tax].[spDeleteAppealRecommendationSignal] TO [cdp_Developer], [cdp_Integration];

/* Base View SQL for Appeal Recommendation Parcels */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Appeal Recommendation Parcels
-- Item: vwAppealRecommendationParcels
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Appeal Recommendation Parcels
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  AppealRecommendationParcel
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwAppealRecommendationParcels]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwAppealRecommendationParcels];
GO

CREATE VIEW [indiana_tax].[vwAppealRecommendationParcels]
AS
SELECT
    a.*,
    indianataxParcel_ParcelID.[ParcelNumber] AS [Parcel]
FROM
    [indiana_tax].[AppealRecommendationParcel] AS a
INNER JOIN
    [indiana_tax].[Parcel] AS indianataxParcel_ParcelID
  ON
    [a].[ParcelID] = indianataxParcel_ParcelID.[ID]
GO
GRANT SELECT ON [indiana_tax].[vwAppealRecommendationParcels] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for Appeal Recommendation Parcels */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Appeal Recommendation Parcels
-- Item: Permissions for vwAppealRecommendationParcels
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwAppealRecommendationParcels] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for Appeal Recommendation Parcels */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Appeal Recommendation Parcels
-- Item: spCreateAppealRecommendationParcel
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR AppealRecommendationParcel
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateAppealRecommendationParcel]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateAppealRecommendationParcel];
GO

CREATE PROCEDURE [indiana_tax].[spCreateAppealRecommendationParcel]
    @ID uniqueidentifier = NULL,
    @AppealRecommendationID uniqueidentifier,
    @ParcelID uniqueidentifier,
    @MemberCurrentAV_Clear bit = 0,
    @MemberCurrentAV decimal(18, 2) = NULL,
    @AllocationShare decimal(9, 6),
    @AllocatedFloor_Clear bit = 0,
    @AllocatedFloor decimal(18, 2) = NULL,
    @AllocatedAsk_Clear bit = 0,
    @AllocatedAsk decimal(18, 2) = NULL,
    @AllocatedSavingsAtAsk_Clear bit = 0,
    @AllocatedSavingsAtAsk decimal(14, 2) = NULL,
    @AllocatedSavingsAtFloor_Clear bit = 0,
    @AllocatedSavingsAtFloor decimal(14, 2) = NULL,
    @AllocationOverride bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[AppealRecommendationParcel]
            (
                [ID],
                [AppealRecommendationID],
                [ParcelID],
                [MemberCurrentAV],
                [AllocationShare],
                [AllocatedFloor],
                [AllocatedAsk],
                [AllocatedSavingsAtAsk],
                [AllocatedSavingsAtFloor],
                [AllocationOverride]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @AppealRecommendationID,
                @ParcelID,
                CASE WHEN @MemberCurrentAV_Clear = 1 THEN NULL ELSE ISNULL(@MemberCurrentAV, NULL) END,
                @AllocationShare,
                CASE WHEN @AllocatedFloor_Clear = 1 THEN NULL ELSE ISNULL(@AllocatedFloor, NULL) END,
                CASE WHEN @AllocatedAsk_Clear = 1 THEN NULL ELSE ISNULL(@AllocatedAsk, NULL) END,
                CASE WHEN @AllocatedSavingsAtAsk_Clear = 1 THEN NULL ELSE ISNULL(@AllocatedSavingsAtAsk, NULL) END,
                CASE WHEN @AllocatedSavingsAtFloor_Clear = 1 THEN NULL ELSE ISNULL(@AllocatedSavingsAtFloor, NULL) END,
                ISNULL(@AllocationOverride, 0)
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[AppealRecommendationParcel]
            (
                [AppealRecommendationID],
                [ParcelID],
                [MemberCurrentAV],
                [AllocationShare],
                [AllocatedFloor],
                [AllocatedAsk],
                [AllocatedSavingsAtAsk],
                [AllocatedSavingsAtFloor],
                [AllocationOverride]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @AppealRecommendationID,
                @ParcelID,
                CASE WHEN @MemberCurrentAV_Clear = 1 THEN NULL ELSE ISNULL(@MemberCurrentAV, NULL) END,
                @AllocationShare,
                CASE WHEN @AllocatedFloor_Clear = 1 THEN NULL ELSE ISNULL(@AllocatedFloor, NULL) END,
                CASE WHEN @AllocatedAsk_Clear = 1 THEN NULL ELSE ISNULL(@AllocatedAsk, NULL) END,
                CASE WHEN @AllocatedSavingsAtAsk_Clear = 1 THEN NULL ELSE ISNULL(@AllocatedSavingsAtAsk, NULL) END,
                CASE WHEN @AllocatedSavingsAtFloor_Clear = 1 THEN NULL ELSE ISNULL(@AllocatedSavingsAtFloor, NULL) END,
                ISNULL(@AllocationOverride, 0)
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwAppealRecommendationParcels] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateAppealRecommendationParcel] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for Appeal Recommendation Parcels */

GRANT EXECUTE ON [indiana_tax].[spCreateAppealRecommendationParcel] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for Appeal Recommendation Parcels */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Appeal Recommendation Parcels
-- Item: spUpdateAppealRecommendationParcel
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR AppealRecommendationParcel
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateAppealRecommendationParcel]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateAppealRecommendationParcel];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateAppealRecommendationParcel]
    @ID uniqueidentifier,
    @AppealRecommendationID uniqueidentifier = NULL,
    @ParcelID uniqueidentifier = NULL,
    @MemberCurrentAV_Clear bit = 0,
    @MemberCurrentAV decimal(18, 2) = NULL,
    @AllocationShare decimal(9, 6) = NULL,
    @AllocatedFloor_Clear bit = 0,
    @AllocatedFloor decimal(18, 2) = NULL,
    @AllocatedAsk_Clear bit = 0,
    @AllocatedAsk decimal(18, 2) = NULL,
    @AllocatedSavingsAtAsk_Clear bit = 0,
    @AllocatedSavingsAtAsk decimal(14, 2) = NULL,
    @AllocatedSavingsAtFloor_Clear bit = 0,
    @AllocatedSavingsAtFloor decimal(14, 2) = NULL,
    @AllocationOverride bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[AppealRecommendationParcel]
    SET
        [AppealRecommendationID] = ISNULL(@AppealRecommendationID, [AppealRecommendationID]),
        [ParcelID] = ISNULL(@ParcelID, [ParcelID]),
        [MemberCurrentAV] = CASE WHEN @MemberCurrentAV_Clear = 1 THEN NULL ELSE ISNULL(@MemberCurrentAV, [MemberCurrentAV]) END,
        [AllocationShare] = ISNULL(@AllocationShare, [AllocationShare]),
        [AllocatedFloor] = CASE WHEN @AllocatedFloor_Clear = 1 THEN NULL ELSE ISNULL(@AllocatedFloor, [AllocatedFloor]) END,
        [AllocatedAsk] = CASE WHEN @AllocatedAsk_Clear = 1 THEN NULL ELSE ISNULL(@AllocatedAsk, [AllocatedAsk]) END,
        [AllocatedSavingsAtAsk] = CASE WHEN @AllocatedSavingsAtAsk_Clear = 1 THEN NULL ELSE ISNULL(@AllocatedSavingsAtAsk, [AllocatedSavingsAtAsk]) END,
        [AllocatedSavingsAtFloor] = CASE WHEN @AllocatedSavingsAtFloor_Clear = 1 THEN NULL ELSE ISNULL(@AllocatedSavingsAtFloor, [AllocatedSavingsAtFloor]) END,
        [AllocationOverride] = ISNULL(@AllocationOverride, [AllocationOverride])
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwAppealRecommendationParcels] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwAppealRecommendationParcels]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateAppealRecommendationParcel] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the AppealRecommendationParcel table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateAppealRecommendationParcel]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateAppealRecommendationParcel];
GO
CREATE TRIGGER [indiana_tax].trgUpdateAppealRecommendationParcel
ON [indiana_tax].[AppealRecommendationParcel]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[AppealRecommendationParcel]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[AppealRecommendationParcel] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for Appeal Recommendation Parcels */

GRANT EXECUTE ON [indiana_tax].[spUpdateAppealRecommendationParcel] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for Appeal Recommendation Parcels */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Appeal Recommendation Parcels
-- Item: spDeleteAppealRecommendationParcel
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR AppealRecommendationParcel
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteAppealRecommendationParcel]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteAppealRecommendationParcel];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteAppealRecommendationParcel]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[AppealRecommendationParcel]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteAppealRecommendationParcel] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for Appeal Recommendation Parcels */

GRANT EXECUTE ON [indiana_tax].[spDeleteAppealRecommendationParcel] TO [cdp_Developer], [cdp_Integration];

/* SQL text to update entity field related entity name field map for entity field ID 7B7BD624-2819-4C0D-ACDC-D0D9FAD5A244 */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='7B7BD624-2819-4C0D-ACDC-D0D9FAD5A244', @RelatedEntityNameFieldMap='Property';

/* Base View SQL for Appeal Recommendations */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Appeal Recommendations
-- Item: vwAppealRecommendations
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Appeal Recommendations
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  AppealRecommendation
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwAppealRecommendations]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwAppealRecommendations];
GO

CREATE VIEW [indiana_tax].[vwAppealRecommendations]
AS
SELECT
    a.*,
    indianataxParcel_ParcelID.[ParcelNumber] AS [Parcel],
    indianataxProperty_PropertyID.[Name] AS [Property]
FROM
    [indiana_tax].[AppealRecommendation] AS a
LEFT OUTER JOIN
    [indiana_tax].[Parcel] AS indianataxParcel_ParcelID
  ON
    [a].[ParcelID] = indianataxParcel_ParcelID.[ID]
LEFT OUTER JOIN
    [indiana_tax].[Property] AS indianataxProperty_PropertyID
  ON
    [a].[PropertyID] = indianataxProperty_PropertyID.[ID]
GO
GRANT SELECT ON [indiana_tax].[vwAppealRecommendations] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for Appeal Recommendations */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Appeal Recommendations
-- Item: Permissions for vwAppealRecommendations
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwAppealRecommendations] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for Appeal Recommendations */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Appeal Recommendations
-- Item: spCreateAppealRecommendation
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR AppealRecommendation
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateAppealRecommendation]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateAppealRecommendation];
GO

CREATE PROCEDURE [indiana_tax].[spCreateAppealRecommendation]
    @ID uniqueidentifier = NULL,
    @SubjectKind nvarchar(10),
    @ParcelID_Clear bit = 0,
    @ParcelID uniqueidentifier = NULL,
    @PropertyID_Clear bit = 0,
    @PropertyID uniqueidentifier = NULL,
    @AssessmentYear int,
    @MethodologyVersion nvarchar(40),
    @IsCurrent bit = NULL,
    @CurrentAV_Clear bit = 0,
    @CurrentAV decimal(18, 2) = NULL,
    @PriorAVAsDetermined_Clear bit = 0,
    @PriorAVAsDetermined decimal(18, 2) = NULL,
    @UnitOfComparison_Clear bit = 0,
    @UnitOfComparison nvarchar(10) = NULL,
    @Denominator_Clear bit = 0,
    @Denominator decimal(14, 2) = NULL,
    @DenominatorSource_Clear bit = 0,
    @DenominatorSource nvarchar(20) = NULL,
    @DenominatorIsFallback bit = NULL,
    @ValueSignalCount tinyint,
    @IncreaseFlag bit,
    @FloorSupport bit,
    @PeerOutOfLine bit,
    @OwnSaleContrary bit,
    @Verdict nvarchar(16),
    @NotAvailableReason_Clear bit = 0,
    @NotAvailableReason nvarchar(60) = NULL,
    @ConfidenceTier_Clear bit = 0,
    @ConfidenceTier nvarchar(8) = NULL,
    @FloorValue_Clear bit = 0,
    @FloorValue decimal(18, 2) = NULL,
    @AskValue_Clear bit = 0,
    @AskValue decimal(18, 2) = NULL,
    @AskPolicy nvarchar(16),
    @AskBasis_Clear bit = 0,
    @AskBasis nvarchar(20) = NULL,
    @EstSavingsAtAsk_Clear bit = 0,
    @EstSavingsAtAsk decimal(14, 2) = NULL,
    @EstSavingsAtFloor_Clear bit = 0,
    @EstSavingsAtFloor decimal(14, 2) = NULL,
    @EffectiveTaxRate_Clear bit = 0,
    @EffectiveTaxRate decimal(9, 6) = NULL,
    @GroupingStatus nvarchar(20),
    @GroupingVersion_Clear bit = 0,
    @GroupingVersion datetime2 = NULL,
    @AlreadyAppealed bit,
    @ExistingRep_Clear bit = 0,
    @ExistingRep nvarchar(200) = NULL,
    @Exempt bit,
    @BelowSavingsFloor bit,
    @RunStamp datetime2,
    @GeneratedAt datetime2
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[AppealRecommendation]
            (
                [ID],
                [SubjectKind],
                [ParcelID],
                [PropertyID],
                [AssessmentYear],
                [MethodologyVersion],
                [IsCurrent],
                [CurrentAV],
                [PriorAVAsDetermined],
                [UnitOfComparison],
                [Denominator],
                [DenominatorSource],
                [DenominatorIsFallback],
                [ValueSignalCount],
                [IncreaseFlag],
                [FloorSupport],
                [PeerOutOfLine],
                [OwnSaleContrary],
                [Verdict],
                [NotAvailableReason],
                [ConfidenceTier],
                [FloorValue],
                [AskValue],
                [AskPolicy],
                [AskBasis],
                [EstSavingsAtAsk],
                [EstSavingsAtFloor],
                [EffectiveTaxRate],
                [GroupingStatus],
                [GroupingVersion],
                [AlreadyAppealed],
                [ExistingRep],
                [Exempt],
                [BelowSavingsFloor],
                [RunStamp],
                [GeneratedAt]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @SubjectKind,
                CASE WHEN @ParcelID_Clear = 1 THEN NULL ELSE ISNULL(@ParcelID, NULL) END,
                CASE WHEN @PropertyID_Clear = 1 THEN NULL ELSE ISNULL(@PropertyID, NULL) END,
                @AssessmentYear,
                @MethodologyVersion,
                ISNULL(@IsCurrent, 1),
                CASE WHEN @CurrentAV_Clear = 1 THEN NULL ELSE ISNULL(@CurrentAV, NULL) END,
                CASE WHEN @PriorAVAsDetermined_Clear = 1 THEN NULL ELSE ISNULL(@PriorAVAsDetermined, NULL) END,
                CASE WHEN @UnitOfComparison_Clear = 1 THEN NULL ELSE ISNULL(@UnitOfComparison, NULL) END,
                CASE WHEN @Denominator_Clear = 1 THEN NULL ELSE ISNULL(@Denominator, NULL) END,
                CASE WHEN @DenominatorSource_Clear = 1 THEN NULL ELSE ISNULL(@DenominatorSource, NULL) END,
                ISNULL(@DenominatorIsFallback, 0),
                @ValueSignalCount,
                @IncreaseFlag,
                @FloorSupport,
                @PeerOutOfLine,
                @OwnSaleContrary,
                @Verdict,
                CASE WHEN @NotAvailableReason_Clear = 1 THEN NULL ELSE ISNULL(@NotAvailableReason, NULL) END,
                CASE WHEN @ConfidenceTier_Clear = 1 THEN NULL ELSE ISNULL(@ConfidenceTier, NULL) END,
                CASE WHEN @FloorValue_Clear = 1 THEN NULL ELSE ISNULL(@FloorValue, NULL) END,
                CASE WHEN @AskValue_Clear = 1 THEN NULL ELSE ISNULL(@AskValue, NULL) END,
                @AskPolicy,
                CASE WHEN @AskBasis_Clear = 1 THEN NULL ELSE ISNULL(@AskBasis, NULL) END,
                CASE WHEN @EstSavingsAtAsk_Clear = 1 THEN NULL ELSE ISNULL(@EstSavingsAtAsk, NULL) END,
                CASE WHEN @EstSavingsAtFloor_Clear = 1 THEN NULL ELSE ISNULL(@EstSavingsAtFloor, NULL) END,
                CASE WHEN @EffectiveTaxRate_Clear = 1 THEN NULL ELSE ISNULL(@EffectiveTaxRate, NULL) END,
                @GroupingStatus,
                CASE WHEN @GroupingVersion_Clear = 1 THEN NULL ELSE ISNULL(@GroupingVersion, NULL) END,
                @AlreadyAppealed,
                CASE WHEN @ExistingRep_Clear = 1 THEN NULL ELSE ISNULL(@ExistingRep, NULL) END,
                @Exempt,
                @BelowSavingsFloor,
                @RunStamp,
                @GeneratedAt
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[AppealRecommendation]
            (
                [SubjectKind],
                [ParcelID],
                [PropertyID],
                [AssessmentYear],
                [MethodologyVersion],
                [IsCurrent],
                [CurrentAV],
                [PriorAVAsDetermined],
                [UnitOfComparison],
                [Denominator],
                [DenominatorSource],
                [DenominatorIsFallback],
                [ValueSignalCount],
                [IncreaseFlag],
                [FloorSupport],
                [PeerOutOfLine],
                [OwnSaleContrary],
                [Verdict],
                [NotAvailableReason],
                [ConfidenceTier],
                [FloorValue],
                [AskValue],
                [AskPolicy],
                [AskBasis],
                [EstSavingsAtAsk],
                [EstSavingsAtFloor],
                [EffectiveTaxRate],
                [GroupingStatus],
                [GroupingVersion],
                [AlreadyAppealed],
                [ExistingRep],
                [Exempt],
                [BelowSavingsFloor],
                [RunStamp],
                [GeneratedAt]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @SubjectKind,
                CASE WHEN @ParcelID_Clear = 1 THEN NULL ELSE ISNULL(@ParcelID, NULL) END,
                CASE WHEN @PropertyID_Clear = 1 THEN NULL ELSE ISNULL(@PropertyID, NULL) END,
                @AssessmentYear,
                @MethodologyVersion,
                ISNULL(@IsCurrent, 1),
                CASE WHEN @CurrentAV_Clear = 1 THEN NULL ELSE ISNULL(@CurrentAV, NULL) END,
                CASE WHEN @PriorAVAsDetermined_Clear = 1 THEN NULL ELSE ISNULL(@PriorAVAsDetermined, NULL) END,
                CASE WHEN @UnitOfComparison_Clear = 1 THEN NULL ELSE ISNULL(@UnitOfComparison, NULL) END,
                CASE WHEN @Denominator_Clear = 1 THEN NULL ELSE ISNULL(@Denominator, NULL) END,
                CASE WHEN @DenominatorSource_Clear = 1 THEN NULL ELSE ISNULL(@DenominatorSource, NULL) END,
                ISNULL(@DenominatorIsFallback, 0),
                @ValueSignalCount,
                @IncreaseFlag,
                @FloorSupport,
                @PeerOutOfLine,
                @OwnSaleContrary,
                @Verdict,
                CASE WHEN @NotAvailableReason_Clear = 1 THEN NULL ELSE ISNULL(@NotAvailableReason, NULL) END,
                CASE WHEN @ConfidenceTier_Clear = 1 THEN NULL ELSE ISNULL(@ConfidenceTier, NULL) END,
                CASE WHEN @FloorValue_Clear = 1 THEN NULL ELSE ISNULL(@FloorValue, NULL) END,
                CASE WHEN @AskValue_Clear = 1 THEN NULL ELSE ISNULL(@AskValue, NULL) END,
                @AskPolicy,
                CASE WHEN @AskBasis_Clear = 1 THEN NULL ELSE ISNULL(@AskBasis, NULL) END,
                CASE WHEN @EstSavingsAtAsk_Clear = 1 THEN NULL ELSE ISNULL(@EstSavingsAtAsk, NULL) END,
                CASE WHEN @EstSavingsAtFloor_Clear = 1 THEN NULL ELSE ISNULL(@EstSavingsAtFloor, NULL) END,
                CASE WHEN @EffectiveTaxRate_Clear = 1 THEN NULL ELSE ISNULL(@EffectiveTaxRate, NULL) END,
                @GroupingStatus,
                CASE WHEN @GroupingVersion_Clear = 1 THEN NULL ELSE ISNULL(@GroupingVersion, NULL) END,
                @AlreadyAppealed,
                CASE WHEN @ExistingRep_Clear = 1 THEN NULL ELSE ISNULL(@ExistingRep, NULL) END,
                @Exempt,
                @BelowSavingsFloor,
                @RunStamp,
                @GeneratedAt
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwAppealRecommendations] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateAppealRecommendation] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for Appeal Recommendations */

GRANT EXECUTE ON [indiana_tax].[spCreateAppealRecommendation] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for Appeal Recommendations */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Appeal Recommendations
-- Item: spUpdateAppealRecommendation
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR AppealRecommendation
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateAppealRecommendation]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateAppealRecommendation];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateAppealRecommendation]
    @ID uniqueidentifier,
    @SubjectKind nvarchar(10) = NULL,
    @ParcelID_Clear bit = 0,
    @ParcelID uniqueidentifier = NULL,
    @PropertyID_Clear bit = 0,
    @PropertyID uniqueidentifier = NULL,
    @AssessmentYear int = NULL,
    @MethodologyVersion nvarchar(40) = NULL,
    @IsCurrent bit = NULL,
    @CurrentAV_Clear bit = 0,
    @CurrentAV decimal(18, 2) = NULL,
    @PriorAVAsDetermined_Clear bit = 0,
    @PriorAVAsDetermined decimal(18, 2) = NULL,
    @UnitOfComparison_Clear bit = 0,
    @UnitOfComparison nvarchar(10) = NULL,
    @Denominator_Clear bit = 0,
    @Denominator decimal(14, 2) = NULL,
    @DenominatorSource_Clear bit = 0,
    @DenominatorSource nvarchar(20) = NULL,
    @DenominatorIsFallback bit = NULL,
    @ValueSignalCount tinyint = NULL,
    @IncreaseFlag bit = NULL,
    @FloorSupport bit = NULL,
    @PeerOutOfLine bit = NULL,
    @OwnSaleContrary bit = NULL,
    @Verdict nvarchar(16) = NULL,
    @NotAvailableReason_Clear bit = 0,
    @NotAvailableReason nvarchar(60) = NULL,
    @ConfidenceTier_Clear bit = 0,
    @ConfidenceTier nvarchar(8) = NULL,
    @FloorValue_Clear bit = 0,
    @FloorValue decimal(18, 2) = NULL,
    @AskValue_Clear bit = 0,
    @AskValue decimal(18, 2) = NULL,
    @AskPolicy nvarchar(16) = NULL,
    @AskBasis_Clear bit = 0,
    @AskBasis nvarchar(20) = NULL,
    @EstSavingsAtAsk_Clear bit = 0,
    @EstSavingsAtAsk decimal(14, 2) = NULL,
    @EstSavingsAtFloor_Clear bit = 0,
    @EstSavingsAtFloor decimal(14, 2) = NULL,
    @EffectiveTaxRate_Clear bit = 0,
    @EffectiveTaxRate decimal(9, 6) = NULL,
    @GroupingStatus nvarchar(20) = NULL,
    @GroupingVersion_Clear bit = 0,
    @GroupingVersion datetime2 = NULL,
    @AlreadyAppealed bit = NULL,
    @ExistingRep_Clear bit = 0,
    @ExistingRep nvarchar(200) = NULL,
    @Exempt bit = NULL,
    @BelowSavingsFloor bit = NULL,
    @RunStamp datetime2 = NULL,
    @GeneratedAt datetime2 = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[AppealRecommendation]
    SET
        [SubjectKind] = ISNULL(@SubjectKind, [SubjectKind]),
        [ParcelID] = CASE WHEN @ParcelID_Clear = 1 THEN NULL ELSE ISNULL(@ParcelID, [ParcelID]) END,
        [PropertyID] = CASE WHEN @PropertyID_Clear = 1 THEN NULL ELSE ISNULL(@PropertyID, [PropertyID]) END,
        [AssessmentYear] = ISNULL(@AssessmentYear, [AssessmentYear]),
        [MethodologyVersion] = ISNULL(@MethodologyVersion, [MethodologyVersion]),
        [IsCurrent] = ISNULL(@IsCurrent, [IsCurrent]),
        [CurrentAV] = CASE WHEN @CurrentAV_Clear = 1 THEN NULL ELSE ISNULL(@CurrentAV, [CurrentAV]) END,
        [PriorAVAsDetermined] = CASE WHEN @PriorAVAsDetermined_Clear = 1 THEN NULL ELSE ISNULL(@PriorAVAsDetermined, [PriorAVAsDetermined]) END,
        [UnitOfComparison] = CASE WHEN @UnitOfComparison_Clear = 1 THEN NULL ELSE ISNULL(@UnitOfComparison, [UnitOfComparison]) END,
        [Denominator] = CASE WHEN @Denominator_Clear = 1 THEN NULL ELSE ISNULL(@Denominator, [Denominator]) END,
        [DenominatorSource] = CASE WHEN @DenominatorSource_Clear = 1 THEN NULL ELSE ISNULL(@DenominatorSource, [DenominatorSource]) END,
        [DenominatorIsFallback] = ISNULL(@DenominatorIsFallback, [DenominatorIsFallback]),
        [ValueSignalCount] = ISNULL(@ValueSignalCount, [ValueSignalCount]),
        [IncreaseFlag] = ISNULL(@IncreaseFlag, [IncreaseFlag]),
        [FloorSupport] = ISNULL(@FloorSupport, [FloorSupport]),
        [PeerOutOfLine] = ISNULL(@PeerOutOfLine, [PeerOutOfLine]),
        [OwnSaleContrary] = ISNULL(@OwnSaleContrary, [OwnSaleContrary]),
        [Verdict] = ISNULL(@Verdict, [Verdict]),
        [NotAvailableReason] = CASE WHEN @NotAvailableReason_Clear = 1 THEN NULL ELSE ISNULL(@NotAvailableReason, [NotAvailableReason]) END,
        [ConfidenceTier] = CASE WHEN @ConfidenceTier_Clear = 1 THEN NULL ELSE ISNULL(@ConfidenceTier, [ConfidenceTier]) END,
        [FloorValue] = CASE WHEN @FloorValue_Clear = 1 THEN NULL ELSE ISNULL(@FloorValue, [FloorValue]) END,
        [AskValue] = CASE WHEN @AskValue_Clear = 1 THEN NULL ELSE ISNULL(@AskValue, [AskValue]) END,
        [AskPolicy] = ISNULL(@AskPolicy, [AskPolicy]),
        [AskBasis] = CASE WHEN @AskBasis_Clear = 1 THEN NULL ELSE ISNULL(@AskBasis, [AskBasis]) END,
        [EstSavingsAtAsk] = CASE WHEN @EstSavingsAtAsk_Clear = 1 THEN NULL ELSE ISNULL(@EstSavingsAtAsk, [EstSavingsAtAsk]) END,
        [EstSavingsAtFloor] = CASE WHEN @EstSavingsAtFloor_Clear = 1 THEN NULL ELSE ISNULL(@EstSavingsAtFloor, [EstSavingsAtFloor]) END,
        [EffectiveTaxRate] = CASE WHEN @EffectiveTaxRate_Clear = 1 THEN NULL ELSE ISNULL(@EffectiveTaxRate, [EffectiveTaxRate]) END,
        [GroupingStatus] = ISNULL(@GroupingStatus, [GroupingStatus]),
        [GroupingVersion] = CASE WHEN @GroupingVersion_Clear = 1 THEN NULL ELSE ISNULL(@GroupingVersion, [GroupingVersion]) END,
        [AlreadyAppealed] = ISNULL(@AlreadyAppealed, [AlreadyAppealed]),
        [ExistingRep] = CASE WHEN @ExistingRep_Clear = 1 THEN NULL ELSE ISNULL(@ExistingRep, [ExistingRep]) END,
        [Exempt] = ISNULL(@Exempt, [Exempt]),
        [BelowSavingsFloor] = ISNULL(@BelowSavingsFloor, [BelowSavingsFloor]),
        [RunStamp] = ISNULL(@RunStamp, [RunStamp]),
        [GeneratedAt] = ISNULL(@GeneratedAt, [GeneratedAt])
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwAppealRecommendations] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwAppealRecommendations]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateAppealRecommendation] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the AppealRecommendation table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateAppealRecommendation]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateAppealRecommendation];
GO
CREATE TRIGGER [indiana_tax].trgUpdateAppealRecommendation
ON [indiana_tax].[AppealRecommendation]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[AppealRecommendation]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[AppealRecommendation] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for Appeal Recommendations */

GRANT EXECUTE ON [indiana_tax].[spUpdateAppealRecommendation] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for Appeal Recommendations */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Appeal Recommendations
-- Item: spDeleteAppealRecommendation
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR AppealRecommendation
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteAppealRecommendation]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteAppealRecommendation];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteAppealRecommendation]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[AppealRecommendation]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteAppealRecommendation] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for Appeal Recommendations */

GRANT EXECUTE ON [indiana_tax].[spDeleteAppealRecommendation] TO [cdp_Developer], [cdp_Integration];

/* Index for Foreign Keys for Property */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Properties
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key CountyID in table Property
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Property_CountyID' 
    AND object_id = OBJECT_ID('[indiana_tax].[Property]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Property_CountyID ON [indiana_tax].[Property] ([CountyID]);

-- Index for foreign key ConfirmedByUserID in table Property
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_Property_ConfirmedByUserID' 
    AND object_id = OBJECT_ID('[indiana_tax].[Property]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_Property_ConfirmedByUserID ON [indiana_tax].[Property] ([ConfirmedByUserID]);

/* Index for Foreign Keys for PropertySuggestionEvidence */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Property Suggestion Evidences
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key PropertyID in table PropertySuggestionEvidence
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_PropertySuggestionEvidence_PropertyID' 
    AND object_id = OBJECT_ID('[indiana_tax].[PropertySuggestionEvidence]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_PropertySuggestionEvidence_PropertyID ON [indiana_tax].[PropertySuggestionEvidence] ([PropertyID]);

/* SQL text to update entity field related entity name field map for entity field ID C2BC649B-187C-4E2E-BE4E-D825F67F042E */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='C2BC649B-187C-4E2E-BE4E-D825F67F042E', @RelatedEntityNameFieldMap='Property';

/* Base View SQL for Properties */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Properties
-- Item: vwProperties
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Properties
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  Property
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwProperties]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwProperties];
GO

CREATE VIEW [indiana_tax].[vwProperties]
AS
SELECT
    p.*,
    indianataxCounty_CountyID.[Name] AS [County],
    MJUser_ConfirmedByUserID.[Name] AS [ConfirmedByUser]
FROM
    [indiana_tax].[Property] AS p
INNER JOIN
    [indiana_tax].[County] AS indianataxCounty_CountyID
  ON
    [p].[CountyID] = indianataxCounty_CountyID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[User] AS MJUser_ConfirmedByUserID
  ON
    [p].[ConfirmedByUserID] = MJUser_ConfirmedByUserID.[ID]
GO
GRANT SELECT ON [indiana_tax].[vwProperties] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for Properties */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Properties
-- Item: Permissions for vwProperties
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwProperties] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for Properties */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Properties
-- Item: spCreateProperty
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR Property
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateProperty]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateProperty];
GO

CREATE PROCEDURE [indiana_tax].[spCreateProperty]
    @ID uniqueidentifier = NULL,
    @Name nvarchar(200),
    @CountyID uniqueidentifier,
    @PropertyType nvarchar(20) = NULL,
    @UnitCount_Clear bit = 0,
    @UnitCount int = NULL,
    @UnitCountSource_Clear bit = 0,
    @UnitCountSource nvarchar(20) = NULL,
    @GroupingStatus nvarchar(20) = NULL,
    @ConfirmedByUserID_Clear bit = 0,
    @ConfirmedByUserID uniqueidentifier = NULL,
    @ConfirmedAt_Clear bit = 0,
    @ConfirmedAt datetime2 = NULL,
    @Notes_Clear bit = 0,
    @Notes nvarchar(MAX) = NULL,
    @GroupingVersion_Clear bit = 0,
    @GroupingVersion datetime2 = NULL,
    @SplitAt_Clear bit = 0,
    @SplitAt datetime2 = NULL,
    @UnitCountSourceURL_Clear bit = 0,
    @UnitCountSourceURL nvarchar(500) = NULL,
    @UnitCountRetrievedAt_Clear bit = 0,
    @UnitCountRetrievedAt datetime2 = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[Property]
            (
                [ID],
                [Name],
                [CountyID],
                [PropertyType],
                [UnitCount],
                [UnitCountSource],
                [GroupingStatus],
                [ConfirmedByUserID],
                [ConfirmedAt],
                [Notes],
                [GroupingVersion],
                [SplitAt],
                [UnitCountSourceURL],
                [UnitCountRetrievedAt]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @Name,
                @CountyID,
                ISNULL(@PropertyType, 'Other'),
                CASE WHEN @UnitCount_Clear = 1 THEN NULL ELSE ISNULL(@UnitCount, NULL) END,
                CASE WHEN @UnitCountSource_Clear = 1 THEN NULL ELSE ISNULL(@UnitCountSource, NULL) END,
                ISNULL(@GroupingStatus, 'Suggested'),
                CASE WHEN @ConfirmedByUserID_Clear = 1 THEN NULL ELSE ISNULL(@ConfirmedByUserID, NULL) END,
                CASE WHEN @ConfirmedAt_Clear = 1 THEN NULL ELSE ISNULL(@ConfirmedAt, NULL) END,
                CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, NULL) END,
                CASE WHEN @GroupingVersion_Clear = 1 THEN NULL ELSE ISNULL(@GroupingVersion, NULL) END,
                CASE WHEN @SplitAt_Clear = 1 THEN NULL ELSE ISNULL(@SplitAt, NULL) END,
                CASE WHEN @UnitCountSourceURL_Clear = 1 THEN NULL ELSE ISNULL(@UnitCountSourceURL, NULL) END,
                CASE WHEN @UnitCountRetrievedAt_Clear = 1 THEN NULL ELSE ISNULL(@UnitCountRetrievedAt, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[Property]
            (
                [Name],
                [CountyID],
                [PropertyType],
                [UnitCount],
                [UnitCountSource],
                [GroupingStatus],
                [ConfirmedByUserID],
                [ConfirmedAt],
                [Notes],
                [GroupingVersion],
                [SplitAt],
                [UnitCountSourceURL],
                [UnitCountRetrievedAt]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @Name,
                @CountyID,
                ISNULL(@PropertyType, 'Other'),
                CASE WHEN @UnitCount_Clear = 1 THEN NULL ELSE ISNULL(@UnitCount, NULL) END,
                CASE WHEN @UnitCountSource_Clear = 1 THEN NULL ELSE ISNULL(@UnitCountSource, NULL) END,
                ISNULL(@GroupingStatus, 'Suggested'),
                CASE WHEN @ConfirmedByUserID_Clear = 1 THEN NULL ELSE ISNULL(@ConfirmedByUserID, NULL) END,
                CASE WHEN @ConfirmedAt_Clear = 1 THEN NULL ELSE ISNULL(@ConfirmedAt, NULL) END,
                CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, NULL) END,
                CASE WHEN @GroupingVersion_Clear = 1 THEN NULL ELSE ISNULL(@GroupingVersion, NULL) END,
                CASE WHEN @SplitAt_Clear = 1 THEN NULL ELSE ISNULL(@SplitAt, NULL) END,
                CASE WHEN @UnitCountSourceURL_Clear = 1 THEN NULL ELSE ISNULL(@UnitCountSourceURL, NULL) END,
                CASE WHEN @UnitCountRetrievedAt_Clear = 1 THEN NULL ELSE ISNULL(@UnitCountRetrievedAt, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwProperties] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateProperty] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for Properties */

GRANT EXECUTE ON [indiana_tax].[spCreateProperty] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for Properties */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Properties
-- Item: spUpdateProperty
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR Property
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateProperty]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateProperty];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateProperty]
    @ID uniqueidentifier,
    @Name nvarchar(200) = NULL,
    @CountyID uniqueidentifier = NULL,
    @PropertyType nvarchar(20) = NULL,
    @UnitCount_Clear bit = 0,
    @UnitCount int = NULL,
    @UnitCountSource_Clear bit = 0,
    @UnitCountSource nvarchar(20) = NULL,
    @GroupingStatus nvarchar(20) = NULL,
    @ConfirmedByUserID_Clear bit = 0,
    @ConfirmedByUserID uniqueidentifier = NULL,
    @ConfirmedAt_Clear bit = 0,
    @ConfirmedAt datetime2 = NULL,
    @Notes_Clear bit = 0,
    @Notes nvarchar(MAX) = NULL,
    @GroupingVersion_Clear bit = 0,
    @GroupingVersion datetime2 = NULL,
    @SplitAt_Clear bit = 0,
    @SplitAt datetime2 = NULL,
    @UnitCountSourceURL_Clear bit = 0,
    @UnitCountSourceURL nvarchar(500) = NULL,
    @UnitCountRetrievedAt_Clear bit = 0,
    @UnitCountRetrievedAt datetime2 = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[Property]
    SET
        [Name] = ISNULL(@Name, [Name]),
        [CountyID] = ISNULL(@CountyID, [CountyID]),
        [PropertyType] = ISNULL(@PropertyType, [PropertyType]),
        [UnitCount] = CASE WHEN @UnitCount_Clear = 1 THEN NULL ELSE ISNULL(@UnitCount, [UnitCount]) END,
        [UnitCountSource] = CASE WHEN @UnitCountSource_Clear = 1 THEN NULL ELSE ISNULL(@UnitCountSource, [UnitCountSource]) END,
        [GroupingStatus] = ISNULL(@GroupingStatus, [GroupingStatus]),
        [ConfirmedByUserID] = CASE WHEN @ConfirmedByUserID_Clear = 1 THEN NULL ELSE ISNULL(@ConfirmedByUserID, [ConfirmedByUserID]) END,
        [ConfirmedAt] = CASE WHEN @ConfirmedAt_Clear = 1 THEN NULL ELSE ISNULL(@ConfirmedAt, [ConfirmedAt]) END,
        [Notes] = CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, [Notes]) END,
        [GroupingVersion] = CASE WHEN @GroupingVersion_Clear = 1 THEN NULL ELSE ISNULL(@GroupingVersion, [GroupingVersion]) END,
        [SplitAt] = CASE WHEN @SplitAt_Clear = 1 THEN NULL ELSE ISNULL(@SplitAt, [SplitAt]) END,
        [UnitCountSourceURL] = CASE WHEN @UnitCountSourceURL_Clear = 1 THEN NULL ELSE ISNULL(@UnitCountSourceURL, [UnitCountSourceURL]) END,
        [UnitCountRetrievedAt] = CASE WHEN @UnitCountRetrievedAt_Clear = 1 THEN NULL ELSE ISNULL(@UnitCountRetrievedAt, [UnitCountRetrievedAt]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwProperties] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwProperties]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateProperty] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the Property table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateProperty]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateProperty];
GO
CREATE TRIGGER [indiana_tax].trgUpdateProperty
ON [indiana_tax].[Property]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[Property]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[Property] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for Properties */

GRANT EXECUTE ON [indiana_tax].[spUpdateProperty] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for Properties */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Properties
-- Item: spDeleteProperty
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR Property
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteProperty]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteProperty];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteProperty]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[Property]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteProperty] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for Properties */

GRANT EXECUTE ON [indiana_tax].[spDeleteProperty] TO [cdp_Developer], [cdp_Integration];

/* Base View SQL for Property Suggestion Evidences */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Property Suggestion Evidences
-- Item: vwPropertySuggestionEvidences
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Property Suggestion Evidences
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  PropertySuggestionEvidence
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwPropertySuggestionEvidences]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwPropertySuggestionEvidences];
GO

CREATE VIEW [indiana_tax].[vwPropertySuggestionEvidences]
AS
SELECT
    p.*,
    indianataxProperty_PropertyID.[Name] AS [Property]
FROM
    [indiana_tax].[PropertySuggestionEvidence] AS p
INNER JOIN
    [indiana_tax].[Property] AS indianataxProperty_PropertyID
  ON
    [p].[PropertyID] = indianataxProperty_PropertyID.[ID]
GO
GRANT SELECT ON [indiana_tax].[vwPropertySuggestionEvidences] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for Property Suggestion Evidences */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Property Suggestion Evidences
-- Item: Permissions for vwPropertySuggestionEvidences
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwPropertySuggestionEvidences] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for Property Suggestion Evidences */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Property Suggestion Evidences
-- Item: spCreatePropertySuggestionEvidence
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR PropertySuggestionEvidence
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreatePropertySuggestionEvidence]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreatePropertySuggestionEvidence];
GO

CREATE PROCEDURE [indiana_tax].[spCreatePropertySuggestionEvidence]
    @ID uniqueidentifier = NULL,
    @PropertyID uniqueidentifier,
    @SignalCode nvarchar(2),
    @Grade nvarchar(1),
    @Evidence nvarchar(400),
    @SuggestedAt datetime2
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[PropertySuggestionEvidence]
            (
                [ID],
                [PropertyID],
                [SignalCode],
                [Grade],
                [Evidence],
                [SuggestedAt]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @PropertyID,
                @SignalCode,
                @Grade,
                @Evidence,
                @SuggestedAt
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[PropertySuggestionEvidence]
            (
                [PropertyID],
                [SignalCode],
                [Grade],
                [Evidence],
                [SuggestedAt]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @PropertyID,
                @SignalCode,
                @Grade,
                @Evidence,
                @SuggestedAt
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwPropertySuggestionEvidences] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreatePropertySuggestionEvidence] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for Property Suggestion Evidences */

GRANT EXECUTE ON [indiana_tax].[spCreatePropertySuggestionEvidence] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for Property Suggestion Evidences */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Property Suggestion Evidences
-- Item: spUpdatePropertySuggestionEvidence
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR PropertySuggestionEvidence
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdatePropertySuggestionEvidence]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdatePropertySuggestionEvidence];
GO

CREATE PROCEDURE [indiana_tax].[spUpdatePropertySuggestionEvidence]
    @ID uniqueidentifier,
    @PropertyID uniqueidentifier = NULL,
    @SignalCode nvarchar(2) = NULL,
    @Grade nvarchar(1) = NULL,
    @Evidence nvarchar(400) = NULL,
    @SuggestedAt datetime2 = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[PropertySuggestionEvidence]
    SET
        [PropertyID] = ISNULL(@PropertyID, [PropertyID]),
        [SignalCode] = ISNULL(@SignalCode, [SignalCode]),
        [Grade] = ISNULL(@Grade, [Grade]),
        [Evidence] = ISNULL(@Evidence, [Evidence]),
        [SuggestedAt] = ISNULL(@SuggestedAt, [SuggestedAt])
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwPropertySuggestionEvidences] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwPropertySuggestionEvidences]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdatePropertySuggestionEvidence] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the PropertySuggestionEvidence table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdatePropertySuggestionEvidence]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdatePropertySuggestionEvidence];
GO
CREATE TRIGGER [indiana_tax].trgUpdatePropertySuggestionEvidence
ON [indiana_tax].[PropertySuggestionEvidence]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[PropertySuggestionEvidence]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[PropertySuggestionEvidence] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for Property Suggestion Evidences */

GRANT EXECUTE ON [indiana_tax].[spUpdatePropertySuggestionEvidence] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for Property Suggestion Evidences */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Property Suggestion Evidences
-- Item: spDeletePropertySuggestionEvidence
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR PropertySuggestionEvidence
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeletePropertySuggestionEvidence]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeletePropertySuggestionEvidence];
GO

CREATE PROCEDURE [indiana_tax].[spDeletePropertySuggestionEvidence]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[PropertySuggestionEvidence]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeletePropertySuggestionEvidence] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for Property Suggestion Evidences */

GRANT EXECUTE ON [indiana_tax].[spDeletePropertySuggestionEvidence] TO [cdp_Developer], [cdp_Integration];

/* Index for Foreign Keys for SaleConveyanceMember */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Sale Conveyance Members
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key SaleConveyanceID in table SaleConveyanceMember
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_SaleConveyanceMember_SaleConveyanceID' 
    AND object_id = OBJECT_ID('[indiana_tax].[SaleConveyanceMember]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_SaleConveyanceMember_SaleConveyanceID ON [indiana_tax].[SaleConveyanceMember] ([SaleConveyanceID]);

-- Index for foreign key SaleTransactionID in table SaleConveyanceMember
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_SaleConveyanceMember_SaleTransactionID' 
    AND object_id = OBJECT_ID('[indiana_tax].[SaleConveyanceMember]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_SaleConveyanceMember_SaleTransactionID ON [indiana_tax].[SaleConveyanceMember] ([SaleTransactionID]);

-- Index for foreign key ParcelID in table SaleConveyanceMember
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_SaleConveyanceMember_ParcelID' 
    AND object_id = OBJECT_ID('[indiana_tax].[SaleConveyanceMember]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_SaleConveyanceMember_ParcelID ON [indiana_tax].[SaleConveyanceMember] ([ParcelID]);

/* SQL text to update entity field related entity name field map for entity field ID FAFA9F38-6D24-4E0A-A38A-C6C072BD43A0 */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='FAFA9F38-6D24-4E0A-A38A-C6C072BD43A0', @RelatedEntityNameFieldMap='SaleTransaction';

/* Index for Foreign Keys for SaleConveyance */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Sale Conveyances
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

/* Base View SQL for Sale Conveyances */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Sale Conveyances
-- Item: vwSaleConveyances
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Sale Conveyances
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  SaleConveyance
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwSaleConveyances]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwSaleConveyances];
GO

CREATE VIEW [indiana_tax].[vwSaleConveyances]
AS
SELECT
    s.*
FROM
    [indiana_tax].[SaleConveyance] AS s
GO
GRANT SELECT ON [indiana_tax].[vwSaleConveyances] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for Sale Conveyances */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Sale Conveyances
-- Item: Permissions for vwSaleConveyances
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwSaleConveyances] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for Sale Conveyances */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Sale Conveyances
-- Item: spCreateSaleConveyance
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR SaleConveyance
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateSaleConveyance]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateSaleConveyance];
GO

CREATE PROCEDURE [indiana_tax].[spCreateSaleConveyance]
    @ID uniqueidentifier = NULL,
    @ConveyanceKey nvarchar(200),
    @CountyNumber int,
    @SaleDate date,
    @SalePrice decimal(18, 2),
    @GranteeNormalized_Clear bit = 0,
    @GranteeNormalized nvarchar(200) = NULL,
    @KeyBasis nvarchar(20),
    @ParcelCount int,
    @DominantTypeGroup_Clear bit = 0,
    @DominantTypeGroup nvarchar(30) = NULL,
    @UnitOfComparison_Clear bit = 0,
    @UnitOfComparison nvarchar(10) = NULL,
    @BuildingSqFtSum_Clear bit = 0,
    @BuildingSqFtSum decimal(14, 2) = NULL,
    @UnitSum_Clear bit = 0,
    @UnitSum decimal(12, 2) = NULL,
    @AcreSum_Clear bit = 0,
    @AcreSum decimal(12, 4) = NULL,
    @IsComplete bit,
    @PricePerUnit_Clear bit = 0,
    @PricePerUnit decimal(14, 2) = NULL,
    @AssessedAtSaleSum_Clear bit = 0,
    @AssessedAtSaleSum decimal(18, 2) = NULL,
    @SaleToAssessedRatio_Clear bit = 0,
    @SaleToAssessedRatio decimal(9, 4) = NULL,
    @RebuiltAt datetime2
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[SaleConveyance]
            (
                [ID],
                [ConveyanceKey],
                [CountyNumber],
                [SaleDate],
                [SalePrice],
                [GranteeNormalized],
                [KeyBasis],
                [ParcelCount],
                [DominantTypeGroup],
                [UnitOfComparison],
                [BuildingSqFtSum],
                [UnitSum],
                [AcreSum],
                [IsComplete],
                [PricePerUnit],
                [AssessedAtSaleSum],
                [SaleToAssessedRatio],
                [RebuiltAt]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @ConveyanceKey,
                @CountyNumber,
                @SaleDate,
                @SalePrice,
                CASE WHEN @GranteeNormalized_Clear = 1 THEN NULL ELSE ISNULL(@GranteeNormalized, NULL) END,
                @KeyBasis,
                @ParcelCount,
                CASE WHEN @DominantTypeGroup_Clear = 1 THEN NULL ELSE ISNULL(@DominantTypeGroup, NULL) END,
                CASE WHEN @UnitOfComparison_Clear = 1 THEN NULL ELSE ISNULL(@UnitOfComparison, NULL) END,
                CASE WHEN @BuildingSqFtSum_Clear = 1 THEN NULL ELSE ISNULL(@BuildingSqFtSum, NULL) END,
                CASE WHEN @UnitSum_Clear = 1 THEN NULL ELSE ISNULL(@UnitSum, NULL) END,
                CASE WHEN @AcreSum_Clear = 1 THEN NULL ELSE ISNULL(@AcreSum, NULL) END,
                @IsComplete,
                CASE WHEN @PricePerUnit_Clear = 1 THEN NULL ELSE ISNULL(@PricePerUnit, NULL) END,
                CASE WHEN @AssessedAtSaleSum_Clear = 1 THEN NULL ELSE ISNULL(@AssessedAtSaleSum, NULL) END,
                CASE WHEN @SaleToAssessedRatio_Clear = 1 THEN NULL ELSE ISNULL(@SaleToAssessedRatio, NULL) END,
                @RebuiltAt
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[SaleConveyance]
            (
                [ConveyanceKey],
                [CountyNumber],
                [SaleDate],
                [SalePrice],
                [GranteeNormalized],
                [KeyBasis],
                [ParcelCount],
                [DominantTypeGroup],
                [UnitOfComparison],
                [BuildingSqFtSum],
                [UnitSum],
                [AcreSum],
                [IsComplete],
                [PricePerUnit],
                [AssessedAtSaleSum],
                [SaleToAssessedRatio],
                [RebuiltAt]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ConveyanceKey,
                @CountyNumber,
                @SaleDate,
                @SalePrice,
                CASE WHEN @GranteeNormalized_Clear = 1 THEN NULL ELSE ISNULL(@GranteeNormalized, NULL) END,
                @KeyBasis,
                @ParcelCount,
                CASE WHEN @DominantTypeGroup_Clear = 1 THEN NULL ELSE ISNULL(@DominantTypeGroup, NULL) END,
                CASE WHEN @UnitOfComparison_Clear = 1 THEN NULL ELSE ISNULL(@UnitOfComparison, NULL) END,
                CASE WHEN @BuildingSqFtSum_Clear = 1 THEN NULL ELSE ISNULL(@BuildingSqFtSum, NULL) END,
                CASE WHEN @UnitSum_Clear = 1 THEN NULL ELSE ISNULL(@UnitSum, NULL) END,
                CASE WHEN @AcreSum_Clear = 1 THEN NULL ELSE ISNULL(@AcreSum, NULL) END,
                @IsComplete,
                CASE WHEN @PricePerUnit_Clear = 1 THEN NULL ELSE ISNULL(@PricePerUnit, NULL) END,
                CASE WHEN @AssessedAtSaleSum_Clear = 1 THEN NULL ELSE ISNULL(@AssessedAtSaleSum, NULL) END,
                CASE WHEN @SaleToAssessedRatio_Clear = 1 THEN NULL ELSE ISNULL(@SaleToAssessedRatio, NULL) END,
                @RebuiltAt
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwSaleConveyances] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateSaleConveyance] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for Sale Conveyances */

GRANT EXECUTE ON [indiana_tax].[spCreateSaleConveyance] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for Sale Conveyances */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Sale Conveyances
-- Item: spUpdateSaleConveyance
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR SaleConveyance
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateSaleConveyance]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateSaleConveyance];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateSaleConveyance]
    @ID uniqueidentifier,
    @ConveyanceKey nvarchar(200) = NULL,
    @CountyNumber int = NULL,
    @SaleDate date = NULL,
    @SalePrice decimal(18, 2) = NULL,
    @GranteeNormalized_Clear bit = 0,
    @GranteeNormalized nvarchar(200) = NULL,
    @KeyBasis nvarchar(20) = NULL,
    @ParcelCount int = NULL,
    @DominantTypeGroup_Clear bit = 0,
    @DominantTypeGroup nvarchar(30) = NULL,
    @UnitOfComparison_Clear bit = 0,
    @UnitOfComparison nvarchar(10) = NULL,
    @BuildingSqFtSum_Clear bit = 0,
    @BuildingSqFtSum decimal(14, 2) = NULL,
    @UnitSum_Clear bit = 0,
    @UnitSum decimal(12, 2) = NULL,
    @AcreSum_Clear bit = 0,
    @AcreSum decimal(12, 4) = NULL,
    @IsComplete bit = NULL,
    @PricePerUnit_Clear bit = 0,
    @PricePerUnit decimal(14, 2) = NULL,
    @AssessedAtSaleSum_Clear bit = 0,
    @AssessedAtSaleSum decimal(18, 2) = NULL,
    @SaleToAssessedRatio_Clear bit = 0,
    @SaleToAssessedRatio decimal(9, 4) = NULL,
    @RebuiltAt datetime2 = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[SaleConveyance]
    SET
        [ConveyanceKey] = ISNULL(@ConveyanceKey, [ConveyanceKey]),
        [CountyNumber] = ISNULL(@CountyNumber, [CountyNumber]),
        [SaleDate] = ISNULL(@SaleDate, [SaleDate]),
        [SalePrice] = ISNULL(@SalePrice, [SalePrice]),
        [GranteeNormalized] = CASE WHEN @GranteeNormalized_Clear = 1 THEN NULL ELSE ISNULL(@GranteeNormalized, [GranteeNormalized]) END,
        [KeyBasis] = ISNULL(@KeyBasis, [KeyBasis]),
        [ParcelCount] = ISNULL(@ParcelCount, [ParcelCount]),
        [DominantTypeGroup] = CASE WHEN @DominantTypeGroup_Clear = 1 THEN NULL ELSE ISNULL(@DominantTypeGroup, [DominantTypeGroup]) END,
        [UnitOfComparison] = CASE WHEN @UnitOfComparison_Clear = 1 THEN NULL ELSE ISNULL(@UnitOfComparison, [UnitOfComparison]) END,
        [BuildingSqFtSum] = CASE WHEN @BuildingSqFtSum_Clear = 1 THEN NULL ELSE ISNULL(@BuildingSqFtSum, [BuildingSqFtSum]) END,
        [UnitSum] = CASE WHEN @UnitSum_Clear = 1 THEN NULL ELSE ISNULL(@UnitSum, [UnitSum]) END,
        [AcreSum] = CASE WHEN @AcreSum_Clear = 1 THEN NULL ELSE ISNULL(@AcreSum, [AcreSum]) END,
        [IsComplete] = ISNULL(@IsComplete, [IsComplete]),
        [PricePerUnit] = CASE WHEN @PricePerUnit_Clear = 1 THEN NULL ELSE ISNULL(@PricePerUnit, [PricePerUnit]) END,
        [AssessedAtSaleSum] = CASE WHEN @AssessedAtSaleSum_Clear = 1 THEN NULL ELSE ISNULL(@AssessedAtSaleSum, [AssessedAtSaleSum]) END,
        [SaleToAssessedRatio] = CASE WHEN @SaleToAssessedRatio_Clear = 1 THEN NULL ELSE ISNULL(@SaleToAssessedRatio, [SaleToAssessedRatio]) END,
        [RebuiltAt] = ISNULL(@RebuiltAt, [RebuiltAt])
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwSaleConveyances] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwSaleConveyances]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateSaleConveyance] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the SaleConveyance table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateSaleConveyance]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateSaleConveyance];
GO
CREATE TRIGGER [indiana_tax].trgUpdateSaleConveyance
ON [indiana_tax].[SaleConveyance]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[SaleConveyance]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[SaleConveyance] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for Sale Conveyances */

GRANT EXECUTE ON [indiana_tax].[spUpdateSaleConveyance] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for Sale Conveyances */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Sale Conveyances
-- Item: spDeleteSaleConveyance
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR SaleConveyance
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteSaleConveyance]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteSaleConveyance];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteSaleConveyance]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[SaleConveyance]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteSaleConveyance] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for Sale Conveyances */

GRANT EXECUTE ON [indiana_tax].[spDeleteSaleConveyance] TO [cdp_Developer], [cdp_Integration];

/* SQL text to update entity field related entity name field map for entity field ID 2890853E-689F-4B7B-B352-39CE4597ACC5 */
EXEC [${flyway:defaultSchema}].[spUpdateEntityFieldRelatedEntityNameFieldMap] @EntityFieldID='2890853E-689F-4B7B-B352-39CE4597ACC5', @RelatedEntityNameFieldMap='Parcel';

/* Base View SQL for Sale Conveyance Members */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Sale Conveyance Members
-- Item: vwSaleConveyanceMembers
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Sale Conveyance Members
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  SaleConveyanceMember
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwSaleConveyanceMembers]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwSaleConveyanceMembers];
GO

CREATE VIEW [indiana_tax].[vwSaleConveyanceMembers]
AS
SELECT
    s.*,
    indianataxSaleTransaction_SaleTransactionID.[SitusAddress] AS [SaleTransaction],
    indianataxParcel_ParcelID.[ParcelNumber] AS [Parcel]
FROM
    [indiana_tax].[SaleConveyanceMember] AS s
INNER JOIN
    [indiana_tax].[SaleTransaction] AS indianataxSaleTransaction_SaleTransactionID
  ON
    [s].[SaleTransactionID] = indianataxSaleTransaction_SaleTransactionID.[ID]
LEFT OUTER JOIN
    [indiana_tax].[Parcel] AS indianataxParcel_ParcelID
  ON
    [s].[ParcelID] = indianataxParcel_ParcelID.[ID]
GO
GRANT SELECT ON [indiana_tax].[vwSaleConveyanceMembers] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for Sale Conveyance Members */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Sale Conveyance Members
-- Item: Permissions for vwSaleConveyanceMembers
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwSaleConveyanceMembers] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for Sale Conveyance Members */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Sale Conveyance Members
-- Item: spCreateSaleConveyanceMember
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR SaleConveyanceMember
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateSaleConveyanceMember]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateSaleConveyanceMember];
GO

CREATE PROCEDURE [indiana_tax].[spCreateSaleConveyanceMember]
    @ID uniqueidentifier = NULL,
    @SaleConveyanceID uniqueidentifier,
    @SaleTransactionID uniqueidentifier,
    @ParcelID_Clear bit = 0,
    @ParcelID uniqueidentifier = NULL,
    @MemberBuildingSqFt_Clear bit = 0,
    @MemberBuildingSqFt decimal(14, 2) = NULL,
    @MemberUnits_Clear bit = 0,
    @MemberUnits decimal(12, 2) = NULL,
    @MemberAcres_Clear bit = 0,
    @MemberAcres decimal(12, 4) = NULL,
    @ContributesSqFt bit,
    @IsDuplicateCard bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[SaleConveyanceMember]
            (
                [ID],
                [SaleConveyanceID],
                [SaleTransactionID],
                [ParcelID],
                [MemberBuildingSqFt],
                [MemberUnits],
                [MemberAcres],
                [ContributesSqFt],
                [IsDuplicateCard]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @SaleConveyanceID,
                @SaleTransactionID,
                CASE WHEN @ParcelID_Clear = 1 THEN NULL ELSE ISNULL(@ParcelID, NULL) END,
                CASE WHEN @MemberBuildingSqFt_Clear = 1 THEN NULL ELSE ISNULL(@MemberBuildingSqFt, NULL) END,
                CASE WHEN @MemberUnits_Clear = 1 THEN NULL ELSE ISNULL(@MemberUnits, NULL) END,
                CASE WHEN @MemberAcres_Clear = 1 THEN NULL ELSE ISNULL(@MemberAcres, NULL) END,
                @ContributesSqFt,
                ISNULL(@IsDuplicateCard, 0)
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[SaleConveyanceMember]
            (
                [SaleConveyanceID],
                [SaleTransactionID],
                [ParcelID],
                [MemberBuildingSqFt],
                [MemberUnits],
                [MemberAcres],
                [ContributesSqFt],
                [IsDuplicateCard]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @SaleConveyanceID,
                @SaleTransactionID,
                CASE WHEN @ParcelID_Clear = 1 THEN NULL ELSE ISNULL(@ParcelID, NULL) END,
                CASE WHEN @MemberBuildingSqFt_Clear = 1 THEN NULL ELSE ISNULL(@MemberBuildingSqFt, NULL) END,
                CASE WHEN @MemberUnits_Clear = 1 THEN NULL ELSE ISNULL(@MemberUnits, NULL) END,
                CASE WHEN @MemberAcres_Clear = 1 THEN NULL ELSE ISNULL(@MemberAcres, NULL) END,
                @ContributesSqFt,
                ISNULL(@IsDuplicateCard, 0)
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwSaleConveyanceMembers] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateSaleConveyanceMember] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for Sale Conveyance Members */

GRANT EXECUTE ON [indiana_tax].[spCreateSaleConveyanceMember] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for Sale Conveyance Members */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Sale Conveyance Members
-- Item: spUpdateSaleConveyanceMember
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR SaleConveyanceMember
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateSaleConveyanceMember]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateSaleConveyanceMember];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateSaleConveyanceMember]
    @ID uniqueidentifier,
    @SaleConveyanceID uniqueidentifier = NULL,
    @SaleTransactionID uniqueidentifier = NULL,
    @ParcelID_Clear bit = 0,
    @ParcelID uniqueidentifier = NULL,
    @MemberBuildingSqFt_Clear bit = 0,
    @MemberBuildingSqFt decimal(14, 2) = NULL,
    @MemberUnits_Clear bit = 0,
    @MemberUnits decimal(12, 2) = NULL,
    @MemberAcres_Clear bit = 0,
    @MemberAcres decimal(12, 4) = NULL,
    @ContributesSqFt bit = NULL,
    @IsDuplicateCard bit = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[SaleConveyanceMember]
    SET
        [SaleConveyanceID] = ISNULL(@SaleConveyanceID, [SaleConveyanceID]),
        [SaleTransactionID] = ISNULL(@SaleTransactionID, [SaleTransactionID]),
        [ParcelID] = CASE WHEN @ParcelID_Clear = 1 THEN NULL ELSE ISNULL(@ParcelID, [ParcelID]) END,
        [MemberBuildingSqFt] = CASE WHEN @MemberBuildingSqFt_Clear = 1 THEN NULL ELSE ISNULL(@MemberBuildingSqFt, [MemberBuildingSqFt]) END,
        [MemberUnits] = CASE WHEN @MemberUnits_Clear = 1 THEN NULL ELSE ISNULL(@MemberUnits, [MemberUnits]) END,
        [MemberAcres] = CASE WHEN @MemberAcres_Clear = 1 THEN NULL ELSE ISNULL(@MemberAcres, [MemberAcres]) END,
        [ContributesSqFt] = ISNULL(@ContributesSqFt, [ContributesSqFt]),
        [IsDuplicateCard] = ISNULL(@IsDuplicateCard, [IsDuplicateCard])
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwSaleConveyanceMembers] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwSaleConveyanceMembers]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateSaleConveyanceMember] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the SaleConveyanceMember table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateSaleConveyanceMember]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateSaleConveyanceMember];
GO
CREATE TRIGGER [indiana_tax].trgUpdateSaleConveyanceMember
ON [indiana_tax].[SaleConveyanceMember]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[SaleConveyanceMember]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[SaleConveyanceMember] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for Sale Conveyance Members */

GRANT EXECUTE ON [indiana_tax].[spUpdateSaleConveyanceMember] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for Sale Conveyance Members */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Sale Conveyance Members
-- Item: spDeleteSaleConveyanceMember
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR SaleConveyanceMember
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteSaleConveyanceMember]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteSaleConveyanceMember];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteSaleConveyanceMember]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[SaleConveyanceMember]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteSaleConveyanceMember] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for Sale Conveyance Members */

GRANT EXECUTE ON [indiana_tax].[spDeleteSaleConveyanceMember] TO [cdp_Developer], [cdp_Integration];

/* SQL text to insert 6 new entity field(s) */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '2e703110-8f1b-4bd4-b3fc-77cdcbcb411d' OR (EntityID = '39DD9AEC-F3C1-425C-85EA-3261C47173D2' AND Name = 'Parcel')) BEGIN
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
            '2e703110-8f1b-4bd4-b3fc-77cdcbcb411d',
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2', -- Entity: Appeal Recommendations
            100077,
            'Parcel',
            'Parcel',
            NULL,
            'nvarchar',
            60,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '6a097969-fbd5-4d66-9a8e-ac11ff122774' OR (EntityID = '39DD9AEC-F3C1-425C-85EA-3261C47173D2' AND Name = 'Property')) BEGIN
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
            '6a097969-fbd5-4d66-9a8e-ac11ff122774',
            '39DD9AEC-F3C1-425C-85EA-3261C47173D2', -- Entity: Appeal Recommendations
            100078,
            'Property',
            'Property',
            NULL,
            'nvarchar',
            400,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '8ee3a0a0-19d4-478a-a617-2ee8b7139e3e' OR (EntityID = '903F0793-42D9-4EAF-8BB8-3EEBF8FFF70A' AND Name = 'Property')) BEGIN
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
            '8ee3a0a0-19d4-478a-a617-2ee8b7139e3e',
            '903F0793-42D9-4EAF-8BB8-3EEBF8FFF70A', -- Entity: Property Suggestion Evidences
            100017,
            'Property',
            'Property',
            NULL,
            'nvarchar',
            400,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd60dd0ad-e7f9-4116-a01c-431ef5a01186' OR (EntityID = '04E37D72-B573-4B81-B1E1-A501F1372851' AND Name = 'SaleTransaction')) BEGIN
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
            'd60dd0ad-e7f9-4116-a01c-431ef5a01186',
            '04E37D72-B573-4B81-B1E1-A501F1372851', -- Entity: Sale Conveyance Members
            100023,
            'SaleTransaction',
            'Sale Transaction',
            NULL,
            'nvarchar',
            400,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'd3fffce6-1512-48f9-a289-4aeeec652088' OR (EntityID = '04E37D72-B573-4B81-B1E1-A501F1372851' AND Name = 'Parcel')) BEGIN
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
            'd3fffce6-1512-48f9-a289-4aeeec652088',
            '04E37D72-B573-4B81-B1E1-A501F1372851', -- Entity: Sale Conveyance Members
            100024,
            'Parcel',
            'Parcel',
            NULL,
            'nvarchar',
            60,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '6a748c79-1624-4fe3-96e5-1df57adee7a5' OR (EntityID = '785D1ECA-0EE2-40C8-B1EE-C5AFED5C5C6A' AND Name = 'Parcel')) BEGIN
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
            '6a748c79-1624-4fe3-96e5-1df57adee7a5',
            '785D1ECA-0EE2-40C8-B1EE-C5AFED5C5C6A', -- Entity: Appeal Recommendation Parcels
            100025,
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

/* Set field properties for entity */

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IsNameField = 1
               WHERE ID = '87FF5BF2-7A33-49DD-A2F9-ECC759C1C9F5'
               AND AutoUpdateIsNameField = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '87FF5BF2-7A33-49DD-A2F9-ECC759C1C9F5'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'B5D1A3CF-6E50-4248-ADC9-D2EF231F1EF0'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '75012C65-FD3E-4CB6-98C9-DFFC181B224A'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '8BB3ECC6-C479-4FE8-808D-2A309DB1BA27'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '625C1D93-1619-4390-8D74-50571E52436C'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '87FF5BF2-7A33-49DD-A2F9-ECC759C1C9F5'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'Exact'
               WHERE ID = '87FF5BF2-7A33-49DD-A2F9-ECC759C1C9F5'
               AND AutoUpdateUserSearchPredicate = 1;

/* Set field properties for entity */

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = 'CB944773-A427-44B1-8CA3-410E4DE6AAD5'
               AND AutoUpdateUserSearchPredicate = 1;

/* Set field properties for entity */

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'FBDE08C2-E482-4DA5-8206-9F68B8AA38A8'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'B06EA103-384F-47DB-BB04-0C4D7C75BB1D'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '8FC53A0E-32F3-42AD-8CA0-840BB7A39B43'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'D60DD0AD-E7F9-4116-A01C-431EF5A01186'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'D3FFFCE6-1512-48F9-A289-4AEEEC652088'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = 'D60DD0AD-E7F9-4116-A01C-431EF5A01186'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = 'D3FFFCE6-1512-48F9-A289-4AEEEC652088'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

/* Set field properties for entity */

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '3B447C2F-2045-4307-8FD7-708DA6946928'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '5E7E00DD-E6DD-456B-AF33-9B03E3989476'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'DD149791-D02E-43D5-A9AD-7628D5DA6DC4'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'D412626F-751F-44F7-A1B7-12BF6E980514'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '7BEAF931-37A6-46B3-8F68-770AD339D06D'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '2E703110-8F1B-4BD4-B3FC-77CDCBCB411D'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '6A097969-FBD5-4D66-9A8E-AC11FF122774'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '2E703110-8F1B-4BD4-B3FC-77CDCBCB411D'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '6A097969-FBD5-4D66-9A8E-AC11FF122774'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = '2E703110-8F1B-4BD4-B3FC-77CDCBCB411D'
               AND AutoUpdateUserSearchPredicate = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = '6A097969-FBD5-4D66-9A8E-AC11FF122774'
               AND AutoUpdateUserSearchPredicate = 1;

/* Set field properties for entity */

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IsNameField = 1
               WHERE ID = '36AA022E-CB91-4A2D-8BB9-1F26A75A0DD5'
               AND AutoUpdateIsNameField = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '36AA022E-CB91-4A2D-8BB9-1F26A75A0DD5'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '710A2CC4-90B4-49A1-9125-FDED0D9A9995'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '3038D933-337A-4213-9CEF-B303DB55AFDA'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '8CBCBC5D-0B9B-4A5C-9588-CCC88CE0377D'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '36AA022E-CB91-4A2D-8BB9-1F26A75A0DD5'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '710A2CC4-90B4-49A1-9125-FDED0D9A9995'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '3038D933-337A-4213-9CEF-B303DB55AFDA'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'Exact'
               WHERE ID = '36AA022E-CB91-4A2D-8BB9-1F26A75A0DD5'
               AND AutoUpdateUserSearchPredicate = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'Exact'
               WHERE ID = '710A2CC4-90B4-49A1-9125-FDED0D9A9995'
               AND AutoUpdateUserSearchPredicate = 1;

/* Set field properties for entity */

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'CA3C64B6-D710-40AD-8E9E-C45A27F62186'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'ED60F832-3B24-408F-A25A-2D2F0FEA8CFF'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '9D617367-4023-45A8-AA4A-C01A426B0829'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '6A748C79-1624-4FE3-96E5-1DF57ADEE7A5'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '6A748C79-1624-4FE3-96E5-1DF57ADEE7A5'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = '6A748C79-1624-4FE3-96E5-1DF57ADEE7A5'
               AND AutoUpdateUserSearchPredicate = 1;

/* Set field properties for entity */

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IsNameField = 1
               WHERE ID = '883F7F65-E677-4E8D-81F5-6B9DAD51D408'
               AND AutoUpdateIsNameField = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '883F7F65-E677-4E8D-81F5-6B9DAD51D408'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '24D030CE-268D-48FE-8069-A63FA9067C88'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '523080E4-C626-4F30-BBEC-83DDD622258C'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'B0A486CB-90DD-4467-8D77-B07592558724'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'FF7CFA14-FA59-4A1C-91A8-BB9EB9FFB5B4'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '083DCC75-B7EB-4E7E-B53D-2D5652EEC553'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '727BE856-9814-4C05-8C3C-F2F39E5BB590'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'CC3B7736-0B2B-49A4-B767-70A78A0EA100'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '883F7F65-E677-4E8D-81F5-6B9DAD51D408'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = 'B0A486CB-90DD-4467-8D77-B07592558724'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = '883F7F65-E677-4E8D-81F5-6B9DAD51D408'
               AND AutoUpdateUserSearchPredicate = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = 'B0A486CB-90DD-4467-8D77-B07592558724'
               AND AutoUpdateUserSearchPredicate = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'Exact'
               WHERE ID = 'D647C0A5-95A2-494B-8FE2-701FDEBE404F'
               AND AutoUpdateUserSearchPredicate = 1;

/* Set categories for 9 fields */

-- UPDATE Entity Field Category Info Property Suggestion Evidences.ID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'D5C54DEC-3A41-4F4E-AF47-D8E1BFB80679' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Property Suggestion Evidences.PropertyID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Suggestion Details',
   GeneratedFormSection = 'Category',
   DisplayName = 'Property',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'C2BC649B-187C-4E2E-BE4E-D825F67F042E' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Property Suggestion Evidences.SignalCode 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Suggestion Details',
   GeneratedFormSection = 'Category',
   ExtendedType = 'Code',
   CodeType = 'Other'
WHERE 
   ID = '36AA022E-CB91-4A2D-8BB9-1F26A75A0DD5' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Property Suggestion Evidences.Grade 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Suggestion Details',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '710A2CC4-90B4-49A1-9125-FDED0D9A9995' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Property Suggestion Evidences.Evidence 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Suggestion Details',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '3038D933-337A-4213-9CEF-B303DB55AFDA' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Property Suggestion Evidences.SuggestedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Suggestion Timing',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '8CBCBC5D-0B9B-4A5C-9588-CCC88CE0377D' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Property Suggestion Evidences.__mj_CreatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '6203F263-D628-4D06-BFF4-FA15743CDE6A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Property Suggestion Evidences.__mj_UpdatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'C60D42ED-A9FC-4C37-985C-5ECB51614241' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Property Suggestion Evidences.Property 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Suggestion Details',
   GeneratedFormSection = 'Category',
   DisplayName = 'Property Name',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '8EE3A0A0-19D4-478A-A617-2EE8B7139E3E' AND AutoUpdateCategory = 1;

/* Set entity icon to fa fa-lightbulb */

               UPDATE [${flyway:defaultSchema}].[Entity]
               SET [Icon] = 'fa fa-lightbulb', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = '903F0793-42D9-4EAF-8BB8-3EEBF8FFF70A';

/* Insert FieldCategoryInfo setting for entity */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('3b61c7ff-a542-4e98-b76b-e1e05648989c', '903F0793-42D9-4EAF-8BB8-3EEBF8FFF70A', 'FieldCategoryInfo', '{"Suggestion Details":{"icon":"fa fa-lightbulb","description":"Property suggestion evidence including signal code, grade, and supporting evidence text for practitioner review"},"Suggestion Timing":{"icon":"fa fa-clock","description":"Timestamp when the suggestion engine generated this evidence"},"System Metadata":{"icon":"fa fa-cog","description":"System-managed audit and tracking fields"}}', GETUTCDATE(), GETUTCDATE());

/* Insert FieldCategoryIcons setting (legacy) */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('2025b42f-ce7e-4749-9c6f-83811abcd073', '903F0793-42D9-4EAF-8BB8-3EEBF8FFF70A', 'FieldCategoryIcons', '{"Suggestion Details":"fa fa-lightbulb","Suggestion Timing":"fa fa-clock","System Metadata":"fa fa-cog"}', GETUTCDATE(), GETUTCDATE());

/* Set DefaultForNewUser=true for NEW entity (category: supporting, confidence: high) */

         UPDATE [${flyway:defaultSchema}].[ApplicationEntity]
         SET [DefaultForNewUser] = 1, [__mj_UpdatedAt] = GETUTCDATE()
         WHERE [EntityID] = '903F0793-42D9-4EAF-8BB8-3EEBF8FFF70A';

/* Set categories for 13 fields */

-- UPDATE Entity Field Category Info Appeal Recommendation Parcels.ID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'CE96492D-F2A5-4203-B472-2B0502D95223' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendation Parcels.AppealRecommendationID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Allocation Details',
   GeneratedFormSection = 'Category',
   DisplayName = 'Appeal Recommendation',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '872B314F-0667-4420-BDC5-1E07158B0D83' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendation Parcels.ParcelID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Allocation Details',
   GeneratedFormSection = 'Category',
   DisplayName = 'Parcel',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '54542E53-7CBB-4DCD-B4A7-3DD98EAF6F47' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendation Parcels.Parcel 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Allocation Details',
   GeneratedFormSection = 'Category',
   DisplayName = 'Parcel Name',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '6A748C79-1624-4FE3-96E5-1DF57ADEE7A5' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendation Parcels.MemberCurrentAV 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Allocation Basis',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '4F89A64C-403E-4E7A-898B-F02C045F9986' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendation Parcels.AllocationShare 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Allocation Basis',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'CA3C64B6-D710-40AD-8E9E-C45A27F62186' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendation Parcels.AllocationOverride 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Allocation Basis',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '9D617367-4023-45A8-AA4A-C01A426B0829' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendation Parcels.AllocatedFloor 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Allocated Values',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '4F350815-368B-4F90-A9EA-745243432C50' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendation Parcels.AllocatedAsk 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Allocated Values',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'ED60F832-3B24-408F-A25A-2D2F0FEA8CFF' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendation Parcels.AllocatedSavingsAtFloor 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Allocated Values',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '61DFB5F7-C99C-451E-ADDD-2DB9005440CD' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendation Parcels.AllocatedSavingsAtAsk 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Allocated Values',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'DAC2CED7-A348-4AA2-A9BF-083F5FCA5D74' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendation Parcels.__mj_CreatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '2B58707D-C291-4B94-A106-07A9B240CB14' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendation Parcels.__mj_UpdatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'FC6A2BAB-53F1-4875-8831-04B647DAB380' AND AutoUpdateCategory = 1;

/* Set entity icon to fa fa-map-marker-alt */

               UPDATE [${flyway:defaultSchema}].[Entity]
               SET [Icon] = 'fa fa-map-marker-alt', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = '785D1ECA-0EE2-40C8-B1EE-C5AFED5C5C6A';

/* Insert FieldCategoryInfo setting for entity */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('62d506b2-9fcd-4149-86b8-194eda8e1e0b', '785D1ECA-0EE2-40C8-B1EE-C5AFED5C5C6A', 'FieldCategoryInfo', '{"Allocation Details":{"icon":"fa fa-sitemap","description":"References to the parent appeal recommendation and member parcel being allocated"},"Allocation Basis":{"icon":"fa fa-calculator","description":"Basis for allocation including current assessed value, calculated share, and override flag"},"Allocated Values":{"icon":"fa fa-dollar-sign","description":"Proportionally allocated financial values including floor, ask, and estimated savings"},"System Metadata":{"icon":"fa fa-cog","description":"System-managed audit and tracking fields"}}', GETUTCDATE(), GETUTCDATE());

/* Insert FieldCategoryIcons setting (legacy) */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('1c62f514-4c36-4754-84b0-d32343a3aead', '785D1ECA-0EE2-40C8-B1EE-C5AFED5C5C6A', 'FieldCategoryIcons', '{"Allocation Details":"fa fa-sitemap","Allocation Basis":"fa fa-calculator","Allocated Values":"fa fa-dollar-sign","System Metadata":"fa fa-cog"}', GETUTCDATE(), GETUTCDATE());

/* Set DefaultForNewUser=true for NEW entity (category: supporting, confidence: high) */

         UPDATE [${flyway:defaultSchema}].[ApplicationEntity]
         SET [DefaultForNewUser] = 1, [__mj_UpdatedAt] = GETUTCDATE()
         WHERE [EntityID] = '785D1ECA-0EE2-40C8-B1EE-C5AFED5C5C6A';

/* Set categories for 13 fields */

-- UPDATE Entity Field Category Info Sale Conveyance Members.ID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'CABCFE03-7D3F-4FCE-A7BB-5E5A6609B84E' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Sale Conveyance Members.SaleConveyanceID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Conveyance Membership',
   GeneratedFormSection = 'Category',
   DisplayName = 'Sale Conveyance',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'BE39C785-0998-4B06-B8FD-4ECFF71B2172' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Sale Conveyance Members.SaleTransactionID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Conveyance Membership',
   GeneratedFormSection = 'Category',
   DisplayName = 'Sale Transaction',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'FAFA9F38-6D24-4E0A-A38A-C6C072BD43A0' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Sale Conveyance Members.ParcelID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Conveyance Membership',
   GeneratedFormSection = 'Category',
   DisplayName = 'Parcel',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '2890853E-689F-4B7B-B352-39CE4597ACC5' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Sale Conveyance Members.MemberBuildingSqFt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Member Property Metrics',
   GeneratedFormSection = 'Category',
   DisplayName = 'Member Building Square Feet',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'FBDE08C2-E482-4DA5-8206-9F68B8AA38A8' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Sale Conveyance Members.MemberUnits 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Member Property Metrics',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'EC4FBCC2-C39D-49AA-928D-1D07AEF936D7' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Sale Conveyance Members.MemberAcres 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Member Property Metrics',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'B06EA103-384F-47DB-BB04-0C4D7C75BB1D' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Sale Conveyance Members.ContributesSqFt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Member Contribution Status',
   GeneratedFormSection = 'Category',
   DisplayName = 'Contributes Square Feet',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'A73373E3-7D43-4364-8C72-E1EE9A953245' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Sale Conveyance Members.IsDuplicateCard 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Member Contribution Status',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '8FC53A0E-32F3-42AD-8CA0-840BB7A39B43' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Sale Conveyance Members.SaleTransaction 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Related Data',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'D60DD0AD-E7F9-4116-A01C-431EF5A01186' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Sale Conveyance Members.Parcel 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Related Data',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'D3FFFCE6-1512-48F9-A289-4AEEEC652088' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Sale Conveyance Members.__mj_CreatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '19D9AE20-7B2D-4AEC-8ADF-CF226E77974B' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Sale Conveyance Members.__mj_UpdatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '7F7387BD-2F34-486C-98CA-61470F013CA9' AND AutoUpdateCategory = 1;

/* Set categories for 18 fields */

-- UPDATE Entity Field Category Info Properties.ID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '4F975031-0A9C-4DB2-8574-B0CE7122BA9A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Properties.Name 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'E5A4F2F1-35CB-4E2B-B24F-F1E171C31612' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Properties.CountyID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '8EF61E52-22A6-41DA-A854-4B0CA06B9E04' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Properties.County 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '4408D170-F71E-4BCC-BDB7-14C5D6AE0B49' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Properties.PropertyType 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'CB944773-A427-44B1-8CA3-410E4DE6AAD5' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Properties.UnitCount 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'EE60105F-F04A-493C-B721-30281AF1CF86' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Properties.UnitCountSource 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'B3D211D1-C386-402E-BEEE-2B4F82D5F6BF' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Properties.UnitCountSourceURL 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Unit Count Source',
   GeneratedFormSection = 'Category',
   ExtendedType = 'URL',
   CodeType = NULL
WHERE 
   ID = '899FD6AE-F819-4E3A-A5D6-B490087011BB' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Properties.UnitCountRetrievedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Unit Count Source',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'D1BC5E6D-FE5F-4592-B2C2-0B11A5601ABD' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Properties.GroupingStatus 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '2AC0CD39-453E-48EC-9677-DAA93B8324FF' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Properties.ConfirmedByUserID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   DisplayName = 'Confirmed By User',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'BE266168-C808-4530-BD04-668AB7A66D6F' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Properties.ConfirmedByUser 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   DisplayName = 'Confirmed By User Name',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'D31668AB-7EE4-4BB3-9968-62164B15D674' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Properties.ConfirmedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '28495A9C-3EA4-44E3-8040-8E1A78816CCE' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Properties.GroupingVersion 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Parcel Grouping',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'FF2B03C2-2FAF-4A0B-8C25-F60573760161' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Properties.SplitAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Parcel Grouping',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '8484331B-9A44-4113-8D26-E3CBBAFC4956' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Properties.Notes 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '0C8E2096-E88C-4D7B-8E24-11694B816710' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Properties.__mj_CreatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '56B5D316-71D9-47C3-99EB-065DED3AA997' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Properties.__mj_UpdatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '33DA207F-E4BB-4463-A334-0FDE26214681' AND AutoUpdateCategory = 1;

/* Set entity icon to fa fa-file-contract */

               UPDATE [${flyway:defaultSchema}].[Entity]
               SET [Icon] = 'fa fa-file-contract', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = '04E37D72-B573-4B81-B1E1-A501F1372851';

/* Insert FieldCategoryInfo setting for entity */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('f4192d8c-79c1-44d6-a4b5-8d6f6bca6b86', '04E37D72-B573-4B81-B1E1-A501F1372851', 'FieldCategoryInfo', '{"Conveyance Membership":{"icon":"fa fa-link","description":"Foreign key relationships linking this member to the conveyance, sale transaction, and parcel records"},"Member Property Metrics":{"icon":"fa fa-ruler-combined","description":"Property measurements for this conveyance member including square footage, units, and acreage"},"Member Contribution Status":{"icon":"fa fa-check-circle","description":"Flags indicating whether this member contributes to conveyance sums and if it is a duplicate card"},"Related Data":{"icon":"fa fa-external-link-alt","description":"Display references to related sale transaction and parcel information"},"System Metadata":{"icon":"fa fa-cog","description":"System-managed audit and tracking fields"}}', GETUTCDATE(), GETUTCDATE());

/* Insert FieldCategoryIcons setting (legacy) */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('a10648a1-6d8f-48cb-916a-6017c5ab46cd', '04E37D72-B573-4B81-B1E1-A501F1372851', 'FieldCategoryIcons', '{"Conveyance Membership":"fa fa-link","Member Property Metrics":"fa fa-ruler-combined","Member Contribution Status":"fa fa-check-circle","Related Data":"fa fa-external-link-alt","System Metadata":"fa fa-cog"}', GETUTCDATE(), GETUTCDATE());

/* Update FieldCategoryInfo setting for entity */

               UPDATE [${flyway:defaultSchema}].[EntitySetting]
               SET [Value] = '{"Unit Count Source":{"icon":"fa fa-info-circle","description":"Source, URL, and retrieval timestamp for unit count data"},"Parcel Grouping":{"icon":"fa fa-object-group","description":"Multi-parcel grouping status, versioning, and split history for property composition"}}', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [EntityID] = '60CE2DDA-DDB0-4445-BE61-4303D0174B8C' AND [Name] = 'FieldCategoryInfo';

/* Set DefaultForNewUser=false for NEW entity (category: junction, confidence: high) */

         UPDATE [${flyway:defaultSchema}].[ApplicationEntity]
         SET [DefaultForNewUser] = 0, [__mj_UpdatedAt] = GETUTCDATE()
         WHERE [EntityID] = '04E37D72-B573-4B81-B1E1-A501F1372851';

/* Update FieldCategoryIcons setting (legacy) */

               UPDATE [${flyway:defaultSchema}].[EntitySetting]
               SET [Value] = '{"Unit Count Source":"fa fa-info-circle","Parcel Grouping":"fa fa-object-group"}', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [EntityID] = '60CE2DDA-DDB0-4445-BE61-4303D0174B8C' AND [Name] = 'FieldCategoryIcons';

/* Set categories for 13 fields */

-- UPDATE Entity Field Category Info Appeal Recommendation Signals.ID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'BE14804D-3F82-43E3-89E0-E8C4CAE421FD' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendation Signals.AppealRecommendationID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Signal Association',
   GeneratedFormSection = 'Category',
   DisplayName = 'Appeal Recommendation',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'AC9F12B3-0C56-4BF1-8064-7DEC7C1E36BD' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendation Signals.SignalCode 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Signal Definition',
   GeneratedFormSection = 'Category',
   ExtendedType = 'Code',
   CodeType = 'Other'
WHERE 
   ID = '87FF5BF2-7A33-49DD-A2F9-ECC759C1C9F5' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendation Signals.Supports 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Signal Evaluation',
   GeneratedFormSection = 'Category',
   DisplayName = 'Supports Appeal',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'B5D1A3CF-6E50-4248-ADC9-D2EF231F1EF0' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendation Signals.NAReason 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Signal Evaluation',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'B91BF5A2-84B3-4D39-9B5D-DCD36BE9436F' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendation Signals.IndicatedValue 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Valuation Results',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '75012C65-FD3E-4CB6-98C9-DFFC181B224A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendation Signals.IndicatedPerUnit 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Valuation Results',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'F2DFA4C0-486A-4158-B6D7-9BAD7AA6A91B' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendation Signals.UnitOfComparison 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Valuation Results',
   GeneratedFormSection = 'Category',
   DisplayName = 'Unit of Comparison',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '8BB3ECC6-C479-4FE8-808D-2A309DB1BA27' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendation Signals.EvidenceCount 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Evidence Details',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '625C1D93-1619-4390-8D74-50571E52436C' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendation Signals.EvidenceNote 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Evidence Details',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'BE464190-4864-44D4-ACFB-337766379CCF' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendation Signals.RuleVersion 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Signal Definition',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'E4195D28-2E65-46B2-B48B-5309B8773903' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendation Signals.__mj_CreatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '9493C56C-3D80-4195-A213-FC5654E8AD82' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendation Signals.__mj_UpdatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'D173B378-D189-4EB1-A813-AE49C69655D5' AND AutoUpdateCategory = 1;

/* Set entity icon to fa fa-lightbulb */

               UPDATE [${flyway:defaultSchema}].[Entity]
               SET [Icon] = 'fa fa-lightbulb', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = '27770192-813F-4E84-A3FA-A856F29920EE';

/* Insert FieldCategoryInfo setting for entity */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('a2ec159e-4b33-41f6-8fbb-834a26b4a80b', '27770192-813F-4E84-A3FA-A856F29920EE', 'FieldCategoryInfo', '{"Signal Association":{"icon":"fa fa-link","description":"Links this signal row to its parent appeal recommendation record"},"Signal Definition":{"icon":"fa fa-tag","description":"Identifies which assessment signal (S1-S10) and the rule version applied"},"Signal Evaluation":{"icon":"fa fa-check-circle","description":"Assessment outcome: whether signal supports appeal and reasons if not evaluable"},"Valuation Results":{"icon":"fa fa-dollar-sign","description":"Indicated property value, per-unit metrics, and unit of measurement from the signal"},"Evidence Details":{"icon":"fa fa-file-alt","description":"Count of supporting records and narrative explanation of evidence findings"},"System Metadata":{"icon":"fa fa-cog","description":"System-managed audit and tracking fields"}}', GETUTCDATE(), GETUTCDATE());

/* Insert FieldCategoryIcons setting (legacy) */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('0db5d072-8d97-4c6a-bce8-5df7c64ee8bd', '27770192-813F-4E84-A3FA-A856F29920EE', 'FieldCategoryIcons', '{"Signal Association":"fa fa-link","Signal Definition":"fa fa-tag","Signal Evaluation":"fa fa-check-circle","Valuation Results":"fa fa-dollar-sign","Evidence Details":"fa fa-file-alt","System Metadata":"fa fa-cog"}', GETUTCDATE(), GETUTCDATE());

/* Set DefaultForNewUser=true for NEW entity (category: supporting, confidence: high) */

         UPDATE [${flyway:defaultSchema}].[ApplicationEntity]
         SET [DefaultForNewUser] = 1, [__mj_UpdatedAt] = GETUTCDATE()
         WHERE [EntityID] = '27770192-813F-4E84-A3FA-A856F29920EE';

/* Set categories for 20 fields */

-- UPDATE Entity Field Category Info Sale Conveyances.ID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '1A45F338-95B3-42A0-B841-E5F9AD44CD91' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Sale Conveyances.ConveyanceKey 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Conveyance Identification',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '883F7F65-E677-4E8D-81F5-6B9DAD51D408' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Sale Conveyances.CountyNumber 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Conveyance Identification',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'D647C0A5-95A2-494B-8FE2-701FDEBE404F' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Sale Conveyances.SaleDate 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Transaction Details',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '24D030CE-268D-48FE-8069-A63FA9067C88' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Sale Conveyances.SalePrice 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Transaction Details',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '523080E4-C626-4F30-BBEC-83DDD622258C' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Sale Conveyances.GranteeNormalized 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Conveyance Parties',
   GeneratedFormSection = 'Category',
   DisplayName = 'Grantee',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'B0A486CB-90DD-4467-8D77-B07592558724' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Sale Conveyances.KeyBasis 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Conveyance Identification',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '6936F407-8C7F-43FB-AC98-A6DB7D386AE6' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Sale Conveyances.ParcelCount 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Property Composition',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'FF7CFA14-FA59-4A1C-91A8-BB9EB9FFB5B4' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Sale Conveyances.DominantTypeGroup 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Property Composition',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '4C398783-5FDA-4EDE-B1E4-3B6C5E24068C' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Sale Conveyances.UnitOfComparison 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Valuation Metrics',
   GeneratedFormSection = 'Category',
   DisplayName = 'Unit of Comparison',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '083DCC75-B7EB-4E7E-B53D-2D5652EEC553' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Sale Conveyances.BuildingSqFtSum 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Valuation Metrics',
   GeneratedFormSection = 'Category',
   DisplayName = 'Building Square Feet',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'E16B4040-DF3F-45CA-9D41-3EEAC095E55A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Sale Conveyances.UnitSum 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Valuation Metrics',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '556A5B37-A243-4DFC-848B-6CAD0199894D' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Sale Conveyances.AcreSum 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Valuation Metrics',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '4E5CC97D-C930-43DD-8166-27FB7A7C6075' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Sale Conveyances.IsComplete 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Valuation Metrics',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '727BE856-9814-4C05-8C3C-F2F39E5BB590' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Sale Conveyances.PricePerUnit 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Valuation Metrics',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'CC3B7736-0B2B-49A4-B767-70A78A0EA100' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Sale Conveyances.AssessedAtSaleSum 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessment Comparison',
   GeneratedFormSection = 'Category',
   DisplayName = 'Assessed at Sale Sum',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '810CDC15-2ECF-42FF-9BB1-52BE1D6F64C6' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Sale Conveyances.SaleToAssessedRatio 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessment Comparison',
   GeneratedFormSection = 'Category',
   DisplayName = 'Sale to Assessed Ratio',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '4E671AF1-1012-4992-BFFB-3B8B49F0DC50' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Sale Conveyances.RebuiltAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '04CF56E4-9694-4714-B527-175CC621F4C4' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Sale Conveyances.__mj_CreatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '04C86FF7-11EC-4DDC-884F-99FF0F86EE58' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Sale Conveyances.__mj_UpdatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'FFC5E690-7D43-4F24-9C57-8DB19BD0C6F5' AND AutoUpdateCategory = 1;

/* Set entity icon to fa fa-file-contract */

               UPDATE [${flyway:defaultSchema}].[Entity]
               SET [Icon] = 'fa fa-file-contract', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = 'ADA5A377-DCA6-440A-9C28-A7F354223568';

/* Insert FieldCategoryInfo setting for entity */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('d52198b4-8dad-49e2-8680-b970380b5b1e', 'ADA5A377-DCA6-440A-9C28-A7F354223568', 'FieldCategoryInfo', '{"Conveyance Identification":{"icon":"fa fa-fingerprint","description":"Key identifiers for the conveyance transaction and grouping method"},"Transaction Details":{"icon":"fa fa-exchange-alt","description":"Core sale transaction information including date and price"},"Conveyance Parties":{"icon":"fa fa-user-tie","description":"Information about the grantee (buyer) in the transaction"},"Property Composition":{"icon":"fa fa-home","description":"Details about the parcels and property types included in the conveyance"},"Valuation Metrics":{"icon":"fa fa-chart-bar","description":"Calculated metrics for property valuation and comparable analysis including price per unit"},"Assessment Comparison":{"icon":"fa fa-balance-scale","description":"Assessed value and sale-to-assessment ratios for valuation analysis"},"System Metadata":{"icon":"fa fa-cog","description":"System-managed audit and tracking fields"}}', GETUTCDATE(), GETUTCDATE());

/* Insert FieldCategoryIcons setting (legacy) */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('68ca135f-7c70-4e13-8c27-71632220a7f4', 'ADA5A377-DCA6-440A-9C28-A7F354223568', 'FieldCategoryIcons', '{"Conveyance Identification":"fa fa-fingerprint","Transaction Details":"fa fa-exchange-alt","Conveyance Parties":"fa fa-user-tie","Property Composition":"fa fa-home","Valuation Metrics":"fa fa-chart-bar","Assessment Comparison":"fa fa-balance-scale","System Metadata":"fa fa-cog"}', GETUTCDATE(), GETUTCDATE());

/* Set DefaultForNewUser=true for NEW entity (category: primary, confidence: high) */

         UPDATE [${flyway:defaultSchema}].[ApplicationEntity]
         SET [DefaultForNewUser] = 1, [__mj_UpdatedAt] = GETUTCDATE()
         WHERE [EntityID] = 'ADA5A377-DCA6-440A-9C28-A7F354223568';

/* Set categories for 39 fields */

-- UPDATE Entity Field Category Info Appeal Recommendations.ID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Recommendation Identity',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'D36178A9-BE15-41E3-8ABA-994D654F9286' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendations.SubjectKind 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Recommendation Identity',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '82566216-36B5-486A-87C4-8EA944D1EEE0' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendations.ParcelID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Recommendation Identity',
   GeneratedFormSection = 'Category',
   DisplayName = 'Parcel',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '5DA3FB6B-C2BB-4631-B84A-86EB339008F4' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendations.PropertyID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Recommendation Identity',
   GeneratedFormSection = 'Category',
   DisplayName = 'Property',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '7B7BD624-2819-4C0D-ACDC-D0D9FAD5A244' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendations.AssessmentYear 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Recommendation Identity',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '3B447C2F-2045-4307-8FD7-708DA6946928' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendations.MethodologyVersion 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Recommendation Identity',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '3B268226-3411-4D95-AC21-EABB8974894E' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendations.IsCurrent 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Recommendation Identity',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '3A8C743F-F243-405C-AF16-5D87AC57DE6D' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendations.CurrentAV 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessment and Valuation',
   GeneratedFormSection = 'Category',
   DisplayName = 'Current Assessed Value',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'C8F1055A-89CB-4AF5-84CF-EAE449B656FE' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendations.PriorAVAsDetermined 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessment and Valuation',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '488E00A0-4DFE-45E7-94C2-8F393C092989' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendations.UnitOfComparison 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessment and Valuation',
   GeneratedFormSection = 'Category',
   DisplayName = 'Unit of Comparison',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '0DE0D626-BB9A-4EF1-AE8C-9FBBCEF658C5' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendations.Denominator 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessment and Valuation',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '8C167E71-B35F-4E9D-8BAD-03B8E738FAF9' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendations.DenominatorSource 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessment and Valuation',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '71A6088B-8382-4EEF-99F2-BEEABEBF19AD' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendations.DenominatorIsFallback 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessment and Valuation',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'A858CFA6-14B1-49FF-9380-6490C3BA2848' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendations.ValueSignalCount 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Appeal Signals and Evidence',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '5E7E00DD-E6DD-456B-AF33-9B03E3989476' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendations.IncreaseFlag 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Appeal Signals and Evidence',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '7C719951-1441-4233-94E7-704C4014E712' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendations.FloorSupport 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Appeal Signals and Evidence',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '6BEA06C4-1320-4605-A4B4-17C81883060B' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendations.PeerOutOfLine 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Appeal Signals and Evidence',
   GeneratedFormSection = 'Category',
   DisplayName = 'Peer Out of Line',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '4C265896-3883-4043-8ED2-E24948C2126D' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendations.OwnSaleContrary 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Appeal Signals and Evidence',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'AE38E36A-EB87-4972-BB15-CB4442068757' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendations.Verdict 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Recommendation Verdict',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'DD149791-D02E-43D5-A9AD-7628D5DA6DC4' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendations.NotAvailableReason 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Recommendation Verdict',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'D3B30128-6B07-47B3-96AE-068C22EAD751' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendations.ConfidenceTier 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Recommendation Verdict',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'D412626F-751F-44F7-A1B7-12BF6E980514' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendations.FloorValue 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Ask and Savings Analysis',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'F2FBA8FF-0C41-48AE-9DDC-58ADACC7A7AA' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendations.AskValue 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Ask and Savings Analysis',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'A48578E1-2B65-4240-AAD9-38C126CB744A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendations.AskPolicy 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Ask and Savings Analysis',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '1826970A-AE2B-4F20-AD92-6DF87139F37B' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendations.AskBasis 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Ask and Savings Analysis',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'E894CCFB-C162-47E3-9762-3310825BC8F4' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendations.EstSavingsAtAsk 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Ask and Savings Analysis',
   GeneratedFormSection = 'Category',
   DisplayName = 'Est Savings at Ask',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '7BEAF931-37A6-46B3-8F68-770AD339D06D' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendations.EstSavingsAtFloor 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Ask and Savings Analysis',
   GeneratedFormSection = 'Category',
   DisplayName = 'Est Savings at Floor',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '5787B0C7-94E9-4615-A6D3-275AD1870EFE' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendations.EffectiveTaxRate 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Ask and Savings Analysis',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'C7AF0316-5A1E-4ABD-9CEB-0F8F317C5404' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendations.GroupingStatus 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Subject Grouping and Status',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '3CF4424D-82F5-44F7-8BAC-0D64AE748E0E' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendations.GroupingVersion 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Subject Grouping and Status',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '58AE8FFE-CD3C-45C6-8F1D-F3AC83298A9F' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendations.AlreadyAppealed 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Subject Grouping and Status',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '55E9CD80-1D4D-43F9-B0F7-7369A7ACB144' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendations.ExistingRep 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Subject Grouping and Status',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '9ADD4883-E629-4EA1-9905-185560BC19BE' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendations.Exempt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Subject Grouping and Status',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '8127FE50-3A5B-4264-B436-6650B0DCBB6B' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendations.BelowSavingsFloor 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Subject Grouping and Status',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '359EA202-0222-4576-9EFA-71F0B411AFA8' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendations.RunStamp 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'E940D1E6-8099-4B68-BEE2-AC8FA3332080' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendations.GeneratedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'B939ADC8-DA98-4DC3-B655-05747611041A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendations.__mj_CreatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'D9AD157C-3BDB-4F7A-B0B8-5D2EAB2AEF62' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendations.__mj_UpdatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'D1BAE6BF-2FA0-45AE-96C8-2DC44F15560E' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Appeal Recommendations.Parcel 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Recommendation Identity',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '2E703110-8F1B-4BD4-B3FC-77CDCBCB411D' AND AutoUpdateCategory = 1;

/* Set entity icon to fa fa-lightbulb */

               UPDATE [${flyway:defaultSchema}].[Entity]
               SET [Icon] = 'fa fa-lightbulb', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = '39DD9AEC-F3C1-425C-85EA-3261C47173D2';

/* Insert FieldCategoryInfo setting for entity */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('33040d5a-ba04-4914-8351-d9f665098346', '39DD9AEC-F3C1-425C-85EA-3261C47173D2', 'FieldCategoryInfo', '{"Recommendation Identity":{"icon":"fa fa-fingerprint","description":"Unique identifier and contextual scope for the recommendation record"},"Assessment and Valuation":{"icon":"fa fa-calculator","description":"Current and prior assessed values, unit of comparison, and denominator information"},"Appeal Signals and Evidence":{"icon":"fa fa-chart-bar","description":"Value signals and contextual flags supporting appeal recommendation"},"Recommendation Verdict":{"icon":"fa fa-gavel","description":"Final recommendation verdict and confidence assessment"},"Ask and Savings Analysis":{"icon":"fa fa-dollar-sign","description":"Recommended ask value, floor value, and estimated tax savings"},"Subject Grouping and Status":{"icon":"fa fa-info-circle","description":"Property grouping status and qualification gates affecting recommendation"},"System Metadata":{"icon":"fa fa-cog","description":"System-managed audit and processing timestamps"}}', GETUTCDATE(), GETUTCDATE());

/* Insert FieldCategoryIcons setting (legacy) */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('ca94574c-4bd7-4653-99aa-d61dad388975', '39DD9AEC-F3C1-425C-85EA-3261C47173D2', 'FieldCategoryIcons', '{"Recommendation Identity":"fa fa-fingerprint","Assessment and Valuation":"fa fa-calculator","Appeal Signals and Evidence":"fa fa-chart-bar","Recommendation Verdict":"fa fa-gavel","Ask and Savings Analysis":"fa fa-dollar-sign","Subject Grouping and Status":"fa fa-info-circle","System Metadata":"fa fa-cog"}', GETUTCDATE(), GETUTCDATE());

/* Set DefaultForNewUser=true for NEW entity (category: primary, confidence: high) */

         UPDATE [${flyway:defaultSchema}].[ApplicationEntity]
         SET [DefaultForNewUser] = 1, [__mj_UpdatedAt] = GETUTCDATE()
         WHERE [EntityID] = '39DD9AEC-F3C1-425C-85EA-3261C47173D2';

/* Generated Validation Functions for Appeal Recommendations */
-- CHECK constraint for Appeal Recommendations @ Table Level was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
INSERT INTO [${flyway:defaultSchema}].[GeneratedCode] ([CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
                      VALUES ((SELECT [ID] FROM [${flyway:defaultSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4FD92457-0BA8-486F-978A-E5947154F4F4', GETUTCDATE(), 'TypeScript', 'Approved', '([SubjectKind]=''Parcel'' AND [ParcelID] IS NOT NULL AND [PropertyID] IS NULL OR [SubjectKind]=''Property'' AND [PropertyID] IS NOT NULL AND [ParcelID] IS NULL)', 'public ValidateSubjectKindAndIdConsistency(result: ValidationResult) {
	if (this.SubjectKind === "Parcel") {
		if (this.ParcelID == null) {
			result.Errors.push(new ValidationErrorInfo(
				"ParcelID",
				"ParcelID is required when SubjectKind is ''Parcel''",
				this.ParcelID,
				ValidationErrorType.Failure
			));
		}
		if (this.PropertyID != null) {
			result.Errors.push(new ValidationErrorInfo(
				"PropertyID",
				"PropertyID must be empty when SubjectKind is ''Parcel''",
				this.PropertyID,
				ValidationErrorType.Failure
			));
		}
	} else if (this.SubjectKind === "Property") {
		if (this.PropertyID == null) {
			result.Errors.push(new ValidationErrorInfo(
				"PropertyID",
				"PropertyID is required when SubjectKind is ''Property''",
				this.PropertyID,
				ValidationErrorType.Failure
			));
		}
		if (this.ParcelID != null) {
			result.Errors.push(new ValidationErrorInfo(
				"ParcelID",
				"ParcelID must be empty when SubjectKind is ''Property''",
				this.ParcelID,
				ValidationErrorType.Failure
			));
		}
	}
}', 'Each assessment record must reference either a Parcel or a Property, but not both. If the SubjectKind is ''Parcel'', then ParcelID must be provided and PropertyID must be empty. If the SubjectKind is ''Property'', then PropertyID must be provided and ParcelID must be empty. This ensures that every assessment is tied to exactly one subject type.', 'ValidateSubjectKindAndIdConsistency', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', '39DD9AEC-F3C1-425C-85EA-3261C47173D2');

