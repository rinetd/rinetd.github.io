---
title: Android Activity和Intent机制学习笔记
date: 2016-01-11T14:10:29+08:00
update: 2016-01-01
categories: [Android]
tags:
---
[](blog.csdn.net/zhangjg_blog/article/details/10901293)
Intent用法实例
1.无参数Activity跳转
```
  Intent it = new Intent(Activity.Main.this, Activity2.class);
  startActivity(it);   
```
2.向下一个Activity传递数据（使用Bundle和Intent.putExtras）
```
Intent it = new Intent(Activity.Main.this, Activity2.class);
Bundle bundle=new Bundle();
bundle.putString("name", "This is from MainActivity!");
it.putExtras(bundle);       // it.putExtra(“test”, "shuju”);
startActivity(it);            // startActivityForResult(it,REQUEST_CODE);
```
对于数据的获取可以采用：
```
Bundle bundle=getIntent().getExtras();
String name=bundle.getString("name");
```


3.向上一个Activity返回结果（使用setResult，针对startActivityForResult(it,REQUEST_CODE)启动的Activity）
```
        Intent intent=getIntent();
        Bundle bundle2=new Bundle();
        bundle2.putString("name", "This is from ShowMsg!");
        intent.putExtras(bundle2);
        setResult(RESULT_OK, intent);
```
4.回调上一个Activity的结果处理函数（onActivityResult）
```
@Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        // TODO Auto-generated method stub
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode==REQUEST_CODE){
            if(resultCode==RESULT_CANCELED)
                  setTitle("cancle");
            else if (resultCode==RESULT_OK) {
                 String temp=null;
                 Bundle bundle=data.getExtras();
                 if(bundle!=null)   temp=bundle.getString("name");
                 setTitle(temp);
            }
        }
    }
```

★intent大全：
1.从google搜索内容
Intent intent = new Intent();
intent.setAction(Intent.ACTION_WEB_SEARCH);
intent.putExtra(SearchManager.QUERY,"searchString")
startActivity(intent);

2.浏览网页
Uri uri = Uri.parse("http://www.google.com");
Intent it  = new Intent(Intent.ACTION_VIEW,uri);
startActivity(it);

3.显示地图
Uri uri = Uri.parse("geo:38.899533,-77.036476");
Intent it = new Intent(Intent.Action_VIEW,uri);
startActivity(it);

4.路径规划
Uri uri = Uri.parse("http://maps.google.com/maps?f=dsaddr=startLat%20startLng&daddr=endLat%20endLng&hl=en");
Intent it = new Intent(Intent.ACTION_VIEW,URI);
startActivity(it);

5.拨打电话
Uri uri = Uri.parse("tel:xxxxxx");
Intent it = new Intent(Intent.ACTION_DIAL, uri);   
startActivity(it);

6.调用发短信的程序
Intent it = new Intent(Intent.ACTION_VIEW);    
it.putExtra("sms_body", "The SMS text");    
it.setType("vnd.android-dir/mms-sms");    
startActivity(it);

7.发送短信
Uri uri = Uri.parse("smsto:0800000123");    
Intent it = new Intent(Intent.ACTION_SENDTO, uri);    
it.putExtra("sms_body", "The SMS text");    
startActivity(it);
String body="this is sms demo";
Intent mmsintent = new Intent(Intent.ACTION_SENDTO, Uri.fromParts("smsto", number, null));
mmsintent.putExtra(Messaging.KEY_ACTION_SENDTO_MESSAGE_BODY, body);
mmsintent.putExtra(Messaging.KEY_ACTION_SENDTO_COMPOSE_MODE, true);
mmsintent.putExtra(Messaging.KEY_ACTION_SENDTO_EXIT_ON_SENT, true);
startActivity(mmsintent);

8.发送彩信
Uri uri = Uri.parse("content://media/external/images/media/23");    
Intent it = new Intent(Intent.ACTION_SEND);    
it.putExtra("sms_body", "some text");    
it.putExtra(Intent.EXTRA_STREAM, uri);    
it.setType("image/png");    
startActivity(it);
StringBuilder sb = new StringBuilder();
sb.append("file://");
sb.append(fd.getAbsoluteFile());
Intent intent = new Intent(Intent.ACTION_SENDTO, Uri.fromParts("mmsto", number, null));
// Below extra datas are all optional.
intent.putExtra(Messaging.KEY_ACTION_SENDTO_MESSAGE_SUBJECT, subject);
intent.putExtra(Messaging.KEY_ACTION_SENDTO_MESSAGE_BODY, body);
intent.putExtra(Messaging.KEY_ACTION_SENDTO_CONTENT_URI, sb.toString());
intent.putExtra(Messaging.KEY_ACTION_SENDTO_COMPOSE_MODE, composeMode);
intent.putExtra(Messaging.KEY_ACTION_SENDTO_EXIT_ON_SENT, exitOnSent);
startActivity(intent);

