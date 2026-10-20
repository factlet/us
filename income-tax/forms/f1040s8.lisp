; Schedule 8812 (2025), Credits for Qualifying Children and Other
; Dependents. IRC §24.

; ---- Part I: Child tax credit and credit for other dependents ----

(def line3 :label "Modified adjusted gross income" f1040/line11a)
(def line4 :label "Qualifying children under 17 with an SSN"
  (count dependents ctc-child))
(def line5 (* line4 law/ctc-per-child))
(def line6 :label "Other dependents" (count dependents odc-dependent))
(def line7 (* line6 law/odc-per-dependent))
(def line8 (+ line5 line7))
(def line9 law/ctc-phaseout-start)
(def line10 (ceil $1,000 (excess line3 line9)))
(def line11 :label "Phaseout" (* law/ctc-phaseout-rate line10))
(def line12 (excess line8 line11))
; Credit Limit Worksheet A: the tax, until other credits are modeled.
(def line13 :label "Credit limit" f1040/line16)
(def line14 :label "Child tax credit and credit for other dependents"
  (min line12 line13))

; ---- Part II-A: Additional child tax credit ----

(def line16a :label "Credit not allowed by the tax limit" (- line12 line14))
(def line16b (* line4 law/actc-per-child))
(def line17 (min line16a line16b))
(def line18a :label "Earned income" f1040/line1a)
(def line19 (excess line18a law/actc-earned-floor))
(def line20 (* law/actc-rate line19))
; Part II-B, which can raise this for three or more children, comes with
; the earned income credit it subtracts.
(def line27 :label "Additional child tax credit" (min line17 line20))
