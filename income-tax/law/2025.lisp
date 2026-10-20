; Tax year 2025: the inflation adjustments of Rev. Proc. 2024-40, as
; amended by P.L. 119-21 (2025-07-04) for the standard deduction.

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
