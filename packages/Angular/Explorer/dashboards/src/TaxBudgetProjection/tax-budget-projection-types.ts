/**
 * Shared types for the Tax Budget Projection dashboard (OPP-1/2/3, per
 * Indiana_Tax_Expert/docs/OPPORTUNITIES.md). Mirrors the shape already
 * validated in scripts/project-tax-budget.js (Indiana_Tax_Expert) and the
 * published Artifact prototype -- this dashboard is the live, any-parcel
 * successor to that curated 3-parcel snapshot.
 */

/** One year of REAL history, from indiana_tax.TaxHistoryYear. */
export interface TaxHistoryRow {
  Year: number;
  Land: number;
  Improvement: number;
  TotalAV: number;
  TaxRate: number;
  /** null = not yet billed (pay-year lag -- Indiana taxes for assessment year N are billed in year N+1). */
  Tax: number | null;
}

export interface TrendStats {
  cagr: number | null;
  volatility: number | null;
  n: number;
}

/** A qualifying recent arm's-length sale, if one exists for the subject. */
export interface SaleAdjustment {
  saleYear: number;
  salePrice: number;
  avAtSale: number;
  gap: number;
  propertyType: string;
}

export type ScenarioMode = 'trend' | 'step-to-price';

export interface ScenarioOverride {
  enabled: boolean;
  year: number;
  value: number | null;
}

/** Editable state for one of the three scenarios. */
export interface ScenarioState {
  mode: ScenarioMode;
  land: number[];
  imp: number[];
  rate: number[];
  probability: number | null;
  probabilitySource: string | null;
  targetValue: number | null;
  triggerYear: number | null;
  override: ScenarioOverride;
}

/**
 * Whether a figure is published fact or the model's estimate. Tracked per FIGURE, not
 * per row, because of the Indiana pay-year lag: assessment year N is billed in N+1, so
 * there is always a "bridge" year whose assessed value the Assessor has already set but
 * whose tax rate DLGF will not publish until early in year N+1. That year is neither
 * history nor pure projection -- one input is known, the other is not.
 */
export type ValueSource = 'actual' | 'projected';

/** An assessment already published for a year whose tax rate has not been. */
export interface KnownAssessment {
  year: number;
  land: number;
  imp: number;
}

/** A single figure on a tax bill, with whether it is published fact or estimate. */
export interface BillFigure {
  value: number | null;
  source: ValueSource;
}

/** Assessed value split across the three statutory circuit-breaker classes. */
export interface CapClassAV {
  av1Pct: number | null;
  av2Pct: number | null;
  av3Pct: number | null;
}

export interface BillInput {
  grossAV: number | null;
  deductions: number | null;
  rate: number | null;
  capAV: CapClassAV;
  /**
   * Effective outside-cap uplift as a fraction. Preferred from the parcel's own capped
   * history; the district mean is a fallback. NOT the referendum rate -- it is net of
   * other local credits. See docs/proposals/tax-bill-projection-design.md sec 7.
   */
  uplift: number | null;
  otherCharges: number | null;
  source?: ValueSource;
}

/** The TS-1 Table 1 chain, one figure per line. */
export interface BillLines {
  grossAV: BillFigure;
  deductions: BillFigure;
  netAV: BillFigure;
  rate: BillFigure;
  grossTax: BillFigure;
  capCeiling: BillFigure;
  capSavings: BillFigure;
  otherCharges: BillFigure;
  totalDue: BillFigure;
}

export interface ProjectionRow {
  /** The assessment year these figures describe. */
  assessmentYear: number;
  /** The year that assessment is billed and paid -- always assessmentYear + 1 in Indiana. */
  payYear: number;
  land: number;
  imp: number;
  totalAV: number;
  rate: number;
  tax: number;
  avSource: ValueSource;
  rateSource: ValueSource;
}

export interface ProjectionInput {
  /**
   * The last year with BOTH a published assessment and a published tax rate. Both bases
   * below must come from THIS year -- taking the value base from a later year than the
   * rate base silently advances them at different speeds and understates every tax.
   */
  baseYear: number;
  baseLand: number;
  baseImp: number;
  baseRate: number;
  scenario: ScenarioState;
  yearsForward: number;
  /** Set when the Assessor has already published baseYear + 1's value. */
  knownAV?: KnownAssessment | null;

  /* --- Bill-chain parameters. When ALL are supplied the projection computes a real bill
   *     (net AV -> gross tax -> cap) instead of `AV x rate`. Optional so existing callers
   *     and the pay-year-lag tests are unaffected. Calibrated from the parcel's own
   *     history where it has any; see scripts/lib/district-uplift.js. --- */

  /** (grossAV - netAV) / grossAV, from the parcel's own recent bills. */
  deductionRatio?: number | null;
  /** How the parcel's gross AV splits across the 1%/2%/3% cap classes; shares sum to ~1. */
  capClassShare?: CapClassAV | null;
  /** Effective outside-cap uplift. NOT the referendum rate -- see BillInput.uplift. */
  uplift?: number | null;
  /** Storm water, special assessments. Not property tax, so not subject to the cap. */
  otherCharges?: number | null;
}

export const SCENARIO_NAMES = ['WorstCase', 'MostLikely', 'BestCase'] as const;
export type ScenarioName = (typeof SCENARIO_NAMES)[number];

export interface ScenarioMeta {
  label: string;
  cssClass: 'worst' | 'likely' | 'best';
}

export const SCENARIO_META: Record<ScenarioName, ScenarioMeta> = {
  WorstCase: { label: 'Worst Case', cssClass: 'worst' },
  MostLikely: { label: 'Most Likely', cssClass: 'likely' },
  BestCase: { label: 'Best Case', cssClass: 'best' },
};

/** A resolved parcel search result. */
export interface ParcelSearchResult {
  ID: string;
  GISParcelNumber: string;
  Address: string;
}

/** One row from indiana_tax.SaleReassessmentScenarioProbability (Component A). */
export interface ScenarioProbabilityRow {
  PropertyTypeGroup: string;
  GapBand: string;
  SampleSize: number;
  PWorstCaseFullChase: number;
  WorstCaseMedianChaseFraction: number | null;
  PMostLikelyPartial: number;
  MostLikelyMedianChaseFraction: number | null;
  PBestCaseNoReaction: number;
  BestCaseMedianChaseFraction: number | null;
  LowSample: boolean;
  ComputedAt: string;
}

export const GAP_BANDS = ['10-25%', '25-50%', '50-100%', '100%+'] as const;
export type GapBand = (typeof GAP_BANDS)[number];

export function gapBandForRatio(gapRatio: number): GapBand | null {
  if (gapRatio < 0.1) return null;
  if (gapRatio < 0.25) return '10-25%';
  if (gapRatio < 0.5) return '25-50%';
  if (gapRatio < 1.0) return '50-100%';
  return '100%+';
}
