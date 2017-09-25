# zprototype
animate(flash) actionscript APP原型模版 v03
#### 基于Animate／Flash的快速原型模版，无需任何AS动作编码就能快速实现页面切换和动画播放控制交互效果。

请直接下载最新版本中的zprototype_vx.swf文件查看动态演示效果.

---
此项目仅供内部培训使用，未经作者许可，任何人不得将其用于任何商业项目。
如有需要请与作者联系QQ286052520

---
### 最近更新
v3
1. 增加新的过场动画right(原fly),left(原fly2）,down,up,fade.
1. 初始化添加home页面的同时自动清理舞台上的page页面.
1. 支持嵌套元件命名的$go_和$this_命令,但请勿在嵌套中重叠使用$命令命名.
1. 支持页面外元件命名使用$命令，不必须把元件放在page内.
1. 优化性能，每次换页不再重复创建页面；如果$go_当前页将产生不恰当的动画.

---
### 安装说明
Animate／Flash新建项目，属性面板【类】填写main,然后将main.js拷贝到项目保存的文件夹内。
Enjoy it！

---
### 使用说明
1. 设定首页：在库面板中将你的影片剪辑【链接】设定为$page_home,无需把它放到舞台，程序会自动添加。
1. 设定其他页面：同样在库面板中将其他页面的影片剪辑的链接设定为$page_开头的名称，例如$page_list,$page_fenlei等。
1. 添加换页动画：选择任意页面内的任意元件（影片剪辑／按钮），在属性面板把它的名称设置为$go_list或其他页面名称，此时ctrl+enter回车预览，点击此按钮即可实现换页。
1. 添加后退动画：同上，将任意元件属性面板内名称设定为$go_back即可实现点击后退到上一页的效果。
1. 添加常用点击事件：同上，将任意元件属性面板内名称设定为$this_开头的命令，例如$this_mcname_gotoAndStop$5表示与此元件舞台内同级的名称为mcname的元件，跳转到第5帧并停止；又如$this_parent_mc_gotoAndPlay$10表示当前元件所在层级的父层内查找名称为mc的元件，让其从第10帧开始播放。

---
### 更多技巧
1. 默认换页使用从从右侧飞入新页面，当前页面往左侧飞出的设定，即$go_pagename$fly模式（默认的$fly可以被省略）；目前v02支持$fly2方式，即$go_pagename$fly2，从左侧飞入新页面，当前页向右飞出。更多方式将在后续版本中支持。
1. 可以将需要滚动的内容单独做成长swf，然后通过元件【滚动面板／scrollpane】的【源／source】文件路径引入（产品发布设置中需要添加打包此swf文件）。外部swf中的$go_pagename换页和$this_mcname_cmdname$frame命名也将被自动支持。但v02版本目前不支持外部swf文件库中的$page_链接命名。
1. 库面板的命名$page可以简写做$p,例如$p_home.


---