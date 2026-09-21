import { describe, it, expect } from 'vitest';
import { EntityReader, ReadQuery, loadSubject, listAnalyses, loadAnalysis, finalAV, subjectFacts, marketFacts, sqlLiteral } from './analysis-store';

/** A fake reader that answers by entity name and records every query. */
function fakeReader(answers: Record<string, unknown[]>): EntityReader & { queries: ReadQuery[] } {
  const queries: ReadQuery[] = [];
  return { queries, async run<T>(q: ReadQuery): Promise<T[]> { queries.push(q); return (answers[q.entity] ?? []) as T[]; } };
}

const parcel = { ID: 'P1', ParcelNumber: '490000000000000000', GISParcelNumber: '1234567', Address: '8800 SAMPLE PKWY', OwnerName: 'OWNER LLC', PropertyClassCode: '441', CountyNumber: 49 };
const record = { ID: 'R1', ParcelID: 'P1', TaxYear: 2026, EstimatedSqFt: 42000, ComparisonUnitType: 'SF', ComparisonUnitCount: 42000, YearBuilt: 1998, Neighborhood: '49-ABC', TaxRate: 2.98, AssessedTotalAV: 8150000, Acreage: '4.1', PropertySubClassDescription: 'Retail center' };
const assessments = [
  { ID: 'A26', ParcelID: 'P1', AssessmentYear: 2026, Source: 'MarionPRC', OriginalTotalAV: 8150000, PTABOATotalAV: null },
  { ID: 'A25', ParcelID: 'P1', AssessmentYear: 2025, Source: 'MarionPRC', OriginalTotalAV: 7600000, PTABOATotalAV: 7410000 },
  { ID: 'A25d', ParcelID: 'P1', AssessmentYear: 2025, Source: 'DLGF', OriginalTotalAV: 7600000, PTABOATotalAV: null },
];