9.发送Email
Uri uri = Uri.parse("mailto:xxx@abc.com");
Intent it = new Intent(Intent.ACTION_SENDTO, uri);
startActivity(it);
Intent it = new Intent(Intent.ACTION_SEND);    
it.putExtra(Intent.EXTRA_EMAIL, "me@abc.com");    
it.putExtra(Intent.EXTRA_TEXT, "The email body text");    
it.setType("text/plain");    
startActivity(Intent.createChooser(it, "Choose Email Client"));
Intent it=new Intent(Intent.ACTION_SEND);      
String[] tos={"me@abc.com"};      
String[] ccs={"you@abc.com"};      
it.putExtra(Intent.EXTRA_EMAIL, tos);      
it.putExtra(Intent.EXTRA_CC, ccs);      
it.putExtra(Intent.EXTRA_TEXT, "The email body text");      
it.putExtra(Intent.EXTRA_SUBJECT, "The email subject text");      
it.setType("message/rfc822");      
startActivity(Intent.createChooser(it, "Choose Email Client"));    

Intent it = new Intent(Intent.ACTION_SEND);    
it.putExtra(Intent.EXTRA_SUBJECT, "The email subject text");    
it.putExtra(Intent.EXTRA_STREAM, "file:///sdcard/mysong.mp3");    
sendIntent.setType("audio/mp3");    
startActivity(Intent.createChooser(it, "Choose Email Client"));

10.播放多媒体   
Intent it = new Intent(Intent.ACTION_VIEW);
Uri uri = Uri.parse("file:///sdcard/song.mp3");
it.setDataAndType(uri, "audio/mp3");
startActivity(it);
Uri uri = Uri.withAppendedPath(MediaStore.Audio.Media.INTERNAL_CONTENT_URI, "1");    
Intent it = new Intent(Intent.ACTION_VIEW, uri);    
startActivity(it);

11.uninstall apk
Uri uri = Uri.fromParts("package", strPackageName, null);    
Intent it = new Intent(Intent.ACTION_DELETE, uri);    
startActivity(it);

12.install apk
Uri installUri = Uri.fromParts("package", "xxx", null);
returnIt = new Intent(Intent.ACTION_PACKAGE_ADDED, installUri);

13. 打开照相机
```
    <1>Intent i = new Intent(Intent.ACTION_CAMERA_BUTTON, null);
           this.sendBroadcast(i);
     <2>long dateTaken = System.currentTimeMillis();
            String name = createName(dateTaken) + ".jpg";
            fileName = folder + name;
            ContentValues values = new ContentValues();
            values.put(Images.Media.TITLE, fileName);
            values.put("_data", fileName);
            values.put(Images.Media.PICASA_ID, fileName);
            values.put(Images.Media.DISPLAY_NAME, fileName);
            values.put(Images.Media.DESCRIPTION, fileName);
            values.put(Images.ImageColumns.BUCKET_DISPLAY_NAME, fileName);
            Uri photoUri = getContentResolver().insert(
                    MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values);

            Intent inttPhoto = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
            inttPhoto.putExtra(MediaStore.EXTRA_OUTPUT, photoUri);
            startActivityForResult(inttPhoto, 10);
```
14.从gallery选取图片
```
  Intent i = new Intent();
            i.setType("image/*");
            i.setAction(Intent.ACTION_GET_CONTENT);
            startActivityForResult(i, 11);
```
15. 打开录音机
   Intent mi = new Intent(Media.RECORD_SOUND_ACTION);
            startActivity(mi);

16.显示应用详细列表       
Uri uri = Uri.parse("market://details?id=app_id");         
Intent it = new Intent(Intent.ACTION_VIEW, uri);         
startActivity(it);         
//where app_id is the application ID, find the ID          
//by clicking on your application on Market home          
//page, and notice the ID from the address bar      

刚才找app id未果，结果发现用package name也可以
Uri uri = Uri.parse("market://details?id=<packagename>");
这个简单多了

