import { describe, it, expect } from 'vitest';
import { buildAppealExport, exportToDocument, AppealExportInput, PrintSection } from './appeal-export';
import { AnalysisRow, AssumptionRow, SubjectBundle, ValuationCompRow } from './analysis-store';
import { SalesCompResult } from './sales-approach';

/** Fix 4 fixture: the two Sales comps `salesResults`/`indications` refer to by SaleTransactionID ('S1'/'S2'), carrying the CompAddress/CompSubmarket the printed Sales table must show instead of the raw id. */
const salesComps: ValuationCompRow[] = [
  {
    ID: 'VC1', ValuationAnalysisID: 'V1', SaleTransactionID: 'S1', CompAddress: '100 First St', CompSubmarket: 'North',
    SaleDate: '2026-01-01', SalePrice: 5_000_000, CompDenominator: 30_000, CompYearBuilt: 2005, CompGradeOrdinal: 4,
    UnitOfComparison: '$/SF', RawPerUnit: 168.94, SizeAdjPct: 0.01, AgeAdjPct: -0.01, GradeAdjPct: -0.01, TimeAdjPct: 0.04,
    NetAdjPct: 0.03, GrossAdjPct: 0.07, AdjustedPerUnit: 174, SubjectIndicatedValue: 7_308_000, SimilarityRank: 1, IsSelected: true, DropReason: null,
  },
  {
    ID: 'VC2', ValuationAnalysisID: 'V1', SaleTransactionID: 'S2', CompAddress: '200 Second Ave', CompSubmarket: 'South',
    SaleDate: '2026-02-01', SalePrice: 6_000_000, CompDenominator: 30_000, CompYearBuilt: 2010, CompGradeOrdinal: 4,
    UnitOfComparison: '$/SF', RawPerUnit: 200, SizeAdjPct: 0, AgeAdjPct: 0, GradeAdjPct: 0, TimeAdjPct: 0,
    NetAdjPct: 0, GrossAdjPct: 0, AdjustedPerUnit: 200, SubjectIndicatedValue: 8_400_000, SimilarityRank: 2, IsSelected: true, DropReason: null,
  },
];

const parcel = {
  ID: 'P1',
  ParcelNumber: '490000000000000000',
  GISParcelNumber: '1234567',
  Address: '8800 SAMPLE PKWY',
  OwnerName: 'OWNER LLC',
  PropertyClassCode: '441',
  CountyNumber: 49,
};
const record = {
  ID: 'R1',
  ParcelID: 'P1',
  TaxYear: 2026,
  EstimatedSqFt: 42000,
  ComparisonUnitType: 'SF',
  ComparisonUnitCount: 42000,
  YearBuilt: 1998,
  Neighborhood: '49-ABC',
  TaxRate: 2.98,
  AssessedTotalAV: 8150000,
  AssessedLandAV: null,
  AssessedImprovementAV: null,
  Acreage: '4.1',
  PropertySubClassDescription: 'Retail center',
  PropertyClass: null,
};

const assessments = [
  { ID: 'A26', ParcelID: 'P1', AssessmentYear: 2026, Source: 'MarionPRC', OriginalTotalAV: 8150000, PTABOATotalAV: null },
  { ID: 'A25', ParcelID: 'P1', AssessmentYear: 2025, Source: 'MarionPRC', OriginalTotalAV: 7600000, PTABOATotalAV: 7410000 },
  { ID: 'A24', ParcelID: 'P1', AssessmentYear: 2024, Source: 'MarionPRC', OriginalTotalAV: 7200000, PTABOATotalAV: null },
];

function baseSubject(overrides: Partial<SubjectBundle> = {}): SubjectBundle {
  return {
    parcel,
    record,
    assessments,
    valuation: {
      ID: 'V1',
      ParcelID: 'P1',
      PropertyTypeGroup: 'Retail',
      CurrentTotalAV: 8150000,
      SalesIndicatedValue: 7050000,
      SalesMethodNote: null,
      IncomeIndicatedValue: 6720000,
      IncomeMethodNote: null,
      CostProxyValue: 8640000,
      CostProxyNote: null,
      ReconciledTargetValue: null,
      LowestSupportedValue: null,
      Recommendation: null,
      ConfidenceTier: null,
      CompCount: null,
      MethodologyVersion: null,
      GeneratedAt: '2026-08-30',
    },
    comps: salesComps,
    compSet: null,
    compMembers: [],
    memberParcels: {},
    ptaboa: [],
    ibtr: [],
    costar: null,
    marketAssumptions: [],
    typeGroup: 'Retail',
    subjectGradeOrdinal: null,
    ...overrides,
  };
}

