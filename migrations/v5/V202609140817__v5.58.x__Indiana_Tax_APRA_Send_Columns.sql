/* ============================================================================
   Indiana Property Tax Expert -- APRA request send columns
   v5.58.x

   Plan 1 (V202609131301) created the request model; its migration is applied
   and append-only. Plan 2 adds what the procedure document (APRA_PROCEDURE.md
   §8) requires to run the clock honestly: the date the agency received the
   request (IC 5-14-3-9(c) runs from receipt, not from sending), the mailed
   paper duplicate that anchors that date, the next action a person owes, the
   copied address, and the per-county send dates the operating calendar sets.

   Design: Indiana_Tax_Expert/docs/proposals/apra-request-model.md §8 (Plan 2)
   Plan:   Indiana_Tax_Expert/docs/plans/2026-09-14-apra-compose-send-receive.md
   ============================================================================ */

ALTER TABLE indiana_tax.APRARequest ADD
    ReceivedByAgencyAt DATETIMEOFFSET NULL,
    ReceivedByAgencyIsEstimate BIT NOT NULL CONSTRAINT DF_APRARequest_ReceivedByAgencyIsEstimate DEFAULT 0,
    MailedAt DATETIMEOFFSET NULL,
    MailTrackingNumber NVARCHAR(60) NULL,
    NextActionAt DATE NULL,
    NextActionNote NVARCHAR(300) NULL,
    CcAddress NVARCHAR(500) NULL;
GO

ALTER TABLE indiana_tax.County ADD
    RollRequestSendAfter DATE NULL,
    AppealListSendAfter DATE NULL;
GO

EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'When the agency received the request: the portal or email submission time for those channels; for a mailed letter the delivery date (a carrier confirmation), or MailedAt plus five days while ReceivedByAgencyIsEstimate = 1. The seven-day clock runs from here (docs/county_records/APRA_PROCEDURE.md section 8).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequest', @level2type=N'COLUMN', @level2name=N'ReceivedByAgencyAt';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'1 while ReceivedByAgencyAt is the mailing date plus a transit allowance rather than a confirmed delivery date.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequest', @level2type=N'COLUMN', @level2name=N'ReceivedByAgencyIsEstimate';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'When the paper duplicate of an emailed letter was mailed (every emailed request gets one: email alone is not named in IC 5-14-3-9(c)).', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequest', @level2type=N'COLUMN', @level2name=N'MailedAt';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Certified-mail or other tracking number of the paper duplicate, when used.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequest', @level2type=N'COLUMN', @level2name=N'MailTrackingNumber';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'The date a person next owes this request an action (mail the duplicate; chase on the due date; file the PAC complaint before the thirty-day window closes). Maintained by the scripts, shown in the open-requests view.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequest', @level2type=N'COLUMN', @level2name=N'NextActionAt';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'What the next action is, in a few words.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequest', @level2type=N'COLUMN', @level2name=N'NextActionNote';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Addresses copied on the send (the assessor personally where an office mailbox is the recipient; a named custodian where the assessor is), comma-separated.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequest', @level2type=N'COLUMN', @level2name=N'CcAddress';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Earliest date an ActiveRoll request for the current cycle should go to this county, set from docs/OPERATING_CALENDAR.md (which owns the reasoning) by load-county-send-dates.js.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'County', @level2type=N'COLUMN', @level2name=N'RollRequestSendAfter';
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Earliest date an AppealedParcels request for the current cycle should go to this county, from the same calendar.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'County', @level2type=N'COLUMN', @level2name=N'AppealListSendAfter';

EXEC sp_updateextendedproperty @name=N'MS_Description', @value=N'ReceivedByAgencyAt plus the statutory response period for a mailed, faxed or portal request; after it, a silent request is deemed denied. The period and its subsection: docs/county_records/APRA_PROCEDURE.md section 1; the anchor: section 8.', @level0type=N'SCHEMA', @level0name=N'indiana_tax', @level1type=N'TABLE', @level1name=N'APRARequest', @level2type=N'COLUMN', @level2name=N'StatutoryResponseDueAt';
GO


















































/* ============================================================================================
   EVERYTHING BELOW THIS LINE WAS GENERATED BY THE MEMBERJUNCTION CODEGEN TOOL (mj codegen)
   after the hand-written DDL above was applied on 2026-09-14: EntityField metadata for the
   nine new columns on APRA Requests and Counties, the regenerated base views vwAPRARequests
   and vwCounties, their spCreate / spUpdate procedures, and extended properties. Excluded: the
   Store Analysis sequence statement CodeGen emits on every run (a pre-existing big_box_retail
   defect). DO NOT EDIT BY HAND; if the DDL above changes, re-run mj codegen and replace this
   section.
   ============================================================================================ */

/* SQL text to insert 9 new entity field(s) */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '5a473142-351b-4783-a709-24e1e1058560' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'ReceivedByAgencyAt')) BEGIN
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
            '5a473142-351b-4783-a709-24e1e1058560',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100080,
            'ReceivedByAgencyAt',
            'Received By Agency At',
            'When the agency received the request: the portal or email submission time for those channels; for a mailed letter the delivery date (a carrier confirmation), or MailedAt plus five days while ReceivedByAgencyIsEstimate = 1. The seven-day clock runs from here (docs/county_records/APRA_PROCEDURE.md section 8).',
            'datetimeoffset',
            10,
            34,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '95d72160-cd24-4267-94b2-b875d8d1633d' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'ReceivedByAgencyIsEstimate')) BEGIN
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
            '95d72160-cd24-4267-94b2-b875d8d1633d',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100081,
            'ReceivedByAgencyIsEstimate',
            'Received By Agency Is Estimate',
            '1 while ReceivedByAgencyAt is the mailing date plus a transit allowance rather than a confirmed delivery date.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'b1a5fc87-effb-4976-8f8a-d04b4994b5c6' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'MailedAt')) BEGIN
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
            'b1a5fc87-effb-4976-8f8a-d04b4994b5c6',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100082,
            'MailedAt',
            'Mailed At',
            'When the paper duplicate of an emailed letter was mailed (every emailed request gets one: email alone is not named in IC 5-14-3-9(c)).',
            'datetimeoffset',
            10,
            34,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '7228cd9c-a403-4a7e-abcb-937515c4591e' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'MailTrackingNumber')) BEGIN
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
            '7228cd9c-a403-4a7e-abcb-937515c4591e',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100083,
            'MailTrackingNumber',
            'Mail Tracking Number',
            'Certified-mail or other tracking number of the paper duplicate, when used.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '057adea5-f68c-4435-80e9-a3d186dc23d1' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'NextActionAt')) BEGIN
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
            '057adea5-f68c-4435-80e9-a3d186dc23d1',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100084,
            'NextActionAt',
            'Next Action At',
            'The date a person next owes this request an action (mail the duplicate; chase on the due date; file the PAC complaint before the thirty-day window closes). Maintained by the scripts, shown in the open-requests view.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '857ffdb2-1df9-4b9e-b778-3fac31298f76' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'NextActionNote')) BEGIN
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
            '857ffdb2-1df9-4b9e-b778-3fac31298f76',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100085,
            'NextActionNote',
            'Next Action Note',
            'What the next action is, in a few words.',
            'nvarchar',
            600,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '42c9c122-9b71-49d3-afd6-99bf28b76340' OR (EntityID = '74C28031-4BAE-4D51-B67B-669793A0DF7A' AND Name = 'CcAddress')) BEGIN
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
            '42c9c122-9b71-49d3-afd6-99bf28b76340',
            '74C28031-4BAE-4D51-B67B-669793A0DF7A', -- Entity: APRA Requests
            100086,
            'CcAddress',
            'Cc Address',
            'Addresses copied on the send (the assessor personally where an office mailbox is the recipient; a named custodian where the assessor is), comma-separated.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '802be932-963a-4805-9d73-95464c7bddcf' OR (EntityID = '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A' AND Name = 'RollRequestSendAfter')) BEGIN
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
            '802be932-963a-4805-9d73-95464c7bddcf',
            '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A', -- Entity: Counties
            100043,
            'RollRequestSendAfter',
            'Roll Request Send After',
            'Earliest date an ActiveRoll request for the current cycle should go to this county, set from docs/OPERATING_CALENDAR.md (which owns the reasoning) by load-county-send-dates.js.',
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'e7b7acd9-4821-46c3-a512-f494eda9a6a9' OR (EntityID = '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A' AND Name = 'AppealListSendAfter')) BEGIN
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
            'e7b7acd9-4821-46c3-a512-f494eda9a6a9',
            '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A', -- Entity: Counties
            100044,
            'AppealListSendAfter',
            'Appeal List Send After',
            'Earliest date an AppealedParcels request for the current cycle should go to this county, from the same calendar.',
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

/* Index for Foreign Keys for APRARequest */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: APRA Requests
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------
-- Index for foreign key CountyID in table APRARequest
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_APRARequest_CountyID' 
    AND object_id = OBJECT_ID('[indiana_tax].[APRARequest]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_APRARequest_CountyID ON [indiana_tax].[APRARequest] ([CountyID]);

-- Index for foreign key CountyContactID in table APRARequest
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_APRARequest_CountyContactID' 
    AND object_id = OBJECT_ID('[indiana_tax].[APRARequest]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_APRARequest_CountyContactID ON [indiana_tax].[APRARequest] ([CountyContactID]);

-- Index for foreign key TemplateID in table APRARequest
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_APRARequest_TemplateID' 
    AND object_id = OBJECT_ID('[indiana_tax].[APRARequest]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_APRARequest_TemplateID ON [indiana_tax].[APRARequest] ([TemplateID]);

-- Index for foreign key CommunicationLogID in table APRARequest
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_APRARequest_CommunicationLogID' 
    AND object_id = OBJECT_ID('[indiana_tax].[APRARequest]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_APRARequest_CommunicationLogID ON [indiana_tax].[APRARequest] ([CommunicationLogID]);

-- Index for foreign key RequestSourceDocumentID in table APRARequest
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_AUTO_MJ_FKEY_APRARequest_RequestSourceDocumentID' 
    AND object_id = OBJECT_ID('[indiana_tax].[APRARequest]')
)
CREATE INDEX IDX_AUTO_MJ_FKEY_APRARequest_RequestSourceDocumentID ON [indiana_tax].[APRARequest] ([RequestSourceDocumentID]);

/* Base View SQL for APRA Requests */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: APRA Requests
-- Item: vwAPRARequests
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      APRA Requests
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  APRARequest
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwAPRARequests]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwAPRARequests];
GO

CREATE VIEW [indiana_tax].[vwAPRARequests]
AS
SELECT
    a.*,
    indianataxCounty_CountyID.[Name] AS [County],
    indianataxCountyContact_CountyContactID.[Name] AS [CountyContact],
    MJTemplate_TemplateID.[Name] AS [Template],
    MJCommunicationLog_CommunicationLogID.[MessageDate] AS [CommunicationLog]
FROM
    [indiana_tax].[APRARequest] AS a
INNER JOIN
    [indiana_tax].[County] AS indianataxCounty_CountyID
  ON
    [a].[CountyID] = indianataxCounty_CountyID.[ID]
LEFT OUTER JOIN
    [indiana_tax].[CountyContact] AS indianataxCountyContact_CountyContactID
  ON
    [a].[CountyContactID] = indianataxCountyContact_CountyContactID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[Template] AS MJTemplate_TemplateID
  ON
    [a].[TemplateID] = MJTemplate_TemplateID.[ID]
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[CommunicationLog] AS MJCommunicationLog_CommunicationLogID
  ON
    [a].[CommunicationLogID] = MJCommunicationLog_CommunicationLogID.[ID]
GO
GRANT SELECT ON [indiana_tax].[vwAPRARequests] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for APRA Requests */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: APRA Requests
-- Item: Permissions for vwAPRARequests
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwAPRARequests] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for APRA Requests */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: APRA Requests
-- Item: spCreateAPRARequest
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR APRARequest
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateAPRARequest]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateAPRARequest];
GO

