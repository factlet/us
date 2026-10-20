; Schedule D (2025), Capital Gains and Losses, with every sale on Form 8949.
; Lines 1a through 3, and 8a through 10, are each taken together: which of
; them a sale goes on doesn't change the tax.

; ---- Part I: Short-term ----

(def short-term-sales :label "Short-term sales (lines 1a–3)"
  (sum f1099-bs (if long-term $0 gain)))
(def line6 :label "Short-term capital loss carryover" (- $0 st-loss-carryover))
(def line7 :label "Net short-term capital gain or loss"
  (+ short-term-sales line6))                                    ; + 4 5

; ---- Part II: Long-term ----

(def long-term-sales :label "Long-term sales (lines 8a–10)"
  (sum f1099-bs (if long-term gain $0)))
(def line13 :label "Capital gain distributions" (sum f1099-divs cap-gain))
(def line14 :label "Long-term capital loss carryover" (- $0 lt-loss-carryover))
(def line15 :label "Net long-term capital gain or loss"
  (+ long-term-sales line13 line14))                             ; + 11 12

; ---- Part III: Summary ----

(def line16 :label "Net capital gain or loss" (+ line7 line15))
; Lines 18 and 19, 28% rate gain and unrecaptured section 1250 gain, aren't
; modeled, so line 20 always leads to the Qualified Dividends and Capital
; Gain Tax Worksheet.
; A net loss comes off other income up to the limit; the rest carries over
; to next year.
(def line21 :label "Deductible capital loss" :cite "IRC §1211(b)"
  (if (< line16 $0) (max line16 (- $0 law/capital-loss-limit)) $0))