17寻找应用       
Uri uri = Uri.parse("market://search?q=pname:pkg_name");         
Intent it = new Intent(Intent.ACTION_VIEW, uri);         
startActivity(it);
//where pkg_name is the full package path for an application       

18打开联系人列表
            <1>            
           Intent i = new Intent();
           i.setAction(Intent.ACTION_GET_CONTENT);
           i.setType("vnd.android.cursor.item/phone");
           startActivityForResult(i, REQUEST_TEXT);

            <2>
            Uri uri = Uri.parse("content://contacts/people");
            Intent it = new Intent(Intent.ACTION_PICK, uri);
            startActivityForResult(it, REQUEST_TEXT);

19 打开另一程序
Intent i = new Intent();
            ComponentName cn = new ComponentName("com.yellowbook.android2",
                    "com.yellowbook.android2.AndroidSearch");
            i.setComponent(cn);
            i.setAction("android.intent.action.MAIN");
            startActivityForResult(i, RESULT_OK);

20.调用系统编辑添加联系人（高版本SDK有效）：
Intent it = newIntent(Intent.ACTION_INSERT_OR_EDIT);
               it.setType("vnd.android.cursor.item/contact");
                //it.setType(Contacts.CONTENT_ITEM_TYPE);
                it.putExtra("name","myName");
               it.putExtra(android.provider.Contacts.Intents.Insert.COMPANY,  "organization");
               it.putExtra(android.provider.Contacts.Intents.Insert.EMAIL,"email");
                it.putExtra(android.provider.Contacts.Intents.Insert.PHONE,"homePhone");
                it.putExtra(android.provider.Contacts.Intents.Insert.SECONDARY_PHONE,
                               "mobilePhone");
                it.putExtra(  android.provider.Contacts.Intents.Insert.TERTIARY_PHONE,
                               "workPhone");
               it.putExtra(android.provider.Contacts.Intents.Insert.JOB_TITLE,"title");
                startActivity(it);

21.调用系统编辑添加联系人（全有效）：
Intent intent = newIntent(Intent.ACTION_INSERT_OR_EDIT);
           intent.setType(People.CONTENT_ITEM_TYPE);
           intent.putExtra(Contacts.Intents.Insert.NAME, "My Name");
           intent.putExtra(Contacts.Intents.Insert.PHONE, "+1234567890");
           intent.putExtra(Contacts.Intents.Insert.PHONE_TYPE,Contacts.PhonesColumns.TYPE_MOBILE);
           intent.putExtra(Contacts.Intents.Insert.EMAIL, "com@com.com");
           intent.putExtra(Contacts.Intents.Insert.EMAIL_TYPE,                    Contacts.ContactMethodsColumns.TYPE_WORK);
           startActivity(intent);
           *****
下面是转载来的其他的一些Intent用法实例（转自javaeye）

显示网页
   1. Uri uri = Uri.parse("http://google.com");
   2. Intent it = new Intent(Intent.ACTION_VIEW, uri);
   3. startActivity(it);

显示地图
   1. Uri uri = Uri.parse("geo:38.899533,-77.036476");
   2. Intent it = new Intent(Intent.ACTION_VIEW, uri);  
   3. startActivity(it);  
   4. //其他 geo URI 範例
   5. //geo:latitude,longitude
   6. //geo:latitude,longitude?z=zoom
   7. //geo:0,0?q=my+street+address
   8. //geo:0,0?q=business+near+city
   9. //google.streetview:cbll=lat,lng&cbp=1,yaw,,pitch,zoom&mz=mapZoom

路径规划
   1. Uri uri = Uri.parse("http://maps.google.com/maps?f=d&saddr=startLat%20startLng&daddr=endLat%20endLng&hl=en");
   2. Intent it = new Intent(Intent.ACTION_VIEW, uri);
   3. startActivity(it);
   4. //where startLat, startLng, endLat, endLng are a long with 6 decimals like: 50.123456

打电话
   1. //叫出拨号程序
   2. Uri uri = Uri.parse("tel:0800000123");
   3. Intent it = new Intent(Intent.ACTION_DIAL, uri);
   4. startActivity(it);
   1. //直接打电话出去
   2. Uri uri = Uri.parse("tel:0800000123");
   3. Intent it = new Intent(Intent.ACTION_CALL, uri);
   4. startActivity(it);
   5. //用這個，要在 AndroidManifest.xml 中，加上
   6. //<uses-permission id="android.permission.CALL_PHONE" />