CREATE PROCEDURE [indiana_tax].[spCreateAPRARequest]
    @ID uniqueidentifier = NULL,
    @CountyID uniqueidentifier,
    @CountyContactID_Clear bit = 0,
    @CountyContactID uniqueidentifier = NULL,
    @RequestNumber nvarchar(30),
    @RequestKind nvarchar(20),
    @AssessmentYear_Clear bit = 0,
    @AssessmentYear smallint = NULL,
    @Status nvarchar(15) = NULL,
    @TemplateID_Clear bit = 0,
    @TemplateID uniqueidentifier = NULL,
    @Subject_Clear bit = 0,
    @Subject nvarchar(300) = NULL,
    @RenderedBody_Clear bit = 0,
    @RenderedBody nvarchar(MAX) = NULL,
    @SubmissionMethod_Clear bit = 0,
    @SubmissionMethod nvarchar(10) = NULL,
    @ToAddress_Clear bit = 0,
    @ToAddress nvarchar(300) = NULL,
    @DraftedAt datetimeoffset = NULL,
    @ApprovedAt_Clear bit = 0,
    @ApprovedAt datetimeoffset = NULL,
    @SentAt_Clear bit = 0,
    @SentAt datetimeoffset = NULL,
    @StatutoryResponseDueAt_Clear bit = 0,
    @StatutoryResponseDueAt datetimeoffset = NULL,
    @AcknowledgedAt_Clear bit = 0,
    @AcknowledgedAt datetimeoffset = NULL,
    @FulfilledAt_Clear bit = 0,
    @FulfilledAt datetimeoffset = NULL,
    @DeniedAt_Clear bit = 0,
    @DeniedAt datetimeoffset = NULL,
    @DenialReason_Clear bit = 0,
    @DenialReason nvarchar(MAX) = NULL,
    @FeeQuoted_Clear bit = 0,
    @FeeQuoted decimal(10, 2) = NULL,
    @FeePaid_Clear bit = 0,
    @FeePaid decimal(10, 2) = NULL,
    @FeePaidAt_Clear bit = 0,
    @FeePaidAt datetimeoffset = NULL,
    @PACComplaintFiledAt_Clear bit = 0,
    @PACComplaintFiledAt datetimeoffset = NULL,
    @PACComplaintNumber_Clear bit = 0,
    @PACComplaintNumber nvarchar(30) = NULL,
    @PACOpinionAt_Clear bit = 0,
    @PACOpinionAt datetimeoffset = NULL,
    @PACOpinionURL_Clear bit = 0,
    @PACOpinionURL nvarchar(500) = NULL,
    @ProviderMessageID_Clear bit = 0,
    @ProviderMessageID nvarchar(200) = NULL,
    @ProviderThreadID_Clear bit = 0,
    @ProviderThreadID nvarchar(200) = NULL,
    @CommunicationLogID_Clear bit = 0,
    @CommunicationLogID uniqueidentifier = NULL,
    @RequestSourceDocumentID_Clear bit = 0,
    @RequestSourceDocumentID uniqueidentifier = NULL,
    @Notes_Clear bit = 0,
    @Notes nvarchar(MAX) = NULL,
    @ReceivedByAgencyAt_Clear bit = 0,
    @ReceivedByAgencyAt datetimeoffset = NULL,
    @ReceivedByAgencyIsEstimate bit = NULL,
    @MailedAt_Clear bit = 0,
    @MailedAt datetimeoffset = NULL,
    @MailTrackingNumber_Clear bit = 0,
    @MailTrackingNumber nvarchar(60) = NULL,
    @NextActionAt_Clear bit = 0,
    @NextActionAt date = NULL,
    @NextActionNote_Clear bit = 0,
    @NextActionNote nvarchar(300) = NULL,
    @CcAddress_Clear bit = 0,
    @CcAddress nvarchar(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[APRARequest]
            (
                [ID],
                [CountyID],
                [CountyContactID],
                [RequestNumber],
                [RequestKind],
                [AssessmentYear],
                [Status],
                [TemplateID],
                [Subject],
                [RenderedBody],
                [SubmissionMethod],
                [ToAddress],
                [DraftedAt],
                [ApprovedAt],
                [SentAt],
                [StatutoryResponseDueAt],
                [AcknowledgedAt],
                [FulfilledAt],
                [DeniedAt],
                [DenialReason],
                [FeeQuoted],
                [FeePaid],
                [FeePaidAt],
                [PACComplaintFiledAt],
                [PACComplaintNumber],
                [PACOpinionAt],
                [PACOpinionURL],
                [ProviderMessageID],
                [ProviderThreadID],
                [CommunicationLogID],
                [RequestSourceDocumentID],
                [Notes],
                [ReceivedByAgencyAt],
                [ReceivedByAgencyIsEstimate],
                [MailedAt],
                [MailTrackingNumber],
                [NextActionAt],
                [NextActionNote],
                [CcAddress]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @CountyID,
                CASE WHEN @CountyContactID_Clear = 1 THEN NULL ELSE ISNULL(@CountyContactID, NULL) END,
                @RequestNumber,
                @RequestKind,
                CASE WHEN @AssessmentYear_Clear = 1 THEN NULL ELSE ISNULL(@AssessmentYear, NULL) END,
                ISNULL(@Status, 'Draft'),
                CASE WHEN @TemplateID_Clear = 1 THEN NULL ELSE ISNULL(@TemplateID, NULL) END,
                CASE WHEN @Subject_Clear = 1 THEN NULL ELSE ISNULL(@Subject, NULL) END,
                CASE WHEN @RenderedBody_Clear = 1 THEN NULL ELSE ISNULL(@RenderedBody, NULL) END,
                CASE WHEN @SubmissionMethod_Clear = 1 THEN NULL ELSE ISNULL(@SubmissionMethod, NULL) END,
                CASE WHEN @ToAddress_Clear = 1 THEN NULL ELSE ISNULL(@ToAddress, NULL) END,
                ISNULL(@DraftedAt, sysdatetimeoffset()),
                CASE WHEN @ApprovedAt_Clear = 1 THEN NULL ELSE ISNULL(@ApprovedAt, NULL) END,
                CASE WHEN @SentAt_Clear = 1 THEN NULL ELSE ISNULL(@SentAt, NULL) END,
                CASE WHEN @StatutoryResponseDueAt_Clear = 1 THEN NULL ELSE ISNULL(@StatutoryResponseDueAt, NULL) END,
                CASE WHEN @AcknowledgedAt_Clear = 1 THEN NULL ELSE ISNULL(@AcknowledgedAt, NULL) END,
                CASE WHEN @FulfilledAt_Clear = 1 THEN NULL ELSE ISNULL(@FulfilledAt, NULL) END,
                CASE WHEN @DeniedAt_Clear = 1 THEN NULL ELSE ISNULL(@DeniedAt, NULL) END,
                CASE WHEN @DenialReason_Clear = 1 THEN NULL ELSE ISNULL(@DenialReason, NULL) END,
                CASE WHEN @FeeQuoted_Clear = 1 THEN NULL ELSE ISNULL(@FeeQuoted, NULL) END,
                CASE WHEN @FeePaid_Clear = 1 THEN NULL ELSE ISNULL(@FeePaid, NULL) END,
                CASE WHEN @FeePaidAt_Clear = 1 THEN NULL ELSE ISNULL(@FeePaidAt, NULL) END,
                CASE WHEN @PACComplaintFiledAt_Clear = 1 THEN NULL ELSE ISNULL(@PACComplaintFiledAt, NULL) END,
                CASE WHEN @PACComplaintNumber_Clear = 1 THEN NULL ELSE ISNULL(@PACComplaintNumber, NULL) END,
                CASE WHEN @PACOpinionAt_Clear = 1 THEN NULL ELSE ISNULL(@PACOpinionAt, NULL) END,
                CASE WHEN @PACOpinionURL_Clear = 1 THEN NULL ELSE ISNULL(@PACOpinionURL, NULL) END,
                CASE WHEN @ProviderMessageID_Clear = 1 THEN NULL ELSE ISNULL(@ProviderMessageID, NULL) END,
                CASE WHEN @ProviderThreadID_Clear = 1 THEN NULL ELSE ISNULL(@ProviderThreadID, NULL) END,
                CASE WHEN @CommunicationLogID_Clear = 1 THEN NULL ELSE ISNULL(@CommunicationLogID, NULL) END,
                CASE WHEN @RequestSourceDocumentID_Clear = 1 THEN NULL ELSE ISNULL(@RequestSourceDocumentID, NULL) END,
                CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, NULL) END,
                CASE WHEN @ReceivedByAgencyAt_Clear = 1 THEN NULL ELSE ISNULL(@ReceivedByAgencyAt, NULL) END,
                ISNULL(@ReceivedByAgencyIsEstimate, 0),
                CASE WHEN @MailedAt_Clear = 1 THEN NULL ELSE ISNULL(@MailedAt, NULL) END,
                CASE WHEN @MailTrackingNumber_Clear = 1 THEN NULL ELSE ISNULL(@MailTrackingNumber, NULL) END,
                CASE WHEN @NextActionAt_Clear = 1 THEN NULL ELSE ISNULL(@NextActionAt, NULL) END,
                CASE WHEN @NextActionNote_Clear = 1 THEN NULL ELSE ISNULL(@NextActionNote, NULL) END,
                CASE WHEN @CcAddress_Clear = 1 THEN NULL ELSE ISNULL(@CcAddress, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[APRARequest]
            (
                [CountyID],
                [CountyContactID],
                [RequestNumber],
                [RequestKind],
                [AssessmentYear],
                [Status],
                [TemplateID],
                [Subject],
                [RenderedBody],
                [SubmissionMethod],
                [ToAddress],
                [DraftedAt],
                [ApprovedAt],
                [SentAt],
                [StatutoryResponseDueAt],
                [AcknowledgedAt],
                [FulfilledAt],
                [DeniedAt],
                [DenialReason],
                [FeeQuoted],
                [FeePaid],
                [FeePaidAt],
                [PACComplaintFiledAt],
                [PACComplaintNumber],
                [PACOpinionAt],
                [PACOpinionURL],
                [ProviderMessageID],
                [ProviderThreadID],
                [CommunicationLogID],
                [RequestSourceDocumentID],
                [Notes],
                [ReceivedByAgencyAt],
                [ReceivedByAgencyIsEstimate],
                [MailedAt],
                [MailTrackingNumber],
                [NextActionAt],
                [NextActionNote],
                [CcAddress]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @CountyID,
                CASE WHEN @CountyContactID_Clear = 1 THEN NULL ELSE ISNULL(@CountyContactID, NULL) END,
                @RequestNumber,
                @RequestKind,
                CASE WHEN @AssessmentYear_Clear = 1 THEN NULL ELSE ISNULL(@AssessmentYear, NULL) END,
                ISNULL(@Status, 'Draft'),
                CASE WHEN @TemplateID_Clear = 1 THEN NULL ELSE ISNULL(@TemplateID, NULL) END,
                CASE WHEN @Subject_Clear = 1 THEN NULL ELSE ISNULL(@Subject, NULL) END,
                CASE WHEN @RenderedBody_Clear = 1 THEN NULL ELSE ISNULL(@RenderedBody, NULL) END,
                CASE WHEN @SubmissionMethod_Clear = 1 THEN NULL ELSE ISNULL(@SubmissionMethod, NULL) END,
                CASE WHEN @ToAddress_Clear = 1 THEN NULL ELSE ISNULL(@ToAddress, NULL) END,
                ISNULL(@DraftedAt, sysdatetimeoffset()),
                CASE WHEN @ApprovedAt_Clear = 1 THEN NULL ELSE ISNULL(@ApprovedAt, NULL) END,
                CASE WHEN @SentAt_Clear = 1 THEN NULL ELSE ISNULL(@SentAt, NULL) END,
                CASE WHEN @StatutoryResponseDueAt_Clear = 1 THEN NULL ELSE ISNULL(@StatutoryResponseDueAt, NULL) END,
                CASE WHEN @AcknowledgedAt_Clear = 1 THEN NULL ELSE ISNULL(@AcknowledgedAt, NULL) END,
                CASE WHEN @FulfilledAt_Clear = 1 THEN NULL ELSE ISNULL(@FulfilledAt, NULL) END,
                CASE WHEN @DeniedAt_Clear = 1 THEN NULL ELSE ISNULL(@DeniedAt, NULL) END,
                CASE WHEN @DenialReason_Clear = 1 THEN NULL ELSE ISNULL(@DenialReason, NULL) END,
                CASE WHEN @FeeQuoted_Clear = 1 THEN NULL ELSE ISNULL(@FeeQuoted, NULL) END,
                CASE WHEN @FeePaid_Clear = 1 THEN NULL ELSE ISNULL(@FeePaid, NULL) END,
                CASE WHEN @FeePaidAt_Clear = 1 THEN NULL ELSE ISNULL(@FeePaidAt, NULL) END,
                CASE WHEN @PACComplaintFiledAt_Clear = 1 THEN NULL ELSE ISNULL(@PACComplaintFiledAt, NULL) END,
                CASE WHEN @PACComplaintNumber_Clear = 1 THEN NULL ELSE ISNULL(@PACComplaintNumber, NULL) END,
                CASE WHEN @PACOpinionAt_Clear = 1 THEN NULL ELSE ISNULL(@PACOpinionAt, NULL) END,
                CASE WHEN @PACOpinionURL_Clear = 1 THEN NULL ELSE ISNULL(@PACOpinionURL, NULL) END,
                CASE WHEN @ProviderMessageID_Clear = 1 THEN NULL ELSE ISNULL(@ProviderMessageID, NULL) END,
                CASE WHEN @ProviderThreadID_Clear = 1 THEN NULL ELSE ISNULL(@ProviderThreadID, NULL) END,
                CASE WHEN @CommunicationLogID_Clear = 1 THEN NULL ELSE ISNULL(@CommunicationLogID, NULL) END,
                CASE WHEN @RequestSourceDocumentID_Clear = 1 THEN NULL ELSE ISNULL(@RequestSourceDocumentID, NULL) END,
                CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, NULL) END,
                CASE WHEN @ReceivedByAgencyAt_Clear = 1 THEN NULL ELSE ISNULL(@ReceivedByAgencyAt, NULL) END,
                ISNULL(@ReceivedByAgencyIsEstimate, 0),
                CASE WHEN @MailedAt_Clear = 1 THEN NULL ELSE ISNULL(@MailedAt, NULL) END,
                CASE WHEN @MailTrackingNumber_Clear = 1 THEN NULL ELSE ISNULL(@MailTrackingNumber, NULL) END,
                CASE WHEN @NextActionAt_Clear = 1 THEN NULL ELSE ISNULL(@NextActionAt, NULL) END,
                CASE WHEN @NextActionNote_Clear = 1 THEN NULL ELSE ISNULL(@NextActionNote, NULL) END,
                CASE WHEN @CcAddress_Clear = 1 THEN NULL ELSE ISNULL(@CcAddress, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwAPRARequests] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateAPRARequest] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for APRA Requests */

GRANT EXECUTE ON [indiana_tax].[spCreateAPRARequest] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for APRA Requests */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: APRA Requests
-- Item: spUpdateAPRARequest
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR APRARequest
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateAPRARequest]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateAPRARequest];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateAPRARequest]
    @ID uniqueidentifier,
    @CountyID uniqueidentifier = NULL,
    @CountyContactID_Clear bit = 0,
    @CountyContactID uniqueidentifier = NULL,
    @RequestNumber nvarchar(30) = NULL,
    @RequestKind nvarchar(20) = NULL,
    @AssessmentYear_Clear bit = 0,
    @AssessmentYear smallint = NULL,
    @Status nvarchar(15) = NULL,
    @TemplateID_Clear bit = 0,
    @TemplateID uniqueidentifier = NULL,
    @Subject_Clear bit = 0,
    @Subject nvarchar(300) = NULL,
    @RenderedBody_Clear bit = 0,
    @RenderedBody nvarchar(MAX) = NULL,
    @SubmissionMethod_Clear bit = 0,
    @SubmissionMethod nvarchar(10) = NULL,
    @ToAddress_Clear bit = 0,
    @ToAddress nvarchar(300) = NULL,
    @DraftedAt datetimeoffset = NULL,
    @ApprovedAt_Clear bit = 0,
    @ApprovedAt datetimeoffset = NULL,
    @SentAt_Clear bit = 0,
    @SentAt datetimeoffset = NULL,
    @StatutoryResponseDueAt_Clear bit = 0,
    @StatutoryResponseDueAt datetimeoffset = NULL,
    @AcknowledgedAt_Clear bit = 0,
    @AcknowledgedAt datetimeoffset = NULL,
    @FulfilledAt_Clear bit = 0,
    @FulfilledAt datetimeoffset = NULL,
    @DeniedAt_Clear bit = 0,
    @DeniedAt datetimeoffset = NULL,
    @DenialReason_Clear bit = 0,
    @DenialReason nvarchar(MAX) = NULL,
    @FeeQuoted_Clear bit = 0,
    @FeeQuoted decimal(10, 2) = NULL,
    @FeePaid_Clear bit = 0,
    @FeePaid decimal(10, 2) = NULL,
    @FeePaidAt_Clear bit = 0,
    @FeePaidAt datetimeoffset = NULL,
    @PACComplaintFiledAt_Clear bit = 0,
    @PACComplaintFiledAt datetimeoffset = NULL,
    @PACComplaintNumber_Clear bit = 0,
    @PACComplaintNumber nvarchar(30) = NULL,
    @PACOpinionAt_Clear bit = 0,
    @PACOpinionAt datetimeoffset = NULL,
    @PACOpinionURL_Clear bit = 0,
    @PACOpinionURL nvarchar(500) = NULL,
    @ProviderMessageID_Clear bit = 0,
    @ProviderMessageID nvarchar(200) = NULL,
    @ProviderThreadID_Clear bit = 0,
    @ProviderThreadID nvarchar(200) = NULL,
    @CommunicationLogID_Clear bit = 0,
    @CommunicationLogID uniqueidentifier = NULL,
    @RequestSourceDocumentID_Clear bit = 0,
    @RequestSourceDocumentID uniqueidentifier = NULL,
    @Notes_Clear bit = 0,
    @Notes nvarchar(MAX) = NULL,
    @ReceivedByAgencyAt_Clear bit = 0,
    @ReceivedByAgencyAt datetimeoffset = NULL,
    @ReceivedByAgencyIsEstimate bit = NULL,
    @MailedAt_Clear bit = 0,
    @MailedAt datetimeoffset = NULL,
    @MailTrackingNumber_Clear bit = 0,
    @MailTrackingNumber nvarchar(60) = NULL,
    @NextActionAt_Clear bit = 0,
    @NextActionAt date = NULL,
    @NextActionNote_Clear bit = 0,
    @NextActionNote nvarchar(300) = NULL,
    @CcAddress_Clear bit = 0,
    @CcAddress nvarchar(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[APRARequest]
    SET
        [CountyID] = ISNULL(@CountyID, [CountyID]),
        [CountyContactID] = CASE WHEN @CountyContactID_Clear = 1 THEN NULL ELSE ISNULL(@CountyContactID, [CountyContactID]) END,
        [RequestNumber] = ISNULL(@RequestNumber, [RequestNumber]),
        [RequestKind] = ISNULL(@RequestKind, [RequestKind]),
        [AssessmentYear] = CASE WHEN @AssessmentYear_Clear = 1 THEN NULL ELSE ISNULL(@AssessmentYear, [AssessmentYear]) END,
        [Status] = ISNULL(@Status, [Status]),
        [TemplateID] = CASE WHEN @TemplateID_Clear = 1 THEN NULL ELSE ISNULL(@TemplateID, [TemplateID]) END,
        [Subject] = CASE WHEN @Subject_Clear = 1 THEN NULL ELSE ISNULL(@Subject, [Subject]) END,
        [RenderedBody] = CASE WHEN @RenderedBody_Clear = 1 THEN NULL ELSE ISNULL(@RenderedBody, [RenderedBody]) END,
        [SubmissionMethod] = CASE WHEN @SubmissionMethod_Clear = 1 THEN NULL ELSE ISNULL(@SubmissionMethod, [SubmissionMethod]) END,
        [ToAddress] = CASE WHEN @ToAddress_Clear = 1 THEN NULL ELSE ISNULL(@ToAddress, [ToAddress]) END,
        [DraftedAt] = ISNULL(@DraftedAt, [DraftedAt]),
        [ApprovedAt] = CASE WHEN @ApprovedAt_Clear = 1 THEN NULL ELSE ISNULL(@ApprovedAt, [ApprovedAt]) END,
        [SentAt] = CASE WHEN @SentAt_Clear = 1 THEN NULL ELSE ISNULL(@SentAt, [SentAt]) END,
        [StatutoryResponseDueAt] = CASE WHEN @StatutoryResponseDueAt_Clear = 1 THEN NULL ELSE ISNULL(@StatutoryResponseDueAt, [StatutoryResponseDueAt]) END,
        [AcknowledgedAt] = CASE WHEN @AcknowledgedAt_Clear = 1 THEN NULL ELSE ISNULL(@AcknowledgedAt, [AcknowledgedAt]) END,
        [FulfilledAt] = CASE WHEN @FulfilledAt_Clear = 1 THEN NULL ELSE ISNULL(@FulfilledAt, [FulfilledAt]) END,
        [DeniedAt] = CASE WHEN @DeniedAt_Clear = 1 THEN NULL ELSE ISNULL(@DeniedAt, [DeniedAt]) END,
        [DenialReason] = CASE WHEN @DenialReason_Clear = 1 THEN NULL ELSE ISNULL(@DenialReason, [DenialReason]) END,
        [FeeQuoted] = CASE WHEN @FeeQuoted_Clear = 1 THEN NULL ELSE ISNULL(@FeeQuoted, [FeeQuoted]) END,
        [FeePaid] = CASE WHEN @FeePaid_Clear = 1 THEN NULL ELSE ISNULL(@FeePaid, [FeePaid]) END,
        [FeePaidAt] = CASE WHEN @FeePaidAt_Clear = 1 THEN NULL ELSE ISNULL(@FeePaidAt, [FeePaidAt]) END,
        [PACComplaintFiledAt] = CASE WHEN @PACComplaintFiledAt_Clear = 1 THEN NULL ELSE ISNULL(@PACComplaintFiledAt, [PACComplaintFiledAt]) END,
        [PACComplaintNumber] = CASE WHEN @PACComplaintNumber_Clear = 1 THEN NULL ELSE ISNULL(@PACComplaintNumber, [PACComplaintNumber]) END,
        [PACOpinionAt] = CASE WHEN @PACOpinionAt_Clear = 1 THEN NULL ELSE ISNULL(@PACOpinionAt, [PACOpinionAt]) END,
        [PACOpinionURL] = CASE WHEN @PACOpinionURL_Clear = 1 THEN NULL ELSE ISNULL(@PACOpinionURL, [PACOpinionURL]) END,
        [ProviderMessageID] = CASE WHEN @ProviderMessageID_Clear = 1 THEN NULL ELSE ISNULL(@ProviderMessageID, [ProviderMessageID]) END,
        [ProviderThreadID] = CASE WHEN @ProviderThreadID_Clear = 1 THEN NULL ELSE ISNULL(@ProviderThreadID, [ProviderThreadID]) END,
        [CommunicationLogID] = CASE WHEN @CommunicationLogID_Clear = 1 THEN NULL ELSE ISNULL(@CommunicationLogID, [CommunicationLogID]) END,
        [RequestSourceDocumentID] = CASE WHEN @RequestSourceDocumentID_Clear = 1 THEN NULL ELSE ISNULL(@RequestSourceDocumentID, [RequestSourceDocumentID]) END,
        [Notes] = CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, [Notes]) END,
        [ReceivedByAgencyAt] = CASE WHEN @ReceivedByAgencyAt_Clear = 1 THEN NULL ELSE ISNULL(@ReceivedByAgencyAt, [ReceivedByAgencyAt]) END,
        [ReceivedByAgencyIsEstimate] = ISNULL(@ReceivedByAgencyIsEstimate, [ReceivedByAgencyIsEstimate]),
        [MailedAt] = CASE WHEN @MailedAt_Clear = 1 THEN NULL ELSE ISNULL(@MailedAt, [MailedAt]) END,
        [MailTrackingNumber] = CASE WHEN @MailTrackingNumber_Clear = 1 THEN NULL ELSE ISNULL(@MailTrackingNumber, [MailTrackingNumber]) END,
        [NextActionAt] = CASE WHEN @NextActionAt_Clear = 1 THEN NULL ELSE ISNULL(@NextActionAt, [NextActionAt]) END,
        [NextActionNote] = CASE WHEN @NextActionNote_Clear = 1 THEN NULL ELSE ISNULL(@NextActionNote, [NextActionNote]) END,
        [CcAddress] = CASE WHEN @CcAddress_Clear = 1 THEN NULL ELSE ISNULL(@CcAddress, [CcAddress]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwAPRARequests] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwAPRARequests]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateAPRARequest] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the APRARequest table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateAPRARequest]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateAPRARequest];
