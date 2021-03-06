;;; thrax-mode.el --- Thrax grammar file mode  -*- lexical-binding: t; coding: utf-8 -*-

;; Copyright (C)  2011-2017 Google, Inc.
;;

;; Author: Richard Sproat <rws@google.com>
;; Version: 0.5
;; Package-Requires: ((emacs "24.3"))
;; Keywords: faces, languages
;; Homepage: http://thrax.opengrm.org/

;; Licensed under the Apache License, Version 2.0 (the "License");
;; you may not use this file except in compliance with the License.
;; You may obtain a copy of the License at
;;
;;     http://www.apache.org/licenses/LICENSE-2.0
;;
;; Unless required by applicable law or agreed to in writing, software
;; distributed under the License is distributed on an "AS IS" BASIS,
;; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;; See the License for the specific language governing permissions and
;; limitations under the License.
;;
;;; Commentary:
					;
;; Definition of Thrax mode for Emacs.
;; Assuming you have installed this in /usr/local/share/thrax/utils then put the
;; following line in your .emacs:
;;
;; (load "/usr/local/share/thrax/utils/thrax-mode.el")

;;; Code:


(defvar thrax-keywords
  (regexp-opt '("as" "import") 'words)
  "Variable containing the regexp defining import keywords in thrax")

(defvar thrax-parse-keywords
  (regexp-opt '("byte" "utf8") 'words)
  "Variable containing the regexp defining parse keywords in thrax")

(defvar thrax-included-keywords
  (regexp-opt '("export" "func" "contained") 'words)
  "Variable containing the regexp matching the built in functions of thrax")

(defvar thrax-built-in-functions
  (regexp-opt
   '("ArcSort" "CDRewrite" "Closure" "Compose" "Concat" "Determinize"
     "Difference" "Expand" "Invert" "LoadFst" "LoadFstFromFar" "Minimize"
     "Optimize" "Project" "Reverse" "Rewrite" "RmEpsilon" "StringFile" "StringFst"
     "SymbolTable" "Union")
   'words)
  "Variable containing the regexp matching the built in functions of thrax")

(defvar thrax-syntax "[\]\[=@:|*+\?\"(),;{}-]"
  "Variable containing the regexp defining the available operators in thrax")

(defvar thrax-single-quoted-string "'[^']*'"
  "Variable containing the regexp defining the single quoted string")

(defvar thrax-weight "<[^<>]*>"
  "Variable containing the regexp defining the weight")

(defvar thrax-range "[0-9]+,[0-9]+"
  "Variable containing the regexp defining a range in thrax")

(defvar thrax-defined-fst "\\([^ \n]+\\)[ \n]*="
  "Every string not including spaces that is followed by optional spaces and an equals sign is a user-defined fst")

(defvar thrax-font-lock-keywords nil
  "The thrax font lock keywords. This variable is redefined by thrax-refont")

(defun thrax-refont ()
  "Refonting buffer routine"
  (interactive)

  ;; Always defined part
  (setq thrax-font-lock-keywords
	`((,thrax-defined-fst          . 1)  ;; Assign  \1 match to font-lock-keyword-face
	  (,thrax-weight               . 'font-lock-constant-face)
	  (,thrax-single-quoted-string . 'font-lock-doc-face)
	  (,thrax-range                . 'red)
	  (,thrax-syntax               . 'font-lock-keyword-face)))

  ;; Optionnal fontify part
  (dolist (exp `(,thrax-keywords ,thrax-parse-keywords ,thrax-included-keywords ,thrax-built-in-functions))
    (when exp
	(add-to-list
	 'thrax-font-lock-keywords
	 `(,exp                 . 'font-lock-keyword-face))))


  ;; Update font-lock-defaults variable
  (setq font-lock-keywords thrax-font-lock-keywords)
  (font-lock-add-keywords nil '(("^#.+" . font-lock-comment-face)))

  ;; Refontify the buffer
  (font-lock-fontify-buffer t))

(defun thrax-comment-dwim (arg)
  "Helper to dwim comment in thrax. ARG correspond to the region to comment"
  (interactive "*P")
  (require 'newcomment)
  (let ((deactivate-mark nil) (comment-start "#") (comment-end ""))
    (comment-dwim arg)))

(define-derived-mode thrax-mode fundamental-mode
  "Thrax mode"
  "Major mode for editing OpenGrm Thrax grammars"

  (define-key thrax-mode-map [remap comment-dwim] 'thrax-comment-dwim)
  (modify-syntax-entry ?# "< b" thrax-mode-syntax-table)
  (modify-syntax-entry ?\n "> b" thrax-mode-syntax-table)

  ;; -- Default font locking
  (setq thrax-font-lock-keywords
	`((,thrax-defined-fst          . 1)  ;; Assign  \1 match to font-lock-keyword-face
	  (,thrax-weight               . 'font-lock-constant-face)
	  (,thrax-single-quoted-string . 'font-lock-doc-face)
	  (,thrax-range                . 'red)
	  (,thrax-syntax               . 'font-lock-keyword-face)))

  ;; -- Default deactivation
  (setq thrax-keywords nil)
  (setq thrax-parse-keywords nil)
  (setq thrax-included-keywords nil)
  (setq thrax-built-in-keywords nil)

  ;; -- Comment part
  (setq-local comment-start "#")
  (setq-local comment-end "")

  ;; -- now fontify
  (setq font-lock-defaults '(thrax-font-lock-keywords))
  (font-lock-add-keywords nil '(("^#.+" . font-lock-comment-face)))
  )

(add-to-list 'auto-mode-alist '("\\.grm\\'" . thrax-mode))

(provide 'thrax-mode)
;;; thrax-mode.el ends here
