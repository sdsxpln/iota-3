
;;(begin 1 2 3)
;;(define (map f l)
;;  (define (mapper l)
;;    (if (null? l) '()
;;      (cons (f (car l)) (mapper (cdr l)))))
;;  (mapper l))

;;(define (macroexpand form)
;;  `,(macroexpand-f `,form)

(define cond
  (macro (:rest clauses) (expand-clauses clauses)))

(define rester
  (macro (:rest clauses) `,clauses))

(define rester2
  (macro (clauses) `,clauses))

(define (rester3 :rest clauses) clauses)

(define (make-if predicate consequent alternative)
  (list 'if predicate consequent alternative))
(define (cond? exp) (tagged-list? exp 'cond))
(define (cond-clauses exp) (cdr exp))
(define (cond-predicate clause) (car clause))
(define (cond-else-clause? clause)
  (eq? (cond-predicate clause) 'else))
(define (cond-actions clause) (cdr clause))
(define (cond->if exp) (expand-clauses (cond-clauses exp)))
(define (expand-clauses clauses)
  (if (null? clauses) #f
      (let ((first (car clauses))
	    (rest (cdr clauses)))
	(if (cond-else-clause? first)
	    (if (null? rest) (sequence->exp (cond-actions first)) 'error)
	    (make-if (cond-predicate first)
		     (sequence->exp (cond-actions first))
		     (expand-clauses rest))))))
(define (expand-clauses clauses)
  (if (null? clauses)
      'false                          
      (let ((first (car clauses))
            (rest (cdr clauses)))
        (if (cond-else-clause? first)
            (if (null? rest)
                (sequence->exp (cond-actions first))
                (error "ELSE clause isn't last -- COND->IF"
                       clauses))
            (make-if (cond-predicate first)
                     (sequence->exp (cond-actions first))
                     (expand-clauses rest))))))
(define (cond? exp) (tagged-list? exp 'cond))
(define (cond-clauses exp) (cdr exp))
(define (cond-else-clause? clause)
  (eq? (cond-predicate clause) 'else))
(define (cond-predicate clause) (car clause))
(define (cond-actions clause) (cdr clause))
(define (cond->if exp)
  (expand-clauses (cond-clauses exp)))
(define expand-clauses
  (macro (clauses)
    (if (null? clauses)
	#f                          
	(let ((first (car clauses))
	      (rest (cdr clauses)))
	  (if (cond-else-clause? first)
	      (if (null? rest)
		  (sequence->exp (cond-actions first))
		  (error "ELSE clause isn't last -- COND->IF"
			 clauses))
	      (make-if (cond-predicate first)
		       (sequence->exp (cond-actions first))
		       (expand-clauses rest)))))))
(define cond
  (macro (:rest clauses)
    (expand-clauses clauses)))

(define cond
  (macro (:rest clauses)
    (if (null? clauses) #f
	(let ((clause (car clauses))
	      (other-clauses (cdr clauses)))
	  (if (null? other-clauses)
	      `'hey
	      `(if ,@clause (cond ,@other-clauses)))))))
(define (cond-fn clauses)
  (let ((clause (car clauses))
	(other-clauses (cdr clauses)))
    (if (null? other-clauses)
	`(if ,@clause)
	`(if ,@clause ,`(cond ,@other-clauses)))))

(define cond
  (macro (:rest x)
    (cond-fn x)))

(define cond
  (macro (:rest clauses)
    `(conder ,clauses)))
(define conder
  (macro (clauses)
    (let ((clause (car clauses))
	  (others (cdr clauses)))
      (if (null? others)
	  (list 'if (car clause) (cadr clause))
	  (list 'if
		(car clause)
		(cadr clause)
		(conder others))))))

(define cond
  (macro (:rest cond-pairs)
    (if (null? cond-pairs)
	nil
	`(if ,(car (car cond-pairs))
	     (begin ,@(cdr (car cond-pairs)))
	     (cond ,@(cdr cond-pairs))))))

(define cond
  (macro (:rest cond-pairs)
    (if (null? cond-pairs)
	'()
	(if (null? (cdr cond-pairs)
		   `(if ,(car (car cond-pairs))
			,(car (cdr (car cond-pairs))))
		   `(if ,(car (car cond-pairs))
			,(car (cdr (car cond-pairs)))
			(cond ,@(cdr cond-pairs))))))))
(define thing
  (macro (:rest x)
    `(car (car ,x))))
	
(define (make-begin seq)
  (cons 'begin seq))

(define (sequence->exp seq)
  (if (null? seq) seq
      (if (null? (cdr seq)) (car seq)
	  (make-begin seq))))
(define (make-if predicate consequent alternative)
  (list 'if predicate consequent alternative))

(defmacro apply
  (fn args)
  `(,fn ,@(cadr args)))
(defmacro eval
  (form)
  (cadr form))

((nil? ,'(cdr args)) ,(car args))
`((set! *stdout* ,stream)
	  ,@body
	  (set! *stdout* *stdout-std*)))
  
(define let
  (macro (assignments :rest body)
    `((lambda ,(map car assignments)
	,@body)
      ,@(map cadr assignments))))
(define (make-table-x)
  (let ((table (list '*table*)))
    (define (assoc key rec)
      (cond ((nil? rec) rec)
	    ((eq? key (caar rec)) (car rec))
	    (else (assoc key (cdr rec)))))
    (define (lookup key1 key2)
      (let ((subtable (assoc key1 (cdr table))))
	(if subtable
	    (assoc key2 (cdr subtable))
	  nil)))
    (define (insert key1 key2 value)
      (set-cdr! (lookup key1 key2) value))
    (define (dispatch m)
      (cond ((eq? m :lookup) lookup)
	    ((eq? m :insert) insert)
	    ((eq? m :inspect) (lambda () table))))
    dispatch))



(defmacro defn
  (fn-name fn-args :rest fn-body)
  (with-gensyms (fn-name fn-args fn-body)
		`(define (,fn-name ,@fn-args)
		   ,@fn-body)))


(cond ((null? l) nil)
	((atom? l) (eq? l item))
	(else (or (contains? (car l) item)
		  (contains? (cdr l) item))))
(define (replace from to l)
  (cond ((null? l) nil)
	((atom? l) (if (eq? l from) to l))
	(else (cons (replace from to (car l))
		    (replace from to (cdr l))))))

(define with-gensyms
  (macro (symbols->gensyms :rest body)
    (let ((bindings (map (lambda (sym) (list (gensym) ,sym)) symbols->gensyms)))
      (let ((sgnidnib (map snoc bindings)))
	`(let ,bindings
	   ,@(replace-many `,sgnidnib `,body))))))

(with-gensyms
 (macro-name macro-args macro-body)
 (define defmacro
   (macro (macro-name macro-args :rest macro-body)
     `(define ,macro-name (macro ,macro-args ,@macro-body)))))

(with-gensyms
 (fn-name fn-args fn-body)
 (define defn
   (macro (fn-name fn-args :rest fn-body)
     `(define (,fn-name ,@fn-args)
	,@fn-body))))

(with-gensyms
 (macro-name macro-args macro-body)
 (define defmacro
   (macro (macro-name macro-args :rest macro-body)
     `(define ,macro-name (macro ,macro-args ,@macro-body)))))
(define defmacro
  (let ((macro-name (gensym))
	(macro-args (gensym))
	(macro-body (gensym)))
    (macro (|macro-name |macro-args :rest |macro-body)
      `(define ,|macro-name
	 (macro ,|macro-args ,@|macro-body)))))

(define defmacro
  (let ((macro-name (gensym))
	(macro-args (gensym))
	(macro-body (gensym)))
    (macro (|macro-name |macro-args :rest |macro-body)
      `(define ,|macro-name
	 (macro ,|macro-args ,@|macro-body)))))

(define defn
  (macro (fn-name fn-args :rest fn-body)
    `(let ((fn (define (,fn-name ,@fn-args)
		 ,@fn-body)))
	   (eval '(define ,fn-name fn) (global-env)))))

(define defn
  (macro (fn-name fn-args :rest fn-body)
    `(let ((fn (lambda ,fn-args ,@fn-body)))
       (eval `(define ,,fn-name ',fn) (global-env)))))
