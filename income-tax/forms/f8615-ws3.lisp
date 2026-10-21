; Form 8615 instructions, Line 5 Worksheet #3: the child's qualified
; dividends and net capital gain in net unearned income, when taxable
; income is less. They bear their share of the deduction, by their share of
; AGI. Itemized deductions are all taken as not directly connected with the
; income (lines 5 through 7).

(def line1 :label "Child's qualified dividends" f1040-qdcg/line2)
(def line2 :label "Child's net capital gain" f1040-qdcg/line3)
(def line3 (+ line1 line2))
(def line4 (if (= line3 $0) 0 (/ line1 line3)))
(def line8 line2)                                                ; − 7
(def line9 line1)                                                ; − 6
(def line11 :label "Standard deduction, or itemized deductions" f1040/line12e)
(def line12 line11)                                              ; + 10
(def line13 :label "Child's AGI" f1040/line11b)
(def line14 (min 1 (/ line3 line13)))
(def line15 (* line12 line14))
(def line16 (* line15 line4))
(def line17 (- line15 line16))
(def line18 :label "Qualified dividends on Form 8615, line 5"
  (min f8615/line5 (excess line9 line16)))
(def line19 :label "Net capital gain on Form 8615, line 5"
  (min (- f8615/line5 line18) (excess line8 line17)))
