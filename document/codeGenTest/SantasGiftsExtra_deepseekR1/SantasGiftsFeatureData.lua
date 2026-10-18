-- Santa's Gifts Feature 数据层
-- 机器名称：SantasGiftsExtra
-- 只关注数据本身，不包含任何展示相关的属性

local SantasGiftsFeatureData = BaseClass("SantasGiftsFeatureData")

-- 初始化
function SantasGiftsFeatureData:__init()
    -- 基础数据
    self.isActive = false
    self.bonusIcons = {}  -- B01图标列表
    self.extraIcons = {}  -- B02图标列表
    self.revealedBonuses = {}  -- 已reveal的bonus
    self.revealedExtras = {}   -- 已reveal的extra
    
    -- 奖励数据
    self.totalCredits = 0
    self.freeSpinsCount = 0
    self.jackpotBonus = false
    self.jackpotRemoveLevels = 0
    
    -- 状态数据
    self.currentPhase = "none"  -- none, revealing, completed
    self.revealIndex = 1
end

-- 重置数据
function SantasGiftsFeatureData:Reset()
    self.isActive = false
    self.bonusIcons = {}
    self.extraIcons = {}
    self.revealedBonuses = {}
    self.revealedExtras = {}
    self.totalCredits = 0
    self.freeSpinsCount = 0
    self.jackpotBonus = false
    self.jackpotRemoveLevels = 0
    self.currentPhase = "none"
    self.revealIndex = 1
end

-- 添加B01图标
function SantasGiftsFeatureData:AddBonusIcon(position, symbolData)
    local bonusIcon = {
        position = position,
        symbolData = symbolData,
        isRevealed = false,
        revealedType = nil,
        revealedValue = 0
    }
    table.insert(self.bonusIcons, bonusIcon)
end

-- 添加B02图标
function SantasGiftsFeatureData:AddExtraIcon(position, symbolData)
    local extraIcon = {
        position = position,
        symbolData = symbolData,
        isRevealed = false,
        revealedType = nil,
        extraLevel = 0
    }
    table.insert(self.extraIcons, extraIcon)
end

-- 获取B01图标数量
function SantasGiftsFeatureData:GetBonusIconCount()
    return #self.bonusIcons
end

-- 获取B02图标数量
function SantasGiftsFeatureData:GetExtraIconCount()
    return #self.extraIcons
end

-- 检查是否有B01图标
function SantasGiftsFeatureData:HasBonusIcons()
    return #self.bonusIcons > 0
end

-- 检查是否有B02图标
function SantasGiftsFeatureData:HasExtraIcons()
    return #self.extraIcons > 0
end

-- 检查是否只有B02图标（数值上需要规避的情况）
function SantasGiftsFeatureData:HasOnlyExtraIcons()
    return #self.bonusIcons == 0 and #self.extraIcons > 0
end

-- 设置B01图标reveal结果
function SantasGiftsFeatureData:SetBonusRevealResult(index, revealType, revealValue)
    if index > 0 and index <= #self.bonusIcons then
        local bonusIcon = self.bonusIcons[index]
        bonusIcon.isRevealed = true
        bonusIcon.revealedType = revealType
        bonusIcon.revealedValue = revealValue
        
        -- 添加到已reveal列表
        table.insert(self.revealedBonuses, {
            index = index,
            type = revealType,
            value = revealValue
        })
    end
end

-- 设置B02图标reveal结果
function SantasGiftsFeatureData:SetExtraRevealResult(index, extraLevel)
    if index > 0 and index <= #self.extraIcons then
        local extraIcon = self.extraIcons[index]
        extraIcon.isRevealed = true
        extraIcon.extraLevel = extraLevel
        
        -- 添加到已reveal列表
        table.insert(self.revealedExtras, {
            index = index,
            level = extraLevel
        })
    end
end

-- 获取总Extra等级
function SantasGiftsFeatureData:GetTotalExtraLevel()
    local totalLevel = 0
    for _, extra in ipairs(self.revealedExtras) do
        totalLevel = totalLevel + extra.level
    end
    return totalLevel
