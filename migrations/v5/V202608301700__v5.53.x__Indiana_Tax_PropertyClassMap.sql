/* ============================================================================
   Indiana Property Tax Expert — PropertyClassMap
   v5.53.x

   The single source of truth for mapping an Indiana DLGF real-property class
   code (the trailing "-NNN" on Marion's PropertySubClassDescription, e.g.
   "COM OFF O/147 - ELEVATOR-449") to a coarse PropertyTypeGroup used for comp
   grouping across the platform.

   Replaces the fragile keyword-matching CASE that lived in
   ParcelPhysicalProfile and in load-sale-transactions.js /
   load-valuation-analysis-sales.js (which mis-classified every office building
   as "Retail" because "OFF" != "OFFICE" and 4xx fell through to Retail).

   Seeded by Indiana_Tax_Expert/scripts/load-property-class-map.js (80 rows).
   Design: Indiana_Tax_Expert/docs/proposals/property-type-classification.md.

   NOTE: CoStar's property type is deliberately NOT merged in here — it stays a
   separate, always-CoStar-labelled datapoint on ParcelPhysicalProfile. This
   map is DLGF-only and authoritative.
   ============================================================================ */

CREATE TABLE indiana_tax.PropertyClassMap (
    Code CHAR(3) NOT NULL,
    Label NVARCHAR(120) NOT NULL,
    TypeGroup NVARCHAR(20) NOT NULL
        CONSTRAINT CK_PropertyClassMap_TypeGroup CHECK (TypeGroup IN (
            'Retail', 'Office', 'Industrial', 'Multifamily', 'Hospitality',
            'Land', 'Special', 'Parking', 'Other')),
    Notes NVARCHAR(400) NULL,

    __mj_CreatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_PropertyClassMap_C DEFAULT (SYSDATETIMEOFFSET()),
    __mj_UpdatedAt DATETIMEOFFSET NOT NULL CONSTRAINT DF_PropertyClassMap_U DEFAULT (SYSDATETIMEOFFSET()),

    CONSTRAINT PK_PropertyClassMap PRIMARY KEY (Code)
);
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Maps an Indiana DLGF real-property class code (3 digits) to a coarse PropertyTypeGroup for comp grouping. The single source of truth for classification; consumed by the ParcelPhysicalProfile view and the SaleTransaction / ValuationAnalysis loaders. DLGF-only -- CoStar type is a separate, CoStar-labelled datapoint and never merged here. Design: Indiana_Tax_Expert/docs/proposals/property-type-classification.md.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'PropertyClassMap';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The 3-digit DLGF real-property class code (e.g. "449").',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'PropertyClassMap', @level2type = N'COLUMN', @level2name = N'Code';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'The DLGF label for the code (from Marion''s PropertySubClassDescription).',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'PropertyClassMap', @level2type = N'COLUMN', @level2name = N'Label';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Coarse group: Retail / Office / Industrial / Multifamily / Hospitality / Land / Special / Parking / Other.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'PropertyClassMap', @level2type = N'COLUMN', @level2name = N'TypeGroup';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Rationale / borderline-call note for this mapping.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax', @level1type = N'TABLE', @level1name = N'PropertyClassMap', @level2type = N'COLUMN', @level2name = N'Notes';
GO
