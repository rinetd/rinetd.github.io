---
title: Emacs org capture的启用设定
date: 2016-01-12T15:30:01+08:00
update: 2016-01-01
categories: [文本编辑]
tags: [emacs]
---


```
(setq org-capture-templates
      '(

        ("t" "Todo" entry (file+headline "gtd.org" "待办事项")
         "* TODO %?\n  %i\n"
         :empty-lines 1)

        ("x" "NEXT" entry (file+headline "gtd.org" "下一步行动")
         "* NEXT [#B] %?\n  %i\n"
         :empty-lines 1)
        ("m" "MAYBE" entry (file+headline "gtd.org" "将来/也许") "* MAYBE [#C]  %?\n  %i\n" )

        ("w" "WAITING" entry (file+headline "gtd.org" "等待waiting")
         "* WAITING [#A] %? %^G  %i\n %U")


        ("l" "待确定讨论 CheckList" checkitem  (file+headline "gtd.org" "待确定") " [ ] %?\n\n" :prepend t :kill-buffer t)

        ;; For capturing details of bills
        ("z" "账单表格 Bill"      table-line (file+headline "gtd.org" "12月账单" ) "| %U | %^{people} | %^{物品} | %^{数量} | %^{价格}| " :prepend t :kill-buffer t)
        ("k" "考勤清单 List"      item       (file+headline "gtd.org" "考勤") " %? ")
        ("j" "一句话备忘录   Journal"   entry      (file+datetree "journal.org") "*  %?")
        ("s" "Code Snippet"      entry      (file "snippets.org") "* %?\t%^g\n#+BEGIN_SRC %^{language}\n\n#+END_SRC")

        ("n" "笔记" entry (file+headline "notes.org" "Quick notes")
         "* %?\n %i\n %x\n %u\n"
         :clock-in t)

        ;; To capture ideas for my blog
        ("b"                                  ; key
         "Blog"                               ; name
         entry                                ; type
         (file+headline "notes.org" "Blog")   ; target
         "* %^{Title} :blog:\n:PROPERTIES:\n:Created: %U\n:END:\n%i\n%?" ; template
         :prepend t                 ; properties
         :empty-lines 1             ; properties
         :created t                 ; properties
         :kill-buffer t)            ; properties

        ("l" "links" entry (file+headline "~/org-notes/notes.org" "Quick notes")
         "* TODO [#C] %?\n  %i\n %a \n %U"
         :empty-lines 1)))

```
(setq org-capture-templates
(quote
(
("l" "Later" checkitem (file+headline "scratch.org" "later") " [ ] %?\n\n" :prepend t :kill-buffer t)
 )))

;; 账单
("a" "Account" table-line  (file+headline "account.org" "Web accounts") "| %? | | %a | %U |")

Instead of using %(org-set-tags) in the template, use %^g

