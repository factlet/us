; Student Loan Interest Deduction Worksheet (Form 1040 instructions,
; Schedule 1, line 21). IRC §221.

(def line1 :label "Student loan interest paid" (min (sum f1098-es interest) law/sli-max))
(def line2 :label "Total income" f1040/line9)
(def line4 :label "Modified adjusted gross income" line2)        ; − 3
(def line5 law/sli-phaseout-start)
(def line6 (excess line4 line5))
; The worksheet rounds to at least three places; this takes three.
(def line7 :label "Share phased out"
  (min 1 (round 0.001 (/ line6 law/sli-phaseout-range))))
(def line8 (* line1 line7))
(def line9 :label "Student loan interest deduction" (- line1 line8))
