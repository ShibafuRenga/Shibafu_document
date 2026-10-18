-- Santa's Gifts Feature Extra Feature加成逻辑
-- 负责处理B02图标的Extra加成逻辑

local SantasGiftsExtraFeatureLogic = BaseClass("SantasGiftsExtraFeatureLogic")

-- 初始化
function SantasGiftsExtraFeatureLogic:__init()
    -- Extra等级配置
    self.extraLevels = {1, 2, 3}
    -- Extra权重配置
    self.extraWeights = {
        [1] = 60,  -- EXTRA
        [2] = 30,  -- EXTRA2
        [3] = 10   -- EXTRA3
    }
    -- 数值限制
    self.constraints = {
        avoidExtra3AndJackpot = true,  -- 避免Extra3和Jackpot同时出现
        maxExtraLevel = 3,  -- 最大Extra等级
        minExtraLevel = 1   -- 最小Extra等级
    }
end

-- 生成B02图标的Extra等级
function SantasGiftsExtraFeatureLogic:GenerateExtraLevel(context)
    -- 检查数值限制
    if not self:CheckNumericalConstraints(context) then
        return self:GenerateSafeExtraLevel(context)
    end
    
    -- 根据权重随机选择Extra等级
    return self:GetWeightedRandomExtraLevel()
end

-- 检查数值限制
function SantasGiftsExtraFeatureLogic:CheckNumericalConstraints(context)
    -- 检查是否应该避免Extra3和Jackpot同时出现
    if self.constraints.avoidExtra3AndJackpot then
        if self:HasExistingJackpotBonus(context) then
            return false
        end
    end
    
    return true
end

-- 检查是否已有Jackpot Bonus
function SantasGiftsExtraFeatureLogic:HasExistingJackpotBonus(context)
    if not context or not context.revealedBonuses then
        return false
    end
    
    for _, bonus in ipairs(context.revealedBonuses) do
        if bonus.type == "jackpotBonus" then
            return true
        end
    end
    
    return false
end

-- 生成安全的Extra等级（避免冲突）
function SantasGiftsExtraFeatureLogic:GenerateSafeExtraLevel(context)
    -- 如果已有Jackpot Bonus，则避免Extra3
    if self:HasExistingJackpotBonus(context) then
        local safeWeights = {
            [1] = 70,  -- EXTRA
            [2] = 30   -- EXTRA2
        }
        return self:GetWeightedRandomExtraLevel(safeWeights)
    end
    
    -- 默认返回Extra1
    return 1
end

-- 根据权重获取随机Extra等级
function SantasGiftsExtraFeatureLogic:GetWeightedRandomExtraLevel(weights)
    weights = weights or self.extraWeights
    
    local totalWeight = 0
    for level, weight in pairs(weights) do
        totalWeight = totalWeight + weight
    end
    
    local randomValue = math.random() * totalWeight
    local currentWeight = 0
    
    for level, weight in pairs(weights) do
        currentWeight = currentWeight + weight
        if randomValue <= currentWeight then
            return level
        end
    end
    
    return 1
end

-- 应用Extra加成到Credits
function SantasGiftsExtraFeatureLogic:ApplyExtraToCredits(creditsValue, extraLevel)
    if not IsNumber(creditsValue) or creditsValue <= 0 then
        return creditsValue
    end
    
    local multiplier = 1 + extraLevel  -- 1倍 = 原值，2倍 = 3倍，3倍 = 4倍
    return creditsValue * multiplier
end

-- 应用Extra加成到Free Spins
function SantasGiftsExtraFeatureLogic:ApplyExtraToFreeSpins(freeSpinsCount, extraLevel)
    if not IsNumber(freeSpinsCount) or freeSpinsCount <= 0 then
        return freeSpinsCount
    end
    
    local additionalSpins = extraLevel * 5  -- 每个extra等级增加5次
    return freeSpinsCount + additionalSpins
end

-- 应用Extra加成到Jackpot Bonus
function SantasGiftsExtraFeatureLogic:ApplyExtraToJackpotBonus(extraLevel)
    -- Extra等级直接对应Remove Level数量
    return extraLevel
end