``` https://sriramkswamy.github.io/dotemacs/
(setq org-capture-templates '(
        ;; For code snippets
        ("a"               ; key
         "Algo/Code"       ; name
         entry             ; type
         (file+headline "~/Dropbox/org/notes.org" "Code")  ; target
         "* %^{TITLE} %(org-set-tags)  :code:\n:PROPERTIES:\n:Created: %U\n:END:\n%i\#+BEGIN_SRC %^{language}\n%?\n\#END_SRC"  ; template
         :prepend t        ; properties
         :empty-lines 1    ; properties
         :created t        ; properties
         :kill-buffer t)   ; properties

        ;; For taking notes on random things
        ("n"               ; key
         "Note"            ; name
         entry             ; type
         (file+headline "~/Dropbox/org/notes.org" "Notes")  ; target
         "* %? %(org-set-tags)  :note:\n:PROPERTIES:\n:Created: %U\n:Linked: %A\n:END:\n%i"  ; template
         :prepend t        ; properties
         :empty-lines 1    ; properties
         :created t        ; properties
         :kill-buffer t)   ; properties

        ;; Ledger is a CLI accounting system
        ("l"               ; key
         "Ledger"          ; name
         entry             ; type
         (file+datetree "~/Dropbox/org/ledger.org" "Ledger")  ; target
         "* %^{expense} %(org-set-tags)  :accounts:\n:PROPERTIES:\n:Created: %U\n:END:\n%i
#+NAME: %\\1-%t
\#+BEGIN_SRC ledger :noweb yes
%^{Date of expense (yyyy/mm/dd)} %^{'*' if cleared, else blank} %\\1
    %^{Account name}                                $%^{Amount}
    %?
\#+END_SRC
"  ; template
         :prepend t        ; properties
         :empty-lines 1    ; properties
         :created t        ; properties
         :kill-buffer t)   ; properties

        ;; For notes or something regarding more work
        ("w"               ; key
         "Work"            ; name
         entry             ; type
         (file+headline "~/Dropbox/org/phd.org" "Work")  ; target
         "* TODO %^{Todo} %(org-set-tags)  :work:\n:PROPERTIES:\n:Created: %U\n:END:\n%i\n%?"  ; template
         :prepend t        ; properties
         :empty-lines 1    ; properties
         :created t        ; properties
         :kill-buffer t)   ; properties

        ;; For capturing some things that are worth reading
        ("r"               ; key
         "Reading"         ; name
         entry             ; type
         (file+headline "~/Dropbox/org/fun.org" "Reading")  ; target
         "* %^{Title} %(org-set-tags)\n:PROPERTIES:\n:Created: %U\n:END:\n%i\n%?"  ; template
         :prepend t        ; properties
         :empty-lines 1    ; properties
         :created t        ; properties
         :kill-buffer t)   ; properties

        ;; For capturing minutes of the meeting
        ("m"               ; key
         "Meeting"         ; name
         entry             ; type
         (file+datetree "~/Dropbox/org/phd.org" "Meeting")  ; target
         "* %^{Title} %(org-set-tags)  :meeting:\n:PROPERTIES:\n:Created: %U\n:END:\n%i\n** Agenda:\n%?\n\n** Minutes of the meeting:\n"  ; template
         :prepend t        ; properties
         :empty-lines 1    ; properties
         :created t        ; properties
         :kill-buffer t)   ; properties

        ;; To practice for my driving test
        ("d"               ; key
         "Drill driving"   ; name
         entry             ; type
         (file+headline "~/Dropbox/org/drill.org" "Driving")  ; target
         "* Question  :drill:driving:\n%^{Question}\n** Answer\n%?"  ; template
         :prepend t        ; properties
         :empty-lines 1    ; properties
         :created t        ; properties
         :kill-buffer t)   ; properties

        ;; For taking notes of math/stats stuff that I keep forgetting
        ("s"              ; key
         "Drill math"     ; name
         entry            ; type
         (file+headline "~/Dropbox/org/drill.org" "Stats/Math")  ; target
         "* Question  :drill:stats:math:\n%^{Question}\n** Answer\n%?"  ; template
         :prepend t        ; properties
         :empty-lines 1    ; properties
         :created t        ; properties
         :kill-buffer t)   ; properties

        ;; For capturing some physics concepts that I need to remember
        ("p"              ; key
         "Drill physics"  ; name
         entry            ; type
         (file+headline "~/Dropbox/org/drill.org" "Physics")  ; target
         "* Question  :drill:physics:\n%^{Question}\n** Answer\n%?"  ; template
         :prepend t        ; properties
         :empty-lines 1    ; properties
         :created t        ; properties
         :kill-buffer t)   ; properties

        ;; For capturing details of a job application/details
        ("j"                      ; key
         "Jobs"                   ; name
         table-line               ; type
         (file+headline "~/Dropbox/org/notes.org" "Jobs")  ; target
         "| %u | %^{Company} | [[%^{job link}][%^{position}]] | %^{referrals?} | %^{Experience?} | %^t | %^{Status} | %^{Follow up} | %^{Result} |"  ; template
         :prepend t               ; properties
         ;; :table-line-pos "II-3"   ; properties
         :empty-lines 1           ; properties
         :created t               ; properties
         :kill-buffer t)          ; properties

        ;; To capture movies that I plan to see
        ("f"              ; key
         "films"          ; name
         entry            ; type
         (file+headline "~/Dropbox/org/fun.org" "Movies")  ; target
         "* %^{Movie} %(org-set-tags)  :film:\n:PROPERTIES:\n:Created: %U\n:END:\n%i
Netflix?: %^{netflix? Yes/No}\nGenre: %^{genre}\nDescription:\n%?"  ; template
         :prepend t        ; properties
         :empty-lines 1    ; properties
         :created t        ; properties
         :kill-buffer t)   ; properties

        ;; To capture ideas for my blog
        ("b"               ; key
         "Blog"            ; name
         entry             ; type
         (file+headline "~/Dropbox/org/blog.org" "Blog")  ; target
         "* %^{Title} %(org-set-tags)  :blog:\n:PROPERTIES:\n:Created: %U\n:END:\n%i\n%?"  ; template
         :prepend t        ; properties
         :empty-lines 1    ; properties
         :created t        ; properties
         :kill-buffer t)   ; properties

        ;; To capture tons of errands
        ("e"               ; key
         "Errands"         ; name
         entry             ; type
         (file+headline "~/Dropbox/org/errands.org" "Errands")  ; target
         "* TODO %^{Todo} %(org-set-tags)  :errands:\n:PROPERTIES:\n:Created: %U\n:END:\n%i\n%?"  ; template
         :prepend t        ; properties
         :empty-lines 1    ; properties
         :created t        ; properties
         :kill-buffer t)   ; properties

        ;; To capture things regarding my course
        ("c"               ; key
         "Courses"         ; name
         entry             ; type
         (file+headline "~/Dropbox/org/phd.org" "Courses")  ; target
         "* %^{Course} %(org-set-tags)  :courses:\n:PROPERTIES:\n:Created: %U\n:END:\n%i\n%?"  ; template
         :prepend t        ; properties
         :empty-lines 1    ; properties
         :created t        ; properties
         :kill-buffer t))) ; properties
```
;; %[file]     插入文件
;; %(sexp)     插入 sexp 的返回值，sexp 必须返回字符串
;; %<...>      插入时间戳信息
;; %t          插入日期
;; %T          插入日期与时间
;; %u, %U      同上，但时间戳用 [] 括起来
;; %i          调用 capture 命令时有选中的内容则插入选中的内容
;; %a          注记，通常是 org-store-link 创建的链接
;; %A          类似 %a，但提示输入链接的描述
;; %l          类似 %a，但仅插入文本链接
;; %c          当前 kill-ring 中的内容
;; %x          粘贴板的内容
;; %k          当前计时任务标题
;; %K          当前计时任务链接
;; %n          用户名，变量 user-full-name
;; %f          capture 命令调用时当前 buffer 对应文件名
;; %F          类似 %f，但显示全路径
;; %:keyword   Specific information for certain link types, see below.
;; %^g         提示输入 tag，target file 中的列表作为可选项
;; %^G         类似 %^g，但是有 agenda 中所有注册的文件中的 tag 作为可选项
;; %^t         类似 %t,但提示手动输入日期，类似还有 %^T， %^u， %^U                 You may define a prompt like %^{Birthday}t.
;; %^C         提示插入哪个 kill-ring 的内容
;; %^L         类似 %^C，但插入为链接
;; %^{prop}p   Prompt the user for a value for property prop.
;; %^{prompt}  prompt the user for a string and replace this sequence with it.
;;             You may specify a default value and a completion table with
;;             %^{prompt|default|completion2|completion3...}.
;;             The arrow keys access a prompt-specific history.
;; %\n         Insert the text entered at the nth %^{prompt}, where n is
;;             a number, starting from 1.
;; %?          After completing the template, position cursor here.

