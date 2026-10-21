# Income tax

The US federal individual income tax as a [factlet](../../factlet) program.

```sh
make check-income-tax    # load and type-check the program, with ../factlet
make test-income-tax     # run the scenarios in tests/
```

From this directory, with the `factlet` command
(`cargo install --path ../../factlet --features cli`):

```sh
factlet explain main.lisp --case examples/family.lisp f1040/line34
factlet eval main.lisp --set married=true f1040/line34
```

## Layout

| Path                  | Holds                                                      |
| --------------------- | ---------------------------------------------------------- |
| `main.lisp`           | Units, enums and shared helpers; the inputs: who is filing, `people` you may claim, and information returns (`w2s`, `f1099-ints`, `f1099-divs`, `f1099-bs`, `f1099-gs`, `f1099-rs`, `ssa1099s`, `f1098-es`, `f1095-as`), and `vehicle-loans`; and the module for each form |
| `person.lisp`         | One filer's questions, included as `you/…` and `spouse/…`, each with their own Form 8889 and Schedule SE (`you/f8889`, `you/f1040sse`, and the spouse's)  |
| `law/2025.lisp`       | Every amount and rate from the Code or IRS guidance, as `law/…` |
| `forms/`              | One module per form or worksheet: `f1040`, `f1040s1`, `f1040s1a`, `f1040s2`, `f1040s3`, `f1040s8`, `f1040sa`, `f1040sd`, `f1040sse`, `f2441`, `f8863`, `f8880`, `f8889`, `f8962`, `f8959`, `f8960`, `f8995`, `f8995a`, `f8995aa`, `f8995ac`, `f8615`, `f6251`, `f1040-qdcg`, `f1040-ssb`, `f1040-eic`, `f1040-eic-b`, `f1040sa-salt`, `f1040s1-ira`, `f1040s1-sli`, `f8615-ws1`, `f8615-ws3`; `p590a-ssb`, `f1040-ssb` again for Pub. 590-A; `f8615-qdcg9` and `f8615-qdcg15`, `f1040-qdcg` again for Form 8615; and `f1040scs`, a collection of Schedules C, one for each business |
| `tests/`              | Scenarios with hand-checked results                        |
| `examples/`           | Sample answers for `eval` and `explain`                    |

## Conventions

- **Lines are named after the form.** `f1040/line12e` is Form 1040, line
  12e, and carries `:line` and `:label`. A form is named by its IRS
  identifier (`f1040s8` is Schedule 8812), and a worksheet by its form's
  plus a short name for it (`f1040-qdcg` is the Form 1040 instructions'
  Qualified Dividends and Capital Gain Tax Worksheet). A worksheet that
  isn't its own form gets a module of its own all the same.
- **Law lives only in `law/`.** Each value there has a `:cite`, and forms
  read it by name instead of repeating the number. Amounts that vary by
  filing status are a `table` on `filing-status`, and amounts that vary by
  number of children are a list starting from none. The tax brackets and
  capital gain thresholds are functions of a filing status instead
  (`law/brackets-for`), since the kiddie tax needs the parent's; a
  function can't carry `:cite`, so it cites in its comment. A new tax year
  is a new `law/<year>.lisp`.
- **Totals keep the form's shape.** A line that adds lines not yet modeled
  lists them in a trailing comment, such as `; + 4b 5b 6b 8` on line 9, so
  `grep -n '; [+−]' forms/` finds every total that's still incomplete.
  Larger missing pieces, such as whole parts of a schedule, are noted where
  they'd go.
- **Inputs are questions.** A checkbox defaults to `false`, so it's
  phrased with the usual answer as no: `home-abroad`, not the form's "main
  home in the U.S.". Every other input stays unanswered until it is given,
  so `eval` reports exactly which questions block a result. Spouse questions are only asked on a
  joint return, and identification numbers only once a dependent or a
  senior makes them matter.
- **Every rule gets a test,** worked by hand in comments, including its
  edge cases (for example, someone born on 1961-01-01 is 65 for 2025).

## Modeled so far

- Form 1040 lines 1a–37 for wages, taxable and tax-exempt interest,
  dividends, capital gains and losses, business income, IRA
  distributions, pensions and annuities, social security benefits, unemployment compensation,
  withholding, and refunds or amounts owed.
