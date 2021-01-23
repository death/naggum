;;; naggum.el --- Show a random Naggum post

;; Author: death <github.com/death>
;; Version: 1.1
;; Package-Requires: ((emacs "24.4"))
;; Keywords: games help
;; URL: http://github.com/death/naggum
;; SPDX-License-Identifier: MIT

;; This file is not part of GNU Emacs.

;; Copyright (c) 2014 death

;; Permission is hereby granted, free of charge, to any person
;; obtaining a copy of this software and associated documentation
;; files (the "Software"), to deal in the Software without
;; restriction, including without limitation the rights to use, copy,
;; modify, merge, publish, distribute, sublicense, and/or sell copies
;; of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:

;; The above copyright notice and this permission notice shall be
;; included in all copies or substantial portions of the Software.

;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
;; BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
;; ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
;; CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;; SOFTWARE.

;;; Commentary:

;; This package provides an interactive command to show a random post
;; from Zach Beane's Erik Naggum comp.lang.lisp archive.

;; Just `M-x naggum` any time you get nostalgic.

;;; Code:

(require 'subr-x)  ; For string-trim.
(require 'url)
(require 'xml)

(defun naggum-string ()
  "Get a random Naggum post as a string."
  (with-temp-buffer
    (let ((url-user-agent "naggum.el"))
      (url-insert-file-contents "https://xach.com/naggum/articles/random"))
    ;; Keep only the part between <pre>...</pre>.
    (re-search-forward "<pre>")
    (delete-region (point-min) (match-end 0))
    (re-search-forward "</pre>")
    (delete-region (match-beginning 0) (point-max))
    ;; Remove all HTML tags (but keep the text in their bodies).
    (goto-char (point-min))
    (while (re-search-forward "<[^<>]*>" nil t) (replace-match ""))
    ;; Expand &lt; and &gt; HTML entities.
    (goto-char (point-min))
    (xml-parse-string)
    (concat (string-trim (buffer-string)) "\n")))

;;;###autoload
(defun naggum ()
  "Show a random Naggum post."
  (interactive)
  (let ((string (naggum-string)))
    (with-current-buffer (get-buffer-create "*Naggum*")
      (let ((inhibit-read-only t))
        (erase-buffer)
        (insert string))
      (goto-char (point-min))
      (mail-mode)
      (view-mode)
      (display-buffer (current-buffer)))))

(provide 'naggum)

;;; naggum.el ends here
