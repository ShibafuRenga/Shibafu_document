-- Santa's Gifts Feature 控制器层
-- 负责业务逻辑控制和协调数据层与视图层

local SantasGiftsFeatureController = BaseClass("SantasGiftsFeatureController")

-- 初始化
function SantasGiftsFeatureController:__init()
    -- 数据层
    self.data = nil
    -- 视图层
    self.view = nil
    -- 状态
    self.isActive = false
    self.isRevealing = false
    -- 配置
    self.config = {}
    -- 回调
    self.onFeatureComplete = nil
    self.onCreditsAwarded = nil
    self.onFreeSpinsAwarded = nil
    self.onJackpotBonusAwarded = nil
end

-- 初始化控制器
function SantasGiftsFeatureController:Initialize(data, view, config)
    self.data = data
    self.view = view
    self.config = config or {}
    
    -- 设置默认配置
    self:SetupDefaultConfig()
    
    -- 初始化视图
    if not IsNull(self.view) then
        self.view:Initialize(self:GetFeaturePanel())
    end
end

-- 设置默认配置
function SantasGiftsFeatureController:SetupDefaultConfig()
    self.config.creditsValues = {0.2, 0.5, 1, 2, 3, 5, 10, 15, 20}
    self.config.freeSpinsValues = {5, 10}
    self.config.extraLevels = {1, 2, 3}
    self.config.revealDelay = 0.5
    self.config.autoReveal = true
end

-- 获取Feature面板
function SantasGiftsFeatureController:GetFeaturePanel()
    -- 这里应该从UI管理器获取Feature面板
    -- 暂时返回nil，实际使用时需要传入
    return nil
end

-- 触发Santa's Gifts Feature
function SantasGiftsFeatureController:TriggerFeature(bonusIcons, extraIcons)
    if self.isActive then
        Logger.LogWarning("Santa's Gifts Feature is already active")
        return
    end
    
    -- 验证输入数据
    if not self:ValidateInputData(bonusIcons, extraIcons) then
        Logger.LogError("Invalid input data for Santa's Gifts Feature")
        return
    end
    
    -- 重置数据
    self.data:Reset()
    
    -- 添加图标数据
    self:AddIconsToData(bonusIcons, extraIcons)
    
    -- 检查数值限制
    if not self:CheckNumericalConstraints() then
        Logger.LogError("Numerical constraints not met")
        return
    end
    
    -- 开始Feature
    self:StartFeature()
end

-- 验证输入数据
function SantasGiftsFeatureController:ValidateInputData(bonusIcons, extraIcons)
    if not IsTable(bonusIcons) and not IsTable(extraIcons) then
        return false
    end
    
    -- 检查是否有B01图标
    if IsTable(bonusIcons) and #bonusIcons == 0 and IsTable(extraIcons) and #extraIcons > 0 then
        -- 数值上规避只有B02的情况
        return false
    end
    
    return true
end

-- 添加图标数据
function SantasGiftsFeatureController:AddIconsToData(bonusIcons, extraIcons)
    -- 添加B01图标
    if IsTable(bonusIcons) then
        for _, bonusIcon in ipairs(bonusIcons) do
            self.data:AddBonusIcon(bonusIcon.position, bonusIcon.symbolData)
        end
    end
    
    -- 添加B02图标
    if IsTable(extraIcons) then
        for _, extraIcon in ipairs(extraIcons) do
            self.data:AddExtraIcon(extraIcon.position, extraIcon.symbolData)
        end
    end
end

-- 检查数值限制
function SantasGiftsFeatureController:CheckNumericalConstraints()
    -- 检查是否只有B02图标
    if self.data:HasOnlyExtraIcons() then
        return false
    end
    
    return true
end

-- 开始Feature
function SantasGiftsFeatureController:StartFeature()
    self.isActive = true
    self.data:SetCurrentPhase("revealing")
    
    -- 显示Feature UI
    self:ShowFeatureUI()
    
    -- 开始Reveal过程
    self:StartRevealProcess()
end

-- 显示Feature UI
function SantasGiftsFeatureController:ShowFeatureUI()
    if IsNull(self.view) then
        Logger.LogError("Santa's Gifts Feature View is null")
        return
    end
    
    self.view:ShowFeature(self.data.bonusIcons, self.data.extraIcons)
end

-- 开始Reveal过程
function SantasGiftsFeatureController:StartRevealProcess()
    self.isRevealing = true
    
    if IsNull(self.view) then
        Logger.LogError("Santa's Gifts Feature View is null")
        return
    end
    
    self.view:StartRevealProcess()
    
    -- 开始自动Reveal
    if self.config.autoReveal then
        self:StartAutoReveal()
    end
