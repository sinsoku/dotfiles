;; メニューバー、ツールバー非表示
(menu-bar-mode 0)
(tool-bar-mode 0)

;; ricty
(set-frame-font "ricty-12")

;; タイトルバーにファイルのフルパスを表示
(setq frame-title-format "%f")

;; 行番号を表示
(global-linum-mode t)

;; TABの表示幅
(setq-default tab-width 4)

;; インデントにタブ文字を使用しない
(setq-default indent-tabs-mode nil)

;; load-path を追加する関数を定義
(defun add-to-load-path (&rest paths)
  (let (path)
    (dolist (path paths paths)
      (let ((default-directory
	      (expand-file-name (concat user-emacs-directory path))))
	(add-to-list 'load-path default-directory)
	(if (fboundp 'normal-top-level-add-subdirs-to-load-path)
	    (normal-top-level-add-subdirs-to-load-path))))))

;; 引数のサブディレクトリをload-pathに追加
(add-to-load-path "elisp" "conf" "public_repos")

;; auto-installの設定
;(when (require 'auto-install nil t)
;  (setq auto-install-directory "~/.emacs.d/elisp")
;  (auto-install-update-emacswiki-package-name t)
;  (auto-install-compatibility-setup))

;; package.elの設定
(when (require 'package nil t)
  ;; パッケージリポジトリにMarmaladeと開発者運営のELPAを追加
  (add-to-list 'package-archives
               '("marmalade" . "http://marmalade-repo.org/packages/"))
  (add-to-list 'package-archives '("ELPA" . "http://tromey.com/elpa/"))
  ;; インストールしたパッケージにロードパスを通して読み込む
  (package-initialize))

;; solarized-theme
(load-theme 'solarized-dark t)

;; 背景の透過
(if window-system (progn
  (set-frame-parameter nil 'alpha 80)))
