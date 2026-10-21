; Adjustments to income: Schedule 1 Part II.

(test "student loan interest is deducted up to $2,500"
  (given you/birth-date 1990-05-01)
  (member w2s acme (given wages $60,000 medicare-wages $60,000 withheld $6,000))
  (member f1098-es lender (given interest $3,000))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs ssa1099s f1040scs people)
  (expect f1040s1-sli/line1 $2,500
          f1040s1-sli/line7 0
          f1040/line10 $2,500
          f1040/line11a $57,500
          f1040/line15 $41,750
          ; row middle $41,775: $1,192.50 + 12% × ($41,775 − $11,925)
          f1040/line16 $4,775
          f1040/line34 $1,225))

(test "it phases out over $15,000 of modified AGI from $85,000"
  (given you/birth-date 1990-05-01)
  (member w2s acme (given wages $90,000 medicare-wages $90,000 withheld $0))
  (member f1098-es lender (given interest $2,000))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs ssa1099s f1040scs people)
  (expect f1040s1-sli/line4 $90,000
          f1040s1-sli/line7 0.333                    ; $5,000 ÷ $15,000
          f1040s1-sli/line8 $666
          f1040/line10 $1,334
          f1040/line11a $88,666)
  (member w2s side-gig (given wages $10,000 medicare-wages $10,000 withheld $0))
  (expect f1040s1-sli/line7 1 f1040/line10 $0))

(test "on a joint return it phases out over $30,000 from $170,000"
  (given married true)
  (member w2s acme (given wages $180,000 medicare-wages $180,000 withheld $0))
  (member f1098-es lender (given interest $2,500))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs ssa1099s f1040scs people)
  (expect f1040s1-sli/line7 0.333                    ; $10,000 ÷ $30,000
          f1040s1-sli/line8 $832.50
          f1040/line10 $1,667.50))

(test "no deduction on a separate return, or for someone another can claim"
  (given married true files-separately true)
  (member w2s acme (given wages $30,000 medicare-wages $30,000 withheld $0))
  (member f1098-es lender (given interest $1,000))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs ssa1099s f1040scs people)
  (expect f1040/line10 $0)
  (given married false claimed-as-dependent true)
  (expect f1040/line10 $0)
  (given claimed-as-dependent false)
  (expect f1040/line10 $1,000))

(test "with no IRA contribution, the IRA deduction asks nothing"
  (member w2s acme (given wages $50,000 medicare-wages $50,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs people)
  (expect f1040s1/line20 $0))

(test "not covered by a plan at work: up to $7,000, or $8,000 from 50"
  (given you/ira-contributions $8,500)
  (member w2s acme (given wages $200,000 medicare-wages $200,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs people)
  (given you/birth-date 1990-05-01)
  (expect f1040s1/line20 $7,000)
  (given you/birth-date 1970-06-01)
  (expect f1040s1/line20 $8,000
          f1040/line11a $192,000))

(test "covered by a plan at work, single: phased out from $79,000 to $89,000"
  (given you/birth-date 1990-05-01
         you/retirement-plan true you/ira-contributions $7,000)
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs people)
  (member w2s acme (given wages $79,000 medicare-wages $79,000 withheld $0))
  (expect f1040s1/line20 $7,000)
  (member w2s b (given wages $6,123 medicare-wages $6,123 withheld $0))
  ; 70% × ($89,000 − $85,123) = $2,713.90, rounded up to $10
  (expect f1040s1-ira/line6a $3,877
          f1040s1/line20 $2,720
          f1040/line11a $82,403)
  (member w2s c (given wages $3,677 medicare-wages $3,677 withheld $0))
  (expect f1040s1/line20 $200)                       ; 70% × $200 is $140
  (member w2s d (given wages $200 medicare-wages $200 withheld $0))
  (expect f1040s1/line20 $0))

(test "on a joint return, a spouse not covered phases out from $236,000 to $246,000"
  (given married true
         you/birth-date 1980-01-01 you/retirement-plan true you/ira-contributions $7,000
         spouse/birth-date 1985-01-01 spouse/ira-contributions $7,000)
  (member w2s acme (given wages $240,000 medicare-wages $240,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs people)
  (expect f1040s1-ira/line7a $0                      ; past $146,000
          f1040s1-ira/line7b $4,200                  ; 70% × ($246,000 − $240,000)
          f1040s1/line20 $4,200))

(test "married filing separately, covered through a spouse you lived with"
  (given married true files-separately true you/birth-date 1990-05-01
         you/ira-contributions $7,000 spouse/retirement-plan true)
  (member w2s acme (given wages $6,000 medicare-wages $6,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs people)
  (expect f1040s1-ira/line1a true
          f1040s1/line20 $2,800)                     ; 70% × ($10,000 − $6,000)
  (given lived-apart-all-year true)
  (expect f1040s1-ira/line1a false
          f1040s1/line20 $6,000))                    ; all of the earned income

(test "a joint return's two IRAs can't take more than the couple's earned income"
  (given married true
         you/birth-date 1990-05-01 you/ira-contributions $7,000
         spouse/birth-date 1990-05-01 spouse/ira-contributions $7,000)
  (member w2s acme (given wages $10,000 medicare-wages $10,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs people)
  (expect f1040s1-ira/line12a $7,000
          f1040s1-ira/line12b $3,000
          f1040s1/line20 $10,000))
