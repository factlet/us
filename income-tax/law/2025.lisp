; Tax year 2025: the inflation adjustments of Rev. Proc. 2024-40, as
; amended by P.L. 119-21 (2025-07-04) for the standard deduction, the child
; tax credit and the new senior deduction.

(def year-end 2025-12-31)
; Ages "at the end of the year" for rules where a birthday counts a day
; early, such as turning 65.
(def day-after-year-end 2026-01-01)

; ---- Income ----

; Social security benefits are taxable once half of them plus other income
; passes the base amount: half of what's over it, then 85% of what's over
; the adjusted base amount, but never more than 85% of the benefits. These
; aren't adjusted for inflation.
(def ssb-base :cite "IRC §86(c)(1)"
  (table filing-status married-joint $32,000 else $25,000))
(def ssb-adjusted-base :cite "IRC §86(c)(2)"
  (table filing-status married-joint $44,000 else $34,000))
(def ssb-lower-rate :cite "IRC §86(a)(1)" 50%)
(def ssb-upper-rate :cite "IRC §86(a)(2)" 85%)

; ---- Tax rates ----

; Each rate applies up to the edge after it.
(def brackets :cite "IRC §1(j)(2); Rev. Proc. 2024-40 §3.01"
  (table filing-status
    single
    [10% $11,925  12% $48,475  22% $103,350  24% $197,300  32% $250,525  35% $626,350  37%]
    (married-joint qualifying-surviving-spouse)
    [10% $23,850  12% $96,950  22% $206,700  24% $394,600  32% $501,050  35% $751,600  37%]
    married-separate
    [10% $11,925  12% $48,475  22% $103,350  24% $197,300  32% $250,525  35% $375,800  37%]
    head-of-household
    [10% $17,000  12% $64,850  22% $103,350  24% $197,300  32% $250,500  35% $626,350  37%]))

; Qualified dividends and net capital gain are taxed at 0% up to the first
; amount, 15% up to the second, and 20% above.
(def cg-0%-top :cite "IRC §1(j)(5)(B)(i); Rev. Proc. 2024-40 §3.03"
  (table filing-status
    (single married-separate)                   $48,350
    (married-joint qualifying-surviving-spouse) $96,700
    head-of-household                           $64,750))
(def cg-15%-top :cite "IRC §1(j)(5)(B)(ii); Rev. Proc. 2024-40 §3.03"
  (table filing-status
    single                                      $533,400
    (married-joint qualifying-surviving-spouse) $600,050
    married-separate                            $300,000
    head-of-household                           $566,700))

; ---- Adjustments to income ----

; Student loan interest up to the maximum, reduced in proportion as
; modified AGI passes through the range above the start.
(def sli-max :cite "IRC §221(b)(1)" $2,500)
(def sli-phaseout-start :cite "IRC §221(b)(2)(B), (f); Rev. Proc. 2024-40"
  (table filing-status married-joint $170,000 else $85,000))
(def sli-phaseout-range :cite "IRC §221(b)(2)(B)"
  (table filing-status married-joint $30,000 else $15,000))

; ---- Deductions ----

(def std-deduction :cite "IRC §63(c)(2); P.L. 119-21 §70102"
  (table filing-status
    (single married-separate)                   $15,750
    (married-joint qualifying-surviving-spouse) $31,500
    head-of-household                           $23,625))
; For someone another taxpayer can claim: the greater of the minimum or
; earned income plus the addition, but no more than the usual amount.
(def dependent-std-minimum :cite "IRC §63(c)(5)(A); Rev. Proc. 2024-40" $1,350)
(def dependent-std-addition :cite "IRC §63(c)(5)(B); Rev. Proc. 2024-40" $450)
; Per filer who is 65 or older, and again per filer who is blind.
(def aged-blind-addition :cite "IRC §63(f); Rev. Proc. 2024-40"
  (table filing-status
    (single head-of-household) $2,000
    else                       $1,600))

; Per filer 65 or older, 2025 through 2028, whether or not they itemize.
(def senior-deduction :cite "IRC §151(d)(5)(C); P.L. 119-21 §70103" $6,000)
(def senior-phaseout-start :cite "IRC §151(d)(5)(C)(ii)"
  (table filing-status married-joint $150,000 else $75,000))
(def senior-phaseout-rate :cite "IRC §151(d)(5)(C)(ii)" 6%)

; ---- Credits ----

(def ctc-per-child :cite "IRC §24(h)(2); P.L. 119-21 §70104" $2,200)
(def odc-per-dependent :cite "IRC §24(h)(4)" $500)
; $50 per $1,000 of modified AGI over the threshold, or fraction thereof.
(def ctc-phaseout-start :cite "IRC §24(h)(3)"
  (table filing-status married-joint $400,000 else $200,000))
(def ctc-phaseout-rate :cite "IRC §24(b)(1)" 5%)
; The refundable portion: up to this much per child, and 15% of earned
; income above the floor.
(def actc-per-child :cite "IRC §24(h)(5); Rev. Proc. 2024-40" $1,700)
(def actc-earned-floor :cite "IRC §24(h)(6)" $2,500)
(def actc-rate :cite "IRC §24(d)(1)(B)(i)" 15%)

; The earned income credit, by number of qualifying children: none, one,
; two, three or more. It rises at the first rate to the maximum, then falls
; at the phaseout rate from the start, on adjusted gross income or earned
; income, whichever is greater, until it's gone at the end.
(def eic-rate :cite "IRC §32(b)(1)" [7.65% 34% 40% 45%])
(def eic-max :cite "IRC §32(b); Rev. Proc. 2024-40 §3.06" [$649 $4,328 $7,152 $8,046])
(def eic-phaseout-rate :cite "IRC §32(b)(1)" [7.65% 15.98% 21.06% 21.06%])
(def eic-phaseout-start :cite "IRC §32(b)(2); Rev. Proc. 2024-40 §3.06"
  (table filing-status
    married-joint [$17,730 $30,470 $30,470 $30,470]
    else          [$10,620 $23,350 $23,350 $23,350]))
(def eic-phaseout-end :cite "Rev. Proc. 2024-40 §3.06"
  (table filing-status
    married-joint [$26,214 $57,554 $64,430 $68,675]
    else          [$19,104 $50,434 $57,310 $61,555]))
; No credit at all once investment income exceeds this.
(def eic-investment-limit :cite "IRC §32(i); Rev. Proc. 2024-40 §3.06(2)" $11,950)
