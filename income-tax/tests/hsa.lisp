; HSAs: Form 8889.

(test "without HDHP coverage, the HSA deduction asks nothing"
  (given filing-status 'single you/hsa-contributions $1,000)
  (expect you/f8889/line3 $0
          f1040s1/line13 $0))

(test "self-only coverage: up to $4,300, less what the employer put in"
  (given filing-status 'single you/birth-date 1990-05-01
         you/hdhp 'self-only you/hsa-contributions $3,000 you/hsa-employer $2,000)
  (member w2s acme (given wages $50,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-gs f1099-rs f1098-es ssa1099s dependents)
  (expect you/f8889/line3 $4,300
          you/f8889/line12 $2,300
          f1040s1/line13 $2,300
          f1040/line11a $47,700)
  (given you/hsa-contributions $1,000)
  (expect f1040s1/line13 $1,000))

(test "family coverage, and $1,000 more from age 55"
  (given filing-status 'head-of-household you/birth-date 1968-04-01
         you/hdhp 'family you/hsa-contributions $10,000)
  (expect you/f8889/line3 $9,550                     ; $8,550 + $1,000
          f1040s1/line13 $9,550))

(test "eligible for part of the year: the limit for each month"
  (given filing-status 'single you/birth-date 1990-05-01
         you/hdhp 'self-only you/hsa-months 6 you/hsa-contributions $4,300)
  (expect you/f8889/line3 $2,150                     ; 6/12 × $4,300
          f1040s1/line13 $2,150)
  ; Eligible on December 1, the last-month rule counts the whole year.
  (given you/hsa-months 12)
  (expect f1040s1/line13 $4,300))

(test "spouses with family coverage share its limit, but not the $1,000 from 55"
  (given filing-status 'married-joint
         you/birth-date 1968-04-01 you/hdhp 'family you/hsa-contributions $5,000
         spouse/birth-date 1985-01-01 spouse/hdhp 'self-only spouse/hsa-contributions $4,000)
  ; The spouse's self-only plan counts as family coverage too.
  (expect spouse/f8889/line3 $8,550
          you/f8889/line7 $1,000
          you/f8889/line6 $4,000                     ; what $5,000 needs past line 7
          spouse/f8889/line6 $4,000
          f1040s1/line13 $9,000)
  ; Needing $10,000 of $8,550, each gets a proportional part.
  (given spouse/hsa-contributions $6,000)
  (expect you/f8889/line6 $3,420                     ; 40% of $8,550
          spouse/f8889/line6 $5,130                  ; 60%
          f1040s1/line13 $9,550))

(test "married filing separately with family coverage takes half its limit"
  (given filing-status 'married-separate you/birth-date 1990-05-01
         you/hdhp 'family you/hsa-contributions $8,000)
  (expect you/f8889/line6 $4,275
          f1040s1/line13 $4,275))

(test "distributions not spent on medical care are taxable, and 20% more"
  (given filing-status 'single you/birth-date 1990-05-01
         you/hsa-distributions $3,000 you/hsa-medical $2,000)
  (member w2s acme (given wages $40,000 withheld $4,000))
  (empty f1099-ints f1099-divs f1099-gs f1099-rs f1098-es ssa1099s dependents)
  (expect you/f8889/line16 $1,000
          f1040s1/line8f $1,000
          f1040/line11a $41,000
          ; row middle $25,275: $1,192.50 + 12% × ($25,275 − $11,925)
          f1040/line16 $2,795
          f1040s2/line17c $200
          f1040/line24 $2,995
          f1040/line34 $1,005)
  (given you/hsa-exception true)
  (expect f1040s2/line17c $0 f1040/line24 $2,795)
  (given you/hsa-rolled-over $500)
  (expect f1040s1/line8f $500))

(test "the HSA deduction lowers the income the IRA phaseout looks at"
  (given filing-status 'single you/birth-date 1990-05-01
         you/retirement-plan true you/ira-contributions $7,000
         you/hdhp 'self-only you/hsa-contributions $4,300)
  (member w2s acme (given wages $85,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-gs f1099-rs f1098-es ssa1099s dependents)
  (expect f1040s1-ira/line5 $80,700
          f1040s1/line20 $5,810                      ; 70% × ($89,000 − $80,700)
          f1040/line11a $74,890))
