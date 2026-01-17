(require 'ox)
(require 'ox-html)

(org-link-set-parameters "blog" :follow #'blog-link-open :export #'blog-link-export :store #'blog-link-store)

(defun blog-link-open (path _)
  (error "not yet implemented"))

(defun blog-link-store (&optional interactive?)
  (error "not yet implemented"))

(defun blog-link-export (link description format _)
  (let ((desc (or description link)))
	(format "<postlink slug=\"%s\">%s</postlink>" link desc)))

(defvar *my/ob-last-exported-title* nil)
(defvar *my/ob-last-exported-date* nil)
(defvar *my/ob-last-exported-tags* nil)

(defun my/ob-get-prop (prop info)
  (org-html-plain-text (org-element-interpret-data (plist-get info prop)) info))

(defun org-blog-template (contents info)
  (setq *my/ob-last-exported-title* (my/ob-get-prop :title info))
  (setq *my/ob-last-exported-date* (my/ob-get-prop :date info))
  (let ((slug (file-name-sans-extension (file-name-nondirectory (plist-get info :input-file))))
		(tags (plist-get info :blog-tags)))
	(setq tags (if tags (split-string tags " ") nil))
	(setq *my/ob-last-exported-tags* tags)
	(concat
	 "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
	 "<?xml-stylesheet type=\"text/xsl\" href=\"../../../render.xsl\"?>"
	 "<post slug=\"" slug "\" published=\"" (my/ob-get-prop :date info) "\" exported=\"" (format-time-string "%Y-%m-%d %H:%M:%S") "\">"
	 "<title>" (my/ob-get-prop :title info) "</title>"
	 "<author>" (my/ob-get-prop :author info) "</author>"
	 "<tags>" (mapconcat (lambda (tg) (format "<tag>%s</tag>" tg)) tags) "</tags>"
	 "<content>" contents "</content>"
	 "</post>")))

(org-export-define-derived-backend 'blog 'html
  :translate-alist '((template . org-blog-template))
  :options-alist '((:blog-tags "BLOG_TAGS" nil nil newline)))

(defun create-blog-db (dir)
  (interactive "DBlog root directory: ")
  (let ((db (sqlite-open (expand-file-name "posts.sqlite3" dir))))
	(sqlite-execute db "create table posts (slug text primary key, title text, published_at date, exported_at date);")
	(sqlite-execute db "create table posts_tags (slug text, tag text, primary key (slug, tag));")
	(sqlite-close db)))

(defun blog-export ()
  (interactive)
  (let ((basedir (file-name-concat default-directory ".." ".." "..")))
	; dont know why this has to be global but `posts' table isnt found otherwise
	(setq *temp/blog-db* (sqlite-open (expand-file-name "posts.sqlite3" basedir)))
	(let ((org-html-doctype "xhtml5")
		  (org-html-html5-fancy t)
		  (slug (file-name-sans-extension (file-name-nondirectory (buffer-file-name)))))
	  (org-export-to-file 'blog (org-export-output-file-name ".xhtml"))
	  (sqlite-execute
	   *temp/blog-db*
	   "insert into posts values (?1, ?2, ?3, datetime()) on conflict do update set title=?2,published_at=?3,exported_at=datetime();"
	   (list slug *my/ob-last-exported-title* *my/ob-last-exported-date*))
	  (dolist (tag *my/ob-last-exported-tags*)
		(sqlite-execute *temp/blog-db* "insert or ignore into posts_tags values (?1, ?2);" (list slug tag))))
	(let ((posts (sqlite-select *temp/blog-db* "select slug, published_at, title from posts order by published_at desc" nil 'set)))
	  (with-temp-file (expand-file-name "posts.xml" basedir)
		(insert "<?xml version=\"1.0\" encoding=\"utf-8\"?>")
		(insert "<posts>")
		(while (sqlite-more-p posts)
		  (let ((post (sqlite-next posts)))
			(when (car post)
			  (insert (format "<posttitle slug=\"%s\" published=\"%s\">%s</posttitle>" (car post) (cadr post) (caddr post) (cadddr post))))))
		(insert "</posts>"))))
  (sqlite-close *temp/blog-db*))
