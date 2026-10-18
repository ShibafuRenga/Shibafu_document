-- Santa's Gifts Feature Bonus图标Reveal逻辑
-- 负责处理B01图标的reveal逻辑和数值控制

local SantasGiftsBonusRevealLogic = BaseClass("SantasGiftsBonusRevealLogic")

-- 初始化
function SantasGiftsBonusRevealLogic:__init()
    -- 分值序列
    self.creditsValues = {0.2, 0.5, 1, 2, 3, 5, 10, 15, 20}
    -- Free Spins次数
    self.freeSpinsValues = {5, 10}
    -- 权重配置
    self.weights = {
        credits = 70,
        freeSpins = 20,
        jackpotBonus = 10
    }
    -- 数值限制
    self.constraints = {
        avoidOnlyExtra = true,  -- 避免只有B02的情况
        avoidFreeSpinsAndJackpot = true,  -- 避免Free Spins和Jackpot同时出现
        avoidExtra3AndJackpot = true  -- 避免Extra3和Jackpot同时出现
    }
end

-- 生成B01图标的Reveal结果
function SantasGiftsBonusRevealLogic:GenerateBonusRevealResult(context)
    -- 检查数值限制
    if not self:CheckNumericalConstraints(context) then
        return self:GenerateSafeRevealResult(context)
    end
    
    -- 随机选择奖励类型
    local rewardType = self:GetRandomRewardType(context)
    
    -- 根据奖励类型生成结果
    if rewardType == "credits" then
        return self:GenerateCreditsResult(context)
    elseif rewardType == "freeSpins" then
        return self:GenerateFreeSpinsResult(context)
    elseif rewardType == "jackpotBonus" then
        return self:GenerateJackpotBonusResult(context)
    end
    
    -- 默认返回Credits
    return self:GenerateCreditsResult(context)
end

-- 检查数值限制
function SantasGiftsBonusRevealLogic:CheckNumericalConstraints(context)
    -- 检查是否应该避免Free Spins和Jackpot同时出现
    if self.constraints.avoidFreeSpinsAndJackpot then
        if self:HasExistingFreeSpins(context) then
            return false
        end
    end
    
    -- 检查是否应该避免Extra3和Jackpot同时出现
    if self.constraints.avoidExtra3AndJackpot then
        if self:HasExistingExtra3(context) then
            return false
        end
    end
    
    return true
end

-- 检查是否已有Free Spins
function SantasGiftsBonusRevealLogic:HasExistingFreeSpins(context)
    if not context or not context.revealedBonuses then
        return false
    end
    
    for _, bonus in ipairs(context.revealedBonuses) do
        if bonus.type == "freeSpins" then
            return true
        end
    end
    
    return false
end

-- 检查是否已有Extra3
function SantasGiftsBonusRevealLogic:HasExistingExtra3(context)
    if not context or not context.revealedExtras then
        return false
    end
    
    for _, extra in ipairs(context.revealedExtras) do
        if extra.level >= 3 then
            return true
        end
    end
    
    return false
end

-- 生成安全的Reveal结果（避免冲突）
function SantasGiftsBonusRevealLogic:GenerateSafeRevealResult(context)
    -- 如果已有Free Spins，则只返回Credits
    if self:HasExistingFreeSpins(context) then
        return self:GenerateCreditsResult(context)
    end
    
    -- 如果已有Extra3，则避免Jackpot
    if self:HasExistingExtra3(context) then
        local weights = {
            credits = 80,
            freeSpins = 20
        }
        local rewardType = self:GetWeightedRandomType(weights)
        
        if rewardType == "credits" then
            return self:GenerateCreditsResult(context)
        elseif rewardType == "freeSpins" then
            return self:GenerateFreeSpinsResult(context)
        end
    end
    
    -- 默认返回Credits
    return self:GenerateCreditsResult(context)
end

