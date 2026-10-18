local SantasGiftsExtraFeature = BaseClass("SantasGiftsExtraFeature")

-- 常量：B01 可揭示类型
local REVEAL_TYPE = {
    Credits = 1,
    FS5 = 2,
    FS10 = 3,
    Jackpot = 4
}

-- 常量：B02 Extra 类型
local EXTRA_TYPE = {
    EXTRA = 1,
    EXTRA2 = 2,
    EXTRA3 = 3
}

local DEFAULT_CREDIT_SEQUENCE = {0.2, 0.5, 1, 2, 3, 5, 10, 15, 20}

function SantasGiftsExtraFeature:ResolveSantaGifts(b01List, extra)
    if IsNull(b01List) or not IsArray(b01List) or #b01List == 0 then
        return { totalCredits = 0, freeSpinsToAdd = 0, jackpotTriggered = false, jackpotRemoveLevel = 0 }
    end

    local hasExtra = IsNotNull(extra) and IsNotNull(extra.type)
    local extraType = hasExtra and extra.type or nil

    local totalCredits = 0
    local freeSpinsToAdd = 0
    local jackpotTriggered = false
    local jackpotRemoveLevel = 0

    local creditMultiplierByExtra = {
        [EXTRA_TYPE.EXTRA] = 2,
        [EXTRA_TYPE.EXTRA2] = 3,
        [EXTRA_TYPE.EXTRA3] = 4
    }
    local fsAddByExtra = {
        [EXTRA_TYPE.EXTRA] = 5,
        [EXTRA_TYPE.EXTRA2] = 10,
        [EXTRA_TYPE.EXTRA3] = 15
    }

    for _, item in ipairs(b01List) do
        if IsNull(item) or IsNull(item.type) then
            goto continue
        end

        if item.type == REVEAL_TYPE.Credits then
            local base = item.value or 0
            local mul = 1
            if hasExtra and creditMultiplierByExtra[extraType] then
                mul = creditMultiplierByExtra[extraType]
            end
            totalCredits = totalCredits + (base * mul)

        elseif item.type == REVEAL_TYPE.FS5 then
            local add = 5
            if hasExtra and fsAddByExtra[extraType] then
                add = add + fsAddByExtra[extraType]
            end
            freeSpinsToAdd = freeSpinsToAdd + add

        elseif item.type == REVEAL_TYPE.FS10 then
            local add = 10
            if hasExtra and fsAddByExtra[extraType] then
                add = add + fsAddByExtra[extraType]
            end
            freeSpinsToAdd = freeSpinsToAdd + add

        elseif item.type == REVEAL_TYPE.Jackpot then
            jackpotTriggered = true
            if hasExtra then
                if extraType == EXTRA_TYPE.EXTRA then
                    jackpotRemoveLevel = math.max(jackpotRemoveLevel, 1)
                elseif extraType == EXTRA_TYPE.EXTRA2 then
                    jackpotRemoveLevel = math.max(jackpotRemoveLevel, 2)
                end
            end
        end

        ::continue::
    end

    return {
        totalCredits = totalCredits,
        freeSpinsToAdd = freeSpinsToAdd,
        jackpotTriggered = jackpotTriggered,
        jackpotRemoveLevel = jackpotRemoveLevel
    }
end

SantasGiftsExtraFeature.Execute = async(function(self, b01List, extra)
    local result = self:ResolveSantaGifts(b01List, extra)

    if result.totalCredits and result.totalCredits > 0 then
        local DollarView = SlotsMachine.View.GetView("DollarView")
        if IsNotNull(DollarView) and IsFunction(DollarView.AddWin) then
            safe_execute(function()
                DollarView:AddWin(result.totalCredits)
            end, "SantasGiftsExtraFeature_AddWin")
        end
    end

    if result.freeSpinsToAdd and result.freeSpinsToAdd > 0 then
        safe_execute(function()
            SlotsMachine.ShowDialog("free", "trigger", 0, result.freeSpinsToAdd)
        end, "SantasGiftsExtraFeature_FreeTrigger")
    end

    if result.jackpotTriggered then
        safe_execute(function()
            local dialogName = "JackpotDialog"
            local startEvent = result.jackpotRemoveLevel == 2 and "JackpotDialogStart2" or (result.jackpotRemoveLevel == 1 and "JackpotDialogStart1" or "JackpotDialogStart")
            SlotsMachine.ShowDialog(dialogName, startEvent, 0)
        end, "SantasGiftsExtraFeature_JackpotTrigger")
    end
end)

function SantasGiftsExtraFeature:Restore()
    -- Santa's Gifts Feature 恢复交由 Free/Bonus 自身流程处理
end

return SantasGiftsExtraFeature

