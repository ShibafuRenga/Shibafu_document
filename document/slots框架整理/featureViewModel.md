相关文件：

1. FeatureVM.cs

add方法

get方法

2. FeatureVM.lua

字典里存Viewmodel

注册一下addViewModel的方法

3. IFeatureVM.cs

所有viewmodel的base

4. MachineViewModel.cs

5. LuaMachineUtility.cs

主要是往featureViewModel里面写东西以及取东西

6. 




5. 具体IFeatureVM实现类在Blowfire.Slot.UI.ViewModel中(CSharp)

  目前有


使用方法：

机器名Context.lua中注册 SlotsMachine.FeatureVM.Add[feature名称](featureVM)

SlotsMachine.FeatureVM.Get[feature名称]()

