我做过以及了解过的：
slots+bone+attachment。

slots是插入spine的插入槽位，插入哪个region图片/mesh，整个slot图片的颜色，用哪个attachment这些信息。

bone类似unity transform层级嵌套，

一种regionattachment和unity一样的，animator各种节点的position，rotation，scale这些。这个我会直接对应动画，动画时长，直接将每帧的所有骨骼数据都烘焙到贴图里面，表示起来其实也就6个值。构成一个3x3的矩阵。


另一种是vertexattachment，比较麻烦，这个是骨骼蒙皮动画的核心。两部分操控，一部分deformTimeLine，另一部分顶点+骨骼权重动画。deformTimeLine负责顶点的偏移。
deform是按照动画+顶点烘焙进贴图里
顶点的骨骼权重这块，没有和spine一样影响顶点的所有骨骼权重都丢进去，只放了权重最大的四个骨骼，实际看上去表现可以接受

问题：bone，slots，vertexattachment这些顶点怎么对应？为什么要烘焙到贴图中？烘焙到tex中的数据是什么格式？