
1. 需要在info.plist 中加入NSCameraUsageDescription & NSLocationWhenInUseUsageDescription权限

2. 需要导入 CoreMotion.framework & CoreLocation.famework

如何使用

1. 初始化视图 并 设置datasource

2. 调用setAnnotations方法设置

3. Present controller

4. 实现ARDataSource代理 提供自定义annotationView

注意： 

1. SDK 可自定义 ARViewController／ARAnnotation／ARAnnotataionView

2. 如果想自定义ARViewController UI， 新建ViewController并继承于MCYARViewController

3. 如果想自定义ARAnnotationView UI， 新建AnnotationView并继承于MCYARAnnotationView

4. 如果想自定义ARAnnotation提供数据， 新建Annotation并继承于MCYARAnnotation；

详情见Demo 

如有问题，欢迎交流。 QQ：294378422 邮箱： 294378422@qq.com




1. Need to include NSCameraUsageDescription & NSLocationWhenInUseUsageDescription permission in info.plist

2. Import CoreMotion.framework & CoreLocation.framework

How to use

1. InitViewController and set datasource

2. Invoke setAnnotations methods

3. Present Controller

4. Implement ARDataSource, And provide custom annotationView

Note

1. SDK could able to custom ARViewController/ARAnnotation/ARAnnotationView

2. If customize ARViewController UI, New Class with ViewController that extend to MCYARViewController

3. If customize ARAnnotationView UI, New Class with AnnotationView that extend to MCYARAnnotationView

4. If customize ARAnnotation provide to data, New Class Annotation that extend to MCYARAnnotation;

Details to demo

Welcome to contact me。 QQ: 294378422 email: icethy@qq.com

