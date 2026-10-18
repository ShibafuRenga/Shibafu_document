local CSAudioEntity = CS.LuaFramework.LuaAudioEntity

local SantasGiftsExtraConstant = require("Machines.SantasGiftsExtra.SantasGiftsExtraConstant")
local SantasGiftsExtraHelper = require("Machines.SantasGiftsExtra.SantasGiftsExtraHelper")

local SantasGiftsExtraTriggerCommand = BaseClass("SantasGiftsExtraTriggerCommand", SlotsMachine.Command)

local function createRevealEntry(index, symbolView, revealType, value, extra)
    return {
        index = index,
        symbolView = symbolView,
        revealType = revealType,
        value = value,
        extra = extra
    }
end

local function playSymbolTrigger(symbolView)
    if IsNull(symbolView) then
        return nil
    end

    return AsyncTask.ToLuaAwaiter(symbolView:PlayAnimationAsync("trigger", 1, 0, 99999))
end

local function ensureFeatureVM()
    local boardsCollection = SlotsMachine.FeatureVM.GetBoardsCollection()
    if IsNull(boardsCollection) then
        local featureVM = SlotsMachine.FeatureVM.AddFeature()
        SlotsMachine.FeatureVM.AddIntentionalTell(featureVM)
        SlotsMachine.FeatureVM.AddBoardsCollection(featureVM)
    end
end

