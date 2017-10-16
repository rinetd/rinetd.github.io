---
title: Activity详解
date: 2016-01-11T14:10:29+08:00
update: 2016-01-01
categories: [Android]
tags: [Activity]
---
[Activity四种启动模式详解](http://blog.csdn.net/zhangjg_blog/article/details/10923643)
[Android生命周期](http://www.cnblogs.com/feisky/archive/2010/01/01/1637427.html)
[理解Fragment生命周期](http://blog.csdn.net/forever_crying/article/details/8238863/)

## Activity四种启动模式详解

1. standard       `［多任务，多实例］ 可重复启动`
2. singleTop      `［栈顶单任务，多实例］任务桟的桟顶，不再启动新实例`
3. singleTask     `［单任务、多实例］ 如果系统中已经存在这样一个实例，就会将这个实例调度到任务栈的栈顶，并清除它当前所在任务中位于它上面的所有的activity`
4. singleInstance `［单任务、单实例］ `
如果要使用这四种启动模式，必须在manifest文件中<activity>标签中的launchMode属性中配置，如：
```
   <activity android:name=".app.InterstitialMessageActivity"  
             android:label="@string/interstitial_label"  
             android:theme="@style/Theme.Dialog"  
             android:launchMode="singleTask"  
   </activity>  
```

## Activity的生命周期

Android中，Activity是所有程序的根本，所有程序的流程都运行在Activity之中，Activity具有自己的生命周期（见http://www.cnblogs.com/feisky/archive/2010/01/01/1637427.html，由系统控制生命周期，程序无法改变，但可以用onSaveInstanceState保存其状态）。

对于Activity，关键是其生命周期的把握（如下图），其次就是状态的保存和恢复（onSaveInstanceState onRestoreInstanceState），以及Activity之间的跳转和数据传输（intent）。

activity_lifecycle

Activity中常用的函数有SetContentView()   findViewById()    finish()   startActivity()，其生命周期涉及的函数有：

注意的是，Activity的使用需要在Manifest文件中添加相应的<Activity>，并设置其属性和intent-filter。

Android使用Task管理活动，一个Task是一组栈里活动的集合
栈：后进先出
Activity的状态：运行状态，暂停状态，停止状态，销毁状态

Activity的生命周期：
onCreate(Bundle savedInstanceState)      第一次被创建时调用，完成初始化的操作。
onStart()       方法由不可见变为可见的时候调用。
onResume()      准备好和用户进行交互的时候调用，活动处于栈顶的位置
onPause()       系统准备启动或者恢复另一个活动时调用。通常释放一些消耗CPU的资源、保存一些关键数据
onStop()        活动完全不可见的时候调用
onDestroy()     活动被销毁钱调用，之后活动会变为销毁状态
onRestart()     停止变为运行状态之前调用

三种生存期：
完整生存期：onCreate()-->onDestory()
可见生存期：onStart()-->onStop()
前台生存期：onResume()-->onPause()
![Activity生命周期](http://img.mukewang.com/56fa0c6f0001086105130663.png)
![Fragment的生命周 ](http://img.my.csdn.net/uploads/201211/29/1354170699_6619.png)
![Fragment与Activity生命周期的对比](http://img.my.csdn.net/uploads/201211/29/1354170682_3824.png)

场景演示 : 切换到该Fragment

11-29 14:26:35.095: D/AppListFragment(7649): onAttach
11-29 14:26:35.095: D/AppListFragment(7649): onCreate
11-29 14:26:35.095: D/AppListFragment(7649): onCreateView
11-29 14:26:35.100: D/AppListFragment(7649): onActivityCreated
11-29 14:26:35.120: D/AppListFragment(7649): onStart
11-29 14:26:35.120: D/AppListFragment(7649): onResume

屏幕灭掉：

11-29 14:27:35.185: D/AppListFragment(7649): onPause
11-29 14:27:35.205: D/AppListFragment(7649): onSaveInstanceState
11-29 14:27:35.205: D/AppListFragment(7649): onStop


屏幕解锁

11-29 14:33:13.240: D/AppListFragment(7649): onStart
11-29 14:33:13.275: D/AppListFragment(7649): onResume


切换到其他Fragment:
11-29 14:33:33.655: D/AppListFragment(7649): onPause
11-29 14:33:33.655: D/AppListFragment(7649): onStop
11-29 14:33:33.660: D/AppListFragment(7649): onDestroyView


切换回本身的Fragment:

11-29 14:33:55.820: D/AppListFragment(7649): onCreateView
11-29 14:33:55.825: D/AppListFragment(7649): onActivityCreated
11-29 14:33:55.825: D/AppListFragment(7649): onStart
11-29 14:33:55.825: D/AppListFragment(7649): onResume

回到桌面

11-29 14:34:26.590: D/AppListFragment(7649): onPause
11-29 14:34:26.880: D/AppListFragment(7649): onSaveInstanceState
11-29 14:34:26.880: D/AppListFragment(7649): onStop

回到应用

11-29 14:36:51.940: D/AppListFragment(7649): onStart
11-29 14:36:51.940: D/AppListFragment(7649): onResume


退出应用

11-29 14:37:03.020: D/AppListFragment(7649): onPause
11-29 14:37:03.155: D/AppListFragment(7649): onStop
11-29 14:37:03.155: D/AppListFragment(7649): onDestroyView
11-29 14:37:03.165: D/AppListFragment(7649): onDestroy
11-29 14:37:03.165: D/AppListFragment(7649): onDetach


比Activity多了一些生命周期，完整和Activity对接上，大家好好利用。
