---
title: Android应用开发
date: 2016-01-11T14:10:29+08:00
update: 2016-01-01
categories: [Android]
tags:
---
Toast定义为全局，避免一直不断的吐吐吐吐。


public class MToast {  
    private static Toast mToast;  

    private static TextView tv_content;  

    public static void showToast(Context context, String msg) {  
        try {  

            if (mToast == null) {  
                mToast = Toast.makeText(context, msg, Toast.LENGTH_SHORT);  
                mToast.setGravity(Gravity.TOP, 0,  
                        DensityUtil.dip2px(context, 3));  
                View view = View.inflate(context, R.layout.m_toast, null);  
                tv_content = (TextView) view.findViewById(R.id.tv_content);  
                mToast.setView(view);  
                tv_content.setText(msg);  
            } else {  
                tv_content.setText(msg);  
            }  
            mToast.show();  
        } catch (Exception e) {  
            // TODO: handle exception  
        }  
    }  
}  

标题栏样式抽取，抽取思路大概有两种，第一种：用<inlcude>标签在xml布局时引入，第二种：自定义一个TitleView，千万不要偷懒节省这个步骤。指不定那天产品就要让你改个样式，到时候你就哭吧。不仅仅是标题栏，字体大小，主题颜色，能抽取的都统一处理，产品的心和女人的新一样，说变就变。

TextView.setText()；中要显示int类型的值，用String.valueOf()转，不要直接124+“”，不知道为什么这样的同学，基础太差，去看看源码就知道为什么了。

退出应用方式，1.直接杀死进程 2.在BaseActivity中注册一个广播，发送广播关闭 3.定义一个全局容器存储Activity应用，退出时遍历退出（不推荐）

一个功能分几个页面处理时，使用Dialog 模拟Activity 避免了数据在Activity之间传递。

手机重启，知乎上看到滴，通过不断的new 空Toast，导致系统奔溃而重启，想想竟有一种无言以对的感觉，原来Toast还可以尼玛这么玩


public void onClick(View v){  
       while(true){  
            Toast toast = new Toast(this);  
             toast.setView(new View(this));  
             toast.show();  
     }  

}  

View类中的setSelected(boolean)方法结合android:state_selected="" 用来实现图片选中效果 自定义标题栏用起来很方便；
EditText 中有个 android:digits="" 属性，用来自定义输入的字符类型，比如输入身份证只能是数字和x或者X 使用 android:digits="1234567890xX" 就轻松搞定了，不用再在代码里面进行蛋疼的校验了；
