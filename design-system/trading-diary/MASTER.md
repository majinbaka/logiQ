# logiq Design System

> **Retrieval rule:** When building a page, first read
> `design-system/trading-diary/pages/[page-name].md`. Page rules override this
> Master file. If no page file exists, follow this Master file.

**Project:** logiq  
**Generated:** 2026-05-05  
**Product type:** Private trading journal, portfolio tracker, risk workflow, and
analytics dashboard  
**Primary platform:** Flutter mobile-first app with responsive tablet/desktop
layouts

---

## Product Principles

- **Dense, not cramped:** financial users need fast scanning, comparison, and
  repeated entry. Prioritize tables, compact cards, segmented filters, and
  persistent context over decorative sections.
- **Private by default:** journal notes, psychology notes, and instrument thesis
  content should feel personal and protected. Avoid social, sharing, telemetry,
  or public-report patterns unless explicitly requested.
- **Source of truth clarity:** trade fills, plans, reviews, risk checks,
  portfolio snapshots, and analytics facts must be visually distinguishable.
- **Action before explanation:** each empty state should present the next useful
  action, not a marketing description.

## Visual Direction

**Style:** Data-Dense Dashboard  
**Keywords:** financial, analytical, precise, calm, compact, data-first,
responsive, privacy-aware  
**Avoid:** landing-page hero layouts, oversized marketing cards, ornamental
gradients, emoji icons, playful illustrations, layout-shifting hover effects

## Color Tokens

Use `Theme.of(context).colorScheme` in widgets. When custom palette helpers are
introduced, map them to these semantic roles.

| Role | Hex | Flutter mapping | Usage |
| --- | --- | --- | --- |
| Primary | `#1E40AF` | `primary` | Navigation selection, focused controls |
| Primary Container | `#DBEAFE` | `primaryContainer` | Selected filter backgrounds |
| Secondary | `#3B82F6` | `secondary` | Links, secondary highlights |
| Accent | `#F59E0B` | `tertiary` | Insight priority, pending review, warning emphasis |
| Success | `#16A34A` | semantic helper | Profit, followed plan, completed |
| Danger | `#DC2626` | `error` | Loss, risk violation, destructive validation |
| Bullish | `#26A69A` | semantic helper | Positive OHLC/candlestick movement |
| Bearish | `#EF5350` | semantic helper | Negative OHLC/candlestick movement |
| Background | `#F8FAFC` | `surface` | App background |
| Surface | `#FFFFFF` | `surfaceContainerLowest` | Tables, forms, sheets |
| Surface Muted | `#F1F5F9` | `surfaceContainer` | Header rows, grouped sections |
| Border | `#CBD5E1` | `outlineVariant` | Dividers, input borders |
| Text | `#0F172A` | `onSurface` | Primary text |
| Text Muted | `#475569` | `onSurfaceVariant` | Labels, helper text |

## Typography

Use a cohesive technical pairing when custom fonts are added:

- **Metric and heading font:** Fira Code, fallback monospace.
- **Body and UI font:** Fira Sans, fallback sans-serif.
- **Numeric data:** tabular figures where supported.

Scale:

| Token | Size | Weight | Usage |
| --- | --- | --- | --- |
| Display | 28 | 700 | Page title on tablet/desktop only |
| Title | 22 | 700 | Page title on mobile |
| Section | 18 | 600 | Form/table section headers |
| Body | 14-16 | 400-500 | Labels, rows, notes |
| Caption | 12 | 500 | Metadata, timestamps, helper text |
| Metric | 24 | 700 | KPI values |

Do not scale text with viewport width. Use wrapping, truncation, or alternate
layouts for small screens.

## Spacing And Shape

| Token | Value | Usage |
| --- | --- | --- |
| `xs` | 4 | Dense row gaps, icon-label gaps |
| `sm` | 8 | Compact controls, table cell padding |
| `md` | 16 | Standard page and form padding |
| `lg` | 24 | Section spacing |
| `xl` | 32 | Major content separation |

