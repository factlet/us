; Social Security Benefits Worksheet (Form 1040 instructions, lines 6a and
; 6b). IRC §86.
;
; The worksheet's STOPs, where none of the benefits are taxable, fall out
; of the subtractions: each enters -0- and so does every line after it.

(def line1 :label "Net benefits" (sum ssa1099s net-benefits))
(def line2 (* law/ssb-lower-rate line1))
(def line3 :label "Other income"
  (+ f1040/line1z f1040/line2b f1040/line3b f1040/line4b f1040/line5b f1040/line7a
     f1040/line8))
(def line4 :label "Tax-exempt interest" f1040/line2a)
(def line5 (+ line2 line3 line4))
; Line 6 leaves out the student loan interest deduction, whose own
; worksheet starts from income that includes these benefits.
(def line6 :label "Adjustments to income" adjustments)
(def line7 :label "Modified adjusted gross income plus half the benefits"
  :cite "IRC §86(b)(1), (2)"
  (excess line5 line6))

; Married filing separately, having lived together at any time in the
; year, the base amounts are zero, which the worksheet takes as skipping
; to 85% of line 7 on line 16.
(def together (and (= filing-status 'married-separate) (not lived-apart-all-year)))
(def line8 :label "Base amount" :cite "IRC §86(c)(1)"
  (if together $0 law/ssb-base))
(def line9 (excess line7 line8))
(def line10 :cite "IRC §86(c)(2)"
  (if together $0 (- law/ssb-adjusted-base law/ssb-base)))
(def line11 :label "Over the adjusted base amount" (excess line9 line10))
(def line12 (min line9 line10))
(def line13 (* law/ssb-lower-rate line12))
(def line14 :cite "IRC §86(a)(1)" (min line2 line13))
(def line15 (* law/ssb-upper-rate line11))
(def line16 (+ line14 line15))
(def line17 (* law/ssb-upper-rate line1))
(def line18 :label "Taxable social security benefits" :cite "IRC §86(a)(2)"
  (min line16 line17))
