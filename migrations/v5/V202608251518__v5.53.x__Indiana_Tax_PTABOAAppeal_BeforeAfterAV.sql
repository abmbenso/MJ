/* ============================================================================
   Indiana Property Tax Expert — PTABOA Appeal Before/After assessed values.
   v5.53.x

   The PTABOA agenda PDFs' table carries a full Before-PTABOA / After-PTABOA /
   Change breakdown (Land, Improvement, Total AV) for every appeal -- already
   parsed into the Indiana_Assessment_Database prototype's SQLite
   ptaboa_appeal table (before_total_land/before_total_imp/before_total_av,
   after_total_land/after_total_imp/after_total_av, change_total_*) since the
   very first version of parse_ptaboa_agendas.py. Like CaseNumber and
   TaxRepresentative before it (see V202608251451), this was silently dropped
   by the original bulk migration into indiana_tax.PTABOAAppeal rather than
   genuinely absent from the source -- no new parsing needed, only a reload
   from the same already-populated SQLite table (see
   scripts/reload-ptaboa-appeals.js).

   Land/Improvement C1/C2/C3 sub-class breakdowns and the Change_* columns are
   deliberately NOT carried into indiana_tax -- Change is always exactly
   After minus Before (trivial to compute at display/query time, not worth
   storing and risking drift), and the C1/C2/C3 split isn't meaningful outside
   the agenda's own internal bookkeeping (matches this schema's existing
   choice not to carry that split on Assessment either).

   This is the data source for per-property-sub-class appeal analytics
   (success rate, average reduction) -- the same underlying figures already
   power AppealLead's PeerWinRate/PeerAvgPctReduction, but grouped there by
   the coarser PropertyClassCode as a scoring input, not browsable by
   PropertySubClassDescription anywhere yet.
   ============================================================================ */

ALTER TABLE indiana_tax.PTABOAAppeal
ADD BeforeLandAV DECIMAL(14,2) NULL,
    BeforeImprovementAV DECIMAL(14,2) NULL,
    BeforeTotalAV DECIMAL(14,2) NULL,
    AfterLandAV DECIMAL(14,2) NULL,
    AfterImprovementAV DECIMAL(14,2) NULL,
    AfterTotalAV DECIMAL(14,2) NULL;
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Land assessed value BEFORE this appeal/exemption was decided, as printed on the PTABOA agenda.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'PTABOAAppeal',
    @level2type = N'COLUMN', @level2name = N'BeforeLandAV';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Improvement assessed value BEFORE this appeal/exemption was decided, as printed on the PTABOA agenda.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'PTABOAAppeal',
    @level2type = N'COLUMN', @level2name = N'BeforeImprovementAV';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Total assessed value (Land + Improvement) BEFORE this appeal/exemption was decided.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'PTABOAAppeal',
    @level2type = N'COLUMN', @level2name = N'BeforeTotalAV';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Land assessed value AFTER this appeal/exemption was decided, as printed on the PTABOA agenda. Equal to BeforeLandAV when the appeal produced no land-value change.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'PTABOAAppeal',
    @level2type = N'COLUMN', @level2name = N'AfterLandAV';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Improvement assessed value AFTER this appeal/exemption was decided, as printed on the PTABOA agenda. Equal to BeforeImprovementAV when the appeal produced no improvement-value change.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'PTABOAAppeal',
    @level2type = N'COLUMN', @level2name = N'AfterImprovementAV';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Total assessed value (Land + Improvement) AFTER this appeal/exemption was decided. AfterTotalAV - BeforeTotalAV is this appeal''s AV change (negative = a reduction) -- computed at query/display time rather than stored, to avoid drift.',
    @level0type = N'SCHEMA', @level0name = N'indiana_tax',
    @level1type = N'TABLE',  @level1name = N'PTABOAAppeal',
    @level2type = N'COLUMN', @level2name = N'AfterTotalAV';
GO