const analysis: AnalysisRow = {
  ID: 'AN1',
  ParcelID: 'P1',
  AssessmentYear: 2026,
  Name: 'FY26 appeal',
  PropertyTypeGroup: 'Retail',
  Status: 'Draft',
  UnitOfComparison: '$/SF',
  SubjectDenominator: 42000,
  CurrentTotalAV: 8150000,
  PriorTotalAV: 7410000,
  BurdenOnAssessor: true,
  AskPolicy: 'Lowest',
  RequestedValue: 6720000,
  RequestedValueApproach: 'Income',
  FloorValue: 6720000,
  FloorApproach: 'Income',
  Recommendation: 'Appeal',
  EstimatedTaxSavings: 42600,
  SavingsRate: 0.03,
  Comments: 'Strong income case.',
  ValuationAnalysisID: 'V1',
  ComparableAssessmentSetID: null,
};

const indications = [
  {
    ID: 'I1',
    AppealAnalysisID: 'AN1',
    Approach: 'Income' as const,
    IndicatedValue: 6720000,
    PerUnit: 160,
    PctOfAV: 0.8246,
    Credible: true,
    Supports: true,
    Status: 'Computed' as const,
    Rationale: 'Cap-rate driven.',
    ComputedAt: '2026-09-01',
  },
  {
    ID: 'I2',
    AppealAnalysisID: 'AN1',
    Approach: 'Sales' as const,
    IndicatedValue: 7050000,
    PerUnit: 167.86,
    PctOfAV: 0.865,
    Credible: true,
    Supports: true,
    Status: 'Computed' as const,
    Rationale: null,
    ComputedAt: '2026-09-01',
  },
];

const salesResults: SalesCompResult[] = [
  {
    id: 'S1',
    rawPerUnit: 168.94,
    sizeAdjPct: 0.01,
    ageAdjPct: -0.01,
    gradeAdjPct: -0.01,
    timeAdjPct: 0.04,
    netAdjPct: 0.03,
    grossAdjPct: 0.07,
    adjustedPerUnit: 174,
    subjectIndicatedValue: 7308000,
    grossAdjustmentWarning: false,
  },
  {
    id: 'S2',
    rawPerUnit: 200,
    sizeAdjPct: 0,
    ageAdjPct: 0,
    gradeAdjPct: 0,
    timeAdjPct: 0,
    netAdjPct: 0,
    grossAdjPct: 0,
    adjustedPerUnit: 200,
    subjectIndicatedValue: 8400000,
    grossAdjustmentWarning: false,
  },
];

const incomeAssumptions: AssumptionRow[] = [
  {
    ID: 'IA1',
    AppealAnalysisID: 'AN1',
    Section: 'Income',
    AssumptionKey: 'rent_base',
    Label: 'Base rent',
    Value: 14.5,
    Unit: '$/SF',
    Mode: 'perSF',
    Source: 'Market',
    SourceRef: 'CoStar',
    ProposedValue: 14.5,
    ProposedSource: 'Market',
    SortOrder: 1,
  },
  {
    ID: 'IA2',
    AppealAnalysisID: 'AN1',
    Section: 'Income',
    AssumptionKey: 'cap_rate',
    Label: 'Cap rate',
    Value: 0.0775,
    Unit: 'rate',
    Mode: 'rate',
    Source: 'Market',
    SourceRef: 'MarketAssumption',
    ProposedValue: 0.0775,
    ProposedSource: 'Market',
    SortOrder: 9,
  },
];

const salesAssumptions: AssumptionRow[] = [
  {
    ID: 'SA1',
    AppealAnalysisID: 'AN1',
    Section: 'Sales',
    AssumptionKey: 'size_elasticity',
    Label: 'Size elasticity',
    Value: 0.1,
    Unit: null,
    Mode: 'rate',
    Source: 'Default',
    SourceRef: null,
    ProposedValue: 0.1,
    ProposedSource: 'Default',
    SortOrder: 1,
  },
];

function baseInput(overrides: Partial<AppealExportInput> = {}): AppealExportInput {
  return {
    subject: baseSubject(),
    analysis,
    assumptions: [...incomeAssumptions, ...salesAssumptions],
    indications,
    salesResults,
    includedSaleTransactionIds: new Set(['S1', 'S2']),
    generatedAt: new Date('2026-09-16T12:00:00Z'),
    ...overrides,
  };
}

