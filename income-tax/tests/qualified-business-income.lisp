; The qualified business income deduction: Form 8995.

(test "20% of each business's profit, less its share of self-employment tax"
  (given you/birth-date 1990-05-01)
  (member w2s acme (given wages $60,000 medicare-wages $60,000 withheld $0 ss-wages $60,000))
  (member f1040scs consulting (given receipts $40,000))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s people)
  (expect f1040s1/line15 $2,825.91
          f8995/line2 $37,174.09                     ; $40,000 − $2,825.91
          f8995/line5 $7,434.818
          f8995/line11 $81,424.09                    ; $97,174.09 − $15,750
          f8995/line14 $16,284.818
          f1040/line13a $7,434.818
          f1040/line15 $73,989.272
          ; row middle $73,975: $1,192.50 + $4,386 + 22% × ($73,975 − $48,475)
          f1040/line16 $11,189))

(test "no more than 20% of taxable income less net capital gain and qualified dividends"
  (given you/birth-date 1990-05-01)
  (member f1040scs consulting (given receipts $40,000))
  (member f1099-divs fund (given ordinary $10,000 qualified $10,000))
  (empty w2s f1099-ints f1099-bs f1099-gs f1099-rs f1098-es ssa1099s people)
  (expect f8995/line10 $7,434.818
          f8995/line11 $31,424.09                    ; $47,174.09 − $15,750
          f8995/line12 $10,000
          f8995/line14 $4,284.818                    ; 20% × $21,424.09
          f8995/line15 $4,284.818))

(test "qualified REIT dividends add 20% of their own, and a business loss carries forward"
  (given you/birth-date 1990-05-01)
  (member w2s acme (given wages $50,000 medicare-wages $50,000 withheld $0))
  (member f1040scs shop (given receipts $5,000 other-expenses $8,000))
  (member f1099-divs reit (given ordinary $1,000 section-199a $1,000))
  (empty f1099-ints f1099-bs f1099-gs f1099-rs f1098-es ssa1099s people)
  (expect f8995/line2 -$3,000
          f8995/line4 $0
          f8995/line9 $200
          f1040/line13a $200
          f8995/line16 -$3,000))

(test "last year's qualified business loss offsets this year's income"
  (given you/birth-date 1990-05-01 qbi-loss-carryforward $7,174.09)
  (member w2s acme (given wages $60,000 medicare-wages $60,000 withheld $0 ss-wages $60,000))
  (member f1040scs consulting (given receipts $40,000))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s people)
  (expect f8995/line4 $30,000
          f8995/line15 $6,000
          f8995/line16 $0))

(test "a business's tips deducted on Schedule 1-A aren't qualified business income"
  (given you/birth-date 1990-05-01 you/tin 'ssn)
  (member w2s cafe
    (given wages $60,000 medicare-wages $60,000 withheld $0 ss-wages $60,000
           qualified-tips $30,000))
  (member f1040scs tours
    (given receipts $50,000 other-expenses $10,000 qualified-tips $20,000))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s people)
  ; $50,000 of tips, of which $25,000 is deducted: half of each job's
  (expect f1040s1a/line13 $25,000
          f1040s1a/tips-deducted-rate 0.5
          f8995/line2 $27,174.09                     ; $40,000 − $2,825.91 − $10,000
          f8995/line15 $5,434.818))

(test "above the threshold, Form 8995-A, where REIT dividends have no wage limit"
  (given you/birth-date 1990-05-01)
  (member w2s a (given wages $210,000 medicare-wages $210,000 withheld $0))
  (member f1099-divs reit (given ordinary $3,050 section-199a $3,050))
  (empty f1099-ints f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs people)
  (expect f8995/line11 $197,300                      ; at the threshold
          f1040/line13a $610)
  (member w2s b (given wages $1 medicare-wages $1 withheld $0))
  (expect f8995a/line31 $610
          f1040/line13a $610))

(test "past the phase-in range, no more than 50% of the business's W-2 wages"
  (given you/birth-date 1990-05-01)
  (empty w2s f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s people)
  (member f1040scs shop
    (given receipts $600,000 wages $100,000 w2-wages $100,000 ubia $0)
    (expect f8995a-line10 $50,000 f8995a-line15 $50,000))
  (expect f8995a/phase-in false
          f1040/line13a $50,000))                    ; not 20% of its $482,386.43

(test "or 25% of them plus 2.5% of its property, if more"
  (given you/birth-date 1990-05-01)
  (empty w2s f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s people)
  (member f1040scs shop
    (given receipts $600,000 wages $100,000 w2-wages $100,000 ubia $2,000,000)
    (expect f8995a-line10 $75,000))                  ; $25,000 + $50,000
  (expect f1040/line13a $75,000))

(test "within the phase-in range, only that share of the excess over the limit is lost"
  ; Statutory employee income: qualified business income with no
  ; self-employment tax.
  (given you/birth-date 1990-05-01)
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s people)
  (member w2s acme (given wages $198,050 medicare-wages $198,050 withheld $0))
  (member f1040scs route
    (given receipts $40,000 statutory-employee true w2-wages $0 ubia $0)
    (expect f8995a-line3 $8,000 f8995a-line10 $0 f8995a-line26 $4,000))
  (expect f8995a/line20 $222,300
          f8995a/line24 0.5                          ; $25,000 of the $50,000
          f1040/line13a $4,000))

(test "a specified service business counts in part within the range, and not at all past it"
  (given you/birth-date 1990-05-01)
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s people)
  (member w2s acme (given wages $198,050 medicare-wages $198,050 withheld $0))
  (member f1040scs practice
    (given receipts $40,000 statutory-employee true specified-service true w2-wages $0 ubia $0)
    (expect f8995aa-line11 $20,000))                 ; 50% of it
  (expect f8995aa/line10 0.5
          f1040/line13a $2,000)                      ; $4,000, half of it lost
  (member w2s raise (given wages $30,000 medicare-wages $30,000 withheld $0))
  (expect f8995aa/line10 0
          f1040/line13a $0))

(test "a business's loss nets against the others' income, and its wages don't count"
  (given you/birth-date 1990-05-01)
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s people)
  (member w2s acme
    (given wages $300,000 medicare-wages $300,000 withheld $0 ss-wages $176,100
           medicare-withheld $4,350))
  (member f1040scs a (given receipts $100,000 w2-wages $20,000 ubia $0)
    (expect f8995a-line10 $10,000 f8995a-line15 $10,000))
  ; Not asked for its wages or property.
  (member f1040scs b (given receipts $10,000 other-expenses $30,000)
    (expect qbi -$20,000 f8995ac-line1c $0 f8995a-line15 $0))
  (member f1040scs c (given receipts $100,000 w2-wages $0 ubia $0)
    (expect f8995a-line15 $0))
  (expect f8995ac/line5 $20,000
          f8995ac/line6 $0
          f1040/line13a $10,000))
