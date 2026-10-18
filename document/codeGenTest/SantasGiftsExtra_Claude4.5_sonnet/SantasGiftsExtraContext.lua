local CSViewFacade = CS.Blowfire.Slot.UI.ViewFacade
local CSViewModel = CS.Blowfire.Slot.UI.ViewModel
local CSPayline = CSViewModel.Payline
local CSUIConstant = CS.Blowfire.Slot.UI.Constant.UIConstant
local CSReels = CS.Blowfire.Slot.UI.ViewModel.Reels
local CSLuaMachineUtility = CS.LuaFramework.LuaMachineUtility
local CSBonus = CS.Blowfire.Slot.UI.ViewModel.Bonus

local SantasGiftsExtraContext = BaseClass("SantasGiftsExtraContext")

function SantasGiftsExtraContext:Init(context)
    self.context = context
    
    -- 注册主Context视图
    SlotsMachine.View.AddViewByName("SantasGiftsExtraContext", self.context)
    
    -- 注册Santa's Gifts Feature
    local feature = safe_require("Machines.SantasGiftsExtra.SantasGiftsExtraFeature")
    if IsNotNull(feature) then
        local featureInstance = feature.New()
        SlotsMachine.View.AddViewByName("SantasGiftsExtraFeature", featureInstance)
        MachineUtility.AddFeatureGamePlay(featureInstance)
    end
    
    -- 注册Feature ViewModel
    local featureVM = SlotsMachine.FeatureVM.AddFeature()
    SlotsMachine.FeatureVM.AddIntentionalTell(featureVM)
    SlotsMachine.FeatureVM.AddCollectionState(featureVM)
    
    -- 如果有Free Spins玩法，在这里注册
    local freespin = safe_require("Machines.SantasGiftsExtra.SantasGiftsExtraFreespin")
    if IsNotNull(freespin) then
        MachineUtility.AddFreeSpinGamePlay(freespin.New())
        CSViewFacade.AddViewModel(CSViewModel.FreeSpin())
    end
    
    -- 如果有Jackpot Bonus玩法，在这里注册
    local bonus = safe_require("Machines.SantasGiftsExtra.SantasGiftsExtraBonus")
    if IsNotNull(bonus) then
        CSLuaMachineUtility.AddBonusGamePlay(bonus.New())
        CSViewFacade.AddViewModel(CSBonus.Pick())
    end
    
    -- 注册音频玩法
    MachineUtility.AddAudioGamePlay()
    
    -- 注册PayLine
    CSViewFacade.AddViewModel(CSPayline())
    
    -- 注册额外的Reels（如果需要）
    CSViewFacade.AddViewModel(CSUIConstant.ExtraReels, CSReels())
end

function SantasGiftsExtraContext:BindData()
    -- 数据绑定逻辑（如果需要）
end

function SantasGiftsExtraContext:Dispose()
    -- 清理资源
    SlotsMachine.View.RemoveViewByName("SantasGiftsExtraContext")
    SlotsMachine.View.RemoveViewByName("SantasGiftsExtraFeature")
end

return SantasGiftsExtraContext
