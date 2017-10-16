---
title: 四大组件之 Service
date: 2016-01-11T14:10:29+08:00
update: 2016-01-01
categories: [Android]
tags:
---
Service,四大组件之一,是一个可以在后台执行长时间运行操作而不使用用户界面的应用组件。服务可由其他应用组件启动，而且即使用户切换到其他应用，服务仍将在后台继续运行。 此外，组件可以绑定到服务，以与之进行交互，甚至是执行进程间通信 (IPC)。 例如，服务可以处理网络事务、播放音乐，执行文件 I/O 或与内容提供程序交互，而所有这一切均可在后台进行。

但是必须要提的是,虽然说是后台,但是Service运行在主线程!
PS:Service的官方文档有中文翻译了!!真是个大好的消息!
![service生命周期](http://ww1.sinaimg.cn/large/98900c07gw1exausnlz6xj20at0e3tan.jpg)

跟Activity类似,service也有自己的生命周期,但是简单了一些.
service_lifecycle
Service的基本使用

上面的生命周期已经提示到了,使用Service有两种方式,启动/停止,绑定/解绑,一一对应:

    startService stopService(启动)
    bindService unbindService(绑定)
    还有一种就是即调用start,又调用bind(又启动又绑定)

这几个方式都有什么区别呢?
不急,咱慢慢来,一一解答.

<!-- more -->

咱先写个MyService,继承service,重写他的各种方法,并加入打印日志(这是我学习最常用的办法).
写几个按钮调用不同方法,再加个ServiceConnection,代码就不给全了,没难度,不过要注意Service要在xml里配置
```
<service
    android:name=".service.MyService"
    android:enabled="true"
    android:exported="false">
</service>
```
解释一下xml的属性:

    enabled: 是否能被系统实例化,false就用不了了
    exported: 其他应用的组件是否能跟它交互,false表示私有只能自己应用使用,true表示可以被其他应用调起

对于xml的配置,官方有些建议:

    为了确保应用的安全性，请始终使用显式 Intent 启动或绑定 Service，且不要为服务声明 Intent 过滤器。
    添加 android:exported 属性并将其设置为 "false"，确保服务仅适用于您的应用。这可以有效阻止其他应用启动您的服务，即便在使用显式 Intent 时也如此。

点击事件:

@OnClick({R.id.start_service, R.id.stop_service, R.id.bind_service, R.id.unbind_service})
public void onClick(View view) {

    Intent intent = new Intent(ServiceActivity.this,MyService.class);
    switch (view.getId()) {
        case R.id.start_service:
            startService(intent);
            break;
        case R.id.stop_service:
            stopService(intent);
            break;
        case R.id.bind_service:
            bindService(intent,con, Service.BIND_AUTO_CREATE);
            break;
        case R.id.unbind_service:
            unbindService(con);
            break;
    }
}

//bindservice 需要
ServiceConnection con = new ServiceConnection() {
    @Override
    public void onServiceConnected(ComponentName name, IBinder service) {
        Log.d(TAG, "onServiceConnected() called with: " + "name = [" + name + "], service = [" + service + "]");
        ((MyService.MyBinder)service).dosth();
    }

    @Override
    public void onServiceDisconnected(ComponentName name) {
        Log.d(TAG, "onServiceDisconnected() called with: " + "name = [" + name + "]");
    }
};

PS:bindService的参数BIND_AUTO_CREATE表示在Activity和Service建立关联后自动创建Service，这会使得MyService中的onCreate()方法得到执行，但onStartCommand()方法不会执行。(来自guolin的博客)
startService&stopService
startService

使用startService启动service:
第一次启动service会调用onCreate,onStartCommand,而后面的则不会再调用onCreate而是onStartCommand,并且每次startId不同.

注意是启动,启动后,这样在手机设置-正在运行界面会显示有MyService存在.

D/MyService: onCreate:
D/MyService: onStartCommand()
//第二次startService
D/MyService: onStartCommand()

stopService

调用stopService,情况如下:

    如果service已经通过startService启动,则onDestroy
    如果service没启动,则没什么效果

    D/MyService: onDestroy:

    stopService之后,正在运行界面不会有MyService存在了.

PS:如果不调用stop,直接关掉Activity对Service没影响,即两者的生命周期没有关联.
bindService&unbindService

用到bind跟之前的startService不同,我们还需要重写onBind,添加Bind类:

@Override
public IBinder onBind(Intent intent) {
    Log.d(TAG, "onBind: ");
    return new MyBinder();
}

public class MyBinder extends Binder{

    public void dosth(){
        Log.d(TAG, "dosth: ");
    }
}

bindService

bindService作用是跟service进行绑定.
文档介绍:
绑定服务是客户端-服务器接口中的服务器。
绑定服务可让组件（例如 Activity）绑定到服务、发送请求、接收响应，甚至执行进程间通信 (IPC)。
绑定服务通常只在为其他应用组件服务时处于活动状态，不会无限期在后台运行。

点击bind按钮,发现MyService调用了onCreate和onBind,并且之前的ServiceConnection里的onServiceConnected也被调用了.
注意:

    跟startService不同的是,多次调用bindService没有效果,不会再多调用onBind**
    如果onBind里我们返回null那么onServiceConnected不会被调用
    不同于startService,bind调用后,设置-正在运行里是看不到有Service运行着的.

    D/MyService: onCreate:
    D/MyService: onBind:
    D/MyService: onServiceConnected()
    D/MyService: dosth:

unbindService

unbindService是用于解绑,取消关联

    如果没用bindService启动过service(注意:即使是startService启动的也不行),直接调用unbindService,则会崩溃:

    java.lang.IllegalArgumentException: Service not registered: yifeiyuan.practice.practicedemos.service.ServiceActivity$1@535f696c

    如果已经用bindService启动过,则会停止service

D/MyService: onUnbind:
D/MyService: onDestroy:

PS:如果不调用onUnbind,直接关掉Activity,跟unBind效果一样,也就是说两者生命周期相同,共存亡.

看到这里,我发现很奇怪的是,我们ServiceConnection里的onServiceDisconnected方法并没有被调用.
于是跟踪了一下方法的说明:

Called when a connection to the Service has been lost.  This typically
happens when the process hosting the service has crashed or been killed.
This does <em>not</em> remove the ServiceConnection itself -- this
binding to the service will remain active, and you will receive a call
to {@link #onServiceConnected} when the Service is next running.

官方文档中也有提到:
Android 系统会在与服务的连接意外中断时（例如当服务崩溃或被终止时）调用该方法。当客户端取消绑定时，系统“绝对不会”调用该方法。

自己尝试去设置界面停止服务,强杀应用,也没发现它调用!.
startService和bindService组合启动

先start后bind:

D/MyService: onCreate:
D/MyService: onStartCommand:
D/MyService: onBind:
D/MyService: onServiceConnected()
D/MyService: dosth:

尝试结束解绑service:

    先stop 效果: Service停止了(运行界面看不到Service),但是没有onDestory的日志,即没销毁

    再unbind 效果: 输出onUnbind和onDestroy,并销毁
    先unbind 效果:输出日志onUnbind,没销毁
    后stop 效果:输出日志onDestroy Service停止了,并销毁

结果: unbind后出现onUnbind,stop后出现onDestroy.

那这个是为什么呢?
因为:服务有两种状态,一种已启动,另外一种已绑定,并且当且仅当服务没有状态时才会销毁.
start和bind的区别

    start启动的service与组件生命周期无关,bind的service与组件的生命周期绑定,共存亡
    start给service一种已启动的状态,bind给的是绑定状态
    广播不能绑定service,但能启动service

另外一些回调

我按Home回桌面的时候,回调了onTrimMemory,其他暂时不知.

D/MyService: onCreate:
D/MyService: onBind:
D/MyService: onServiceConnected()
D/MyService: dosth:
D/MyService: onTrimMemory:

在前台运行服务

前面说到service是后台,所以呢service可能会被杀死.
前台服务被认为是用户主动意识到的一种服务，因此在内存不足时，系统也不会考虑将其终止。
前台服务必须为状态栏提供通知!

这种非常常见,比如网易云音乐播放音乐的时候就会有通知在通知栏~

通过startForeground来让服务运行于前台:

Notification notification = new Notification(R.drawable.icon, getText(R.string.ticker_text),System.currentTimeMillis());
Intent notificationIntent = new Intent(this, ExampleActivity.class);
PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, notificationIntent, 0);
notification.setLatestEventInfo(this, getText(R.string.notification_title),getText(R.string.notification_message), pendingIntent);
startForeground(ONGOING_NOTIFICATION_ID, notification);

可以通过stopForeground(boolean removeNotification)来停止.
removeNotification代表 是否也删除状态栏通知。
需要注意的是: 此方法绝对不会停止服务。 但是，如果您在服务正在前台运行时将其停止，则通知也会被删除。
Service通信

Service与Activity通信的除了之前所说的bind进行绑定之外,还可以选择:

    发送广播
    使用EventBus/Otto等事件订阅发送框架(推荐这个,更加方便)

跨进程通信(IPC):

    AIDL
    Messenger

官方资料:
使用Messenger是执行进程间通信 (IPC) 的最简单方法,因为 Messenger 会在单一线程中创建包含所有请求的队列，这样您就不必对服务进行线程安全设计。

这些AIDL跟Messenger的例子官网都有,就不写了,官方的资料总是最好的~

    PS: Android Interface Definition Language (AIDL)

处理Service的onStartCommand返回值

来源于官方文档:
onStartCommand() 方法必须返回整型数,用于描述系统应该如何在服务终止的情况下继续运行服务.

从 onStartCommand() 返回的值必须是以下常量之一：

    START_NOT_STICKY
    如果系统在 onStartCommand() 返回后终止服务，则除非有挂起 Intent 要传递，否则系统 不会重建服务。
    这是最安全的选项,可以 避免在不必要时以及应用能够轻松重启所有未完成的作业时运行服务。
    START_STICKY
    如果系统在 onStartCommand() 返回后终止服务，则会 重建服务并调用 onStartCommand(),但绝对不会重新传递最后一个 Intent.
    相反，除非有挂起 Intent 要启动服务（在这种情况下，将传递这些 Intent ），否则系统会通过 空Intent 调用 onStartCommand()。
    这适用于 不执行命令、但无限期运行并等待作业的媒体播放器(或类似服务)。
    START_REDELIVER_INTENT
    如果系统在 onStartCommand() 返回后终止服务，则会 重建服务，并通过 传递给服务的最后一个 Intent 调用 onStartCommand()。
    任何挂起 Intent 均依次传递。这适用于主动执行应该立即恢复的作业（例如下载文件）的服务。

小结:

    START_STICKY,START_REDELIVER_INTENT 会重启服务
    START_STICKY 会传递null的intent
    START_REDELIVER_INTENT 会传递最后一个intent

总结

诶,学android一年了才来学习Service也真是给跪了,平时也不怎么用到service就用来下载文件.
之前说到service是主线程运行的,还需要自己开线程,而且多线程不安全,很坑,还好我们还有IntentService.
接下去就学习IntentService去~
更多资料

    绑定服务
    Android Interface Definition Language(AIDL)
    http://blog.csdn.net/guolin_blog/article/details/11952435
    http://blog.csdn.net/guolin_blog/article/details/9797169
