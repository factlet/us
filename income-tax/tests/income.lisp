; Income: wages, interest and dividends.

(test "interest and dividends add to wages, but tax-exempt interest doesn't"
  (given filing-status 'single you/birth-date 1990-05-01)
  (member w2s acme (given wages $40,000 withheld $3,000))
  (member f1099-ints bank (given interest $1,200 treasury-interest $800 withheld $100))
  (member f1099-ints muni (given interest $0 tax-exempt-interest $500))
  (member f1099-divs fund (given ordinary $1,000 exempt-interest $250))
  (empty dependents)
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
  (given filing-status 'single)
  (member w2s acme (given wages $40,000 withheld $3,000))
  (expect f1040/line9 ?)
  (empty f1099-ints)
  (expect f1040/line9 ?)
  (empty f1099-divs)
  (expect f1040/line9 $40,000))
