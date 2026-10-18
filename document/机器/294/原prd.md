转至内容
转至导航栏
转至主菜单
转至动作菜单
转至快速搜索
已链接应用程序
Confluence
空间
人员
日程表
TeamDecision
创建
创建

帮助
0
chengzhe.zhang@blow-fire.com 的个人资料头像

Slots Wiki
设置
294_FireballTripleEruption
 E编辑  F收藏  观看  S分享
页面 … 02-Wild机器文档
Skip to end of banner
Go to start of banner
Skip to end of metadata
由 Zhang Jiayu创建, 最后修改于大约2小时以前
Go to start of metadata
美术需求：
afp://172.16.20.202/BF-NAS/01-040/Projects/11-Wild机器/294_Fireball2Temp/01-策划文档/01-美术需求
玩法说明
版本控制说明
版本
日期
变更内容
修订人
备注
1.0	2026.09.14	初始版本	张家宇	







目标读者：PM、数值PM、前端Dev、后端Dev、QA

1. 机器基本信息
1.1. 参考机器
Playson 机器 4 Supercharged Clovers Hold and Win
原型机链接 https://slotslaunch.com/playson/4-supercharged-clovers-hold-and-win
使用Safari浏览器打开可玩，可直接Buy Feature
1.2. 棋盘和中奖线规格（剪裁后）: 
棋盘规格：
base：棋盘：5x3 （标准3轴classic 有blank ）
link：棋盘：3X5 （15个格子单独转）
中奖线：5线

1.3. 图标列表和分值
编号	程序编号	名称	一线中3 	备注
S00	0	Blank	

B01	1	蓝火球	

B02	2	紫火球	

B03	3	绿火球	
可能出现5TB / 7.5TB/ MINI / MINOR / MAJOR / 100TB/150TB
B04	4	红火球	
和出现金额（1TB/2TB/3TB/4TB/5TB/MINI）仅出现在LINK玩法中，出现时带金额
W01	5	2X Wild	80	三轴都有，2X倍数影响线奖
H01	6	黄7	10	
H02	7	红7	5	
H03	8	黑7	3	混7: 2
L01	9	2BAR	2	
L02	10	1BAR	1	
bar混合：0.5