- Form 1099-R: IRA distributions (lines 4a, 4b) and pensions and annuities
  (5a, 5b), taxed at the payer's taxable amount less what you rolled over
  within 60 days, and Schedule 2 line 8, the 10% additional tax on an
  early distribution coded 1.
- Taxable social security benefits (line 6b), from the Social Security
  Benefits Worksheet: up to half of the benefits over the base amount, and
  85% over the adjusted base amount, counting tax-exempt interest toward
  them. The base amounts are zero for married filing separately, unless
  the spouses lived apart all year.
- Schedule D and Form 8949: short- and long-term sales, netted with last
  year's loss carryovers and capital gain distributions, a net loss
  limited to $3,000 ($1,500 on a separate return), and the net long-term
  gain taxed at the capital gain rates.
- Schedule C for each business: income, cost of goods sold, the Part II
  expenses, and a home office by the simplified method ($5 a square foot
  of up to 300), with its net profit or loss on Schedule 1 line 3.
- Schedule SE for each spouse: 15.3% self-employment tax on 92.35% of
  their own profit once that's $400, the 12.4% only up to what their own
  social security wages leave of the $176,100 wage base, on Schedule 2
  line 4, with half of it deducted on Schedule 1 line 15. Self-employment
  income is earned income, by EIC Worksheet B, for the EIC, the
  additional child tax credit and the IRA deduction; statutory employee
  income is earned income but owes no self-employment tax.
- Form 8959: the 0.9% Additional Medicare Tax on Medicare wages and
  self-employment income over $250,000 on a joint return, $125,000 on a
  separate one or $200,000 otherwise, and what employers withheld of it
  (Form 1040 line 25c).
- Form 8960: the 3.8% net investment income tax on interest, dividends
  and capital gain distributions, or on modified AGI over the threshold
  ($250,000 for a joint return or a qualifying surviving spouse), if less.
- Form 8889 for each spouse: the HSA limit for self-only or family
  coverage for each month eligible (all 12 under the last-month rule),
  $1,000 more from age 55, a family limit shared between spouses, less
  employer contributions; and distributions not spent on medical care,
  taxable (Schedule 1 line 8f) with the 20% additional tax (Schedule 2
  line 17c) unless after 65 or disability.
- Schedule 1: business income (line 3); unemployment compensation
  (line 7); the HSA deduction (line 13); the deductible part of
  self-employment tax (line 15); the IRA deduction
  (line 20), with the catch-up from age 50 and the phaseouts for someone
  covered by a retirement plan at work or through a spouse; and the
  student loan interest deduction (line 21), with its phaseout and the
  rules against taking it on a separate return or as someone else's
  dependent. With social security benefits, the IRA deduction follows
  Pub. 590-A's Appendix B: its limit uses the benefits taxable before
  it, and the benefits taxable on the return come after it.
- The standard deduction, with the additions for age and blindness and the
  limit for someone claimed as a dependent, and none when a spouse filing
  separately itemizes.
- Schedule A: medical expenses past 7.5% of AGI; state and local taxes up
  to the 2025 limit of $40,000 ($20,000 on a separate return), coming down
  past $500,000 of AGI to $10,000 ($5,000); mortgage and investment
  interest, gifts to charity, disaster losses and other itemized
  deductions. Itemized instead of the standard deduction when larger, or
  when chosen.
- Tax from the Tax Table (the midpoint of each $25 or $50 row) below
  $100,000, the Tax Computation Worksheet from $100,000, and the Qualified
  Dividends and Capital Gain Tax Worksheet.
- Form 6251, the alternative minimum tax, on Schedule 2 line 2: taxable
  income with the standard deduction (or state and local taxes), the
  senior deduction, private activity bond interest and incentive stock
  options added back, less an exemption that comes down by 25% past
  $626,350 ($1,252,700 joint), taxed at 26% and 28%, with qualified
  dividends and net capital gain at their own rates (Part III). It's owed
  to the extent it's more than the regular tax.