传送SMS/MMS
   1. //调用短信程序
   2. Intent it = new Intent(Intent.ACTION_VIEW, uri);
   3. it.putExtra("sms_body", "The SMS text");  
   4. it.setType("vnd.android-dir/mms-sms");
   5. startActivity(it);
   1. //传送消息
   2. Uri uri = Uri.parse("smsto://0800000123");
   3. Intent it = new Intent(Intent.ACTION_SENDTO, uri);
   4. it.putExtra("sms_body", "The SMS text");
   5. startActivity(it);
   1. //传送 MMS
   2. Uri uri = Uri.parse("content://media/external/images/media/23");
   3. Intent it = new Intent(Intent.ACTION_SEND);  
   4. it.putExtra("sms_body", "some text");  
   5. it.putExtra(Intent.EXTRA_STREAM, uri);
   6. it.setType("image/png");  
   7. startActivity(it);

传送 Email
   1. Uri uri = Uri.parse("mailto:xxx@abc.com");
   2. Intent it = new Intent(Intent.ACTION_SENDTO, uri);
   3. startActivity(it);


   1. Intent it = new Intent(Intent.ACTION_SEND);
   2. it.putExtra(Intent.EXTRA_EMAIL, "me@abc.com");
   3. it.putExtra(Intent.EXTRA_TEXT, "The email body text");
   4. it.setType("text/plain");
   5. startActivity(Intent.createChooser(it, "Choose Email Client"));


   1. Intent it=new Intent(Intent.ACTION_SEND);   
   2. String[] tos={"me@abc.com"};   
   3. String[] ccs={"you@abc.com"};   
   4. it.putExtra(Intent.EXTRA_EMAIL, tos);   
   5. it.putExtra(Intent.EXTRA_CC, ccs);   
   6. it.putExtra(Intent.EXTRA_TEXT, "The email body text");   
   7. it.putExtra(Intent.EXTRA_SUBJECT, "The email subject text");   
   8. it.setType("message/rfc822");   
   9. startActivity(Intent.createChooser(it, "Choose Email Client"));


   1. //传送附件
   2. Intent it = new Intent(Intent.ACTION_SEND);
   3. it.putExtra(Intent.EXTRA_SUBJECT, "The email subject text");
   4. it.putExtra(Intent.EXTRA_STREAM, "file:///sdcard/mysong.mp3");
   5. sendIntent.setType("audio/mp3");
   6. startActivity(Intent.createChooser(it, "Choose Email Client"));

播放多媒体
       Uri uri = Uri.parse("file:///sdcard/song.mp3");
       Intent it = new Intent(Intent.ACTION_VIEW, uri);
       it.setType("audio/mp3");
       startActivity(it);
       Uri uri = Uri.withAppendedPath(MediaStore.Audio.Media.INTERNAL_CONTENT_URI, "1");
       Intent it = new Intent(Intent.ACTION_VIEW, uri);
       startActivity(it);

Market 相关
1.        //寻找某个应用
2.        Uri uri = Uri.parse("market://search?q=pname:pkg_name");
3.        Intent it = new Intent(Intent.ACTION_VIEW, uri);
4.        startActivity(it);
5.        //where pkg_name is the full package path for an application
1.        //显示某个应用的相关信息
2.        Uri uri = Uri.parse("market://details?id=app_id");
3.        Intent it = new Intent(Intent.ACTION_VIEW, uri);
4.        startActivity(it);
5.        //where app_id is the application ID, find the ID  
6.        //by clicking on your application on Market home  
7.        //page, and notice the ID from the address bar

