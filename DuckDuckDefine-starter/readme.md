#使用carthage进行第三方包的管理

1.当引入的包有问题时候可能会导致项目build不成功
2.carthage update --platform iOS
3.手动将framework添加到linked framework
4.添加runscript  /usr/local/bin/carthage copy-frameworks
5.input files添加framework的路径（为了包发到App Store不会有问题)

