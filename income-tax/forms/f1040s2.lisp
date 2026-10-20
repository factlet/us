; Schedule 2 (2025), Additional Taxes. So far only the additional taxes on
; early distributions from IRAs and retirement plans, and on HSA
; distributions not spent on medical care.

; ---- Part II: Other taxes ----

; With code 1 on the Form 1099-R and no exception to claim, it's 10% of the
; taxable part, without Form 5329.
(def line8 :label "Additional tax on IRAs and other retirement plans" :cite "IRC §72(t)"
  (* law/early-distribution-rate (sum f1099-rs (if early taxable-part $0))))
(def line17c :label "Additional tax on HSA distributions"
  (+ you/f8889/line17b (if joint spouse/f8889/line17b $0)))
(def line18 :label "Total additional taxes" line17c)             ; + 17a 17b 17d–17z
(def line21 :label "Total other taxes" (+ line8 line18))         ; + 4 7 9–16 19