Uninstall 应用程序
```
        Uri uri = Uri.fromParts("package", strPackageName, null);
        Intent it = new Intent(Intent.ACTION_DELETE, uri);  
       startActivity(it);
```
## 一 Android系统用于Activity的标准Intent
1 根据联系人ID显示联系人信息
```
    Intent intent = new Intent();  
    intent.setAction(Intent.ACTION_VIEW);   //显示联系人信息  
    intent.setData(Uri.parse("content://contacts/people/492"));  
    startActivity(intent);  
```
2 根据联系人ID显示拨号面板  
```
    Intent intent = new Intent();  
    intent.setAction(Intent.ACTION_DIAL);  //显示拨号面板  
    intent.setData(Uri.parse("content://contacts/people/492"));  
    startActivity(intent);    
```
3 显示拨号面板， 并在拨号面板上将号码显示出来  
```
    Intent intent = new Intent();  
    intent.setAction(Intent.ACTION_VIEW);     
    intent.setData(Uri.parse("tel://15216448315"));  
    startActivity(intent);    
```
4 显示拨号面板， 并在拨号面板上将号码显示出来  
```
    Intent intent = new Intent();  
    intent.setAction(Intent.ACTION_DIAL);   //显示拨号面板, 并在拨号面板上将号码显示出来  
    intent.setData(Uri.parse("tel://15216448315"));  
    startActivity(intent);    
```
5 根据联系人的ID编辑联系人  
```
    Intent intent = new Intent();  
    intent.setAction(Intent.ACTION_EDIT);   //编辑联系人  
    intent.setData(Uri.parse("content://contacts/people/492"));  
    startActivity(intent);    
```
6 显示通讯录联系人和其他账号联系人的列表  
```
    Intent intent = new Intent();  
    intent.setAction(Intent.ACTION_VIEW);     
    intent.setData(Uri.parse("content://contacts/people/"));  
    startActivity(intent);    
```
7 启动HomeScreen  
```
    Intent intent = new Intent();  
    intent.setAction(Intent.ACTION_MAIN);     //启动HomeScreen  
    intent.addCategory(Intent.CATEGORY_HOME);  
    startActivity(intent);    
```
8 选择某个联系人的号码，返回一个代表这个号码的uri，如:content://contacts/phones/982  
```
    Intent intent = new Intent();  
    intent.setAction(Intent.ACTION_GET_CONTENT);       
    intent.setType("vnd.android.cursor.item/phone");  
    startActivityForResult(intent, 1);    
```
9  打开多个应用选取各种类型的数据,以uri返回。返回的uri可使用ContentResolver.openInputStream(Uri)打开
    该功能可用在邮件中附件的选取
    举例如下:
    选取一张图片, 返回的uri为 content://media/external/images/media/47
    选取一首歌, 返回的uri为 content://media/external/audio/media/51  
```
    Intent intent = new Intent();  
    intent.setAction(Intent.ACTION_GET_CONTENT);       
    intent.setType("*/*");  
    intent.addCategory(Intent.CATEGORY_OPENABLE);  
    startActivityForResult(intent, 2);   
```
10 自定义一个chooser，不使用系统的chooser
     该chooser可以有自己的标题(Title)
     并且不必让用户指定偏好  
 ```
    Intent intent = new Intent();  
    intent.setAction(Intent.ACTION_CHOOSER);   
    intent.putExtra(Intent.EXTRA_TITLE, "my chooser");  
    intent.putExtra(Intent.EXTRA_INTENT,   
            new Intent(Intent.ACTION_GET_CONTENT)  
            .setType("*/*")  
            .addCategory(Intent.CATEGORY_OPENABLE)  
            );  
    startActivityForResult(intent, 2);    
```
11 选取activity，返回的activity可在返回的intent.getComponent()中得到  
```
    Intent intent = new Intent();  
    intent.setAction(Intent.ACTION_PICK_ACTIVITY);   
    intent.putExtra( Intent.EXTRA_INTENT,   
            new Intent(Intent.ACTION_GET_CONTENT)  
            .setType("*/*")  
            .addCategory(Intent.CATEGORY_OPENABLE)  
            );  
    startActivityForResult(intent, 3);    
```
12 启动搜索，在以下示例代码中，"ANDROID"为要搜索的字符串
     当执行这段代码后, 会在系统的Chooser中显示可以用于搜索的程序列表  
 ```
    Intent intent = new Intent();  
    intent.setAction(Intent.ACTION_SEARCH);     //启动搜索  
    intent.putExtra(SearchManager.QUERY, "ANDROID");  
    startActivity(intent);    
```
13 启动WEB搜索，在以下示例代码中，"ANDROID"为要搜索的字符串
     当执行这段代码后, 会在系统的Chooser中显示可以用于搜索的程序列表，一般情况下系统中安装的浏览器都会显示出来  
 ```
    Intent intent = new Intent();  
    intent.setAction(Intent.ACTION_WEB_SEARCH);     //启动搜索  
    intent.putExtra(SearchManager.QUERY, "ANDROID");  
    startActivity(intent);    
```
## 二  Android系统用于BroadcastReceiver的标准Intent
1 ACTION_TIME_TICK，系统时钟广播，系统每分钟都会发送一个这样的广播，
   如果在应用开发中，有些逻辑依赖于系统时钟，可以注册一个广播接收者
   这是一个受保护的action，只有系统才能发送这个广播
   并且，在manifest文件中注册的广播接收者不能接收到该广播，若要接收该广播，必须在代码中注册广播接收者  
