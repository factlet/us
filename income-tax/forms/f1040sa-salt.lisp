; State and Local Tax Deduction Worksheet (Schedule A instructions, line
; 5e): up to $40,000, less 30% of modified AGI over $500,000, but not below
; $10,000. On a separate return the threshold is $250,000, and the limit
; half of what that leaves. IRC §164(b)(7).

(def line1 law/salt-limit)
(def line2 :label "Adjusted gross income" f1040/line11b)
(def line4 :label "Modified adjusted gross income" line2)        ; + 3e
(def line5 law/salt-phaseout-start)
(def line6 (excess line4 line5))
(def line7 (* law/salt-phaseout-rate line6))
(def line8 (- line1 line7))
(def line9 (max line8 law/salt-floor))
(def line10 :label "State and local tax deduction"
  (min (if (= filing-status 'married-separate) (/ line9 2) line9) f1040sa/line5d))
