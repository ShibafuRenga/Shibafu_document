local CSGamePlayFacade = CS.Blowfire.Slot.UI.GamePlay.GamePlayFacade
local CSGameType = CS.Blowfire.Network.Data.Machine.GameType
local CSGameStatus = CS.Blowfire.Network.Data.Machine.GameStatus
local CSLuaMachineUtility = CS.LuaFramework.LuaMachineUtility

local SantasGiftsExtraConstant = require("Machines.SantasGiftsExtra.SantasGiftsExtraConstant")
local SantasGiftsExtraHelper = require("Machines.SantasGiftsExtra.SantasGiftsExtraHelper")

local SantasGiftsExtraModel = BaseClass("SantasGiftsExtraModel")

function SantasGiftsExtraModel.IsInBase()
    local gamePlay = CSGamePlayFacade.SpinResultEnumerator:GetCurrentGame()
    return IsNotNull(gamePlay) and gamePlay.GameType == CSGameType.Basegame
end

function SantasGiftsExtraModel.IsInFree()
    local gamePlay = CSGamePlayFacade.SpinResultEnumerator:GetCurrentGame()
    return IsNotNull(gamePlay) and gamePlay.GameType == CSGameType.Freespin
end

function SantasGiftsExtraModel.ShouldRestoreFeature()
    if SantasGiftsExtraModel.IsInBase() then
        local gamePlay = CSGamePlayFacade.SpinResultEnumerator:GetCurrentGame()
        return IsNotNull(gamePlay) and gamePlay.GameStatus == CSGameStatus.Pause
    end

    if SantasGiftsExtraModel.IsInFree() then
        local gamePlay = CSGamePlayFacade.SpinResultEnumerator:GetCurrentGame()
        return IsNotNull(gamePlay) and gamePlay.GameStatus ~= CSGameStatus.Over
    end

    return false
end

function SantasGiftsExtraModel.GetReels()
    return CSLuaMachineUtility.GetReelsViewModel()
end

function SantasGiftsExtraModel.GetB01Positions(reels)
    local positions = {}

    if IsNull(reels) then
        return positions
    end

    local symbols = reels.Symbols
    if IsNull(symbols) then
        return positions
    end

    for index = 0, symbols.Count - 1 do
        if symbols[index] == SantasGiftsExtraConstant.SYMBOL_ID.B01 then
            table.insert(positions, index)
        end
    end

    return positions
end

function SantasGiftsExtraModel.HasOnlyB02(reels)
    if IsNull(reels) then
        return false
    end

    local symbols = reels.Symbols
    if IsNull(symbols) then
        return false
    end

    local hasB02 = false
    local hasB01 = false

    for index = 0, symbols.Count - 1 do
        local symbolId = symbols[index]

        if symbolId == SantasGiftsExtraConstant.SYMBOL_ID.B02 then
            hasB02 = true
        elseif symbolId == SantasGiftsExtraConstant.SYMBOL_ID.B01 then
            hasB01 = true
            break
        end
    end

    return hasB02 and not hasB01
end

function SantasGiftsExtraModel.FindFirstB02(reels)
    if IsNull(reels) then
        return nil
    end

    local symbols = reels.Symbols
    if IsNull(symbols) then
        return nil
    end

    for index = 0, symbols.Count - 1 do
        if symbols[index] == SantasGiftsExtraConstant.SYMBOL_ID.B02 then
            return index
        end
    end

    return nil
end

function SantasGiftsExtraModel.GetBoardFeature()
    local featureVM = SlotsMachine.FeatureVM.AddFeature()
    SlotsMachine.FeatureVM.AddIntentionalTell(featureVM)
    SlotsMachine.FeatureVM.AddBoardsCollection(featureVM)
end

function SantasGiftsExtraModel.GetBoardCollection()
    return SlotsMachine.FeatureVM.GetBoardsCollection()
end

function SantasGiftsExtraModel.SaveBoardState(state)
    local boardsCollection = SantasGiftsExtraModel.GetBoardCollection()
    if IsNull(boardsCollection) then
        return
    end

    boardsCollection.featureState = state
end

function SantasGiftsExtraModel.LoadBoardState()
    local boardsCollection = SantasGiftsExtraModel.GetBoardCollection()
    if IsNull(boardsCollection) then
        return nil
    end

    return boardsCollection.featureState
end

function SantasGiftsExtraModel.ClearBoardState()
    local boardsCollection = SantasGiftsExtraModel.GetBoardCollection()
    if IsNotNull(boardsCollection) then
        boardsCollection.featureState = nil
    end
end

function SantasGiftsExtraModel.BuildFeatureData(b01List, b02Data)
    local t = {
        revealList = b01List,
        bonus = nil,
        bonusValue = 0,
        bonusExtra = nil,
        extraType = b02Data and b02Data.extraType or nil,
        extraPos = b02Data and b02Data.index or nil
    }

    return t
end

return SantasGiftsExtraModel

