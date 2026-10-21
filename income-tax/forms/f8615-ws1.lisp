; Form 8615 instructions, Line 5 Worksheet #1: the child's qualified
; dividends and net capital gain in net unearned income, when that's all of
; the unearned income over $2,700. Each loses its share of the $2,700.

(def line1 :label "Child's qualified dividends" f1040-qdcg/line2)
(def line2 :label "Child's net capital gain" f1040-qdcg/line3)
(def line3 f8615/line1)
(def line4 (min 1 (/ line1 line3)))
(def line5 (min 1 (/ line2 line3)))
(def line6 (* f8615/line2 line4))
(def line7 (* f8615/line2 line5))
(def line8 :label "Qualified dividends on Form 8615, line 5"
  (min f8615/line5 (excess line1 line6)))
(def line9 :label "Net capital gain on Form 8615, line 5"
  (min (- f8615/line5 line8) (excess line2 line7)))
