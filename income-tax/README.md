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
factlet eval main.lisp --set "filing-status='single" f1040/line34
```

## Layout

| Path                  | Holds                                                      |
| --------------------- | ---------------------------------------------------------- |
| `main.lisp`           | Units, enums and shared helpers; the inputs: who is filing, `dependents`, and information returns (`w2s`, `f1099-ints`, `f1099-divs`, `f1099-gs`, `f1099-rs`, `ssa1099s`, `f1098-es`); and the module for each form |
| `person.lisp`         | One filer's questions, included as `you/…` and `spouse/…`, each with their own Form 8889 and Schedule SE (`you/f8889`, `you/f1040sse`, and the spouse's)  |
| `law/2025.lisp`       | Every amount and rate from the Code or IRS guidance, as `law/…` |
| `forms/`              | One module per form or worksheet: `f1040`, `f1040s1`, `f1040s1a`, `f1040s2`, `f1040s8`, `f1040sse`, `f8889`, `f1040-qdcg`, `f1040-ssb`, `f1040-eic`, `f1040-eic-b`, `f1040s1-ira`, `f1040s1-sli`; `p590a-ssb`, `f1040-ssb` again for Pub. 590-A; and `f1040scs`, a collection of Schedules C, one for each business |
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
  number of children are a list starting from none. A new tax year is a
  new `law/<year>.lisp`.
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
  dividends and capital gain distributions, business income, IRA
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
  limit for someone claimed as a dependent.
- Tax from the Tax Table (the midpoint of each $25 or $50 row) below
  $100,000, the Tax Computation Worksheet from $100,000, and the Qualified
  Dividends and Capital Gain Tax Worksheet.
- Schedule 1-A Part V: the enhanced deduction for seniors (2025–2028).
- Schedule 8812: the child tax credit, the credit for other dependents, the
  phaseout, and the additional child tax credit (Parts II-A and II-B). This
  includes the identification number rules: a filer (one spouse on a joint
  return) and the child need a valid SSN for the child credit, a child who
  lacks one falls back to the $500 credit, and every filer needs some
  number by the due date (IRC §24(e), (h)(4)(C), (h)(7)). A dependent who
  isn't a U.S. citizen, national or resident alien gets neither credit.
- The earned income credit (line 27a): EIC Worksheets A and B, with the EIC
  Table's credit at the midpoint of each $50 row, and Steps 1–4 of the
  instructions for who can take it. That covers a valid SSN for every
  filer, the investment income limit, the separated-spouse rule, Form
  2555, nonresident aliens, the bans after a claim found fraudulent or
  reckless, and, for filers without a qualifying child, the age, home and
  dependent rules. After any other disallowance, it assumes Form 8862 is
  attached to claim it again.

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
- Roth IRA contributions aren't asked about, though they share the
  traditional IRA's limit, and nondeductible traditional contributions
  aren't carried to Form 8606.
- A child who is your qualifying child for the EIC but not your dependent
  isn't counted: one you released to the other parent (Form 8332), or one
  who provided over half their own support.
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
- Social security benefits that include a lump-sum payment for earlier
  years are all taxed this year: the lump-sum election (line 6c, Pub. 915)
  isn't offered.
- The EIC doesn't ask about a married head of household without a
  qualifying child, which rules it out.

## Next

One commit each, in rough order of how many returns need them:

1. Schedule 2: additional Medicare tax (Form 8959) and net investment
   income tax (Form 8960)
2. Schedule D and Form 8949
3. Schedule A, including the separate-return rule of IRC §63(c)(6)
4. Schedule 3 credits (child care, Form 2441; education, Form 8863;
   saver's, Form 8880) and Credit Limit Worksheet A
5. Form 8962, the premium tax credit
6. Schedule 1-A Parts II–IV: tips, overtime and car loan interest
7. Form 8995, the qualified business income deduction
8. An EIC qualifying child who isn't your dependent (Form 8332)
9. Deriving filing status (IRC §2) and dependents (IRC §152) from facts,
   instead of asking for them
10. Form 8615 (kiddie tax) and Form 6251 (AMT)
11. Tax year 2026 (Rev. Proc. 2025-32)
