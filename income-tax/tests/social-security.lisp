; Social security benefits: the Social Security Benefits Worksheet.

(test "none are taxable until half of them plus other income passes $25,000"
  (given filing-status 'single you/birth-date 1955-06-01 you/tin 'ssn)
  (member ssa1099s you (given net-benefits $24,000))
  (member f1099-ints bank (given interest $10,000))
  (empty w2s f1099-divs f1099-gs f1099-rs f1098-es dependents)
  (expect f1040-ssb/line5 $22,000                    ; $12,000 + $10,000
          f1040/line6a $24,000
          f1040/line6b $0
          f1040/line11a $10,000)
  (member f1099-ints cd (given interest $4,000))
  ; Half of the $1,000 over $25,000.
  (expect f1040-ssb/line9 $1,000
          f1040/line6b $500
          f1040/line11a $14,500
          f1040/line15 $0))                          ; $17,750 + $6,000 for a senior

(test "85% of what's over $34,000, but no more than 85% of the benefits"
  (given filing-status 'single you/birth-date 1955-06-01 you/tin 'ssn)
  (member ssa1099s you (given net-benefits $30,000 withheld $3,000))
  (member w2s acme (given wages $50,000 withheld $2,000))
  (empty f1099-ints f1099-divs f1099-gs f1099-rs f1098-es dependents)
  (expect f1040-ssb/line9 $40,000                    ; $15,000 + $50,000 − $25,000
          f1040-ssb/line14 $4,500                    ; half of $9,000
          f1040-ssb/line15 $26,350                   ; 85% × $31,000
          f1040-ssb/line16 $30,850
          f1040/line6b $25,500                       ; 85% × $30,000
          f1040/line11a $75,500
          f1040s1a/line35 $5,970                     ; $6,000 − 6% × $500
          f1040/line15 $51,780                       ; − $17,750 − $5,970
          ; row middle $51,775: $5,578.50 + 22% × ($51,775 − $48,475)
          f1040/line16 $6,305
          f1040/line25b $3,000
          f1040/line37 $1,305))

(test "on a joint return, from $32,000 and $44,000"
  (given filing-status 'married-joint
         you/birth-date 1955-06-01 you/tin 'ssn
         spouse/birth-date 1957-02-01 spouse/tin 'ssn)
  (member ssa1099s you (given net-benefits $18,000))
  (member ssa1099s spouse (given net-benefits $12,000))
  (member f1099-ints bank (given interest $30,000))
  (empty w2s f1099-divs f1099-gs f1099-rs f1098-es dependents)
  (expect f1040-ssb/line9 $13,000                    ; $15,000 + $30,000 − $32,000
          f1040-ssb/line11 $1,000
          f1040-ssb/line14 $6,000                    ; half of $12,000
          f1040-ssb/line15 $850
          f1040/line6b $6,850
          f1040/line11a $36,850))

(test "married filing separately, living together, 85% from the first dollar"
  (given filing-status 'married-separate you/birth-date 1990-01-01)
  (member ssa1099s you (given net-benefits $10,000))
  (member f1099-ints bank (given interest $2,000))
  (empty w2s f1099-divs f1099-gs f1099-rs f1098-es dependents)
  (expect f1040-ssb/line8 $0
          f1040/line6b $5,950)                       ; 85% × ($5,000 + $2,000)
  (given lived-apart-all-year true)
  (expect f1040-ssb/line8 $25,000
          f1040/line6b $0))

(test "tax-exempt interest counts toward the base amount, though it isn't taxed"
  (given filing-status 'single you/birth-date 1955-06-01 you/tin 'ssn)
  (member ssa1099s you (given net-benefits $20,000))
  (member f1099-ints muni (given interest $0 tax-exempt-interest $16,000))
  (empty w2s f1099-divs f1099-gs f1099-rs f1098-es dependents)
  (expect f1040-ssb/line5 $26,000                    ; $10,000 + $16,000
          f1040/line6b $500
          f1040/line11a $500))

(test "repayments over the year's benefits leave none taxable"
  (given filing-status 'single you/birth-date 1955-06-01 you/tin 'ssn)
  (member ssa1099s you (given net-benefits -$500))
  (member w2s acme (given wages $40,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-gs f1099-rs f1098-es dependents)
  (expect f1040/line6a -$500
          f1040/line6b $0
          f1040/line9 $40,000))

(test "covered by a plan at work, the IRA deduction sees the benefits taxable before it"
  ; Pub. 590-A, Appendix B: Worksheet 1 figures the benefits taxable
  ; without the deduction, Worksheet 2 the deduction, and Worksheet 3 the
  ; benefits taxable after it.
  (given filing-status 'single you/birth-date 1962-03-01 you/tin 'ssn
         you/retirement-plan true you/ira-contributions $8,000)
  (member w2s acme (given wages $48,000 withheld $0))
  (member ssa1099s you (given net-benefits $46,000))
  (empty f1099-ints f1099-divs f1099-gs f1099-rs f1098-es dependents)
  ; $4,500 + 85% × ($23,000 + $48,000 − $34,000)
  (expect p590a-ssb/line18 $35,950
          f1040s1-ira/line5 $83,950
          f1040s1/line20 $4,040                      ; 80% × ($89,000 − $83,950)
          ; $4,500 + 85% × ($23,000 + $48,000 − $4,040 − $34,000)
          f1040/line6b $32,516
          f1040/line11a $76,476))
