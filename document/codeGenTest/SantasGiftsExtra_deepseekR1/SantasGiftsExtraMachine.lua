-- SantasGiftsExtra 机器主入口文件
-- 机器名称：SantasGiftsExtra
-- 整合所有Santa's Gifts Feature相关组件

local SantasGiftsExtraMachine = BaseClass("SantasGiftsExtraMachine")

-- 初始化
function SantasGiftsExtraMachine:__init()
    -- 组件引用
    self.data = nil
    self.view = nil
    self.controller = nil
    self.bonusRevealLogic = nil
    self.extraFeatureLogic = nil
    
    -- 状态
    self.isInitialized = false
    self.isActive = false
    
    -- 配置
    self.config = {}
end

-- 初始化机器
function SantasGiftsExtraMachine:Initialize(config)
    if self.isInitialized then
        Logger.LogWarning("SantasGiftsExtra Machine is already initialized")
        return
    end
    
    self.config = config or {}
    
    -- 初始化各个组件
    self:InitializeComponents()
    
    -- 设置组件之间的关联
    self:SetupComponentRelations()
    
    self.isInitialized = true
    Logger.Log("SantasGiftsExtra Machine initialized successfully")
end

-- 初始化各个组件
function SantasGiftsExtraMachine:InitializeComponents()
    -- 初始化数据层
    self.data = SantasGiftsFeatureData.New()
    
    -- 初始化视图层
    self.view = SantasGiftsFeatureView.New()
    
    -- 初始化控制器层
    self.controller = SantasGiftsFeatureController.New()
    
    -- 初始化Bonus Reveal逻辑
    self.bonusRevealLogic = SantasGiftsBonusRevealLogic.New()
    
    -- 初始化Extra Feature逻辑
    self.extraFeatureLogic = SantasGiftsExtraFeatureLogic.New()
    
    -- 设置配置
    self:SetupComponentConfigs()
end

-- 设置组件配置
function SantasGiftsExtraMachine:SetupComponentConfigs()
    -- 设置Bonus Reveal逻辑配置
    if self.bonusRevealLogic then
        self.bonusRevealLogic:SetWeights(self.config.bonusWeights)
        self.bonusRevealLogic:SetConstraints(self.config.bonusConstraints)
        self.bonusRevealLogic:SetCreditsValues(self.config.creditsValues)
        self.bonusRevealLogic:SetFreeSpinsValues(self.config.freeSpinsValues)
    end
    
    -- 设置Extra Feature逻辑配置
    if self.extraFeatureLogic then
        self.extraFeatureLogic:SetExtraWeights(self.config.extraWeights)
        self.extraFeatureLogic:SetConstraints(self.config.extraConstraints)
    end
end

-- 设置组件之间的关联
function SantasGiftsExtraMachine:SetupComponentRelations()
    -- 初始化控制器
    if self.controller then
        self.controller:Initialize(self.data, self.view, self.config)
        
        -- 设置回调
        self.controller:SetCallbacks({
            onFeatureComplete = function()
                self:OnFeatureComplete()
            end,
            onCreditsAwarded = function(credits)
                self:OnCreditsAwarded(credits)
            end,
            onFreeSpinsAwarded = function(freeSpinsCount)
                self:OnFreeSpinsAwarded(freeSpinsCount)
            end,
            onJackpotBonusAwarded = function(removeLevels)
                self:OnJackpotBonusAwarded(removeLevels)
            end
        })
    end
end

-- 触发Santa's Gifts Feature
function SantasGiftsExtraMachine:TriggerSantasGiftsFeature(bonusIcons, extraIcons)
    if not self.isInitialized then
        Logger.LogError("SantasGiftsExtra Machine is not initialized")
        return false
    end
    
    if self.isActive then
        Logger.LogWarning("SantasGiftsExtra Machine is already active")
        return false
    end
    
    -- 验证输入数据
    if not self:ValidateInputData(bonusIcons, extraIcons) then
        Logger.LogError("Invalid input data for Santa's Gifts Feature")
        return false
    end
    
    -- 通过控制器触发Feature
    if self.controller then
        self.controller:TriggerFeature(bonusIcons, extraIcons)
        self.isActive = true
        return true
    end
    
    return false
end

-- 验证输入数据
function SantasGiftsExtraMachine:ValidateInputData(bonusIcons, extraIcons)
    -- 检查是否有B01图标
    local hasBonusIcons = IsTable(bonusIcons) and #bonusIcons > 0
    local hasExtraIcons = IsTable(extraIcons) and #extraIcons > 0
    
    -- 数值上规避只有B02的情况
    if not hasBonusIcons and hasExtraIcons then
        Logger.LogError("Cannot have only B02 icons (numerical constraint)")
        return false
    end
    
    -- 至少需要一个图标
    if not hasBonusIcons and not hasExtraIcons then
        Logger.LogError("At least one icon is required")
        return false
    end
    
    return true
end

-- 检查是否激活
function SantasGiftsExtraMachine:IsActive()
    return self.isActive
end

-- 检查是否正在Reveal
function SantasGiftsExtraMachine:IsRevealing()
    if self.controller then
        return self.controller:IsRevealing()
    end
    return false
end