describe('loadSubject', () => {
  it('assembles the bundle, bounding every query and filtering by the parcel', async () => {
    const reader = fakeReader({
      'Parcels': [parcel], 'County Assessor Records': [record], 'Assessments': assessments,
      'Valuation Analysis': [{ ID: 'V1', ParcelID: 'P1', PropertyTypeGroup: 'Retail', SalesIndicatedValue: 7050000, IncomeIndicatedValue: 6720000, CostProxyValue: 8640000, CurrentTotalAV: 8150000, GeneratedAt: '2026-08-30' }],
      'Valuation Comps': [{ ID: 'C1', ValuationAnalysisID: 'V1', SimilarityRank: 1 }],
      'Comparable Assessment Sets': [{ ID: 'S1', SubjectParcelID: 'P1', NeighborhoodMedianPerUnit: 178, SubjectDenomValue: 42000 }],
      'Comparable Assessment Members': [{ ID: 'M1', ComparableAssessmentSetID: 'S1', ComparableParcelID: 'P2', GeographyBucket: 'Neighborhood', IsSelected: true }],
      'PTABOA Appeals': [], 'IBTR Appeals': [],
      'Co Star Income Inputs': [{ ID: 'K1', ParcelID: 'P1', AvgEffectiveRentPerSF: 14.5, VacancyPct: 8, Submarket: 'North' }],
      'Market Assumptions': [{ ID: 'MA1', AssumptionType: 'CapRate', PropertyTypeGroup: 'Retail', PeriodYear: 2026, Value: 0.0775, Method: 'SalesExtraction' }],
    });
    const b = await loadSubject(reader, 'P1');
    expect(b).not.toBeNull();
    expect(b!.typeGroup).toBe('Retail');
    expect(b!.comps).toHaveLength(1);
    expect(b!.compMembers).toHaveLength(1);
    for (const q of reader.queries) expect(q.maxRows).toBeGreaterThan(0);
    expect(reader.queries.find((q) => q.entity === 'Valuation Comps')!.filter).toContain("ValuationAnalysisID = 'V1'");
    expect(reader.queries.find((q) => q.entity === 'Assessments')!.filter).toContain("ParcelID = 'P1'");
  });
  it('returns null when the parcel does not exist', async () => {
    expect(await loadSubject(fakeReader({}), 'nope')).toBeNull();
  });
  it('facts: County SF and rate, Market rent/vacancy from CoStar and cap from MarketAssumption', async () => {
    const reader = fakeReader({ 'Parcels': [parcel], 'County Assessor Records': [record], 'Assessments': assessments,
      'Valuation Analysis': [{ ID: 'V1', ParcelID: 'P1', PropertyTypeGroup: 'Retail' }],
      'Co Star Income Inputs': [{ ID: 'K1', ParcelID: 'P1', AvgEffectiveRentPerSF: 14.5, VacancyPct: 8 }],
      'Market Assumptions': [{ ID: 'MA1', AssumptionType: 'CapRate', PropertyTypeGroup: 'Retail', PeriodYear: 2026, Value: 0.0775, Method: 'SalesExtraction' }, { ID: 'MA0', AssumptionType: 'CapRate', PropertyTypeGroup: 'Retail', PeriodYear: 2025, Value: 0.07, Method: 'SalesExtraction' }] });
    const b = (await loadSubject(reader, 'P1'))!;
    expect(subjectFacts(b)).toEqual({ typeGroup: 'Retail', sqFt: 42000, units: null, yearBuilt: 1998, taxRatePer100: 2.98 });
    const m = marketFacts(b);
    expect(m.rentPerSF).toBe(14.5);
    expect(m.vacancyPct).toBe(0.08);
    expect(m.capRate).toBe(0.0775);
    expect(m.capRef).toContain('2026');
  });
  it('converts a CoStar VacancyPct stored as a percent (8) to a decimal (0.08), and leaves a MarketAssumption vacancy decimal alone', async () => {
    const withCoStar = fakeReader({ 'Parcels': [parcel], 'County Assessor Records': [record], 'Assessments': assessments,
      'Valuation Analysis': [{ ID: 'V1', ParcelID: 'P1', PropertyTypeGroup: 'Retail' }],
      'Co Star Income Inputs': [{ ID: 'K1', ParcelID: 'P1', AvgEffectiveRentPerSF: 14.5, VacancyPct: 12 }],
    });
    const b1 = (await loadSubject(withCoStar, 'P1'))!;
    expect(marketFacts(b1).vacancyPct).toBe(0.12);

    const withAssumptionOnly = fakeReader({ 'Parcels': [parcel], 'County Assessor Records': [record], 'Assessments': assessments,
      'Valuation Analysis': [{ ID: 'V1', ParcelID: 'P1', PropertyTypeGroup: 'Retail' }],
      'Market Assumptions': [{ ID: 'MA1', AssumptionType: 'Vacancy', PropertyTypeGroup: 'Retail', PeriodYear: 2026, Value: 0.08, Method: 'Survey' }],
    });
    const b2 = (await loadSubject(withAssumptionOnly, 'P1'))!;
    expect(marketFacts(b2).vacancyPct).toBe(0.08);
  });
  it('divides an annual MarketAssumption MarketRentPerUnit by 12 to get a monthly Multifamily rent when no CoStar row exists', async () => {
    const reader = fakeReader({ 'Parcels': [parcel], 'County Assessor Records': [record], 'Assessments': assessments,
      'Valuation Analysis': [{ ID: 'V1', ParcelID: 'P1', PropertyTypeGroup: 'Multifamily' }],
      'Market Assumptions': [{ ID: 'MA1', AssumptionType: 'MarketRentPerUnit', PropertyTypeGroup: 'Multifamily', PeriodYear: 2026, Value: 15000, Method: 'Survey' }],
    });
    const b = (await loadSubject(reader, 'P1'))!;
    expect(marketFacts(b).rentPerUnitMonthly).toBe(1250);
  });
  it('I2: prefers the group-level (null-submarket) MarketAssumption row when the subject has no CoStar submarket match', async () => {
    const reader = fakeReader({ 'Parcels': [parcel], 'County Assessor Records': [record], 'Assessments': assessments,
      'Valuation Analysis': [{ ID: 'V1', ParcelID: 'P1', PropertyTypeGroup: 'Retail' }],
      'Market Assumptions': [
        { ID: 'MA-N', AssumptionType: 'MarketRentPerSqFt', PropertyTypeGroup: 'Retail', Submarket: 'North', PeriodYear: 2026, Value: 16, Method: 'Survey' },
        { ID: 'MA-G', AssumptionType: 'MarketRentPerSqFt', PropertyTypeGroup: 'Retail', Submarket: null, PeriodYear: 2026, Value: 14, Method: 'Survey' },
      ] });
    const b = (await loadSubject(reader, 'P1'))!;
    expect(marketFacts(b).rentPerSF).toBe(14);
  });
  it("I2: prefers the submarket row matching the subject's CoStar submarket over the group row, and names it in the ref", async () => {
    const reader = fakeReader({ 'Parcels': [parcel], 'County Assessor Records': [record], 'Assessments': assessments,
      'Valuation Analysis': [{ ID: 'V1', ParcelID: 'P1', PropertyTypeGroup: 'Retail' }],
      'Co Star Income Inputs': [{ ID: 'K1', ParcelID: 'P1', Submarket: 'North' }],
      'Market Assumptions': [
        { ID: 'MA-N', AssumptionType: 'MarketRentPerSqFt', PropertyTypeGroup: 'Retail', Submarket: 'North', PeriodYear: 2026, Value: 16, Method: 'Survey' },
        { ID: 'MA-G', AssumptionType: 'MarketRentPerSqFt', PropertyTypeGroup: 'Retail', Submarket: null, PeriodYear: 2026, Value: 14, Method: 'Survey' },
      ] });
    const b = (await loadSubject(reader, 'P1'))!;
    const m = marketFacts(b);
    expect(m.rentPerSF).toBe(16);
    expect(m.rentRef).toContain('North');
  });
  it("I6: prefers CoStar's own property cap rate over the MarketAssumption cap rate when present", async () => {
    const reader = fakeReader({ 'Parcels': [parcel], 'County Assessor Records': [record], 'Assessments': assessments,
      'Valuation Analysis': [{ ID: 'V1', ParcelID: 'P1', PropertyTypeGroup: 'Retail' }],
      'Co Star Income Inputs': [{ ID: 'K1', ParcelID: 'P1', CapRate: 0.069 }],
      'Market Assumptions': [{ ID: 'MA1', AssumptionType: 'CapRate', PropertyTypeGroup: 'Retail', PeriodYear: 2026, Value: 0.0775, Method: 'SalesExtraction' }] });
    const b = (await loadSubject(reader, 'P1'))!;
    const m = marketFacts(b);
    expect(m.capRate).toBe(0.069);
    expect(m.capRef).toBe('CoStar property cap rate');
  });
});

