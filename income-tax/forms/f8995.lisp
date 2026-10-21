; Form 8995 (2025), Qualified Business Income Deduction Simplified
; Computation: for taxable income before the deduction up to the threshold,
; where even a specified service business counts in full. IRC §199A.

; Each Schedule C's, statutory employee income included.
(def line2 :label "Total qualified business income or loss" (sum f1040scs qbi))  ; + Schedules E, F, K-1
(def line3 :label "Qualified business net loss carryforward from the prior year"
  (- qbi-loss-carryforward))
(def line4 :label "Total qualified business income" (max $0 (+ line2 line3)))
(def line5 :label "Qualified business income component" (* law/qbi-rate line4))
(def line6 :label "Qualified REIT dividends and PTP income or loss"
  (sum f1099-divs section-199a))                                 ; + PTP income
(def line7 :label "Qualified REIT dividends and PTP loss carryforward from the prior year"
  (- reit-ptp-loss-carryforward))
(def line8 :label "Total qualified REIT dividends and PTP income" (max $0 (+ line6 line7)))
(def line9 :label "REIT and PTP component" (* law/qbi-rate line8))
(def line10 :label "Qualified business income deduction before the income limitation"
  (+ line5 line9))
(def line11 :label "Taxable income before qualified business income deduction"
  (- f1040/line11a f1040/line12e f1040/line13b))
; Net capital gain, increased by qualified dividends, as for the tax.
(def line12 :label "Net capital gain plus qualified dividends" f1040-qdcg/line4)
(def line13 (excess line11 line12))
(def line14 :label "Income limitation" :cite "IRC §199A(a)(2)" (* law/qbi-rate line13))
(def line15 :label "Qualified business income deduction" (min line10 line14))
; To carry forward to next year, as negative amounts.
(def line16 :label "Total qualified business loss carryforward" (min $0 (+ line2 line3)))
(def line17 :label "Total qualified REIT dividends and PTP loss carryforward"
  (min $0 (+ line6 line7)))
