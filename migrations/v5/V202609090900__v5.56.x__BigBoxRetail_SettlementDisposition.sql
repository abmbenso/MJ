/* ============================================================================
   Big Box Retail — date a settlement, and name its disposition
   v5.56.x

   ParcelSettlement held a conceded assessed value with no way to say WHICH
   assessment year it settled or HOW it was disposed of. Both are now extracted
   where the note states them (extract-sale-history.py), and both are recorded
   here as nullable, because on most notes they genuinely cannot be determined.

   ## Disposition — the more useful of the two

   Indiana form numbers name the stage, and they are not interchangeable:

     * **Form 134** — joint report of a PRELIMINARY INFORMAL CONFERENCE: a
       settlement reached before any hearing. This is the stage that actually
       produces reductions, and 24 of the 35 settlements naming a form are
       Form 134 against just 4 Form 115.
     * **Form 115** — PTABOA determination: the county board ruled.
     * **Form 133** — petition for correction of ERROR, which is not a
       valuation dispute at all and must not be read as one.

   35 of 123 settlements name a form. That is what is observable in the notes,
   not a population statistic — the other 88 say nothing, so the 24:4 split
   describes the sample and should not be quoted as a rate.

   ## AssessmentYear — deliberately sparse, and why

   Only 4 of 123 carry a year, and that is the honest number rather than a
   disappointing one. A first pass reached 27% and an audit of every extracted
   year against its own note found it riddled: "12-13-22" is 13 December 2022
   and was read as AY2012; "21-22 BLDG PERMIT" is a building permit; an
   assessed-value grid cell standing near a year was bound to it as though
   settled. A wrong year is worse than none — it files a settlement against an
   assessment it never touched — so the extractor now demands the year sit
   within 60 characters of the amount AND be joined to it by an actual
   statement of value ("total av =", "agreed", "assessment of"). The 4 that
   survive were checked individually: one Form 134 stipulation at $8,400,000
   binding AY2017-2020, exactly as its note reads.
   ============================================================================ */

ALTER TABLE big_box_retail.ParcelSettlement ADD
    AssessmentYear   INT           NULL,
    DispositionForm  NVARCHAR(4)   NULL,
    Disposition      NVARCHAR(60)  NULL;
GO

ALTER TABLE big_box_retail.ParcelSettlement ADD
    CONSTRAINT CK_ParcelSettlement_DispositionForm
        CHECK (DispositionForm IN (N'115', N'130', N'131', N'133', N'134', N'136'));
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'The assessment year this settlement resolved, where the note states it unambiguously. NULL on most rows by design: a first extraction pass reached 27% coverage and an audit found it wrong often enough to be dangerous (dash-written dates read as year pairs, building-permit references read as settlements). A wrong year files a concession against an assessment it never touched, so the extractor now requires the year to sit within 60 characters of the amount and be joined to it by an actual statement of value.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelSettlement', @level2type = N'COLUMN', @level2name = N'AssessmentYear';

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Indiana form number naming how the appeal was disposed of: 134 preliminary informal conference, 115 PTABOA determination, 133 correction of error, 130 petition to the county board, 131 appeal to the IBTR, 136 exemption. NULL where the note does not name one (88 of 123).',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelSettlement', @level2type = N'COLUMN', @level2name = N'DispositionForm';

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'The form number in words. Read Form 134 first: a preliminary informal conference is a settlement reached BEFORE any hearing, and it is the stage that actually produces reductions - 24 of the 35 settlements naming a form are Form 134 against 4 Form 115. Form 133 is a correction of error and is NOT a valuation dispute, so it must not be counted as a concession on value.',
    @level0type = N'SCHEMA', @level0name = N'big_box_retail',
    @level1type = N'TABLE',  @level1name = N'ParcelSettlement', @level2type = N'COLUMN', @level2name = N'Disposition';
GO
