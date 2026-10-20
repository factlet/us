; Schedule 8812 (2025), Credits for Qualifying Children and Other
; Dependents. IRC §24.

; ---- Part I: Child tax credit and credit for other dependents ----

(def line3 :label "Modified adjusted gross income" f1040/line11a)  ; + 2d
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
; Credit Limit Worksheet A: tax less other nonrefundable credits.
(def line13 :label "Credit limit" f1040/line18)                 ; − Schedule 3 credits
(def line14 :label "Child tax credit and credit for other dependents"
  (min line12 line13))

; ---- Part II-A: Additional child tax credit ----

(def line16a :label "Credit not allowed by the tax limit" (- line12 line14))
(def line16b (* line4 law/actc-per-child))
(def line17 (min line16a line16b))
(def line18a :label "Earned income" f1040/line1z)
(def line19 (excess line18a law/actc-earned-floor))
(def line20 (* law/actc-rate line19))

; ---- Part II-B: Certain filers who have three or more qualifying children ----

(def line21 :label "Withheld social security and Medicare taxes"
  (sum w2s (+ ss-withheld medicare-withheld)))
(def line23 line21)                                             ; + 22
(def line24 :label "Earned income credit" f1040/line27a)        ; + Schedule 3 line 11
(def line25 (excess line23 line24))
(def line26 (max line20 line25))

; ---- Part II-C: Additional child tax credit ----

; Part II-B is only for three or more children, and only when line 20
; leaves some of line 17 unclaimed.
(def line27 :label "Additional child tax credit"
  (if (and (>= line4 3) (< line20 line17)) (min line17 line26) (min line17 line20)))
