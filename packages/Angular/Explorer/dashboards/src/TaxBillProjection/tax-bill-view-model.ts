/**
 * Tax Bill Projection V2 view model -- a RE-EXPORT, not an owner.
 *
 * The TS-1 Table 1 / Table 2 row model (buildBillGrid, capSummaryRows) and the historical columns
 * read from DLGF bills (billColumnsFromTaxBills) are owned by @abmbenso/mj-indiana-tax-core
 * (src/ts1/) since 2026-09-27, so this dashboard and the Parcel Assistant's server-side rundown
 * render the same rows. The dashboard-only editing and URL helpers live in ./tax-bill-assumptions.
 * Existing importers keep importing from here.
 */
export { buildBillGrid, capSummaryRows, billColumnsFromTaxBills } from '@abmbenso/mj-indiana-tax-core';
export type { BillGridLines, BillColumn, BillLineKey, BillRow, TaxBillFigures, AssessmentSplit } from '@abmbenso/mj-indiana-tax-core';
export * from './tax-bill-assumptions';
