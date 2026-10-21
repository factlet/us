; Form 6251 (2025), Alternative Minimum Tax—Individuals: a second tax on a
; broader base, owed to the extent it's more than the regular tax.
; IRC §§55–59.

; ---- Part I: Alternative minimum taxable income ----

; Taxable income with the senior deduction added back.
(def line1a :cite "IRC §56(b)(1)(E)" (- f1040/line14 f1040s1a/line37))
(def line1b (- f1040/line11b line1a))
; State and local taxes for someone itemizing, or else the standard
; deduction: neither is allowed.
(def line2a :label "Taxes, or the standard deduction" :cite "IRC §56(b)(1)(A), (E)"
  (if f1040/itemizes f1040sa/line7 f1040/line12e))
(def line2g :label "Interest from specified private activity bonds" :cite "IRC §57(a)(5)"
  (+ (sum f1099-ints private-activity-interest) (sum f1099-divs private-activity-dividends)))
(def line2i :label "Exercise of incentive stock options" :cite "IRC §56(b)(3)" iso-adjustment)
; Line 4, raised on a separate return by 25% of what's past the end of
; the exemption's phaseout, up to the exemption.
(def end-of-phaseout (+ law/amt-phaseout-start (/ law/amt-exemption law/amt-phaseout-rate)))
(def amti (+ line1b line2a line2g line2i))                       ; + 2b–2f 2h 2j–2t 3
(def line4 :label "Alternative minimum taxable income" :cite "IRC §55(b)(2), (d)"
  (if (= filing-status 'married-separate)
      (+ amti (min law/amt-exemption (* law/amt-phaseout-rate (excess amti end-of-phaseout))))
      amti))

; ---- Part II: Alternative minimum tax ----

; Exemption Worksheet.
(def line5 :label "Exemption" :cite "IRC §55(d)"
  (excess law/amt-exemption (* law/amt-phaseout-rate (excess line4 law/amt-phaseout-start))))
(def line6 (excess line4 line5))
(defn amt-on [amount : usd] (brackets amount law/amt-brackets))
; With qualified dividends or net capital gain, Part III.
(def line7 :cite "IRC §55(b)(1)(A)"
  (if (= f1040-qdcg/line4 $0) (amt-on line6) line40))
(def line9 :label "Tentative minimum tax" line7)                 ; − 8
; The regular tax, with Schedule 2's other additions to it.
(def line10 :label "Regular tax" :cite "IRC §55(c)"
  (+ f1040/line16 f1040s2/line1z))                               ; − Schedule 3 line 1
(def line11 :label "Alternative minimum tax" :cite "IRC §55(a)" (excess line9 line10))

; ---- Part III: Tax computation using maximum capital gains rates ----

; The Qualified Dividends and Capital Gain Tax Worksheet's amounts, which
; are the same for the AMT without any AMT adjustments to capital gains.
(def line12 line6)
(def line13 :label "Qualified dividends and net capital gain" f1040-qdcg/line4)
(def line15 line13)                                              ; + 14
(def line16 (min line12 line15))
(def line17 (- line12 line16))
(def line18 (amt-on line17))
(def line19 (law/cg-0%-top-for filing-status))
(def line20 f1040-qdcg/line5)
(def line21 (excess line19 line20))
(def line22 (min line12 line13))
(def line23 :label "Taxed at 0%" (min line21 line22))
(def line24 (- line22 line23))
(def line25 (law/cg-15%-top-for filing-status))
(def line26 line21)
(def line27 f1040-qdcg/line5)
(def line28 (+ line26 line27))
(def line29 (excess line25 line28))
(def line30 :label "Taxed at 15%" (min line24 line29))
(def line31 :cite "IRC §55(b)(3)" (* 15% line30))
(def line32 (+ line23 line30))
(def line33 :label "Taxed at 20%" (- line22 line32))
(def line34 :cite "IRC §55(b)(3)" (* 20% line33))
(def line38 (+ line18 line31 line34))                            ; + 37
(def line39 (amt-on line12))
(def line40 (min line38 line39))
