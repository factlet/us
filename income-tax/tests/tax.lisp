(test "joint filers taxed by the Tax Computation Worksheet"
  (given filing-status 'married-joint)
  (member w2s acme (given wages $131,500))
  ; $2,385 + 12% × $73,100 + 22% × ($100,000 − $96,950)
  (expect f1040/line15 $100,000
          f1040/line16 $11,828))