1.4. Jackpot倍数
Grand  1000TB       Major  50TB       Minor   20TB       Mini   10TB
仅Grand Jackpot有Progressive
2. Basegame
2.1. Basegame玩法
1）图标出现规则：
Reels有Blank，图标不堆叠，B01/B02/B03 三个Bonus，在三个轴都有出现，三个Bonus图标都不带金额
出现三种颜色的火球图标，分别向三个顶部火球做收集，按规则使左侧火球升级或者触发；
同轴可能出现两个火球图标（不一定同色），一共最多可出6个（可能）；
2）火球升级和触发规则: 
三个左侧大火球，从上到下分别对应B02/B01/B03的收集，
每个火球分别有4个从小到大的等级，每次收集都有概率直接触发对应的Link Feature，若触发，则对应的火球保持trigger状态，完成其他后续流程后，再播放后续触发Link动画
若本次没有触发Link，则当收集满一定个数个时，顶部火球播升级动画，；
初始等级的火球，收集2-20个B01/B02/B03图标后，升级为第二级；收集2-20个B01/B02/B03图标后，升级为第三级；同样收集2-20个B01/B02/B03图标后，升级为第四级即最高级，不能继续升级。每次升级需要的收集数量条件，分别随机从2-20中取随机值；
若在一级阶段直接触发了Link，则连续播放三次升级动画，再触发trigger状态及后续逻辑，（线奖结算在Win栏，带入Link进行结算）
3)   拉近震屏逻辑：
在中10倍及以上倍数奖励时，播放拉近震屏效果（仅Base以及Link结束后播放）
4）land逻辑：
B01/B02/B03出现就播Land；
W01出现就播land;
5）Intentional tell 逻辑：
当本次spin会触发Link时，50%概率播放Tell
2.2. Basegame保存恢复需求
分Bet保存3个顶部火球收集的状态；
3. LINK玩法
3.1 触发条件
三种火球对应三个LINK feature，随机概率触发LINK，可能同时触发两个，或全部三个feature;
3.2 Link玩法
3.2.1 Link初始阶段规则：
15个格子单独旋转，触发牌面的的Bonus图标分别映射到Link棋盘中的第1/3/5列（不改变火球颜色）。
进入LINK后第一次SPIN之前，初始带入的B01/B02/B03图标按顺序结算各自奖励feature一遍；
触发当此有多种Bonus图标，但有Bonus没有触发自身的feature，次Bonus带入Link后是否需要结算，或是避免出现这种情况？？暂定避免这种情况
初始三次SPIN，Link过程中新出现B01/B02/B03/B04图标重置 Link的次数为三次；
3.2.2 Link过程中规则：
每次Link中新出现的B01/B02/B03触发各自的奖励featrue：
B03对应的绿色火球Mystery玩法：随机给获得一个不小于5TB的分值奖励，包括5TB/ 7.5TB/ MINI/ MINOR /MAJOR/100TB/150TB，当和其他类型Bonus同次SPIN出现时，结算顺序优先；
B02对应的紫色火球Multi玩法：随机给3个空位的格子增加Mulitplier框，分别为“X2”“X3”“X5”，若空位上已有“X”的框，则Multiplier相加，最高可以叠加为“X12”（来源于原型机），结算顺序其次
B01对应的蓝色火球Collect玩法：收集所有牌面其他图标的分值作为自己的分值，结算顺序最末。若此时有其他分值上有Multi，先把（除自身外的）所有Multi乘以各自分值（被乘倍的有Jackpot时，先折算为金额再乘倍），再执行收集金额，收集结算完成后，复原其他图标的基础分值和Multi显示。
Bonus图标落在Multiplier框上时，Mulitplier框即刻显示改为Mulitplier在右上角上，并在所有各自转停后，把自身的Mulitplier值复制到另一个空位上，若空位上已有Mulitplier框，则两个Multiplier值相加；
Link中概率出现随机Feature，表现为特殊的格子SPIN状态，随机Feature中可能转出全部三种feature，包括触发本次Link时并没有激活的feature；
随机feature中的出现的feature按各自的规则在当次SPIN执行，若出现的feature不包括在初始触发之中，则有概率在功能执行后，触发对应feature的激活retrigger；
3.2.3 Link结算阶段规则：
若所有15个格子都有bonus时，或剩余SPIN次数为零，Link结束，收集所有bonus上的分值奖励，作为最终奖励（包括触发时的线奖）；
若所有15个格子都有bonus了，则获得GRAND Jackpot奖励，其他分值奖励正常结算之后，最后结算jackpot奖励。
Link开始最终结算时先再把除Jackpot外的Multi乘倍依次结算到各自格子的分值上，跳过Jackpot带乘倍的格子。在最后结算收集金额时，再播放Jackpot乘倍弹窗；
结算顺序：从左到右按列结算，每列从上到下结算，结算多个同档位Jackpot或者Jackpot奖励的乘倍时，按位置先后，只结算第一个同档位Jackpot的增长值，若此时的Jackpot有乘倍结算，增长值也乘倍 (可出现在棋盘的上的三档Jackpot 都无增长值）。
3.3 Link保存恢复需求
Wheel 保存恢复点列表如下：
编号
保存位置
恢复状态
1
触发Link
回到Link，开始Link旋转
2	
Link过程中
恢复Multiplier值及所在位置，各类Bonus的位置和金额正确，Jackpot积累值正确，剩余的SPIN次数正确
4. 数值需求：
HitRate: 15%       BigWin: 1.8%    ColossalWin: 0.1%  
BaseRTP: 32%      LinkTriggerRate:   1.15%-1.2%
可考虑的测试：
测试feature触发，四种模型按照马尔可夫链方式进行概率切换（参考286机器测试）
测试Link中基础分值图标的倍数的高低，对玩家SPIN的影响，更多的link出现的图标对比更高的基础图标分值
测试更多的随机feature，以及更多的retrigger对玩家SPIN的影响
可调整参数：
三种Buff效果，在各自feature中触发的次数分布；
Link中触发随机Feature的次数体验，随机Feature能够触发retrigger的次数比例
Link的平均SPIN次数（防止LINK体验过于冗长）
参考279机器测试结果：
不需要调高多feature触发的概率，让特别幸运感保留在feature中的意外惊喜；
需要相对较多的Base火球的出现









赞成为第一个赞同者
无标签 编辑标签
用户图标: 添加头像
写评论...
基于 Atlassian Confluence 7.13.0 技术构建 报告缺陷 Atlassian 新闻
Atlassian