;; properties
      ;; :prepend 通常情况下,新捕获的内容会附加在target location的后面,而该属性会添加在target location的前面
      ;; :immediate-finish 该属性表示不需要显示capture buffer给用户输入更多的信息.直接返回就好. 若所有的信息都能够通过模板变量自动获得的情况下可以使用
      ;; :empty-lines 插入新捕获的内容时,前后空出多少个空行.
      ;; :clock-in 为新捕获的item开始计时
      ;; :clock-keep 若设置了clock-in,则在capture动作完成后,依然保持计时器的继续运行
      ;; :clock-resume
      ;; 若capture操作中断了对之前任务的计时,则在完成capture操作之后继续对之前任务进行计时.
      ;; 需要注意的是,:clock-keep的优先级高于:clock-resume,若两者都设置为t,则当前计时器会启动,而前一个计时器不会继续运行.
      ;; :unnarrowed 不要narrow target buffer,显示target buffer的所有内容. 默认情况下会narrow target buffer,让它只显示捕获新事物的那节点内容
      ;; :table-line-pos 设置capture的内容插入到table的位置. 它的格式类似于”II-3”,表示它是表格中第二部分(以——-分隔)的第三行
      ;; :kill-buffer 若target file是未打开的状态,则在capture完成之后,自动kill掉新打开的buffer




Emacs的配置
org capture的启用设定

