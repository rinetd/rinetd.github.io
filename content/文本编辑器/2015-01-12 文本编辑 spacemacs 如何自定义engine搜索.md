---
title: spacemacs 如何自定义engine搜索
date: 2016-01-12T15:30:01+08:00
update: 2016-01-01
categories: [文本编辑]
tags: [emacs]
---

spacemacs 如何自定义engine搜索

## 方式1 .spacemacs

(defun dotspacemacs/user-config ()

  ;; 1. 定义搜索引擎
  (defengine spotify "https://play.spotify.com/search/%s")
  ;; 2. 添加搜索引擎
  (add-to-list 'search-engine-alist
          '(spotify
          :name "Spotify"
          :url "https://play.spotify.com/search/%s"))

)
## 方式2 自定义layer中配置
[appleshan/my-spacemacs-config: My personal Spacemacs config](https://github.com/appleshan/my-spacemacs-config)

(defun appleshan-programming/post-init-engine-mode ()
  (add-to-list 'search-engine-alist
    ;; elisp code search
    '(Elisp
         :name "Elisp code search"
         :url "http://www.google.com.au/search?q=%s+filetype:el")
    ;; javascript search on mozilla.org
    '(Elisp
         :name "Javascript search on mozilla.org"
         :url "http://www.google.com.au/search?q=%s+site:developer.mozilla.org")
    ))
