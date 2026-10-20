; Schedule 1 (2025), Additional Income and Adjustments to Income. So far
; only unemployment compensation, the IRA deduction and the student loan
; interest deduction.

; ---- Part I: Additional income ----

(def line7 :label "Unemployment compensation" :cite "IRC §85"
  (sum f1099-gs unemployment))
(def line10 :label "Additional income" line7)                    ; + 1 2a 3 4 5 6 9

; ---- Part II: Adjustments to income ----

(def line20 :label "IRA deduction" :cite "IRC §219"
  (+ f1040s1-ira/line12a f1040s1-ira/line12b))
; Not on a separate return, nor for someone another taxpayer can claim.
(def line21 :label "Student loan interest deduction" :cite "IRC §221(c), (e)(2)"
  (if (or (= filing-status 'married-separate) claimed-as-dependent) $0 f1040s1-sli/line9))
(def line26 :label "Adjustments to income" (+ line20 line21))   ; + 11–19 23 25