-- 计算总Extra等级
function SantasGiftsExtraFeatureLogic:CalculateTotalExtraLevel(extraLevels)
    local totalLevel = 0
    for _, level in ipairs(extraLevels) do
        totalLevel = totalLevel + level
    end
    return totalLevel
end

-- 应用总Extra加成
function SantasGiftsExtraFeatureLogic:ApplyTotalExtraToRewards(rewards, totalExtraLevel)
    if not rewards or totalExtraLevel <= 0 then
        return rewards
    end
    
    local modifiedRewards = DeepCopy(rewards)
    
    -- 应用Credits加成
    if modifiedRewards.totalCredits and modifiedRewards.totalCredits > 0 then
        modifiedRewards.totalCredits = self:ApplyExtraToCredits(modifiedRewards.totalCredits, totalExtraLevel)
    end
    
    -- 应用Free Spins加成
    if modifiedRewards.totalFreeSpins and modifiedRewards.totalFreeSpins > 0 then
        modifiedRewards.totalFreeSpins = self:ApplyExtraToFreeSpins(modifiedRewards.totalFreeSpins, totalExtraLevel)
    end
    
    -- 应用Jackpot Remove Levels
    if modifiedRewards.hasJackpotBonus then
        modifiedRewards.jackpotRemoveLevels = self:ApplyExtraToJackpotBonus(totalExtraLevel)
    end
    
    return modifiedRewards
end

-- 获取Extra等级显示文本
function SantasGiftsExtraFeatureLogic:GetExtraLevelDisplayText(extraLevel)
    if extraLevel == 1 then
        return "EXTRA"
    elseif extraLevel == 2 then
        return "EXTRA2"
    elseif extraLevel == 3 then
        return "EXTRA3"
    else
        return "EXTRA" .. tostring(extraLevel)
    end
end

-- 获取Extra等级描述
function SantasGiftsExtraFeatureLogic:GetExtraLevelDescription(extraLevel)
    if extraLevel == 1 then
        return "分值增加1倍（变成原来的2倍）"
    elseif extraLevel == 2 then
        return "分值增加2倍（变成原来的3倍）"
    elseif extraLevel == 3 then
        return "分值增加3倍（变成原来的4倍）"
    else
        return "分值增加" .. tostring(extraLevel) .. "倍"
    end
end

-- 获取Free Spins加成描述
function SantasGiftsExtraFeatureLogic:GetFreeSpinsExtraDescription(extraLevel)
    local additionalSpins = extraLevel * 5
    return "Free Spins增加" .. tostring(additionalSpins) .. "次"
end

-- 获取Jackpot Remove Levels描述
function SantasGiftsExtraFeatureLogic:GetJackpotRemoveLevelsDescription(extraLevel)
    if extraLevel == 1 then
        return "Jackpot Bonus变成remove level"
    elseif extraLevel == 2 then
        return "Jackpot Bonus变成remove level2"
    else
        return "Jackpot Bonus增加" .. tostring(extraLevel) .. "个remove level"
    end
end

-- 验证Extra等级
function SantasGiftsExtraFeatureLogic:ValidateExtraLevel(extraLevel)
    if not IsNumber(extraLevel) then
        return false
    end
    
    return extraLevel >= self.constraints.minExtraLevel and 
           extraLevel <= self.constraints.maxExtraLevel
end

-- 获取Extra等级动画配置
function SantasGiftsExtraFeatureLogic:GetExtraLevelAnimationConfig(extraLevel)
    local config = {
        duration = 1.0,
        delay = 0.2,
        effectType = "extra",
        scale = 1.0
    }
    
    -- 根据Extra等级调整动画配置
    if extraLevel == 1 then
        config.duration = 0.8
        config.scale = 1.0
    elseif extraLevel == 2 then
        config.duration = 1.0
        config.scale = 1.2
    elseif extraLevel == 3 then
        config.duration = 1.2
        config.scale = 1.5
    end
    
    return config
end

