; One filer, included as `you` and as `spouse`.

(input birth-date : date :label "Date of birth")
(input blind : bool :default false :label "Blind at the end of the year" :line 12d)
(input tin : tin :label "Identification number issued by the return's due date")

; Issued to a citizen or someone authorized to work, which is what the child
; tax credit and the senior deduction both mean by an SSN.
(def valid-ssn :label "Has a valid SSN" :cite "IRC §24(h)(7)(B)" (= tin 'ssn))

; 65 by the end of the year. A person turns 65 the day before their 65th
; birthday, so for 2025 that's anyone born before 1961-01-02 (line 12d).
(def aged :label "65 or older" :cite "IRC §63(f)(1)"
  (>= (age-on birth-date law/day-after-year-end) 65))

(def boxes :label "Line 12d boxes checked" (+ (if aged 1 0) (if blind 1 0)))
