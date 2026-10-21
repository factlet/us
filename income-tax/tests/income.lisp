; Income: wages, interest, dividends and unemployment.

(test "interest and dividends add to wages, but tax-exempt interest doesn't"
  (given you/birth-date 1990-05-01)
  (member w2s acme (given wages $40,000 medicare-wages $40,000 withheld $3,000))
  (member f1099-ints bank (given interest $1,200 treasury-interest $800 withheld $100))
  (member f1099-ints muni (given interest $0 tax-exempt-interest $500))
  (member f1099-divs fund (given ordinary $1,000 exempt-interest $250))
  (empty f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs people)
  (expect f1040/line2a $750
          f1040/line2b $2,000
          f1040/line3b $1,000
          f1040/line9 $43,000
          f1040/line15 $27,250
          ; row $27,250–$27,300: $1,192.50 + 12% × ($27,275 − $11,925)
          f1040/line16 $3,035
          f1040/line25d $3,100
          f1040/line34 $65))

(test "income waits on every kind of document"
  (member w2s acme (given wages $40,000 medicare-wages $40,000 withheld $3,000))
  (expect f1040/line9 ?)
  (empty f1099-ints)
  (expect f1040/line9 ?)
  (empty f1099-divs)
  (expect f1040/line9 ?)
  (empty f1099-bs)
  (expect f1040/line9 ?)
  (empty f1099-gs)
  (expect f1040/line9 ?)
  (empty f1099-rs)
  (expect f1040/line9 ?)
  (empty ssa1099s)
  (expect f1040/line9 ?)
  (empty f1040scs)
  (expect f1040/line9 $40,000))

(test "unemployment adds to income, but isn't earned income"
  (given you/birth-date 1990-05-01 you/tin 'ssn)
  (member w2s acme (given wages $8,000 medicare-wages $8,000 withheld $0))
  (member f1099-gs state (given unemployment $4,000 withheld $400))
  (empty f1099-ints f1099-divs f1099-bs f1099-rs f1098-es ssa1099s f1040scs people)
  (expect f1040s1/line7 $4,000
          f1040/line8 $4,000
          f1040/line11a $12,000
          f1040/line16 $0
          f1040/line25b $400
          ; the EIC on earned income, 7.65% × $8,025, is $614, but past the
          ; phaseout start it can't exceed the EIC on AGI:
          ; $649 − 7.65% × ($12,025 − $10,620)
          f1040-eic/line2 $614
          f1040/line27a $542
          f1040/line34 $942))
