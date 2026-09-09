/**
 * Pure projection engine for the Tax Budget Projection dashboard. A direct
 * TypeScript port of Indiana_Tax_Expert/scripts/project-tax-budget.js's
 * projectScenario()/trendStats() and the artifact prototype's client-side
 * mirror of the same -- kept as pure functions (no Angular/DI) so the exact
 * same logic that was validated against real parcels there is reused here,
 * not re-derived.
 */

import {
  BillFigure,
  BillInput,
  BillLines,
  CapClassAV,
  KnownAssessment,
  ProjectionInput,
  ProjectionRow,
  ScenarioName,
  ScenarioState,
  TaxHistoryRow,
  TrendStats,
  ValueSource,
} from './tax-budget-projection-types';

/** Rounds a DOLLAR figure to cents. Never apply this to a tax rate -- see projectScenario. */
function r2(x: number | null): number | null {
  return x == null || !isFinite(x) ? null : Math.round(x * 100) / 100;
}

/**
 * The base year for a projection: the most recent year whose tax rate has actually been
 * published. Not simply the last row -- once an assessment lands for the current year, that
 * row exists with no rate yet (the pay-year lag), and basing the projection on it would
 * take a rate of 0 forward and zero out every projected tax bill.
 */
export function selectBaseYearRow(history: TaxHistoryRow[]): TaxHistoryRow | null {
  for (let i = history.length - 1; i >= 0; i--) {
    const row = history[i];
    if (row.TaxRate != null && row.TaxRate > 0) return row;
  }
  return null;
}

/**
 * Most Likely's probability: the share the empirical Worst Case and Best Case columns leave
 * over. Clamped to [0, 1] because those two columns are computed independently from the
 * county sample and nothing guarantees they sum to <= 1 -- an overlap would otherwise put a
 * NEGATIVE probability in front of a taxpayer ("-8% likely"), which reads as a broken tool
 * rather than as thin data.
 */
export function residualProbability(pWorstCase: number | null, pBestCase: number | null): number {
  const residual = 1 - (pWorstCase ?? 0) - (pBestCase ?? 0);
  return Math.min(1, Math.max(0, residual));
}

/** Statutory circuit-breaker rates by cap class (IC 6-1.1-20.6). */
const CAP_RATES: Record<keyof CapClassAV, number> = { av1Pct: 0.01, av2Pct: 0.02, av3Pct: 0.03 };

function figure(value: number | null, source: ValueSource): BillFigure {
  return { value: value == null || !isFinite(value) ? null : value, source };
}

/**
 * The bare statutory ceiling: each cap class's AV at its own rate. Null (never 0) when the
 * bill carries no classified AV -- an exempt parcel has no ceiling, and 0 would read as
 * "capped at zero tax" and wipe out the projection.
 */
function bareCeiling(caps: CapClassAV): number | null {
  const parts = (Object.keys(CAP_RATES) as (keyof CapClassAV)[])
    .map((k) => (caps[k] == null ? null : (caps[k] as number) * CAP_RATES[k]))
    .filter((v): v is number => v != null);
  return parts.length ? parts.reduce((a, b) => a + b, 0) : null;
}

/**
 * The TS-1 Table 1 chain. This replaces `tax = AV x rate`, which was wrong twice over:
 * the bill is computed on NET assessed value, and the result is then reduced by the
 * circuit-breaker cap.
 *
 * Order matters. Other charges (storm water, special assessments) are added AFTER the
 * cap, because they are not property tax and are not subject to the circuit breaker --
 * adding them before would let the cap erase them.
 *
 * The ceiling is LIFTED by `uplift`: referendum debt sits outside the cap
 * (IC 6-1.1-20.6), so the cap is a rate modifier, not a gate. A capped taxpayer still
 * pays, and still saves on an AV reduction, on the outside-cap portion.
 *
 * Any absent input yields a null figure downstream, never a fabricated zero.
 */
export function computeBill(input: BillInput): BillLines {
  const src: ValueSource = input.source ?? 'actual';
  const { grossAV, deductions, rate, otherCharges, uplift } = input;

  const netAVValue = grossAV == null || deductions == null ? null : grossAV - deductions;
  const grossTaxValue = netAVValue == null || rate == null ? null : (netAVValue * rate) / 100;

  const bare = bareCeiling(input.capAV);
  const ceilingValue = bare == null || uplift == null ? null : bare * (1 + uplift);

  const capSavingsValue = grossTaxValue == null || ceilingValue == null ? null : Math.max(0, grossTaxValue - ceilingValue);

  const totalDueValue = grossTaxValue == null || capSavingsValue == null ? null : grossTaxValue - capSavingsValue + (otherCharges ?? 0);

  return {
    grossAV: figure(grossAV, src),
    deductions: figure(deductions, src),
    netAV: figure(netAVValue, src),
    rate: figure(rate, src),
    grossTax: figure(grossTaxValue, src),
    capCeiling: figure(ceilingValue, src),
    capSavings: figure(capSavingsValue, src),
    otherCharges: figure(otherCharges, src),
    totalDue: figure(totalDueValue, src),
  };
}