end

-- 计算最终奖励
function SantasGiftsFeatureData:CalculateFinalRewards()
    local totalCredits = 0
    local freeSpinsCount = 0
    local jackpotBonus = false
    local jackpotRemoveLevels = 0
    
    local extraLevel = self:GetTotalExtraLevel()
    
    -- 处理B01图标的奖励
    for _, bonus in ipairs(self.revealedBonuses) do
        if bonus.type == "credits" then
            local multiplier = 1 + extraLevel  -- 1倍 = 原值，2倍 = 3倍，3倍 = 4倍
            totalCredits = totalCredits + (bonus.value * multiplier)
        elseif bonus.type == "freeSpins" then
            local additionalSpins = extraLevel * 5  -- 每个extra等级增加5次
            freeSpinsCount = freeSpinsCount + bonus.value + additionalSpins
        elseif bonus.type == "jackpotBonus" then
            jackpotBonus = true
            jackpotRemoveLevels = extraLevel
        end
    end
    
    self.totalCredits = totalCredits
    self.freeSpinsCount = freeSpinsCount
    self.jackpotBonus = jackpotBonus
    self.jackpotRemoveLevels = jackpotRemoveLevels
end

-- 检查是否完成reveal
function SantasGiftsFeatureData:IsRevealComplete()
    local totalIcons = #self.bonusIcons + #self.extraIcons
    local revealedIcons = #self.revealedBonuses + #self.revealedExtras
    return revealedIcons >= totalIcons
end

-- 获取下一个需要reveal的图标
function SantasGiftsFeatureData:GetNextRevealIcon()
    -- 先reveal所有B01图标
    if self.revealIndex <= #self.bonusIcons then
        return "bonus", self.revealIndex
    end
    
    -- 再reveal所有B02图标
    local extraIndex = self.revealIndex - #self.bonusIcons
    if extraIndex <= #self.extraIcons then
        return "extra", extraIndex
    end
    
    return nil, 0
end

-- 移动到下一个reveal
function SantasGiftsFeatureData:MoveToNextReveal()
    self.revealIndex = self.revealIndex + 1
end

-- 设置当前阶段
function SantasGiftsFeatureData:SetCurrentPhase(phase)
    self.currentPhase = phase
end

-- 获取当前阶段
function SantasGiftsFeatureData:GetCurrentPhase()
    return self.currentPhase
end

-- 检查是否有Jackpot Bonus
function SantasGiftsFeatureData:HasJackpotBonus()
    return self.jackpotBonus
end

-- 检查是否有Free Spins
function SantasGiftsFeatureData:HasFreeSpins()
    return self.freeSpinsCount > 0
end

-- 检查是否有Credits奖励
function SantasGiftsFeatureData:HasCredits()
    return self.totalCredits > 0
end

-- 获取总Credits
function SantasGiftsFeatureData:GetTotalCredits()
    return self.totalCredits
end

-- 获取Free Spins次数
function SantasGiftsFeatureData:GetFreeSpinsCount()
    return self.freeSpinsCount
end

-- 获取Jackpot Remove Levels
function SantasGiftsFeatureData:GetJackpotRemoveLevels()
    return self.jackpotRemoveLevels
end

-- 检查是否同时有Free Spins和Jackpot Bonus（数值上需要排除的情况）
function SantasGiftsFeatureData:HasBothFreeSpinsAndJackpot()
    return self.jackpotBonus and self.freeSpinsCount > 0
end

-- 检查是否有Extra3和Jackpot Bonus同时出现（数值上需要排除的情况）
function SantasGiftsFeatureData:HasExtra3AndJackpot()
    local hasExtra3 = false
    for _, extra in ipairs(self.revealedExtras) do
        if extra.level >= 3 then
            hasExtra3 = true
            break
        end
    end
    return hasExtra3 and self.jackpotBonus
end

return SantasGiftsFeatureData