end

-- 开始自动Reveal
function SantasGiftsFeatureController:StartAutoReveal()
    self:RevealNextIcon()
end

-- Reveal下一个图标
function SantasGiftsFeatureController:RevealNextIcon()
    local iconType, index = self.data:GetNextRevealIcon()
    
    if not iconType then
        -- 所有图标都已reveal完成
        self:CompleteRevealProcess()
        return
    end
    
    -- 生成Reveal结果
    local revealType, revealValue = self:GenerateRevealResult(iconType, index)
    
    -- 设置数据
    if iconType == "bonus" then
        self.data:SetBonusRevealResult(index, revealType, revealValue)
    elseif iconType == "extra" then
        self.data:SetExtraRevealResult(index, revealValue)
    end
    
    -- 更新视图
    self:UpdateView(iconType, index, revealType, revealValue)
    
    -- 移动到下一个
    self.data:MoveToNextReveal()
    
    -- 延迟Reveal下一个图标
    if self.config.autoReveal then
        DoTween.DelayedCall(self.config.revealDelay, function()
            self:RevealNextIcon()
        end)
    end
end

-- 生成Reveal结果
function SantasGiftsFeatureController:GenerateRevealResult(iconType, index)
    if iconType == "bonus" then
        return self:GenerateBonusRevealResult()
    elseif iconType == "extra" then
        return self:GenerateExtraRevealResult()
    end
    
    return nil, 0
end

-- 生成B01 Reveal结果
function SantasGiftsFeatureController:GenerateBonusRevealResult()
    -- 检查数值限制
    if self:ShouldAvoidFreeSpinsAndJackpot() then
        return "credits", self:GetRandomCreditsValue()
    end
    
    if self:ShouldAvoidExtra3AndJackpot() then
        -- 如果已经有Extra3，则避免Jackpot
        return self:GetRandomNonJackpotBonus()
    end
    
    -- 随机选择奖励类型
    local rewardType = self:GetRandomRewardType()
    
    if rewardType == "credits" then
        return "credits", self:GetRandomCreditsValue()
    elseif rewardType == "freeSpins" then
        return "freeSpins", self:GetRandomFreeSpinsValue()
    elseif rewardType == "jackpotBonus" then
        return "jackpotBonus", 0
    end
    
    return "credits", self:GetRandomCreditsValue()
end

-- 生成B02 Reveal结果
function SantasGiftsFeatureController:GenerateExtraRevealResult()
    -- 随机选择Extra等级
    local extraLevel = self:GetRandomExtraLevel()
    return "extra", extraLevel
end

-- 检查是否应该避免Free Spins和Jackpot同时出现
function SantasGiftsFeatureController:ShouldAvoidFreeSpinsAndJackpot()
    -- 检查是否已经有Free Spins
    for _, bonus in ipairs(self.data.revealedBonuses) do
        if bonus.type == "freeSpins" then
            return true
        end
    end
    
    return false
end

-- 检查是否应该避免Extra3和Jackpot同时出现
function SantasGiftsFeatureController:ShouldAvoidExtra3AndJackpot()
    -- 检查是否已经有Extra3
    for _, extra in ipairs(self.data.revealedExtras) do
        if extra.level >= 3 then
            return true
        end
    end
    
    return false
end

-- 获取随机奖励类型
function SantasGiftsFeatureController:GetRandomRewardType()
    local weights = {
        credits = 70,
        freeSpins = 20,
        jackpotBonus = 10
    }
    
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

