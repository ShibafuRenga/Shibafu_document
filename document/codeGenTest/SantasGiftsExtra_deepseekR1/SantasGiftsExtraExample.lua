-- SantasGiftsExtra 机器使用示例
-- 展示如何使用Santa's Gifts Feature

local SantasGiftsExtraExample = BaseClass("SantasGiftsExtraExample")

-- 初始化
function SantasGiftsExtraExample:__init()
    self.machine = nil
    self.isInitialized = false
end

-- 初始化示例
function SantasGiftsExtraExample:Initialize()
    if self.isInitialized then
        Logger.LogWarning("SantasGiftsExtra Example is already initialized")
        return
    end
    
    -- 创建机器实例
    self.machine = SantasGiftsExtraMachine.New()
    
    -- 设置配置
    local config = self:GetExampleConfig()
    self.machine:Initialize(config)
    
    self.isInitialized = true
    Logger.Log("SantasGiftsExtra Example initialized successfully")
end

-- 获取示例配置
function SantasGiftsExtraExample:GetExampleConfig()
    local defaultConfig = self.machine:GetDefaultConfig()
    return {
        -- 使用默认配置
        bonusWeights = defaultConfig.bonusWeights,
        bonusConstraints = defaultConfig.bonusConstraints,
        creditsValues = defaultConfig.creditsValues,
        freeSpinsValues = defaultConfig.freeSpinsValues,
        extraWeights = defaultConfig.extraWeights,
        extraConstraints = defaultConfig.extraConstraints,
        revealDelay = defaultConfig.revealDelay,
        autoReveal = defaultConfig.autoReveal,
        
        -- 自定义回调
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
    }
end

-- 示例1：触发只有B01图标的Feature
function SantasGiftsExtraExample:Example1_BonusIconsOnly()
    Logger.Log("=== 示例1：只有B01图标的Feature ===")
    
    local bonusIcons = {
        {
            position = Vector2(-100, 0),
            symbolData = {type = "B01", id = 1}
        },
        {
            position = Vector2(0, 0),
            symbolData = {type = "B01", id = 2}
        },
        {
            position = Vector2(100, 0),
            symbolData = {type = "B01", id = 3}
        }
    }
    
    local extraIcons = {}
    
    self:TriggerFeature(bonusIcons, extraIcons)
end

-- 示例2：触发B01和B02图标的Feature
function SantasGiftsExtraExample:Example2_BonusAndExtraIcons()
    Logger.Log("=== 示例2：B01和B02图标的Feature ===")
    
    local bonusIcons = {
        {
            position = Vector2(-100, 0),
            symbolData = {type = "B01", id = 1}
        },
        {
            position = Vector2(0, 0),
            symbolData = {type = "B01", id = 2}
        }
    }
    
    local extraIcons = {
        {
            position = Vector2(100, 0),
            symbolData = {type = "B02", id = 1}
        }
    }
    
    self:TriggerFeature(bonusIcons, extraIcons)
end

-- 示例3：触发多个B01和B02图标的Feature
function SantasGiftsExtraExample:Example3_MultipleIcons()
    Logger.Log("=== 示例3：多个B01和B02图标的Feature ===")
    
    local bonusIcons = {
        {
            position = Vector2(-150, 0),
            symbolData = {type = "B01", id = 1}
        },
        {
            position = Vector2(-50, 0),
            symbolData = {type = "B01", id = 2}
        },
        {
            position = Vector2(50, 0),
            symbolData = {type = "B01", id = 3}
        },
        {
            position = Vector2(150, 0),
            symbolData = {type = "B01", id = 4}
        }
    }
    
    local extraIcons = {
        {
            position = Vector2(-100, 100),
            symbolData = {type = "B02", id = 1}
        },
        {
            position = Vector2(100, 100),
            symbolData = {type = "B02", id = 2}
        }
    }
    
    self:TriggerFeature(bonusIcons, extraIcons)
end

-- 示例4：测试数值限制（只有B02图标，应该失败）
function SantasGiftsExtraExample:Example4_OnlyExtraIcons()
    Logger.Log("=== 示例4：只有B02图标的Feature（应该失败） ===")
    
    local bonusIcons = {}
    
    local extraIcons = {
        {
            position = Vector2(0, 0),
            symbolData = {type = "B02", id = 1}
        }
    }
    
    local success = self:TriggerFeature(bonusIcons, extraIcons)
    if not success then
        Logger.Log("测试通过：只有B02图标的Feature被正确拒绝")
    else
        Logger.LogError("测试失败：只有B02图标的Feature应该被拒绝")
    end
end

-- 触发Feature
function SantasGiftsExtraExample:TriggerFeature(bonusIcons, extraIcons)
    if not self.isInitialized or not self.machine then
        Logger.LogError("SantasGiftsExtra Example is not initialized")
        return false
    end
    
    if self.machine:IsActive() then
        Logger.LogWarning("Machine is already active, force ending current feature")
        self.machine:ForceEndFeature()
    end
    
    return self.machine:TriggerSantasGiftsFeature(bonusIcons, extraIcons)
end

-- 获取机器状态
function SantasGiftsExtraExample:GetMachineStatus()
    if not self.machine then
        return "Machine not initialized"
    end
    
    local stats = self.machine:GetMachineStatistics()
    return "Machine Status: " .. 
           "Active=" .. tostring(stats.isActive) .. 
           ", Phase=" .. stats.currentPhase .. 
           ", Revealing=" .. tostring(stats.isRevealing)
end

-- 重置机器
function SantasGiftsExtraExample:ResetMachine()
    if self.machine then
        self.machine:Reset()
        Logger.Log("Machine reset")
    end
end

-- Feature完成回调
function SantasGiftsExtraExample:OnFeatureComplete()
    Logger.Log("=== Feature完成 ===")
    Logger.Log("机器状态: " .. self:GetMachineStatus())
end

-- Credits奖励回调
function SantasGiftsExtraExample:OnCreditsAwarded(credits)
    Logger.Log("=== 获得Credits奖励 ===")
    Logger.Log("奖励金额: " .. credits)
end

-- Free Spins奖励回调
function SantasGiftsExtraExample:OnFreeSpinsAwarded(freeSpinsCount)
    Logger.Log("=== 获得Free Spins奖励 ===")
    Logger.Log("Free Spins次数: " .. freeSpinsCount)
end

-- Jackpot Bonus奖励回调
function SantasGiftsExtraExample:OnJackpotBonusAwarded(removeLevels)
    Logger.Log("=== 获得Jackpot Bonus奖励 ===")
    Logger.Log("Remove Levels: " .. removeLevels)
end

-- 运行所有示例
function SantasGiftsExtraExample:RunAllExamples()
    if not self.isInitialized then
        Logger.LogError("Please initialize first")
        return
    end
    
    Logger.Log("开始运行所有示例...")
    
    -- 运行示例1
    self:Example1_BonusIconsOnly()
    
    -- 等待Feature完成
    DoTween.DelayedCall(5.0, function()
        self:Example2_BonusAndExtraIcons()
    end)
    
    -- 等待Feature完成
    DoTween.DelayedCall(10.0, function()
        self:Example3_MultipleIcons()
    end)
    
    -- 等待Feature完成
    DoTween.DelayedCall(15.0, function()
        self:Example4_OnlyExtraIcons()
    end)
    
    Logger.Log("所有示例已启动")
end

-- 销毁
function SantasGiftsExtraExample:OnDispose()
    if self.machine then
        self.machine:OnDispose()
        self.machine = nil
    end
    
    self.isInitialized = false
    Logger.Log("SantasGiftsExtra Example disposed")
end

return SantasGiftsExtraExample