```
    registerReceiver(new BroadcastReceiver(){  
        @Override  
        public void onReceive(Context context, Intent intent) {  
            Log.i("xxxx", "TIME_TICK");  
        }  
    },   
    new IntentFilter(Intent.ACTION_TIME_TICK));    
```
2 在官方文档中，列出了以下标准的广播action  
```
    ACTION_TIME_TICK               系统时钟广播
    ACTION_TIME_CHANGED            时间被重新设置
    ACTION_TIMEZONE_CHANGED        时区改变
    ACTION_BOOT_COMPLETED          系统启动完成
    ACTION_PACKAGE_ADDED           系统中安装了新的应用
    ACTION_PACKAGE_CHANGED         系统中已存在的app包被更改
    ACTION_PACKAGE_REMOVED         系统中已存在的app被移除
    ACTION_PACKAGE_RESTARTED       用户重启了一个app，这个app的所有进程被杀死
    ACTION_PACKAGE_DATA_CLEARED    用户清除了一个app的数据
    ACTION_UID_REMOVED             系统中的一个user ID被移除
    ACTION_BATTERY_CHANGED         电池状态改变，这是一个sticky广播
    ACTION_POWER_CONNECTED         设备连接了外部电源
    ACTION_POWER_DISCONNECTED      外部电源被移除
    ACTION_SHUTDOWN                设备正在关机  
```
## 三  Android中的标准类别（category）
类别（category）一般配合action使用，以下为系统中的标准类别，由于数量过多，只能在使用到时再详细研究  
```
    CATEGORY_DEFAULT
    CATEGORY_BROWSABLE
    CATEGORY_TAB
    CATEGORY_ALTERNATIVE
    CATEGORY_SELECTED_ALTERNATIVE
    CATEGORY_LAUNCHER
    CATEGORY_INFO
    CATEGORY_HOME
    CATEGORY_PREFERENCE
    CATEGORY_TEST
    CATEGORY_CAR_DOCK
    CATEGORY_DESK_DOCK
    CATEGORY_LE_DESK_DOCK
    CATEGORY_HE_DESK_DOCK
    CATEGORY_CAR_MODE
    CATEGORY_APP_MARKET  
```
## 四  Android中的标准Extra键值
这些常量用于在调用Intent.putExtra(String, Bundle)时作为键值传递数据，同样由于数量较多，在此只列出索引  
```
    EXTRA_ALARM_COUNT
    EXTRA_BCC
    EXTRA_CC
    EXTRA_CHANGED_COMPONENT_NAME
    EXTRA_DATA_REMOVED
    EXTRA_DOCK_STATE
    EXTRA_DOCK_STATE_HE_DESK
    EXTRA_DOCK_STATE_LE_DESK
    EXTRA_DOCK_STATE_CAR
    EXTRA_DOCK_STATE_DESK
    EXTRA_DOCK_STATE_UNDOCKED
    EXTRA_DONT_KILL_APP
    EXTRA_EMAIL
    EXTRA_INITIAL_INTENTS
    EXTRA_INTENT
    EXTRA_KEY_EVENT
    EXTRA_ORIGINATING_URI
    EXTRA_PHONE_NUMBER
    EXTRA_REFERRER
    EXTRA_REMOTE_INTENT_TOKEN
    EXTRA_REPLACING
    EXTRA_SHORTCUT_ICON
    EXTRA_SHORTCUT_ICON_RESOURCE
    EXTRA_SHORTCUT_INTENT
    EXTRA_STREAM
    EXTRA_SHORTCUT_NAME
    EXTRA_SUBJECT
    EXTRA_TEMPLATE
    EXTRA_TEXT
    EXTRA_TITLE
    EXTRA_UID  
```
五  Intent中的标志（FLAG）
Intent类中定义了一些以FLAG_开头的标志位，这些标志位中有的非常重要，会影响app中Activity和BroadcastReceiver等的行为。
以下为这些标志位的索引，是从官方文档上的截图。之后会对重要的标志加以详细分析
[ Android开发——Intent中的各种FLAG ](http://blog.csdn.net/javensun/article/details/8700265)
