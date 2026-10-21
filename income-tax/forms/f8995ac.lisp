; Schedule C (Form 8995-A) (Rev. December 2022), Loss Netting and
; Carryforward: the businesses' losses, and last year's, taken from the
; others' income in proportion to it (`f8995ac-line1b` on each Schedule C).
; IRC §199A(c)(2); Treas. Reg. §1.199A-1(d)(2)(iii).

(def line2 :label "Qualified business net loss carryforward from prior years"
  (- qbi-loss-carryforward))
(def line3 :label "Total losses" (+ (sum f1040scs (min $0 f8995aa-line11)) line2))
(def line4 :label "Total income" (sum f1040scs (max $0 f8995aa-line11)))
; As a positive amount, where the form has it in parentheses.
(def line5 :label "Losses netted with income of other businesses" (min (- line3) line4))
(def line6 :label "Qualified business net loss carryforward" (min $0 (+ line3 line5)))
