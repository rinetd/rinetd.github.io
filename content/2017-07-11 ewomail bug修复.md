---
title: EwoMail修改密码后无法登陆bug修复
date: 2016-03-29T21:25:45+08:00
categories: [网络安全]
tags:
---
EwoMail修改密码后无法登陆bug修复

现象:
  新用户登陆后修改密码后 新密码旧密码都无法登陆

排查 ：
1. 登陆数据库 查看密码
`select id,password from ewomail.i_users \G;`
*************************** 11. row ***************************
      id: 12
password: d41d8cd98f00b204e9800998ecf8427e
*************************** 12. row ***************************
      id: 13
password: d41d8cd98f00b204e9800998ecf8427e
*************************** 13. row ***************************
      id: 14
password: d41d8cd98f00b204e9800998ecf8427e

 2.  MD5解密d41d8cd98f00b204e9800998ecf8427e发现是个空密码

     查询结果：  
     [空密码]/[Empty String]

 3. 前端调试 ajax postform传值 Status Code:200 OK
   PrevPassword=lsl123457&NewPassword=lshl123457&Action=ChangePassword&XToken=6b43065d8ab5c2ba300337907c7d21fb
   所以问题出在后端程序处理

 4. 后端定位密码修改
 app/libraries/RainLoop/EwoMail.php
 ```php
 public function updatePassword($email,$password,$new_passowrd)
    {
        $newData = [
            'email'=>$email,
            'password'=>$password,
            'new_passowrd'=>$new_passowrd
        ];
        $r = $this->send('User/update_password',$newData);
        return $r;
    }
  ```

继续跟踪 ewomail-admin/module/Api/User.php

```php
/**
 * 修改账号密码
 */
Rout::get('update_password',function(){
    $email = iany('email');
    $password = iany('password');
    $new_password = iany('new_password');
    if(!$email){
        E::error('email domain parameter');
    }
    if(!$password){
        E::error('password domain parameter');
    }
    if(!$password){
        E::error('new_password domain parameter');
    }
    $row = App::$db->getOne("select * from ".table("users")." where email='$email' and active=1");
    if(!$row){
        E::error('Data does not exist');
    }
    if($row['password']!=md5($password)){
        E::error('The original password is not correct');
    }
    $newData = [
        'password'=>md5($new_password)
    ];
    App::$db->update("users",$newData,"email='$email'");
    E::success('');
});
```
发现 `new_passowrd` 笔误，改正
```php
public function updatePassword($email,$password,$new_password)
   {
       $newData = [
           'email'=>$email,
           'password'=>$password,
           'new_password'=>$new_password
       ];
       $r = $this->send('User/update_password',$newData);
       return $r;
   }
```

问题修复。

总结：问题虽然不大，但是查起来确实麻烦