- Form 8615, the kiddie tax: for a child under 18, or 18 or a full-time
  student under 24 whose earned income was no more than half their support,
  with a parent alive and not filing jointly, net unearned income over
  $2,700 is taxed at the parent's rate. That's the parent's tax with it
  added, less the parent's own, shared with the parent's other children,
  plus the child's tax on the rest, if more than the child's tax alone.
  Qualified dividends and net capital gain keep their rates, split by Line
  5 Worksheet #1 or #3. The parent's taxable income, tax and filing status
  are asked for. The same definition of a child keeps the American
  opportunity credit from being refundable.
- Schedule 1-A (2025–2028), deductions whether or not you itemize:
  - qualified tips, up to $25,000, from W-2s and from businesses, a
    business's only up to its profit less its share of its owner's
    deductible self-employment tax
  - the FLSA overtime premium from W-2s, up to $12,500 ($25,000 joint)
  - interest on loans for new vehicles bought for personal use, up to
    $10,000
  - the enhanced deduction for seniors

  Tips and overtime come down by $100 for each full $1,000 of modified AGI
  over $150,000 ($300,000 joint), and need a valid SSN for whoever received
  them and, if married, a joint return. Car loan interest comes down by
  $200 for each $1,000 or part of it over $100,000 ($200,000 joint).
- Form 8995: the qualified business income deduction (line 13a), 20% of
  each Schedule C's profit, less its share of self-employment tax and the
  tips Schedule 1-A deducts for it, and of qualified REIT dividends, with
  last year's loss carryforwards. It's no more than 20% of taxable income
  less net capital gain and qualified dividends.
- Form 8995-A, above the $197,300 ($394,600 joint) threshold, with a
  column on each Schedule C. A business's 20% is limited to the greater
  of 50% of its W-2 wages, or 25% of them plus 2.5% of its property's
  unadjusted basis, phased in over the next $50,000 ($100,000 joint). A
  specified service business counts by the applicable percentage over the
  same range, and not at all past it (Schedule A). Losses, and last
  year's, are netted against the other businesses' income in proportion
  to it, which leaves a loss business's wages and property out (Schedule
  C).
- Schedule 8812: the child tax credit, the credit for other dependents, the
  phaseout, and the additional child tax credit (Parts II-A and II-B). This
  includes the identification number rules: a filer (one spouse on a joint
  return) and the child need a valid SSN for the child credit, a child who
  lacks one falls back to the $500 credit, and every filer needs some
  number by the due date (IRC §24(e), (h)(4)(C), (h)(7)). A dependent who
  isn't a U.S. citizen, national or resident alien gets neither credit.
- Form 2441 and Schedule 3: the credit for child and dependent care
  expenses, 35% down to 20% by AGI, of up to $3,000 ($6,000 for two or more)
  of care for a child under 13 or a disabled dependent. It's no more than
  the lower earner's earned income, which is at least $250 or $500 a month
  for a student or disabled spouse, and on a separate return only when
  considered unmarried. Employer dependent care benefits are excluded up
  to $5,000, the rest taxable as wages. The child tax credit then takes
  what's left of the tax (Credit Limit Worksheet A).
- Form 8863: the education credits for you, your spouse or a dependent.
  The American opportunity credit is all of the first $2,000 of a
  student's expenses and 25% of the next $2,000, for a student eligible on
  Part III's questions, with 40% refundable unless you're under 24 and
  supported like a dependent. Otherwise, the lifetime learning credit is
  20% of up to $10,000 on the return. Both phase out from $80,000
  ($160,000 joint), and aren't for a separate return or someone another
  taxpayer can claim.
- Form 8880: the saver's credit, 50%, 20% or 10% by AGI of up to $2,000
  of each spouse's IRA contributions and elective deferrals, less
  distributions since 2023; not for someone under 18, a full-time
  student, or someone another taxpayer can claim. Schedule 3's credits
  come in the form's order, each limited by the tax the ones before leave.
- Form 8962: the premium tax credit for Marketplace coverage. Household
  income (AGI with tax-exempt interest, untaxed social security and
  dependents who must file) as a share of the 2024 poverty line for the
  tax family sets the applicable figure, from 0% at 150% to 8.5% from
  400% with no cliff. The credit is the benchmark plan's premium less that
  contribution, no more than the premiums, for the whole year or for the
  months covered. Net of advance payments, it goes on Schedule 3 line 9;
  excess advance payments are repaid on Schedule 2 line 1a, up to Table
  5's limit below 400%. Not for someone claimed as a dependent, nor
  separately without the abuse or abandonment exception.