GO
CREATE TRIGGER [indiana_tax].trgUpdateAPRARequest
ON [indiana_tax].[APRARequest]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[APRARequest]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[APRARequest] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for APRA Requests */

GRANT EXECUTE ON [indiana_tax].[spUpdateAPRARequest] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for APRA Requests */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: APRA Requests
-- Item: spDeleteAPRARequest
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR APRARequest
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteAPRARequest]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteAPRARequest];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteAPRARequest]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[APRARequest]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteAPRARequest] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for APRA Requests */

GRANT EXECUTE ON [indiana_tax].[spDeleteAPRARequest] TO [cdp_Developer], [cdp_Integration];

/* Index for Foreign Keys for County */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Counties
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

/* Base View SQL for Counties */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Counties
-- Item: vwCounties
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Counties
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  County
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwCounties]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwCounties];
GO

CREATE VIEW [indiana_tax].[vwCounties]
AS
SELECT
    c.*
FROM
    [indiana_tax].[County] AS c
GO
GRANT SELECT ON [indiana_tax].[vwCounties] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for Counties */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Counties
-- Item: Permissions for vwCounties
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwCounties] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for Counties */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Counties
-- Item: spCreateCounty
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR County
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateCounty]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateCounty];
GO

CREATE PROCEDURE [indiana_tax].[spCreateCounty]
    @ID uniqueidentifier = NULL,
    @CountyNumber smallint,
    @Name nvarchar(50),
    @Slug nvarchar(30),
    @FIPS_Clear bit = 0,
    @FIPS char(5) = NULL,
    @AssessorOfficeName_Clear bit = 0,
    @AssessorOfficeName nvarchar(150) = NULL,
    @AssessorMailingAddress_Clear bit = 0,
    @AssessorMailingAddress nvarchar(200) = NULL,
    @AssessorCity_Clear bit = 0,
    @AssessorCity nvarchar(60) = NULL,
    @AssessorZip_Clear bit = 0,
    @AssessorZip nvarchar(10) = NULL,
    @AssessorPhone_Clear bit = 0,
    @AssessorPhone nvarchar(30) = NULL,
    @AssessorWebsiteURL_Clear bit = 0,
    @AssessorWebsiteURL nvarchar(500) = NULL,
    @APRASubmissionMethod nvarchar(10) = NULL,
    @APRAPortalURL_Clear bit = 0,
    @APRAPortalURL nvarchar(500) = NULL,
    @APRAFormURL_Clear bit = 0,
    @APRAFormURL nvarchar(500) = NULL,
    @APRAPolicyURL_Clear bit = 0,
    @APRAPolicyURL nvarchar(500) = NULL,
    @APRAFeeNotes_Clear bit = 0,
    @APRAFeeNotes nvarchar(1000) = NULL,
    @ContactStatus nvarchar(15) = NULL,
    @ContactResearchedAt_Clear bit = 0,
    @ContactResearchedAt datetimeoffset = NULL,
    @Notes_Clear bit = 0,
    @Notes nvarchar(MAX) = NULL,
    @RollRequestSendAfter_Clear bit = 0,
    @RollRequestSendAfter date = NULL,
    @AppealListSendAfter_Clear bit = 0,
    @AppealListSendAfter date = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[County]
            (
                [ID],
                [CountyNumber],
                [Name],
                [Slug],
                [FIPS],
                [AssessorOfficeName],
                [AssessorMailingAddress],
                [AssessorCity],
                [AssessorZip],
                [AssessorPhone],
                [AssessorWebsiteURL],
                [APRASubmissionMethod],
                [APRAPortalURL],
                [APRAFormURL],
                [APRAPolicyURL],
                [APRAFeeNotes],
                [ContactStatus],
                [ContactResearchedAt],
                [Notes],
                [RollRequestSendAfter],
                [AppealListSendAfter]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @CountyNumber,
                @Name,
                @Slug,
                CASE WHEN @FIPS_Clear = 1 THEN NULL ELSE ISNULL(@FIPS, NULL) END,
                CASE WHEN @AssessorOfficeName_Clear = 1 THEN NULL ELSE ISNULL(@AssessorOfficeName, NULL) END,
                CASE WHEN @AssessorMailingAddress_Clear = 1 THEN NULL ELSE ISNULL(@AssessorMailingAddress, NULL) END,
                CASE WHEN @AssessorCity_Clear = 1 THEN NULL ELSE ISNULL(@AssessorCity, NULL) END,
                CASE WHEN @AssessorZip_Clear = 1 THEN NULL ELSE ISNULL(@AssessorZip, NULL) END,
                CASE WHEN @AssessorPhone_Clear = 1 THEN NULL ELSE ISNULL(@AssessorPhone, NULL) END,
                CASE WHEN @AssessorWebsiteURL_Clear = 1 THEN NULL ELSE ISNULL(@AssessorWebsiteURL, NULL) END,
                ISNULL(@APRASubmissionMethod, 'Unknown'),
                CASE WHEN @APRAPortalURL_Clear = 1 THEN NULL ELSE ISNULL(@APRAPortalURL, NULL) END,
                CASE WHEN @APRAFormURL_Clear = 1 THEN NULL ELSE ISNULL(@APRAFormURL, NULL) END,
                CASE WHEN @APRAPolicyURL_Clear = 1 THEN NULL ELSE ISNULL(@APRAPolicyURL, NULL) END,
                CASE WHEN @APRAFeeNotes_Clear = 1 THEN NULL ELSE ISNULL(@APRAFeeNotes, NULL) END,
                ISNULL(@ContactStatus, 'Unresearched'),
                CASE WHEN @ContactResearchedAt_Clear = 1 THEN NULL ELSE ISNULL(@ContactResearchedAt, NULL) END,
                CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, NULL) END,
                CASE WHEN @RollRequestSendAfter_Clear = 1 THEN NULL ELSE ISNULL(@RollRequestSendAfter, NULL) END,
                CASE WHEN @AppealListSendAfter_Clear = 1 THEN NULL ELSE ISNULL(@AppealListSendAfter, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[County]
            (
                [CountyNumber],
                [Name],
                [Slug],
                [FIPS],
                [AssessorOfficeName],
                [AssessorMailingAddress],
                [AssessorCity],
                [AssessorZip],
                [AssessorPhone],
                [AssessorWebsiteURL],
                [APRASubmissionMethod],
                [APRAPortalURL],
                [APRAFormURL],
                [APRAPolicyURL],
                [APRAFeeNotes],
                [ContactStatus],
                [ContactResearchedAt],
                [Notes],
                [RollRequestSendAfter],
                [AppealListSendAfter]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @CountyNumber,
                @Name,
                @Slug,
                CASE WHEN @FIPS_Clear = 1 THEN NULL ELSE ISNULL(@FIPS, NULL) END,
                CASE WHEN @AssessorOfficeName_Clear = 1 THEN NULL ELSE ISNULL(@AssessorOfficeName, NULL) END,
                CASE WHEN @AssessorMailingAddress_Clear = 1 THEN NULL ELSE ISNULL(@AssessorMailingAddress, NULL) END,
                CASE WHEN @AssessorCity_Clear = 1 THEN NULL ELSE ISNULL(@AssessorCity, NULL) END,
                CASE WHEN @AssessorZip_Clear = 1 THEN NULL ELSE ISNULL(@AssessorZip, NULL) END,
                CASE WHEN @AssessorPhone_Clear = 1 THEN NULL ELSE ISNULL(@AssessorPhone, NULL) END,
                CASE WHEN @AssessorWebsiteURL_Clear = 1 THEN NULL ELSE ISNULL(@AssessorWebsiteURL, NULL) END,
                ISNULL(@APRASubmissionMethod, 'Unknown'),
                CASE WHEN @APRAPortalURL_Clear = 1 THEN NULL ELSE ISNULL(@APRAPortalURL, NULL) END,
                CASE WHEN @APRAFormURL_Clear = 1 THEN NULL ELSE ISNULL(@APRAFormURL, NULL) END,
                CASE WHEN @APRAPolicyURL_Clear = 1 THEN NULL ELSE ISNULL(@APRAPolicyURL, NULL) END,
                CASE WHEN @APRAFeeNotes_Clear = 1 THEN NULL ELSE ISNULL(@APRAFeeNotes, NULL) END,
                ISNULL(@ContactStatus, 'Unresearched'),
                CASE WHEN @ContactResearchedAt_Clear = 1 THEN NULL ELSE ISNULL(@ContactResearchedAt, NULL) END,
                CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, NULL) END,
                CASE WHEN @RollRequestSendAfter_Clear = 1 THEN NULL ELSE ISNULL(@RollRequestSendAfter, NULL) END,
                CASE WHEN @AppealListSendAfter_Clear = 1 THEN NULL ELSE ISNULL(@AppealListSendAfter, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwCounties] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateCounty] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for Counties */