-- 获取随机奖励类型
function SantasGiftsBonusRevealLogic:GetRandomRewardType(context)
    return self:GetWeightedRandomType(self.weights)
end

-- 根据权重获取随机类型
function SantasGiftsBonusRevealLogic:GetWeightedRandomType(weights)
    local totalWeight = 0
    for _, weight in pairs(weights) do
        totalWeight = totalWeight + weight
    end
    
    local randomValue = math.random() * totalWeight
    local currentWeight = 0
    
    for rewardType, weight in pairs(weights) do
        currentWeight = currentWeight + weight
        if randomValue <= currentWeight then
            return rewardType
        end
    end
    
    return "credits"
end

-- 生成Credits结果
function SantasGiftsBonusRevealLogic:GenerateCreditsResult(context)
    local creditsValue = self:GetRandomCreditsValue()
    return {
        type = "credits",
        value = creditsValue,
        displayText = tostring(creditsValue),
        effectType = "credits"
    }
end

-- 生成Free Spins结果
function SantasGiftsBonusRevealLogic:GenerateFreeSpinsResult(context)
    local freeSpinsCount = self:GetRandomFreeSpinsValue()
    return {
        type = "freeSpins",
        value = freeSpinsCount,
        displayText = tostring(freeSpinsCount) .. " FREE SPINS",
        effectType = "freeSpins"
    }
end

-- 生成Jackpot Bonus结果
function SantasGiftsBonusRevealLogic:GenerateJackpotBonusResult(context)
    return {
        type = "jackpotBonus",
        value = 0,
        displayText = "JACKPOT BONUS",
        effectType = "jackpotBonus"
    }
end