-- 获取当前阶段
function SantasGiftsExtraMachine:GetCurrentPhase()
    if self.controller then
        return self.controller:GetCurrentPhase()
    end
    return "none"
end

-- 强制结束Feature
function SantasGiftsExtraMachine:ForceEndFeature()
    if self.isActive and self.controller then
        self.controller:ForceEndFeature()
        self.isActive = false
    end
end

-- Feature完成回调
function SantasGiftsExtraMachine:OnFeatureComplete()
    self.isActive = false
    Logger.Log("Santa's Gifts Feature completed")
    
    -- 通知外部Feature完成
    if self.config.onFeatureComplete then
        self.config.onFeatureComplete()
    end
end

-- Credits奖励回调
function SantasGiftsExtraMachine:OnCreditsAwarded(credits)
    Logger.Log("Santa's Gifts Feature awarded credits: " .. credits)
    
    -- 通知外部Credits奖励
    if self.config.onCreditsAwarded then
        self.config.onCreditsAwarded(credits)
    end
end

-- Free Spins奖励回调
function SantasGiftsExtraMachine:OnFreeSpinsAwarded(freeSpinsCount)
    Logger.Log("Santa's Gifts Feature awarded free spins: " .. freeSpinsCount)
    
    -- 通知外部Free Spins奖励
    if self.config.onFreeSpinsAwarded then
        self.config.onFreeSpinsAwarded(freeSpinsCount)
    end
end

-- Jackpot Bonus奖励回调
function SantasGiftsExtraMachine:OnJackpotBonusAwarded(removeLevels)
    Logger.Log("Santa's Gifts Feature awarded jackpot bonus with remove levels: " .. removeLevels)
    
    -- 通知外部Jackpot Bonus奖励
    if self.config.onJackpotBonusAwarded then
        self.config.onJackpotBonusAwarded(removeLevels)
    end
end

-- 获取机器统计信息
function SantasGiftsExtraMachine:GetMachineStatistics()
    local stats = {
        isActive = self.isActive,
        isInitialized = self.isInitialized,
        currentPhase = self:GetCurrentPhase(),
        isRevealing = self:IsRevealing()
    }
    
    -- 添加数据统计
    if self.data then
        stats.bonusIconCount = self.data:GetBonusIconCount()
        stats.extraIconCount = self.data:GetExtraIconCount()
        stats.totalCredits = self.data:GetTotalCredits()
        stats.freeSpinsCount = self.data:GetFreeSpinsCount()
        stats.hasJackpotBonus = self.data:HasJackpotBonus()
        stats.jackpotRemoveLevels = self.data:GetJackpotRemoveLevels()
    end
    
    return stats
end

-- 更新配置
function SantasGiftsExtraMachine:UpdateConfig(newConfig)
    if not IsTable(newConfig) then
        Logger.LogError("Invalid config provided")
        return
    end
    
    -- 合并配置
    for key, value in pairs(newConfig) do
        self.config[key] = value
    end
    
    -- 更新组件配置
    self:SetupComponentConfigs()
    
    Logger.Log("SantasGiftsExtra Machine config updated")
end

-- 重置机器
function SantasGiftsExtraMachine:Reset()
    if self.isActive then
        self:ForceEndFeature()
    end
    
    if self.data then
        self.data:Reset()
    end
    
    Logger.Log("SantasGiftsExtra Machine reset")
end

-- 获取默认配置
function SantasGiftsExtraMachine:GetDefaultConfig()
    return {
        -- Bonus权重配置
        bonusWeights = {
            credits = 70,
            freeSpins = 20,
            jackpotBonus = 10
        },
        
        -- Bonus数值限制
        bonusConstraints = {
            avoidOnlyExtra = true,
            avoidFreeSpinsAndJackpot = true,
            avoidExtra3AndJackpot = true
        },
        
        -- Credits分值序列
        creditsValues = {0.2, 0.5, 1, 2, 3, 5, 10, 15, 20},
        
        -- Free Spins值
        freeSpinsValues = {5, 10},
        
        -- Extra权重配置
        extraWeights = {
            [1] = 60,  -- EXTRA
            [2] = 30,  -- EXTRA2
            [3] = 10   -- EXTRA3
        },
        
        -- Extra数值限制
        extraConstraints = {
            avoidExtra3AndJackpot = true,
            maxExtraLevel = 3,
            minExtraLevel = 1
        },
        
        -- Reveal配置
        revealDelay = 0.5,
        autoReveal = true,
        
        -- 回调函数
        onFeatureComplete = nil,
        onCreditsAwarded = nil,
        onFreeSpinsAwarded = nil,
        onJackpotBonusAwarded = nil
    }
end

-- 销毁
function SantasGiftsExtraMachine:OnDispose()
    if self.isActive then
        self:ForceEndFeature()
    end
    
    if self.controller then
        self.controller:OnDispose()
    end
    
    if self.data then
        self.data:Reset()
    end
    
    if self.view then
        self.view:OnDispose()
    end
    
    self.data = nil
    self.view = nil
    self.controller = nil
    self.bonusRevealLogic = nil
    self.extraFeatureLogic = nil
    self.isInitialized = false
    self.isActive = false
    
    Logger.Log("SantasGiftsExtra Machine disposed")
end

return SantasGiftsExtraMachine