describe('buildAppealExport', () => {
  it('omits a section entirely when it has no data, rather than an empty table', () => {
    const model = buildAppealExport(baseInput({ subject: baseSubject({ ptaboa: [], ibtr: [] }) }));
    expect(model.sections.Decisions).toBeUndefined();
  });

  it('includes a Decisions section when the subject has PTABOA or IBTR history', () => {
    const model = buildAppealExport(
      baseInput({
        subject: baseSubject({ ptaboa: [{ ID: 'PT1', ParcelID: 'P1', HearingDate: '2025-06-01', DecisionStatus: 'Sustained', Circumstances: null }] }),
      }),
    );
    expect(model.sections.Decisions).toBeDefined();
    expect(model.sections.Decisions?.table?.rows.length).toBeGreaterThan(0);
  });

  it('includes an analyst-edited warning for an overridden coefficient', () => {
    const edited: AssumptionRow = { ...salesAssumptions[0], Source: 'Analyst', SourceRef: 'analyst override' };
    const model = buildAppealExport(baseInput({ assumptions: [...incomeAssumptions, edited] }));
    expect(model.analystEditedWarnings.length).toBeGreaterThan(0);
    expect(model.analystEditedWarnings[0]).toContain('Size elasticity');
  });

  it('produces no analyst-edited warnings when every assumption is County/Market/Default', () => {
    const model = buildAppealExport(baseInput());
    expect(model.analystEditedWarnings).toEqual([]);
  });

  it('Sales section only shows included comps, not the full candidate pool', () => {
    const model = buildAppealExport(baseInput({ includedSaleTransactionIds: new Set(['S1']) }));
    expect(model.sections.Sales?.table?.rows.length).toBe(1);
    // Fix 4: the "Comp" column is the comp's address/submarket, not the raw SaleTransactionID.
    expect(model.sections.Sales?.table?.rows[0][0]).toBe('100 First St — North');
  });

  it('omits the Sales section entirely when no comp is included', () => {
    const model = buildAppealExport(baseInput({ includedSaleTransactionIds: new Set() }));
    expect(model.sections.Sales).toBeUndefined();
  });

  /**
   * Fix 4 (final whole-plan review): the Sales section's own comp table was printing the raw
   * `SaleTransactionID` GUID in the "Comp" column -- the actual settlement-support package a
   * practitioner hands to an assessor would list comps as raw GUIDs instead of addresses. It must
   * show the same address/submarket label the on-screen Sales tab already shows for the same comps.
   */
  it('Sales section shows every included comp\'s address/submarket, not a raw SaleTransactionID', () => {
    const model = buildAppealExport(baseInput());
    const compCells = model.sections.Sales?.table?.rows.map((r) => r[0]) ?? [];
    expect(compCells).toEqual(['100 First St — North', '200 Second Ave — South']);
    for (const cell of compCells) {
      expect(cell).not.toBe('S1');
      expect(cell).not.toBe('S2');
    }
  });

  it('Sales section falls back to the raw id for a comp with no matching subject.comps entry (defensive, not a regression)', () => {
    const model = buildAppealExport(
      baseInput({ salesResults: [...salesResults, { ...salesResults[0], id: 'S-UNMATCHED' }], includedSaleTransactionIds: new Set(['S-UNMATCHED']) }),
    );
    expect(model.sections.Sales?.table?.rows[0][0]).toBe('S-UNMATCHED');
  });

  it('omits the Cost section when the subject has no cost-proxy value', () => {
    const model = buildAppealExport(baseInput({ subject: baseSubject({ valuation: null }) }));
    expect(model.sections.Cost).toBeUndefined();
  });

  it('includes the Cost section when the subject has a cost-proxy value', () => {
    const model = buildAppealExport(baseInput());
    expect(model.sections.Cost).toBeDefined();
    expect(model.sections.Cost?.rows?.[0].value).toContain('8,640,000');
  });

  /**
   * Fix 7 (final whole-plan review): the Income row formatter's ternary had identical branches
   * (`Unit === '%' || Unit === 'pct' ? 2 : 2`) -- dead code masking the real bug, a %/pct-unit
   * row printed its raw decimal (e.g. `0.0775`) instead of a percentage (`7.8%`, via this file's
   * own `pct()` helper, already used throughout Cover/Sales/Tax).
   */
  it('an Income row with a %/pct Unit renders as a percentage, not a raw decimal', () => {
    const pctRow: AssumptionRow = {
      ID: 'IA3', AppealAnalysisID: 'AN1', Section: 'Income', AssumptionKey: 'vacancy', Label: 'Vacancy',
      Value: 0.0775, Unit: '%', Mode: 'rate', Source: 'Market', SourceRef: 'CoStar',
      ProposedValue: 0.0775, ProposedSource: 'Market', SortOrder: 2,
    };
    const model = buildAppealExport(baseInput({ assumptions: [...incomeAssumptions, pctRow, ...salesAssumptions] }));
    const row = model.sections.Income?.table?.rows.find((r) => r[0] === 'Vacancy');
    expect(row?.[1]).toBe('7.8%');
    expect(row?.[1]).not.toContain('0.0775');
  });

  it('an Income row with a non-percentage Unit still renders as a plain number, not a percentage', () => {
    const model = buildAppealExport(baseInput());
    const row = model.sections.Income?.table?.rows.find((r) => r[0] === 'Base rent');
    expect(row?.[1]).toBe('14.50');
  });

  it('always produces a Cover section carrying the reconciled floor/ask/recommendation', () => {
    const model = buildAppealExport(baseInput());
    const cover = model.sections.Cover;
    expect(cover).toBeDefined();
    const rec = cover?.rows?.find((r) => r.label === 'Recommendation');
    expect(rec?.value).toBe('Appeal');
  });

  it('Cover section renders the 3-year assessment history as a genuine Year | Original AV | Final AV | % Change table, separate from the indication ladder', () => {
    const model = buildAppealExport(baseInput());
    const cover = model.sections.Cover;
    expect(cover?.secondaryTable?.columns).toEqual(['Year', 'Original AV', 'Final AV', '% Change']);
    // Three fixture years (2024-2026); each row is [year, original, final, %change] -- not
    // flattened into rows/dl.rows label-value lines.
    expect(cover?.secondaryTable?.rows).toEqual([
      ['2024', '$7,200,000', '$7,200,000', '—'],
      ['2025', '$7,600,000', '$7,410,000', '2.9%'],
      ['2026', '$8,150,000', '$8,150,000', '10.0%'],
    ]);
    // The indication ladder stays the section's PRIMARY table, untouched by the secondary one.
    expect(cover?.table?.columns).toEqual(['Approach', 'Indicated value', '% of AV', 'Credible', 'Supports', 'Role']);
    // The 3-year AV rows that used to be flattened into `rows` are gone from there now.
    expect(cover?.rows?.some((r) => r.label.startsWith('AV '))).toBe(false);
  });

  it('omits the Tax section when there is no district tax rate on file', () => {
    const model = buildAppealExport(baseInput({ subject: baseSubject({ record: { ...record, TaxRate: null } }) }));
    expect(model.sections.Tax).toBeUndefined();
  });

  it('includes the Tax section with savings at both ask and floor when a tax rate is on file', () => {
    const model = buildAppealExport(baseInput());
    expect(model.sections.Tax).toBeDefined();
    const labels = model.sections.Tax?.rows?.map((r) => r.label) ?? [];
    expect(labels).toContain('Estimated saving at ask');
    expect(labels).toContain('Estimated saving at floor');
  });

  it('title and subtitle carry the subject address, parcel number and assessment year', () => {
    const model = buildAppealExport(baseInput());
    expect(model.title).toContain('8800 SAMPLE PKWY');
    expect(model.subtitle).toContain('490000000000000000');
    expect(model.subtitle).toContain('2026');
  });
});

