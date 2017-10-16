---
title: Android Intent 详解
date: 2016-01-11T14:10:29+08:00
update: 2016-01-01
categories: [Android]
tags: [Intent]
---
[第十章：Intent详解](http://www.cnblogs.com/engine1984/p/4146621.html)
[android intent和intent action大全](http://www.cnblogs.com/playing/archive/2010/09/15/1826918.html)
[Android Activity和Intent机制学习笔记](http://www.cnblogs.com/feisky/archive/2010/01/16/1649081.html?t=1354241162250)
---
1.Intent的用法：
(1)用Action跳转
1、使用Action跳转，如果有一个程序的AndroidManifest.xml中的某一个 Activity的IntentFilter段中 定义了包含了相同的Action那么这个Intent就与这个目标Action匹配。如果这个IntentFilter段中没有定义 Type,Category，那么这个 Activity就匹配了。但是如果手机中有两个以上的程序匹配，那么就会弹出一个对话可框来提示说明。
Action 的值在Android中有很多预定义，如果你想直接转到你自己定义的Intent接收者，你可以在接收者的IntentFilter 中加入一个自定义的Action值（同时要设定 Category值为"android.intent.category.DEFAULT"），在你的Intent中设定该值为Intent的 Action,就直接能跳转到你自己的Intent接收者中。因为这个Action在系统中是唯一的。
2,data/type，你可以用Uri 来做为data,比如Uri uri = Uri.parse(http://www.google.com);
Intent i = new Intent(Intent.ACTION_VIEW,uri);手机的Intent分发过程中，会根据http://www.google.com 的scheme判断出数据类型type 。手机的Brower则能匹配它，在Brower的Manifest.xml中的IntenFilter中 首先有ACTION_VIEW Action,也能处理http:的type，
3， 至于分类Category，一般不要去在Intent中设置它，如果你写Intent的接收者，就在Manifest.xml的Activity的 IntentFilter中包含android.category.DEFAULT,这样所有不设置 Category（Intent.addCategory(String c);）的Intent都会与这个Category匹配。
4,extras（附 加信息），是其它所有附加信息的集合。使用extras可以为组件提供扩展信息，比如，如果要执行“发送电子邮件”这个动 作，可以将电子邮件的标题、正文等保存在extras里，传给电子邮件发送组件。
（2）用类名跳转
    Intent负责对应用中一次操作的动作、动作涉及数据、附加数据进行描 述，Android则根据此Intent的描述， 负责找到对应的组件，将 Intent传递给调用的组件，并完成组件的调用。Intent在这里起着实现调用者与被调用者之间的解耦作用。Intent传递过程中，要找 到目标消费者（另一个Activity,IntentReceiver或Service），也就是Intent的响 应者。
Intent intent = new Intent();
intent.setClass(context, targetActivy.class);
//或者直接用 Intent intent = new Intent(context, targetActivity.class);

startActivity(intent);
不过注意用类名跳转，需要在AndroidManifest.xml中申明activity  
<activity android:name="targetActivity"></activity>
######
Intent *意图* 组件虽然不是四大组件，但却是连接四大组件的桥梁

Android中提供了Intent机制来协助应用间的交互与通讯，Intent负责对应用中一次操作的动作、动作涉及数据、附加数据进行描述，Android则根据此Intent的描述，负责找到对应的组件，将 Intent传递给调用的组件，并完成组件的调用。Intent不仅可用于应用程序之间，也可用于应用程序内部的Activity/Service之间的交互。因此，Intent在这里起着一个媒体中介的作用，专门提供组件互相调用的相关信息，实现调用者与被调用者之间的解耦。在SDK中给出了Intent作用的表现形式为：
对于向这三种组件发送intent有不同的机制：
### 对于向这三种组件发送intent有不同的机制：

    使用`Context.startActivity()` 或 `Activity.startActivityForResult()`，传入一个intent来启动一个activity。使用 `Activity.setResult()`，传入一个intent来从activity中返回结果
    将intent对象传给`Context.startService()`来启动一个service或者传消息给一个运行的service。将intent对象传给 `Context.bindService()`来绑定一个service。
    将intent对象传给 `Context.sendBroadcast()`，`Context.sendOrderedBroadcast()`，或者`Context.sendStickyBroadcast()`等广播方法，则它们被传给 broadcast receiver。

    通过 `Context.startActivity()` or`Activity.startActivityForResult()` 启动一个Activity；
    通过 `Context.startService()` 启动一个服务，或者通过`Context.bindService()` 和后台服务交互；
    通过广播方法(比如 `Context.sendBroadcast()`,`Context.sendOrderedBroadcast()`,  `Context.sendStickyBroadcast()`) 发给broadcast receivers。
### Intent的相关属性：
        Intent由以下各个组成部分：
        component(组件)：目的组件
        action（动作）：用来表现意图的行动
        category（类别）：用来表现动作的类别
        data（数据）：表示与动作要操纵的数据
        type（数据类型）：对于data范例的描写
        extras（扩展信息）：扩展信息
        Flags（标志位）：期望这个意图的运行模式

# 理解Intent的关键之一是理解清楚Intent的两种基本用法
    一种是显式的Intent，即在构造Intent对象时就指定接收者；另一种是隐式的Intent，即Intent的发送者在构造Intent对象时，并不知道也不关心接收者是谁，有利于降低发送者和接收者之间的耦合。

    对于显式Intent，Android不需要去做解析，因为目标组件已经很明确，Android需要解析的是那些隐式Intent，通过解析，将 Intent映射给可以处理此Intent的Activity、IntentReceiver或Service。        

    Intent解析机制主要是通过查找已注册在AndroidManifest.xml中的所有IntentFilter及其中定义的Intent，最终找到匹配的Intent。在这个解析过程中，Android是通过Intent的action、type、category这三个属性来进行判断的，判断方法如下：

        如果Intent指明定了action，则目标组件的IntentFilter的action列表中就必须包含有这个action，否则不能匹配；
        如果Intent没有提供type，系统将从data中得到数据类型。和action一样，目标组件的数据类型列表中必须包含Intent的数据类型，否则不能匹配。
        如果Intent中的数据不是content: 类型的URI，而且Intent也没有明确指定它的type，将根据Intent中数据的scheme （比如 http: 或者mailto:） 进行匹配。同上，Intent 的scheme必须出现在目标组件的scheme列表中。
        如果Intent指定了一个或多个category，这些类别必须全部出现在组建的类别列表中。比如Intent中包含了两个类别：LAUNCHER_CATEGORY 和 ALTERNATIVE_CATEGORY，解析得到的目标组件必须至少包含这两个类别。

    Intent-Filter的定义

    一些属性设置的例子：
    ```
    <action android:name="com.example.project.SHOW_CURRENT" />
    <category android:name="android.intent.category.DEFAULT" />
    <data android:mimeType="video/mpeg" android:scheme="http" . . . />
    <data android:mimeType="image/*" />
    <data android:scheme="http" android:type="video/*" />
    ```
    完整的实例
    ```
    <activity android:name="NotesList" android:label="@string/title_notes_list">
        <intent-filter>
            <action android:name="android.intent.action.MAIN" />
            <category android:name="android.intent.category.LAUNCHER" />
        </intent-filter>
        <intent-filter>
            <action android:name="android.intent.action.VIEW" />
            <action android:name="android.intent.action.EDIT" />
            <action android:name="android.intent.action.PICK" />
            <category android:name="android.intent.category.DEFAULT" />
            <data android:mimeType="vnd.android.cursor.dir/vnd.google.note" />
        </intent-filter>
        <intent-filter>
            <action android:name="android.intent.action.GET_CONTENT" />
            <category android:name="android.intent.category.DEFAULT" />
            <data android:mimeType="vnd.android.cursor.item/vnd.google.note" />
        </intent-filter>
    </activity>

    ```


Intent属性的设置，包括以下几点：（以下为XML中定义，当然也可以通过Intent类的方法来获取和设置）

## （1）Action，也就是要执行的动作

SDk中定义了一些标准的动作，包括
onstant 	Target component 	Action
ACTION_CALL 	activity 	Initiate a phone call.
ACTION_EDIT 	activity 	Display data for the user to edit.
ACTION_MAIN 	activity 	Start up as the initial activity of a task, with no data input and no returned output.
ACTION_SYNC 	activity 	Synchronize data on a server with data on the mobile device.
ACTION_BATTERY_LOW 	broadcast receiver 	A warning that the battery is low.
ACTION_HEADSET_PLUG 	broadcast receiver 	A headset has been plugged into the device, or unplugged from it.
ACTION_SCREEN_ON 	broadcast receiver 	The screen has been turned on.
ACTION_TIMEZONE_CHANGED 	broadcast receiver 	The setting for the time zone has changed.

当然，也可以自定义动作（自定义的动作在使用时，需要加上包名作为前缀，如"com.example.project.SHOW_COLOR”），并可定义相应的Activity来处理我们的自定义动作。

## （2）Data，也就是执行动作要操作的数据
Android中采用指向数据的一个URI来表示，如在联系人应用中，一个指向某联系人的URI可能为：content://contacts/1。对于不同的动作，其URI数据的类型是不同的（可以设置type属性指定特定类型数据），如ACTION_EDIT指定Data为文件URI，打电话为tel:URI，访问网络为http:URI，而由content provider提供的数据则为content: URIs。

## （3）type（数据类型），
显式指定Intent的数据类型（MIME）。一般Intent的数据类型能够根据数据本身进行判定，但是通过设置这个属性，可以强制采用显式指定的类型而不再进行推导。

## （4）category（类别），
被执行动作的附加信息。例如 LAUNCHER_CATEGORY 表示Intent 的接受者应该在Launcher中作为顶级应用出现；而ALTERNATIVE_CATEGORY表示当前的Intent是一系列的可选动作中的一个，这些动作可以在同一块数据上执行。还有其他的为
Constant 	Meaning
CATEGORY_BROWSABLE 	The target activity can be safely invoked by the browser to display data referenced by a link — for example, an image or an e-mail message.
CATEGORY_GADGET 	The activity can be embedded inside of another activity that hosts gadgets.
CATEGORY_HOME 	The activity displays the home screen, the first screen the user sees when the device is turned on or when the HOME key is pressed.
CATEGORY_LAUNCHER 	The activity can be the initial activity of a task and is listed in the top-level application launcher.
CATEGORY_PREFERENCE 	The target activity is a preference panel.

## （5）component（组件），
指定Intent的的目标组件的类名称。通常 Android会根据Intent 中包含的其它属性的信息，比如action、data/type、category进行查找，最终找到一个与之匹配的目标组件。但是，如果 component这个属性有指定的话，将直接使用它指定的组件，而不再执行上述查找过程。指定了这个属性以后，Intent的其它所有属性都是可选的。

## （6）extras（附加信息），
是其它所有附加信息的集合。使用extras可以为组件提供扩展信息，比如，如果要执行“发送电子邮件”这个动作，可以将电子邮件的标题、正文等保存在extras里，传给电子邮件发送组件。
