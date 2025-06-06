;;; org-export.el --- Generic Export Engine For Org

;; Copyright (C) 2012, 2013  Free Software Foundation, Inc.

;; Author: Nicolas Goaziou <n.goaziou at gmail dot com>
;; Keywords: outlines, hypermedia, calendar, wp

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; This library implements a generic export engine for Org, built on
;; its syntactical parser: Org Elements.
;;
;; Besides that parser, the generic exporter is made of three distinct
;; parts:
;;
;; - The communication channel consists in a property list, which is
;;   created and updated during the process.  Its use is to offer
;;   every piece of information, would it be about initial environment
;;   or contextual data, all in a single place.  The exhaustive list
;;   of properties is given in "The Communication Channel" section of
;;   this file.
;;
;; - The transcoder walks the parse tree, ignores or treat as plain
;;   text elements and objects according to export options, and
;;   eventually calls back-end specific functions to do the real
;;   transcoding, concatenating their return value along the way.
;;
;; - The filter system is activated at the very beginning and the very
;;   end of the export process, and each time an element or an object
;;   has been converted.  It is the entry point to fine-tune standard
;;   output from back-end transcoders.  See "The Filter System"
;;   section for more information.
;;
;; The core function is `org-export-as'.  It returns the transcoded
;; buffer as a string.
;;
;; An export back-end is defined with `org-export-define-backend',
;; which sets one mandatory variable: his translation table.  Its name
;; is always `org-BACKEND-translate-alist' where BACKEND stands for
;; the name chosen for the back-end.  Its value is an alist whose keys
;; are elements and objects types and values translator functions.
;; See function's docstring for more information about translators.
;;
;; Optionally, `org-export-define-backend' can also support specific
;; buffer keywords, OPTION keyword's items and filters.  Also refer to
;; function documentation for more information.
;;
;; If the new back-end shares most properties with another one,
;; `org-export-define-derived-backend' can be used to simplify the
;; process.
;;
;; Any back-end can define its own variables.  Among them, those
;; customizable should belong to the `org-export-BACKEND' group.
;;
;; Tools for common tasks across back-ends are implemented in the
;; penultimate part of this file.  A dispatcher for standard back-ends
;; is provided in the last one.

;;; Code:

(eval-when-compile (require 'cl))
(require 'org-element)


(declare-function org-e-ascii-export-as-ascii "org-e-ascii"
		  (&optional subtreep visible-only body-only ext-plist))
(declare-function org-e-ascii-export-to-ascii "org-e-ascii"
		  (&optional subtreep visible-only body-only ext-plist pub-dir))
(declare-function org-e-html-export-as-html "org-e-html"
		  (&optional subtreep visible-only body-only ext-plist))
(declare-function org-e-html-export-to-html "org-e-html"
		  (&optional subtreep visible-only body-only ext-plist pub-dir))
(declare-function org-e-latex-export-as-latex "org-e-latex"
		  (&optional subtreep visible-only body-only ext-plist))
(declare-function org-e-latex-export-to-latex "org-e-latex"
		  (&optional subtreep visible-only body-only ext-plist pub-dir))
(declare-function org-e-latex-export-to-pdf "org-e-latex"
		  (&optional subtreep visible-only body-only ext-plist pub-dir))
(declare-function org-e-odt-export-to-odt "org-e-odt"
		  (&optional subtreep visible-only body-only ext-plist pub-dir))
(declare-function org-e-publish "org-e-publish" (project &optional force))
(declare-function org-e-publish-all "org-e-publish" (&optional force))
(declare-function org-e-publish-current-file "org-e-publish" (&optional force))
(declare-function org-e-publish-current-project "org-e-publish"
		  (&optional force))
(declare-function org-export-blocks-preprocess "org-exp-blocks")

(defvar org-e-publish-project-alist)
(defvar org-table-number-fraction)
(defvar org-table-number-regexp)



;;; Internal Variables
;;
;; Among internal variables, the most important is
;; `org-export-options-alist'.  This variable define the global export
;; options, shared between every exporter, and how they are acquired.

(defconst org-export-max-depth 19
  "Maximum nesting depth for headlines, counting from 0.")

(defconst org-export-options-alist
  '((:author "AUTHOR" nil user-full-name t)
    (:creator "CREATOR" nil org-export-creator-string)
    (:date "DATE" nil nil t)
    (:description "DESCRIPTION" nil nil newline)
    (:email "EMAIL" nil user-mail-address t)
    (:exclude-tags "EXCLUDE_TAGS" nil org-export-exclude-tags split)
    (:headline-levels nil "H" org-export-headline-levels)
    (:keywords "KEYWORDS" nil nil space)
    (:language "LANGUAGE" nil org-export-default-language t)
    (:preserve-breaks nil "\\n" org-export-preserve-breaks)
    (:section-numbers nil "num" org-export-with-section-numbers)
    (:select-tags "SELECT_TAGS" nil org-export-select-tags split)
    (:time-stamp-file nil "timestamp" org-export-time-stamp-file)
    (:title "TITLE" nil nil space)
    (:with-archived-trees nil "arch" org-export-with-archived-trees)
    (:with-author nil "author" org-export-with-author)
    (:with-clocks nil "c" org-export-with-clocks)
    (:with-creator nil "creator" org-export-with-creator)
    (:with-drawers nil "d" org-export-with-drawers)
    (:with-email nil "email" org-export-with-email)
    (:with-emphasize nil "*" org-export-with-emphasize)
    (:with-entities nil "e" org-export-with-entities)
    (:with-fixed-width nil ":" org-export-with-fixed-width)
    (:with-footnotes nil "f" org-export-with-footnotes)
    (:with-inlinetasks nil "inline" org-export-with-inlinetasks)
    (:with-plannings nil "p" org-export-with-planning)
    (:with-priority nil "pri" org-export-with-priority)
    (:with-special-strings nil "-" org-export-with-special-strings)
    (:with-sub-superscript nil "^" org-export-with-sub-superscripts)
    (:with-toc nil "toc" org-export-with-toc)
    (:with-tables nil "|" org-export-with-tables)
    (:with-tags nil "tags" org-export-with-tags)
    (:with-tasks nil "tasks" org-export-with-tasks)
    (:with-timestamps nil "<" org-export-with-timestamps)
    (:with-todo-keywords nil "todo" org-export-with-todo-keywords))
  "Alist between export properties and ways to set them.

The CAR of the alist is the property name, and the CDR is a list
like (KEYWORD OPTION DEFAULT BEHAVIOUR) where:

KEYWORD is a string representing a buffer keyword, or nil.  Each
  property defined this way can also be set, during subtree
  export, through an headline property named after the keyword
  with the \"EXPORT_\" prefix (i.e. DATE keyword and EXPORT_DATE
  property).
OPTION is a string that could be found in an #+OPTIONS: line.
DEFAULT is the default value for the property.
BEHAVIOUR determine how Org should handle multiple keywords for
  the same property.  It is a symbol among:
  nil       Keep old value and discard the new one.
  t         Replace old value with the new one.
  `space'   Concatenate the values, separating them with a space.
  `newline' Concatenate the values, separating them with
	    a newline.
  `split'   Split values at white spaces, and cons them to the
	    previous list.

KEYWORD and OPTION have precedence over DEFAULT.

All these properties should be back-end agnostic.  Back-end
specific properties are set through `org-export-define-backend'.
Properties redefined there have precedence over these.")

(defconst org-export-special-keywords
  '("SETUP_FILE" "OPTIONS" "MACRO")
  "List of in-buffer keywords that require special treatment.
These keywords are not directly associated to a property.  The
way they are handled must be hard-coded into
`org-export--get-inbuffer-options' function.")

(defconst org-export-filters-alist
  '((:filter-bold . org-export-filter-bold-functions)
    (:filter-babel-call . org-export-filter-babel-call-functions)
    (:filter-center-block . org-export-filter-center-block-functions)
    (:filter-clock . org-export-filter-clock-functions)
    (:filter-code . org-export-filter-code-functions)
    (:filter-comment . org-export-filter-comment-functions)
    (:filter-comment-block . org-export-filter-comment-block-functions)
    (:filter-drawer . org-export-filter-drawer-functions)
    (:filter-dynamic-block . org-export-filter-dynamic-block-functions)
    (:filter-entity . org-export-filter-entity-functions)
    (:filter-example-block . org-export-filter-example-block-functions)
    (:filter-export-block . org-export-filter-export-block-functions)
    (:filter-export-snippet . org-export-filter-export-snippet-functions)
    (:filter-final-output . org-export-filter-final-output-functions)
    (:filter-fixed-width . org-export-filter-fixed-width-functions)
    (:filter-footnote-definition . org-export-filter-footnote-definition-functions)
    (:filter-footnote-reference . org-export-filter-footnote-reference-functions)
    (:filter-headline . org-export-filter-headline-functions)
    (:filter-horizontal-rule . org-export-filter-horizontal-rule-functions)
    (:filter-inline-babel-call . org-export-filter-inline-babel-call-functions)
    (:filter-inline-src-block . org-export-filter-inline-src-block-functions)
    (:filter-inlinetask . org-export-filter-inlinetask-functions)
    (:filter-italic . org-export-filter-italic-functions)
    (:filter-item . org-export-filter-item-functions)
    (:filter-keyword . org-export-filter-keyword-functions)
    (:filter-latex-environment . org-export-filter-latex-environment-functions)
    (:filter-latex-fragment . org-export-filter-latex-fragment-functions)
    (:filter-line-break . org-export-filter-line-break-functions)
    (:filter-link . org-export-filter-link-functions)
    (:filter-macro . org-export-filter-macro-functions)
    (:filter-paragraph . org-export-filter-paragraph-functions)
    (:filter-parse-tree . org-export-filter-parse-tree-functions)
    (:filter-plain-list . org-export-filter-plain-list-functions)
    (:filter-plain-text . org-export-filter-plain-text-functions)
    (:filter-planning . org-export-filter-planning-functions)
    (:filter-property-drawer . org-export-filter-property-drawer-functions)
    (:filter-quote-block . org-export-filter-quote-block-functions)
    (:filter-quote-section . org-export-filter-quote-section-functions)
    (:filter-radio-target . org-export-filter-radio-target-functions)
    (:filter-section . org-export-filter-section-functions)
    (:filter-special-block . org-export-filter-special-block-functions)
    (:filter-src-block . org-export-filter-src-block-functions)
    (:filter-statistics-cookie . org-export-filter-statistics-cookie-functions)
    (:filter-strike-through . org-export-filter-strike-through-functions)
    (:filter-subscript . org-export-filter-subscript-functions)
    (:filter-superscript . org-export-filter-superscript-functions)
    (:filter-table . org-export-filter-table-functions)
    (:filter-table-cell . org-export-filter-table-cell-functions)
    (:filter-table-row . org-export-filter-table-row-functions)
    (:filter-target . org-export-filter-target-functions)
    (:filter-timestamp . org-export-filter-timestamp-functions)
    (:filter-underline . org-export-filter-underline-functions)
    (:filter-verbatim . org-export-filter-verbatim-functions)
    (:filter-verse-block . org-export-filter-verse-block-functions))
  "Alist between filters properties and initial values.

The key of each association is a property name accessible through
the communication channel.  Its value is a configurable global
variable defining initial filters.

This list is meant to install user specified filters.  Back-end
developers may install their own filters using
`org-export-define-backend'.  Filters defined there will always
be prepended to the current list, so they always get applied
first.")

(defconst org-export-default-inline-image-rule
  `(("file" .
     ,(format "\\.%s\\'"
	      (regexp-opt
	       '("png" "jpeg" "jpg" "gif" "tiff" "tif" "xbm"
		 "xpm" "pbm" "pgm" "ppm") t))))
  "Default rule for link matching an inline image.
This rule applies to links with no description.  By default, it
will be considered as an inline image if it targets a local file
whose extension is either \"png\", \"jpeg\", \"jpg\", \"gif\",
\"tiff\", \"tif\", \"xbm\", \"xpm\", \"pbm\", \"pgm\" or \"ppm\".
See `org-export-inline-image-p' for more information about
rules.")



;;; User-configurable Variables
;;
;; Configuration for the masses.
;;
;; They should never be accessed directly, as their value is to be
;; stored in a property list (cf. `org-export-options-alist').
;; Back-ends will read their value from there instead.

(defgroup org-export nil
  "Options for exporting Org mode files."
  :tag "Org Export"
  :group 'org)

(defgroup org-export-general nil
  "General options for export engine."
  :tag "Org Export General"
  :group 'org-export)

(defcustom org-export-with-archived-trees 'headline
  "Whether sub-trees with the ARCHIVE tag should be exported.

This can have three different values:
nil         Do not export, pretend this tree is not present.
t           Do export the entire tree.
`headline'  Only export the headline, but skip the tree below it.

This option can also be set with the #+OPTIONS line,
e.g. \"arch:nil\"."
  :group 'org-export-general
  :type '(choice
	  (const :tag "Not at all" nil)
	  (const :tag "Headline only" 'headline)
	  (const :tag "Entirely" t)))

(defcustom org-export-with-author t
  "Non-nil means insert author name into the exported file.
This option can also be set with the #+OPTIONS line,
e.g. \"author:nil\"."
  :group 'org-export-general
  :type 'boolean)

(defcustom org-export-with-clocks nil
  "Non-nil means export CLOCK keywords.
This option can also be set with the #+OPTIONS line,
e.g. \"c:t\"."
  :group 'org-export-general
  :type 'boolean)

(defcustom org-export-with-creator 'comment
  "Non-nil means the postamble should contain a creator sentence.

The sentence can be set in `org-export-creator-string' and
defaults to \"Generated by Org mode XX in Emacs XXX.\".

If the value is `comment' insert it as a comment."
  :group 'org-export-general
  :type '(choice
	  (const :tag "No creator sentence" nil)
	  (const :tag "Sentence as a comment" 'comment)
	  (const :tag "Insert the sentence" t)))

(defcustom org-export-creator-string
  (format "Generated by Org mode %s in Emacs %s."
	  (if (fboundp 'org-version) (org-version) "(Unknown)")
	  emacs-version)
  "String to insert at the end of the generated document."
  :group 'org-export-general
  :type '(string :tag "Creator string"))

(defcustom org-export-with-drawers t
  "Non-nil means export contents of standard drawers.

When t, all drawers are exported.  This may also be a list of
drawer names to export.  This variable doesn't apply to
properties drawers.

This option can also be set with the #+OPTIONS line,
e.g. \"d:nil\"."
  :group 'org-export-general
  :type '(choice
	  (const :tag "All drawers" t)
	  (const :tag "None" nil)
	  (repeat :tag "Selected drawers"
		  (string :tag "Drawer name"))))

(defcustom org-export-with-email nil
  "Non-nil means insert author email into the exported file.
This option can also be set with the #+OPTIONS line,
e.g. \"email:t\"."
  :group 'org-export-general
  :type 'boolean)

(defcustom org-export-with-emphasize t
  "Non-nil means interpret *word*, /word/, and _word_ as emphasized text.

If the export target supports emphasizing text, the word will be
typeset in bold, italic, or underlined, respectively.  Not all
export backends support this.

This option can also be set with the #+OPTIONS line, e.g. \"*:nil\"."
  :group 'org-export-general
  :type 'boolean)

(defcustom org-export-exclude-tags '("noexport")
  "Tags that exclude a tree from export.

All trees carrying any of these tags will be excluded from
export.  This is without condition, so even subtrees inside that
carry one of the `org-export-select-tags' will be removed.

This option can also be set with the #+EXCLUDE_TAGS: keyword."
  :group 'org-export-general
  :type '(repeat (string :tag "Tag")))

(defcustom org-export-with-fixed-width t
  "Non-nil means lines starting with \":\" will be in fixed width font.

This can be used to have pre-formatted text, fragments of code
etc.  For example:
  : ;; Some Lisp examples
  : (while (defc cnt)
  :   (ding))
will be looking just like this in also HTML.  See also the QUOTE
keyword.  Not all export backends support this.

This option can also be set with the #+OPTIONS line, e.g. \"::nil\"."
  :group 'org-export-translation
  :type 'boolean)

(defcustom org-export-with-footnotes t
  "Non-nil means Org footnotes should be exported.
This option can also be set with the #+OPTIONS line,
e.g. \"f:nil\"."
  :group 'org-export-general
  :type 'boolean)

(defcustom org-export-headline-levels 3
  "The last level which is still exported as a headline.

Inferior levels will produce itemize lists when exported.

This option can also be set with the #+OPTIONS line, e.g. \"H:2\"."
  :group 'org-export-general
  :type 'integer)

(defcustom org-export-default-language "en"
  "The default language for export and clocktable translations, as a string.
This may have an association in
`org-clock-clocktable-language-setup'."
  :group 'org-export-general
  :type '(string :tag "Language"))

(defcustom org-export-preserve-breaks nil
  "Non-nil means preserve all line breaks when exporting.

Normally, in HTML output paragraphs will be reformatted.

This option can also be set with the #+OPTIONS line,
e.g. \"\\n:t\"."
  :group 'org-export-general
  :type 'boolean)

(defcustom org-export-with-entities t
  "Non-nil means interpret entities when exporting.

For example, HTML export converts \\alpha to &alpha; and \\AA to
&Aring;.

For a list of supported names, see the constant `org-entities'
and the user option `org-entities-user'.

This option can also be set with the #+OPTIONS line,
e.g. \"e:nil\"."
  :group 'org-export-general
  :type 'boolean)

(defcustom org-export-with-inlinetasks t
  "Non-nil means inlinetasks should be exported.
This option can also be set with the #+OPTIONS line,
e.g. \"inline:nil\"."
  :group 'org-export-general
  :type 'boolean)

(defcustom org-export-with-planning nil
  "Non-nil means include planning info in export.
This option can also be set with the #+OPTIONS: line,
e.g. \"p:t\"."
  :group 'org-export-general
  :type 'boolean)

(defcustom org-export-with-priority nil
  "Non-nil means include priority cookies in export.
This option can also be set with the #+OPTIONS line,
e.g. \"pri:t\"."
  :group 'org-export-general
  :type 'boolean)

(defcustom org-export-with-section-numbers t
  "Non-nil means add section numbers to headlines when exporting.

When set to an integer n, numbering will only happen for
headlines whose relative level is higher or equal to n.

This option can also be set with the #+OPTIONS line,
e.g. \"num:t\"."
  :group 'org-export-general
  :type 'boolean)

(defcustom org-export-select-tags '("export")
  "Tags that select a tree for export.

If any such tag is found in a buffer, all trees that do not carry
one of these tags will be ignored during export.  Inside trees
that are selected like this, you can still deselect a subtree by
tagging it with one of the `org-export-exclude-tags'.

This option can also be set with the #+SELECT_TAGS: keyword."
  :group 'org-export-general
  :type '(repeat (string :tag "Tag")))

(defcustom org-export-with-special-strings t
  "Non-nil means interpret \"\-\", \"--\" and \"---\" for export.

When this option is turned on, these strings will be exported as:

  Org     HTML     LaTeX
 -----+----------+--------
  \\-    &shy;      \\-
  --    &ndash;    --
  ---   &mdash;    ---
  ...   &hellip;   \ldots

This option can also be set with the #+OPTIONS line,
e.g. \"-:nil\"."
  :group 'org-export-general
  :type 'boolean)

(defcustom org-export-with-sub-superscripts t
  "Non-nil means interpret \"_\" and \"^\" for export.

When this option is turned on, you can use TeX-like syntax for
sub- and superscripts.  Several characters after \"_\" or \"^\"
will be considered as a single item - so grouping with {} is
normally not needed.  For example, the following things will be
parsed as single sub- or superscripts.

 10^24   or   10^tau     several digits will be considered 1 item.
 10^-12  or   10^-tau    a leading sign with digits or a word
 x^2-y^3                 will be read as x^2 - y^3, because items are
			 terminated by almost any nonword/nondigit char.
 x_{i^2} or   x^(2-i)    braces or parenthesis do grouping.

Still, ambiguity is possible - so when in doubt use {} to enclose
the sub/superscript.  If you set this variable to the symbol
`{}', the braces are *required* in order to trigger
interpretations as sub/superscript.  This can be helpful in
documents that need \"_\" frequently in plain text.

This option can also be set with the #+OPTIONS line,
e.g. \"^:nil\"."
  :group 'org-export-general
  :type '(choice
	  (const :tag "Interpret them" t)
	  (const :tag "Curly brackets only" {})
	  (const :tag "Do not interpret them" nil)))

(defcustom org-export-with-toc t
  "Non-nil means create a table of contents in exported files.

The TOC contains headlines with levels up
to`org-export-headline-levels'.  When an integer, include levels
up to N in the toc, this may then be different from
`org-export-headline-levels', but it will not be allowed to be
larger than the number of headline levels.  When nil, no table of
contents is made.

This option can also be set with the #+OPTIONS line,
e.g. \"toc:nil\" or \"toc:3\"."
  :group 'org-export-general
  :type '(choice
	  (const :tag "No Table of Contents" nil)
	  (const :tag "Full Table of Contents" t)
	  (integer :tag "TOC to level")))

(defcustom org-export-with-tables t
  "If non-nil, lines starting with \"|\" define a table.
For example:

  | Name        | Address  | Birthday  |
  |-------------+----------+-----------|
  | Arthur Dent | England  | 29.2.2100 |

This option can also be set with the #+OPTIONS line, e.g. \"|:nil\"."
  :group 'org-export-general
  :type 'boolean)

(defcustom org-export-with-tags t
  "If nil, do not export tags, just remove them from headlines.

If this is the symbol `not-in-toc', tags will be removed from
table of contents entries, but still be shown in the headlines of
the document.

This option can also be set with the #+OPTIONS line,
e.g. \"tags:nil\"."
  :group 'org-export-general
  :type '(choice
	  (const :tag "Off" nil)
	  (const :tag "Not in TOC" not-in-toc)
	  (const :tag "On" t)))

(defcustom org-export-with-tasks t
  "Non-nil means include TODO items for export.
This may have the following values:
t                    include tasks independent of state.
todo                 include only tasks that are not yet done.
done                 include only tasks that are already done.
nil                  remove all tasks before export
list of keywords     keep only tasks with these keywords"
  :group 'org-export-general
  :type '(choice
	  (const :tag "All tasks" t)
	  (const :tag "No tasks" nil)
	  (const :tag "Not-done tasks" todo)
	  (const :tag "Only done tasks" done)
	  (repeat :tag "Specific TODO keywords"
		  (string :tag "Keyword"))))

(defcustom org-export-time-stamp-file t
  "Non-nil means insert a time stamp into the exported file.
The time stamp shows when the file was created.

This option can also be set with the #+OPTIONS line,
e.g. \"timestamp:nil\"."
  :group 'org-export-general
  :type 'boolean)

(defcustom org-export-with-timestamps t
  "Non nil means allow timestamps in export.

It can be set to `active', `inactive', t or nil, in order to
export, respectively, only active timestamps, only inactive ones,
all of them or none.

This option can also be set with the #+OPTIONS line, e.g.
\"<:nil\"."
  :group 'org-export-general
  :type '(choice
	  (const :tag "All timestamps" t)
	  (const :tag "Only active timestamps" active)
	  (const :tag "Only inactive timestamps" inactive)
	  (const :tag "No timestamp" nil)))

(defcustom org-export-with-todo-keywords t
  "Non-nil means include TODO keywords in export.
When nil, remove all these keywords from the export."
  :group 'org-export-general
  :type 'boolean)

(defcustom org-export-allow-BIND 'confirm
  "Non-nil means allow #+BIND to define local variable values for export.
This is a potential security risk, which is why the user must
confirm the use of these lines."
  :group 'org-export-general
  :type '(choice
	  (const :tag "Never" nil)
	  (const :tag "Always" t)
	  (const :tag "Ask a confirmation for each file" confirm)))

(defcustom org-export-snippet-translation-alist nil
  "Alist between export snippets back-ends and exporter back-ends.

This variable allows to provide shortcuts for export snippets.

For example, with a value of '\(\(\"h\" . \"e-html\"\)\), the
HTML back-end will recognize the contents of \"@@h:<b>@@\" as
HTML code while every other back-end will ignore it."
  :group 'org-export-general
  :type '(repeat
	  (cons
	   (string :tag "Shortcut")
	   (string :tag "Back-end"))))

(defcustom org-export-coding-system nil
  "Coding system for the exported file."
  :group 'org-export-general
  :type 'coding-system)

(defcustom org-export-copy-to-kill-ring t
  "Non-nil means exported stuff will also be pushed onto the kill ring."
  :group 'org-export-general
  :type 'boolean)

(defcustom org-export-initial-scope 'buffer
  "The initial scope when exporting with `org-export-dispatch'.
This variable can be either set to `buffer' or `subtree'."
  :group 'org-export-general
  :type '(choice
	  (const :tag "Export current buffer" 'buffer)
	  (const :tag "Export current subtree" 'subtree)))

(defcustom org-export-show-temporary-export-buffer t
  "Non-nil means show buffer after exporting to temp buffer.
When Org exports to a file, the buffer visiting that file is ever
shown, but remains buried.  However, when exporting to
a temporary buffer, that buffer is popped up in a second window.
When this variable is nil, the buffer remains buried also in
these cases."
  :group 'org-export-general
  :type 'boolean)

(defcustom org-export-dispatch-use-expert-ui nil
  "Non-nil means using a non-intrusive `org-export-dispatch'.
In that case, no help buffer is displayed.  Though, an indicator
for current export scope is added to the prompt \(i.e. \"b\" when
output is restricted to body only, \"s\" when it is restricted to
the current subtree and \"v\" when only visible elements are
considered for export\).  Also, \[?] allows to switch back to
standard mode."
  :group 'org-export-general
  :type 'boolean)



;;; Defining New Back-ends

(defmacro org-export-define-backend (backend translators &rest body)
  "Define a new back-end BACKEND.

TRANSLATORS is an alist between object or element types and
functions handling them.

These functions should return a string without any trailing
space, or nil.  They must accept three arguments: the object or
element itself, its contents or nil when it isn't recursive and
the property list used as a communication channel.

Contents, when not nil, are stripped from any global indentation
\(although the relative one is preserved).  They also always end
with a single newline character.

If, for a given type, no function is found, that element or
object type will simply be ignored, along with any blank line or
white space at its end.  The same will happen if the function
returns the nil value.  If that function returns the empty
string, the type will be ignored, but the blank lines or white
spaces will be kept.

In addition to element and object types, one function can be
associated to the `template' symbol and another one to the
`plain-text' symbol.

The former returns the final transcoded string, and can be used
to add a preamble and a postamble to document's body.  It must
accept two arguments: the transcoded string and the property list
containing export options.

The latter, when defined, is to be called on every text not
recognized as an element or an object.  It must accept two
arguments: the text string and the information channel.  It is an
appropriate place to protect special chars relative to the
back-end.

BODY can start with pre-defined keyword arguments.  The following
keywords are understood:

  :export-block

    String, or list of strings, representing block names that
    will not be parsed.  This is used to specify blocks that will
    contain raw code specific to the back-end.  These blocks
    still have to be handled by the relative `export-block' type
    translator.

  :filters-alist

    Alist between filters and function, or list of functions,
    specific to the back-end.  See `org-export-filters-alist' for
    a list of all allowed filters.  Filters defined here
    shouldn't make a back-end test, as it may prevent back-ends
    derived from this one to behave properly.

  :options-alist

    Alist between back-end specific properties introduced in
    communication channel and how their value are acquired.  See
    `org-export-options-alist' for more information about
    structure of the values.

As an example, here is how the `e-ascii' back-end is defined:

\(org-export-define-backend e-ascii
  \((bold . org-e-ascii-bold)
   \(center-block . org-e-ascii-center-block)
   \(clock . org-e-ascii-clock)
   \(code . org-e-ascii-code)
   \(drawer . org-e-ascii-drawer)
   \(dynamic-block . org-e-ascii-dynamic-block)
   \(entity . org-e-ascii-entity)
   \(example-block . org-e-ascii-example-block)
   \(export-block . org-e-ascii-export-block)
   \(export-snippet . org-e-ascii-export-snippet)
   \(fixed-width . org-e-ascii-fixed-width)
   \(footnote-definition . org-e-ascii-footnote-definition)
   \(footnote-reference . org-e-ascii-footnote-reference)
   \(headline . org-e-ascii-headline)
   \(horizontal-rule . org-e-ascii-horizontal-rule)
   \(inline-src-block . org-e-ascii-inline-src-block)
   \(inlinetask . org-e-ascii-inlinetask)
   \(italic . org-e-ascii-italic)
   \(item . org-e-ascii-item)
   \(keyword . org-e-ascii-keyword)
   \(latex-environment . org-e-ascii-latex-environment)
   \(latex-fragment . org-e-ascii-latex-fragment)
   \(line-break . org-e-ascii-line-break)
   \(link . org-e-ascii-link)
   \(macro . org-e-ascii-macro)
   \(paragraph . org-e-ascii-paragraph)
   \(plain-list . org-e-ascii-plain-list)
   \(plain-text . org-e-ascii-plain-text)
   \(planning . org-e-ascii-planning)
   \(property-drawer . org-e-ascii-property-drawer)
   \(quote-block . org-e-ascii-quote-block)
   \(quote-section . org-e-ascii-quote-section)
   \(radio-target . org-e-ascii-radio-target)
   \(section . org-e-ascii-section)
   \(special-block . org-e-ascii-special-block)
   \(src-block . org-e-ascii-src-block)
   \(statistics-cookie . org-e-ascii-statistics-cookie)
   \(strike-through . org-e-ascii-strike-through)
   \(subscript . org-e-ascii-subscript)
   \(superscript . org-e-ascii-superscript)
   \(table . org-e-ascii-table)
   \(table-cell . org-e-ascii-table-cell)
   \(table-row . org-e-ascii-table-row)
   \(target . org-e-ascii-target)
   \(template . org-e-ascii-template)
   \(timestamp . org-e-ascii-timestamp)
   \(underline . org-e-ascii-underline)
   \(verbatim . org-e-ascii-verbatim)
   \(verse-block . org-e-ascii-verse-block))
  :export-block \"ASCII\"
  :filters-alist ((:filter-headline . org-e-ascii-filter-headline-blank-lines)
		  \(:filter-section . org-e-ascii-filter-headline-blank-lines))
  :options-alist ((:ascii-charset nil nil org-e-ascii-charset)))"
  (declare (debug (&define name sexp [&rest [keywordp sexp]] defbody))
	   (indent 1))
  (let (filters options export-block)
    (while (keywordp (car body))
      (case (pop body)
        (:export-block (let ((names (pop body)))
			 (setq export-block
			       (if (consp names) (mapcar 'upcase names)
				 (list (upcase names))))))
	(:filters-alist (setq filters (pop body)))
        (:options-alist (setq options (pop body)))
        (t (pop body))))
    `(progn
       ;; Define translators.
       (defvar ,(intern (format "org-%s-translate-alist" backend)) ',translators
	 "Alist between element or object types and translators.")
       ;; Define options.
       ,(when options
	  `(defconst ,(intern (format "org-%s-options-alist" backend)) ',options
	     ,(format "Alist between %s export properties and ways to set them.
See `org-export-options-alist' for more information on the
structure of the values."
		      backend)))
       ;; Define filters.
       ,(when filters
	  `(defconst ,(intern (format "org-%s-filters-alist" backend)) ',filters
	     "Alist between filters keywords and back-end specific filters.
See `org-export-filters-alist' for more information."))
       ;; Tell parser to not parse EXPORT-BLOCK blocks.
       ,(when export-block
	  `(mapc
	    (lambda (name)
	      (add-to-list 'org-element-block-name-alist
			   `(,name . org-element-export-block-parser)))
	    ',export-block))
       ;; Splice in the body, if any.
       ,@body)))

(defmacro org-export-define-derived-backend (child parent &rest body)
  "Create a new back-end as a variant of an existing one.

CHILD is the name of the derived back-end.  PARENT is the name of
the parent back-end.

BODY can start with pre-defined keyword arguments.  The following
keywords are understood:

  :export-block

    String, or list of strings, representing block names that
    will not be parsed.  This is used to specify blocks that will
    contain raw code specific to the back-end.  These blocks
    still have to be handled by the relative `export-block' type
    translator.

  :filters-alist

    Alist of filters that will overwrite or complete filters
    defined in PARENT back-end.  See `org-export-filters-alist'
    for more a list of allowed filters.

  :options-alist

    Alist of back-end specific properties that will overwrite or
    complete those defined in PARENT back-end.  Refer to
    `org-export-options-alist' for more information about
    structure of the values.

  :translate-alist

    Alist of element and object types and transcoders that will
    overwrite or complete transcode table from PARENT back-end.
    Refer to `org-export-define-backend' for detailed information
    about transcoders.

As an example, here is how one could define \"my-latex\" back-end
as a variant of `e-latex' back-end with a custom template
function:

  \(org-export-define-derived-backend my-latex e-latex
     :translate-alist ((template . my-latex-template-fun)))

The back-end could then be called with, for example:

  \(org-export-to-buffer 'my-latex \"*Test my-latex*\")"
  (declare (debug (&define name sexp [&rest [keywordp sexp]] def-body))
	   (indent 2))
  (let (filters options translate export-block)
    (while (keywordp (car body))
      (case (pop body)
	(:export-block (let ((names (pop body)))
			 (setq export-block
			       (if (consp names) (mapcar 'upcase names)
				 (list (upcase names))))))
        (:filters-alist (setq filters (pop body)))
        (:options-alist (setq options (pop body)))
        (:translate-alist (setq translate (pop body)))
        (t (pop body))))
    `(progn
       ;; Tell parser to not parse EXPORT-BLOCK blocks.
       ,(when export-block
	  `(mapc
	    (lambda (name)
	      (add-to-list 'org-element-block-name-alist
			   `(,name . org-element-export-block-parser)))
	    ',export-block))
       ;; Define filters.
       ,(let ((parent-filters (intern (format "org-%s-filters-alist" parent))))
	  (when (or (boundp parent-filters) filters)
	    `(defconst ,(intern (format "org-%s-filters-alist" child))
	       ',(append filters
			 (and (boundp parent-filters)
			      (copy-sequence (symbol-value parent-filters))))
	       "Alist between filters keywords and back-end specific filters.
See `org-export-filters-alist' for more information.")))
       ;; Define options.
       ,(let ((parent-options (intern (format "org-%s-options-alist" parent))))
	  (when (or (boundp parent-options) options)
	    `(defconst ,(intern (format "org-%s-options-alist" child))
	       ',(append options
			 (and (boundp parent-options)
			      (copy-sequence (symbol-value parent-options))))
	       ,(format "Alist between %s export properties and ways to set them.
See `org-export-options-alist' for more information on the
structure of the values."
			child))))
       ;; Define translators.
       (defvar ,(intern (format "org-%s-translate-alist" child))
	 ',(append translate
		   (copy-sequence
		    (symbol-value
		     (intern (format "org-%s-translate-alist" parent)))))
	 "Alist between element or object types and translators.")
       ;; Splice in the body, if any.
       ,@body)))



;;; The Communication Channel
;;
;; During export process, every function has access to a number of
;; properties.  They are of two types:
;;
;; 1. Environment options are collected once at the very beginning of
;;    the process, out of the original buffer and configuration.
;;    Collecting them is handled by `org-export-get-environment'
;;    function.
;;
;;    Most environment options are defined through the
;;    `org-export-options-alist' variable.
;;
;; 2. Tree properties are extracted directly from the parsed tree,
;;    just before export, by `org-export-collect-tree-properties'.
;;
;; Here is the full list of properties available during transcode
;; process, with their category (option, tree or local) and their
;; value type.
;;
;; + `:author' :: Author's name.
;;   - category :: option
;;   - type :: string
;;
;; + `:back-end' :: Current back-end used for transcoding.
;;   - category :: tree
;;   - type :: symbol
;;
;; + `:creator' :: String to write as creation information.
;;   - category :: option
;;   - type :: string
;;
;; + `:date' :: String to use as date.
;;   - category :: option
;;   - type :: string
;;
;; + `:description' :: Description text for the current data.
;;   - category :: option
;;   - type :: string
;;
;; + `:email' :: Author's email.
;;   - category :: option
;;   - type :: string
;;
;; + `:exclude-tags' :: Tags for exclusion of subtrees from export
;;      process.
;;   - category :: option
;;   - type :: list of strings
;;
;; + `:exported-data' :: Hash table used for memoizing
;;     `org-export-data'.
;;   - category :: tree
;;   - type :: hash table
;;
;; + `:footnote-definition-alist' :: Alist between footnote labels and
;;     their definition, as parsed data.  Only non-inlined footnotes
;;     are represented in this alist.  Also, every definition isn't
;;     guaranteed to be referenced in the parse tree.  The purpose of
;;     this property is to preserve definitions from oblivion
;;     (i.e. when the parse tree comes from a part of the original
;;     buffer), it isn't meant for direct use in a back-end.  To
;;     retrieve a definition relative to a reference, use
;;     `org-export-get-footnote-definition' instead.
;;   - category :: option
;;   - type :: alist (STRING . LIST)
;;
;; + `:headline-levels' :: Maximum level being exported as an
;;      headline.  Comparison is done with the relative level of
;;      headlines in the parse tree, not necessarily with their
;;      actual level.
;;   - category :: option
;;   - type :: integer
;;
;; + `:headline-offset' :: Difference between relative and real level
;;      of headlines in the parse tree.  For example, a value of -1
;;      means a level 2 headline should be considered as level
;;      1 (cf. `org-export-get-relative-level').
;;   - category :: tree
;;   - type :: integer
;;
;; + `:headline-numbering' :: Alist between headlines and their
;;      numbering, as a list of numbers
;;      (cf. `org-export-get-headline-number').
;;   - category :: tree
;;   - type :: alist (INTEGER . LIST)
;;
;; + `:id-alist' :: Alist between ID strings and destination file's
;;      path, relative to current directory.  It is used by
;;      `org-export-resolve-id-link' to resolve ID links targeting an
;;      external file.
;;   - category :: option
;;   - type :: alist (STRING . STRING)
;;
;; + `:ignore-list' :: List of elements and objects that should be
;;      ignored during export.
;;   - category :: tree
;;   - type :: list of elements and objects
;;
;; + `:input-file' :: Full path to input file, if any.
;;   - category :: option
;;   - type :: string or nil
;;
;; + `:keywords' :: List of keywords attached to data.
;;   - category :: option
;;   - type :: string
;;
;; + `:language' :: Default language used for translations.
;;   - category :: option
;;   - type :: string
;;
;; + `:parse-tree' :: Whole parse tree, available at any time during
;;      transcoding.
;;   - category :: option
;;   - type :: list (as returned by `org-element-parse-buffer')
;;
;; + `:preserve-breaks' :: Non-nil means transcoding should preserve
;;      all line breaks.
;;   - category :: option
;;   - type :: symbol (nil, t)
;;
;; + `:section-numbers' :: Non-nil means transcoding should add
;;      section numbers to headlines.
;;   - category :: option
;;   - type :: symbol (nil, t)
;;
;; + `:select-tags' :: List of tags enforcing inclusion of sub-trees
;;      in transcoding.  When such a tag is present, subtrees without
;;      it are de facto excluded from the process.  See
;;      `use-select-tags'.
;;   - category :: option
;;   - type :: list of strings
;;
;; + `:target-list' :: List of targets encountered in the parse tree.
;;      This is used to partly resolve "fuzzy" links
;;      (cf. `org-export-resolve-fuzzy-link').
;;   - category :: tree
;;   - type :: list of strings
;;
;; + `:time-stamp-file' :: Non-nil means transcoding should insert
;;      a time stamp in the output.
;;   - category :: option
;;   - type :: symbol (nil, t)
;;
;; + `:translate-alist' :: Alist between element and object types and
;;      transcoding functions relative to the current back-end.
;;      Special keys `template' and `plain-text' are also possible.
;;   - category :: option
;;   - type :: alist (SYMBOL . FUNCTION)
;;
;; + `:with-archived-trees' :: Non-nil when archived subtrees should
;;      also be transcoded.  If it is set to the `headline' symbol,
;;      only the archived headline's name is retained.
;;   - category :: option
;;   - type :: symbol (nil, t, `headline')
;;
;; + `:with-author' :: Non-nil means author's name should be included
;;      in the output.
;;   - category :: option
;;   - type :: symbol (nil, t)
;;
;; + `:with-clocks' :: Non-nild means clock keywords should be exported.
;;   - category :: option
;;   - type :: symbol (nil, t)
;;
;; + `:with-creator' :: Non-nild means a creation sentence should be
;;      inserted at the end of the transcoded string.  If the value
;;      is `comment', it should be commented.
;;   - category :: option
;;   - type :: symbol (`comment', nil, t)
;;
;; + `:with-drawers' :: Non-nil means drawers should be exported.  If
;;      its value is a list of names, only drawers with such names
;;      will be transcoded.
;;   - category :: option
;;   - type :: symbol (nil, t) or list of strings
;;
;; + `:with-email' :: Non-nil means output should contain author's
;;                   email.
;;   - category :: option
;;   - type :: symbol (nil, t)
;;
;; + `:with-emphasize' :: Non-nil means emphasized text should be
;;      interpreted.
;;   - category :: option
;;   - type :: symbol (nil, t)
;;
;; + `:with-fixed-width' :: Non-nil if transcoder should interpret
;;      strings starting with a colon as a fixed-with (verbatim) area.
;;   - category :: option
;;   - type :: symbol (nil, t)
;;
;; + `:with-footnotes' :: Non-nil if transcoder should interpret
;;      footnotes.
;;   - category :: option
;;   - type :: symbol (nil, t)
;;
;; + `:with-plannings' :: Non-nil means transcoding should include
;;      planning info.
;;   - category :: option
;;   - type :: symbol (nil, t)
;;
;; + `:with-priority' :: Non-nil means transcoding should include
;;      priority cookies.
;;   - category :: option
;;   - type :: symbol (nil, t)
;;
;; + `:with-special-strings' :: Non-nil means transcoding should
;;      interpret special strings in plain text.
;;   - category :: option
;;   - type :: symbol (nil, t)
;;
;; + `:with-sub-superscript' :: Non-nil means transcoding should
;;      interpret subscript and superscript.  With a value of "{}",
;;      only interpret those using curly brackets.
;;   - category :: option
;;   - type :: symbol (nil, {}, t)
;;
;; + `:with-tables' :: Non-nil means transcoding should interpret
;;      tables.
;;   - category :: option
;;   - type :: symbol (nil, t)
;;
;; + `:with-tags' :: Non-nil means transcoding should keep tags in
;;      headlines.  A `not-in-toc' value will remove them from the
;;      table of contents, if any, nonetheless.
;;   - category :: option
;;   - type :: symbol (nil, t, `not-in-toc')
;;
;; + `:with-tasks' :: Non-nil means transcoding should include
;;      headlines with a TODO keyword.  A `todo' value will only
;;      include headlines with a todo type keyword while a `done'
;;      value will do the contrary.  If a list of strings is provided,
;;      only tasks with keywords belonging to that list will be kept.
;;   - category :: option
;;   - type :: symbol (t, todo, done, nil) or list of strings
;;
;; + `:with-timestamps' :: Non-nil means transcoding should include
;;      time stamps.  Special value `active' (resp. `inactive') ask to
;;      export only active (resp. inactive) timestamps.  Otherwise,
;;      completely remove them.
;;   - category :: option
;;   - type :: symbol: (`active', `inactive', t, nil)
;;
;; + `:with-toc' :: Non-nil means that a table of contents has to be
;;      added to the output.  An integer value limits its depth.
;;   - category :: option
;;   - type :: symbol (nil, t or integer)
;;
;; + `:with-todo-keywords' :: Non-nil means transcoding should
;;      include TODO keywords.
;;   - category :: option
;;   - type :: symbol (nil, t)


;;;; Environment Options
;;
;; Environment options encompass all parameters defined outside the
;; scope of the parsed data.  They come from five sources, in
;; increasing precedence order:
;;
;; - Global variables,
;; - Buffer's attributes,
;; - Options keyword symbols,
;; - Buffer keywords,
;; - Subtree properties.
;;
;; The central internal function with regards to environment options
;; is `org-export-get-environment'.  It updates global variables with
;; "#+BIND:" keywords, then retrieve and prioritize properties from
;; the different sources.
;;
;;  The internal functions doing the retrieval are:
;;  `org-export--get-global-options',
;;  `org-export--get-buffer-attributes',
;;  `org-export--parse-option-keyword',
;;  `org-export--get-subtree-options' and
;;  `org-export--get-inbuffer-options'
;;
;; Also, `org-export--confirm-letbind' and `org-export--install-letbind'
;; take care of the part relative to "#+BIND:" keywords.

(defun org-export-get-environment (&optional backend subtreep ext-plist)
  "Collect export options from the current buffer.

Optional argument BACKEND is a symbol specifying which back-end
specific options to read, if any.

When optional argument SUBTREEP is non-nil, assume the export is
done against the current sub-tree.

Third optional argument EXT-PLIST is a property list with
external parameters overriding Org default settings, but still
inferior to file-local settings."
  ;; First install #+BIND variables.
  (org-export--install-letbind-maybe)
  ;; Get and prioritize export options...
  (org-combine-plists
   ;; ... from global variables...
   (org-export--get-global-options backend)
   ;; ... from buffer's attributes...
   (org-export--get-buffer-attributes)
   ;; ... from an external property list...
   ext-plist
   ;; ... from in-buffer settings...
   (org-export--get-inbuffer-options
    backend
    (and buffer-file-name (org-remove-double-quotes buffer-file-name)))
   ;; ... and from subtree, when appropriate.
   (and subtreep (org-export--get-subtree-options backend))
   ;; Eventually install back-end symbol and its translation table.
   `(:back-end
     ,backend
     :translate-alist
     ,(let ((trans-alist (intern (format "org-%s-translate-alist" backend))))
	(when (boundp trans-alist) (symbol-value trans-alist))))))

(defun org-export--parse-option-keyword (options &optional backend)
  "Parse an OPTIONS line and return values as a plist.
Optional argument BACKEND is a symbol specifying which back-end
specific items to read, if any."
  (let* ((all
	  (append org-export-options-alist
		  (and backend
		       (let ((var (intern
				   (format "org-%s-options-alist" backend))))
			 (and (boundp var) (eval var))))))
	 ;; Build an alist between #+OPTION: item and property-name.
	 (alist (delq nil
		      (mapcar (lambda (e)
				(when (nth 2 e) (cons (regexp-quote (nth 2 e))
						      (car e))))
			      all)))
	 plist)
    (mapc (lambda (e)
	    (when (string-match (concat "\\(\\`\\|[ \t]\\)"
					(car e)
					":\\(([^)\n]+)\\|[^ \t\n\r;,.]*\\)")
				options)
	      (setq plist (plist-put plist
				     (cdr e)
				     (car (read-from-string
					   (match-string 2 options)))))))
	  alist)
    plist))

(defun org-export--get-subtree-options (&optional backend)
  "Get export options in subtree at point.
Optional argument BACKEND is a symbol specifying back-end used
for export.  Return options as a plist."
  ;; For each buffer keyword, create an headline property setting the
  ;; same property in communication channel. The name for the property
  ;; is the keyword with "EXPORT_" appended to it.
  (org-with-wide-buffer
   (let (prop plist)
     ;; Make sure point is at an heading.
     (unless (org-at-heading-p) (org-back-to-heading t))
     ;; Take care of EXPORT_TITLE. If it isn't defined, use headline's
     ;; title as its fallback value.
     (when (setq prop (progn (looking-at org-todo-line-regexp)
			     (or (save-match-data
				   (org-entry-get (point) "EXPORT_TITLE"))
				 (org-match-string-no-properties 3))))
       (setq plist
	     (plist-put
	      plist :title
	      (org-element-parse-secondary-string
	       prop (org-element-restriction 'keyword)))))
     ;; EXPORT_OPTIONS are parsed in a non-standard way.
     (when (setq prop (org-entry-get (point) "EXPORT_OPTIONS"))
       (setq plist
	     (nconc plist (org-export--parse-option-keyword prop backend))))
     ;; Handle other keywords.
     (let ((seen '("TITLE")))
       (mapc
	(lambda (option)
	  (let ((property (nth 1 option)))
	    (when (and property (not (member property seen)))
	      (let* ((subtree-prop (concat "EXPORT_" property))
		     ;; Export properties are not case-sensitive.
		     (value (let ((case-fold-search t))
			      (org-entry-get (point) subtree-prop))))
		(push property seen)
		(when value
		  (setq plist
			(plist-put
			 plist
			 (car option)
			 ;; Parse VALUE if required.
			 (if (member property org-element-parsed-keywords)
			     (org-element-parse-secondary-string
			      value (org-element-restriction 'keyword))
			   value))))))))
	;; Also look for both general keywords and back-end specific
	;; options if BACKEND is provided.
	(append (and backend
		     (let ((var (intern
				 (format "org-%s-options-alist" backend))))
		       (and (boundp var) (symbol-value var))))
		org-export-options-alist)))
     ;; Return value.
     plist)))

(defun org-export--get-inbuffer-options (&optional backend files)
  "Return current buffer export options, as a plist.

Optional argument BACKEND, when non-nil, is a symbol specifying
which back-end specific options should also be read in the
process.

Optional argument FILES is a list of setup files names read so
far, used to avoid circular dependencies.

Assume buffer is in Org mode.  Narrowing, if any, is ignored."
  (org-with-wide-buffer
   (goto-char (point-min))
   (let ((case-fold-search t) plist)
     ;; 1. Special keywords, as in `org-export-special-keywords'.
     (let ((special-re (org-make-options-regexp org-export-special-keywords)))
       (while (re-search-forward special-re nil t)
	 (let ((element (org-element-at-point)))
	   (when (eq (org-element-type element) 'keyword)
	     (let* ((key (org-element-property :key element))
		    (val (org-element-property :value element))
		    (prop
		     (cond
		      ((string= key "SETUP_FILE")
		       (let ((file
			      (expand-file-name
			       (org-remove-double-quotes (org-trim val)))))
			 ;; Avoid circular dependencies.
			 (unless (member file files)
			   (with-temp-buffer
			     (insert (org-file-contents file 'noerror))
			     (org-mode)
			     (org-export--get-inbuffer-options
			      backend (cons file files))))))
		      ((string= key "OPTIONS")
		       (org-export--parse-option-keyword val backend))
		      ((string= key "MACRO")
		       (when (string-match
			      "^\\([-a-zA-Z0-9_]+\\)\\(?:[ \t]+\\(.*?\\)[ \t]*$\\)?"
			      val)
			 (let ((key
				(intern
				 (concat ":macro-"
					 (downcase (match-string 1 val)))))
			       (value (org-match-string-no-properties 2 val)))
			   (cond
			    ((not value) nil)
			    ;; Value will be evaled: do not parse it.
			    ((string-match "\\`(eval\\>" value)
			     (list key (list value)))
			    ;; Value has to be parsed for nested
			    ;; macros.
			    (t
			     (list
			      key
			      (let ((restr (org-element-restriction 'macro)))
				(org-element-parse-secondary-string
				 ;; If user explicitly asks for
				 ;; a newline, be sure to preserve it
				 ;; from further filling with
				 ;; `hard-newline'.  Also replace
				 ;; "\\n" with "\n", "\\\n" with "\\n"
				 ;; and so on...
				 (replace-regexp-in-string
				  "\\(\\\\\\\\\\)n" "\\\\"
				  (replace-regexp-in-string
				   "\\(?:^\\|[^\\\\]\\)\\(\\\\n\\)"
				   hard-newline value nil nil 1)
				  nil nil 1)
				 restr)))))))))))
	       (setq plist (org-combine-plists plist prop)))))))
     ;; 2. Standard options, as in `org-export-options-alist'.
     (let* ((all (append org-export-options-alist
			 ;; Also look for back-end specific options
			 ;; if BACKEND is defined.
			 (and backend
			      (let ((var
				     (intern
				      (format "org-%s-options-alist" backend))))
				(and (boundp var) (eval var))))))
	    ;; Build alist between keyword name and property name.
	    (alist
	     (delq nil (mapcar
			(lambda (e) (when (nth 1 e) (cons (nth 1 e) (car e))))
			all)))
	    ;; Build regexp matching all keywords associated to export
	    ;; options.  Note: the search is case insensitive.
	    (opt-re (org-make-options-regexp
		     (delq nil (mapcar (lambda (e) (nth 1 e)) all)))))
       (goto-char (point-min))
       (while (re-search-forward opt-re nil t)
	 (let ((element (org-element-at-point)))
	   (when (eq (org-element-type element) 'keyword)
	     (let* ((key (org-element-property :key element))
		    (val (org-element-property :value element))
		    (prop (cdr (assoc key alist)))
		    (behaviour (nth 4 (assq prop all))))
	       (setq plist
		     (plist-put
		      plist prop
		      ;; Handle value depending on specified BEHAVIOUR.
		      (case behaviour
			(space
			 (if (not (plist-get plist prop)) (org-trim val)
			   (concat (plist-get plist prop) " " (org-trim val))))
			(newline
			 (org-trim
			  (concat (plist-get plist prop) "\n" (org-trim val))))
			(split
			 `(,@(plist-get plist prop) ,@(org-split-string val)))
			('t val)
			(otherwise (if (not (plist-member plist prop)) val
				     (plist-get plist prop))))))))))
       ;; Parse keywords specified in `org-element-parsed-keywords'.
       (mapc
	(lambda (key)
	  (let* ((prop (cdr (assoc key alist)))
		 (value (and prop (plist-get plist prop))))
	    (when (stringp value)
	      (setq plist
		    (plist-put
		     plist prop
		     (org-element-parse-secondary-string
		      value (org-element-restriction 'keyword)))))))
	org-element-parsed-keywords))
     ;; 3. Return final value.
     plist)))

(defun org-export--get-buffer-attributes ()
  "Return properties related to buffer attributes, as a plist."
  (let ((visited-file (buffer-file-name (buffer-base-buffer))))
    (list
     ;; Store full path of input file name, or nil.  For internal use.
     :input-file visited-file
     :title (or (and visited-file
		     (file-name-sans-extension
		      (file-name-nondirectory visited-file)))
		(buffer-name (buffer-base-buffer)))
     :footnote-definition-alist
     ;; Footnotes definitions must be collected in the original
     ;; buffer, as there's no insurance that they will still be in the
     ;; parse tree, due to possible narrowing.
     (let (alist)
       (org-with-wide-buffer
	(goto-char (point-min))
	(while (re-search-forward org-footnote-definition-re nil t)
	  (let ((def (org-footnote-at-definition-p)))
	    (when def
	      (org-skip-whitespace)
	      (push (cons (car def)
			  (save-restriction
			    (narrow-to-region (point) (nth 2 def))
			    ;; Like `org-element-parse-buffer', but
			    ;; makes sure the definition doesn't start
			    ;; with a section element.
			    (org-element--parse-elements
			     (point-min) (point-max) nil nil nil nil
			     (list 'org-data nil))))
		    alist))))
	alist))
     :id-alist
     ;; Collect id references.
     (let (alist)
       (org-with-wide-buffer
	(goto-char (point-min))
	(while (re-search-forward
		"\\[\\[id:\\(\\S-+?\\)\\]\\(?:\\[.*?\\]\\)?\\]" nil t)
	  (let* ((id (org-match-string-no-properties 1))
		 (file (org-id-find-id-file id)))
	    (when file (push (cons id (file-relative-name file)) alist)))))
       alist)
     :macro-modification-time
     (and visited-file
	  (file-exists-p visited-file)
	  (concat "(eval (format-time-string \"$1\" '"
		  (prin1-to-string (nth 5 (file-attributes visited-file)))
		  "))"))
     ;; Store input file name as a macro.
     :macro-input-file (and visited-file (file-name-nondirectory visited-file))
     ;; `:macro-date', `:macro-time' and `:macro-property' could as
     ;; well be initialized as tree properties, since they don't
     ;; depend on buffer properties.  Though, it may be more logical
     ;; to keep them close to other ":macro-" properties.
     :macro-date "(eval (format-time-string \"$1\"))"
     :macro-time "(eval (format-time-string \"$1\"))"
     :macro-property "(eval (org-entry-get nil \"$1\" 'selective))")))

(defun org-export--get-global-options (&optional backend)
  "Return global export options as a plist.

Optional argument BACKEND, if non-nil, is a symbol specifying
which back-end specific export options should also be read in the
process."
  (let ((all (append org-export-options-alist
		     (and backend
			  (let ((var (intern
				      (format "org-%s-options-alist" backend))))
			    (and (boundp var) (symbol-value var))))))
	;; Output value.
	plist)
    (mapc
     (lambda (cell)
       (setq plist
	     (plist-put
	      plist
	      (car cell)
	      ;; Eval default value provided.  If keyword is a member
	      ;; of `org-element-parsed-keywords', parse it as
	      ;; a secondary string before storing it.
	      (let ((value (eval (nth 3 cell))))
		(if (not (stringp value)) value
		  (let ((keyword (nth 1 cell)))
		    (if (not (member keyword org-element-parsed-keywords)) value
		      (org-element-parse-secondary-string
		       value (org-element-restriction 'keyword)))))))))
     all)
    ;; Return value.
    plist))

(defvar org-export--allow-BIND-local nil)
(defun org-export--confirm-letbind ()
  "Can we use #+BIND values during export?
By default this will ask for confirmation by the user, to divert
possible security risks."
  (cond
   ((not org-export-allow-BIND) nil)
   ((eq org-export-allow-BIND t) t)
   ((local-variable-p 'org-export--allow-BIND-local)
    org-export--allow-BIND-local)
   (t (org-set-local 'org-export--allow-BIND-local
		     (yes-or-no-p "Allow BIND values in this buffer? ")))))

(defun org-export--install-letbind-maybe ()
  "Install the values from #+BIND lines as local variables.
Variables must be installed before in-buffer options are
retrieved."
  (let (letbind pair)
    (org-with-wide-buffer
     (goto-char (point-min))
     (while (re-search-forward (org-make-options-regexp '("BIND")) nil t)
       (when (org-export-confirm-letbind)
	 (push (read (concat "(" (org-match-string-no-properties 2) ")"))
	       letbind))))
    (while (setq pair (pop letbind))
      (org-set-local (car pair) (nth 1 pair)))))


;;;; Tree Properties
;;
;; Tree properties are infromation extracted from parse tree.  They
;; are initialized at the beginning of the transcoding process by
;; `org-export-collect-tree-properties'.
;;
;; Dedicated functions focus on computing the value of specific tree
;; properties during initialization.  Thus,
;; `org-export--populate-ignore-list' lists elements and objects that
;; should be skipped during export, `org-export--get-min-level' gets
;; the minimal exportable level, used as a basis to compute relative
;; level for headlines.  Eventually
;; `org-export--collect-headline-numbering' builds an alist between
;; headlines and their numbering.

(defun org-export-collect-tree-properties (data info)
  "Extract tree properties from parse tree.

DATA is the parse tree from which information is retrieved.  INFO
is a list holding export options.

Following tree properties are set or updated:

`:exported-data' Hash table used to memoize results from
                 `org-export-data'.

`:footnote-definition-alist' List of footnotes definitions in
                   original buffer and current parse tree.

`:headline-offset' Offset between true level of headlines and
		   local level.  An offset of -1 means an headline
		   of level 2 should be considered as a level
		   1 headline in the context.

`:headline-numbering' Alist of all headlines as key an the
		      associated numbering as value.

`:ignore-list'     List of elements that should be ignored during
                   export.

`:target-list'     List of all targets in the parse tree.

Return updated plist."
  ;; Install the parse tree in the communication channel, in order to
  ;; use `org-export-get-genealogy' and al.
  (setq info (plist-put info :parse-tree data))
  ;; Get the list of elements and objects to ignore, and put it into
  ;; `:ignore-list'.  Do not overwrite any user ignore that might have
  ;; been done during parse tree filtering.
  (setq info
	(plist-put info
		   :ignore-list
		   (append (org-export--populate-ignore-list data info)
			   (plist-get info :ignore-list))))
  ;; Compute `:headline-offset' in order to be able to use
  ;; `org-export-get-relative-level'.
  (setq info
	(plist-put info
		   :headline-offset
		   (- 1 (org-export--get-min-level data info))))
  ;; Update footnotes definitions list with definitions in parse tree.
  ;; This is required since buffer expansion might have modified
  ;; boundaries of footnote definitions contained in the parse tree.
  ;; This way, definitions in `footnote-definition-alist' are bound to
  ;; match those in the parse tree.
  (let ((defs (plist-get info :footnote-definition-alist)))
    (org-element-map
     data 'footnote-definition
     (lambda (fn)
       (push (cons (org-element-property :label fn)
		   `(org-data nil ,@(org-element-contents fn)))
	     defs)))
    (setq info (plist-put info :footnote-definition-alist defs)))
  ;; Properties order doesn't matter: get the rest of the tree
  ;; properties.
  (nconc
   `(:target-list
     ,(org-element-map
       data '(keyword target)
       (lambda (blob)
	 (when (or (eq (org-element-type blob) 'target)
		   (string= (org-element-property :key blob) "TARGET"))
	   blob)) info)
     :headline-numbering ,(org-export--collect-headline-numbering data info)
     :exported-data ,(make-hash-table :test 'eq :size 4001))
   info))

(defun org-export--get-min-level (data options)
  "Return minimum exportable headline's level in DATA.
DATA is parsed tree as returned by `org-element-parse-buffer'.
OPTIONS is a plist holding export options."
  (catch 'exit
    (let ((min-level 10000))
      (mapc
       (lambda (blob)
	 (when (and (eq (org-element-type blob) 'headline)
		    (not (memq blob (plist-get options :ignore-list))))
	   (setq min-level
		 (min (org-element-property :level blob) min-level)))
	 (when (= min-level 1) (throw 'exit 1)))
       (org-element-contents data))
      ;; If no headline was found, for the sake of consistency, set
      ;; minimum level to 1 nonetheless.
      (if (= min-level 10000) 1 min-level))))

(defun org-export--collect-headline-numbering (data options)
  "Return numbering of all exportable headlines in a parse tree.

DATA is the parse tree.  OPTIONS is the plist holding export
options.

Return an alist whose key is an headline and value is its
associated numbering \(in the shape of a list of numbers\)."
  (let ((numbering (make-vector org-export-max-depth 0)))
    (org-element-map
     data
     'headline
     (lambda (headline)
       (let ((relative-level
	      (1- (org-export-get-relative-level headline options))))
	 (cons
	  headline
	  (loop for n across numbering
		for idx from 0 to org-export-max-depth
		when (< idx relative-level) collect n
		when (= idx relative-level) collect (aset numbering idx (1+ n))
		when (> idx relative-level) do (aset numbering idx 0)))))
     options)))

(defun org-export--populate-ignore-list (data options)
  "Return list of elements and objects to ignore during export.
DATA is the parse tree to traverse.  OPTIONS is the plist holding
export options."
  (let* (ignore
	 walk-data			; for byte-compiler.
	 (walk-data
	  (function
	   (lambda (data options selected)
	     ;; Collect ignored elements or objects into IGNORE-LIST.
	     (mapc
	      (lambda (el)
		(if (org-export--skip-p el options selected) (push el ignore)
		  (let ((type (org-element-type el)))
		    (if (and (eq (plist-get options :with-archived-trees)
				 'headline)
			     (eq (org-element-type el) 'headline)
			     (org-element-property :archivedp el))
			;; If headline is archived but tree below has
			;; to be skipped, add it to ignore list.
			(mapc (lambda (e) (push e ignore))
			      (org-element-contents el))
		      ;; Move into recursive objects/elements.
		      (when (org-element-contents el)
			(funcall walk-data el options selected))))))
	      (org-element-contents data))))))
    ;; Main call.  First find trees containing a select tag, if any.
    (funcall walk-data data options (org-export--selected-trees data options))
    ;; Return value.
    ignore))

(defun org-export--selected-trees (data info)
  "Return list of headlines containing a select tag in their tree.
DATA is parsed data as returned by `org-element-parse-buffer'.
INFO is a plist holding export options."
  (let* (selected-trees
	 walk-data			; for byte-compiler.
	 (walk-data
	  (function
	   (lambda (data genealogy)
	     (case (org-element-type data)
	       (org-data (mapc (lambda (el) (funcall walk-data el genealogy))
			       (org-element-contents data)))
	       (headline
		(let ((tags (org-element-property :tags data)))
		  (if (loop for tag in (plist-get info :select-tags)
			    thereis (member tag tags))
		      ;; When a select tag is found, mark full
		      ;; genealogy and every headline within the tree
		      ;; as acceptable.
		      (setq selected-trees
			    (append
			     genealogy
			     (org-element-map data 'headline 'identity)
			     selected-trees))
		    ;; Else, continue searching in tree, recursively.
		    (mapc
		     (lambda (el) (funcall walk-data el (cons data genealogy)))
		     (org-element-contents data))))))))))
    (funcall walk-data data nil) selected-trees))

(defun org-export--skip-p (blob options selected)
  "Non-nil when element or object BLOB should be skipped during export.
OPTIONS is the plist holding export options.  SELECTED, when
non-nil, is a list of headlines belonging to a tree with a select
tag."
  (case (org-element-type blob)
    ;; Check headline.
    (headline
     (let ((with-tasks (plist-get options :with-tasks))
	   (todo (org-element-property :todo-keyword blob))
	   (todo-type (org-element-property :todo-type blob))
	   (archived (plist-get options :with-archived-trees))
	   (tags (org-element-property :tags blob)))
       (or
	;; Ignore subtrees with an exclude tag.
	(loop for k in (plist-get options :exclude-tags)
	      thereis (member k tags))
	;; When a select tag is present in the buffer, ignore any tree
	;; without it.
	(and selected (not (memq blob selected)))
	;; Ignore commented sub-trees.
	(org-element-property :commentedp blob)
	;; Ignore archived subtrees if `:with-archived-trees' is nil.
	(and (not archived) (org-element-property :archivedp blob))
	;; Ignore tasks, if specified by `:with-tasks' property.
	(and todo
	     (or (not with-tasks)
		 (and (memq with-tasks '(todo done))
		      (not (eq todo-type with-tasks)))
		 (and (consp with-tasks) (not (member todo with-tasks))))))))
    ;; Check inlinetask.
    (inlinetask (not (plist-get options :with-inlinetasks)))
    ;; Check timestamp.
    (timestamp
     (case (plist-get options :with-timestamps)
       ;; No timestamp allowed.
       ('nil t)
       ;; Only active timestamps allowed and the current one isn't
       ;; active.
       (active
	(not (memq (org-element-property :type blob)
		   '(active active-range))))
       ;; Only inactive timestamps allowed and the current one isn't
       ;; inactive.
       (inactive
	(not (memq (org-element-property :type blob)
		   '(inactive inactive-range))))))
    ;; Check drawer.
    (drawer
     (or (not (plist-get options :with-drawers))
	 (and (consp (plist-get options :with-drawers))
	      (not (member (org-element-property :drawer-name blob)
			   (plist-get options :with-drawers))))))
    ;; Check table-row.
    (table-row (org-export-table-row-is-special-p blob options))
    ;; Check table-cell.
    (table-cell
     (and (org-export-table-has-special-column-p
	   (org-export-get-parent-table blob))
	  (not (org-export-get-previous-element blob options))))
    ;; Check clock.
    (clock (not (plist-get options :with-clocks)))
    ;; Check planning.
    (planning (not (plist-get options :with-plannings)))))



;;; The Transcoder
;;
;; `org-export-data' reads a parse tree (obtained with, i.e.
;; `org-element-parse-buffer') and transcodes it into a specified
;; back-end output.  It takes care of filtering out elements or
;; objects according to export options and organizing the output blank
;; lines and white space are preserved.  The function memoizes its
;; results, so it is cheap to call it within translators.
;;
;; Internally, three functions handle the filtering of objects and
;; elements during the export.  In particular,
;; `org-export-ignore-element' marks an element or object so future
;; parse tree traversals skip it, `org-export--interpret-p' tells which
;; elements or objects should be seen as real Org syntax and
;; `org-export-expand' transforms the others back into their original
;; shape
;;
;; `org-export-transcoder' is an accessor returning appropriate
;; translator function for a given element or object.

(defun org-export-transcoder (blob info)
  "Return appropriate transcoder for BLOB.
INFO is a plist containing export directives."
  (let ((type (org-element-type blob)))
    ;; Return contents only for complete parse trees.
    (if (eq type 'org-data) (lambda (blob contents info) contents)
      (let ((transcoder (cdr (assq type (plist-get info :translate-alist)))))
	(and (functionp transcoder) transcoder)))))

(defun org-export-data (data info)
  "Convert DATA into current back-end format.

DATA is a parse tree, an element or an object or a secondary
string.  INFO is a plist holding export options.

Return transcoded string."
  (let ((memo (gethash data (plist-get info :exported-data) 'no-memo)))
    (if (not (eq memo 'no-memo)) memo
      (let* ((type (org-element-type data))
	     (results
	      (cond
	       ;; Ignored element/object.
	       ((memq data (plist-get info :ignore-list)) nil)
	       ;; Plain text.
	       ((eq type 'plain-text)
		(org-export-filter-apply-functions
		 (plist-get info :filter-plain-text)
		 (let ((transcoder (org-export-transcoder data info)))
		   (if transcoder (funcall transcoder data info) data))
		 info))
	       ;; Uninterpreted element/object: change it back to Org
	       ;; syntax and export again resulting raw string.
	       ((not (org-export--interpret-p data info))
		(org-export-data
		 (org-export-expand
		  data
		  (mapconcat (lambda (blob) (org-export-data blob info))
			     (org-element-contents data)
			     ""))
		 info))
	       ;; Secondary string.
	       ((not type)
		(mapconcat (lambda (obj) (org-export-data obj info)) data ""))
	       ;; Element/Object without contents or, as a special case,
	       ;; headline with archive tag and archived trees restricted
	       ;; to title only.
	       ((or (not (org-element-contents data))
		    (and (eq type 'headline)
			 (eq (plist-get info :with-archived-trees) 'headline)
			 (org-element-property :archivedp data)))
		(let ((transcoder (org-export-transcoder data info)))
		  (and (functionp transcoder)
		       (funcall transcoder data nil info))))
	       ;; Element/Object with contents.
	       (t
		(let ((transcoder (org-export-transcoder data info)))
		  (when transcoder
		    (let* ((greaterp (memq type org-element-greater-elements))
			   (objectp
			    (and (not greaterp)
				 (memq type org-element-recursive-objects)))
			   (contents
			    (mapconcat
			     (lambda (element) (org-export-data element info))
			     (org-element-contents
			      (if (or greaterp objectp) data
				;; Elements directly containing objects
				;; must have their indentation normalized
				;; first.
				(org-element-normalize-contents
				 data
				 ;; When normalizing contents of the first
				 ;; paragraph in an item or a footnote
				 ;; definition, ignore first line's
				 ;; indentation: there is none and it
				 ;; might be misleading.
				 (when (eq type 'paragraph)
				   (let ((parent (org-export-get-parent data)))
				     (and
				      (eq (car (org-element-contents parent))
					  data)
				      (memq (org-element-type parent)
					    '(footnote-definition item))))))))
			     "")))
		      (funcall transcoder data
			       (if (not greaterp) contents
				 (org-element-normalize-string contents))
			       info))))))))
	;; Final result will be memoized before being returned.
	(puthash
	 data
	 (cond
	  ((not results) nil)
	  ((memq type '(org-data plain-text nil)) results)
	  ;; Append the same white space between elements or objects as in
	  ;; the original buffer, and call appropriate filters.
	  (t
	   (let ((results
		  (org-export-filter-apply-functions
		   (plist-get info (intern (format ":filter-%s" type)))
		   (let ((post-blank (or (org-element-property :post-blank data)
					 0)))
		     (if (memq type org-element-all-elements)
			 (concat (org-element-normalize-string results)
				 (make-string post-blank ?\n))
		       (concat results (make-string post-blank ? ))))
		   info)))
	     results)))
	 (plist-get info :exported-data))))))

(defun org-export--interpret-p (blob info)
  "Non-nil if element or object BLOB should be interpreted as Org syntax.
Check is done according to export options INFO, stored as
a plist."
  (case (org-element-type blob)
    ;; ... entities...
    (entity (plist-get info :with-entities))
    ;; ... emphasis...
    (emphasis (plist-get info :with-emphasize))
    ;; ... fixed-width areas.
    (fixed-width (plist-get info :with-fixed-width))
    ;; ... footnotes...
    ((footnote-definition footnote-reference)
     (plist-get info :with-footnotes))
    ;; ... sub/superscripts...
    ((subscript superscript)
     (let ((sub/super-p (plist-get info :with-sub-superscript)))
       (if (eq sub/super-p '{})
	   (org-element-property :use-brackets-p blob)
	 sub/super-p)))
    ;; ... tables...
    (table (plist-get info :with-tables))
    (otherwise t)))

(defun org-export-expand (blob contents)
  "Expand a parsed element or object to its original state.
BLOB is either an element or an object.  CONTENTS is its
contents, as a string or nil."
  (funcall
   (intern (format "org-element-%s-interpreter" (org-element-type blob)))
   blob contents))

(defun org-export-ignore-element (element info)
  "Add ELEMENT to `:ignore-list' in INFO.

Any element in `:ignore-list' will be skipped when using
`org-element-map'.  INFO is modified by side effects."
  (plist-put info :ignore-list (cons element (plist-get info :ignore-list))))



;;; The Filter System
;;
;; Filters allow end-users to tweak easily the transcoded output.
;; They are the functional counterpart of hooks, as every filter in
;; a set is applied to the return value of the previous one.
;;
;; Every set is back-end agnostic.  Although, a filter is always
;; called, in addition to the string it applies to, with the back-end
;; used as argument, so it's easy for the end-user to add back-end
;; specific filters in the set.  The communication channel, as
;; a plist, is required as the third argument.
;;
;; From the developer side, filters sets can be installed in the
;; process with the help of `org-export-define-backend', which
;; internally sets `org-BACKEND-filters-alist' variable.  Each
;; association has a key among the following symbols and a function or
;; a list of functions as value.
;;
;; - `:filter-parse-tree' applies directly on the complete parsed
;;   tree.  It's the only filters set that doesn't apply to a string.
;;   Users can set it through `org-export-filter-parse-tree-functions'
;;   variable.
;;
;; - `:filter-final-output' applies to the final transcoded string.
;;   Users can set it with `org-export-filter-final-output-functions'
;;   variable
;;
;; - `:filter-plain-text' applies to any string not recognized as Org
;;   syntax.  `org-export-filter-plain-text-functions' allows users to
;;   configure it.
;;
;; - `:filter-TYPE' applies on the string returned after an element or
;;   object of type TYPE has been transcoded.  An user can modify
;;   `org-export-filter-TYPE-functions'
;;
;; All filters sets are applied with
;; `org-export-filter-apply-functions' function.  Filters in a set are
;; applied in a LIFO fashion.  It allows developers to be sure that
;; their filters will be applied first.
;;
;; Filters properties are installed in communication channel with
;; `org-export-install-filters' function.
;;
;; Eventually, a hook (`org-export-before-parsing-hook') is run just
;; before parsing to allow for heavy structure modifications.


;;;; Before Parsing Hook

(defvar org-export-before-parsing-hook nil
  "Hook run before parsing an export buffer.

This is run after include keywords have been expanded and Babel
code executed, on a copy of original buffer's area being
exported.  Visibility is the same as in the original one.  Point
is left at the beginning of the new one.

Every function in this hook will be called with one argument: the
back-end currently used, as a symbol.")


;;;; Special Filters

(defvar org-export-filter-parse-tree-functions nil
  "List of functions applied to the parsed tree.
Each filter is called with three arguments: the parse tree, as
returned by `org-element-parse-buffer', the back-end, as
a symbol, and the communication channel, as a plist.  It must
return the modified parse tree to transcode.")

(defvar org-export-filter-final-output-functions nil
  "List of functions applied to the transcoded string.
Each filter is called with three arguments: the full transcoded
string, the back-end, as a symbol, and the communication channel,
as a plist.  It must return a string that will be used as the
final export output.")

(defvar org-export-filter-plain-text-functions nil
  "List of functions applied to plain text.
Each filter is called with three arguments: a string which
contains no Org syntax, the back-end, as a symbol, and the
communication channel, as a plist.  It must return a string or
nil.")


;;;; Elements Filters

(defvar org-export-filter-center-block-functions nil
  "List of functions applied to a transcoded center block.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-clock-functions nil
  "List of functions applied to a transcoded clock.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-drawer-functions nil
  "List of functions applied to a transcoded drawer.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-dynamic-block-functions nil
  "List of functions applied to a transcoded dynamic-block.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-headline-functions nil
  "List of functions applied to a transcoded headline.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-inlinetask-functions nil
  "List of functions applied to a transcoded inlinetask.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-plain-list-functions nil
  "List of functions applied to a transcoded plain-list.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-item-functions nil
  "List of functions applied to a transcoded item.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-comment-functions nil
  "List of functions applied to a transcoded comment.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-comment-block-functions nil
  "List of functions applied to a transcoded comment-comment.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-example-block-functions nil
  "List of functions applied to a transcoded example-block.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-export-block-functions nil
  "List of functions applied to a transcoded export-block.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-fixed-width-functions nil
  "List of functions applied to a transcoded fixed-width.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-footnote-definition-functions nil
  "List of functions applied to a transcoded footnote-definition.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-horizontal-rule-functions nil
  "List of functions applied to a transcoded horizontal-rule.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-keyword-functions nil
  "List of functions applied to a transcoded keyword.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-latex-environment-functions nil
  "List of functions applied to a transcoded latex-environment.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-babel-call-functions nil
  "List of functions applied to a transcoded babel-call.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-paragraph-functions nil
  "List of functions applied to a transcoded paragraph.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-planning-functions nil
  "List of functions applied to a transcoded planning.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-property-drawer-functions nil
  "List of functions applied to a transcoded property-drawer.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-quote-block-functions nil
  "List of functions applied to a transcoded quote block.
Each filter is called with three arguments: the transcoded quote
data, as a string, the back-end, as a symbol, and the
communication channel, as a plist.  It must return a string or
nil.")

(defvar org-export-filter-quote-section-functions nil
  "List of functions applied to a transcoded quote-section.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-section-functions nil
  "List of functions applied to a transcoded section.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-special-block-functions nil
  "List of functions applied to a transcoded special block.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-src-block-functions nil
  "List of functions applied to a transcoded src-block.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-table-functions nil
  "List of functions applied to a transcoded table.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-table-cell-functions nil
  "List of functions applied to a transcoded table-cell.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-table-row-functions nil
  "List of functions applied to a transcoded table-row.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-verse-block-functions nil
  "List of functions applied to a transcoded verse block.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")


;;;; Objects Filters

(defvar org-export-filter-bold-functions nil
  "List of functions applied to transcoded bold text.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-code-functions nil
  "List of functions applied to transcoded code text.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-entity-functions nil
  "List of functions applied to a transcoded entity.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-export-snippet-functions nil
  "List of functions applied to a transcoded export-snippet.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-footnote-reference-functions nil
  "List of functions applied to a transcoded footnote-reference.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-inline-babel-call-functions nil
  "List of functions applied to a transcoded inline-babel-call.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-inline-src-block-functions nil
  "List of functions applied to a transcoded inline-src-block.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-italic-functions nil
  "List of functions applied to transcoded italic text.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-latex-fragment-functions nil
  "List of functions applied to a transcoded latex-fragment.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-line-break-functions nil
  "List of functions applied to a transcoded line-break.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-link-functions nil
  "List of functions applied to a transcoded link.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-macro-functions nil
  "List of functions applied to a transcoded macro.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-radio-target-functions nil
  "List of functions applied to a transcoded radio-target.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-statistics-cookie-functions nil
  "List of functions applied to a transcoded statistics-cookie.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-strike-through-functions nil
  "List of functions applied to transcoded strike-through text.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-subscript-functions nil
  "List of functions applied to a transcoded subscript.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-superscript-functions nil
  "List of functions applied to a transcoded superscript.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-target-functions nil
  "List of functions applied to a transcoded target.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-timestamp-functions nil
  "List of functions applied to a transcoded timestamp.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-underline-functions nil
  "List of functions applied to transcoded underline text.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")

(defvar org-export-filter-verbatim-functions nil
  "List of functions applied to transcoded verbatim text.
Each filter is called with three arguments: the transcoded data,
as a string, the back-end, as a symbol, and the communication
channel, as a plist.  It must return a string or nil.")


;;;; Filters Tools
;;
;; Internal function `org-export-install-filters' installs filters
;; hard-coded in back-ends (developer filters) and filters from global
;; variables (user filters) in the communication channel.
;;
;; Internal function `org-export-filter-apply-functions' takes care
;; about applying each filter in order to a given data.  It ignores
;; filters returning a nil value but stops whenever a filter returns
;; an empty string.

(defun org-export-filter-apply-functions (filters value info)
  "Call every function in FILTERS.

Functions are called with arguments VALUE, current export
back-end and INFO.  A function returning a nil value will be
skipped.  If it returns the empty string, the process ends and
VALUE is ignored.

Call is done in a LIFO fashion, to be sure that developer
specified filters, if any, are called first."
  (catch 'exit
    (dolist (filter filters value)
      (let ((result (funcall filter value (plist-get info :back-end) info)))
	(cond ((not value))
	      ((equal value "") (throw 'exit nil))
	      (t (setq value result)))))))

(defun org-export-install-filters (info)
  "Install filters properties in communication channel.

INFO is a plist containing the current communication channel.

Return the updated communication channel."
  (let (plist)
    ;; Install user defined filters with `org-export-filters-alist'.
    (mapc (lambda (p)
	    (setq plist (plist-put plist (car p) (eval (cdr p)))))
	  org-export-filters-alist)
    ;; Prepend back-end specific filters to that list.
    (let ((back-end-filters (intern (format "org-%s-filters-alist"
					    (plist-get info :back-end)))))
      (when (boundp back-end-filters)
	(mapc (lambda (p)
		;; Single values get consed, lists are prepended.
		(let ((key (car p)) (value (cdr p)))
		  (when value
		    (setq plist
			  (plist-put
			   plist key
			   (if (atom value) (cons value (plist-get plist key))
			     (append value (plist-get plist key))))))))
	      (eval back-end-filters))))
    ;; Return new communication channel.
    (org-combine-plists info plist)))



;;; Core functions
;;
;; This is the room for the main function, `org-export-as', along with
;; its derivatives, `org-export-to-buffer' and `org-export-to-file'.
;; They differ only by the way they output the resulting code.
;;
;; `org-export-output-file-name' is an auxiliary function meant to be
;; used with `org-export-to-file'.  With a given extension, it tries
;; to provide a canonical file name to write export output to.
;;
;; Note that `org-export-as' doesn't really parse the current buffer,
;; but a copy of it (with the same buffer-local variables and
;; visibility), where include keywords are expanded and Babel blocks
;; are executed, if appropriate.
;; `org-export-with-current-buffer-copy' macro prepares that copy.
;;
;; File inclusion is taken care of by
;; `org-export-expand-include-keyword' and
;; `org-export--prepare-file-contents'.  Structure wise, including
;; a whole Org file in a buffer often makes little sense.  For
;; example, if the file contains an headline and the include keyword
;; was within an item, the item should contain the headline.  That's
;; why file inclusion should be done before any structure can be
;; associated to the file, that is before parsing.

(defun org-export-as
  (backend &optional subtreep visible-only body-only ext-plist noexpand)
  "Transcode current Org buffer into BACKEND code.

If narrowing is active in the current buffer, only transcode its
narrowed part.

If a region is active, transcode that region.

When optional argument SUBTREEP is non-nil, transcode the
sub-tree at point, extracting information from the headline
properties first.

When optional argument VISIBLE-ONLY is non-nil, don't export
contents of hidden elements.

When optional argument BODY-ONLY is non-nil, only return body
code, without preamble nor postamble.

Optional argument EXT-PLIST, when provided, is a property list
with external parameters overriding Org default settings, but
still inferior to file-local settings.

Optional argument NOEXPAND, when non-nil, prevents included files
to be expanded and Babel code to be executed.

Return code as a string."
  (save-excursion
    (save-restriction
      ;; Narrow buffer to an appropriate region or subtree for
      ;; parsing.  If parsing subtree, be sure to remove main headline
      ;; too.
      (cond ((org-region-active-p)
	     (narrow-to-region (region-beginning) (region-end)))
	    (subtreep
	     (org-narrow-to-subtree)
	     (goto-char (point-min))
	     (forward-line)
	     (narrow-to-region (point) (point-max))))
      ;; 1. Get export environment from original buffer.  Also install
      ;;    user's and developer's filters.
      (let ((info (org-export-install-filters
		   (org-export-get-environment backend subtreep ext-plist)))
	    ;; 2. Get parse tree.  Buffer isn't parsed directly.
	    ;;    Instead, a temporary copy is created, where include
	    ;;    keywords are expanded and code blocks are evaluated.
	    (tree (let ((buf (or (buffer-file-name (buffer-base-buffer))
				 (current-buffer))))
		    (org-export-with-current-buffer-copy
		     (unless noexpand
		       (org-export-expand-include-keyword)
		       ;; TODO: Setting `org-current-export-file' is
		       ;; required by Org Babel to properly resolve
		       ;; noweb references.  Once "org-exp.el" is
		       ;; removed, modify
		       ;; `org-export-blocks-preprocess' so it accepts
		       ;; the value as an argument instead.
		       (let ((org-current-export-file buf))
			 (org-export-blocks-preprocess)))
		     (goto-char (point-min))
		     ;; Run hook
		     ;; `org-export-before-parsing-hook'. with current
		     ;; back-end as argument.
		     (run-hook-with-args
		      'org-export-before-parsing-hook backend)
		     ;; Eventually parse buffer.
		     (org-element-parse-buffer nil visible-only)))))
	;; 3. Call parse-tree filters to get the final tree.
	(setq tree
	      (org-export-filter-apply-functions
	       (plist-get info :filter-parse-tree) tree info))
	;; 4. Now tree is complete, compute its properties and add
	;;    them to communication channel.
	(setq info
	      (org-combine-plists
	       info (org-export-collect-tree-properties tree info)))
	;; 5. Eventually transcode TREE.  Wrap the resulting string
	;;    into a template, if required.  Eventually call
	;;    final-output filter.
	(let* ((body (org-element-normalize-string (org-export-data tree info)))
	       (template (cdr (assq 'template
				    (plist-get info :translate-alist))))
	       (output (org-export-filter-apply-functions
			(plist-get info :filter-final-output)
			(if (or (not (functionp template)) body-only) body
			  (funcall template body info))
			info)))
	  ;; Maybe add final OUTPUT to kill ring, then return it.
	  (when org-export-copy-to-kill-ring (org-kill-new output))
	  output)))))

(defun org-export-to-buffer
  (backend buffer &optional subtreep visible-only body-only ext-plist noexpand)
  "Call `org-export-as' with output to a specified buffer.

BACKEND is the back-end used for transcoding, as a symbol.

BUFFER is the output buffer.  If it already exists, it will be
erased first, otherwise, it will be created.

Optional arguments SUBTREEP, VISIBLE-ONLY, BODY-ONLY, EXT-PLIST
and NOEXPAND are similar to those used in `org-export-as', which
see.

Return buffer."
  (let ((out (org-export-as
	      backend subtreep visible-only body-only ext-plist noexpand))
	(buffer (get-buffer-create buffer)))
    (with-current-buffer buffer
      (erase-buffer)
      (insert out)
      (goto-char (point-min)))
    buffer))

(defun org-export-to-file
  (backend file &optional subtreep visible-only body-only ext-plist noexpand)
  "Call `org-export-as' with output to a specified file.

BACKEND is the back-end used for transcoding, as a symbol.  FILE
is the name of the output file, as a string.

Optional arguments SUBTREEP, VISIBLE-ONLY, BODY-ONLY, EXT-PLIST
and NOEXPAND are similar to those used in `org-export-as', which
see.

Return output file's name."
  ;; Checks for FILE permissions.  `write-file' would do the same, but
  ;; we'd rather avoid needless transcoding of parse tree.
  (unless (file-writable-p file) (error "Output file not writable"))
  ;; Insert contents to a temporary buffer and write it to FILE.
  (let ((out (org-export-as
	      backend subtreep visible-only body-only ext-plist noexpand)))
    (with-temp-buffer
      (insert out)
      (let ((coding-system-for-write org-export-coding-system))
	(write-file file))))
  ;; Return full path.
  file)

(defun org-export-output-file-name (extension &optional subtreep pub-dir)
  "Return output file's name according to buffer specifications.

EXTENSION is a string representing the output file extension,
with the leading dot.

With a non-nil optional argument SUBTREEP, try to determine
output file's name by looking for \"EXPORT_FILE_NAME\" property
of subtree at point.

When optional argument PUB-DIR is set, use it as the publishing
directory.

When optional argument VISIBLE-ONLY is non-nil, don't export
contents of hidden elements.

Return file name as a string, or nil if it couldn't be
determined."
  (let ((base-name
	 ;; File name may come from EXPORT_FILE_NAME subtree property,
	 ;; assuming point is at beginning of said sub-tree.
	 (file-name-sans-extension
	  (or (and subtreep
		   (org-entry-get
		    (save-excursion
		      (ignore-errors (org-back-to-heading) (point)))
		    "EXPORT_FILE_NAME" t))
	      ;; File name may be extracted from buffer's associated
	      ;; file, if any.
	      (buffer-file-name (buffer-base-buffer))
	      ;; Can't determine file name on our own: Ask user.
	      (let ((read-file-name-function
		     (and org-completion-use-ido 'ido-read-file-name)))
		(read-file-name
		 "Output file: " pub-dir nil nil nil
		 (lambda (name)
		   (string= (file-name-extension name t) extension))))))))
    ;; Build file name. Enforce EXTENSION over whatever user may have
    ;; come up with. PUB-DIR, if defined, always has precedence over
    ;; any provided path.
    (cond
     (pub-dir
      (concat (file-name-as-directory pub-dir)
	      (file-name-nondirectory base-name)
	      extension))
     ((string= (file-name-nondirectory base-name) base-name)
      (concat (file-name-as-directory ".") base-name extension))
     (t (concat base-name extension)))))

(defmacro org-export-with-current-buffer-copy (&rest body)
  "Apply BODY in a copy of the current buffer.

The copy preserves local variables and visibility of the original
buffer.

Point is at buffer's beginning when BODY is applied."
  (org-with-gensyms (original-buffer offset buffer-string overlays)
    `(let ((,original-buffer (current-buffer))
	   (,offset (1- (point-min)))
	   (,buffer-string (buffer-string))
	   (,overlays (mapcar
		       'copy-overlay (overlays-in (point-min) (point-max)))))
       (with-temp-buffer
	 (let ((buffer-invisibility-spec nil))
	   (org-clone-local-variables
	    ,original-buffer
	    "^\\(org-\\|orgtbl-\\|major-mode$\\|outline-\\(regexp\\|level\\)$\\)")
	   (insert ,buffer-string)
	   (mapc (lambda (ov)
		   (move-overlay
		    ov
		    (- (overlay-start ov) ,offset)
		    (- (overlay-end ov) ,offset)
		    (current-buffer)))
		 ,overlays)
	   (goto-char (point-min))
	   (progn ,@body))))))
(def-edebug-spec org-export-with-current-buffer-copy (body))

(defun org-export-expand-include-keyword (&optional included dir)
  "Expand every include keyword in buffer.
Optional argument INCLUDED is a list of included file names along
with their line restriction, when appropriate.  It is used to
avoid infinite recursion.  Optional argument DIR is the current
working directory.  It is used to properly resolve relative
paths."
  (let ((case-fold-search t))
    (goto-char (point-min))
    (while (re-search-forward "^[ \t]*#\\+INCLUDE: \\(.*\\)" nil t)
      (when (eq (org-element-type (save-match-data (org-element-at-point)))
		'keyword)
	(beginning-of-line)
	;; Extract arguments from keyword's value.
	(let* ((value (match-string 1))
	       (ind (org-get-indentation))
	       (file (and (string-match "^\"\\(\\S-+\\)\"" value)
			  (prog1 (expand-file-name (match-string 1 value) dir)
			    (setq value (replace-match "" nil nil value)))))
	       (lines
		(and (string-match
		      ":lines +\"\\(\\(?:[0-9]+\\)?-\\(?:[0-9]+\\)?\\)\"" value)
		     (prog1 (match-string 1 value)
		       (setq value (replace-match "" nil nil value)))))
	       (env (cond ((string-match "\\<example\\>" value) 'example)
			  ((string-match "\\<src\\(?: +\\(.*\\)\\)?" value)
			   (match-string 1 value))))
	       ;; Minimal level of included file defaults to the child
	       ;; level of the current headline, if any, or one.  It
	       ;; only applies is the file is meant to be included as
	       ;; an Org one.
	       (minlevel
		(and (not env)
		     (if (string-match ":minlevel +\\([0-9]+\\)" value)
			 (prog1 (string-to-number (match-string 1 value))
			   (setq value (replace-match "" nil nil value)))
		       (let ((cur (org-current-level)))
			 (if cur (1+ (org-reduced-level cur)) 1))))))
	  ;; Remove keyword.
	  (delete-region (point) (progn (forward-line) (point)))
	  (cond
	   ((not (file-readable-p file)) (error "Cannot include file %s" file))
	   ;; Check if files has already been parsed.  Look after
	   ;; inclusion lines too, as different parts of the same file
	   ;; can be included too.
	   ((member (list file lines) included)
	    (error "Recursive file inclusion: %s" file))
	   (t
	    (cond
	     ((eq env 'example)
	      (insert
	       (let ((ind-str (make-string ind ? ))
		     (contents
		      ;; Protect sensitive contents with commas.
		      (replace-regexp-in-string
		       "\\(^\\)\\([*]\\|[ \t]*#\\+\\)" ","
		       (org-export--prepare-file-contents file lines)
		       nil nil 1)))
		 (format "%s#+BEGIN_EXAMPLE\n%s%s#+END_EXAMPLE\n"
			 ind-str contents ind-str))))
	     ((stringp env)
	      (insert
	       (let ((ind-str (make-string ind ? ))
		     (contents
		      ;; Protect sensitive contents with commas.
		      (replace-regexp-in-string
		       (if (string= env "org") "\\(^\\)\\(.\\)"
			 "\\(^\\)\\([*]\\|[ \t]*#\\+\\)") ","
		       (org-export--prepare-file-contents file lines)
		       nil nil 1)))
		 (format "%s#+BEGIN_SRC %s\n%s%s#+END_SRC\n"
			 ind-str env contents ind-str))))
	     (t
	      (insert
	       (with-temp-buffer
		 (org-mode)
		 (insert
		  (org-export--prepare-file-contents file lines ind minlevel))
		 (org-export-expand-include-keyword
		  (cons (list file lines) included)
		  (file-name-directory file))
		 (buffer-string))))))))))))

(defun org-export--prepare-file-contents (file &optional lines ind minlevel)
  "Prepare the contents of FILE for inclusion and return them as a string.

When optional argument LINES is a string specifying a range of
lines, include only those lines.

Optional argument IND, when non-nil, is an integer specifying the
global indentation of returned contents.  Since its purpose is to
allow an included file to stay in the same environment it was
created \(i.e. a list item), it doesn't apply past the first
headline encountered.

Optional argument MINLEVEL, when non-nil, is an integer
specifying the level that any top-level headline in the included
file should have."
  (with-temp-buffer
    (insert-file-contents file)
    (when lines
      (let* ((lines (split-string lines "-"))
	     (lbeg (string-to-number (car lines)))
	     (lend (string-to-number (cadr lines)))
	     (beg (if (zerop lbeg) (point-min)
		    (goto-char (point-min))
		    (forward-line (1- lbeg))
		    (point)))
	     (end (if (zerop lend) (point-max)
		    (goto-char (point-min))
		    (forward-line (1- lend))
		    (point))))
	(narrow-to-region beg end)))
    ;; Remove blank lines at beginning and end of contents.  The logic
    ;; behind that removal is that blank lines around include keyword
    ;; override blank lines in included file.
    (goto-char (point-min))
    (org-skip-whitespace)
    (beginning-of-line)
    (delete-region (point-min) (point))
    (goto-char (point-max))
    (skip-chars-backward " \r\t\n")
    (forward-line)
    (delete-region (point) (point-max))
    ;; If IND is set, preserve indentation of include keyword until
    ;; the first headline encountered.
    (when ind
      (unless (eq major-mode 'org-mode) (org-mode))
      (goto-char (point-min))
      (let ((ind-str (make-string ind ? )))
	(while (not (or (eobp) (looking-at org-outline-regexp-bol)))
	  ;; Do not move footnote definitions out of column 0.
	  (unless (and (looking-at org-footnote-definition-re)
		       (eq (org-element-type (org-element-at-point))
			   'footnote-definition))
	    (insert ind-str))
	  (forward-line))))
    ;; When MINLEVEL is specified, compute minimal level for headlines
    ;; in the file (CUR-MIN), and remove stars to each headline so
    ;; that headlines with minimal level have a level of MINLEVEL.
    (when minlevel
      (unless (eq major-mode 'org-mode) (org-mode))
      (let ((levels (org-map-entries
		     (lambda () (org-reduced-level (org-current-level))))))
	(when levels
	  (let ((offset (- minlevel (apply 'min levels))))
	    (unless (zerop offset)
	      (when org-odd-levels-only (setq offset (* offset 2)))
	      ;; Only change stars, don't bother moving whole
	      ;; sections.
	      (org-map-entries
	       (lambda () (if (< offset 0) (delete-char (abs offset))
			    (insert (make-string offset ?*))))))))))
    (buffer-string)))


;;; Tools For Back-Ends
;;
;; A whole set of tools is available to help build new exporters.  Any
;; function general enough to have its use across many back-ends
;; should be added here.
;;
;; As of now, functions operating on footnotes, headlines, links,
;; macros, references, src-blocks, tables and tables of contents are
;; implemented.

;;;; For Affiliated Keywords
;;
;; `org-export-read-attribute' reads a property from a given element
;;  as a plist.  It can be used to normalize affiliated keywords'
;;  syntax.

(defun org-export-read-attribute (attribute element &optional property)
  "Turn ATTRIBUTE property from ELEMENT into a plist.

When optional argument PROPERTY is non-nil, return the value of
that property within attributes.

This function assumes attributes are defined as \":keyword
value\" pairs.  It is appropriate for `:attr_html' like
properties."
  (let ((attributes
	 (let ((value (org-element-property attribute element)))
	   (and value
		(read (format "(%s)" (mapconcat 'identity value " ")))))))
    (if property (plist-get attributes property) attributes)))


;;;; For Export Snippets
;;
;; Every export snippet is transmitted to the back-end.  Though, the
;; latter will only retain one type of export-snippet, ignoring
;; others, based on the former's target back-end.  The function
;; `org-export-snippet-backend' returns that back-end for a given
;; export-snippet.

(defun org-export-snippet-backend (export-snippet)
  "Return EXPORT-SNIPPET targeted back-end as a symbol.
Translation, with `org-export-snippet-translation-alist', is
applied."
  (let ((back-end (org-element-property :back-end export-snippet)))
    (intern
     (or (cdr (assoc back-end org-export-snippet-translation-alist))
	 back-end))))


;;;; For Footnotes
;;
;; `org-export-collect-footnote-definitions' is a tool to list
;; actually used footnotes definitions in the whole parse tree, or in
;; an headline, in order to add footnote listings throughout the
;; transcoded data.
;;
;; `org-export-footnote-first-reference-p' is a predicate used by some
;; back-ends, when they need to attach the footnote definition only to
;; the first occurrence of the corresponding label.
;;
;; `org-export-get-footnote-definition' and
;; `org-export-get-footnote-number' provide easier access to
;; additional information relative to a footnote reference.

(defun org-export-collect-footnote-definitions (data info)
  "Return an alist between footnote numbers, labels and definitions.

DATA is the parse tree from which definitions are collected.
INFO is the plist used as a communication channel.

Definitions are sorted by order of references.  They either
appear as Org data or as a secondary string for inlined
footnotes.  Unreferenced definitions are ignored."
  (let* (num-alist
	 collect-fn			; for byte-compiler.
	 (collect-fn
	  (function
	   (lambda (data)
	     ;; Collect footnote number, label and definition in DATA.
	     (org-element-map
	      data 'footnote-reference
	      (lambda (fn)
		(when (org-export-footnote-first-reference-p fn info)
		  (let ((def (org-export-get-footnote-definition fn info)))
		    (push
		     (list (org-export-get-footnote-number fn info)
			   (org-element-property :label fn)
			   def)
		     num-alist)
		    ;; Also search in definition for nested footnotes.
		    (when (eq (org-element-property :type fn) 'standard)
		      (funcall collect-fn def)))))
	      ;; Don't enter footnote definitions since it will happen
	      ;; when their first reference is found.
	      info nil 'footnote-definition)))))
    (funcall collect-fn (plist-get info :parse-tree))
    (reverse num-alist)))

(defun org-export-footnote-first-reference-p (footnote-reference info)
  "Non-nil when a footnote reference is the first one for its label.

FOOTNOTE-REFERENCE is the footnote reference being considered.
INFO is the plist used as a communication channel."
  (let ((label (org-element-property :label footnote-reference)))
    ;; Anonymous footnotes are always a first reference.
    (if (not label) t
      ;; Otherwise, return the first footnote with the same LABEL and
      ;; test if it is equal to FOOTNOTE-REFERENCE.
      (let* (search-refs		; for byte-compiler.
	     (search-refs
	      (function
	       (lambda (data)
		 (org-element-map
		  data 'footnote-reference
		  (lambda (fn)
		    (cond
		     ((string= (org-element-property :label fn) label)
		      (throw 'exit fn))
		     ;; If FN isn't inlined, be sure to traverse its
		     ;; definition before resuming search.  See
		     ;; comments in `org-export-get-footnote-number'
		     ;; for more information.
		     ((eq (org-element-property :type fn) 'standard)
		      (funcall search-refs
			       (org-export-get-footnote-definition fn info)))))
		  ;; Don't enter footnote definitions since it will
		  ;; happen when their first reference is found.
		  info 'first-match 'footnote-definition)))))
	(eq (catch 'exit (funcall search-refs (plist-get info :parse-tree)))
	       footnote-reference)))))

(defun org-export-get-footnote-definition (footnote-reference info)
  "Return definition of FOOTNOTE-REFERENCE as parsed data.
INFO is the plist used as a communication channel."
  (let ((label (org-element-property :label footnote-reference)))
    (or (org-element-property :inline-definition footnote-reference)
        (cdr (assoc label (plist-get info :footnote-definition-alist))))))

(defun org-export-get-footnote-number (footnote info)
  "Return number associated to a footnote.

FOOTNOTE is either a footnote reference or a footnote definition.
INFO is the plist used as a communication channel."
  (let* ((label (org-element-property :label footnote))
	 seen-refs
	 search-ref			; For byte-compiler.
	 (search-ref
	  (function
	   (lambda (data)
	     ;; Search footnote references through DATA, filling
	     ;; SEEN-REFS along the way.
	     (org-element-map
	      data 'footnote-reference
	      (lambda (fn)
		(let ((fn-lbl (org-element-property :label fn)))
		  (cond
		   ;; Anonymous footnote match: return number.
		   ((and (not fn-lbl) (eq fn footnote))
		    (throw 'exit (1+ (length seen-refs))))
		   ;; Labels match: return number.
		   ((and label (string= label fn-lbl))
		    (throw 'exit (1+ (length seen-refs))))
		   ;; Anonymous footnote: it's always a new one.  Also,
		   ;; be sure to return nil from the `cond' so
		   ;; `first-match' doesn't get us out of the loop.
		   ((not fn-lbl) (push 'inline seen-refs) nil)
		   ;; Label not seen so far: add it so SEEN-REFS.
		   ;;
		   ;; Also search for subsequent references in
		   ;; footnote definition so numbering follows reading
		   ;; logic.  Note that we don't have to care about
		   ;; inline definitions, since `org-element-map'
		   ;; already traverses them at the right time.
		   ;;
		   ;; Once again, return nil to stay in the loop.
		   ((not (member fn-lbl seen-refs))
		    (push fn-lbl seen-refs)
		    (funcall search-ref
			     (org-export-get-footnote-definition fn info))
		    nil))))
	      ;; Don't enter footnote definitions since it will happen
	      ;; when their first reference is found.
	      info 'first-match 'footnote-definition)))))
    (catch 'exit (funcall search-ref (plist-get info :parse-tree)))))


;;;; For Headlines
;;
;; `org-export-get-relative-level' is a shortcut to get headline
;; level, relatively to the lower headline level in the parsed tree.
;;
;; `org-export-get-headline-number' returns the section number of an
;; headline, while `org-export-number-to-roman' allows to convert it
;; to roman numbers.
;;
;; `org-export-low-level-p', `org-export-first-sibling-p' and
;; `org-export-last-sibling-p' are three useful predicates when it
;; comes to fulfill the `:headline-levels' property.

(defun org-export-get-relative-level (headline info)
  "Return HEADLINE relative level within current parsed tree.
INFO is a plist holding contextual information."
  (+ (org-element-property :level headline)
     (or (plist-get info :headline-offset) 0)))

(defun org-export-low-level-p (headline info)
  "Non-nil when HEADLINE is considered as low level.

INFO is a plist used as a communication channel.

A low level headlines has a relative level greater than
`:headline-levels' property value.

Return value is the difference between HEADLINE relative level
and the last level being considered as high enough, or nil."
  (let ((limit (plist-get info :headline-levels)))
    (when (wholenump limit)
      (let ((level (org-export-get-relative-level headline info)))
        (and (> level limit) (- level limit))))))

(defun org-export-get-headline-number (headline info)
  "Return HEADLINE numbering as a list of numbers.
INFO is a plist holding contextual information."
  (cdr (assoc headline (plist-get info :headline-numbering))))

(defun org-export-numbered-headline-p (headline info)
  "Return a non-nil value if HEADLINE element should be numbered.
INFO is a plist used as a communication channel."
  (let ((sec-num (plist-get info :section-numbers))
	(level (org-export-get-relative-level headline info)))
    (if (wholenump sec-num) (<= level sec-num) sec-num)))

(defun org-export-number-to-roman (n)
  "Convert integer N into a roman numeral."
  (let ((roman '((1000 . "M") (900 . "CM") (500 . "D") (400 . "CD")
		 ( 100 . "C") ( 90 . "XC") ( 50 . "L") ( 40 . "XL")
		 (  10 . "X") (  9 . "IX") (  5 . "V") (  4 . "IV")
		 (   1 . "I")))
	(res ""))
    (if (<= n 0)
	(number-to-string n)
      (while roman
	(if (>= n (caar roman))
	    (setq n (- n (caar roman))
		  res (concat res (cdar roman)))
	  (pop roman)))
      res)))

(defun org-export-get-tags (element info &optional tags)
  "Return list of tags associated to ELEMENT.

ELEMENT has either an `headline' or an `inlinetask' type.  INFO
is a plist used as a communication channel.

Select tags (see `org-export-select-tags') and exclude tags (see
`org-export-exclude-tags') are removed from the list.

When non-nil, optional argument TAGS should be a list of strings.
Any tag belonging to this list will also be removed."
  (org-remove-if (lambda (tag) (or (member tag (plist-get info :select-tags))
			      (member tag (plist-get info :exclude-tags))
			      (member tag tags)))
		 (org-element-property :tags element)))

(defun org-export-first-sibling-p (headline info)
  "Non-nil when HEADLINE is the first sibling in its sub-tree.
INFO is a plist used as a communication channel."
  (not (eq (org-element-type (org-export-get-previous-element headline info))
	   'headline)))

(defun org-export-last-sibling-p (headline info)
  "Non-nil when HEADLINE is the last sibling in its sub-tree.
INFO is a plist used as a communication channel."
  (not (org-export-get-next-element headline info)))


;;;; For Links
;;
;; `org-export-solidify-link-text' turns a string into a safer version
;; for links, replacing most non-standard characters with hyphens.
;;
;; `org-export-get-coderef-format' returns an appropriate format
;; string for coderefs.
;;
;; `org-export-inline-image-p' returns a non-nil value when the link
;; provided should be considered as an inline image.
;;
;; `org-export-resolve-fuzzy-link' searches destination of fuzzy links
;; (i.e. links with "fuzzy" as type) within the parsed tree, and
;; returns an appropriate unique identifier when found, or nil.
;;
;; `org-export-resolve-id-link' returns the first headline with
;; specified id or custom-id in parse tree, the path to the external
;; file with the id or nil when neither was found.
;;
;; `org-export-resolve-coderef' associates a reference to a line
;; number in the element it belongs, or returns the reference itself
;; when the element isn't numbered.

(defun org-export-solidify-link-text (s)
  "Take link text S and make a safe target out of it."
  (save-match-data
    (mapconcat 'identity (org-split-string s "[^a-zA-Z0-9_.-]+") "-")))

(defun org-export-get-coderef-format (path desc)
  "Return format string for code reference link.
PATH is the link path.  DESC is its description."
  (save-match-data
    (cond ((not desc) "%s")
	  ((string-match (regexp-quote (concat "(" path ")")) desc)
	   (replace-match "%s" t t desc))
	  (t desc))))

(defun org-export-inline-image-p (link &optional rules)
  "Non-nil if LINK object points to an inline image.

Optional argument is a set of RULES defining inline images.  It
is an alist where associations have the following shape:

  \(TYPE . REGEXP)

Applying a rule means apply REGEXP against LINK's path when its
type is TYPE.  The function will return a non-nil value if any of
the provided rules is non-nil.  The default rule is
`org-export-default-inline-image-rule'.

This only applies to links without a description."
  (and (not (org-element-contents link))
       (let ((case-fold-search t)
	     (rules (or rules org-export-default-inline-image-rule)))
	 (catch 'exit
	   (mapc
	    (lambda (rule)
	      (and (string= (org-element-property :type link) (car rule))
		   (string-match (cdr rule)
				 (org-element-property :path link))
		   (throw 'exit t)))
	    rules)
	   ;; Return nil if no rule matched.
	   nil))))

(defun org-export-resolve-coderef (ref info)
  "Resolve a code reference REF.

INFO is a plist used as a communication channel.

Return associated line number in source code, or REF itself,
depending on src-block or example element's switches."
  (org-element-map
   (plist-get info :parse-tree) '(example-block src-block)
   (lambda (el)
     (with-temp-buffer
       (insert (org-trim (org-element-property :value el)))
       (let* ((label-fmt (regexp-quote
			  (or (org-element-property :label-fmt el)
			      org-coderef-label-format)))
	      (ref-re
	       (format "^.*?\\S-.*?\\([ \t]*\\(%s\\)\\)[ \t]*$"
		       (replace-regexp-in-string "%s" ref label-fmt nil t))))
	 ;; Element containing REF is found.  Resolve it to either
	 ;; a label or a line number, as needed.
	 (when (re-search-backward ref-re nil t)
	   (cond
	    ((org-element-property :use-labels el) ref)
	    ((eq (org-element-property :number-lines el) 'continued)
	     (+ (org-export-get-loc el info) (line-number-at-pos)))
	    (t (line-number-at-pos)))))))
   info 'first-match))

(defun org-export-resolve-fuzzy-link (link info)
  "Return LINK destination.

INFO is a plist holding contextual information.

Return value can be an object, an element, or nil:

- If LINK path matches a target object (i.e. <<path>>) or
  element (i.e. \"#+TARGET: path\"), return it.

- If LINK path exactly matches the name affiliated keyword
  \(i.e. #+NAME: path) of an element, return that element.

- If LINK path exactly matches any headline name, return that
  element.  If more than one headline share that name, priority
  will be given to the one with the closest common ancestor, if
  any, or the first one in the parse tree otherwise.

- Otherwise, return nil.

Assume LINK type is \"fuzzy\"."
  (let* ((path (org-element-property :path link))
	 (match-title-p (eq (aref path 0) ?*)))
    (cond
     ;; First try to find a matching "<<path>>" unless user specified
     ;; he was looking for an headline (path starts with a *
     ;; character).
     ((and (not match-title-p)
	   (loop for target in (plist-get info :target-list)
		 when (string= (org-element-property :value target) path)
		 return target)))
     ;; Then try to find an element with a matching "#+NAME: path"
     ;; affiliated keyword.
     ((and (not match-title-p)
	   (org-element-map
	    (plist-get info :parse-tree) org-element-all-elements
	    (lambda (el)
              (when (string= (org-element-property :name el) path) el))
	    info 'first-match)))
     ;; Last case: link either points to an headline or to
     ;; nothingness.  Try to find the source, with priority given to
     ;; headlines with the closest common ancestor.  If such candidate
     ;; is found, return it, otherwise return nil.
     (t
      (let ((find-headline
	     (function
	      ;; Return first headline whose `:raw-value' property
	      ;; is NAME in parse tree DATA, or nil.
	      (lambda (name data)
		(org-element-map
		 data 'headline
		 (lambda (headline)
		   (when (string=
			  (org-element-property :raw-value headline)
			  name)
		     headline))
		 info 'first-match)))))
	;; Search among headlines sharing an ancestor with link,
	;; from closest to farthest.
	(or (catch 'exit
	      (mapc
	       (lambda (parent)
		 (when (eq (org-element-type parent) 'headline)
		   (let ((foundp (funcall find-headline path parent)))
		     (when foundp (throw 'exit foundp)))))
	       (org-export-get-genealogy link)) nil)
	    ;; No match with a common ancestor: try the full parse-tree.
	    (funcall find-headline
		     (if match-title-p (substring path 1) path)
		     (plist-get info :parse-tree))))))))

(defun org-export-resolve-id-link (link info)
  "Return headline referenced as LINK destination.

INFO is a plist used as a communication channel.

Return value can be the headline element matched in current parse
tree, a file name or nil.  Assume LINK type is either \"id\" or
\"custom-id\"."
  (let ((id (org-element-property :path link)))
    ;; First check if id is within the current parse tree.
    (or (org-element-map
	 (plist-get info :parse-tree) 'headline
	 (lambda (headline)
	   (when (or (string= (org-element-property :id headline) id)
		     (string= (org-element-property :custom-id headline) id))
	     headline))
	 info 'first-match)
	;; Otherwise, look for external files.
	(cdr (assoc id (plist-get info :id-alist))))))

(defun org-export-resolve-radio-link (link info)
  "Return radio-target object referenced as LINK destination.

INFO is a plist used as a communication channel.

Return value can be a radio-target object or nil.  Assume LINK
has type \"radio\"."
  (let ((path (org-element-property :path link)))
    (org-element-map
     (plist-get info :parse-tree) 'radio-target
     (lambda (radio)
       (when (equal (org-element-property :value radio) path) radio))
     info 'first-match)))


;;;; For Macros
;;
;; `org-export-expand-macro' simply takes care of expanding macros.

(defun org-export-expand-macro (macro info)
  "Expand MACRO and return it as a string.
INFO is a plist holding export options."
  (let* ((key (org-element-property :key macro))
	 (args (org-element-property :args macro))
	 ;; User's macros are stored in the communication channel with
	 ;; a ":macro-" prefix.  Replace arguments in VALUE.  Also
	 ;; expand recursively macros within.
	 (value (org-export-data
		 (mapcar
		  (lambda (obj)
		    (if (not (stringp obj)) (org-export-data obj info)
		      (replace-regexp-in-string
		       "\\$[0-9]+"
		       (lambda (arg)
			 (nth (1- (string-to-number (substring arg 1))) args))
		       obj)))
		  (plist-get info (intern (format ":macro-%s" key))))
		 info)))
    ;; VALUE starts with "(eval": it is a s-exp, `eval' it.
    (when (string-match "\\`(eval\\>" value) (setq value (eval (read value))))
    ;; Return string.
    (format "%s" (or value ""))))


;;;; For References
;;
;; `org-export-get-ordinal' associates a sequence number to any object
;; or element.

(defun org-export-get-ordinal (element info &optional types predicate)
  "Return ordinal number of an element or object.

ELEMENT is the element or object considered.  INFO is the plist
used as a communication channel.

Optional argument TYPES, when non-nil, is a list of element or
object types, as symbols, that should also be counted in.
Otherwise, only provided element's type is considered.

Optional argument PREDICATE is a function returning a non-nil
value if the current element or object should be counted in.  It
accepts two arguments: the element or object being considered and
the plist used as a communication channel.  This allows to count
only a certain type of objects (i.e. inline images).

Return value is a list of numbers if ELEMENT is an headline or an
item.  It is nil for keywords.  It represents the footnote number
for footnote definitions and footnote references.  If ELEMENT is
a target, return the same value as if ELEMENT was the closest
table, item or headline containing the target.  In any other
case, return the sequence number of ELEMENT among elements or
objects of the same type."
  ;; A target keyword, representing an invisible target, never has
  ;; a sequence number.
  (unless (eq (org-element-type element) 'keyword)
    ;; Ordinal of a target object refer to the ordinal of the closest
    ;; table, item, or headline containing the object.
    (when (eq (org-element-type element) 'target)
      (setq element
	    (loop for parent in (org-export-get-genealogy element)
		  when
		  (memq
		   (org-element-type parent)
		   '(footnote-definition footnote-reference headline item
                                         table))
		  return parent)))
    (case (org-element-type element)
      ;; Special case 1: An headline returns its number as a list.
      (headline (org-export-get-headline-number element info))
      ;; Special case 2: An item returns its number as a list.
      (item (let ((struct (org-element-property :structure element)))
	      (org-list-get-item-number
	       (org-element-property :begin element)
	       struct
	       (org-list-prevs-alist struct)
	       (org-list-parents-alist struct))))
      ((footnote-definition footnote-reference)
       (org-export-get-footnote-number element info))
      (otherwise
       (let ((counter 0))
	 ;; Increment counter until ELEMENT is found again.
	 (org-element-map
	  (plist-get info :parse-tree) (or types (org-element-type element))
	  (lambda (el)
	    (cond
	     ((eq element el) (1+ counter))
	     ((not predicate) (incf counter) nil)
	     ((funcall predicate el info) (incf counter) nil)))
	  info 'first-match))))))


;;;; For Src-Blocks
;;
;; `org-export-get-loc' counts number of code lines accumulated in
;; src-block or example-block elements with a "+n" switch until
;; a given element, excluded.  Note: "-n" switches reset that count.
;;
;; `org-export-unravel-code' extracts source code (along with a code
;; references alist) from an `element-block' or `src-block' type
;; element.
;;
;; `org-export-format-code' applies a formatting function to each line
;; of code, providing relative line number and code reference when
;; appropriate.  Since it doesn't access the original element from
;; which the source code is coming, it expects from the code calling
;; it to know if lines should be numbered and if code references
;; should appear.
;;
;; Eventually, `org-export-format-code-default' is a higher-level
;; function (it makes use of the two previous functions) which handles
;; line numbering and code references inclusion, and returns source
;; code in a format suitable for plain text or verbatim output.

(defun org-export-get-loc (element info)
  "Return accumulated lines of code up to ELEMENT.

INFO is the plist used as a communication channel.

ELEMENT is excluded from count."
  (let ((loc 0))
    (org-element-map
     (plist-get info :parse-tree)
     `(src-block example-block ,(org-element-type element))
     (lambda (el)
       (cond
        ;; ELEMENT is reached: Quit the loop.
        ((eq el element))
        ;; Only count lines from src-block and example-block elements
        ;; with a "+n" or "-n" switch.  A "-n" switch resets counter.
        ((not (memq (org-element-type el) '(src-block example-block))) nil)
        ((let ((linums (org-element-property :number-lines el)))
	   (when linums
	     ;; Accumulate locs or reset them.
	     (let ((lines (org-count-lines
			   (org-trim (org-element-property :value el)))))
	       (setq loc (if (eq linums 'new) lines (+ loc lines))))))
	 ;; Return nil to stay in the loop.
         nil)))
     info 'first-match)
    ;; Return value.
    loc))

(defun org-export-unravel-code (element)
  "Clean source code and extract references out of it.

ELEMENT has either a `src-block' an `example-block' type.

Return a cons cell whose CAR is the source code, cleaned from any
reference and protective comma and CDR is an alist between
relative line number (integer) and name of code reference on that
line (string)."
  (let* ((line 0) refs
	 ;; Get code and clean it.  Remove blank lines at its
	 ;; beginning and end.
	 (code (let ((c (replace-regexp-in-string
			 "\\`\\([ \t]*\n\\)+" ""
			 (replace-regexp-in-string
			  "\\(:?[ \t]*\n\\)*[ \t]*\\'" "\n"
			  (org-element-property :value element)))))
		 ;; If appropriate, remove global indentation.
		 (if (or org-src-preserve-indentation
			 (org-element-property :preserve-indent element))
		     c
		   (org-remove-indentation c))))
	 ;; Get format used for references.
	 (label-fmt (regexp-quote
		     (or (org-element-property :label-fmt element)
			 org-coderef-label-format)))
	 ;; Build a regexp matching a loc with a reference.
	 (with-ref-re
	  (format "^.*?\\S-.*?\\([ \t]*\\(%s\\)[ \t]*\\)$"
		  (replace-regexp-in-string
		   "%s" "\\([-a-zA-Z0-9_ ]+\\)" label-fmt nil t))))
    ;; Return value.
    (cons
     ;; Code with references removed.
     (org-element-normalize-string
      (mapconcat
       (lambda (loc)
	 (incf line)
	 (if (not (string-match with-ref-re loc)) loc
	   ;; Ref line: remove ref, and signal its position in REFS.
	   (push (cons line (match-string 3 loc)) refs)
	   (replace-match "" nil nil loc 1)))
       (org-split-string code "\n") "\n"))
     ;; Reference alist.
     refs)))

(defun org-export-format-code (code fun &optional num-lines ref-alist)
  "Format CODE by applying FUN line-wise and return it.

CODE is a string representing the code to format.  FUN is
a function.  It must accept three arguments: a line of
code (string), the current line number (integer) or nil and the
reference associated to the current line (string) or nil.

Optional argument NUM-LINES can be an integer representing the
number of code lines accumulated until the current code.  Line
numbers passed to FUN will take it into account.  If it is nil,
FUN's second argument will always be nil.  This number can be
obtained with `org-export-get-loc' function.

Optional argument REF-ALIST can be an alist between relative line
number (i.e. ignoring NUM-LINES) and the name of the code
reference on it.  If it is nil, FUN's third argument will always
be nil.  It can be obtained through the use of
`org-export-unravel-code' function."
  (let ((--locs (org-split-string code "\n"))
	(--line 0))
    (org-element-normalize-string
     (mapconcat
      (lambda (--loc)
	(incf --line)
	(let ((--ref (cdr (assq --line ref-alist))))
	  (funcall fun --loc (and num-lines (+ num-lines --line)) --ref)))
      --locs "\n"))))

(defun org-export-format-code-default (element info)
  "Return source code from ELEMENT, formatted in a standard way.

ELEMENT is either a `src-block' or `example-block' element.  INFO
is a plist used as a communication channel.

This function takes care of line numbering and code references
inclusion.  Line numbers, when applicable, appear at the
beginning of the line, separated from the code by two white
spaces.  Code references, on the other hand, appear flushed to
the right, separated by six white spaces from the widest line of
code."
  ;; Extract code and references.
  (let* ((code-info (org-export-unravel-code element))
         (code (car code-info))
         (code-lines (org-split-string code "\n"))
	 (refs (and (org-element-property :retain-labels element)
		    (cdr code-info)))
         ;; Handle line numbering.
         (num-start (case (org-element-property :number-lines element)
                      (continued (org-export-get-loc element info))
                      (new 0)))
         (num-fmt
          (and num-start
               (format "%%%ds  "
                       (length (number-to-string
                                (+ (length code-lines) num-start))))))
         ;; Prepare references display, if required.  Any reference
         ;; should start six columns after the widest line of code,
         ;; wrapped with parenthesis.
	 (max-width
	  (+ (apply 'max (mapcar 'length code-lines))
	     (if (not num-start) 0 (length (format num-fmt num-start))))))
    (org-export-format-code
     code
     (lambda (loc line-num ref)
       (let ((number-str (and num-fmt (format num-fmt line-num))))
         (concat
          number-str
          loc
          (and ref
               (concat (make-string
                        (- (+ 6 max-width)
                           (+ (length loc) (length number-str))) ? )
                       (format "(%s)" ref))))))
     num-start refs)))


;;;; For Tables
;;
;; `org-export-table-has-special-column-p' and and
;; `org-export-table-row-is-special-p' are predicates used to look for
;; meta-information about the table structure.
;;
;; `org-table-has-header-p' tells when the rows before the first rule
;;  should be considered as table's header.
;;
;; `org-export-table-cell-width', `org-export-table-cell-alignment'
;; and `org-export-table-cell-borders' extract information from
;; a table-cell element.
;;
;; `org-export-table-dimensions' gives the number on rows and columns
;; in the table, ignoring horizontal rules and special columns.
;; `org-export-table-cell-address', given a table-cell object, returns
;; the absolute address of a cell. On the other hand,
;; `org-export-get-table-cell-at' does the contrary.
;;
;; `org-export-table-cell-starts-colgroup-p',
;; `org-export-table-cell-ends-colgroup-p',
;; `org-export-table-row-starts-rowgroup-p',
;; `org-export-table-row-ends-rowgroup-p',
;; `org-export-table-row-starts-header-p' and
;; `org-export-table-row-ends-header-p' indicate position of current
;; row or cell within the table.

(defun org-export-table-has-special-column-p (table)
  "Non-nil when TABLE has a special column.
All special columns will be ignored during export."
  ;; The table has a special column when every first cell of every row
  ;; has an empty value or contains a symbol among "/", "#", "!", "$",
  ;; "*" "_" and "^".  Though, do not consider a first row containing
  ;; only empty cells as special.
  (let ((special-column-p 'empty))
    (catch 'exit
      (mapc
       (lambda (row)
	 (when (eq (org-element-property :type row) 'standard)
	   (let ((value (org-element-contents
			 (car (org-element-contents row)))))
	     (cond ((member value '(("/") ("#") ("!") ("$") ("*") ("_") ("^")))
		    (setq special-column-p 'special))
		   ((not value))
		   (t (throw 'exit nil))))))
       (org-element-contents table))
      (eq special-column-p 'special))))

(defun org-export-table-has-header-p (table info)
  "Non-nil when TABLE has an header.

INFO is a plist used as a communication channel.

A table has an header when it contains at least two row groups."
  (let ((rowgroup 1) row-flag)
    (org-element-map
     table 'table-row
     (lambda (row)
       (cond
	((> rowgroup 1) t)
	((and row-flag (eq (org-element-property :type row) 'rule))
	 (incf rowgroup) (setq row-flag nil))
	((and (not row-flag) (eq (org-element-property :type row) 'standard))
	 (setq row-flag t) nil)))
     info)))

(defun org-export-table-row-is-special-p (table-row info)
  "Non-nil if TABLE-ROW is considered special.

INFO is a plist used as the communication channel.

All special rows will be ignored during export."
  (when (eq (org-element-property :type table-row) 'standard)
    (let ((first-cell (org-element-contents
		       (car (org-element-contents table-row)))))
      ;; A row is special either when...
      (or
       ;; ... it starts with a field only containing "/",
       (equal first-cell '("/"))
       ;; ... the table contains a special column and the row start
       ;; with a marking character among, "^", "_", "$" or "!",
       (and (org-export-table-has-special-column-p
	     (org-export-get-parent table-row))
	    (member first-cell '(("^") ("_") ("$") ("!"))))
       ;; ... it contains only alignment cookies and empty cells.
       (let ((special-row-p 'empty))
	 (catch 'exit
	   (mapc
	    (lambda (cell)
	      (let ((value (org-element-contents cell)))
		;; Since VALUE is a secondary string, the following
		;; checks avoid expanding it with `org-export-data'.
		(cond ((not value))
		      ((and (not (cdr value))
			    (stringp (car value))
			    (string-match "\\`<[lrc]?\\([0-9]+\\)?>\\'"
					  (car value)))
		       (setq special-row-p 'cookie))
		      (t (throw 'exit nil)))))
	    (org-element-contents table-row))
	   (eq special-row-p 'cookie)))))))

(defun org-export-table-row-group (table-row info)
  "Return TABLE-ROW's group.

INFO is a plist used as the communication channel.

Return value is the group number, as an integer, or nil special
rows and table rules.  Group 1 is also table's header."
  (unless (or (eq (org-element-property :type table-row) 'rule)
	      (org-export-table-row-is-special-p table-row info))
    (let ((group 0) row-flag)
      (catch 'found
	(mapc
	 (lambda (row)
	   (cond
	    ((and (eq (org-element-property :type row) 'standard)
		  (not (org-export-table-row-is-special-p row info)))
	     (unless row-flag (incf group) (setq row-flag t)))
	    ((eq (org-element-property :type row) 'rule)
	     (setq row-flag nil)))
	   (when (eq table-row row) (throw 'found group)))
	 (org-element-contents (org-export-get-parent table-row)))))))

(defun org-export-table-cell-width (table-cell info)
  "Return TABLE-CELL contents width.

INFO is a plist used as the communication channel.

Return value is the width given by the last width cookie in the
same column as TABLE-CELL, or nil."
  (let* ((row (org-export-get-parent table-cell))
	 (column (let ((cells (org-element-contents row)))
		   (- (length cells) (length (memq table-cell cells)))))
	 (table (org-export-get-parent-table table-cell))
	 cookie-width)
    (mapc
     (lambda (row)
       (cond
	;; In a special row, try to find a width cookie at COLUMN.
	((org-export-table-row-is-special-p row info)
	 (let ((value (org-element-contents
		       (elt (org-element-contents row) column))))
	   ;; The following checks avoid expanding unnecessarily the
	   ;; cell with `org-export-data'
	   (when (and value
		      (not (cdr value))
		      (stringp (car value))
		      (string-match "\\`<[lrc]?\\([0-9]+\\)?>\\'" (car value))
		      (match-string 1 (car value)))
	     (setq cookie-width
		   (string-to-number (match-string 1 (car value)))))))
	;; Ignore table rules.
	((eq (org-element-property :type row) 'rule))))
     (org-element-contents table))
    ;; Return value.
    cookie-width))

(defun org-export-table-cell-alignment (table-cell info)
  "Return TABLE-CELL contents alignment.

INFO is a plist used as the communication channel.

Return alignment as specified by the last alignment cookie in the
same column as TABLE-CELL.  If no such cookie is found, a default
alignment value will be deduced from fraction of numbers in the
column (see `org-table-number-fraction' for more information).
Possible values are `left', `right' and `center'."
  (let* ((row (org-export-get-parent table-cell))
	 (column (let ((cells (org-element-contents row)))
		   (- (length cells) (length (memq table-cell cells)))))
	 (table (org-export-get-parent-table table-cell))
	 (number-cells 0)
	 (total-cells 0)
	 cookie-align)
    (mapc
     (lambda (row)
       (cond
	;; In a special row, try to find an alignment cookie at
	;; COLUMN.
	((org-export-table-row-is-special-p row info)
	 (let ((value (org-element-contents
		       (elt (org-element-contents row) column))))
	   ;; Since VALUE is a secondary string, the following checks
	   ;; avoid useless expansion through `org-export-data'.
	   (when (and value
		      (not (cdr value))
		      (stringp (car value))
		      (string-match "\\`<\\([lrc]\\)?\\([0-9]+\\)?>\\'"
				    (car value))
		      (match-string 1 (car value)))
	     (setq cookie-align (match-string 1 (car value))))))
	;; Ignore table rules.
	((eq (org-element-property :type row) 'rule))
	;; In a standard row, check if cell's contents are expressing
	;; some kind of number.  Increase NUMBER-CELLS accordingly.
	;; Though, don't bother if an alignment cookie has already
	;; defined cell's alignment.
	((not cookie-align)
	 (let ((value (org-export-data
		       (org-element-contents
			(elt (org-element-contents row) column))
		       info)))
	   (incf total-cells)
	   (when (string-match org-table-number-regexp value)
	     (incf number-cells))))))
     (org-element-contents table))
    ;; Return value.  Alignment specified by cookies has precedence
    ;; over alignment deduced from cells contents.
    (cond ((equal cookie-align "l") 'left)
	  ((equal cookie-align "r") 'right)
	  ((equal cookie-align "c") 'center)
	  ((>= (/ (float number-cells) total-cells) org-table-number-fraction)
	   'right)
	  (t 'left))))

(defun org-export-table-cell-borders (table-cell info)
  "Return TABLE-CELL borders.

INFO is a plist used as a communication channel.

Return value is a list of symbols, or nil.  Possible values are:
`top', `bottom', `above', `below', `left' and `right'.  Note:
`top' (resp. `bottom') only happen for a cell in the first
row (resp. last row) of the table, ignoring table rules, if any.

Returned borders ignore special rows."
  (let* ((row (org-export-get-parent table-cell))
	 (table (org-export-get-parent-table table-cell))
	 borders)
    ;; Top/above border?  TABLE-CELL has a border above when a rule
    ;; used to demarcate row groups can be found above.  Hence,
    ;; finding a rule isn't sufficient to push `above' in BORDERS:
    ;; another regular row has to be found above that rule.
    (let (rule-flag)
      (catch 'exit
	(mapc (lambda (row)
		(cond ((eq (org-element-property :type row) 'rule)
		       (setq rule-flag t))
		      ((not (org-export-table-row-is-special-p row info))
		       (if rule-flag (throw 'exit (push 'above borders))
			 (throw 'exit nil)))))
	      ;; Look at every row before the current one.
	      (cdr (memq row (reverse (org-element-contents table)))))
	;; No rule above, or rule found starts the table (ignoring any
	;; special row): TABLE-CELL is at the top of the table.
	(when rule-flag (push 'above borders))
	(push 'top borders)))
    ;; Bottom/below border? TABLE-CELL has a border below when next
    ;; non-regular row below is a rule.
    (let (rule-flag)
      (catch 'exit
	(mapc (lambda (row)
		(cond ((eq (org-element-property :type row) 'rule)
		       (setq rule-flag t))
		      ((not (org-export-table-row-is-special-p row info))
		       (if rule-flag (throw 'exit (push 'below borders))
			 (throw 'exit nil)))))
	      ;; Look at every row after the current one.
	      (cdr (memq row (org-element-contents table))))
	;; No rule below, or rule found ends the table (modulo some
	;; special row): TABLE-CELL is at the bottom of the table.
	(when rule-flag (push 'below borders))
	(push 'bottom borders)))
    ;; Right/left borders?  They can only be specified by column
    ;; groups.  Column groups are defined in a row starting with "/".
    ;; Also a column groups row only contains "<", "<>", ">" or blank
    ;; cells.
    (catch 'exit
      (let ((column (let ((cells (org-element-contents row)))
		      (- (length cells) (length (memq table-cell cells))))))
	(mapc
	 (lambda (row)
	   (unless (eq (org-element-property :type row) 'rule)
	     (when (equal (org-element-contents
			   (car (org-element-contents row)))
			  '("/"))
	       (let ((column-groups
		      (mapcar
		       (lambda (cell)
			 (let ((value (org-element-contents cell)))
			   (when (member value '(("<") ("<>") (">") nil))
			     (car value))))
		       (org-element-contents row))))
		 ;; There's a left border when previous cell, if
		 ;; any, ends a group, or current one starts one.
		 (when (or (and (not (zerop column))
				(member (elt column-groups (1- column))
					'(">" "<>")))
			   (member (elt column-groups column) '("<" "<>")))
		   (push 'left borders))
		 ;; There's a right border when next cell, if any,
		 ;; starts a group, or current one ends one.
		 (when (or (and (/= (1+ column) (length column-groups))
				(member (elt column-groups (1+ column))
					'("<" "<>")))
			   (member (elt column-groups column) '(">" "<>")))
		   (push 'right borders))
		 (throw 'exit nil)))))
	 ;; Table rows are read in reverse order so last column groups
	 ;; row has precedence over any previous one.
	 (reverse (org-element-contents table)))))
    ;; Return value.
    borders))

(defun org-export-table-cell-starts-colgroup-p (table-cell info)
  "Non-nil when TABLE-CELL is at the beginning of a row group.
INFO is a plist used as a communication channel."
  ;; A cell starts a column group either when it is at the beginning
  ;; of a row (or after the special column, if any) or when it has
  ;; a left border.
  (or (eq (org-element-map
	      (org-export-get-parent table-cell)
	      'table-cell 'identity info 'first-match)
	     table-cell)
      (memq 'left (org-export-table-cell-borders table-cell info))))

(defun org-export-table-cell-ends-colgroup-p (table-cell info)
  "Non-nil when TABLE-CELL is at the end of a row group.
INFO is a plist used as a communication channel."
  ;; A cell ends a column group either when it is at the end of a row
  ;; or when it has a right border.
  (or (eq (car (last (org-element-contents
			 (org-export-get-parent table-cell))))
	     table-cell)
      (memq 'right (org-export-table-cell-borders table-cell info))))

(defun org-export-table-row-starts-rowgroup-p (table-row info)
  "Non-nil when TABLE-ROW is at the beginning of a column group.
INFO is a plist used as a communication channel."
  (unless (or (eq (org-element-property :type table-row) 'rule)
	      (org-export-table-row-is-special-p table-row info))
    (let ((borders (org-export-table-cell-borders
		    (car (org-element-contents table-row)) info)))
      (or (memq 'top borders) (memq 'above borders)))))

(defun org-export-table-row-ends-rowgroup-p (table-row info)
  "Non-nil when TABLE-ROW is at the end of a column group.
INFO is a plist used as a communication channel."
  (unless (or (eq (org-element-property :type table-row) 'rule)
	      (org-export-table-row-is-special-p table-row info))
    (let ((borders (org-export-table-cell-borders
		    (car (org-element-contents table-row)) info)))
      (or (memq 'bottom borders) (memq 'below borders)))))

(defun org-export-table-row-starts-header-p (table-row info)
  "Non-nil when TABLE-ROW is the first table header's row.
INFO is a plist used as a communication channel."
  (and (org-export-table-has-header-p
	(org-export-get-parent-table table-row) info)
       (org-export-table-row-starts-rowgroup-p table-row info)
       (= (org-export-table-row-group table-row info) 1)))

(defun org-export-table-row-ends-header-p (table-row info)
  "Non-nil when TABLE-ROW is the last table header's row.
INFO is a plist used as a communication channel."
  (and (org-export-table-has-header-p
	(org-export-get-parent-table table-row) info)
       (org-export-table-row-ends-rowgroup-p table-row info)
       (= (org-export-table-row-group table-row info) 1)))

(defun org-export-table-dimensions (table info)
  "Return TABLE dimensions.

INFO is a plist used as a communication channel.

Return value is a CONS like (ROWS . COLUMNS) where
ROWS (resp. COLUMNS) is the number of exportable
rows (resp. columns)."
  (let (first-row (columns 0) (rows 0))
    ;; Set number of rows, and extract first one.
    (org-element-map
     table 'table-row
     (lambda (row)
       (when (eq (org-element-property :type row) 'standard)
	 (incf rows)
	 (unless first-row (setq first-row row)))) info)
    ;; Set number of columns.
    (org-element-map first-row 'table-cell (lambda (cell) (incf columns)) info)
    ;; Return value.
    (cons rows columns)))

(defun org-export-table-cell-address (table-cell info)
  "Return address of a regular TABLE-CELL object.

TABLE-CELL is the cell considered.  INFO is a plist used as
a communication channel.

Address is a CONS cell (ROW . COLUMN), where ROW and COLUMN are
zero-based index.  Only exportable cells are considered.  The
function returns nil for other cells."
  (let* ((table-row (org-export-get-parent table-cell))
	 (table (org-export-get-parent-table table-cell)))
    ;; Ignore cells in special rows or in special column.
    (unless (or (org-export-table-row-is-special-p table-row info)
		(and (org-export-table-has-special-column-p table)
		     (eq (car (org-element-contents table-row)) table-cell)))
      (cons
       ;; Row number.
       (let ((row-count 0))
	 (org-element-map
	  table 'table-row
	  (lambda (row)
	    (cond ((eq (org-element-property :type row) 'rule) nil)
		  ((eq row table-row) row-count)
		  (t (incf row-count) nil)))
	  info 'first-match))
       ;; Column number.
       (let ((col-count 0))
	 (org-element-map
	  table-row 'table-cell
	  (lambda (cell)
	    (if (eq cell table-cell) col-count (incf col-count) nil))
	  info 'first-match))))))

(defun org-export-get-table-cell-at (address table info)
  "Return regular table-cell object at ADDRESS in TABLE.

Address is a CONS cell (ROW . COLUMN), where ROW and COLUMN are
zero-based index.  TABLE is a table type element.  INFO is
a plist used as a communication channel.

If no table-cell, among exportable cells, is found at ADDRESS,
return nil."
  (let ((column-pos (cdr address)) (column-count 0))
    (org-element-map
     ;; Row at (car address) or nil.
     (let ((row-pos (car address)) (row-count 0))
       (org-element-map
	table 'table-row
	(lambda (row)
	  (cond ((eq (org-element-property :type row) 'rule) nil)
		((= row-count row-pos) row)
		(t (incf row-count) nil)))
	info 'first-match))
     'table-cell
     (lambda (cell)
       (if (= column-count column-pos) cell
	 (incf column-count) nil))
     info 'first-match)))


;;;; For Tables Of Contents
;;
;; `org-export-collect-headlines' builds a list of all exportable
;; headline elements, maybe limited to a certain depth.  One can then
;; easily parse it and transcode it.
;;
;; Building lists of tables, figures or listings is quite similar.
;; Once the generic function `org-export-collect-elements' is defined,
;; `org-export-collect-tables', `org-export-collect-figures' and
;; `org-export-collect-listings' can be derived from it.

(defun org-export-collect-headlines (info &optional n)
  "Collect headlines in order to build a table of contents.

INFO is a plist used as a communication channel.

When optional argument N is an integer, it specifies the depth of
the table of contents.  Otherwise, it is set to the value of the
last headline level.  See `org-export-headline-levels' for more
information.

Return a list of all exportable headlines as parsed elements."
  (unless (wholenump n) (setq n (plist-get info :headline-levels)))
  (org-element-map
   (plist-get info :parse-tree)
   'headline
   (lambda (headline)
     ;; Strip contents from HEADLINE.
     (let ((relative-level (org-export-get-relative-level headline info)))
       (unless (> relative-level n) headline)))
   info))

(defun org-export-collect-elements (type info &optional predicate)
  "Collect referenceable elements of a determined type.

TYPE can be a symbol or a list of symbols specifying element
types to search.  Only elements with a caption are collected.

INFO is a plist used as a communication channel.

When non-nil, optional argument PREDICATE is a function accepting
one argument, an element of type TYPE.  It returns a non-nil
value when that element should be collected.

Return a list of all elements found, in order of appearance."
  (org-element-map
   (plist-get info :parse-tree) type
   (lambda (element)
     (and (org-element-property :caption element)
	  (or (not predicate) (funcall predicate element))
	  element))
   info))

(defun org-export-collect-tables (info)
  "Build a list of tables.
INFO is a plist used as a communication channel.

Return a list of table elements with a caption."
  (org-export-collect-elements 'table info))

(defun org-export-collect-figures (info predicate)
  "Build a list of figures.

INFO is a plist used as a communication channel.  PREDICATE is
a function which accepts one argument: a paragraph element and
whose return value is non-nil when that element should be
collected.

A figure is a paragraph type element, with a caption, verifying
PREDICATE.  The latter has to be provided since a \"figure\" is
a vague concept that may depend on back-end.

Return a list of elements recognized as figures."
  (org-export-collect-elements 'paragraph info predicate))

(defun org-export-collect-listings (info)
  "Build a list of src blocks.

INFO is a plist used as a communication channel.

Return a list of src-block elements with a caption."
  (org-export-collect-elements 'src-block info))


;;;; Topology
;;
;; Here are various functions to retrieve information about the
;; neighbourhood of a given element or object.  Neighbours of interest
;; are direct parent (`org-export-get-parent'), parent headline
;; (`org-export-get-parent-headline'), first element containing an
;; object, (`org-export-get-parent-element'), parent table
;; (`org-export-get-parent-table'), previous element or object
;; (`org-export-get-previous-element') and next element or object
;; (`org-export-get-next-element').
;;
;; `org-export-get-genealogy' returns the full genealogy of a given
;; element or object, from closest parent to full parse tree.

(defun org-export-get-parent (blob)
  "Return BLOB parent or nil.
BLOB is the element or object considered."
  (org-element-property :parent blob))

(defun org-export-get-genealogy (blob)
  "Return full genealogy relative to a given element or object.

BLOB is the element or object being considered.

Ancestors are returned from closest to farthest, the last one
being the full parse tree."
  (let (genealogy (parent blob))
    (while (setq parent (org-element-property :parent parent))
      (push parent genealogy))
    (nreverse genealogy)))

(defun org-export-get-parent-headline (blob)
  "Return BLOB parent headline or nil.
BLOB is the element or object being considered."
  (let ((parent blob))
    (while (and (setq parent (org-element-property :parent parent))
		(not (eq (org-element-type parent) 'headline))))
    parent))

(defun org-export-get-parent-element (object)
  "Return first element containing OBJECT or nil.
OBJECT is the object to consider."
  (let ((parent object))
    (while (and (setq parent (org-element-property :parent parent))
		(memq (org-element-type parent) org-element-all-objects)))
    parent))

(defun org-export-get-parent-table (object)
  "Return OBJECT parent table or nil.
OBJECT is either a `table-cell' or `table-element' type object."
  (let ((parent object))
    (while (and (setq parent (org-element-property :parent parent))
		(not (eq (org-element-type parent) 'table))))
    parent))

(defun org-export-get-previous-element (blob info)
  "Return previous element or object.
BLOB is an element or object.  INFO is a plist used as
a communication channel.  Return previous exportable element or
object, a string, or nil."
  (let (prev)
    (catch 'exit
      (mapc (lambda (obj)
	      (cond ((eq obj blob) (throw 'exit prev))
		    ((memq obj (plist-get info :ignore-list)))
		    (t (setq prev obj))))
	    (org-element-contents (org-export-get-parent blob))))))

(defun org-export-get-next-element (blob info)
  "Return next element or object.
BLOB is an element or object.  INFO is a plist used as
a communication channel.  Return next exportable element or
object, a string, or nil."
  (catch 'found
    (mapc (lambda (obj)
	    (unless (memq obj (plist-get info :ignore-list))
	      (throw 'found obj)))
	  (cdr (memq blob (org-element-contents (org-export-get-parent blob)))))
    nil))


;;;; Translation
;;
;; `org-export-translate' translates a string according to language
;; specified by LANGUAGE keyword or `org-export-language-setup'
;; variable and a specified charset.  `org-export-dictionary' contains
;; the dictionary used for the translation.

(defconst org-export-dictionary
  '(("Author"
     ("fr"
      :ascii "Auteur"
      :latin1 "Auteur"
      :utf-8 "Auteur"))
    ("Date"
     ("fr"
      :ascii "Date"
      :latin1 "Date"
      :utf-8 "Date"))
    ("Equation")
    ("Figure")
    ("Footnotes"
     ("fr"
      :ascii "Notes de bas de page"
      :latin1 "Notes de bas de page"
      :utf-8 "Notes de bas de page"))
    ("List of Listings"
     ("fr"
      :ascii "Liste des programmes"
      :latin1 "Liste des programmes"
      :utf-8 "Liste des programmes"))
    ("List of Tables"
     ("fr"
      :ascii "Liste des tableaux"
      :latin1 "Liste des tableaux"
      :utf-8 "Liste des tableaux"))
    ("Listing %d:"
     ("fr"
      :ascii "Programme %d :"
      :latin1 "Programme %d :"
      :utf-8 "Programme nº %d :"))
    ("Listing %d: %s"
     ("fr"
      :ascii "Programme %d : %s"
      :latin1 "Programme %d : %s"
      :utf-8 "Programme nº %d : %s"))
    ("See section %s"
     ("fr"
      :ascii "cf. section %s"
      :latin1 "cf. section %s"
      :utf-8 "cf. section %s"))
    ("Table %d:"
     ("fr"
      :ascii "Tableau %d :"
      :latin1 "Tableau %d :"
      :utf-8 "Tableau nº %d :"))
    ("Table %d: %s"
     ("fr"
      :ascii "Tableau %d : %s"
      :latin1 "Tableau %d : %s"
      :utf-8 "Tableau nº %d : %s"))
    ("Table of Contents"
     ("fr"
      :ascii "Sommaire"
      :latin1 "Table des matières"
      :utf-8 "Table des matières"))
    ("Unknown reference"
     ("fr"
      :ascii "Destination inconnue"
      :latin1 "Référence inconnue"
      :utf-8 "Référence inconnue")))
  "Dictionary for export engine.

Alist whose CAR is the string to translate and CDR is an alist
whose CAR is the language string and CDR is a plist whose
properties are possible charsets and values translated terms.

It is used as a database for `org-export-translate'. Since this
function returns the string as-is if no translation was found,
the variable only needs to record values different from the
entry.")

(defun org-export-translate (s encoding info)
  "Translate string S according to language specification.

ENCODING is a symbol among `:ascii', `:html', `:latex', `:latin1'
and `:utf-8'.  INFO is a plist used as a communication channel.

Translation depends on `:language' property.  Return the
translated string.  If no translation is found return S."
  (let ((lang (plist-get info :language))
	(translations (cdr (assoc s org-export-dictionary))))
    (or (plist-get (cdr (assoc lang translations)) encoding) s)))



;;; The Dispatcher
;;
;; `org-export-dispatch' is the standard interactive way to start an
;; export process.  It uses `org-export-dispatch-ui' as a subroutine
;; for its interface.  Most commons back-ends should have an entry in
;; it.

;;;###autoload
(defun org-export-dispatch ()
  "Export dispatcher for Org mode.

It provides an access to common export related tasks in a buffer.
Its interface comes in two flavours: standard and expert.  While
both share the same set of bindings, only the former displays the
valid keys associations.  Set `org-export-dispatch-use-expert-ui'
to switch to one or the other.

Return an error if key pressed has no associated command."
  (interactive)
  (let* ((input (org-export-dispatch-ui
		 (if (listp org-export-initial-scope) org-export-initial-scope
		   (list org-export-initial-scope))
		 org-export-dispatch-use-expert-ui))
	 (raw-key (car input))
	 (optns (cdr input)))
    ;; Translate "C-a", "C-b"... into "a", "b"... Then take action
    ;; depending on user's key pressed.
    (case (if (< raw-key 27) (+ raw-key 96) raw-key)
      ;; Allow to quit with "q" key.
      (?q nil)
      ;; Export with `e-ascii' back-end.
      ((?A ?N ?U)
       (org-e-ascii-export-as-ascii
	(memq 'subtree optns) (memq 'visible optns) (memq 'body optns)
	`(:ascii-charset ,(case raw-key (?A 'ascii) (?N 'latin1) (t 'utf-8)))))
      ((?a ?n ?u)
       (org-e-ascii-export-to-ascii
	(memq 'subtree optns) (memq 'visible optns) (memq 'body optns)
	`(:ascii-charset ,(case raw-key (?a 'ascii) (?n 'latin1) (t 'utf-8)))))
      ;; Export with `e-latex' back-end.
      (?L (org-e-latex-export-as-latex
	   (memq 'subtree optns) (memq 'visible optns) (memq 'body optns)))
      (?l
       (org-e-latex-export-to-latex
	(memq 'subtree optns) (memq 'visible optns) (memq 'body optns)))
      (?p
       (org-e-latex-export-to-pdf
	(memq 'subtree optns) (memq 'visible optns) (memq 'body optns)))
      (?d
       (org-open-file
	(org-e-latex-export-to-pdf
	 (memq 'subtree optns) (memq 'visible optns) (memq 'body optns))))
      ;; Export with `e-html' back-end.
      (?H
       (org-e-html-export-as-html
	(memq 'subtree optns) (memq 'visible optns) (memq 'body optns)))
      (?h
       (org-e-html-export-to-html
	(memq 'subtree optns) (memq 'visible optns) (memq 'body optns)))
      (?b
       (org-open-file
	(org-e-html-export-to-html
	 (memq 'subtree optns) (memq 'visible optns) (memq 'body optns))))
      ;; Export with `e-odt' back-end.
      (?o
       (org-e-odt-export-to-odt
	(memq 'subtree optns) (memq 'visible optns) (memq 'body optns)))
      (?O
       (org-open-file
	(org-e-odt-export-to-odt
	 (memq 'subtree optns) (memq 'visible optns) (memq 'body optns))))
      ;; Publishing facilities
      (?F
       (org-e-publish-current-file (memq 'force optns)))
      (?P
       (org-e-publish-current-project (memq 'force optns)))
      (?X
       (let ((project
	      (assoc (org-icompleting-read
		      "Publish project: " org-e-publish-project-alist nil t)
		     org-e-publish-project-alist)))
	 (org-e-publish project (memq 'force optns))))
      (?E
       (org-e-publish-all (memq 'force optns)))
      ;; Undefined command.
      (t (error "No command associated with key %s"
		(char-to-string raw-key))))))

(defun org-export-dispatch-ui (options expertp)
  "Handle interface for `org-export-dispatch'.

OPTIONS is a list containing current interactive options set for
export.  It can contain any of the following symbols:
`body'    toggles a body-only export
`subtree' restricts export to current subtree
`visible' restricts export to visible part of buffer.
`force'   force publishing files.

EXPERTP, when non-nil, triggers expert UI.  In that case, no help
buffer is provided, but indications about currently active
options are given in the prompt.  Moreover, \[?] allows to switch
back to standard interface.

Return value is a list with key pressed as CAR and a list of
final interactive export options as CDR."
  (let ((help
	 (format "---- (Options) -------------------------------------------

\[1] Body only:     %s       [2] Export scope:     %s
\[3] Visible only:  %s       [4] Force publishing: %s


--- (ASCII/Latin-1/UTF-8 Export) -------------------------

\[a/n/u] to TXT file          [A/N/U] to temporary buffer

--- (HTML Export) ----------------------------------------

\[h] to HTML file             [b] ... and open it
\[H] to temporary buffer

--- (LaTeX Export) ---------------------------------------

\[l] to TEX file              [L] to temporary buffer
\[p] to PDF file              [d] ... and open it

--- (ODF Export) -----------------------------------------

\[o] to ODT file              [O] ... and open it

--- (Publish) --------------------------------------------

\[F] current file             [P] current project
\[X] a project                [E] every project"
		 (if (memq 'body options) "On " "Off")
		 (if (memq 'subtree options) "Subtree" "Buffer ")
		 (if (memq 'visible options) "On " "Off")
		 (if (memq 'force options) "On " "Off")))
	(standard-prompt "Export command: ")
	(expert-prompt (format "Export command (%s%s%s%s): "
			       (if (memq 'body options) "b" "-")
			       (if (memq 'subtree options) "s" "-")
			       (if (memq 'visible options) "v" "-")
			       (if (memq 'force options) "f" "-")))
	(handle-keypress
	 (function
	  ;; Read a character from command input, toggling interactive
	  ;; options when applicable.  PROMPT is the displayed prompt,
	  ;; as a string.
	  (lambda (prompt)
	    (let ((key (read-char-exclusive prompt)))
	      (cond
	       ;; Ignore non-standard characters (i.e. "M-a").
	       ((not (characterp key)) (org-export-dispatch-ui options expertp))
	       ;; Help key: Switch back to standard interface if
	       ;; expert UI was active.
	       ((eq key ??) (org-export-dispatch-ui options nil))
	       ;; Toggle export options.
	       ((memq key '(?1 ?2 ?3 ?4))
		(org-export-dispatch-ui
		 (let ((option (case key (?1 'body) (?2 'subtree) (?3 'visible)
				     (?4 'force))))
		   (if (memq option options) (remq option options)
		     (cons option options)))
		 expertp))
	       ;; Action selected: Send key and options back to
	       ;; `org-export-dispatch'.
	       (t (cons key options))))))))
    ;; With expert UI, just read key with a fancy prompt.  In standard
    ;; UI, display an intrusive help buffer.
    (if expertp (funcall handle-keypress expert-prompt)
      (save-window-excursion
	(delete-other-windows)
	(with-output-to-temp-buffer "*Org Export/Publishing Help*" (princ help))
	(org-fit-window-to-buffer
	 (get-buffer-window "*Org Export/Publishing Help*"))
	(funcall handle-keypress standard-prompt)))))


(provide 'org-export)
;;; org-export.el ends here
