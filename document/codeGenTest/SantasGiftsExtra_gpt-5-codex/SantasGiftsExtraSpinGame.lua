local CSLuaMachineUtility = CS.LuaFramework.LuaMachineUtility
local CSPanel = CS.BlowFire.SlotLib.Panel

local SantasGiftsExtraConstant = require("Machines.SantasGiftsExtra.SantasGiftsExtraConstant")
local SantasGiftsExtraHelper = require("Machines.SantasGiftsExtra.SantasGiftsExtraHelper")

local SantasGiftsExtraSpinGame = BaseClass("SantasGiftsExtraSpinGame")

function SantasGiftsExtraSpinGame:Init(spinGame)
    self.spinGame = spinGame
    SlotsMachine.View.AddViewByName("CSSantasGiftsExtraSpinGame", self.spinGame)
    SlotsMachine.View.AddViewByName("SantasGiftsExtraSpinGame", self)

    self.featureData = nil
    self.isPlayingReveal = false
end

function SantasGiftsExtraSpinGame:InitStartState()
    self:Reset()

    if SantasGiftsExtraHelper.IsFeatureRecoverable() then
        self:RestoreFeature()
    end
end

function SantasGiftsExtraSpinGame:Reset()
    self.featureData = nil
    self.isPlayingReveal = false
    local boardsCollection = SlotsMachine.FeatureVM.GetBoardsCollection()
    if IsNotNull(boardsCollection) then
        boardsCollection.featureState = nil
    end
end

function SantasGiftsExtraSpinGame:RestoreFeature()
    local boardsCollection = SlotsMachine.FeatureVM.GetBoardsCollection()
    if IsNull(boardsCollection) then
        return
    end

    local featureState = boardsCollection.featureState
    if IsNull(featureState) then
        return
    end

    self.featureData = featureState
    self:PlayRevealSequence(featureState)
end

function SantasGiftsExtraSpinGame:SetFeatureData(featureData)
    self.featureData = featureData
end

function SantasGiftsExtraSpinGame:PlayRevealSequence(featureData)
    if self.isPlayingReveal then
        return
    end

    if IsNull(featureData) or IsNull(featureData.b01List) or #featureData.b01List == 0 then
        return
    end

    self.isPlayingReveal = true

    local function playEntryReveal(entry)
        if IsNull(entry) then
            return nil
        end

        local symbolView = entry.symbolView
        if IsNull(symbolView) then
            return nil
        end

        local revealType = entry.revealType
        if revealType == SantasGiftsExtraConstant.B01_TYPE.VALUE then
            symbolView:PlayAnimation("reveal_value", 1, 0, 99999)
        elseif revealType == SantasGiftsExtraConstant.B01_TYPE.FREE_SPIN then
            symbolView:PlayAnimation("reveal_free", 1, 0, 99999)
        elseif revealType == SantasGiftsExtraConstant.B01_TYPE.JACKPOT then
            symbolView:PlayAnimation("reveal_jackpot", 1, 0, 99999)
        else
            symbolView:PlayAnimation("reveal_value", 1, 0, 99999)
        end
    end

    local taskList = {}
    for _, entry in ipairs(featureData.b01List) do
        playEntryReveal(entry)
    end

    if IsNotNull(featureData.b02Data) then
        local symbolView = featureData.b02Data.symbolView
        if IsNotNull(symbolView) then
            symbolView:PlayAnimation("reveal_extra", 1, 0, 99999)
        end
    end

    await(AsyncTask.Delay(1.2))

    self:ApplyRewards(featureData)

    self.isPlayingReveal = false
end

function SantasGiftsExtraSpinGame:ApplyRewards(featureData)
    if IsNull(featureData) then
        return
    end

    local mul = 1
    local extraFreeSpin = 0
    local removeLevel = 0
    local extraType

    if IsNotNull(featureData.b02Data) then
        extraType = featureData.b02Data.extraType
        mul = SantasGiftsExtraHelper.GetB02Multiplier(extraType)
        extraFreeSpin = SantasGiftsExtraHelper.GetB02FreeSpinBonus(extraType)
        removeLevel = SantasGiftsExtraHelper.GetB02JackpotRemoveLevel(extraType)
    end

    local totalValue = 0
    local hasFreeSpin = false
    local freeSpinValue = 0
    local hasJackpot = false

    for _, entry in ipairs(featureData.b01List) do
        if IsNotNull(entry) then
            if entry.revealType == SantasGiftsExtraConstant.B01_TYPE.VALUE then
                totalValue = totalValue + (entry.value or 0)
            elseif entry.revealType == SantasGiftsExtraConstant.B01_TYPE.FREE_SPIN then
                hasFreeSpin = true
                freeSpinValue = entry.value or 0
            elseif entry.revealType == SantasGiftsExtraConstant.B01_TYPE.JACKPOT then
                hasJackpot = true
            end
        end
    end

    if totalValue > 0 then
        local finalValue = totalValue * mul
        MachineUtility.AddCoinsToWin(math.floor(finalValue * MachineUtility.GetCurrentBet()))
    end

    if hasFreeSpin then
        local totalFree = freeSpinValue + extraFreeSpin
        MachineUtility.TriggerFreeSpin(totalFree)
    end

    if hasJackpot then
        MachineUtility.TriggerJackpot(removeLevel)
    end

    self:Reset()
end

return SantasGiftsExtraSpinGame