- The earned income credit (line 27a): EIC Worksheets A and B, with the EIC
  Table's credit at the midpoint of each $50 row, and Steps 1–4 of the
  instructions for who can take it. That covers a valid SSN for every
  filer, the investment income limit, the separated-spouse rule, Form
  2555, nonresident aliens, the bans after a claim found fraudulent or
  reckless, and, for filers without a qualifying child, the age, home and
  dependent rules. After any other disallowance, it assumes Form 8862 is
  attached to claim it again.
- Filing status (IRC §2, §7703), from the facts of the year rather than
  asked. Married at the end of the year files jointly, or separately by
  choice. Otherwise:
  - qualifying surviving spouse: a spouse who died in either of the two
    years before, and a home kept up all year for a dependent child (not
    a foster child)
  - head of household: a home kept up for over half the year for a
    qualifying person, or a dependent parent's own home. That's an
    unmarried qualifying child, even one who isn't your dependent, or a
    dependent relative who lived with you, but not someone who is your
    dependent only by the other parent's release or by living with you all
    year.
  - single, otherwise

  Married filing separately counts as unmarried, and so can be head of
  household, when your spouse wasn't in your home for the last 6 months
  and you kept it up for your child (IRC §7703(b)). The child and
  dependent care credit takes the same for any qualifying person (IRC
  §21(e)(4)). The EIC's rule for separated spouses applies to every
  married filer not filing jointly, head of household included.
- Dependents (IRC §152), from facts about each of the `people` you may
  claim, by Steps 1–5 of the instructions:
  - a qualifying child: a child, sibling or descendant of either who
    lived with you more than half the year; under 19, or a student under
    24, and younger than you, or permanently and totally disabled; who
    didn't provide over half their own support or file jointly
  - a qualifying relative: a relative, or anyone who lived with you all
    year, who isn't anyone's qualifying child, with gross income under
    $5,200 and over half their support from you
  - and not when someone can claim you, unless you file jointly, nor for
    someone who isn't a U.S. citizen, national or resident, or living in
    Canada or Mexico

  The credits each take their own: the child tax credit a dependent
  qualifying child, and the EIC a qualifying child without the support
  test. For children of divorced or separated parents (Form 8332), a
  child the custodial parent released to you is your dependent for the
  child tax credit, but the EIC and the child and dependent care credit
  stay with the custodial parent.

## Known gaps

These give wrong answers for returns they affect, so they come first:

- Earned income leaves out alimony (for the IRA deduction), nontaxable
  combat pay and Medicaid waiver payments. Schedule SE has no farm or
  partnership income, church employee income, optional methods, or
  unreported tips and uncollected social security (Forms 4137 and 8919).
- A Schedule C loss is taken in full: the at-risk rules (Form 6198), the
  passive activity limits for a business you didn't materially
  participate in (Form 8582) and the excess business loss limit (Form
  461) aren't applied. A home office is only by the simplified method, not
  Form 8829, and limited by the business's profit as though all of its
  income came from the home.
- Roth IRA contributions, asked for the saver's credit, don't reduce the
  traditional IRA's limit they share, and nondeductible traditional
  contributions aren't carried to Form 8606. The saver's credit counts a
  spouse's distributions in both columns even from a year you didn't
  file jointly.
- Dependents leave out the tie-breaker rules for a child who is the
  qualifying child of more than one person, multiple support agreements,
  a kidnapped child, the citizenship exception for an adopted child, and
  the gross income exception for a disabled relative's sheltered
  workshop pay. A disabled person counts for the child and dependent care
  credit only as your dependent, not also when only their income or a
  joint return keeps them from being one.
- A Form 1099-R is taxed at its box 2a amount less rollovers. There's no
  Form 8606 for IRA basis or Roth distributions, no Simplified Method for
  a pension whose payer didn't figure the taxable amount, and no qualified
  charitable or HSA funding distributions.
- An early distribution coded 1 always owes the 10% additional tax: the
  exceptions on Form 5329 aren't asked about, and a SIMPLE IRA's 25% in
  its first two years (code S) isn't charged.
- A disability pension received before the minimum retirement age belongs
  on line 1h as earned income for the EIC, but is taken as a pension.