describe('memberParcels — I8: comps resolved to a GIS number and address, not a raw GUID', () => {
  it('runs one bounded Parcels IN-read only when comp members exist, keyed by member ID', async () => {
    const reader = fakeReader({
      'Parcels': [parcel, { ID: 'P2', ParcelNumber: 'x', GISParcelNumber: '7654321', Address: '100 OTHER ST', OwnerName: null, PropertyClassCode: null, CountyNumber: 49 }],
      'County Assessor Records': [record], 'Assessments': assessments,
      'Valuation Analysis': [{ ID: 'V1', ParcelID: 'P1', PropertyTypeGroup: 'Retail' }],
      'Comparable Assessment Sets': [{ ID: 'S1', SubjectParcelID: 'P1' }],
      'Comparable Assessment Members': [{ ID: 'M1', ComparableAssessmentSetID: 'S1', ComparableParcelID: 'P2', GeographyBucket: 'Neighborhood', IsSelected: true }],
    });
    const b = (await loadSubject(reader, 'P1'))!;
    expect(b.memberParcels['P2']).toEqual({ GISParcelNumber: '7654321', Address: '100 OTHER ST' });
    expect(reader.queries.filter((q) => q.entity === 'Parcels')).toHaveLength(2); // subject parcel + the member IN-read
  });
  it('skips the Parcels IN-read, and returns an empty map, when there are no comp members', async () => {
    const reader = fakeReader({ 'Parcels': [parcel], 'County Assessor Records': [record], 'Assessments': assessments,
      'Valuation Analysis': [{ ID: 'V1', ParcelID: 'P1', PropertyTypeGroup: 'Retail' }] });
    const b = (await loadSubject(reader, 'P1'))!;
    expect(reader.queries.filter((q) => q.entity === 'Parcels')).toHaveLength(1); // just the subject parcel read
    expect(b.memberParcels).toEqual({});
  });
});

describe('ENTITIES guard (C1) — every read touches only these fifteen registered entity names', () => {
  it('records every q.entity across loadSubject, listAnalyses and loadAnalysis, and each is in the golden list', async () => {
    const GOLDEN_ENTITY_NAMES = [
      'Parcels',
      'County Assessor Records',
      'Assessments',
      'Valuation Analysis',
      'Valuation Comps',
      'Comparable Assessment Sets',
      'Comparable Assessment Members',
      'Market Assumptions',
      'Co Star Income Inputs',
      'PTABOA Appeals',
      'IBTR Appeals',
      'Appeal Analysis',
      'Appeal Analysis Assumptions',
      'Appeal Analysis Indications',
      'Appeal Analysis Comp Decisions',
    ];
    const reader = fakeReader({
      'Parcels': [parcel, { ID: 'P2', ParcelNumber: 'x', GISParcelNumber: '7654321', Address: '100 OTHER ST', OwnerName: null, PropertyClassCode: null, CountyNumber: 49 }],
      'County Assessor Records': [record], 'Assessments': assessments,
      'Valuation Analysis': [{ ID: 'V1', ParcelID: 'P1', PropertyTypeGroup: 'Retail' }],
      'Comparable Assessment Sets': [{ ID: 'S1', SubjectParcelID: 'P1' }],
      'Comparable Assessment Members': [{ ID: 'M1', ComparableAssessmentSetID: 'S1', ComparableParcelID: 'P2', GeographyBucket: 'Neighborhood', IsSelected: true }],
      'PTABOA Appeals': [], 'IBTR Appeals': [], 'Co Star Income Inputs': [],
      'Market Assumptions': [],
      'Appeal Analysis': [{ ID: 'X1', ParcelID: 'P1', Name: 'n', Status: 'Draft' }],
      'Appeal Analysis Assumptions': [], 'Appeal Analysis Indications': [],
      'Appeal Analysis Comp Decisions': [],
    });
    await loadSubject(reader, 'P1');
    await listAnalyses(reader, 'P1');
    await loadAnalysis(reader, 'X1');
    expect(reader.queries.length).toBeGreaterThan(0);
    for (const q of reader.queries) expect(GOLDEN_ENTITY_NAMES).toContain(q.entity);
  });
});

