; Form 8995-A (2025), Qualified Business Income Deduction, for taxable
; income before it over the threshold. Each business's column of Parts II
; and III is on its Schedule C (`f8995a-line2` through `f8995a-line26`).
; IRC §199A.

(def line16 :label "Total qualified business income component"
  (sum f1040scs f8995a-line15))

; ---- Part III: Phased-in reduction ----

(def line20 :label "Taxable income before qualified business income deduction" f8995/line11)
(def line21 law/qbi-threshold)
(def line22 (- line20 line21))
(def line23 law/qbi-phase-in-range)
(def line24 :label "Phase-in percentage" (/ line22 line23))
(def phase-in :label "Within the phase-in range" (<= line22 line23))

; ---- Part IV: Determine your qualified business income deduction ----

(def line27 line16)
(def line28 :label "Qualified REIT dividends and PTP income or loss" f8995/line6)
(def line29 f8995/line7)
(def line30 (max $0 (+ line28 line29)))
(def line31 :label "REIT and PTP component" (* law/qbi-rate line30))
(def line32 (+ line27 line31))
(def line33 line20)
(def line34 :label "Net capital gain plus qualified dividends" f8995/line12)
(def line35 (excess line33 line34))
(def line36 :label "Income limitation" :cite "IRC §199A(a)(2)" (* law/qbi-rate line35))
(def line37 (min line32 line36))
(def line39 :label "Total qualified business income deduction" line37)  ; + 38
(def line40 :label "Total qualified REIT dividends and PTP loss carryforward"
  (min $0 (+ line28 line29)))
