### unity prefab转pixi组件

需求：现在需要写一个脚本，用来将unity的prefab asset转为pixi中的可控制组件。

前提：
1. 需要转换的unity prefab里面最多只会有Image/RawImage用来渲染图片

第一阶段目标：
1. 读取unity prefab并且解析所有依赖的资源，将资源copy整理到pixijs项目工程下，并且将该prefab继承“2”中的pixiUnityObject实现一个子类（可以暂时排除粒子系统，在后续阶段再实现）
2. 封装一个pixi的"pixiUnityObject"组件，必须提供以下函数：初始化（用来根据原unity prefab中的层级，位置，scale拼图片），放置（将这个组件放置到canvas的具体位置）

需要输出：pixi的pixiUnityObject组件，可以运行的将prefab转为pixiUnityObject子类的脚本

第二阶段目标：
1. 解析prefab上最顶层的animator，用自己的方式序列化为动画资产，供后续pixi中使用，硬编码到对应UnityAnimatorObject的子类里也行
2. 继承"pixiUnityObject"写一个"pixiUnityAnimatorObject"在pixiUnityAnimatorObject中增加PlayAnimation函数，用来根据unity中prefab上挂载的动画，传入动画名称播放具体动画

需要输出：更新的pixiUnityAnimatorObject组件，更新后的可以运行的将prefab转为pixiUnityAnimatorObject子类的脚本


第三阶段：
动画导出插件优化：
1. 支持指定部分动画导出
2. 指定所有动画中：alpha恒定为0，rootCanvasGroup的alpha恒为0，active恒为false的节点以及当前节点依赖的图片资源。 需要被剔除（记录所有节点，记录每个动画中不生效节点（前面说的那三种）求交集，所有节点去掉交集里的节点就是剩余节点）

第四阶段：

新增功能：导出unity序列帧动画

粒子导出没问题

最后就是做个debug界面，一个粒子一个粒子和unity里对应查看各种参数有没有问题


### panel引擎

需求：写一系列pixi组件，用来满足slots老虎机转轴旋转的需求。整体架构可以参考/Users/zcz/zczWorkspace/projects/machine_editor_2022/Assets/BlowFire/SlotFramework/SlotsLib/Panel.cs的panel和reel组件
