; Form 1040 (2025), U.S. Individual Income Tax Return.

(def line1a :label "Wages from Forms W-2" :line 1a (sum w2s wages))
(def line11a :label "Adjusted gross income" :line 11a :cite "IRC §62" line1a)
(def line12e :label "Standard deduction" :line 12e :cite "IRC §63(c)" law/std-deduction)
(def line15 :label "Taxable income" :line 15 :cite "IRC §63" (excess line11a line12e))
; The Tax Computation Worksheet; the Tax Table below $100,000 is to come.
(def line16 :label "Tax" :line 16 :cite "IRC §1" (round $1 (brackets line15 law/brackets)))
