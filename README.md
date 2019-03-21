# 基于Cam的APIs 开发App的SDK操作指南


一．相机控制：

1 建立通道setCameraIP：

mRemoteCam.setWifiIP((String) param, 7878, 8787);

2 建立连接start session：
mRemoteCam.startSession()

3 关闭连接stop session：
mRemoteCam.stopSession();

4 开始录像start record
mRemoteCam.startRecord();

5 停止录像stop record
mRemoteCam.stopRecord();

6 拍照take photo
mRemoteCam.takePhoto();

7 切换模式switch mode
mRemoteCam.switchMode((Integer) param);

8 获取相机信息get cam info
mRemoteCam.getDeviceInfo();

9 获取相机设置信息get cam setting
mRemoteCam.getAllSettings();


10 设置相机set setting（详细参数可以参照Foream_Wireless_Remote_Control_API.pdf文档）
String param = "\"type\":\"" + mHeader +         "\",\"param\":\"" + mSelectedItem + "\"";

mRemoteCam.setSetting((String) param);

11 同步时间 
mRemoteCam.settingCamtime((String)param, "date");



二、文件列表获取

文件列表获取，使用的是http协议，打开链接http://192.168.42.1/DCIM/，可以获取到文件夹列表，用户只需要对获取的信息做html解析即可得到文件列表及文件相关信息。



三、文件播放和下载

文件的下载和播放链接也是文件存储路径，比如 http://192.168.42.1/DCIM/100MEDIA/IMG0001.jpg


四、视频流的播放

视频流的播放，播放地址是：tcp://192.168.42.1:8001

可以采用ijk播放器或者vitamio播放器，我们同时提供了vitamio播放器和ijk播放器的demo供参考。

五、SDK支持的平台

我们在iOS端和android端均提供SDK，方便用户进行二次开发。
