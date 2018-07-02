#####iOS使用机器学习#####
使用Python练的模型,然后将模型文件引入工程使用

1.首先使用界面比较友好的Anaconda写Python,因为Anaconda有Python的playground的功能
2.使用命令   ./anaconda2/bin/pip install -U coremltools  这个是Python机器学习的库,具有一些通用的API,然后可以使得Python的模型转为iOS可以用的模型
3.使用命令   mkdir notebooks
./anaconda2/bin/jupyter notebook notebooks
4.这个是将jupyter写出的东西可以存储到notebooks的目录文件里面
5.工程文件的.mlmodel就是使用Python机器学习库生成的文件
6.具体怎么生成这个文件可以查看  scikit-learn 库的使用
