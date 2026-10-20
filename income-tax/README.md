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
| `main.lisp`           | Units, enums and shared helpers; the inputs: who is filing, `dependents`, and information returns (`w2s`, `f1099-ints`, `f1099-divs`, `f1099-gs`, `ssa1099s`, `f1098-es`); and the module for each form |
| `person.lisp`         | One filer's questions, included as `you/…` and `spouse/…`  |
| `law/2025.lisp`       | Every amount and rate from the Code or IRS guidance, as `law/…` |
| `forms/`              | One module per form or worksheet: `f1040`, `f1040s1`, `f1040s1a`, `f1040s8`, `f1040-qdcg`, `f1040-ssb`, `f1040-eic`, `f1040s1-sli` |
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
  dividends and capital gain distributions, social security benefits,
  unemployment compensation, withholding, and refunds or amounts owed.
- Taxable social security benefits (line 6b), from the Social Security
  Benefits Worksheet: up to half of the benefits over the base amount, and
  85% over the adjusted base amount, counting tax-exempt interest toward
  them. The base amounts are zero for married filing separately, unless
  the spouses lived apart all year.
- Schedule 1: unemployment compensation (line 7) and the student loan
  interest deduction (line 21), with its phaseout and the rules against
  taking it on a separate return or as someone else's dependent.
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
- The earned income credit (line 27a): EIC Worksheet A, with the EIC
  Table's credit at the midpoint of each $50 row, and Steps 1–4 of the
  instructions for who can take it. That covers a valid SSN for every
  filer, the investment income limit, the separated-spouse rule, Form
  2555, nonresident aliens, the bans after a claim found fraudulent or
  reckless, and, for filers without a qualifying child, the age, home and
  dependent rules. After any other disallowance, it assumes Form 8862 is
  attached to claim it again.

## Known gaps

These give wrong answers for returns they affect, so they come first:

- Earned income is wages only, with no self-employment income (EIC
  Worksheet B), combat pay or Medicaid waiver payments.
- A child who is your qualifying child for the EIC but not your dependent
  isn't counted: one you released to the other parent (Form 8332), or one
  who provided over half their own support.
- Social security benefits that include a lump-sum payment for earlier
  years are all taxed this year: the lump-sum election (line 6c, Pub. 915)
  isn't offered.
- The EIC doesn't ask about a married head of household without a
  qualifying child, which rules it out.

## Next

One commit each, in rough order of how many returns need them:

1. Pensions and IRA distributions: Form 1099-R (lines 4a–5b)
2. Schedule 1: the IRA deduction and its worksheet
3. Form 8889 and the HSA deduction
4. Schedule C
5. Schedule SE, self-employment tax and its deduction, and EIC Worksheet B
6. Schedule 2: additional Medicare tax (Form 8959) and net investment
   income tax (Form 8960)
7. Schedule D and Form 8949
8. Schedule A, including the separate-return rule of IRC §63(c)(6)
9. Schedule 3 credits (child care, Form 2441; education, Form 8863;
   saver's, Form 8880) and Credit Limit Worksheet A
10. Form 8962, the premium tax credit
11. Schedule 1-A Parts II–IV: tips, overtime and car loan interest
12. Form 8995, the qualified business income deduction
13. An EIC qualifying child who isn't your dependent (Form 8332)
14. Deriving filing status (IRC §2) and dependents (IRC §152) from facts,
    instead of asking for them
15. Form 8615 (kiddie tax) and Form 6251 (AMT)
16. Tax year 2026 (Rev. Proc. 2025-32)
