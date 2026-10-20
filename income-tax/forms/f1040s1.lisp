; Schedule 1 (2025), Additional Income and Adjustments to Income. So far
; only business income, unemployment compensation, HSAs, the IRA deduction
; and the student loan interest deduction.

; ---- Part I: Additional income ----

(def line3 :label "Business income or loss" (sum f1040scs line31))
(def line7 :label "Unemployment compensation" :cite "IRC §85"
  (sum f1099-gs unemployment))
(def line8f :label "Income from Form 8889"
  (+ you/f8889/line16 (if joint spouse/f8889/line16 $0)))         ; + Form 8889 line 20
(def line9 :label "Total other income" line8f)                   ; + 8a–8e 8g–8z
(def line10 :label "Additional income" (+ line3 line7 line9))    ; + 1 2a 4 5 6

; ---- Part II: Adjustments to income ----

(def line13 :label "HSA deduction" :cite "IRC §223"
  (+ you/f8889/line13 (if joint spouse/f8889/line13 $0)))
(def line15 :label "Deductible part of self-employment tax" :cite "IRC §164(f)"
  (+ you/f1040sse/line13 (if joint spouse/f1040sse/line13 $0)))
(def line20 :label "IRA deduction" :cite "IRC §219"
  (+ f1040s1-ira/line12a f1040s1-ira/line12b))
; Not on a separate return, nor for someone another taxpayer can claim.
(def line21 :label "Student loan interest deduction" :cite "IRC §221(c), (e)(2)"
  (if (or (= filing-status 'married-separate) claimed-as-dependent) $0 f1040s1-sli/line9))
(def line26 :label "Adjustments to income"
  (+ line13 line15 line20 line21))                               ; + 11 12 14 16–19 23 25
