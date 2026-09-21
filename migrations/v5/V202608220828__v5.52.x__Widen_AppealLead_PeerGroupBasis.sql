-- Widens indiana_tax.AppealLead.PeerGroupBasis from NVARCHAR(20) to NVARCHAR(50).
--
-- The original size was too small for the actual values the scoring methodology
-- produces (e.g. "class only (class+grade too thin)" is 33 characters, used when
-- a class+grade peer bucket is too small and the algorithm falls back to a
-- coarser class-only grouping). Loading the real data set hit this immediately:
-- SQL Server/tedious reported a corrupted TDS stream ("Data type 0xE7 has an
-- invalid data length or metadata length") because the client-side parameter
-- was typed NVARCHAR(20) while the value was 33 characters, rather than a
-- clean truncation error. NVARCHAR(50) gives headroom over the two known
-- values ("class+grade", 11 chars; the fallback string above, 33 chars).

-- Note: AppealLead lives in the indiana_tax schema (a domain schema, not the
-- MJ core __mj schema), so this migration references it directly rather than
-- via ${flyway:defaultSchema}.

IF EXISTS (SELECT * FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('indiana_tax.AppealLead')
           AND minor_id = (SELECT column_id FROM sys.columns
                          WHERE object_id = OBJECT_ID('indiana_tax.AppealLead')
                          AND name = 'PeerGroupBasis')
           AND name = 'MS_Description')
BEGIN
    EXEC sp_dropextendedproperty
        @name = N'MS_Description',
        @level0type = N'SCHEMA', @level0name = 'indiana_tax',
        @level1type = N'TABLE', @level1name = 'AppealLead',
        @level2type = N'COLUMN', @level2name = 'PeerGroupBasis';
END

ALTER TABLE indiana_tax.AppealLead
ALTER COLUMN PeerGroupBasis NVARCHAR(50) NULL;

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'How the peer comparison group was defined for this parcel (e.g. "class+grade", or a coarser fallback like "class only (class+grade too thin)" when the class+grade bucket had too few peers). Widened to NVARCHAR(50) after the original NVARCHAR(20) proved too small for the fallback-description strings the methodology actually produces.',
    @level0type = N'SCHEMA', @level0name = 'indiana_tax',
    @level1type = N'TABLE', @level1name = 'AppealLead',
    @level2type = N'COLUMN', @level2name = 'PeerGroupBasis';