- Cards and panels: 8px radius maximum.
- Buttons and inputs: 8px radius.
- Data tables: 0-8px radius depending on surrounding surface.
- Avoid cards inside cards. Use section dividers inside large tool surfaces.

## Navigation

- Mobile: bottom navigation with 4-5 primary destinations.
- Tablet/desktop: navigation rail or left sidebar with labels.
- Primary destinations:
  - Journal
  - Portfolio
  - Analytics
  - Psychology
  - Settings or More
- Secondary modules such as strategies, risk rules, instruments, and insights
  can live behind contextual tabs or the More destination until the app grows.

## Component Rules

### Buttons

- Primary action: filled button using `primary` or `tertiary` only when it is a
  high-priority insight/action.
- Secondary action: outlined or tonal button.
- Destructive action: explicit danger styling and confirmation for record
  deletion or archive.
- Icon buttons must use a consistent icon set, preferably Flutter Material
  icons unless a project icon package is introduced.

### Forms

- Use labeled fields, helper text, and inline validation.
- Validate on blur or field change for numeric constraints.
- Group long forms into sections or tabs: Core, Plan, Fills, Review, Risk.
- Numeric trading fields should align values and preserve visible units:
  quantity, price, fee, tax, percent, score.

### Tables And Lists

- Desktop/tablet: dense tables with sticky or repeated context headers where
  practical.
- Mobile: transform wide tables into cards with the most important value first.
- All list rows need active, selected, disabled, loading, and empty states.
- PnL, risk, and discipline states must use both text labels and color.

### Charts

- Keep charts simple and readable before adding complex interactions.
- Provide a table/list fallback for important chart data.
- Recommended chart types:
  - Equity and PnL timeline: line chart.
  - Drawdown: area chart or line below equity.
  - Strategy/instrument comparison: horizontal bar chart.
  - R-multiple distribution: histogram.
  - Allocation: donut or stacked bar with a list fallback.
  - OHLC/trading context: candlestick only if OHLC data is present.
- Bullish `#26A69A`, bearish `#EF5350`, volume at 40% opacity.

### States

- Loading: skeleton rows/cards for tables and dashboards.
- Empty: concise message plus primary creation/import action.
- Error: explain the recoverable action and keep user data intact.
- Saved draft: subtle timestamp in page header or footer.
- Offline/local-only: show a quiet local data indicator if sync is later added.

## Flutter Implementation Rules

- Prefer `LayoutBuilder` and breakpoints over fixed widths.
- Use `ThemeData`, `ColorScheme`, `TextTheme`, `InputDecorationTheme`,
  `DataTableThemeData`, and `NavigationBarThemeData`.
- Do not hardcode colors inside feature widgets.
- Do not perform async work in `build()`.
- Wrap non-button custom interactions with `Semantics` and visible focus states.
- Respect reduced motion for nonessential animation.

## Accessibility

- Minimum text contrast: 4.5:1.
- Tap targets: 44x44 logical pixels minimum for primary controls.
- Color cannot be the only signal for win/loss, risk violation, or validation.
- Forms require labels; icon-only buttons require tooltip/semantic labels.
- Tables that collapse into cards must preserve the same information.

## Page Index

Create or update the matching page file before implementing each screen:

- `pages/app-shell.md`
- `pages/trade-list.md`
- `pages/trade-detail-editor.md`
- `pages/strategy-risk.md`
- `pages/portfolio-overview.md`
- `pages/daily-journal.md`
- `pages/psychology.md`
- `pages/instrument-notes.md`
- `pages/analytics-insights.md`

## Pre-Delivery Checklist

- [ ] Page override checked before implementation.
- [ ] User-visible strings localized once l10n exists.
- [ ] No hardcoded feature colors in widgets.
- [ ] Responsive at 375px, 768px, 1024px, and 1440px.
- [ ] Empty, loading, error, validation, and saved states handled.
- [ ] No horizontal overflow on mobile.
- [ ] Important chart data has text/table fallback.
- [ ] Focus, tooltip, and semantics are present for custom interactions.