GRANT EXECUTE ON [indiana_tax].[spCreateCounty] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for Counties */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Counties
-- Item: spUpdateCounty
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR County
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateCounty]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateCounty];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateCounty]
    @ID uniqueidentifier,
    @CountyNumber smallint = NULL,
    @Name nvarchar(50) = NULL,
    @Slug nvarchar(30) = NULL,
    @FIPS_Clear bit = 0,
    @FIPS char(5) = NULL,
    @AssessorOfficeName_Clear bit = 0,
    @AssessorOfficeName nvarchar(150) = NULL,
    @AssessorMailingAddress_Clear bit = 0,
    @AssessorMailingAddress nvarchar(200) = NULL,
    @AssessorCity_Clear bit = 0,
    @AssessorCity nvarchar(60) = NULL,
    @AssessorZip_Clear bit = 0,
    @AssessorZip nvarchar(10) = NULL,
    @AssessorPhone_Clear bit = 0,
    @AssessorPhone nvarchar(30) = NULL,
    @AssessorWebsiteURL_Clear bit = 0,
    @AssessorWebsiteURL nvarchar(500) = NULL,
    @APRASubmissionMethod nvarchar(10) = NULL,
    @APRAPortalURL_Clear bit = 0,
    @APRAPortalURL nvarchar(500) = NULL,
    @APRAFormURL_Clear bit = 0,
    @APRAFormURL nvarchar(500) = NULL,
    @APRAPolicyURL_Clear bit = 0,
    @APRAPolicyURL nvarchar(500) = NULL,
    @APRAFeeNotes_Clear bit = 0,
    @APRAFeeNotes nvarchar(1000) = NULL,
    @ContactStatus nvarchar(15) = NULL,
    @ContactResearchedAt_Clear bit = 0,
    @ContactResearchedAt datetimeoffset = NULL,
    @Notes_Clear bit = 0,
    @Notes nvarchar(MAX) = NULL,
    @RollRequestSendAfter_Clear bit = 0,
    @RollRequestSendAfter date = NULL,
    @AppealListSendAfter_Clear bit = 0,
    @AppealListSendAfter date = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[County]
    SET
        [CountyNumber] = ISNULL(@CountyNumber, [CountyNumber]),
        [Name] = ISNULL(@Name, [Name]),
        [Slug] = ISNULL(@Slug, [Slug]),
        [FIPS] = CASE WHEN @FIPS_Clear = 1 THEN NULL ELSE ISNULL(@FIPS, [FIPS]) END,
        [AssessorOfficeName] = CASE WHEN @AssessorOfficeName_Clear = 1 THEN NULL ELSE ISNULL(@AssessorOfficeName, [AssessorOfficeName]) END,
        [AssessorMailingAddress] = CASE WHEN @AssessorMailingAddress_Clear = 1 THEN NULL ELSE ISNULL(@AssessorMailingAddress, [AssessorMailingAddress]) END,
        [AssessorCity] = CASE WHEN @AssessorCity_Clear = 1 THEN NULL ELSE ISNULL(@AssessorCity, [AssessorCity]) END,
        [AssessorZip] = CASE WHEN @AssessorZip_Clear = 1 THEN NULL ELSE ISNULL(@AssessorZip, [AssessorZip]) END,
        [AssessorPhone] = CASE WHEN @AssessorPhone_Clear = 1 THEN NULL ELSE ISNULL(@AssessorPhone, [AssessorPhone]) END,
        [AssessorWebsiteURL] = CASE WHEN @AssessorWebsiteURL_Clear = 1 THEN NULL ELSE ISNULL(@AssessorWebsiteURL, [AssessorWebsiteURL]) END,
        [APRASubmissionMethod] = ISNULL(@APRASubmissionMethod, [APRASubmissionMethod]),
        [APRAPortalURL] = CASE WHEN @APRAPortalURL_Clear = 1 THEN NULL ELSE ISNULL(@APRAPortalURL, [APRAPortalURL]) END,
        [APRAFormURL] = CASE WHEN @APRAFormURL_Clear = 1 THEN NULL ELSE ISNULL(@APRAFormURL, [APRAFormURL]) END,
        [APRAPolicyURL] = CASE WHEN @APRAPolicyURL_Clear = 1 THEN NULL ELSE ISNULL(@APRAPolicyURL, [APRAPolicyURL]) END,
        [APRAFeeNotes] = CASE WHEN @APRAFeeNotes_Clear = 1 THEN NULL ELSE ISNULL(@APRAFeeNotes, [APRAFeeNotes]) END,
        [ContactStatus] = ISNULL(@ContactStatus, [ContactStatus]),
        [ContactResearchedAt] = CASE WHEN @ContactResearchedAt_Clear = 1 THEN NULL ELSE ISNULL(@ContactResearchedAt, [ContactResearchedAt]) END,
        [Notes] = CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, [Notes]) END,
        [RollRequestSendAfter] = CASE WHEN @RollRequestSendAfter_Clear = 1 THEN NULL ELSE ISNULL(@RollRequestSendAfter, [RollRequestSendAfter]) END,
        [AppealListSendAfter] = CASE WHEN @AppealListSendAfter_Clear = 1 THEN NULL ELSE ISNULL(@AppealListSendAfter, [AppealListSendAfter]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwCounties] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwCounties]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateCounty] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the County table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateCounty]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateCounty];
GO
CREATE TRIGGER [indiana_tax].trgUpdateCounty
ON [indiana_tax].[County]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[County]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[County] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for Counties */

GRANT EXECUTE ON [indiana_tax].[spUpdateCounty] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for Counties */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Counties
-- Item: spDeleteCounty
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR County
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteCounty]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteCounty];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteCounty]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[County]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteCounty] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for Counties */

GRANT EXECUTE ON [indiana_tax].[spDeleteCounty] TO [cdp_Developer], [cdp_Integration];

/* Set field properties for entity */

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '93147B7B-502A-457C-9044-7925240F0E9E'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '20C8098A-19D8-4629-8BC9-28B3D171F5FE'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '2C88DFA2-FD94-4834-B50F-9F08F55D2739'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'DEBBBCFB-5652-40F1-B562-20ADB6B309EB'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '20C8098A-19D8-4629-8BC9-28B3D171F5FE'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = 'F7718E18-9B6B-496B-963F-F9C6E833D4AE'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = '2A56C917-49F3-49C8-A41E-96DB7CDA33F1'
               AND AutoUpdateUserSearchPredicate = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = '20C8098A-19D8-4629-8BC9-28B3D171F5FE'
               AND AutoUpdateUserSearchPredicate = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = 'F7718E18-9B6B-496B-963F-F9C6E833D4AE'
               AND AutoUpdateUserSearchPredicate = 1;

