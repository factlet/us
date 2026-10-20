; Form 8960 (2025), Net Investment Income Tax: 3.8% of net investment
; income or of modified AGI over the threshold, whichever is less. IRC §1411.

; ---- Part I: Investment income ----

(def line1 :label "Taxable interest" f1040/line2b)
(def line2 :label "Ordinary dividends" f1040/line3b)
(def line5a :label "Net gain from dispositions" f1040/line7a)  ; + Form 4797
(def line5d line5a)                                              ; + 5b 5c
(def line8 :label "Total investment income"
  (+ line1 line2 line5d))                                        ; + 3 4c 6 7

; ---- Part III: Tax computation ----

(def line12 :label "Net investment income" (max $0 line8))       ; − 11
(def line13 :label "Modified adjusted gross income" f1040/line11a)
(def line14 :label "Threshold" law/niit-threshold)
(def line15 (excess line13 line14))
(def line16 (min line12 line15))
(def line17 :label "Net investment income tax" :cite "IRC §1411(a)(1)"
  (* law/niit-rate line16))
