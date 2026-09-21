/**
 * Every read Analyze a Property makes, behind one EntityReader so the component owns the
 * MJ plumbing and this file stays testable with a fake. Every query is bounded (MaxRows).
 * Row types name the entity fields actually read; anything else stays out.
 */
import { Approach, IndicationStatus, AskPolicy, Recommendation } from './appeal-rules';
import { AssumptionMode, AssumptionSource, TypeGroup, SubjectFacts, MarketFacts } from './analysis-defaults';

export interface ReadQuery { entity: string; fields?: string[]; filter: string; orderBy?: string; maxRows?: number; }
export interface EntityReader { run<T>(q: ReadQuery): Promise<T[]>; }
export const sqlLiteral = (s: string): string => s.replace(/'/g, "''");

export const CURRENT_ASSESSMENT_YEAR = 2026;
export const MARION_COUNTY_NUMBER = 49;

/**
 * The fifteen registered entity names this store (and the shell) may read or write. C1:
 * 'Valuation Analysis' is singular — the plural form does not resolve.
 * There is no live MJ entity for `ParcelPhysicalProfile`/grade data as of 2026-09-16 (confirmed
 * by direct grep of the generated entity registry) — the view described in
 * `Indiana_Tax_Expert/docs/proposals/parcel_physical_profile.sql` appears not to have been
 * migrated + CodeGen'd into this worktree yet. `loadSubject`'s `subjectGradeOrdinal` is therefore
 * unconditionally `null` and issues no read at all (Ruling 6) — MJ's `RunView` surfaces a
 * user-visible error toast for an unresolvable entity name regardless of what the caller does
 * with the resulting rejection, so a name that is known in advance to never resolve must not be
 * queried, not merely caught.
 */
export const ENTITIES = {
  parcels: 'Parcels',
  countyRecords: 'County Assessor Records',
  assessments: 'Assessments',
  valuationAnalysis: 'Valuation Analysis',
  valuationComps: 'Valuation Comps',
  compSets: 'Comparable Assessment Sets',
  compMembers: 'Comparable Assessment Members',
  marketAssumptions: 'Market Assumptions',
  costar: 'Co Star Income Inputs',
  ptaboa: 'PTABOA Appeals',
  ibtr: 'IBTR Appeals',
  appealAnalysis: 'Appeal Analysis',
  appealAssumptions: 'Appeal Analysis Assumptions',
  appealIndications: 'Appeal Analysis Indications',
  compDecisions: 'Appeal Analysis Comp Decisions',
} as const;

export interface ParcelRow { ID: string; ParcelNumber: string; GISParcelNumber: string | null; Address: string | null; OwnerName: string | null; PropertyClassCode: string | null; CountyNumber: number | null; }
export interface CountyRecordRow { ID: string; ParcelID: string; TaxYear: number | null; EstimatedSqFt: number | null; ComparisonUnitType: string | null; ComparisonUnitCount: number | null; YearBuilt: number | null; Neighborhood: string | null; TaxRate: number | null; AssessedTotalAV: number | null; AssessedLandAV: number | null; AssessedImprovementAV: number | null; Acreage: string | null; PropertySubClassDescription: string | null; PropertyClass: string | null; }
export interface AssessmentRow { ID: string; ParcelID: string; AssessmentYear: number; Source: string; OriginalTotalAV: number | null; PTABOATotalAV: number | null; OriginalLandAV?: number | null; OriginalImprovementAV?: number | null; }
export interface ValuationAnalysisRow { ID: string; ParcelID: string; PropertyTypeGroup: string | null; CurrentTotalAV: number | null; SalesIndicatedValue: number | null; SalesMethodNote: string | null; IncomeIndicatedValue: number | null; IncomeMethodNote: string | null; CostProxyValue: number | null; CostProxyNote: string | null; ReconciledTargetValue: number | null; LowestSupportedValue: number | null; Recommendation: string | null; ConfidenceTier: string | null; CompCount: number | null; MethodologyVersion: string | null; GeneratedAt: string | null; }
export interface ValuationCompRow { ID: string; ValuationAnalysisID: string; SaleTransactionID: string; CompAddress: string | null; CompSubmarket: string | null; SaleDate: string | null; SalePrice: number | null; CompDenominator: number | null; CompYearBuilt: number | null; CompGradeOrdinal: number | null; UnitOfComparison: string; RawPerUnit: number | null; SizeAdjPct: number | null; AgeAdjPct: number | null; GradeAdjPct: number | null; TimeAdjPct: number | null; NetAdjPct: number | null; GrossAdjPct: number | null; AdjustedPerUnit: number | null; SubjectIndicatedValue: number | null; SimilarityRank: number | null; IsSelected: boolean; DropReason: string | null; }
export interface CompDecisionRow { ID: string; AppealAnalysisID: string; SaleTransactionID: string; IsIncluded: boolean; SortOrder: number | null; }
export interface CompSetRow { ID: string; SubjectParcelID: string; UnitOfComparison: string; HeadlineTrack: string; SubjectDenomValue: number | null; SubjectEffectiveAV: number | null; SubjectPerUnitEffective: number | null; NeighborhoodCode: string | null; NeighborhoodCompCount: number | null; NeighborhoodMedianPerUnit: number | null; NeighborhoodMeanPerUnit: number | null; CountyCompCount: number | null; CountyMedianPerUnit: number | null; CountyMeanPerUnit: number | null; GeneratedAt: string | null; }
export interface CompMemberRow { ID: string; ComparableAssessmentSetID: string; ComparableParcelID: string; GeographyBucket: 'Neighborhood' | 'County'; SimilarityScore: number | null; SortOrder: number | null; IsSelected: boolean; ComparableBuildingSqFt: number | null; ComparableUnitCount: number | null; ComparableGradeCode: string | null; DenomValue: number | null; OriginalAV: number | null; AppealedAV: number | null; AppealLevel: string | null; AppealPctChange: number | null; AppealRepresentative: string | null; EffectiveAV: number | null; OriginalPerUnit: number | null; EffectivePerUnit: number | null; }
export interface MarketAssumptionRow { ID: string; AssumptionType: string; PropertyTypeGroup: string; Submarket: string | null; PeriodYear: number | null; PeriodLabel: string | null; Value: number; LowValue: number | null; HighValue: number | null; SampleSize: number | null; Method: string; SourceNote: string | null; }
export interface CoStarIncomeRow { ID: string; ParcelID: string | null; PropertyTypeGroup: string | null; Submarket: string | null; PropertyName: string | null; Units: number | null; RBA: number | null; AvgEffectiveRentPerUnit: number | null; AvgEffectiveRentPerSF: number | null; VacancyPct: number | null; CapRate: number | null; }
export interface PTABOARow { ID: string; ParcelID: string; HearingDate: string | null; DecisionStatus: string | null; Circumstances: string | null; [k: string]: unknown; }
export interface IBTRRow { ID: string; ParcelID: string | null; PetitionNumber: string; PetitionerName: string | null; AppealType: string | null; DecisionDate: string | null; DispositionType: string; Summary: string | null; UseCategory: string | null; }
export interface AnalysisRow { ID: string; ParcelID: string; AssessmentYear: number; Name: string; PropertyTypeGroup: string | null; Status: 'Draft' | 'Final'; UnitOfComparison: '$/SF' | '$/unit'; SubjectDenominator: number | null; CurrentTotalAV: number | null; PriorTotalAV: number | null; BurdenOnAssessor: boolean | null; AskPolicy: AskPolicy; RequestedValue: number | null; RequestedValueApproach: string | null; FloorValue: number | null; FloorApproach: string | null; Recommendation: Recommendation | null; EstimatedTaxSavings: number | null; SavingsRate: number | null; Comments: string | null; ValuationAnalysisID: string | null; ComparableAssessmentSetID: string | null; __mj_CreatedAt?: string; __mj_UpdatedAt?: string; }
export interface AssumptionRow { ID: string; AppealAnalysisID: string; Section: string; AssumptionKey: string; Label: string; Value: number | null; Unit: string | null; Mode: AssumptionMode; Source: AssumptionSource; SourceRef: string | null; ProposedValue: number | null; ProposedSource: string | null; SortOrder: number; }
export interface IndicationRow { ID: string; AppealAnalysisID: string; Approach: Approach; IndicatedValue: number | null; PerUnit: number | null; PctOfAV: number | null; Credible: boolean; Supports: boolean; Status: IndicationStatus; Rationale: string | null; ComputedAt: string | null; }

export interface MemberParcelInfo { GISParcelNumber: string | null; Address: string | null; }
export interface SubjectBundle { parcel: ParcelRow; record: CountyRecordRow | null; assessments: AssessmentRow[]; valuation: ValuationAnalysisRow | null; comps: ValuationCompRow[]; compSet: CompSetRow | null; compMembers: CompMemberRow[]; memberParcels: Record<string, MemberParcelInfo>; ptaboa: PTABOARow[]; ibtr: IBTRRow[]; costar: CoStarIncomeRow | null; marketAssumptions: MarketAssumptionRow[]; typeGroup: TypeGroup; subjectGradeOrdinal: number | null; }

const GROUPS: TypeGroup[] = ['Retail', 'Office', 'Industrial', 'Multifamily'];
function toTypeGroup(g: string | null | undefined): TypeGroup { return (GROUPS as string[]).includes(g ?? '') ? (g as TypeGroup) : 'Other'; }

export async function loadSubject(reader: EntityReader, parcelId: string): Promise<SubjectBundle | null> {
  const id = sqlLiteral(parcelId);
  const [parcel] = await reader.run<ParcelRow>({ entity: ENTITIES.parcels, filter: `ID = '${id}'`, maxRows: 1 });
  if (!parcel) return null;
  const [records, assessments, valuations, compSets, ptaboa, ibtr, costars] = await Promise.all([
    reader.run<CountyRecordRow>({ entity: ENTITIES.countyRecords, filter: `ParcelID = '${id}'`, orderBy: 'TaxYear DESC', maxRows: 1 }),
    reader.run<AssessmentRow>({ entity: ENTITIES.assessments, filter: `ParcelID = '${id}' AND AssessmentYear >= ${CURRENT_ASSESSMENT_YEAR - 2}`, orderBy: 'AssessmentYear DESC', maxRows: 20 }),
    reader.run<ValuationAnalysisRow>({ entity: ENTITIES.valuationAnalysis, filter: `ParcelID = '${id}'`, orderBy: 'GeneratedAt DESC', maxRows: 1 }),
    reader.run<CompSetRow>({ entity: ENTITIES.compSets, filter: `SubjectParcelID = '${id}'`, orderBy: 'GeneratedAt DESC', maxRows: 1 }),
    reader.run<PTABOARow>({ entity: ENTITIES.ptaboa, filter: `ParcelID = '${id}'`, orderBy: 'HearingDate DESC', maxRows: 50 }),
    reader.run<IBTRRow>({ entity: ENTITIES.ibtr, filter: `ParcelID = '${id}'`, orderBy: 'DecisionDate DESC', maxRows: 50 }),
    reader.run<CoStarIncomeRow>({ entity: ENTITIES.costar, filter: `ParcelID = '${id}'`, maxRows: 1 }),
  ]);
  // See the ENTITIES doc-comment: 'Parcel Physical Profiles' is an unverified guess -- no live
  // MJ entity was found for it as of 2026-09-16 (confirmed by direct grep of the generated
  // entity registry). A prior version of this code still issued the RunView call wrapped in
  // .catch() so a rejected promise wouldn't fail the rest of the subject load, but MJ's own
  // RunView plumbing surfaces a user-visible error toast for an unresolvable entity name
  // independent of what the caller does with the resulting rejection or throw -- the .catch()
  // stopped `loadSubject` from crashing, but never stopped the toast. Since the outcome is
  // already known with certainty (this entity cannot resolve), there is nothing to gain by
  // attempting the read at all: subjectGradeOrdinal is null unconditionally until a real
  // ParcelPhysicalProfile-equivalent entity is registered with MJ (Ruling 6).
  const subjectGradeOrdinal: number | null = null;
  const valuation = valuations[0] ?? null;
  const compSet = compSets[0] ?? null;
  const typeGroup = toTypeGroup(valuation?.PropertyTypeGroup ?? costars[0]?.PropertyTypeGroup);
  const [comps, compMembers, marketAssumptions] = await Promise.all([
    valuation ? reader.run<ValuationCompRow>({ entity: ENTITIES.valuationComps, filter: `ValuationAnalysisID = '${sqlLiteral(valuation.ID)}'`, orderBy: 'SimilarityRank ASC', maxRows: 200 }) : Promise.resolve([]),
    compSet ? reader.run<CompMemberRow>({ entity: ENTITIES.compMembers, filter: `ComparableAssessmentSetID = '${sqlLiteral(compSet.ID)}'`, orderBy: 'GeographyBucket ASC, SortOrder ASC', maxRows: 100 }) : Promise.resolve([]),
    reader.run<MarketAssumptionRow>({ entity: ENTITIES.marketAssumptions, filter: `PropertyTypeGroup IN ('${sqlLiteral(typeGroup)}', 'All')`, orderBy: 'PeriodYear DESC', maxRows: 200 }),
  ]);
  // I8: comps were shown as raw GUIDs — resolve the member parcels' GIS number and address in one bounded IN-read.
  const memberIds = Array.from(new Set(compMembers.map((m) => m.ComparableParcelID)));
  const memberParcels: Record<string, MemberParcelInfo> = {};
  if (memberIds.length) {
    const rows = await reader.run<{ ID: string; GISParcelNumber: string | null; Address: string | null }>({
      entity: ENTITIES.parcels,
      filter: `ID IN (${memberIds.map(sqlLiteral).map((x) => `'${x}'`).join(',')})`,
      fields: ['ID', 'GISParcelNumber', 'Address'],
      maxRows: 200,
    });
    for (const r of rows) memberParcels[r.ID] = { GISParcelNumber: r.GISParcelNumber, Address: r.Address };
  }
  return { parcel, record: records[0] ?? null, assessments, valuation, comps, compSet, compMembers, memberParcels, ptaboa, ibtr, costar: costars[0] ?? null, marketAssumptions, typeGroup, subjectGradeOrdinal };
}

export async function listAnalyses(reader: EntityReader, parcelId: string): Promise<AnalysisRow[]> {
  return reader.run<AnalysisRow>({ entity: ENTITIES.appealAnalysis, filter: `ParcelID = '${sqlLiteral(parcelId)}'`, orderBy: '__mj_CreatedAt DESC', maxRows: 50 });
}

export async function loadAnalysis(reader: EntityReader, analysisId: string): Promise<{ analysis: AnalysisRow; assumptions: AssumptionRow[]; indications: IndicationRow[]; compDecisions: CompDecisionRow[] } | null> {
  const id = sqlLiteral(analysisId);
  const [analysis] = await reader.run<AnalysisRow>({ entity: ENTITIES.appealAnalysis, filter: `ID = '${id}'`, maxRows: 1 });
  if (!analysis) return null;
  const [assumptions, indications, compDecisions] = await Promise.all([
    reader.run<AssumptionRow>({ entity: ENTITIES.appealAssumptions, filter: `AppealAnalysisID = '${id}'`, orderBy: 'Section ASC, SortOrder ASC', maxRows: 500 }),
    reader.run<IndicationRow>({ entity: ENTITIES.appealIndications, filter: `AppealAnalysisID = '${id}'`, maxRows: 10 }),
    reader.run<CompDecisionRow>({ entity: ENTITIES.compDecisions, filter: `AppealAnalysisID = '${id}'`, maxRows: 200 }),
  ]);
  return { analysis, assumptions, indications, compDecisions };
}

/**
 * The value "as finally determined" for a year: the record card beats the DLGF roll on
 * "as finally determined" (this project's standing rule) — a MarionPRC row for the year, if
 * any exists, is the ONLY source considered; only when no MarionPRC row exists for the year
 * does another source's row win. Once the winning row is picked, its own PTABOA value applies
 * if any, else its own original value. Never fall through to another source's PTABOA once a
 * MarionPRC row exists.
 */
export function finalAV(rows: AssessmentRow[], year: number): number | null {
  const ofYear = rows.filter((r) => r.AssessmentYear === year);
  const winner = ofYear.find((r) => r.Source === 'MarionPRC') ?? ofYear[0];
  if (!winner) return null;
  return winner.PTABOATotalAV ?? winner.OriginalTotalAV ?? null;
}

export function subjectFacts(b: SubjectBundle): SubjectFacts {
  const r = b.record;
  const units = r?.ComparisonUnitType === 'Unit' ? r.ComparisonUnitCount : b.costar?.Units ?? null;
  return { typeGroup: b.typeGroup, sqFt: r?.EstimatedSqFt ?? b.costar?.RBA ?? null, units, yearBuilt: r?.YearBuilt ?? null, taxRatePer100: r?.TaxRate ?? null };
}

/**
 * I2: a group-level row (Submarket == null) is preferred by default; a submarket-level row is
 * used ONLY when its Submarket equals the subject's own CoStar submarket, and then it wins over
 * the group row (a more specific match beats the general one). 'All' is the last-resort fallback.
 */
function latest(rows: MarketAssumptionRow[], type: string, group: string, submarket: string | null): MarketAssumptionRow | null {
  const byYear = (a: MarketAssumptionRow, b: MarketAssumptionRow): number => (b.PeriodYear ?? 0) - (a.PeriodYear ?? 0);
  const ofGroup = rows.filter((r) => r.AssumptionType === type && r.PropertyTypeGroup === group);
  const submarketMatch = submarket != null ? ofGroup.filter((r) => r.Submarket === submarket).sort(byYear)[0] : undefined;
  const groupLevel = ofGroup.filter((r) => r.Submarket == null).sort(byYear)[0];
  return submarketMatch ?? groupLevel
    ?? rows.filter((r) => r.AssumptionType === type && r.PropertyTypeGroup === 'All' && r.Submarket == null).sort(byYear)[0] ?? null;
}
const ref = (r: MarketAssumptionRow | null): string | null => r ? `MarketAssumption ${r.AssumptionType} ${r.PropertyTypeGroup}${r.Submarket ? ` ${r.Submarket}` : ''} ${r.PeriodYear ?? r.PeriodLabel ?? ''} (${r.Method}${r.SampleSize ? `, n=${r.SampleSize}` : ''})`.trim() : null;

/**
 * CoStar VacancyPct is stored as a percent (8.000 means 8%) — divide by 100. MarketAssumption
 * Vacancy values are already decimals (0.08) and are left alone.
 * MarketAssumption MarketRentPerUnit is ANNUAL (rent/unit × 12); CoStar AvgEffectiveRentPerUnit
 * is MONTHLY. rentPerUnitMonthly is always monthly: CoStar value as-is, MarketAssumption value ÷ 12.
 */
export function marketFacts(b: SubjectBundle): MarketFacts {
  const c = b.costar;
  const submarket = c?.Submarket ?? null;
  const rentMA = latest(b.marketAssumptions, b.typeGroup === 'Multifamily' ? 'MarketRentPerUnit' : 'MarketRentPerSqFt', b.typeGroup, submarket);
  const vacMA = latest(b.marketAssumptions, 'Vacancy', b.typeGroup, submarket);
  const capMA = latest(b.marketAssumptions, 'CapRate', b.typeGroup, submarket);
  const rentPerSF = c?.AvgEffectiveRentPerSF ?? (b.typeGroup !== 'Multifamily' ? rentMA?.Value ?? null : null);
  const rentPerUnitMonthly = c?.AvgEffectiveRentPerUnit ?? (b.typeGroup === 'Multifamily' && rentMA?.Value != null ? rentMA.Value / 12 : null);
  const vacancyPct = c?.VacancyPct != null ? c.VacancyPct / 100 : vacMA?.Value ?? null;
  // I6: CoStar's own property-level cap rate wins when present (it rarely is); otherwise the MarketAssumption group/submarket cap rate.
  const capRate = c?.CapRate ?? capMA?.Value ?? null;
  return {
    rentPerSF, rentPerUnitMonthly, vacancyPct, capRate,
    rentRef: c?.AvgEffectiveRentPerSF != null || c?.AvgEffectiveRentPerUnit != null ? `CoStar ${c?.PropertyName ?? ''} ${c?.Submarket ?? ''}`.trim() : ref(rentMA),
    vacancyRef: c?.VacancyPct != null ? `CoStar ${c.Submarket ?? ''}`.trim() : ref(vacMA),
    capRef: c?.CapRate != null ? 'CoStar property cap rate' : ref(capMA),
  };
}
