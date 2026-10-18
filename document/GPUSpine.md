印象中SkeletonGraphic的网格全部都是CPU算的，有没有什么办法减少CPU的计算的开销？毕竟骨骼蒙皮一多，用CPU计算也不合理

1. 先搞清楚现在的Mesh是怎么算出来的，搞清楚再说别的


大概看的差不多了，总之各种计算全在CPU，UpdateMesh这里开销最大。其次是一大堆TimeLine。

总流程是一大堆TImeLine对Bone做各种编辑。
然后UpdateMesh里面BuildMeshWithArrays里面根据骨骼计算顶点，UV等东西
最后canvasRenderer里面SetMesh，交给canvas渲染。


先不管useClip的事，优化一下BuildMeshWithArrays

想法：Mesh不再依赖CPU算，先不管tintBlack路径

regionAttachment和meshAttachment都有在用。这俩计算方式不一样，但是依旧都需要算。

不用computeShader的优化方法？

先捋一下Shader能做什么。。

想要正常的shader来算，最少要给到顶点和uv的，，但是顶点和uv需要根据slot和attachment来算。

预先搞一个基底mesh，把instruction的信息传进去，然后根据基底mesh来计算正确的顶点位置？

原顶点可以存对应的boneIndex，然后根据这个boneIndex能读是哪个骨头

ver.1 依旧遍历了所有骨骼，但是还是需要进行大量的属性复制，每帧都得向GPU传一大堆东西，合批肯定是没法合批的，毕竟每个Spine实例的动画播放状态都不一致，每个都需要单独传输矩阵。动画也都是CPU自己计算，走的还是之前Skeleton的animState逻辑，通过timeline来算。

### 考虑一下类似gpu动画的做法？

把动画相关的骨骼数据/各种动画TImeline数据全部烘焙到贴图里面，播放时只指定时间？那动画融合怎么搞？
1. 把MeshAttachment和RegionAttachment统一一下？都可以作为MeshAttachment来看吧？毕竟都是顶点+uv，好像没什么区别？
    MeshAttachment用的是顶点+uv，但是RegionAttachment用的是offset+uv，顶点可以理解，offset是干什么用的？


现在的想法是完全不经过CPU计算了，
先做第一个阶段：预先把初始顶点mesh bake好，然后所有的timeline数据bake到贴图里面，使用时直接把贴图传GPU上，给shader一个时间参数，根据时间来从贴图里面取timeline数据，计算顶点并且播放。

### Phase1 落地（Assets/Tests/GPUSpine）
- `SpineGpuAnimTextureBaker`：离线按 fps 求值动画（Apply+UpdateWorldTransform），写入 BoneTex / SlotTex（不是原始 timeline 关键帧）
- `SpineGpuAnimTexturePlayer`：CPU 只 `animTime += dt`，MPB 传 `_AnimTime`
- Shader `GPUSpine/AnimTexture`：按时间采样骨头矩阵 + slot 颜色/piece，VS 蒙皮
- `SpineGpuAnimTextureStressSpawner`：共享 bake 压测
- 未做：Deform、Clipping、DrawOrder、多 track mix

目前遇到的问题：
1. Spine状态太多的时候文件太大。（271 PiggybankMegaWheel里面三十个动画状态，bake出来后20M，并且很多deform贴图都是纯黑的（应该可以检测是不是有deform再把没deform的动画的defrom贴图干掉？

现在的bake直接bake了固定帧率，但是动画制作的时候可能只k了一部分的关键帧，然后在两个关键帧之间进行采样，而不是现在我们这样固定fps为关键帧进行采样。。这样会导致大量的空间浪费？

### Phase2 然后是下个阶段，做一下动画混合。

这个项目的使用场景比较简单，只考虑两个动画之间的动画融合，不考虑更多动画一块的融合情况。

一般的两个动画切换过程中的动画融合，都是将切换时间归一化为[0, 1]，然后根据这个归一化值对原动画状态和目标动画状态进行插值。

好像shader里面多加几个变量然后两个都计算一下骨骼作用后的顶点并且lerp一下就行？

先把所有动画都烘焙到一张贴图上，每个动画指定贴图采样起始点和长度，用这样表示动画。

动画融合就在CPU侧控制多个动画的目标时长以及blend系数，

### Phase2 落地（Assets/Tests/GPUSpine）
- `SpineGpuAnimTextureBaker.BakeLibrary`：多动画竖向叠 Bone/Slot/Deform Atlas，`AnimEntry{frameStart,frameCount,duration}`
- `SpineGpuAnimLibrary`：磁盘资产（RestMesh + VertexAttrTex + 三张 Atlas + entries）
- Bake 窗口勾选 **Bake As Library Atlas** → 输出 `Library.asset`
- Shader `AnimTexture` / `AnimTextureUI`：`_FrameStartA/B` + `_AnimTime/_AnimTimeB/_Blend`；两姿态各自蒙皮后 **lerp 顶点位置**（不 lerp 骨矩阵）
- `SpineGpuAnimTexturePlayer`：`Play(name)` / `CrossFade(name, mixDuration)`；CPU 只推进 time + blend
- 单 Clip 仍可用（frameStart=0）；跨动画融合需要 Library


## 发散一下知识点？


骨骼动画的表示与计算？
网格形变动画的表示？
