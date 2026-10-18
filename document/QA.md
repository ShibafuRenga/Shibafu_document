Canvas Renderer?

ViewPort Rect

rebatch rebuild

播动效底层判断：land smallwin

https://learn.unity.com/tutorial/optimizing-unity-ui#disabling-canvas-renderers

Q：怎么做到的从机器场景打开也能正常加载资源初始化？（在start的时候嵌入一些代码？）
A：资源初始化没有找到，但是看到了EditorApplication.playModeStateChanged，这个可以绑定unity编辑器状态变化事件


Q：jackpot怎么实时刷新的？  没找到

热更新的lua代码中加注释？

Q: AnimationCollection怎么播的？各个参数都有啥用？
A: 相关脚本AnimItem, AnimInstance, MachineEventManager，AnimInstance里面有所有的动画播放逻辑，用dotween处理before、播放、end回调、delayafter, after之后reset
spin的时候有些图标是如何固定的？

spin音效根据名称自动绑定？

GetPlayResult里面的new对象是否是每次都重新创建？
init每次都只调用一次

prewin的时候PlayResultCommandTranslator有个对象池解析以及new都只new了一次，只有第一次new了

Q：UIParticle， Ignore Canvas Scaler?!

hugewinstart之后没有unload

paylineview

Q：luainterfacebase里面C#和lua的交互需要看一下



Q：调用feature Restore的地方?
A：LuaMachineFeature

Q：这个feature 怎么注册的？又是在哪被统一调用C#的restore的？
A：在LuaAdapter的静态构造方法中注册，LuaEnv.AddIniter()加入到luaEnv中，然后在LuaEnv的构造函数中调用__create静态函数创建LuaBase对象（注册主要是为了把Lua虚拟机对象传进C#对象中，方便后面调用），调用restore是在EnterMachine.cs（有两个EnterMachine）里面，直接从gameplayfacade里面get到feature的（之前在context里面用MachineUtility加进去的）
A：进入机器的流程还有一部分在MachineController的OnGameConsoleStartedMessageArrive里面

Q：需要详细看这个注册过程，思考为什么要这样注册lua环境然后调用

Q：机器245需要做保存一些数据的功能，模仿242的保存数据实现
Q：在feature.lua里面恢复数据，为什么选择在这里恢复？从CSDataProxy里面读数据，CSDataProxy怎么实现的？
A：看MachineController.OnGameConsoleStartedMessageArrive，这里面两个enter cmd的顺序，先获取数据，然后进行restore
A：保存恢复需求应该放在这个context里面，可能要改协议？或者直接约定好放一个地方
A：CSDataProxy就是个局内的数据manager，啥也没干


感觉feature就是用来读远程数据做一些初始化的？不然为什么要在enter请求到数据之后restore，请求了上次spin的结果、context、machineconfig，需要的时候直接从DataProxy里面读就行

Q：数据在什么时候保存的
A：UpdateBetData，在SetResult里面保存对应bet的gamePlay结果就行

Q：245的飞行动画怎么实现？
A：dotween实现飞行的动画，用async实现（controller里面的playresult创建一个新command，command里面start一个异步操作之后就不管它了），要是中间切bet或者继续spin动画继续，但是结果设置需要判断dirty，但是如果间隔很短是创建多个？还是现有动画换位置？模仿CoinsRichesCollectView写就行

Q：245画线？
A：defaultpaylineview 直接用就行，但是感觉线的位置有些问题，起点和终点以及转折点怎么定的？

Q：245 anticipation
A：playSymbolland 3 （提前判断中奖）的时候动画状态机切换永久蓝轴，然后等啥时候播bell_win动效?

Q：关于rolling流程控制的一些猜想
A：完全判断曲线时间 and 服务器数据是否返回，服务器数据返回时间统一，数据返回后开始计时判断曲线停止时间，曲线时间到了之后发布对应事件（全都在reel里面）。

Q： command的Serial,Internal, Parallel都什么意思




Q：画线的positions是从哪来的？
A：定位到MachineController的GetPayLinePositions，相关函数有payLine.GetPositions()和panelView.GetSymbolRelativePosition()
A：第一个PayLine.GetPositions应该是从什么配置里面读取的东西，
Q：为什么这个payline的positions里面第一个和最后一个总是到最左和最右
A：需要自己设定这个linepanel的大小，然后position的位置会根据symbol的位置计算

Q：音效管理部分？
A：CSAudioEntity/LuaAudioEntity，项目中有很多用到适配器模式的地方，封装原来的CSharp代码供Lua调用
音效资源的缓存，播放等通过SharePlaySound.cs进行
里面维护的是SoundUnitItem列表，可以FindSameAudioClip的话，直接播放对应item,
SoundUnitIem封装了一下AudioSource，可以判断音效是否正在播放，比较名字，
默认第一次加载播放用的是PlayFirst,找一个没用的AudioSource然后PlayUnitItem播放，找没用的AudioSource就是找第一个没有在播放并且是音效的source
说实话，从16个里面找一个audiosource也没什么开销吧。。。有的东西没必要硬优化，但是被问到得会说怎样优化
每次play一个音效的时候都会把音效移到维护列表最前面

