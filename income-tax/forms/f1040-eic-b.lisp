; EIC Worksheet B (Form 1040 instructions, line 27a), Parts 1 through 4:
; earned income for someone self-employed, with both spouses' amounts
; together on a joint return. Its lines 6 through 11 repeat Worksheet A's
; 1 through 6 (`f1040-eic`), starting from line 4b here. With no one
; self-employed, line 4b is Step 5's earned income, as Worksheet A takes it.

; ---- Part 1: Filing Schedule SE ----

(defn filing [se-line : usd required : bool] (if required se-line $0))
(def line1a :label "Schedule SE line 3"
  (+ (filing you/f1040sse/line3 you/f1040sse/required)
     (if joint (filing spouse/f1040sse/line3 spouse/f1040sse/required) $0)))
(def line1c line1a)                                              ; + 1b
(def line1d :label "Schedule SE line 13"
  (+ you/f1040sse/line13 (if joint spouse/f1040sse/line13 $0)))
(def line1e (- line1c line1d))

; ---- Part 2: Self-employed, not filing Schedule SE ----

; Net earnings under $400, a profit or a loss, is still earned income.
(defn not-filing [se-line : usd required : bool] (if required $0 se-line))
(def line2b :label "Schedule C line 31"
  (+ (not-filing you/f1040sse/line2 you/f1040sse/required)
     (if joint (not-filing spouse/f1040sse/line2 spouse/f1040sse/required) $0)))
(def line2c line2b)                                              ; + 2a

; ---- Part 3: Statutory employees ----

(def line3 :label "Statutory employee income from Schedule C line 1"
  (sum f1040scs (if statutory-employee receipts $0)))

; ---- Part 4 ----

(def line4a :label "Earned income from Step 5" f1040/line1z)     ; − Medicaid waiver payments + combat pay
(def line4b :label "Total earned income" (+ line1e line2c line3 line4a))
