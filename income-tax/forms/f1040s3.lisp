; Schedule 3 (2025), Additional Credits and Payments. So far only the
; credit for child and dependent care expenses, the education credits, the
; saver's credit, and the net premium tax credit.

; ---- Part I: Nonrefundable credits ----

(def line2 :label "Credit for child and dependent care expenses" f2441/line11)
(def line3 :label "Education credits" f8863/line19)
(def line4 :label "Retirement savings contributions credit" f8880/line12)
(def line8 :label "Nonrefundable credits" (+ line2 line3 line4)) ; + 1 5a 5b 7

; ---- Part II: Other payments and refundable credits ----

(def line9 :label "Net premium tax credit" f8962/line26)
(def line15 :label "Other payments and refundable credits" line9)  ; + 10–12 14
