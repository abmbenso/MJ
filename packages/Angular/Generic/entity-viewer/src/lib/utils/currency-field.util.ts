/**
 * Decides whether a numeric entity field should render as currency when no explicit column
 * format says otherwise. Metadata carries no "currency" ExtendedType, so this is a name rule.
 *
 * Two tiers:
 *  - ANY numeric type whose name contains amount / price / cost / total — the long-standing rule.
 *  - Decimal, numeric and money types whose name reads as a money figure in a ledger or tax
 *    context (tax, fee, savings, revenue, relief, due, ...AV / assessed value), unless the name
 *    says it is a rate, percentage or ratio (TaxRate, MaxSpreadPct). Integers are never matched
 *    here: an integer "TaxYear" or "DaysDue" is a label or a count, not money.
 */
const ANY_NUMERIC_CURRENCY = /amount|price|cost|total/;
const DECIMAL_CURRENCY = /tax|fee|savings|revenue|relief|due|assessedvalue|av$/;
const NOT_CURRENCY = /rate|pct|percent|ratio|count|factor|multiplier/;

export function IsDecimalSQLType(sqlType: string | null | undefined): boolean {
  return !!sqlType && /decimal|numeric|money/i.test(sqlType);
}

export function IsCurrencyFieldName(fieldName: string, sqlType: string | null | undefined): boolean {
  const name = (fieldName ?? '').toLowerCase();
  if (!name) return false;
  if (ANY_NUMERIC_CURRENCY.test(name)) return true;
  if (!IsDecimalSQLType(sqlType)) return false;
  if (NOT_CURRENCY.test(name)) return false;
  return DECIMAL_CURRENCY.test(name);
}
