; Tax year 2025: the inflation adjustments of Rev. Proc. 2024-40, as
; amended by P.L. 119-21 (2025-07-04) for the standard deduction and the
; new senior deduction and the child tax credit.

(def year-end 2025-12-31)
; Ages "at the end of the year" for rules where a birthday counts a day
; early, such as turning 65.
(def day-after-year-end 2026-01-01)

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
