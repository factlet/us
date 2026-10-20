; Qualified Dividends and Capital Gain Tax Worksheet (Form 1040
; instructions, line 16). Qualified dividends and net capital gain sit on
; top of ordinary income and are taxed at 0%, 15% or 20% by where they fall.

(def line1 :label "Taxable income" f1040/line15)
(def line2 :label "Qualified dividends" f1040/line3a)
; Schedule D's net long-term gain, as far as the net gain goes: just the
; capital gain distributions when they're all there is.
(def line3 :label "Net capital gain"
  (max $0 (min f1040sd/line15 f1040sd/line16)))
(def line4 (+ line2 line3))
(def line5 :label "Ordinary income" (excess line1 line4))
(def line6 law/cg-0%-top)
(def line7 (min line1 line6))
(def line8 (min line5 line7))
(def line9 :label "Taxed at 0%" (- line7 line8))
(def line10 (min line1 line4))
(def line11 line9)
(def line12 (- line10 line11))
(def line13 law/cg-15%-top)
(def line14 (min line1 line13))
(def line15 (+ line5 line9))
(def line16 (excess line14 line15))
(def line17 :label "Taxed at 15%" (min line12 line16))
(def line18 :cite "IRC §1(h)(1)(C)" (* 15% line17))
(def line19 (+ line9 line17))
(def line20 :label "Taxed at 20%" (- line10 line19))
(def line21 :cite "IRC §1(h)(1)(D)" (* 20% line20))
(def line22 :label "Tax on ordinary income" (f1040/tax-on line5))
(def line23 (+ line18 line21 line22))
(def line24 :label "Tax as if all ordinary" (f1040/tax-on line1))
(def line25 :label "Tax" :cite "IRC §1(h)" (round $1 (min line23 line24)))
