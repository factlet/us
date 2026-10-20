; US federal individual income tax, tax year 2025.
;
; A form's lines are named after the line they fill: `f1040/line11a` is
; Form 1040, line 11a.

(unit usd :prefix "$" :places 2)

(enum filing-status
  single married-joint married-separate head-of-household
  qualifying-surviving-spouse)

; The form's "subtract b from a; if zero or less, enter -0-".
(defn excess [a : usd b : usd] (max $0 (- a b)))

(input filing-status : filing-status :label "Filing status")

(collection w2s :label "Forms W-2"
  (input wages : usd :label "Wages, tips, other compensation" :line 1))

(module law (include "law/2025.lisp"))

(module f1040 (include "forms/f1040.lisp"))
