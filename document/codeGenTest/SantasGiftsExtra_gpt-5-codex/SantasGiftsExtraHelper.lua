local CSGamePlayFacade = CS.Blowfire.Slot.UI.GamePlay.GamePlayFacade
local CSGameType = CS.Blowfire.Network.Data.Machine.GameType
local CSGameStatus = CS.Blowfire.Network.Data.Machine.GameStatus
local CSLuaMachineUtility = CS.LuaFramework.LuaMachineUtility

local SantasGiftsExtraConstant = require("Machines.SantasGiftsExtra.SantasGiftsExtraConstant")

local SantasGiftsExtraHelper = BaseClass("SantasGiftsExtraHelper")

function SantasGiftsExtraHelper.IsInBase()
    local gamePlay = CSGamePlayFacade.SpinResultEnumerator:GetCurrentGame()
    if IsNull(gamePlay) then
        return false
    end

    return gamePlay.GameType == CSGameType.Basegame
end

function SantasGiftsExtraHelper.IsInFree()
    local gamePlay = CSGamePlayFacade.SpinResultEnumerator:GetCurrentGame()
    if IsNull(gamePlay) then
        return false
    end

    return gamePlay.GameType == CSGameType.Freespin
end

function SantasGiftsExtraHelper.IsFeatureRecoverable()
    local gamePlay = CSGamePlayFacade.SpinResultEnumerator:GetCurrentGame()
    if IsNull(gamePlay) then
        return false
    end

    if gamePlay.GameType == CSGameType.Basegame then
        return gamePlay.GameStatus == CSGameStatus.Pause
    end

    if gamePlay.GameType == CSGameType.Freespin then
        return gamePlay.GameStatus ~= CSGameStatus.Over
    end

    return false
end

function SantasGiftsExtraHelper.HasBoardFeature()
    local boardsCollection = SlotsMachine.FeatureVM.GetBoardsCollection()
    return IsNotNull(boardsCollection)
end

function SantasGiftsExtraHelper.GetCurrentReels()
    return CSLuaMachineUtility.GetReelsViewModel()
end

function SantasGiftsExtraHelper.GetSymbolId(symbolIndex)
    local symbolId = SantasGiftsExtraConstant.SYMBOL_ID[symbolIndex]
    if IsNull(symbolId) then
        Logger.LogError(string.format("SantasGiftsExtra: 未知symbol索引 %s", tostring(symbolIndex)))
        return SantasGiftsExtraConstant.SYMBOL_ID.S01
    end

    return symbolId
end

function SantasGiftsExtraHelper.IsB01Symbol(symbolId)
    return symbolId == SantasGiftsExtraConstant.SYMBOL_ID.B01
end

function SantasGiftsExtraHelper.IsB02Symbol(symbolId)
    return symbolId == SantasGiftsExtraConstant.SYMBOL_ID.B02
end

function SantasGiftsExtraHelper.ParseB01Content(extra)
    if IsNull(extra) or extra == "" then
        return SantasGiftsExtraConstant.B01_TYPE.VALUE, 0
    end

    local numberValue = tonumber(extra)
    if IsNotNull(numberValue) then
        if SantasGiftsExtraConstant.B01_FREE_SPIN_VALUE[numberValue] then
            return SantasGiftsExtraConstant.B01_TYPE.FREE_SPIN, numberValue
        end

        if SantasGiftsExtraConstant.B01_VALUE_LOOKUP[numberValue] then
            return SantasGiftsExtraConstant.B01_TYPE.VALUE, numberValue
        end
    end

    if extra == "jackpot" then
        return SantasGiftsExtraConstant.B01_TYPE.JACKPOT, 0
    end

    Logger.LogWarning(string.format("SantasGiftsExtra: 未识别的B01内容 %s", tostring(extra)))
    return SantasGiftsExtraConstant.B01_TYPE.VALUE, 0
end

function SantasGiftsExtraHelper.ParseB02Content(extra)
    if IsNull(extra) or extra == "" then
        return SantasGiftsExtraConstant.B02_TYPE.EXTRA
    end

    local content = string.lower(extra)
    if content == "extra2" then
        return SantasGiftsExtraConstant.B02_TYPE.EXTRA2
    end

    if content == "extra3" then
        return SantasGiftsExtraConstant.B02_TYPE.EXTRA3
    end

    return SantasGiftsExtraConstant.B02_TYPE.EXTRA
end

function SantasGiftsExtraHelper.GetB02Multiplier(extraType)
    return SantasGiftsExtraConstant.B02_VALUE_MULTIPLIER[extraType] or 1
end

function SantasGiftsExtraHelper.GetB02FreeSpinBonus(extraType)
    return SantasGiftsExtraConstant.B02_FREE_SPIN_BONUS[extraType] or 0
end

function SantasGiftsExtraHelper.GetB02JackpotRemoveLevel(extraType)
    return SantasGiftsExtraConstant.B02_JACKPOT_REMOVE_LEVEL[extraType] or 0
end

return SantasGiftsExtraHelper