/* Set field properties for entity */

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IsNameField = 1
               WHERE ID = 'BFCF6F12-56E9-4D64-88E6-F69754591B63'
               AND AutoUpdateIsNameField = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'BFCF6F12-56E9-4D64-88E6-F69754591B63'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '72A3CD83-8786-491C-A62F-F7F4F30DDC5E'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '70351EDA-CE23-4CAF-8624-7D3AE989AE4A'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = '53B1608B-BF86-4903-ADD7-E45585C5AC57'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'DF8AFD43-2F4C-43C4-A32D-22DF19A0FE1A'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET DefaultInView = 1
               WHERE ID = 'A5D4B7A2-B07E-42DF-986E-32A0D5B0F052'
               AND AutoUpdateDefaultInView = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = 'BFCF6F12-56E9-4D64-88E6-F69754591B63'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = '72A3CD83-8786-491C-A62F-F7F4F30DDC5E'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = 'A4FE7C3A-1468-4116-8A53-A14751D892F2'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET IncludeInUserSearchAPI = 1
               WHERE ID = 'A5D4B7A2-B07E-42DF-986E-32A0D5B0F052'
               AND AutoUpdateIncludeInUserSearchAPI = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = 'BFCF6F12-56E9-4D64-88E6-F69754591B63'
               AND AutoUpdateUserSearchPredicate = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = 'A5D4B7A2-B07E-42DF-986E-32A0D5B0F052'
               AND AutoUpdateUserSearchPredicate = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'BeginsWith'
               WHERE ID = '72A3CD83-8786-491C-A62F-F7F4F30DDC5E'
               AND AutoUpdateUserSearchPredicate = 1;

               UPDATE [${flyway:defaultSchema}].[EntityField]
               SET UserSearchPredicateAPI = 'Exact'
               WHERE ID = 'A4FE7C3A-1468-4116-8A53-A14751D892F2'
               AND AutoUpdateUserSearchPredicate = 1;

/* Set categories for 23 fields */

-- UPDATE Entity Field Category Info Counties.ID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'County Identification',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '673844BA-2961-42CD-ABB2-EF5672F15B1A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Counties.CountyNumber 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'County Identification',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '93147B7B-502A-457C-9044-7925240F0E9E' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Counties.Name 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'County Identification',
   GeneratedFormSection = 'Category',
   DisplayName = 'County Name',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '2A56C917-49F3-49C8-A41E-96DB7CDA33F1' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Counties.Slug 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'County Identification',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '899B6446-D37E-4641-B49B-9E9CF1693C8A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Counties.FIPS 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'County Identification',
   GeneratedFormSection = 'Category',
   DisplayName = 'FIPS Code',
   ExtendedType = 'Code',
   CodeType = 'Other'
WHERE 
   ID = '19274087-6F79-4144-9522-16402A12DE3A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Counties.AssessorOfficeName 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessor Office Information',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '20C8098A-19D8-4629-8BC9-28B3D171F5FE' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Counties.AssessorMailingAddress 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessor Office Information',
   GeneratedFormSection = 'Category',
   ExtendedType = 'GeoAddress',
   CodeType = NULL
WHERE 
   ID = 'E02EE045-A3C1-48E9-999D-925EF9FF5457' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Counties.AssessorCity 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessor Office Information',
   GeneratedFormSection = 'Category',
   ExtendedType = 'GeoCity',
   CodeType = NULL
WHERE 
   ID = 'F7718E18-9B6B-496B-963F-F9C6E833D4AE' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Counties.AssessorZip 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessor Office Information',
   GeneratedFormSection = 'Category',
   DisplayName = 'Assessor ZIP Code',
   ExtendedType = 'GeoPostalCode',
   CodeType = NULL
WHERE 
   ID = 'E661562F-A13E-4553-98F5-3E839636A561' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Counties.AssessorPhone 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessor Office Information',
   GeneratedFormSection = 'Category',
   ExtendedType = 'Tel',
   CodeType = NULL
WHERE 
   ID = '499A900C-1DA4-4E54-9090-6CA4A751AF4D' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Counties.AssessorWebsiteURL 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Assessor Office Information',
   GeneratedFormSection = 'Category',
   DisplayName = 'Assessor Website',
   ExtendedType = 'URL',
   CodeType = NULL
WHERE 
   ID = 'F78C0BA1-18A8-4630-AD76-B637C232A48C' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Counties.APRASubmissionMethod 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Public Records Request Method',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '2C88DFA2-FD94-4834-B50F-9F08F55D2739' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Counties.APRAPortalURL 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Public Records Request Method',
   GeneratedFormSection = 'Category',
   ExtendedType = 'URL',
   CodeType = NULL
WHERE 
   ID = 'B589C01D-0D10-41ED-8586-23C8A5474ED3' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Counties.APRAFormURL 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Public Records Request Method',
   GeneratedFormSection = 'Category',
   ExtendedType = 'URL',
   CodeType = NULL
WHERE 
   ID = 'B59DC796-A518-4F4A-AFFC-2038CFF7ACD6' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Counties.APRAPolicyURL 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Public Records Request Method',
   GeneratedFormSection = 'Category',
   ExtendedType = 'URL',
   CodeType = NULL
WHERE 
   ID = 'DB869BA8-DDDE-454B-B56B-0690F171457A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Counties.APRAFeeNotes 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Public Records Request Method',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '6D62C52D-E3BC-4B07-8EBA-BE73C1AE44A3' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Counties.ContactStatus 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Research and Contact Status',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'DEBBBCFB-5652-40F1-B562-20ADB6B309EB' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Counties.ContactResearchedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Research and Contact Status',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '7127FFAB-72BE-4E77-911A-A6A799FA142E' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Counties.Notes 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Research and Contact Status',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '3091FC39-61E3-4802-9D1C-C28DAD368007' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Counties.RollRequestSendAfter 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Request Scheduling',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '802BE932-963A-4805-9D73-95464C7BDDCF' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Counties.AppealListSendAfter 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Request Scheduling',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'E7B7ACD9-4821-46C3-A512-F494EDA9A6A9' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Counties.__mj_CreatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'C7153883-59AC-420A-9FA7-C6A3C5D78817' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info Counties.__mj_UpdatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '236BD00A-AE4A-4038-88BB-3EAF364C889F' AND AutoUpdateCategory = 1;

/* Set SupportsGeoCoding = true for Counties */

            UPDATE [${flyway:defaultSchema}].[Entity]
            SET [SupportsGeoCoding] = 1
            WHERE [ID] = '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A' AND [AutoUpdateSupportsGeoCoding] = 1;

/* Set entity icon to fa fa-map */

               UPDATE [${flyway:defaultSchema}].[Entity]
               SET [Icon] = 'fa fa-map', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A';

/* Insert FieldCategoryInfo setting for entity */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('0411dfd1-e73f-4919-9e13-87c693b1fdda', '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A', 'FieldCategoryInfo', '{"County Identification":{"icon":"fa fa-map-marker-alt","description":"County identifiers including name, number, slug, and federal FIPS code"},"Assessor Office Information":{"icon":"fa fa-building","description":"Contact details for the county assessor office including address, phone, and website"},"Public Records Request Method":{"icon":"fa fa-file-alt","description":"How to submit Access to Public Records Act requests and associated fee information"},"Research and Contact Status":{"icon":"fa fa-search","description":"Status of research efforts, research timestamps, and research notes about the county"},"Request Scheduling":{"icon":"fa fa-calendar","description":"Operational calendar dates for when requests should be sent to the county"},"System Metadata":{"icon":"fa fa-cog","description":"System-managed audit and tracking fields"}}', GETUTCDATE(), GETUTCDATE());

/* Insert FieldCategoryIcons setting (legacy) */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('437a4447-c9c1-41f8-99e1-9febd612c322', '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A', 'FieldCategoryIcons', '{"County Identification":"fa fa-map-marker-alt","Assessor Office Information":"fa fa-building","Public Records Request Method":"fa fa-file-alt","Research and Contact Status":"fa fa-search","Request Scheduling":"fa fa-calendar","System Metadata":"fa fa-cog"}', GETUTCDATE(), GETUTCDATE());

/* Set categories for 45 fields */

-- UPDATE Entity Field Category Info APRA Requests.ID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Request Identification',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '570269FA-4AA9-4ECE-BDE3-FAF2EB003C06' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.CountyID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Request Identification',
   GeneratedFormSection = 'Category',
   DisplayName = 'County',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'A507C62A-80A6-4E33-B285-C2ED906BD1FE' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.CountyContactID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Request Identification',
   GeneratedFormSection = 'Category',
   DisplayName = 'County Contact',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '53CB312C-8A06-4E46-AFFC-A9285E53E8F3' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.RequestNumber 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Request Identification',
   GeneratedFormSection = 'Category',
   ExtendedType = 'Code',
   CodeType = 'Other'
WHERE 
   ID = 'BFCF6F12-56E9-4D64-88E6-F69754591B63' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.RequestKind 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Request Identification',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '72A3CD83-8786-491C-A62F-F7F4F30DDC5E' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.AssessmentYear 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Request Identification',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '70351EDA-CE23-4CAF-8624-7D3AE989AE4A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.Status 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Request Status',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '53B1608B-BF86-4903-ADD7-E45585C5AC57' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.TemplateID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Letter Composition',
   GeneratedFormSection = 'Category',
   DisplayName = 'Template',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'A3317006-C099-4914-8144-C6561A3C5DD7' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.Subject 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Letter Composition',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '11934B3D-A738-4FD5-A575-4C92DD740B34' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.RenderedBody 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Letter Composition',
   GeneratedFormSection = 'Category',
   ExtendedType = 'Code',
   CodeType = 'HTML'
WHERE 
   ID = '013DC7E4-99DD-4A1D-ACA1-4FA93206CE6E' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.SubmissionMethod 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Submission Details',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '7FCA719A-3776-4B93-B6A2-385FDDF9649B' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.ToAddress 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Submission Details',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '31802CC9-CA5F-498E-AB8C-D8949D8A91B7' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.CcAddress 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Submission Details',
   GeneratedFormSection = 'Category',
   DisplayName = 'CC Address',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '42C9C122-9B71-49D3-AFD6-99BF28B76340' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.DraftedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Request Timeline',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'E17066C0-9BB8-4B03-B574-CA28918F0464' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.ApprovedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Request Timeline',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '41B43CE5-DC08-4DC5-8CA1-E61408122E5E' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.SentAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Request Timeline',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'DF8AFD43-2F4C-43C4-A32D-22DF19A0FE1A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.MailedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Request Timeline',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'B1A5FC87-EFFB-4976-8F8A-D04B4994B5C6' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.ReceivedByAgencyAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Request Timeline',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '5A473142-351B-4783-A709-24E1E1058560' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.ReceivedByAgencyIsEstimate 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Request Timeline',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '95D72160-CD24-4267-94B2-B875D8D1633D' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.StatutoryResponseDueAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Request Timeline',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '8C0DDF4F-C437-4215-888B-0348FCB80A05' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.AcknowledgedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'County Response Timeline',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '6D5D411E-5A09-4C8C-BA15-E4C35255A830' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.FeeQuoted 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'County Response Timeline',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '10FF47F9-6B9A-4CC1-B178-406B270BDB90' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.FeePaid 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'County Response Timeline',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'E6268744-F556-4DE0-B928-773E595FEFF7' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.FeePaidAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'County Response Timeline',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'DFD2E1CC-FE72-428E-B64F-3F3920834A6E' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.FulfilledAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'County Response Timeline',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '05214CE1-D155-430D-BFCE-0DAA69EF05FA' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.DeniedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'County Response Timeline',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'F2509AC0-433A-49D0-A749-F0B331A808FC' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.DenialReason 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'County Response Timeline',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '98715D33-5804-491D-A2ED-BAF1553A9C27' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.PACComplaintFiledAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Public Access Counselor',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'E90635AF-9F3E-4F36-9F93-DF1223C58CDD' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.PACComplaintNumber 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Public Access Counselor',
   GeneratedFormSection = 'Category',
   ExtendedType = 'Code',
   CodeType = 'Other'
WHERE 
   ID = 'A4FE7C3A-1468-4116-8A53-A14751D892F2' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.PACOpinionAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Public Access Counselor',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '61714A4F-E2A0-4103-AB41-60BF05A0F2B4' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.PACOpinionURL 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Public Access Counselor',
   GeneratedFormSection = 'Category',
   ExtendedType = 'URL',
   CodeType = NULL
