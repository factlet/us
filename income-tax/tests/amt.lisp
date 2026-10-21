; The alternative minimum tax: Form 6251, and Schedule 2 line 2.

(test "incentive stock options can bring on the AMT"
  (given you/birth-date 1990-05-01)
  (member w2s acme (given wages $200,000 medicare-wages $200,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs people)
  ; $1,192.50 + $4,386 + $12,072.50 + 24% × ($184,250 − $103,350)
  (expect f1040/line16 $37,067
          f6251/line4 $200,000                       ; the standard deduction back
          f6251/line7 $29,094                        ; 26% × ($200,000 − $88,100)
          f6251/line11 $0)
  (given iso-adjustment $100,000)
  (expect f6251/line4 $300,000
          f6251/line7 $55,094                        ; 26% × $211,900
          f6251/line11 $18,027
          f1040s2/line2 $18,027
          f1040/line17 $18,027
          f1040/line18 $55,094))

(test "the exemption comes down by 25% past $626,350, and 28% starts at $239,100"
  (given you/birth-date 1990-05-01)
  (member w2s acme (given wages $700,000 medicare-wages $700,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs people)
  (expect f6251/line5 $69,687.50                     ; $88,100 − 25% × $73,650
          f6251/line6 $630,312.50
          f6251/line7 $171,705.50                    ; 28% × $630,312.50 − $4,782
          f6251/line11 $0)                           ; less than the regular tax
  (member w2s b (given wages $300,000 medicare-wages $300,000 withheld $0))
  (expect f6251/line5 $0))

(test "qualified dividends keep their rates (Part III)"
  (given you/birth-date 1990-05-01 iso-adjustment $200,000)
  (member w2s acme (given wages $150,000 medicare-wages $150,000 withheld $0))
  (member f1099-divs fund (given ordinary $100,000 qualified $100,000))
  (empty f1099-ints f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs people)
  (expect f1040/line16 $40,067
          f6251/line6 $361,900                       ; $450,000 − $88,100
          ; 26% × $239,100 + 28% × $22,800 on the rest
          f6251/line18 $68,550
          f6251/line30 $100,000                      ; all at 15%
          f6251/line38 $83,550
          f6251/line39 $96,550
          f6251/line7 $83,550
          f6251/line11 $43,483))

(test "married filing separately: a smaller exemption and 28% bracket, and AMTI raised past $900,350"
  (given you/birth-date 1990-05-01 married true files-separately true iso-adjustment $420,350)
  (member w2s acme (given wages $500,000 medicare-wages $500,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs people)
  (expect f6251/amti $920,350
          f6251/line4 $925,350                       ; + 25% × $20,000
          f6251/line5 $0
          f6251/line7 $256,707                       ; 28% × $925,350 − $2,391
          f1040/line16 $141,204
          f6251/line11 $115,503))

(test "the senior deduction and private activity bond interest count toward AMTI"
  (given you/birth-date 1955-01-01 you/tin 'ssn)
  (member w2s acme (given wages $60,000 medicare-wages $60,000 withheld $0))
  (member f1099-ints muni
    (given interest $0 tax-exempt-interest $20,000 private-activity-interest $20,000))
  (empty f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs people)
  (expect f1040/line15 $36,250                       ; less $17,750 and the $6,000 senior deduction
          f6251/line1b $42,250                       ; only the $17,750 taken off
          f6251/line2g $20,000
          f6251/line4 $80,000
          f6251/line11 $0))
