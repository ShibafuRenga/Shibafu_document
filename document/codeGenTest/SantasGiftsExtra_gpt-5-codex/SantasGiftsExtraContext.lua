local CSViewFacade = CS.Blowfire.Slot.UI.ViewFacade
local CSViewModel = CS.Blowfire.Slot.UI.ViewModel
local CSPayline = CSViewModel.Payline
local CSUIConstant = CS.Blowfire.Slot.UI.Constant.UIConstant
local CSReels = CS.Blowfire.Slot.UI.ViewModel.Reels

local SantasGiftsExtraContext = BaseClass("SantasGiftsExtraContext")

function SantasGiftsExtraContext:Init(context)
    self.context = context
    SlotsMachine.View.AddViewByName("SantasGiftsExtraContext", context)

    local freespin = require("Machines.SantasGiftsExtra.SantasGiftsExtraFreespin")
    MachineUtility.AddFreeSpinGamePlay(freespin.New())
    CSViewFacade.AddViewModel(CSViewModel.FreeSpin())

    local featureVM = SlotsMachine.FeatureVM.AddFeature()
    SlotsMachine.FeatureVM.AddIntentionalTell(featureVM)
    SlotsMachine.FeatureVM.AddBoardsCollection(featureVM)

    MachineUtility.AddAudioGamePlay()
    CSViewFacade.AddViewModel(CSPayline())
    CSViewFacade.AddViewModel(CSUIConstant.ExtraReels, CSReels())
end

return SantasGiftsExtraContext