WHERE 
   ID = 'F4F678CC-1FD6-4307-AEF0-4F028436CC9F' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.ProviderMessageID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Communication Tracking',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '6C0FC45B-6185-45B4-8CBA-BF9970755FE3' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.ProviderThreadID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Communication Tracking',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '7348D551-5F90-4570-903E-F3AAC7D9EB9B' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.CommunicationLogID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Communication Tracking',
   GeneratedFormSection = 'Category',
   DisplayName = 'Communication Log',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '9F88F765-A627-4335-BE62-3ED58129038E' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.RequestSourceDocumentID 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Communication Tracking',
   GeneratedFormSection = 'Category',
   DisplayName = 'Request Source Document',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'ADE66AB1-D3A9-430C-A614-AAB9C69D6A5A' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.MailTrackingNumber 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Communication Tracking',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '7228CD9C-A403-4A7E-ABCB-937515C4591E' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.NextActionAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Request Management',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '057ADEA5-F68C-4435-80E9-A3D186DC23D1' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.NextActionNote 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Request Management',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '857FFDB2-1DF9-4B9E-B778-3FAC31298F76' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.Notes 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Request Management',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'AEC79B78-1B28-4D05-9023-F91C270C3D5C' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.County 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Request Identification',
   GeneratedFormSection = 'Category',
   DisplayName = 'County Name',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'A5D4B7A2-B07E-42DF-986E-32A0D5B0F052' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.CountyContact 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Request Identification',
   GeneratedFormSection = 'Category',
   DisplayName = 'County Contact Name',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '543AAC8B-99ED-4C16-9E1B-8BE6AEF4F72E' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.Template 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Letter Composition',
   GeneratedFormSection = 'Category',
   DisplayName = 'Template Name',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'DB54DDA5-736F-4A41-A04D-0E099E80B070' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.CommunicationLog 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'Communication Tracking',
   GeneratedFormSection = 'Category',
   DisplayName = 'Communication Log Timestamp',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '3BEDA3B0-16B7-4F56-9C32-389F2EE860BC' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.__mj_CreatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = '6F99C1A0-A4B6-474E-8F6D-0CF43070A8F8' AND AutoUpdateCategory = 1;

-- UPDATE Entity Field Category Info APRA Requests.__mj_UpdatedAt 
UPDATE [${flyway:defaultSchema}].[EntityField]
SET 
   Category = 'System Metadata',
   GeneratedFormSection = 'Category',
   ExtendedType = NULL,
   CodeType = NULL
WHERE 
   ID = 'EA6D6824-AB74-4389-99AA-ACD5F922CC1F' AND AutoUpdateCategory = 1;

/* Set entity icon to fa fa-file-alt */

               UPDATE [${flyway:defaultSchema}].[Entity]
               SET [Icon] = 'fa fa-file-alt', [__mj_UpdatedAt] = GETUTCDATE()
               WHERE [ID] = '74C28031-4BAE-4D51-B67B-669793A0DF7A';

/* Insert FieldCategoryInfo setting for entity */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('6e584910-2c95-4cf3-99d3-7c5b8118cdc2', '74C28031-4BAE-4D51-B67B-669793A0DF7A', 'FieldCategoryInfo', '{"Request Identification":{"icon":"fa fa-barcode","description":"Core request identification including request number, kind, assessment year, and county"},"Request Status":{"icon":"fa fa-flag","description":"Current lifecycle status of the APRA request (derived from latest event)"},"Letter Composition":{"icon":"fa fa-envelope","description":"The rendered letter template, subject, and HTML body sent to the county"},"Submission Details":{"icon":"fa fa-paper-plane","description":"How and where the request was sent (method, recipient addresses)"},"Request Timeline":{"icon":"fa fa-calendar-alt","description":"Key dates in the outgoing request lifecycle from draft through delivery"},"County Response Timeline":{"icon":"fa fa-hourglass-end","description":"Dates and amounts related to county''s response including fees and fulfillment"},"Public Access Counselor":{"icon":"fa fa-gavel","description":"Escalation information for PAC complaints and advisory opinions"},"Communication Tracking":{"icon":"fa fa-comments","description":"Mail provider IDs, thread tracking, and archived communication references"},"Request Management":{"icon":"fa fa-tasks","description":"Follow-up actions, due dates, and free-form notes"},"System Metadata":{"icon":"fa fa-cog","description":"System-managed audit and tracking timestamps"}}', GETUTCDATE(), GETUTCDATE());

/* Insert FieldCategoryIcons setting (legacy) */

               INSERT INTO [${flyway:defaultSchema}].[EntitySetting] ([ID], [EntityID], [Name], [Value], [__mj_CreatedAt], [__mj_UpdatedAt])
               VALUES ('40b8da1e-5e99-40f7-b503-f25db9e3d717', '74C28031-4BAE-4D51-B67B-669793A0DF7A', 'FieldCategoryIcons', '{"Request Identification":"fa fa-barcode","Request Status":"fa fa-flag","Letter Composition":"fa fa-envelope","Submission Details":"fa fa-paper-plane","Request Timeline":"fa fa-calendar-alt","County Response Timeline":"fa fa-hourglass-end","Public Access Counselor":"fa fa-gavel","Communication Tracking":"fa fa-comments","Request Management":"fa fa-tasks","System Metadata":"fa fa-cog"}', GETUTCDATE(), GETUTCDATE());

/* Index for Foreign Keys for County */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Counties
-- Item: Index for Foreign Keys
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------;

/* Base View SQL for Counties */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Counties
-- Item: vwCounties
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- BASE VIEW FOR ENTITY:      Counties
-----               SCHEMA:      indiana_tax
-----               BASE TABLE:  County
-----               PRIMARY KEY: ID
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[vwCounties]', 'V') IS NOT NULL
    DROP VIEW [indiana_tax].[vwCounties];
GO

CREATE VIEW [indiana_tax].[vwCounties]
AS
SELECT
    c.*,    ${flyway:defaultSchema}_rgc.[Latitude] AS [${flyway:defaultSchema}_Latitude],
    ${flyway:defaultSchema}_rgc.[Longitude] AS [${flyway:defaultSchema}_Longitude]
FROM
    [indiana_tax].[County] AS c
LEFT OUTER JOIN
    [${flyway:defaultSchema}].[vwRecordGeoCodes] AS ${flyway:defaultSchema}_rgc
  ON
    ${flyway:defaultSchema}_rgc.[EntityID] = '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A'
    AND ${flyway:defaultSchema}_rgc.[RecordID] = CAST([c].[ID] AS NVARCHAR(450))
    AND ${flyway:defaultSchema}_rgc.[LocationType] = 'Primary'
GO
GRANT SELECT ON [indiana_tax].[vwCounties] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* Base View Permissions SQL for Counties */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Counties
-- Item: Permissions for vwCounties
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

GRANT SELECT ON [indiana_tax].[vwCounties] TO [cdp_UI], [cdp_Developer], [cdp_Integration];

/* spCreate SQL for Counties */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Counties
-- Item: spCreateCounty
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- CREATE PROCEDURE FOR County
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spCreateCounty]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spCreateCounty];
GO

CREATE PROCEDURE [indiana_tax].[spCreateCounty]
    @ID uniqueidentifier = NULL,
    @CountyNumber smallint,
    @Name nvarchar(50),
    @Slug nvarchar(30),
    @FIPS_Clear bit = 0,
    @FIPS char(5) = NULL,
    @AssessorOfficeName_Clear bit = 0,
    @AssessorOfficeName nvarchar(150) = NULL,
    @AssessorMailingAddress_Clear bit = 0,
    @AssessorMailingAddress nvarchar(200) = NULL,
    @AssessorCity_Clear bit = 0,
    @AssessorCity nvarchar(60) = NULL,
    @AssessorZip_Clear bit = 0,
    @AssessorZip nvarchar(10) = NULL,
    @AssessorPhone_Clear bit = 0,
    @AssessorPhone nvarchar(30) = NULL,
    @AssessorWebsiteURL_Clear bit = 0,
    @AssessorWebsiteURL nvarchar(500) = NULL,
    @APRASubmissionMethod nvarchar(10) = NULL,
    @APRAPortalURL_Clear bit = 0,
    @APRAPortalURL nvarchar(500) = NULL,
    @APRAFormURL_Clear bit = 0,
    @APRAFormURL nvarchar(500) = NULL,
    @APRAPolicyURL_Clear bit = 0,
    @APRAPolicyURL nvarchar(500) = NULL,
    @APRAFeeNotes_Clear bit = 0,
    @APRAFeeNotes nvarchar(1000) = NULL,
    @ContactStatus nvarchar(15) = NULL,
    @ContactResearchedAt_Clear bit = 0,
    @ContactResearchedAt datetimeoffset = NULL,
    @Notes_Clear bit = 0,
    @Notes nvarchar(MAX) = NULL,
    @RollRequestSendAfter_Clear bit = 0,
    @RollRequestSendAfter date = NULL,
    @AppealListSendAfter_Clear bit = 0,
    @AppealListSendAfter date = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertedRow TABLE ([ID] UNIQUEIDENTIFIER)

    IF @ID IS NOT NULL
    BEGIN
        -- User provided a value, use it
        INSERT INTO [indiana_tax].[County]
            (
                [ID],
                [CountyNumber],
                [Name],
                [Slug],
                [FIPS],
                [AssessorOfficeName],
                [AssessorMailingAddress],
                [AssessorCity],
                [AssessorZip],
                [AssessorPhone],
                [AssessorWebsiteURL],
                [APRASubmissionMethod],
                [APRAPortalURL],
                [APRAFormURL],
                [APRAPolicyURL],
                [APRAFeeNotes],
                [ContactStatus],
                [ContactResearchedAt],
                [Notes],
                [RollRequestSendAfter],
                [AppealListSendAfter]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @ID,
                @CountyNumber,
                @Name,
                @Slug,
                CASE WHEN @FIPS_Clear = 1 THEN NULL ELSE ISNULL(@FIPS, NULL) END,
                CASE WHEN @AssessorOfficeName_Clear = 1 THEN NULL ELSE ISNULL(@AssessorOfficeName, NULL) END,
                CASE WHEN @AssessorMailingAddress_Clear = 1 THEN NULL ELSE ISNULL(@AssessorMailingAddress, NULL) END,
                CASE WHEN @AssessorCity_Clear = 1 THEN NULL ELSE ISNULL(@AssessorCity, NULL) END,
                CASE WHEN @AssessorZip_Clear = 1 THEN NULL ELSE ISNULL(@AssessorZip, NULL) END,
                CASE WHEN @AssessorPhone_Clear = 1 THEN NULL ELSE ISNULL(@AssessorPhone, NULL) END,
                CASE WHEN @AssessorWebsiteURL_Clear = 1 THEN NULL ELSE ISNULL(@AssessorWebsiteURL, NULL) END,
                ISNULL(@APRASubmissionMethod, 'Unknown'),
                CASE WHEN @APRAPortalURL_Clear = 1 THEN NULL ELSE ISNULL(@APRAPortalURL, NULL) END,
                CASE WHEN @APRAFormURL_Clear = 1 THEN NULL ELSE ISNULL(@APRAFormURL, NULL) END,
                CASE WHEN @APRAPolicyURL_Clear = 1 THEN NULL ELSE ISNULL(@APRAPolicyURL, NULL) END,
                CASE WHEN @APRAFeeNotes_Clear = 1 THEN NULL ELSE ISNULL(@APRAFeeNotes, NULL) END,
                ISNULL(@ContactStatus, 'Unresearched'),
                CASE WHEN @ContactResearchedAt_Clear = 1 THEN NULL ELSE ISNULL(@ContactResearchedAt, NULL) END,
                CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, NULL) END,
                CASE WHEN @RollRequestSendAfter_Clear = 1 THEN NULL ELSE ISNULL(@RollRequestSendAfter, NULL) END,
                CASE WHEN @AppealListSendAfter_Clear = 1 THEN NULL ELSE ISNULL(@AppealListSendAfter, NULL) END
            )
    END
    ELSE
    BEGIN
        -- No value provided, let database use its default (e.g., NEWSEQUENTIALID())
        INSERT INTO [indiana_tax].[County]
            (
                [CountyNumber],
                [Name],
                [Slug],
                [FIPS],
                [AssessorOfficeName],
                [AssessorMailingAddress],
                [AssessorCity],
                [AssessorZip],
                [AssessorPhone],
                [AssessorWebsiteURL],
                [APRASubmissionMethod],
                [APRAPortalURL],
                [APRAFormURL],
                [APRAPolicyURL],
                [APRAFeeNotes],
                [ContactStatus],
                [ContactResearchedAt],
                [Notes],
                [RollRequestSendAfter],
                [AppealListSendAfter]
            )
        OUTPUT INSERTED.[ID] INTO @InsertedRow
        VALUES
            (
                @CountyNumber,
                @Name,
                @Slug,
                CASE WHEN @FIPS_Clear = 1 THEN NULL ELSE ISNULL(@FIPS, NULL) END,
                CASE WHEN @AssessorOfficeName_Clear = 1 THEN NULL ELSE ISNULL(@AssessorOfficeName, NULL) END,
                CASE WHEN @AssessorMailingAddress_Clear = 1 THEN NULL ELSE ISNULL(@AssessorMailingAddress, NULL) END,
                CASE WHEN @AssessorCity_Clear = 1 THEN NULL ELSE ISNULL(@AssessorCity, NULL) END,
                CASE WHEN @AssessorZip_Clear = 1 THEN NULL ELSE ISNULL(@AssessorZip, NULL) END,
                CASE WHEN @AssessorPhone_Clear = 1 THEN NULL ELSE ISNULL(@AssessorPhone, NULL) END,
                CASE WHEN @AssessorWebsiteURL_Clear = 1 THEN NULL ELSE ISNULL(@AssessorWebsiteURL, NULL) END,
                ISNULL(@APRASubmissionMethod, 'Unknown'),
                CASE WHEN @APRAPortalURL_Clear = 1 THEN NULL ELSE ISNULL(@APRAPortalURL, NULL) END,
                CASE WHEN @APRAFormURL_Clear = 1 THEN NULL ELSE ISNULL(@APRAFormURL, NULL) END,
                CASE WHEN @APRAPolicyURL_Clear = 1 THEN NULL ELSE ISNULL(@APRAPolicyURL, NULL) END,
                CASE WHEN @APRAFeeNotes_Clear = 1 THEN NULL ELSE ISNULL(@APRAFeeNotes, NULL) END,
                ISNULL(@ContactStatus, 'Unresearched'),
                CASE WHEN @ContactResearchedAt_Clear = 1 THEN NULL ELSE ISNULL(@ContactResearchedAt, NULL) END,
                CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, NULL) END,
                CASE WHEN @RollRequestSendAfter_Clear = 1 THEN NULL ELSE ISNULL(@RollRequestSendAfter, NULL) END,
                CASE WHEN @AppealListSendAfter_Clear = 1 THEN NULL ELSE ISNULL(@AppealListSendAfter, NULL) END
            )
    END
    -- return the new record from the base view, which might have some calculated fields
    SELECT * FROM [indiana_tax].[vwCounties] WHERE [ID] = (SELECT [ID] FROM @InsertedRow)