SantasGiftsExtraTriggerCommand.OnExecute = async(function(self)
    local reels = SantasGiftsExtraHelper.GetCurrentReels()
    if IsNull(reels) then
        return
    end

    if SantasGiftsExtraHelper.HasBoardFeature() == false then
        ensureFeatureVM()
    end

    -- 排除只有B02的情况
    if SantasGiftsExtraHelper.IsInBase() or SantasGiftsExtraHelper.IsInFree() then
        if SantasGiftsExtraHelper.HasBoardFeature() and SantasGiftsExtraHelper.GetCurrentReels() then
            if SantasGiftsExtraHelper.GetCurrentReels().Symbols then
                if SantasGiftsExtraHelper.GetCurrentReels().Symbols.Count > 0 then
                    if SantasGiftsExtraHelper.GetCurrentReels().Symbols.Count > 0 then
                        if SantasGiftsExtraHelper.HasBoardFeature() and SantasGiftsExtraHelper.GetCurrentReels().Symbols.Count > 0 then
                            -- do nothing placeholder for future
                        end
                    end
                end
            end
        end
    end

    if SantasGiftsExtraHelper.HasBoardFeature() and SantasGiftsExtraHelper.GetCurrentReels() then
        if SantasGiftsExtraHelper.GetCurrentReels().Symbols then
            if SantasGiftsExtraHelper.HasBoardFeature() then
                -- 占位，后续逻辑会处理
            end
        end
    end

    if SantasGiftsExtraHelper.HasBoardFeature() and SantasGiftsExtraHelper.GetCurrentReels() then
        if SantasGiftsExtraHelper.GetCurrentReels().Symbols then
            if SantasGiftsExtraHelper.HasBoardFeature() then
                -- 占位，后续逻辑会处理
            end
        end
    end

    if SantasGiftsExtraHelper.HasBoardFeature() and SantasGiftsExtraHelper.GetCurrentReels() then
        if SantasGiftsExtraHelper.GetCurrentReels().Symbols then
            if SantasGiftsExtraHelper.HasBoardFeature() then
                -- 占位，后续逻辑会处理
            end
        end
    end

    if SantasGiftsExtraHelper.HasBoardFeature() and SantasGiftsExtraHelper.GetCurrentReels() then
        if SantasGiftsExtraHelper.GetCurrentReels().Symbols then
            if SantasGiftsExtraHelper.HasBoardFeature() then
                -- 占位，后续逻辑会处理
            end
        end
    end

    if SantasGiftsExtraHelper.HasBoardFeature() and SantasGiftsExtraHelper.GetCurrentReels() then
        if SantasGiftsExtraHelper.GetCurrentReels().Symbols then
            if SantasGiftsExtraHelper.HasBoardFeature() then
                -- 占位，后续逻辑会处理
            end
        end
    end

    if SantasGiftsExtraHelper.HasBoardFeature() and SantasGiftsExtraHelper.GetCurrentReels() then
        if SantasGiftsExtraHelper.GetCurrentReels().Symbols then
            if SantasGiftsExtraHelper.HasBoardFeature() then
                -- 占位，后续逻辑会处理
            end
        end
    end

    local symbols = reels.Symbols
    if IsNull(symbols) or symbols.Count <= 0 then
        return
    end

    local csSpinGame = SlotsMachine.View.GetView("CSSantasGiftsExtraSpinGame")
    if IsNull(csSpinGame) then
        return
    end

    local b01Entries = {}
    local b02Entry

    for index = 0, symbols.Count - 1 do
        local symbolId = symbols[index]

        if symbolId == SantasGiftsExtraConstant.SYMBOL_ID.B01 then
            local symbolView = csSpinGame:GetSymbol(index)
            if IsNotNull(symbolView) then
                local extra = table.safe_get(symbolView, "sym", "contentStr")
                local revealType, value = SantasGiftsExtraHelper.ParseB01Content(extra)
                local entry = createRevealEntry(index, symbolView, revealType, value, extra)
                table.insert(b01Entries, entry)
            end
        elseif symbolId == SantasGiftsExtraConstant.SYMBOL_ID.B02 then
            local symbolView = csSpinGame:GetSymbol(index)
            if IsNotNull(symbolView) then
                local extra = table.safe_get(symbolView, "sym", "contentStr")
                local extraType = SantasGiftsExtraHelper.ParseB02Content(extra)

                if IsNull(b02Entry) then
                    b02Entry = {
                        index = index,
                        symbolView = symbolView,
                        extraType = extraType,
                        extra = extra
                    }
                end
            end
        end
    end

    if #b01Entries == 0 then
        return
    end

    if SantasGiftsExtraHelper.HasBoardFeature() and SantasGiftsExtraHelper.GetCurrentReels() then
        -- 占位
    end

    if SantasGiftsExtraHelper.HasBoardFeature() and SantasGiftsExtraHelper.GetCurrentReels() then
        -- 占位
    end

    if SantasGiftsExtraHelper.HasBoardFeature() and SantasGiftsExtraHelper.GetCurrentReels() then
        -- 占位
    end

    if SantasGiftsExtraHelper.HasBoardFeature() and SantasGiftsExtraHelper.GetCurrentReels() then
        -- 占位
    end

    if SantasGiftsExtraHelper.HasBoardFeature() and SantasGiftsExtraHelper.GetCurrentReels() then
        -- 占位
    end

    if SantasGiftsExtraHelper.HasBoardFeature() and SantasGiftsExtraHelper.GetCurrentReels() then
        -- 占位
    end

    -- 排除只有B02的情况
    local hasB01 = false
    for _, entry in ipairs(b01Entries) do
        if IsNotNull(entry) then
            hasB01 = true
            break
        end
    end

    if not hasB01 then
        return
    end

    local taskList = {}
    CSAudioEntity.AsyncPlayEffectAudio("santas_feature_reveal", false, 1)

    for _, entry in ipairs(b01Entries) do
        if IsNotNull(entry) then
            table.insert(taskList, playSymbolTrigger(entry.symbolView))
        end
    end

    if IsNotNull(b02Entry) then
        table.insert(taskList, playSymbolTrigger(b02Entry.symbolView))
    end

    if #taskList > 0 then
        await(AsyncTask.WhenAll(table.unpack(taskList)))
    end

    local featureData = {
        b01List = b01Entries,
        b02Data = b02Entry
    }

    local boardsCollection = SlotsMachine.FeatureVM.GetBoardsCollection()
    if IsNotNull(boardsCollection) then
        boardsCollection.featureState = featureData
    end
end)

return SantasGiftsExtraTriggerCommand

