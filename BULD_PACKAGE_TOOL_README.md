### Android APK 批量打包工具

使用 gradle，在 build.gradle 中进行相应配置

1. 在 AndroidManifest.xml 配置 渠道号名称和值，此时 值需要定义为传参形式；
``` xml
      <meta-data
              android:name="CHANNEL_DISPATCH_PLATFORM_NAME"
              android:value="\ ${CHANNEL_PARAMETER_NAME}" />
```
          例如：
``` xml
      <meta-data
             android:name="UMENG_CHANNEL"
             android:value="\ ${UMENG_VALUE}" />
```
2. 在 channal.txt 中输入所有准备要发布apk平台的平台名称；
3. 在 build.gradle 文件中配置发布平台（channal.txt）、签名文件(signingConfigs)、编译类型(buildTypes);
4. 在 AndroidStudio 的 Terminal 中运行如下命令：
``` shell
      $./gradlew clean
      $./gradlew build
      $./gradlew assembleRelease
```
5. 即可在自定义输出路径的文件夹下找到所有平台对应的apk包；
6. 注意确认打包后的 AndroidManifest.xml 文件中是否包含了渠道号，如果没有，则证明批量打包失败，请重新确认配置是否争取。

##### 参考资料：不可考