-- 获取随机Credits值
function SantasGiftsBonusRevealLogic:GetRandomCreditsValue()
    return self.creditsValues[math.random(1, #self.creditsValues)]
end

-- 获取随机Free Spins值
function SantasGiftsBonusRevealLogic:GetRandomFreeSpinsValue()
    return self.freeSpinsValues[math.random(1, #self.freeSpinsValues)]
end

-- 应用Extra加成
function SantasGiftsBonusRevealLogic:ApplyExtraMultiplier(bonusResult, extraLevel)
    if not bonusResult or bonusResult.type ~= "credits" then
        return bonusResult
    end
    
    local multiplier = 1 + extraLevel  -- 1倍 = 原值，2倍 = 3倍，3倍 = 4倍
    local newValue = bonusResult.value * multiplier
    
    return {
        type = bonusResult.type,
        value = newValue,
        displayText = tostring(newValue),
        effectType = bonusResult.effectType,
        originalValue = bonusResult.value,
        multiplier = multiplier
    }
end

-- 应用Extra Free Spins加成
function SantasGiftsBonusRevealLogic:ApplyExtraFreeSpins(bonusResult, extraLevel)
    if not bonusResult or bonusResult.type ~= "freeSpins" then
        return bonusResult
    end
    
    local additionalSpins = extraLevel * 5  -- 每个extra等级增加5次
    local newValue = bonusResult.value + additionalSpins
    
    return {
        type = bonusResult.type,
        value = newValue,
        displayText = tostring(newValue) .. " FREE SPINS",
        effectType = bonusResult.effectType,
        originalValue = bonusResult.value,
        additionalSpins = additionalSpins
    }
end

-- 应用Extra Jackpot Remove Levels
function SantasGiftsBonusRevealLogic:ApplyExtraJackpotRemoveLevels(bonusResult, extraLevel)
    if not bonusResult or bonusResult.type ~= "jackpotBonus" then
        return bonusResult
    end
    
    return {
        type = bonusResult.type,
        value = bonusResult.value,
        displayText = bonusResult.displayText,
        effectType = bonusResult.effectType,
        removeLevels = extraLevel
    }
end

-- 计算最终奖励
function SantasGiftsBonusRevealLogic:CalculateFinalRewards(bonusResults, extraLevel)
    local totalCredits = 0
    local totalFreeSpins = 0
    local hasJackpotBonus = false
    local jackpotRemoveLevels = 0
    
    for _, bonusResult in ipairs(bonusResults) do
        if bonusResult.type == "credits" then
            totalCredits = totalCredits + bonusResult.value
        elseif bonusResult.type == "freeSpins" then
            totalFreeSpins = totalFreeSpins + bonusResult.value
        elseif bonusResult.type == "jackpotBonus" then
            hasJackpotBonus = true
            jackpotRemoveLevels = bonusResult.removeLevels or 0
        end
    end
    
    return {
        totalCredits = totalCredits,
        totalFreeSpins = totalFreeSpins,
        hasJackpotBonus = hasJackpotBonus,
        jackpotRemoveLevels = jackpotRemoveLevels
    }
end

-- 验证Reveal结果
function SantasGiftsBonusRevealLogic:ValidateRevealResult(result)
    if not result or not result.type then
        return false
    end
    
    if result.type == "credits" then
        return IsNumber(result.value) and result.value > 0
    elseif result.type == "freeSpins" then
        return IsNumber(result.value) and result.value > 0
    elseif result.type == "jackpotBonus" then
        return true
    end
    
    return false
end

-- 获取Reveal动画配置
function SantasGiftsBonusRevealLogic:GetRevealAnimationConfig(result)
    local config = {
        duration = 1.0,
        delay = 0.2,
        effectType = result.effectType or "default"
    }
    
    -- 根据奖励类型调整动画配置
    if result.type == "credits" then
        config.duration = 0.8
        config.effectType = "credits"
    elseif result.type == "freeSpins" then
        config.duration = 1.2
        config.effectType = "freeSpins"
    elseif result.type == "jackpotBonus" then
        config.duration = 1.5
        config.effectType = "jackpotBonus"
    end
    
    return config
end

-- 获取Reveal音效配置
function SantasGiftsBonusRevealLogic:GetRevealSoundConfig(result)
    local config = {
        soundName = "reveal_default",
        volume = 1.0,
        pitch = 1.0
    }
    
    -- 根据奖励类型调整音效配置
    if result.type == "credits" then
        config.soundName = "reveal_credits"
        config.volume = 0.8
    elseif result.type == "freeSpins" then
        config.soundName = "reveal_freeSpins"
        config.volume = 1.0
    elseif result.type == "jackpotBonus" then
        config.soundName = "reveal_jackpot"
        config.volume = 1.2
        config.pitch = 0.9
    end
    
    return config
end

-- 获取Reveal特效配置
function SantasGiftsBonusRevealLogic:GetRevealEffectConfig(result)
    local config = {
        effectName = "reveal_default",
        duration = 2.0,
        scale = 1.0
    }
    
    -- 根据奖励类型调整特效配置
    if result.type == "credits" then
        config.effectName = "reveal_credits"
        config.duration = 1.5
    elseif result.type == "freeSpins" then
        config.effectName = "reveal_freeSpins"
        config.duration = 2.0
    elseif result.type == "jackpotBonus" then
        config.effectName = "reveal_jackpot"
        config.duration = 3.0
        config.scale = 1.5
    end
    
    return config
end

-- 设置权重配置
function SantasGiftsBonusRevealLogic:SetWeights(weights)
    self.weights = weights or self.weights
end

-- 设置数值限制
function SantasGiftsBonusRevealLogic:SetConstraints(constraints)
    self.constraints = constraints or self.constraints
end

-- 设置分值序列
function SantasGiftsBonusRevealLogic:SetCreditsValues(values)
    self.creditsValues = values or self.creditsValues
end

-- 设置Free Spins值
function SantasGiftsBonusRevealLogic:SetFreeSpinsValues(values)
    self.freeSpinsValues = values or self.freeSpinsValues
end

return SantasGiftsBonusRevealLogic