/** Trailing CAGR + YoY volatility over a value series keyed by year. */
export function trendStats(series: TaxHistoryRow[], valueKey: 'Land' | 'Improvement' | 'TaxRate'): TrendStats {
  const pts = series.filter((r) => r[valueKey] != null && r[valueKey] > 0);
  if (pts.length < 2) return { cagr: null, volatility: null, n: pts.length };
  const first = pts[0];
  const last = pts[pts.length - 1];
  const nYears = last.Year - first.Year;
  const cagr = nYears > 0 ? Math.pow(last[valueKey] / first[valueKey], 1 / nYears) - 1 : null;
  const yoy: number[] = [];
  for (let i = 1; i < pts.length; i++) {
    const y0 = pts[i - 1][valueKey];
    if (y0 > 0) yoy.push(pts[i][valueKey] / y0 - 1);
  }
  const mean = yoy.reduce((a, b) => a + b, 0) / (yoy.length || 1);
  const variance = yoy.reduce((a, b) => a + (b - mean) ** 2, 0) / (yoy.length || 1);
  return { cagr, volatility: Math.sqrt(variance), n: pts.length };
}

/**
 * Zero-based index of the year whose assessment is already published, or -1.
 */
function pinnedYearIndex(baseYear: number, knownAV: KnownAssessment | null): number {
  return knownAV ? knownAV.year - baseYear - 1 : -1;
}

/**
 * Zero-based index of the year a sale-chase step actually lands on, or -1 when the scenario
 * has no step. A step aimed at the bridge year is DEFERRED to the next year -- that year's
 * assessment is already published, so it cannot be re-projected.
 *
 * Exported so the narrative reports the year the step LANDS on rather than the raw trigger
 * year; when the two disagreed, the prose contradicted the table printed beside it.
 */
export function resolveStepIndex(scenario: ScenarioState, baseYear: number, knownAV: KnownAssessment | null): number {
  if (scenario.mode !== 'step-to-price' || scenario.targetValue == null || scenario.triggerYear == null) return -1;
  const pinned = pinnedYearIndex(baseYear, knownAV);
  const requested = scenario.triggerYear - 1;
  return requested === pinned ? pinned + 1 : requested;
}

/**
 * Projects one scenario forward from a single coherent base year, honoring step-to-price
 * and manual-override triggers.
 *
 * Every row's assessed value and tax rate advance the SAME number of years from the SAME
 * base. An earlier version took the value base from the latest Assessments row and the rate
 * base from the last Tax History row -- a year apart -- so each row paired an assessment
 * with a rate from the year before it, and every projected tax came out low.
 *
 * `knownAV` pins the bridge year: the Assessor has published that year's value, so it is
 * used verbatim rather than trended, while its rate is still projected. A published
 * assessment cannot be re-projected, so neither a sale-chase step nor a manual override is
 * allowed to overwrite it -- the step defers to the next year, the override is ignored.
 *
 * Tax RATES are carried at full precision. Indiana rates are published to four decimals,
 * so rounding them to cents mid-compound (as dollars are rounded) would bias every
 * downstream tax figure; rounding for display belongs in the template.
 */
export function projectScenario(input: ProjectionInput): ProjectionRow[] {
  const { baseYear, baseLand, baseImp, baseRate, scenario, yearsForward } = input;
  const knownAV: KnownAssessment | null = input.knownAV ?? null;

  const rows: ProjectionRow[] = [];
  let land = baseLand;
  let imp = baseImp;
  let rate = baseRate;

  // All four bill parameters must be present; a partial set would silently mix a bill
  // chain with a legacy multiplication and produce a number nobody could account for.
  const share = input.capClassShare ?? { av1Pct: null, av2Pct: null, av3Pct: null };
  const billShaped = input.deductionRatio != null && input.uplift != null && input.capClassShare != null;

  const pinnedIndex = pinnedYearIndex(baseYear, knownAV);
  const stepIndex = resolveStepIndex(scenario, baseYear, knownAV);
  // override.year is a 1-based year number within the projection.
  const overrideIndex = scenario.override.enabled && scenario.override.value != null ? scenario.override.year - 1 : -1;

  for (let i = 0; i < yearsForward; i++) {
    let avSource: ValueSource = 'projected';
    if (i === pinnedIndex) {
      land = knownAV!.land;
      imp = knownAV!.imp;
      avSource = 'actual';
    } else if (i === overrideIndex || i === stepIndex) {
      // Manual override wins over the model's own step-to-price default when both land on the same year.
      const total = i === overrideIndex ? scenario.override.value! : scenario.targetValue!;
      const cur = land + imp;
      const landWeight = cur > 0 ? land / cur : 0.15;
      land = r2(total * landWeight)!;
      imp = r2(total * (1 - landWeight))!;
    } else {
      land = r2(land * (1 + (scenario.land[i] || 0)))!;
      imp = r2(imp * (1 + (scenario.imp[i] || 0)))!;
    }
    rate = rate * (1 + (scenario.rate[i] || 0));
    const totalAV = r2(land + imp)!;

    // Bill-shaped when the caller supplied the parcel's own bill parameters; otherwise the
    // legacy AV x rate, so existing callers are unaffected. The bill path is the correct
    // one: tax is computed on NET assessed value and then limited by the circuit breaker.
    let tax: number;
    if (billShaped) {
      const bill = computeBill({
        grossAV: totalAV,
        deductions: totalAV * (input.deductionRatio as number),
        rate,
        // The cap classes scale WITH gross AV -- the ceiling is a percentage of it, so a
        // growing assessment raises the ceiling too. Holding them fixed would make the cap
        // bite harder every year for no statutory reason.
        capAV: {
          av1Pct: totalAV * (share.av1Pct ?? 0),
          av2Pct: totalAV * (share.av2Pct ?? 0),
          av3Pct: totalAV * (share.av3Pct ?? 0),
        },
        uplift: input.uplift as number,
        otherCharges: input.otherCharges ?? 0,
        source: 'projected',
      });
      tax = r2(bill.totalDue.value)!;
    } else {
      tax = r2(totalAV * (rate / 100))!;
    }
    const assessmentYear = baseYear + i + 1;
    rows.push({ assessmentYear, payYear: assessmentYear + 1, land, imp, totalAV, rate, tax, avSource, rateSource: 'projected' });
  }
  return rows;
}