看playaudio的时候又出来一个
音乐资源用的是MusicAudioItem，分区是否为effect，创建的时候直接用musicLength和索引判断，索引大于musicLength的用为effect，也就是说以5为边界分两个区大（不包括）的是effect


Q：资源管理，目前有看到NewAssetsBundleManager, AssetBundleLoadManager，都是干什么用？

Q：加载资源判断是否超时---AudioManager.cs   374行，逻辑优点意思，后面看看


Q： 获取这一局的所有symbol信息


Q: Debug窗口的层级在一些弹窗的下面，手快了容易卡死。。。


Q：机器win动画的播放逻辑？




Q：一键集成都干了什么？
A：在LuaScriptMachineGenWindow.cs里面，这里就是给LuaScriptMachineGen.cs传一堆bool值，在LuaScriptMachineGen里面进行生成
A：打开机器名对应场景
A：复制lua代码模版到相应文件夹，改改名字，改改代码里面缺省的机器名，根据输入的配置取消一些注释什么的
A：向场景中添加资源，BannerCanvas,PayLineView这些都是直接放上去
A：paytable是拷贝预制体，然后找到对应paytable文件夹下的文件名，排下顺序，加载一下sprite挂到paytable的脚本上，按钮也就找对应的sprite然后换了一下
A：震屏资源和引用这些也是。。。都是复制一下
A：绑定脚本addcomponent啥的都很明白，但是用了SerializedObject来绑定lua..其实直接设置也差不多，setdirty的区别
A：在各个脚本上挂载东西，，这个为啥不直接做到模版里面复制？有绑定prefab，spin，overlay这些
A：最后save一下
A：感觉SetDirty作用不大？


Q：看看机器预览界面
A：上一半在RollReelEditor里面，下一半在MachineEditor里面，带子配置也可以读取，
A：带子配置和panel脚本的Strip绑定，
Q：全局的崩溃事件？


Q：RenderingThreadingMode


Q：导入Spin的时候发生了什么？怎么三个文件变成六个了。。

Q：动画集播放，，怎么找的prefab，prefab的路径和引用哪个优先？
Q：问题描述：第一个路径错引用对的播放成功，但是后面的两个路径对引用对的播放失败。。并且控制台显示两个 no animateObject
A：machineevent调用animationcollection调用animitem调用animinstance。animinstance创建的时候找UnityObjectRef根据objpath创建一个预制体，这个创建是在(UnityObjectRef.GetObject)ResolveRef，但是找不到谁注册了这个方法。

Q：上面的问题有些找不到，先看现有问题，prefab移动位置之后，动画集中引用的path没有更新

Q：AssetPostprocessor和AssetModificationProcessor？有个ObjRefPostprocessor对资产的导入啥的做了一些处理，

Q： feature的restore谁调用的？开局如何获取历史记录？
A: EnterMachine的时候，在MachineController的OnGameConsoleStartedMessageArrive里面的EnterMachine

Q：想看看CSLuaUtil都有哪些功能


Q：获取当前倍率？游戏结果？
A：CSBaseSlotMachineController.Instance.currentBetting，（local CSBaseSlotMachineController = CS.BaseSlotMachineController）
A：CSGamePlayFacade.SpinResultEnumerator:GetCurrentGame()  local CSGamePlayFacade = CS.Blowfire.Slot.UI.GamePlay.GamePlayFacade


Q：anticipationcheck？？
A：count的意思应该是每轴对之前的轴出现的组合累计数进行判断，例如3*3机器，牌面如下：
0, 0, 0
1, 1, 1,
0, 0, 0
用1表示需要anticipation的symbol
对于不包含当前轴的情况：
对于第一轴，中奖线的实际count为0，如果配置count[0]<=0就会播放anticipation
对于第二轴，中奖线的实际count为1，如果配置count[1]<=1就会在第二轴播放anticipation
对于第三轴，中奖线的实际count为2，如果配置count[2]<=2就会在第三轴播放anticipation

ReelSymbol和ReelSymbols分别为总的Symbol和具体的组合，ReelSymbol是只要实际牌面中包含其中的一个，就可以判断，ReelSymbols则需要严格判断相等。ReelSymbols有配置时，ReelSymbol自动失效

Q: rect2d和spine的层级？
A：


实现进入场景就加载所有依赖资源方便调试，分离资源加载与正常boot情况下的登陆以及进入游戏等逻辑。
实现方式？监听unity editor的状态切换事件，判断当前场景名称，开始run的时候自动挂载脚本，加载单例等


Q： Accelerometer Frequency是什么

Q：POT纹理尺寸？

Q：unity不可视三角面的剔除？

Q：SRP Batcher？

Q：前向渲染和URP区别？

Q：光照探针？

Q：occlusion culling和frustum culling？

