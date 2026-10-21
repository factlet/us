; Schedule 2 (2025), Additional Taxes. So far only the repayment of excess
; advance premium tax credit, the alternative minimum tax, self-employment
; tax, the Additional Medicare
; Tax, the net investment income tax, and the additional taxes on early
; distributions from IRAs and retirement plans and on HSA distributions
; not spent on medical care.

; ---- Part I: Tax ----

(def line1a :label "Excess advance premium tax credit repayment" f8962/line29)
(def line1z :label "Other additions to tax" line1a)            ; + 1b–1y
(def line2 :label "Alternative minimum tax" f6251/line11)
(def line3 :label "Additions to tax" (+ line1z line2))

; ---- Part II: Other taxes ----

(def line4 :label "Self-employment tax" :cite "IRC §1401"
  (+ you/f1040sse/line12 (if joint spouse/f1040sse/line12 $0)))

; With code 1 on the Form 1099-R and no exception to claim, it's 10% of the
; taxable part, without Form 5329.
(def line8 :label "Additional tax on IRAs and other retirement plans" :cite "IRC §72(t)"
  (* law/early-distribution-rate (sum f1099-rs (if early taxable-part $0))))
(def line11 :label "Additional Medicare Tax" f8959/line18)
(def line12 :label "Net investment income tax" f8960/line17)
(def line17c :label "Additional tax on HSA distributions"
  (+ you/f8889/line17b (if joint spouse/f8889/line17b $0)))
(def line18 :label "Total additional taxes" line17c)             ; + 17a 17b 17d–17z
(def line21 :label "Total other taxes"
  (+ line4 line8 line11 line12 line18))                          ; + 7 9 10 13–16 19
