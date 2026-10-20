; Form 8880 (2025), Credit for Qualified Retirement Savings Contributions:
; the saver's credit, with a column for you and one for your spouse on a
; joint return. IRC §25B.

; Each column: the person's own IRA contributions and elective deferrals,
; less distributions, which on a joint return are both spouses' in both
; columns.
(def line1a :label "Your IRA contributions" (+ you/ira-contributions you/roth-contributions))
(def line1b :label "Your spouse's IRA contributions"
  (if joint (+ spouse/ira-contributions spouse/roth-contributions) $0))
(def line2a :label "Your elective deferrals" (sum w2s (if spouses $0 deferrals)))
(def line2b :label "Your spouse's elective deferrals" (if joint (sum w2s (if spouses deferrals $0)) $0))
(def line3a (+ line1a line2a))
(def line3b (+ line1b line2b))
(def line4 :label "Distributions"
  (+ you/retirement-distributions (if joint spouse/retirement-distributions $0)))
(def line5a (excess line3a line4))
(def line5b (excess line3b line4))
(def line6a (if (and (> line5a $0) you/saver-eligible) (min line5a law/savers-limit) $0))
(def line6b (if (and (> line5b $0) spouse/saver-eligible) (min line5b law/savers-limit) $0))
(def line7 (+ line6a line6b))
(def line8 :label "Adjusted gross income" f1040/line11a)
(def line9 :label "Decimal amount" :cite "IRC §25B(b)"
  (cond ((<= line8 (nth law/savers-tops 0)) (nth law/savers-rates 0))
        ((<= line8 (nth law/savers-tops 1)) (nth law/savers-rates 1))
        ((<= line8 (nth law/savers-tops 2)) (nth law/savers-rates 2))
        (else 0%)))
(def line10 (* line7 line9))
; Credit Limit Worksheet: the tax, less the credits for child care and
; education.
(def line11 :label "Tax liability limit"
  (excess f1040/line18 (+ f1040s3/line2 f1040s3/line3)))         ; − Schedule 3 lines 1 6d 6l
(def line12 :label "Retirement savings contributions credit"
  (if (= line7 $0) $0 (min line10 line11)))