-- 获取Extra等级音效配置
function SantasGiftsExtraFeatureLogic:GetExtraLevelSoundConfig(extraLevel)
    local config = {
        soundName = "extra_default",
        volume = 1.0,
        pitch = 1.0
    }
    
    -- 根据Extra等级调整音效配置
    if extraLevel == 1 then
        config.soundName = "extra_1"
        config.volume = 0.8
        config.pitch = 1.0
    elseif extraLevel == 2 then
        config.soundName = "extra_2"
        config.volume = 1.0
        config.pitch = 0.9
    elseif extraLevel == 3 then
        config.soundName = "extra_3"
        config.volume = 1.2
        config.pitch = 0.8
    end
    
    return config
end

-- 获取Extra等级特效配置
function SantasGiftsExtraFeatureLogic:GetExtraLevelEffectConfig(extraLevel)
    local config = {
        effectName = "extra_default",
        duration = 2.0,
        scale = 1.0,
        color = "white"
    }
    
    -- 根据Extra等级调整特效配置
    if extraLevel == 1 then
        config.effectName = "extra_1"
        config.duration = 1.5
        config.scale = 1.0
        config.color = "green"
    elseif extraLevel == 2 then
        config.effectName = "extra_2"
        config.duration = 2.0
        config.scale = 1.2
        config.color = "blue"
    elseif extraLevel == 3 then
        config.effectName = "extra_3"
        config.duration = 2.5
        config.scale = 1.5
        config.color = "red"
    end
    
    return config
end

-- 检查Extra等级组合是否有效
function SantasGiftsExtraFeatureLogic:IsValidExtraCombination(extraLevels, context)
    if not IsTable(extraLevels) then
        return false
    end
    
    local totalLevel = self:CalculateTotalExtraLevel(extraLevels)
    
    -- 检查是否超过最大等级限制
    if totalLevel > self.constraints.maxExtraLevel * 3 then  -- 最多3个Extra3
        return false
    end
    
    -- 检查是否与Jackpot Bonus冲突
    if self.constraints.avoidExtra3AndJackpot then
        local hasExtra3 = false
        for _, level in ipairs(extraLevels) do
            if level >= 3 then
                hasExtra3 = true
                break
            end
        end
        
        if hasExtra3 and self:HasExistingJackpotBonus(context) then
            return false
        end
    end
    
    return true
end

-- 获取Extra等级统计信息
function SantasGiftsExtraFeatureLogic:GetExtraLevelStatistics(extraLevels)
    local stats = {
        totalLevel = 0,
        levelCount = {},
        hasExtra1 = false,
        hasExtra2 = false,
        hasExtra3 = false
    }
    
    for _, level in ipairs(extraLevels) do
        stats.totalLevel = stats.totalLevel + level
        stats.levelCount[level] = (stats.levelCount[level] or 0) + 1
        
        if level == 1 then
            stats.hasExtra1 = true
        elseif level == 2 then
            stats.hasExtra2 = true
        elseif level == 3 then
            stats.hasExtra3 = true
        end
    end
    
    return stats
end

-- 设置Extra等级配置
function SantasGiftsExtraFeatureLogic:SetExtraLevels(levels)
    self.extraLevels = levels or self.extraLevels
end

-- 设置Extra权重配置
function SantasGiftsExtraFeatureLogic:SetExtraWeights(weights)
    self.extraWeights = weights or self.extraWeights
end

-- 设置数值限制
function SantasGiftsExtraFeatureLogic:SetConstraints(constraints)
    self.constraints = constraints or self.constraints
end

-- 获取Extra等级概率分布
function SantasGiftsExtraFeatureLogic:GetExtraLevelProbabilityDistribution()
    local totalWeight = 0
    for _, weight in pairs(self.extraWeights) do
        totalWeight = totalWeight + weight
    end
    
    local distribution = {}
    for level, weight in pairs(self.extraWeights) do
        distribution[level] = weight / totalWeight
    end
    
    return distribution
end

-- 计算Extra等级期望值
function SantasGiftsExtraFeatureLogic:CalculateExtraLevelExpectedValue()
    local distribution = self:GetExtraLevelProbabilityDistribution()
    local expectedValue = 0
    
    for level, probability in pairs(distribution) do
        expectedValue = expectedValue + (level * probability)
    end
    
    return expectedValue
end

return SantasGiftsExtraFeatureLogic
