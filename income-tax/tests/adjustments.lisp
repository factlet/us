; Adjustments to income: Schedule 1 Part II.

(test "student loan interest is deducted up to $2,500"
  (given filing-status 'single you/birth-date 1990-05-01)
  (member w2s acme (given wages $60,000 withheld $6,000))
  (member f1098-es lender (given interest $3,000))
  (empty f1099-ints f1099-divs f1099-gs dependents)
  (expect f1040s1-sli/line1 $2,500
          f1040s1-sli/line7 0
          f1040/line10 $2,500
          f1040/line11a $57,500
          f1040/line15 $41,750
          ; row middle $41,775: $1,192.50 + 12% × ($41,775 − $11,925)
          f1040/line16 $4,775
          f1040/line34 $1,225))

(test "it phases out over $15,000 of modified AGI from $85,000"
  (given filing-status 'single you/birth-date 1990-05-01)
  (member w2s acme (given wages $90,000 withheld $0))
  (member f1098-es lender (given interest $2,000))
  (empty f1099-ints f1099-divs f1099-gs dependents)
  (expect f1040s1-sli/line4 $90,000
          f1040s1-sli/line7 0.333                    ; $5,000 ÷ $15,000
          f1040s1-sli/line8 $666
          f1040/line10 $1,334
          f1040/line11a $88,666)
  (member w2s side-gig (given wages $10,000 withheld $0))
  (expect f1040s1-sli/line7 1 f1040/line10 $0))

(test "on a joint return it phases out over $30,000 from $170,000"
  (given filing-status 'married-joint)
  (member w2s acme (given wages $180,000 withheld $0))
  (member f1098-es lender (given interest $2,500))
  (empty f1099-ints f1099-divs f1099-gs dependents)
  (expect f1040s1-sli/line7 0.333                    ; $10,000 ÷ $30,000
          f1040s1-sli/line8 $832.50
          f1040/line10 $1,667.50))

(test "no deduction on a separate return, or for someone another can claim"
  (given filing-status 'married-separate)
  (member w2s acme (given wages $30,000 withheld $0))
  (member f1098-es lender (given interest $1,000))
  (empty f1099-ints f1099-divs f1099-gs dependents)
  (expect f1040/line10 $0)
  (given filing-status 'single claimed-as-dependent true)
  (expect f1040/line10 $0)
  (given claimed-as-dependent false)
  (expect f1040/line10 $1,000))
