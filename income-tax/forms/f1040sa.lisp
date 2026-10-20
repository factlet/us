; Schedule A (2025), Itemized Deductions. IRC §§63(d), 211–225.

; ---- Medical and dental expenses ----

(input medical : usd :default $0
  :label "Medical and dental expenses, not reimbursed" :line 1 :cite "IRC §213")
(def line1 medical)
(def line2 :label "Adjusted gross income" f1040/line11b)
(def line3 (* law/medical-floor line2))
(def line4 :label "Deductible medical and dental expenses" (excess line1 line3))

; ---- Taxes you paid ----

(input income-taxes : usd :default $0
  :label "State and local income taxes, or general sales taxes instead" :line 5a
  :cite "IRC §164(a)(3), (b)(5)")
(input real-estate-taxes : usd :default $0
  :label "State and local real estate taxes" :line 5b :cite "IRC §164(a)(1)")
(input property-taxes : usd :default $0
  :label "State and local personal property taxes" :line 5c :cite "IRC §164(a)(2)")
(def line5d (+ income-taxes real-estate-taxes property-taxes))
(def line5e :label "State and local taxes, up to the limit" :cite "IRC §164(b)(6), (7)"
  f1040sa-salt/line10)
(input other-taxes : usd :default $0 :label "Other taxes, such as foreign income taxes" :line 6)
(def line7 (+ line5e other-taxes))

; ---- Interest you paid ----

; Taken in full: the limit to interest on $750,000 of mortgage debt
; (Pub. 936) isn't applied.
(input mortgage-interest : usd :default $0
  :label "Home mortgage interest and points reported on Form 1098" :line 8a
  :cite "IRC §163(h)(3)")
(input other-mortgage-interest : usd :default $0
  :label "Home mortgage interest not reported on Form 1098" :line 8b)
(input points : usd :default $0 :label "Points not reported on Form 1098" :line 8c)
(def line8e (+ mortgage-interest other-mortgage-interest points))
(input investment-interest : usd :default $0
  :label "Investment interest (Form 4952)" :line 9 :cite "IRC §163(d)")
(def line10 (+ line8e investment-interest))

; ---- Gifts to charity ----

; Taken in full: the limits by share of AGI (Pub. 526) aren't applied.
(input cash-gifts : usd :default $0
  :label "Gifts to charity by cash or check" :line 11 :cite "IRC §170")
(input noncash-gifts : usd :default $0
  :label "Gifts to charity other than by cash or check" :line 12)
(input gift-carryover : usd :default $0
  :label "Charitable contributions carried over from earlier years" :line 13)
(def line14 (+ cash-gifts noncash-gifts gift-carryover))

; ---- Casualty and theft losses, and other itemized deductions ----

(input casualty : usd :default $0
  :label "Casualty and theft losses from a federally declared disaster (Form 4684)"
  :line 15 :cite "IRC §165(h)")
(input other-itemized : usd :default $0
  :label "Other itemized deductions, from the list in the instructions" :line 16)

; ---- Total ----

(def line17 :label "Total itemized deductions"
  (+ line4 line7 line10 line14 casualty other-itemized))
(input elect-itemize : bool :default false
  :label "Itemize even though less than the standard deduction" :line 18
  :cite "IRC §63(e)")
