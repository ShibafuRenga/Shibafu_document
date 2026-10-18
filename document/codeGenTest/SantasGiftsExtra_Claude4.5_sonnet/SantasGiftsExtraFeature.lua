local CSPanel = CS.BlowFire.SlotLib.Panel
local CSLuaMachineUtility = CS.LuaFramework.LuaMachineUtility
local CSGameType = CS.Blowfire.Network.Data.Machine.GameType
local CSGamePlayFacade = CS.Blowfire.Slot.UI.GamePlay.GamePlayFacade

local SantasGiftsExtraModel = safe_require("Machines.SantasGiftsExtra.SantasGiftsExtraModel")

local SantasGiftsExtraFeature = BaseClass("SantasGiftsExtraFeature")

function SantasGiftsExtraFeature:__init()
    self.model = SantasGiftsExtraModel.New()
end

--- Feature恢复处理
function SantasGiftsExtraFeature:Restore()
    safe_execute(
        function()
            -- 解析Feature数据
            self.model:ParseFeatureData()
            
            if self.model:HasFeature() then
                -- 恢复Feature状态
                self:RestoreFeatureState()
            end
        end,
        "SantasGiftsExtraFeature:Restore",
        function(error)
            Logger.LogError("Santa's Gifts Feature恢复失败: " .. tostring(error))
        end
    )
end

--- 恢复Feature状态
function SantasGiftsExtraFeature:RestoreFeatureState()
    local featureView = SlotsMachine.View.GetView("SantasGiftsExtraFeatureView")
    if IsNull(featureView) then return end
    
    local featureType = self.model:GetFeatureType()
    
    if featureType == "credits" then
        -- 恢复分值Feature状态
        featureView:RestoreCreditsState(self.model)
    elseif featureType == "freespins" then
        -- 恢复Free Spins Feature状态
        featureView:RestoreFreeSpinsState(self.model)
    elseif featureType == "jackpot" then
        -- 恢复Jackpot Feature状态
        featureView:RestoreJackpotState(self.model)
    end
end

--- 播放Feature
---@return AsyncTask
SantasGiftsExtraFeature.PlayFeature = async(function(self)
    -- 解析Feature数据
    self.model:ParseFeatureData()
    
    if not self.model:HasFeature() then
        return
    end
    
    local featureView = SlotsMachine.View.GetView("SantasGiftsExtraFeatureView")
    if IsNull(featureView) then
        Logger.LogError("SantasGiftsExtraFeatureView not found")
        return
    end
    
    -- 显示Feature界面
    await(featureView:Show())
    
    -- 按顺序Reveal B01符号
    await(self:RevealB01Symbols(featureView))
    
    -- 如果有B02，则Reveal B02并应用EXTRA效果
    if IsNotNull(self.model:GetB02Symbol()) then
        await(self:RevealB02Symbol(featureView))
        await(self:ApplyExtraEffects(featureView))
    end
    
    await(AsyncTask.Delay(0.5))
    
    -- 根据Feature类型执行相应逻辑
    local featureType = self.model:GetFeatureType()
    
    if featureType == "credits" then
        -- 显示并收集分值
        await(self:CollectCredits(featureView))
    elseif featureType == "freespins" then
        -- 触发Free Spins
        await(self:TriggerFreeSpins(featureView))
    elseif featureType == "jackpot" then
        -- 触发Jackpot Bonus
        await(self:TriggerJackpotBonus(featureView))
    end
    
    -- 隐藏Feature界面
    await(featureView:Hide())
end)

--- Reveal B01符号
---@param featureView table
---@return AsyncTask
SantasGiftsExtraFeature.RevealB01Symbols = async(function(self, featureView)
    local b01Symbols = self.model:GetB01Symbols()
    
    if IsNull(b01Symbols) or #b01Symbols == 0 then
        return
    end
    
    -- 逐个Reveal B01
    for i, b01Data in ipairs(b01Symbols) do
        safe_execute(
            function()
                await(featureView:RevealB01(b01Data, i))
                await(AsyncTask.Delay(0.3))
            end,
            "RevealB01Symbol",
            function(error)
                Logger.LogError("Reveal B01符号失败: " .. tostring(error))
            end
        )
    end
    
    await(AsyncTask.Delay(0.5))
end)