- HSA coverage that changed between self-only and family during the year
  is taken as the one on line 1 for every month eligible. Spouses with
  family coverage for different months share the limit as if for the
  same, and married filing separately takes half the family limit even
  when the spouse has no HSA. Excess contributions (Form 5329), excess
  employer contributions, Archer MSAs, IRA funding distributions and
  Part III (the testing period) aren't modeled.
- Schedule A takes mortgage interest, investment interest and gifts to
  charity in full: the limit to interest on $750,000 of mortgage debt
  (Pub. 936), Form 4952's limit to net investment income, and the
  charitable limits by share of AGI (Pub. 526) aren't applied. A
  dual-status alien's standard deduction (line 12c) isn't zeroed.
- Schedule D has no 28% rate gain (collectibles, section 1202 stock) or
  unrecaptured section 1250 gain, so no Schedule D Tax Worksheet; no gains
  from Forms 4797, 6252 or Schedules K-1; and doesn't figure the loss to
  carry over to next year.
- For the child and dependent care credit, a disabled spouse isn't a
  qualifying person, and two spouses who were students in the same month
  both get the deemed $250. Married filing separately and not considered
  unmarried takes your own earned income for your spouse's (line 19).
  Expenses for 2024 paid in 2025 (line 9b) and benefits carried over or
  forfeited (lines 13 and 14) aren't asked about, and earned income for
  lines 4 and 5 leaves out taxable benefits (line 1e).
- Net investment income leaves out annuities, rents, royalties and
  passive income, and isn't reduced by investment expenses (Form 8960
  Part II). The Additional Medicare Tax leaves out railroad retirement
  compensation.
- The premium tax credit takes every Form 1095-A as covering the same
  months at the same amounts each month, instead of lines 12 through 23
  month by month. It doesn't allocate a policy shared with another
  taxpayer (Part IV), use the alternative calculation for the year of
  marriage (Part V), or interact with the self-employed health insurance
  deduction. Household income under 100% of the poverty line is taken as
  eligible whenever advance payments were made.
- Qualified tips are what you say they are: Form 4137's unreported tips
  aren't added (Schedule 1-A line 4b), and an employee tipped in more than
  one occupation for the same employer isn't asked which tips came from
  which. Qualified overtime reported on Forms 1099-NEC or 1099-MISC (line
  14b) isn't asked for. A business's net income for its tips subtracts
  only its share of self-employment tax, not of the self-employed health
  insurance or retirement plan deductions. Modified AGI doesn't add back
  excluded foreign or territory income (line 2e).
- Qualified business income comes only from Schedules C and qualified
  REIT dividends: no rentals, farms, partnerships, S corporations or
  publicly traded partnerships, nor an agricultural cooperative's patrons.
  It isn't reduced by the self-employed health insurance or retirement
  plan deductions. Form 8995-A has no aggregation of businesses (Schedule
  B), and W-2 wages and property are asked for, not figured.
- The AMT makes only the adjustments above (lines 2a, 2g and 2i): not
  investment interest, tax refunds, depreciation, net operating losses,
  passive activities, small business stock or the rest of lines 2b–3. It
  has no AMT basis for stock sold, no unrecaptured section 1250 gain in
  Part III, no AMT foreign tax credit, and no credit for prior year
  minimum tax (Form 8801).
- The kiddie tax counts all of a business's profit as earned income, not
  just a reasonable allowance where capital matters, and leaves out the
  early withdrawal penalty. It takes no itemized deductions as directly
  connected with the unearned income (line 2, and Line 5 Worksheet #2),
  and has no Schedule D Tax Worksheet for 28% rate or unrecaptured
  section 1250 gain. It doesn't offer the parent's election to report the
  child's income instead (Form 8814).
- Social security benefits that include a lump-sum payment for earlier
  years are all taxed this year: the lump-sum election (line 6c, Pub. 915)
  isn't offered.
- Filing status doesn't treat someone married to a nonresident alien as
  unmarried for head of household (IRC §2(b)(2)(B)), or bar a
  nonresident alien from it. A surviving spouse's child must be a
  dependent outright, without the exceptions for their income, a joint
  return, or your being someone else's dependent (IRC §2(a)(1)(B)).

## Next

One commit each, in rough order of how many returns need them:

1. Tax year 2026 (Rev. Proc. 2025-32)