function pct1(x: number | null): string {
  return x == null ? '—' : `${(x * 100).toFixed(1)}%`;
}
function pctInt(x: number | null): string {
  return x == null ? '—' : `${Math.round(x * 100)}%`;
}
function usd(x: number | null): string {
  return x == null || !isFinite(x) ? '—' : `$${Math.round(x).toLocaleString('en-US')}`;
}

/** Numbered plain-English assumption sentences for one scenario, matching the reference Faegre Drinker workbook's own style. */
export function narrativeLines(name: ScenarioName, scenario: ScenarioState, baseYear: number, knownAV?: KnownAssessment | null): string[] {
  const lines: string[] = [];
  lines.push(
    `Starts from the actual ${baseYear} assessed value and the actual ${baseYear} tax rate (billed in ${baseYear + 1}) — the most recent assessment year for which both are published.`,
  );
  if (knownAV) {
    lines.push(
      `Assessment year ${knownAV.year} (pay ${knownAV.year + 1}) carries the Assessor's actual assessed value of ${usd(knownAV.land + knownAV.imp)}, which is already set; its tax rate is projected, because DLGF does not certify ${knownAV.year} rates until early ${knownAV.year + 1} and they first reach a tax bill around April ${knownAV.year + 1}.`,
    );
  }
  if (scenario.override.enabled && scenario.override.value != null) {
    lines.push(
      `Year ${baseYear + scenario.override.year} Total AV overridden directly to ${usd(scenario.override.value)}; later years trend forward from that figure at the rates below.`,
    );
  } else if (scenario.mode === 'step-to-price') {
    // The year the step LANDS on -- not scenario.triggerYear, which the engine defers when it
    // aims at a year whose assessment is already published.
    const stepYear = baseYear + resolveStepIndex(scenario, baseYear, knownAV ?? null) + 1;
    lines.push(
      `Assumes a ${pct1(scenario.probability)} probability (${scenario.probabilitySource}) that the Assessor re-assesses the parcel to ${usd(scenario.targetValue)} — the full sale price — in assessment year ${stepYear} (pay ${stepYear + 1}), then resumes ordinary trending afterward.`,
    );
  } else if (name === 'WorstCase' && scenario.probability == null) {
    lines.push(
      `This Worst Case is an aggressive-trend fallback, NOT an empirically-probability-weighted sale-chasing estimate: ${scenario.probabilitySource}. Treat it as a wide upper bound, not a specific predicted outcome.`,
    );
  } else if (scenario.probability != null) {
    lines.push(
      `Assumes a ${pct1(scenario.probability)} probability the Assessor does not meaningfully react beyond ordinary trending (${scenario.probabilitySource}).`,
    );
  } else {
    lines.push('Assumes the Assessor continues to assess using prior-year methodology and does not "chase" any transaction price.');
  }
  lines.push(`Land value trended at ${scenario.land.map(pctInt).join(' / ')} per year; Improvement value at ${scenario.imp.map(pctInt).join(' / ')} per year.`);
  lines.push(`Tax rate trended at ${scenario.rate.map(pctInt).join(' / ')} per year.`);
  lines.push(
    'Not a substitute for a real appeal-decision analysis if this parcel is itself an appeal candidate. Does not model abatements, local tax credits, new-construction phase-in, or special/direct assessments — deliberately out of scope.',
  );
  return lines;
}

export { usd, pct1, pctInt };
