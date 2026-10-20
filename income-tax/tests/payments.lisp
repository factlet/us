; Payments: withholding, and the refund or amount owed.

(test "withholding over the tax is refunded, and short of it is owed"
  (given filing-status 'single you/birth-date 1990-05-01)
  (member w2s acme (given wages $58,000 withheld $6,000))
  (empty f1099-ints f1099-divs f1099-gs f1099-rs f1098-es ssa1099s dependents)
  (expect f1040/line34 $1,165 f1040/line37 $0)       ; tax $4,835
  (member w2s side-gig (given wages $10,000 withheld $0))
  ; row middle $52,275: $5,578.50 + 22% × ($52,275 − $48,475) = $6,414.50
  (expect f1040/line16 $6,415
          f1040/line34 $0
          f1040/line37 $415))

(test "withholding from Forms 1099 counts with the W-2s'"
  (given filing-status 'single you/birth-date 1990-05-01)
  (member w2s acme (given wages $58,000 withheld $4,000))
  (member f1099-ints bank (given interest $0 withheld $300))
  (member f1099-divs fund (given ordinary $0 withheld $200))
  (empty f1099-gs f1099-rs f1098-es ssa1099s dependents)
  (expect f1040/line25b $500
          f1040/line25d $4,500
          f1040/line37 $335))                         ; tax $4,835