在emacs的启动配置文件中，使用如下代码完成org capture的启用。

(setq org-default-notes-file (concat org-directory "~/notes.org"))
(define-key global-map "\C-cc" 'org-capture)

代码解释如下：

    (setq org-default-notes-file (concat org-directory "~/notes.org"))
    设定默认的片段存放文件名为Home目录中的“notes.org”文件。在Windows中“~/notes.org”也可以写做“d:/home/notes.org”

    (define-key global-map "\C-cc" 'org-capture)
    使用组合键“Ctrl-c c”激活org capture功能。当然，如果使用“Alt-x”组合键后输入 org-capture <enter> 也可以达到同样的目的。

配置模板

利用我们上面介绍的内容，我们可以开始定义我们要用到的模板信息：

(setq org-capture-templates
   '(("l" "灵感" entry (file+headline "~/写作创意.org" "创意")
          "* %?\n  %i\n  %a")
     ("j" "Journal" entry (file+datetree "~/journal.org")
          "* %?\n输入于： %U\n  %i\n  %a")))
          Capture的模板

          在Capture的基本使用流程之中，我们提到了一个名词“模板”。什么是模板？

          我们来试着定义一下，所谓的模板是：

              一个记录事件的加速系统，通过简单的几个按键就可以定位到一个具体的记录类别
              一个快速记录事件的框架，类似网站的表单，通些必要的字段即可完成事件记录。
              一个归档位置的快速定义，不同类别的记录可以按设定记录在不同的文件里，方便查询。

          一个有效的模板由以下几个部分组成：

              快捷键 - keys
              用于在列表中快速选择模板。支持单个字符。嗯，多个字符的快捷键有待进一步研究。
              描述 - description
              简单的描述模板的用途。这部分设定会出现在选择模板的过程中

              类型 - type
              模板的种类。目前支持的取值为：
                  entry
                  Org Mode的标题节点。使用中须指定Org文件的名称
                  item
                  一个简单列表中的项目。同样，这个类型的模板最终需要存储在org文件中。
                  checkitem
                  一个带有checkbox的项目。与item类型的模板相比，多了一个checkbox。
                  table-line
                  在指定位置表格添加一行新的记录。
                  plain
                  一段文字。如何输入的，就如何记录下来。

              注：org文件：扩展名为org的文本文件。遵循org mode定义的各类文本文件编写规则。目前Emacs对org mode的支持最好（org mode就是在emacs中用elisp编写开发的）。

              目标 - target
              用于定义收集得到的文字片段在文件的存储方式。一般来说，目标文件为一个org文件。收集得到的相关内容也会记录到相应的标题之下。最常用的target是：

                  指定文件名和文件中唯一的标题

                  (file+headline "path/to/file" "node headline")

                  指定文件名和完整的标题路径（如果需要存放片段的标题不唯一）

                  (file+olp "path/to/file" "Level 1 heading" "Level 2" ...)

                  指定日期方式的标题路径，在今天的日期下添加片段

                  (file+datetree "path/to/file")



                  4.3 预定义tag

                  上面提到，除了可以输入标签外，还可以从预定义的标签中进行选择。预定义的方式有两种：

                      在当前文件头部定义

                      这种方式预定义的标签只能在当前文件中使用。使用#+TAGS元数据进行标记，如：

                          #+TAGS: { 桌面(d) 服务器(s) }  编辑器(e) 浏览器(f) 多媒体(m) 压缩(z)    

                      每项之间必须用空格分隔，可以在括号中定义一个快捷键；花括号里的为标签组，只能选择一个

                      对标签定义进行修改后，要在标签定义的位置按 C-c C-c 刷新才能生效。
                      在配置文件中定义 上面的标签定义只能在当前文件生效，如果要在所有的.org 文件中生效，需要在 Emacs 配置文件 .emacs 中进行定义：
                      (setq org-tag-alist '(

                                          (:startgroup . nil)
                                               ("桌面" . ?d) ("服务器" . ?s)
                                          (:endgroup . nil)
                                          ("编辑器" . ?e)
                                          ("浏览器" . ?f)
                                          ("多媒体" . ?m)
                                          ))    

                  默认情况下，org会动态维护一个Tag列表，即当前输入的标签若不在列表中，则自动加入列表以供下次补齐使用。

                  为了使这几种情况（默认列表、文件预设tags，全局预设tags）同时生效，需要在文件中增加一个空的TAGS定义：

                      #+TAGS:
