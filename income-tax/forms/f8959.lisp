; Form 8959 (2025), Additional Medicare Tax: 0.9% of Medicare wages and
; self-employment income over the threshold, both spouses' together on a
; joint return. IRC §§1401(b)(2), 3101(b)(2).

; ---- Part I: Medicare wages ----

(def line1 :label "Medicare wages and tips" (sum w2s medicare-wages))
(def line4 line1)                                                ; + 2 3
(def line5 :label "Threshold" law/medicare-surtax-threshold)
(def line6 (excess line4 line5))
(def line7 :label "Additional Medicare Tax on Medicare wages"
  (* law/medicare-surtax-rate line6))

; ---- Part II: Self-employment income ----

(def line8 :label "Self-employment income"
  (max $0 (+ you/f1040sse/line6 (if joint spouse/f1040sse/line6 $0))))
(def line9 law/medicare-surtax-threshold)
(def line10 line4)
(def line11 :label "What wages leave of the threshold" (excess line9 line10))
(def line12 (excess line8 line11))
(def line13 :label "Additional Medicare Tax on self-employment income"
  (* law/medicare-surtax-rate line12))

; ---- Part IV: Total ----

(def line18 :label "Additional Medicare Tax" (+ line7 line13))  ; + 17

; ---- Part V: Withholding reconciliation ----

; Lines 19 through 21 a W-2 at a time: an employer withholds the 0.9% only
; on Medicare wages it pays over $200,000 (IRC §3102(f)), so box 6 is more
; than the regular 1.45% only on such a W-2, the only kind asked for it.
(def line22 :label "Additional Medicare Tax withholding"
  (sum w2s (if (> medicare-wages law/medicare-surtax-withholding-start)
               (excess medicare-withheld (* law/medicare-rate medicare-wages))
               $0)))
(def line24 :label "Total Additional Medicare Tax withholding" line22)  ; + 23