-- 获取随机Credits值
function SantasGiftsFeatureController:GetRandomCreditsValue()
    local values = self.config.creditsValues
    return values[math.random(1, #values)]
end

-- 获取随机Free Spins值
function SantasGiftsFeatureController:GetRandomFreeSpinsValue()
    local values = self.config.freeSpinsValues
    return values[math.random(1, #values)]
end

-- 获取随机Extra等级
function SantasGiftsFeatureController:GetRandomExtraLevel()
    local levels = self.config.extraLevels
    return levels[math.random(1, #levels)]
end

-- 获取随机非Jackpot奖励
function SantasGiftsFeatureController:GetRandomNonJackpotBonus()
    local weights = {
        credits = 80,
        freeSpins = 20
    }
    
    local totalWeight = 0
    for _, weight in pairs(weights) do
        totalWeight = totalWeight + weight
    end
    
    local randomValue = math.random() * totalWeight
    local currentWeight = 0
    
    for rewardType, weight in pairs(weights) do
        currentWeight = currentWeight + weight
        if randomValue <= currentWeight then
            if rewardType == "credits" then
                return "credits", self:GetRandomCreditsValue()
            elseif rewardType == "freeSpins" then
                return "freeSpins", self:GetRandomFreeSpinsValue()
            end
        end
    end
    
    return "credits", self:GetRandomCreditsValue()
end

-- 更新视图
function SantasGiftsFeatureController:UpdateView(iconType, index, revealType, revealValue)
    if IsNull(self.view) then
        return
    end
    
    self.view:RevealIcon(iconType, index, revealType, revealValue)
end

-- 完成Reveal过程
function SantasGiftsFeatureController:CompleteRevealProcess()
    self.isRevealing = false
    self.data:SetCurrentPhase("completed")
    
    -- 计算最终奖励
    self.data:CalculateFinalRewards()
    
    -- 更新视图
    if not IsNull(self.view) then
        self.view:CompleteRevealProcess()
    end
    
    -- 延迟处理奖励
    DoTween.DelayedCall(1.0, function()
        self:ProcessFinalRewards()
    end)
end

-- 处理最终奖励
function SantasGiftsFeatureController:ProcessFinalRewards()
    -- 处理Credits奖励
    if self.data:HasCredits() then
        self:ProcessCreditsReward()
    end
    
    -- 处理Free Spins奖励
    if self.data:HasFreeSpins() then
        self:ProcessFreeSpinsReward()
    end
    
    -- 处理Jackpot Bonus奖励
    if self.data:HasJackpotBonus() then
        self:ProcessJackpotBonusReward()
    end
    
    -- 延迟结束Feature
    DoTween.DelayedCall(2.0, function()
        self:EndFeature()
    end)
end

-- 处理Credits奖励
function SantasGiftsFeatureController:ProcessCreditsReward()
    local credits = self.data:GetTotalCredits()
    Logger.Log("Santa's Gifts Feature awarded credits: " .. credits)
    
    -- 通知Credits奖励
    if self.onCreditsAwarded then
        self.onCreditsAwarded(credits)
    end
end

-- 处理Free Spins奖励
function SantasGiftsFeatureController:ProcessFreeSpinsReward()
    local freeSpinsCount = self.data:GetFreeSpinsCount()
    Logger.Log("Santa's Gifts Feature awarded free spins: " .. freeSpinsCount)
    
    -- 通知Free Spins奖励
    if self.onFreeSpinsAwarded then
        self.onFreeSpinsAwarded(freeSpinsCount)
    end
end

-- 处理Jackpot Bonus奖励
function SantasGiftsFeatureController:ProcessJackpotBonusReward()
    local removeLevels = self.data:GetJackpotRemoveLevels()
    Logger.Log("Santa's Gifts Feature awarded jackpot bonus with remove levels: " .. removeLevels)
    
    -- 通知Jackpot Bonus奖励
    if self.onJackpotBonusAwarded then
        self.onJackpotBonusAwarded(removeLevels)
    end
end

-- 结束Feature
function SantasGiftsFeatureController:EndFeature()
    self.isActive = false
    
    -- 隐藏Feature UI
    if not IsNull(self.view) then
        self.view:HideFeature()
    end
    
    -- 通知Feature完成
    if self.onFeatureComplete then
        self.onFeatureComplete()
    end
end

-- 设置回调
function SantasGiftsFeatureController:SetCallbacks(callbacks)
    self.onFeatureComplete = callbacks.onFeatureComplete
    self.onCreditsAwarded = callbacks.onCreditsAwarded
    self.onFreeSpinsAwarded = callbacks.onFreeSpinsAwarded
    self.onJackpotBonusAwarded = callbacks.onJackpotBonusAwarded
end

-- 检查是否激活
function SantasGiftsFeatureController:IsActive()
    return self.isActive
end

-- 检查是否正在Reveal
function SantasGiftsFeatureController:IsRevealing()
    return self.isRevealing
end

-- 获取当前阶段
function SantasGiftsFeatureController:GetCurrentPhase()
    if IsNull(self.data) then
        return "none"
    end
    return self.data:GetCurrentPhase()
end

-- 强制结束Feature
function SantasGiftsFeatureController:ForceEndFeature()
    if self.isActive then
        self:EndFeature()
    end
end

-- 销毁
function SantasGiftsFeatureController:OnDispose()
    self:ForceEndFeature()
    
    if not IsNull(self.data) then
        self.data:Reset()
    end
    
    if not IsNull(self.view) then
        self.view:OnDispose()
    end
    
    self.data = nil
    self.view = nil
    self.onFeatureComplete = nil
    self.onCreditsAwarded = nil
    self.onFreeSpinsAwarded = nil
    self.onJackpotBonusAwarded = nil
end

return SantasGiftsFeatureController