describe('exportToDocument', () => {
  it('renders only sections both present in the model and requested in `include`', () => {
    const model = buildAppealExport(baseInput());
    const html = exportToDocument(model, new Set<PrintSection>(['Cover']));
    expect(html).toContain('Cover');
    expect(html).not.toContain(model.sections.Income?.title ?? '__none__');
    expect(html).not.toContain(model.sections.Sales?.title ?? '__none__');
  });

  it('renders a section requested in `include` but omits one not present in the model even if requested', () => {
    const model = buildAppealExport(baseInput({ subject: baseSubject({ valuation: null }) }));
    const html = exportToDocument(model, new Set<PrintSection>(['Cover', 'Cost']));
    expect(html).toContain('Cover');
    expect(html).not.toContain('Cost Analysis');
  });

  it('renders every requested-and-present section when include holds the full set', () => {
    const model = buildAppealExport(baseInput());
    const allSections = Object.keys(model.sections) as PrintSection[];
    const html = exportToDocument(model, new Set(allSections));
    for (const key of allSections) {
      expect(html).toContain(escapeForAssert(model.sections[key]!.title));
    }
  });

  it('renders the Cover assessment-history table with its own heading, positioned between the property-facts rows and the indication ladder', () => {
    const model = buildAppealExport(baseInput());
    const html = exportToDocument(model, new Set<PrintSection>(['Cover']));
    const headingIdx = html.indexOf('<h3>Assessment History</h3>');
    const yearBuiltIdx = html.indexOf('Year built'); // last property-fact row
    const ladderHeaderIdx = html.indexOf('Indicated value'); // a column header unique to the primary ladder table
    expect(headingIdx).toBeGreaterThan(-1);
    expect(headingIdx).toBeGreaterThan(yearBuiltIdx);
    expect(headingIdx).toBeLessThan(ladderHeaderIdx);
    // The real per-year comparison renders as <table> rows, not as flattened dl.rows lines.
    expect(html).toContain('<td>2025</td><td>$7,600,000</td><td>$7,410,000</td><td>2.9%</td>');
  });

  it('leads with the analyst-edited warning banner before any section content', () => {
    const edited: AssumptionRow = { ...salesAssumptions[0], Source: 'Analyst', SourceRef: 'analyst override' };
    const model = buildAppealExport(baseInput({ assumptions: [...incomeAssumptions, edited] }));
    const html = exportToDocument(model, new Set<PrintSection>(['Cover']));
    const warnIdx = html.indexOf('Hand-edited by the analyst');
    const firstSectionIdx = html.indexOf('<h2>');
    expect(warnIdx).toBeGreaterThan(-1);
    expect(warnIdx).toBeLessThan(firstSectionIdx);
  });

  it('is a self-contained document: no network fetches, no external scripts', () => {
    const model = buildAppealExport(baseInput());
    const html = exportToDocument(model, new Set<PrintSection>(['Cover']));
    expect(html).not.toContain('<script src=');
    expect(html).not.toContain('fetch(');
    expect(html).toContain('window.print()');
  });

  it('escapes HTML-significant characters from analysis comments', () => {
    const model = buildAppealExport(baseInput({ analysis: { ...analysis, Comments: '<b>bold</b> & "quoted"' } }));
    const html = exportToDocument(model, new Set<PrintSection>(['Cover']));
    expect(html).not.toContain('<b>bold</b>');
    expect(html).toContain('&lt;b&gt;bold&lt;/b&gt;');
  });

  /**
   * Fix 3 (final whole-plan review): `LANDSCAPE_SECTIONS`/`wide` existed with a comment promising
   * landscape "like the Tax Bill schedule," but the `@page` rule was hardcoded `letter portrait`
   * regardless -- `wide` only ever changed the on-screen `.sheet` max-width, never the print CSS
   * `window.print()` actually reads. Only Sales needs landscape per the design (its comp table
   * runs one column per adjustment factor); every other section stays portrait.
   */
  it('the document is landscape when Sales is among the requested sections', () => {
    const model = buildAppealExport(baseInput());
    const html = exportToDocument(model, new Set<PrintSection>(['Cover', 'Sales']));
    expect(html).toContain('@page { size: letter landscape; margin: 0.5in; }');
    expect(html).not.toContain('@page { size: letter portrait; margin: 0.5in; }');
  });

  it('the document stays portrait when Sales is not among the requested sections', () => {
    const model = buildAppealExport(baseInput());
    const html = exportToDocument(model, new Set<PrintSection>(['Cover', 'Income']));
    expect(html).toContain('@page { size: letter portrait; margin: 0.5in; }');
    expect(html).not.toContain('@page { size: letter landscape; margin: 0.5in; }');
  });

  it('the document stays portrait for the full section set when Sales itself is excluded from `include` even though present in the model', () => {
    const model = buildAppealExport(baseInput());
    const allButSales = (Object.keys(model.sections) as PrintSection[]).filter((k) => k !== 'Sales');
    const html = exportToDocument(model, new Set(allButSales));
    expect(html).toContain('@page { size: letter portrait; margin: 0.5in; }');
  });
});

function escapeForAssert(s: string): string {
  return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}