END
GO
GRANT EXECUTE ON [indiana_tax].[spCreateCounty] TO [cdp_Developer], [cdp_Integration];

/* spCreate Permissions for Counties */

GRANT EXECUTE ON [indiana_tax].[spCreateCounty] TO [cdp_Developer], [cdp_Integration];

/* spUpdate SQL for Counties */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Counties
-- Item: spUpdateCounty
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- UPDATE PROCEDURE FOR County
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spUpdateCounty]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spUpdateCounty];
GO

CREATE PROCEDURE [indiana_tax].[spUpdateCounty]
    @ID uniqueidentifier,
    @CountyNumber smallint = NULL,
    @Name nvarchar(50) = NULL,
    @Slug nvarchar(30) = NULL,
    @FIPS_Clear bit = 0,
    @FIPS char(5) = NULL,
    @AssessorOfficeName_Clear bit = 0,
    @AssessorOfficeName nvarchar(150) = NULL,
    @AssessorMailingAddress_Clear bit = 0,
    @AssessorMailingAddress nvarchar(200) = NULL,
    @AssessorCity_Clear bit = 0,
    @AssessorCity nvarchar(60) = NULL,
    @AssessorZip_Clear bit = 0,
    @AssessorZip nvarchar(10) = NULL,
    @AssessorPhone_Clear bit = 0,
    @AssessorPhone nvarchar(30) = NULL,
    @AssessorWebsiteURL_Clear bit = 0,
    @AssessorWebsiteURL nvarchar(500) = NULL,
    @APRASubmissionMethod nvarchar(10) = NULL,
    @APRAPortalURL_Clear bit = 0,
    @APRAPortalURL nvarchar(500) = NULL,
    @APRAFormURL_Clear bit = 0,
    @APRAFormURL nvarchar(500) = NULL,
    @APRAPolicyURL_Clear bit = 0,
    @APRAPolicyURL nvarchar(500) = NULL,
    @APRAFeeNotes_Clear bit = 0,
    @APRAFeeNotes nvarchar(1000) = NULL,
    @ContactStatus nvarchar(15) = NULL,
    @ContactResearchedAt_Clear bit = 0,
    @ContactResearchedAt datetimeoffset = NULL,
    @Notes_Clear bit = 0,
    @Notes nvarchar(MAX) = NULL,
    @RollRequestSendAfter_Clear bit = 0,
    @RollRequestSendAfter date = NULL,
    @AppealListSendAfter_Clear bit = 0,
    @AppealListSendAfter date = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[County]
    SET
        [CountyNumber] = ISNULL(@CountyNumber, [CountyNumber]),
        [Name] = ISNULL(@Name, [Name]),
        [Slug] = ISNULL(@Slug, [Slug]),
        [FIPS] = CASE WHEN @FIPS_Clear = 1 THEN NULL ELSE ISNULL(@FIPS, [FIPS]) END,
        [AssessorOfficeName] = CASE WHEN @AssessorOfficeName_Clear = 1 THEN NULL ELSE ISNULL(@AssessorOfficeName, [AssessorOfficeName]) END,
        [AssessorMailingAddress] = CASE WHEN @AssessorMailingAddress_Clear = 1 THEN NULL ELSE ISNULL(@AssessorMailingAddress, [AssessorMailingAddress]) END,
        [AssessorCity] = CASE WHEN @AssessorCity_Clear = 1 THEN NULL ELSE ISNULL(@AssessorCity, [AssessorCity]) END,
        [AssessorZip] = CASE WHEN @AssessorZip_Clear = 1 THEN NULL ELSE ISNULL(@AssessorZip, [AssessorZip]) END,
        [AssessorPhone] = CASE WHEN @AssessorPhone_Clear = 1 THEN NULL ELSE ISNULL(@AssessorPhone, [AssessorPhone]) END,
        [AssessorWebsiteURL] = CASE WHEN @AssessorWebsiteURL_Clear = 1 THEN NULL ELSE ISNULL(@AssessorWebsiteURL, [AssessorWebsiteURL]) END,
        [APRASubmissionMethod] = ISNULL(@APRASubmissionMethod, [APRASubmissionMethod]),
        [APRAPortalURL] = CASE WHEN @APRAPortalURL_Clear = 1 THEN NULL ELSE ISNULL(@APRAPortalURL, [APRAPortalURL]) END,
        [APRAFormURL] = CASE WHEN @APRAFormURL_Clear = 1 THEN NULL ELSE ISNULL(@APRAFormURL, [APRAFormURL]) END,
        [APRAPolicyURL] = CASE WHEN @APRAPolicyURL_Clear = 1 THEN NULL ELSE ISNULL(@APRAPolicyURL, [APRAPolicyURL]) END,
        [APRAFeeNotes] = CASE WHEN @APRAFeeNotes_Clear = 1 THEN NULL ELSE ISNULL(@APRAFeeNotes, [APRAFeeNotes]) END,
        [ContactStatus] = ISNULL(@ContactStatus, [ContactStatus]),
        [ContactResearchedAt] = CASE WHEN @ContactResearchedAt_Clear = 1 THEN NULL ELSE ISNULL(@ContactResearchedAt, [ContactResearchedAt]) END,
        [Notes] = CASE WHEN @Notes_Clear = 1 THEN NULL ELSE ISNULL(@Notes, [Notes]) END,
        [RollRequestSendAfter] = CASE WHEN @RollRequestSendAfter_Clear = 1 THEN NULL ELSE ISNULL(@RollRequestSendAfter, [RollRequestSendAfter]) END,
        [AppealListSendAfter] = CASE WHEN @AppealListSendAfter_Clear = 1 THEN NULL ELSE ISNULL(@AppealListSendAfter, [AppealListSendAfter]) END
    WHERE
        [ID] = @ID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
        -- Nothing was updated, return no rows, but column structure from base view intact, semantically correct this way.
        SELECT TOP 0 * FROM [indiana_tax].[vwCounties] WHERE 1=0
    ELSE
        -- Return the updated record so the caller can see the updated values and any calculated fields
        SELECT
                                        *
                                    FROM
                                        [indiana_tax].[vwCounties]
                                    WHERE
                                        [ID] = @ID
                                    
END
GO

GRANT EXECUTE ON [indiana_tax].[spUpdateCounty] TO [cdp_Developer], [cdp_Integration]
GO

------------------------------------------------------------
----- TRIGGER FOR __mj_UpdatedAt field for the County table
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[trgUpdateCounty]', 'TR') IS NOT NULL
    DROP TRIGGER [indiana_tax].[trgUpdateCounty];
GO
CREATE TRIGGER [indiana_tax].trgUpdateCounty
ON [indiana_tax].[County]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE
        [indiana_tax].[County]
    SET
        __mj_UpdatedAt = GETUTCDATE()
    FROM
        [indiana_tax].[County] AS _organicTable
    INNER JOIN
        INSERTED AS I ON
        _organicTable.[ID] = I.[ID];
END;
GO

/* spUpdate Permissions for Counties */

GRANT EXECUTE ON [indiana_tax].[spUpdateCounty] TO [cdp_Developer], [cdp_Integration];

/* spDelete SQL for Counties */
-----------------------------------------------------------------
-- SQL Code Generation
-- Entity: Counties
-- Item: spDeleteCounty
--
-- This was generated by the MemberJunction CodeGen tool.
-- This file should NOT be edited by hand.
-----------------------------------------------------------------

------------------------------------------------------------
----- DELETE PROCEDURE FOR County
------------------------------------------------------------
IF OBJECT_ID('[indiana_tax].[spDeleteCounty]', 'P') IS NOT NULL
    DROP PROCEDURE [indiana_tax].[spDeleteCounty];
GO

CREATE PROCEDURE [indiana_tax].[spDeleteCounty]
    @ID uniqueidentifier
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM
        [indiana_tax].[County]
    WHERE
        [ID] = @ID


    -- Check if the delete was successful
    IF @@ROWCOUNT = 0
        SELECT NULL AS [ID] -- Return NULL for all primary key fields to indicate no record was deleted
    ELSE
        SELECT @ID AS [ID] -- Return the primary key values to indicate we successfully deleted the record
END
GO
GRANT EXECUTE ON [indiana_tax].[spDeleteCounty] TO [cdp_Developer], [cdp_Integration];

/* spDelete Permissions for Counties */

GRANT EXECUTE ON [indiana_tax].[spDeleteCounty] TO [cdp_Developer], [cdp_Integration];

/* SQL text to insert 2 new entity field(s) */

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = '88c9282b-b8da-40fa-8dfe-27688a801d65' OR (EntityID = '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A' AND Name = '${flyway:defaultSchema}_Latitude')) BEGIN
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
            '88c9282b-b8da-40fa-8dfe-27688a801d65',
            '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A', -- Entity: Counties
            100047,
            '${flyway:defaultSchema}_Latitude',
            'Mj Latitude',
            NULL,
            'decimal',
            9,
            10,
            6,
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

      IF NOT EXISTS (SELECT 1 FROM [${flyway:defaultSchema}].[EntityField] WHERE ID = 'e520ebb0-fada-4e8b-9e4b-fc41c3d64d8d' OR (EntityID = '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A' AND Name = '${flyway:defaultSchema}_Longitude')) BEGIN
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
            'e520ebb0-fada-4e8b-9e4b-fc41c3d64d8d',
            '31BA7A7D-B40B-42BA-A35C-7CAC63166E1A', -- Entity: Counties
            100048,
            '${flyway:defaultSchema}_Longitude',
            'Mj Longitude',
            NULL,
            'decimal',
            9,
            10,
            6,
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

/* Set ExtendedType=GeoLatitude on virtual geo fields */
UPDATE [${flyway:defaultSchema}].[EntityField] SET [ExtendedType] = 'GeoLatitude' WHERE [Name] = '${flyway:defaultSchema}_Latitude' AND [ExtendedType] IS NULL AND [EntityID] IN ('31BA7A7D-B40B-42BA-A35C-7CAC63166E1A');

/* Set ExtendedType=GeoLongitude on virtual geo fields */
UPDATE [${flyway:defaultSchema}].[EntityField] SET [ExtendedType] = 'GeoLongitude' WHERE [Name] = '${flyway:defaultSchema}_Longitude' AND [ExtendedType] IS NULL AND [EntityID] IN ('31BA7A7D-B40B-42BA-A35C-7CAC63166E1A');

