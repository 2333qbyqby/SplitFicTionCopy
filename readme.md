这是一个Unity的复刻双影奇境最后一关的效果的项目，基于URP管线,new Input System，Unity版本为2022.3.47f1c1

Scene1:最基础的双地图缝合，开启ScreenSplitRenderFeature，SplitType的选项设置为TwoCamera

![image-20250405014159499](https://typorapicturefivuvuv.oss-cn-shanghai.aliyuncs.com/picgo/image-20250405014159499.png)

Scene2:针对双地图混合的demo，左边人物wasd,G疾跑，F跳跃，右边人物方向键，KL为疾跑和跳跃

![image-20250405014400539](https://typorapicturefivuvuv.oss-cn-shanghai.aliyuncs.com/picgo/image-20250405014400539.png)

Scene3:模板测试尝试,打开MaskSceneFeature和RenderObject（未完善，本来想模仿在一个场景里开另一个场景的洞的功能，Shader水平不过关qwq)

![image-20250405015015035](https://typorapicturefivuvuv.oss-cn-shanghai.aliyuncs.com/picgo/image-20250405015015035.png)

Scene4:模拟摄像机四分（官方肯定不是这么实现的，已经燃尽了想不出了）开启ScreenSplitRenderFeature，SplitType的选项设置为FourCamera

![image-20250405015136027](https://typorapicturefivuvuv.oss-cn-shanghai.aliyuncs.com/picgo/image-20250405015136027.png)