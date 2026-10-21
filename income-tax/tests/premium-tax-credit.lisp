; The premium tax credit: Form 8962.

(test "the credit is the benchmark plan less the contribution, net of advance payments"
  (given you/birth-date 1990-05-01 marketplace true)
  (member w2s acme (given wages $30,000 medicare-wages $30,000 withheld $0))
  (member f1095-as plan (given premiums $6,000 slcsp $7,200 advance $3,000))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs people)
  (expect f8962/line4 $15,060
          f8962/line5 199                            ; $30,000 ÷ $15,060
          f8962/line7 0.0196                         ; Table 2 for 199
          f8962/line8a $588
          f8962/line11d $6,612
          f8962/line24 $6,000                        ; no more than the premiums
          f8962/line26 $3,000
          f1040s3/line9 $3,000
          f1040/line31 $3,000))

(test "excess advance payments are repaid, up to Table 5's limit"
  (given you/birth-date 1990-05-01 marketplace true)
  (member w2s acme (given wages $45,000 medicare-wages $45,000 withheld $0))
  (member f1095-as plan (given premiums $6,000 slcsp $6,000 advance $5,000))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs people)
  (expect f8962/line5 298
          f8962/line7 0.0592
          f8962/line24 $3,336                        ; $6,000 − $2,664
          f8962/line27 $1,664
          f8962/line29 $975                          ; single, 200% to 300%
          f1040s2/line1a $975
          f1040/line17 $975))

(test "from 400% of the poverty line, 8.5% of income, and all of the excess repaid"
  (given you/birth-date 1990-05-01 marketplace true)
  (member w2s acme (given wages $70,000 medicare-wages $70,000 withheld $0))
  (member f1095-as plan (given premiums $9,000 slcsp $9,000 advance $5,000))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs people)
  (expect f8962/line5 401
          f8962/line7 0.085
          f8962/line24 $3,050                        ; $9,000 − $5,950
          f8962/line29 $1,950))

(test "the applicable figure follows Table 2 between its points"
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs people)
  (member w2s a (given wages $45,400 medicare-wages $45,400 withheld $0))
  (expect f8962/line5 301 f8962/line7 0.0603)
  (member w2s b (given wages $7,500 medicare-wages $7,500 withheld $0))
  (expect f8962/line5 351 f8962/line7 0.0728))

(test "the poverty line grows with the family, and is higher in Alaska"
  (given married true you/birth-date 1990-01-01)
  (member w2s acme (given wages $60,000 medicare-wages $60,000 withheld $0))
  (member people a (given birth-date 2019-01-01 relationship 'child tin 'ssn))
  (member people b (given birth-date 2021-01-01 relationship 'child tin 'ssn))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs)
  (expect f8962/line1 4
          f8962/line4 $31,200
          f8962/line5 192
          f8962/line7 0.0168)
  (given residence 'alaska)
  (expect f8962/line4 $39,000
          f8962/line5 153
          f8962/line7 0.0012))

(test "household income adds back tax-exempt interest and untaxed social security"
  (given you/birth-date 1990-05-01)
  (member w2s acme (given wages $20,000 medicare-wages $20,000 withheld $0))
  (member f1099-ints muni (given interest $0 tax-exempt-interest $2,000))
  (member ssa1099s you (given net-benefits $10,000))
  (empty f1099-divs f1099-bs f1099-gs f1099-rs f1098-es f1040scs people)
  (expect f1040/line6b $1,000
          f1040/line11a $21,000
          f8962/line2a $32,000))                     ; + $2,000 + $9,000

(test "part of the year: the monthly contribution for each month covered"
  (given you/birth-date 1990-05-01 marketplace true
         marketplace-months 6)
  (member w2s acme (given wages $30,000 medicare-wages $30,000 withheld $0))
  (member f1095-as plan (given premiums $3,000 slcsp $3,200 advance $1,500))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs people)
  (expect f8962/line8b $49
          f8962/line11c $294                         ; 6 × $49
          f8962/line24 $2,906
          f8962/line26 $1,406))

(test "married filing separately repays it all, up to the limit, without the exception"
  (given married true files-separately true you/birth-date 1990-05-01 marketplace true)
  (member w2s acme (given wages $30,000 medicare-wages $30,000 withheld $0))
  (member f1095-as plan (given premiums $6,000 slcsp $7,200 advance $3,000))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs people)
  (expect f8962/line24 $0
          f8962/line29 $750)                         ; not single, under 200%
  (given ptc-separate-exception true)
  (expect f8962/line24 $6,000
          f8962/line26 $3,000))