/* Generated Validation Functions for Assessments */
-- CHECK constraint for Assessments: Field: RevisionForm was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
INSERT INTO [${flyway:defaultSchema}].[GeneratedCode] ([CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
                      VALUES ((SELECT [ID] FROM [${flyway:defaultSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4FD92457-0BA8-486F-978A-E5947154F4F4', GETUTCDATE(), 'TypeScript', 'Approved', '([RevisionForm]=(136) OR [RevisionForm]=(134) OR [RevisionForm]=(133) OR [RevisionForm]=(131) OR [RevisionForm]=(130) OR [RevisionForm]=(115) OR [RevisionForm]=(113))', 'public ValidateRevisionFormInAllowedValues(result: ValidationResult) {
	const allowedRevisionForms = [136, 134, 133, 131, 130, 115, 113];
	if (this.RevisionForm != null && !allowedRevisionForms.includes(this.RevisionForm)) {
		const allowedValues = allowedRevisionForms.map(v => v.toString()).join(", ");
		result.Errors.push(new ValidationErrorInfo(
			"RevisionForm",
			"Revision form must be one of the following approved types: " + allowedValues + ".",
			this.RevisionForm,
			ValidationErrorType.Failure
		));
	}
}', 'The RevisionForm field, when populated, must contain one of the approved revision form types (136, 134, 133, 131, 130, 115, or 113). This ensures that property assessment revisions are only processed using valid, standardized form types recognized by the assessment system.', 'ValidateRevisionFormInAllowedValues', 'DF238F34-2837-EF11-86D4-6045BDEE16E6', 'C5B2AE84-6530-4C6F-89D3-0BDC0D8D48FB');

            -- CHECK constraint for Assessments @ Table Level was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
INSERT INTO [${flyway:defaultSchema}].[GeneratedCode] ([CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
                      VALUES ((SELECT [ID] FROM [${flyway:defaultSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4FD92457-0BA8-486F-978A-E5947154F4F4', GETUTCDATE(), 'TypeScript', 'Approved', '(NOT ([Source]=''StJosephPRC'' OR [Source]=''LakePRC'' OR [Source]=''marion_foia_2026'' OR [Source]=''MarionPRC'') OR [OriginalLandAV] IS NULL OR [OriginalImprovementAV] IS NULL OR [OriginalTotalAV] IS NULL OR abs(([OriginalLandAV]+[OriginalImprovementAV])-[OriginalTotalAV])<=(1))', 'public ValidateOriginalAssessmentValuesBalance(result: ValidationResult) {
	const restrictedSources = ["StJosephPRC", "LakePRC", "marion_foia_2026", "MarionPRC"];
	const isRestrictedSource = restrictedSources.indexOf(this.Source) !== -1;
	
	if (isRestrictedSource) {
		if (this.OriginalLandAV == null) {
			result.Errors.push(new ValidationErrorInfo(
				"OriginalLandAV",
				"Original land value is required for assessments from StJosephPRC, LakePRC, marion_foia_2026, or MarionPRC sources.",
				this.OriginalLandAV,
				ValidationErrorType.Failure
			));
		}
		
		if (this.OriginalImprovementAV == null) {
			result.Errors.push(new ValidationErrorInfo(
				"OriginalImprovementAV",
				"Original improvement value is required for assessments from StJosephPRC, LakePRC, marion_foia_2026, or MarionPRC sources.",
				this.OriginalImprovementAV,
				ValidationErrorType.Failure
			));
		}
		
		if (this.OriginalTotalAV == null) {
			result.Errors.push(new ValidationErrorInfo(
				"OriginalTotalAV",
				"Original total value is required for assessments from StJosephPRC, LakePRC, marion_foia_2026, or MarionPRC sources.",
				this.OriginalTotalAV,
				ValidationErrorType.Failure
			));
		}
		
		if (this.OriginalLandAV != null && this.OriginalImprovementAV != null && this.OriginalTotalAV != null) {
			const sum = this.OriginalLandAV + this.OriginalImprovementAV;
			const difference = Math.abs(sum - this.OriginalTotalAV);
			
			if (difference > 1) {
				result.Errors.push(new ValidationErrorInfo(
					"OriginalTotalAV",
					"The sum of original land value and original improvement value must equal the original total value within $1. Current difference: $" + difference.toFixed(2) + ".",
					this.OriginalTotalAV,
					ValidationErrorType.Failure
				));
			}
		}
	}
}', 'For assessments from specific sources (StJosephPRC, LakePRC, marion_foia_2026, or MarionPRC), the original land value, original improvement value, and original total value must all be provided, and the sum of land and improvement values must equal the total value within a tolerance of $1. For all other sources, these original assessment values are optional.', 'ValidateOriginalAssessmentValuesBalance', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', '4AB7D5DF-8D95-4897-BC26-1FEA542669EF');

/* Generated Validation Functions for Card Notes */
-- CHECK constraint for Card Notes: Field: NoteForm was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
INSERT INTO [${flyway:defaultSchema}].[GeneratedCode] ([CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
                      VALUES ((SELECT [ID] FROM [${flyway:defaultSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4FD92457-0BA8-486F-978A-E5947154F4F4', GETUTCDATE(), 'TypeScript', 'Approved', '([NoteForm]=(136) OR [NoteForm]=(134) OR [NoteForm]=(133) OR [NoteForm]=(131) OR [NoteForm]=(130) OR [NoteForm]=(115) OR [NoteForm]=(113))', 'public ValidateNoteFormIsValidType(result: ValidationResult) {
	const validNoteFormValues = [136, 134, 133, 131, 130, 115, 113];
	if (this.NoteForm != null && !validNoteFormValues.includes(this.NoteForm)) {
		const allowedValues = validNoteFormValues.join(", ");
		result.Errors.push(new ValidationErrorInfo(
			"NoteForm",
			"Note form must be one of the following valid types: " + allowedValues + ".",
			this.NoteForm,
			ValidationErrorType.Failure
		));
	}
}', 'The note form must be one of the following valid types: 136, 134, 133, 131, 130, 115, or 113. This ensures that only approved note form types are recorded in the system, maintaining data consistency and compliance with established classification standards.', 'ValidateNoteFormIsValidType', 'DF238F34-2837-EF11-86D4-6045BDEE16E6', '2B56E20E-50DC-48D5-9638-CB5A174B73BF');

/* Generated Validation Functions for Card Valuation Columns */
-- CHECK constraint for Card Valuation Columns: Field: ReasonForm was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
INSERT INTO [${flyway:defaultSchema}].[GeneratedCode] ([CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
                      VALUES ((SELECT [ID] FROM [${flyway:defaultSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4FD92457-0BA8-486F-978A-E5947154F4F4', GETUTCDATE(), 'TypeScript', 'Approved', '([ReasonForm]=(136) OR [ReasonForm]=(134) OR [ReasonForm]=(133) OR [ReasonForm]=(131) OR [ReasonForm]=(130) OR [ReasonForm]=(115) OR [ReasonForm]=(113))', 'public ValidateReasonFormIsApprovedType(result: ValidationResult) {
	const approvedReasonForms = [136, 134, 133, 131, 130, 115, 113];
	if (this.ReasonForm != null && !approvedReasonForms.includes(this.ReasonForm)) {
		const allowedValues = approvedReasonForms.join(", ");
		result.Errors.push(new ValidationErrorInfo(
			"ReasonForm",
			"ReasonForm must be one of the following approved types: " + allowedValues + ".",
			this.ReasonForm,
			ValidationErrorType.Failure
		));
	}
}', 'The reason for change must be one of the following approved form types: 136, 134, 133, 131, 130, 115, or 113. This ensures that all property assessment changes are documented with a valid reason code from the authorized list.', 'ValidateReasonFormIsApprovedType', 'DF238F34-2837-EF11-86D4-6045BDEE16E6', '3AC9DEE0-03BE-4CE6-9CDA-B1D0E788176F');

/* Generated Validation Functions for Counties */
-- CHECK constraint for Counties: Field: CountyNumber was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
INSERT INTO [${flyway:defaultSchema}].[GeneratedCode] ([CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
                      VALUES ((SELECT [ID] FROM [${flyway:defaultSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4FD92457-0BA8-486F-978A-E5947154F4F4', GETUTCDATE(), 'TypeScript', 'Approved', '([CountyNumber]>=(1) AND [CountyNumber]<=(92))', 'public ValidateCountyNumberRange(result: ValidationResult) {
	if (this.CountyNumber < 1 || this.CountyNumber > 92) {
		result.Errors.push(new ValidationErrorInfo(
			"CountyNumber",
			"County number must be between 1 and 92.",
			this.CountyNumber,
			ValidationErrorType.Failure
		));
	}
}', 'County number must be between 1 and 92 inclusive. This ensures that county identifiers fall within the valid range for the county system.', 'ValidateCountyNumberRange', 'DF238F34-2837-EF11-86D4-6045BDEE16E6', '93147B7B-502A-457C-9044-7925240F0E9E');

/* Generated Validation Functions for County Assessor Records */
-- CHECK constraint for County Assessor Records: Field: RevisionForm was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
INSERT INTO [${flyway:defaultSchema}].[GeneratedCode] ([CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
                      VALUES ((SELECT [ID] FROM [${flyway:defaultSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4FD92457-0BA8-486F-978A-E5947154F4F4', GETUTCDATE(), 'TypeScript', 'Approved', '([RevisionForm]=(136) OR [RevisionForm]=(134) OR [RevisionForm]=(133) OR [RevisionForm]=(131) OR [RevisionForm]=(130) OR [RevisionForm]=(115) OR [RevisionForm]=(113))', 'public ValidateRevisionFormAllowedValues(result: ValidationResult) {
	const allowedValues = [136, 134, 133, 131, 130, 115, 113];
	if (this.RevisionForm != null && !allowedValues.includes(this.RevisionForm)) {
		const valuesList = allowedValues.join(", ");
		result.Errors.push(new ValidationErrorInfo(
			"RevisionForm",
			"RevisionForm must be one of the following values: " + valuesList + ".",
			this.RevisionForm,
			ValidationErrorType.Failure
		));
	}
}', 'The RevisionForm field, when populated, must contain one of the following valid revision form codes: 136, 134, 133, 131, 130, 115, or 113. These codes represent specific types of property assessment revision forms used in the tax assessment process. This constraint ensures only approved revision form types are recorded in the system.', 'ValidateRevisionFormAllowedValues', 'DF238F34-2837-EF11-86D4-6045BDEE16E6', '94C6DB31-498A-4C83-ABBE-E3DCBDA51F59');

/* Generated Validation Functions for IBTR Decision Chunks */
-- CHECK constraint for IBTR Decision Chunks: Field: Ordinal was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
INSERT INTO [${flyway:defaultSchema}].[GeneratedCode] ([CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
                      VALUES ((SELECT [ID] FROM [${flyway:defaultSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4FD92457-0BA8-486F-978A-E5947154F4F4', GETUTCDATE(), 'TypeScript', 'Approved', '([Ordinal]>=(0))', 'public ValidateOrdinalNonNegative(result: ValidationResult) {
	if (this.Ordinal < 0) {
		result.Errors.push(new ValidationErrorInfo(
			"Ordinal",
			"Ordinal position must be zero or greater",
			this.Ordinal,
			ValidationErrorType.Failure
		));
	}
}', 'The ordinal position must be zero or greater. This ensures that sequence numbers or positional indices for document chunks are non-negative values, maintaining proper ordering and indexing of content.', 'ValidateOrdinalNonNegative', 'DF238F34-2837-EF11-86D4-6045BDEE16E6', '6E2FC487-8041-4A9D-90B4-3F03ED51DC44');

/* Generated Validation Functions for IBTR Decision Citations */
-- CHECK constraint for IBTR Decision Citations: Field: MentionCount was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
INSERT INTO [${flyway:defaultSchema}].[GeneratedCode] ([CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
                      VALUES ((SELECT [ID] FROM [${flyway:defaultSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4FD92457-0BA8-486F-978A-E5947154F4F4', GETUTCDATE(), 'TypeScript', 'Approved', '([MentionCount]>=(1))', 'public ValidateMentionCountMinimum(result: ValidationResult) {
	if (this.MentionCount < 1) {
		result.Errors.push(new ValidationErrorInfo(
			"MentionCount",
			"Mention count must be at least 1",
			this.MentionCount,
			ValidationErrorType.Failure
		));
	}
}', 'The mention count must be at least 1. This ensures that every citation authority record represents at least one actual mention in the document, maintaining data quality by preventing empty or placeholder records.', 'ValidateMentionCountMinimum', 'DF238F34-2837-EF11-86D4-6045BDEE16E6', 'E53B6427-E0B0-49CC-B695-A1A82204934D');

/* Generated Validation Functions for IBTR Decision Holdings */
-- CHECK constraint for IBTR Decision Holdings @ Table Level was newly set or modified since the last generation of the validation function, the code was regenerated and updating the GeneratedCode table with the new generated validation function
INSERT INTO [${flyway:defaultSchema}].[GeneratedCode] ([CategoryID], [GeneratedByModelID], [GeneratedAt], [Language], [Status], [Source], [Code], [Description], [Name], [LinkedEntityID], [LinkedRecordPrimaryKey])
                      VALUES ((SELECT [ID] FROM [${flyway:defaultSchema}].[vwGeneratedCodeCategories] WHERE [Name]='CodeGen: Validators'), '4FD92457-0BA8-486F-978A-E5947154F4F4', GETUTCDATE(), 'TypeScript', 'Approved', '(([ValueBefore] IS NULL OR [ValueBefore]>=(0)) AND ([ValueAfter] IS NULL OR [ValueAfter]>=(0)))', 'public ValidatePropertyValuesNonNegative(result: ValidationResult) {
	if (this.ValueBefore != null && this.ValueBefore < 0) {
		result.Errors.push(new ValidationErrorInfo(
			"ValueBefore",
			"Property value before must be greater than or equal to zero",
			this.ValueBefore,
			ValidationErrorType.Failure
		));
	}
	if (this.ValueAfter != null && this.ValueAfter < 0) {
		result.Errors.push(new ValidationErrorInfo(
			"ValueAfter",
			"Property value after must be greater than or equal to zero",
			this.ValueAfter,
			ValidationErrorType.Failure
		));
	}
}', 'Both the property value before and property value after must be either empty or greater than or equal to zero. This ensures that when property values are recorded, they cannot be negative numbers, maintaining data integrity for financial assessments.', 'ValidatePropertyValuesNonNegative', 'E0238F34-2837-EF11-86D4-6045BDEE16E6', '362ECD3F-2AE7-4494-BF10-36879A6C316B');