--- Reveal B02符号
---@param featureView table
---@return AsyncTask
SantasGiftsExtraFeature.RevealB02Symbol = async(function(self, featureView)
    local b02Symbol = self.model:GetB02Symbol()
    
    if IsNull(b02Symbol) then
        return
    end
    
    safe_execute(
        function()
            await(featureView:RevealB02(b02Symbol))
            await(AsyncTask.Delay(0.5))
        end,
        "RevealB02Symbol",
        function(error)
            Logger.LogError("Reveal B02符号失败: " .. tostring(error))
        end
    )
end)

--- 应用EXTRA效果
---@param featureView table
---@return AsyncTask
SantasGiftsExtraFeature.ApplyExtraEffects = async(function(self, featureView)
    local extraType = self.model:GetExtraType()
    
    if extraType == SantasGiftsExtraModel.ExtraType.None then
        return
    end
    
    local featureType = self.model:GetFeatureType()
    
    safe_execute(
        function()
            if featureType == "credits" then
                -- 播放分值倍增动画
                await(featureView:PlayCreditsMultiplyEffect(extraType))
            elseif featureType == "freespins" then
                -- 播放Free Spins增加动画
                await(featureView:PlayFreeSpinsAddEffect(extraType))
            elseif featureType == "jackpot" then
                -- 播放Jackpot Remove Level动画
                await(featureView:PlayJackpotRemoveLevelEffect(extraType))
            end
            
            await(AsyncTask.Delay(0.5))
        end,
        "ApplyExtraEffects",
        function(error)
            Logger.LogError("应用EXTRA效果失败: " .. tostring(error))
        end
    )
end)

--- 收集分值
---@param featureView table
---@return AsyncTask
SantasGiftsExtraFeature.CollectCredits = async(function(self, featureView)
    local totalCredits = self.model:GetTotalCredits()
    local currentBet = CSLuaMachineUtility.GetCurrentBetting()
    local totalWin = totalCredits * currentBet
    
    safe_execute(
        function()
            -- 播放收集分值动画
            await(featureView:PlayCollectCreditsAnimation(totalWin))
            
            await(AsyncTask.Delay(1))
            
            -- 更新玩家金币
            local win = CSLuaMachineUtility.GetLuaWinViewModel()
            if IsNotNull(win) then
                win:SetCoins(totalWin)
            end
            
            Logger.Log("Santa's Gifts Feature - Credits: " .. totalWin)
        end,
        "CollectCredits",
        function(error)
            Logger.LogError("收集分值失败: " .. tostring(error))
        end
    )
end)

--- 触发Free Spins
---@param featureView table
---@return AsyncTask
SantasGiftsExtraFeature.TriggerFreeSpins = async(function(self, featureView)
    local freeSpinsTimes = self.model:GetFreeSpinsTimes()
    
    if freeSpinsTimes <= 0 then
        return
    end
    
    safe_execute(
        function()
            -- 播放Free Spins触发动画
            await(featureView:PlayFreeSpinsTriggerAnimation(freeSpinsTimes))
            
            await(AsyncTask.Delay(1))
            
            Logger.Log("Santa's Gifts Feature - Free Spins: " .. freeSpinsTimes)
            
            -- Free Spins将由系统自动处理
        end,
        "TriggerFreeSpins",
        function(error)
            Logger.LogError("触发Free Spins失败: " .. tostring(error))
        end
    )
end)

--- 触发Jackpot Bonus
---@param featureView table
---@return AsyncTask
SantasGiftsExtraFeature.TriggerJackpotBonus = async(function(self, featureView)
    local removeLevel = self.model:GetJackpotRemoveLevel()
    
    safe_execute(
        function()
            -- 播放Jackpot触发动画
            await(featureView:PlayJackpotTriggerAnimation(removeLevel))
            
            await(AsyncTask.Delay(1))
            
            Logger.Log("Santa's Gifts Feature - Jackpot Bonus with " .. removeLevel .. " remove level(s)")
            
            -- Jackpot Bonus将由系统自动处理
        end,
        "TriggerJackpotBonus",
        function(error)
            Logger.LogError("触发Jackpot Bonus失败: " .. tostring(error))
        end
    )
end)

--- 获取Model
---@return SantasGiftsExtraModel
function SantasGiftsExtraFeature:GetModel()
    return self.model
end

return SantasGiftsExtraFeature
