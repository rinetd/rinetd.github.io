---
title: Android应用请求获取Root权限
date: 2016-01-11T14:10:29+08:00
update: 2016-01-01
categories: [Android]
tags: [root]
---
[Android应用请求获取Root权限](http://blog.csdn.net/zhufuing/article/details/7875216)

要让Android应用获得Root权限，首先Android设备必须已经获得Root权限。
应用获取Root权限的原理：让应用的代码执行目录获取最高权限。在Linux中通过chmod 777 [代码执行目录]
```
/**
 * 应用程序运行命令获取 Root权限，设备必须已破解(获得ROOT权限)
 *  
 * @return 应用程序是/否获取Root权限
 */  
public static boolean upgradeRootPermission(String pkgCodePath) {  
    Process process = null;  
    DataOutputStream os = null;  
    try {  
        String cmd="chmod 777 " + pkgCodePath;  
        process = Runtime.getRuntime().exec("su"); //切换到root帐号  
        os = new DataOutputStream(process.getOutputStream());  
        os.writeBytes(cmd + "\n");  
        os.writeBytes("exit\n");  
        os.flush();  
        process.waitFor();  
    } catch (Exception e) {  
        return false;  
    } finally {  
        try {  
            if (os != null) {  
                os.close();  
            }  
            process.destroy();  
        } catch (Exception e) {  
        }  
    }  
    return true;  
}
@Override  
public void onCreate(Bundle savedInstanceState) {  
    super.onCreate(savedInstanceState);  
    setContentView(R.layout.main);  
    //当前应用的代码执行目录  
    upgradeRootPermission(getPackageCodePath());  
}
```