describe('finalAV — as finally determined', () => {
  it('prefers the PTABOA value, and the MarionPRC source over DLGF', () => {
    expect(finalAV(assessments as never, 2025)).toBe(7410000);
    expect(finalAV(assessments as never, 2026)).toBe(8150000);
    expect(finalAV(assessments as never, 2024)).toBeNull();
  });
  it('never falls through to another source once a MarionPRC row exists for the year', () => {
    const rows = [
      { ID: 'A', ParcelID: 'P1', AssessmentYear: 2025, Source: 'MarionPRC', OriginalTotalAV: 100, PTABOATotalAV: null },
      { ID: 'B', ParcelID: 'P1', AssessmentYear: 2025, Source: 'DLGF', OriginalTotalAV: 95, PTABOATotalAV: 90 },
    ];
    expect(finalAV(rows as never, 2025)).toBe(100);
  });
  it('uses the DLGF PTABOA value when no MarionPRC row exists for the year', () => {
    const rows = [
      { ID: 'B', ParcelID: 'P1', AssessmentYear: 2025, Source: 'DLGF', OriginalTotalAV: 95, PTABOATotalAV: 90 },
    ];
    expect(finalAV(rows as never, 2025)).toBe(90);
  });
});

describe('analyses', () => {
  it('lists newest first and loads one with its rows', async () => {
    const reader = fakeReader({
      'Appeal Analysis': [{ ID: 'X1', ParcelID: 'P1', Name: 'n', Status: 'Draft' }],
      'Appeal Analysis Assumptions': [{ ID: 'S', AppealAnalysisID: 'X1', Section: 'Income', AssumptionKey: 'cap_rate', Value: 0.0775 }],
      'Appeal Analysis Indications': [{ ID: 'I', AppealAnalysisID: 'X1', Approach: 'Income', Status: 'Computed' }],
    });
    const list = await listAnalyses(reader, 'P1');
    expect(list).toHaveLength(1);
    expect(reader.queries[0].orderBy).toBe('__mj_CreatedAt DESC');
    const one = await loadAnalysis(reader, 'X1');
    expect(one!.assumptions).toHaveLength(1);
    expect(one!.indications).toHaveLength(1);
  });
  it('loadAnalysis returns compDecisions from a fake Appeal Analysis Comp Decisions read', async () => {
    const reader = fakeReader({
      'Appeal Analysis': [{ ID: 'X1', ParcelID: 'P1', Name: 'n', Status: 'Draft' }],
      'Appeal Analysis Comp Decisions': [
        { ID: 'D1', AppealAnalysisID: 'X1', SaleTransactionID: 'ST1', IsIncluded: true, SortOrder: 1 },
        { ID: 'D2', AppealAnalysisID: 'X1', SaleTransactionID: 'ST2', IsIncluded: false, SortOrder: null },
      ],
    });
    const one = await loadAnalysis(reader, 'X1');
    expect(one!.compDecisions).toHaveLength(2);
    expect(one!.compDecisions[0]).toEqual({ ID: 'D1', AppealAnalysisID: 'X1', SaleTransactionID: 'ST1', IsIncluded: true, SortOrder: 1 });
    expect(reader.queries.find((q) => q.entity === 'Appeal Analysis Comp Decisions')!.filter).toContain("AppealAnalysisID = 'X1'");
  });
});

describe('subjectGradeOrdinal', () => {
  it('is unconditionally null and issues no read for it (Ruling 6: no live entity to read GradeOrdinal from)', async () => {
    const reader = fakeReader({
      'Parcels': [parcel], 'County Assessor Records': [record], 'Assessments': assessments,
      'Valuation Analysis': [{ ID: 'V1', ParcelID: 'P1', PropertyTypeGroup: 'Retail' }],
    });
    const b = (await loadSubject(reader, 'P1'))!;
    expect(b.subjectGradeOrdinal).toBeNull();
    expect(reader.queries.some((q) => q.entity === 'Parcel Physical Profiles')).toBe(false);
  });
});

describe('sqlLiteral', () => { it('doubles quotes', () => { expect(sqlLiteral("O'BRIEN")).toBe("O''BRIEN"); }); });
