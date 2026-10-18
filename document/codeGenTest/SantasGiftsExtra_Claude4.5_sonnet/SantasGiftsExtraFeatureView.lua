local CSAudioEntity = CS.LuaFramework.LuaAudioEntity
local CSUtilities = CS.Utils.Utilities
local CSBaseSlotMachineController = CS.BaseSlotMachineController

local SantasGiftsExtraModel = safe_require("Machines.SantasGiftsExtra.SantasGiftsExtraModel")

local SantasGiftsExtraFeatureView = BaseClass("SantasGiftsExtraFeatureView")

function SantasGiftsExtraFeatureView:InitMono(monoBehaviour)
    self.transform = monoBehaviour.transform
    self.gameObject = monoBehaviour.gameObject
    
    -- 注册视图
    SlotsMachine.View.AddViewByName("SantasGiftsExtraFeatureView", self)
    
    -- 初始化UI组件引用
    self:InitComponents()
    
    -- 隐藏Feature界面
    self.gameObject:SetActive(false)
end

--- 初始化UI组件
function SantasGiftsExtraFeatureView:InitComponents()
    -- 这里需要根据实际的UI结构来获取组件
    -- 示例代码，实际需要根据Unity预制体结构调整
    
    -- Feature容器
    self.featureContainer = LuaUtil.FindComponent(self.transform, "FeatureContainer")
    
    -- B01符号显示区域
    self.b01Container = LuaUtil.FindComponent(self.transform, "B01Container")
    
    -- B02符号显示区域
    self.b02Container = LuaUtil.FindComponent(self.transform, "B02Container")
    
    -- 结果显示文本
    self.resultText = LuaUtil.FindComponent(self.transform, "ResultText", typeof(CS.TMPro.TextMeshProUGUI))
    
    -- 背景动画
    self.bgAnimator = LuaUtil.FindComponent(self.transform, "Background", typeof(CS.UnityEngine.Animator))
end

--- 显示Feature界面
---@return AsyncTask
SantasGiftsExtraFeatureView.Show = async(function(self)
    if IsNull(self.gameObject) then return end
    
    safe_execute(
        function()
            self.gameObject:SetActive(true)
            
            -- 播放进入动画
            if IsNotNull(self.bgAnimator) then
                self.bgAnimator:Play("feature_enter")
            end
            
            -- 播放音效
            CSAudioEntity.AsyncPlayEffectAudio("santa_gifts_enter", false, 1)
            
            await(AsyncTask.Delay(1))
        end,
        "SantasGiftsExtraFeatureView:Show",
        function(error)
            Logger.LogError("显示Santa's Gifts Feature界面失败: " .. tostring(error))
        end
    )
end)

--- 隐藏Feature界面
---@return AsyncTask
SantasGiftsExtraFeatureView.Hide = async(function(self)
    if IsNull(self.gameObject) then return end
    
    safe_execute(
        function()
            -- 播放退出动画
            if IsNotNull(self.bgAnimator) then
                self.bgAnimator:Play("feature_exit")
            end
            
            await(AsyncTask.Delay(0.5))
            
            self.gameObject:SetActive(false)
        end,
        "SantasGiftsExtraFeatureView:Hide",
        function(error)
            Logger.LogError("隐藏Santa's Gifts Feature界面失败: " .. tostring(error))
        end
    )
end)

--- Reveal B01符号
---@param b01Data table B01数据
---@param index number 索引
---@return AsyncTask
SantasGiftsExtraFeatureView.RevealB01 = async(function(self, b01Data, index)
    safe_execute(
        function()
            -- 播放Reveal动画
            local animator = self:GetB01Animator(index)
            if IsNotNull(animator) then
                animator:Play("gift_reveal")
            end
            
            -- 播放音效
            CSAudioEntity.AsyncPlayEffectAudio("gift_reveal", false, 1)
            
            await(AsyncTask.Delay(0.8))
            
            -- 显示Reveal结果
            self:ShowB01Result(b01Data, index)
            
            await(AsyncTask.Delay(0.5))
        end,
        "RevealB01",
        function(error)
            Logger.LogError("Reveal B01符号失败: " .. tostring(error))
        end
    )
end)

--- 显示B01结果
---@param b01Data table
---@param index number
function SantasGiftsExtraFeatureView:ShowB01Result(b01Data, index)
    if IsNull(b01Data) then return end
    
    local resultObj = self:GetB01ResultObject(index)
    if IsNull(resultObj) then return end
    
    local resultText = LuaUtil.FindComponent(resultObj.transform, "Text", typeof(CS.TMPro.TextMeshProUGUI))
    if IsNull(resultText) then return end
    
    -- 根据类型显示不同的文本
    if b01Data.revealType == SantasGiftsExtraModel.RevealType.Credits then
        local currentBet = CSBaseSlotMachineController.Instance.currentBetting
        local coins = b01Data.credits * currentBet
        resultText.text = CSUtilities.GetAbbreviationNumShow(coins)
    elseif b01Data.revealType == SantasGiftsExtraModel.RevealType.FreeSpins5 then
        resultText.text = "5 FREE SPINS"
    elseif b01Data.revealType == SantasGiftsExtraModel.RevealType.FreeSpins10 then
        resultText.text = "10 FREE SPINS"
    elseif b01Data.revealType == SantasGiftsExtraModel.RevealType.JackpotBonus or 
           b01Data.revealType == SantasGiftsExtraModel.RevealType.JackpotBonusRemove1 or
           b01Data.revealType == SantasGiftsExtraModel.RevealType.JackpotBonusRemove2 then
        resultText.text = "JACKPOT BONUS"
    end
    
    resultObj:SetActive(true)
end

--- Reveal B02符号
---@param b02Data table B02数据
---@return AsyncTask
SantasGiftsExtraFeatureView.RevealB02 = async(function(self, b02Data)
    safe_execute(
        function()
            if IsNull(b02Data) then return end
            
            -- 播放Reveal动画
            if IsNotNull(self.b02Container) then
                local animator = LuaUtil.FindComponent(self.b02Container.transform, "Animator", typeof(CS.UnityEngine.Animator))
                if IsNotNull(animator) then
                    animator:Play("extra_reveal")
                end
            end
            
            -- 播放音效
            CSAudioEntity.AsyncPlayEffectAudio("extra_reveal", false, 1)
            
            await(AsyncTask.Delay(1))
            
            -- 显示EXTRA类型
            self:ShowB02Result(b02Data)
        end,
        "RevealB02",
        function(error)
            Logger.LogError("Reveal B02符号失败: " .. tostring(error))
        end
    )
end)

--- 显示B02结果
---@param b02Data table
function SantasGiftsExtraFeatureView:ShowB02Result(b02Data)
    if IsNull(b02Data) or IsNull(self.b02Container) then return end
    
    local resultText = LuaUtil.FindComponent(self.b02Container.transform, "ResultText", typeof(CS.TMPro.TextMeshProUGUI))
    if IsNull(resultText) then return end
    
    if b02Data.extraType == SantasGiftsExtraModel.ExtraType.Extra1 then
        resultText.text = "EXTRA"
    elseif b02Data.extraType == SantasGiftsExtraModel.ExtraType.Extra2 then
        resultText.text = "EXTRA2"
    elseif b02Data.extraType == SantasGiftsExtraModel.ExtraType.Extra3 then
        resultText.text = "EXTRA3"
    end
end

--- 播放分值倍增效果
---@param extraType number
---@return AsyncTask
SantasGiftsExtraFeatureView.PlayCreditsMultiplyEffect = async(function(self, extraType)
    safe_execute(
        function()
            local multiplier = 1
            
            if extraType == SantasGiftsExtraModel.ExtraType.Extra1 then
                multiplier = 2
            elseif extraType == SantasGiftsExtraModel.ExtraType.Extra2 then
                multiplier = 3
            elseif extraType == SantasGiftsExtraModel.ExtraType.Extra3 then
                multiplier = 4
            end
            
            -- 播放倍增动画和音效
            CSAudioEntity.AsyncPlayEffectAudio("credits_multiply", false, 1)
            
            -- 显示倍数文本
            if IsNotNull(self.resultText) then
                self.resultText.text = "x" .. multiplier
            end
            
            await(AsyncTask.Delay(1.5))
        end,
        "PlayCreditsMultiplyEffect",
        function(error)
            Logger.LogError("播放分值倍增效果失败: " .. tostring(error))
        end
    )
end)

--- 播放Free Spins增加效果
---@param extraType number
---@return AsyncTask
SantasGiftsExtraFeatureView.PlayFreeSpinsAddEffect = async(function(self, extraType)
    safe_execute(
        function()
            local extraTimes = 0
            
            if extraType == SantasGiftsExtraModel.ExtraType.Extra1 then
                extraTimes = 5
            elseif extraType == SantasGiftsExtraModel.ExtraType.Extra2 then
                extraTimes = 10
            elseif extraType == SantasGiftsExtraModel.ExtraType.Extra3 then
                extraTimes = 15
            end
            
            -- 播放增加动画和音效
            CSAudioEntity.AsyncPlayEffectAudio("freespins_add", false, 1)
            
            -- 显示增加的次数
            if IsNotNull(self.resultText) then
                self.resultText.text = "+" .. extraTimes .. " FREE SPINS"
            end
            
            await(AsyncTask.Delay(1.5))
        end,
        "PlayFreeSpinsAddEffect",
        function(error)
            Logger.LogError("播放Free Spins增加效果失败: " .. tostring(error))
        end
    )
end)

--- 播放Jackpot Remove Level效果
---@param extraType number
---@return AsyncTask
SantasGiftsExtraFeatureView.PlayJackpotRemoveLevelEffect = async(function(self, extraType)
    safe_execute(
        function()
            local removeLevel = 0
            
            if extraType == SantasGiftsExtraModel.ExtraType.Extra1 then
                removeLevel = 1
            elseif extraType == SantasGiftsExtraModel.ExtraType.Extra2 then
                removeLevel = 2
            end
            
            -- 播放Remove Level动画和音效
            CSAudioEntity.AsyncPlayEffectAudio("jackpot_remove_level", false, 1)
            
            -- 显示Remove Level信息
            if IsNotNull(self.resultText) then
                self.resultText.text = "+" .. removeLevel .. " REMOVE LEVEL"
            end
            
            await(AsyncTask.Delay(1.5))
        end,
        "PlayJackpotRemoveLevelEffect",
        function(error)
            Logger.LogError("播放Jackpot Remove Level效果失败: " .. tostring(error))
        end
    )
end)

--- 播放收集分值动画
---@param totalWin number
---@return AsyncTask
SantasGiftsExtraFeatureView.PlayCollectCreditsAnimation = async(function(self, totalWin)
    safe_execute(
        function()
            -- 播放收集动画和音效
            CSAudioEntity.AsyncPlayEffectAudio("credits_collect", false, 1)
            
            -- 显示总奖金
            if IsNotNull(self.resultText) then
                self.resultText.text = "WIN: " .. CSUtilities.GetAbbreviationNumShow(totalWin)
            end
            
            await(AsyncTask.Delay(2))
        end,
        "PlayCollectCreditsAnimation",
        function(error)
            Logger.LogError("播放收集分值动画失败: " .. tostring(error))
        end
    )
end)

--- 播放Free Spins触发动画
---@param freeSpinsTimes number
---@return AsyncTask
SantasGiftsExtraFeatureView.PlayFreeSpinsTriggerAnimation = async(function(self, freeSpinsTimes)
    safe_execute(
        function()
            -- 播放触发动画和音效
            CSAudioEntity.AsyncPlayEffectAudio("freespins_trigger", false, 1)
            
            -- 显示Free Spins次数
            if IsNotNull(self.resultText) then
                self.resultText.text = freeSpinsTimes .. " FREE SPINS"
            end
            
            await(AsyncTask.Delay(2))
        end,
        "PlayFreeSpinsTriggerAnimation",
        function(error)
            Logger.LogError("播放Free Spins触发动画失败: " .. tostring(error))
        end
    )
end)

--- 播放Jackpot触发动画
---@param removeLevel number
---@return AsyncTask
SantasGiftsExtraFeatureView.PlayJackpotTriggerAnimation = async(function(self, removeLevel)
    safe_execute(
        function()
            -- 播放触发动画和音效
            CSAudioEntity.AsyncPlayEffectAudio("jackpot_trigger", false, 1)
            
            -- 显示Jackpot信息
            if IsNotNull(self.resultText) then
                local text = "JACKPOT BONUS"
                if removeLevel > 0 then
                    text = text .. "\n+" .. removeLevel .. " REMOVE LEVEL"
                end
                self.resultText.text = text
            end
            
            await(AsyncTask.Delay(2))
        end,
        "PlayJackpotTriggerAnimation",
        function(error)
            Logger.LogError("播放Jackpot触发动画失败: " .. tostring(error))
        end
    )
end)

--- 恢复Credits状态
---@param model SantasGiftsExtraModel
function SantasGiftsExtraFeatureView:RestoreCreditsState(model)
    safe_execute(
        function()
            if IsNull(model) then return end
            
            -- 显示所有已reveal的B01
            local b01Symbols = model:GetB01Symbols()
            for i, b01Data in ipairs(b01Symbols) do
                self:ShowB01Result(b01Data, i)
            end
            
            -- 如果有B02，显示B02结果
            local b02Symbol = model:GetB02Symbol()
            if IsNotNull(b02Symbol) then
                self:ShowB02Result(b02Symbol)
            end
        end,
        "RestoreCreditsState",
        function(error)
            Logger.LogError("恢复Credits状态失败: " .. tostring(error))
        end
    )
end

--- 恢复Free Spins状态
---@param model SantasGiftsExtraModel
function SantasGiftsExtraFeatureView:RestoreFreeSpinsState(model)
    safe_execute(
        function()
            if IsNull(model) then return end
            
            -- 显示所有已reveal的B01
            local b01Symbols = model:GetB01Symbols()
            for i, b01Data in ipairs(b01Symbols) do
                self:ShowB01Result(b01Data, i)
            end
            
            -- 如果有B02，显示B02结果
            local b02Symbol = model:GetB02Symbol()
            if IsNotNull(b02Symbol) then
                self:ShowB02Result(b02Symbol)
            end
        end,
        "RestoreFreeSpinsState",
        function(error)
            Logger.LogError("恢复Free Spins状态失败: " .. tostring(error))
        end
    )
end

--- 恢复Jackpot状态
---@param model SantasGiftsExtraModel
function SantasGiftsExtraFeatureView:RestoreJackpotState(model)
    safe_execute(
        function()
            if IsNull(model) then return end
            
            -- 显示所有已reveal的B01
            local b01Symbols = model:GetB01Symbols()
            for i, b01Data in ipairs(b01Symbols) do
                self:ShowB01Result(b01Data, i)
            end
            
            -- 如果有B02，显示B02结果
            local b02Symbol = model:GetB02Symbol()
            if IsNotNull(b02Symbol) then
                self:ShowB02Result(b02Symbol)
            end
        end,
        "RestoreJackpotState",
        function(error)
            Logger.LogError("恢复Jackpot状态失败: " .. tostring(error))
        end
    )
end

--- 获取B01动画组件
---@param index number
---@return UnityEngine.Animator|nil
function SantasGiftsExtraFeatureView:GetB01Animator(index)
    if IsNull(self.b01Container) then return nil end
    
    local b01Obj = self:GetB01Object(index)
    if IsNull(b01Obj) then return nil end
    
    return LuaUtil.FindComponent(b01Obj.transform, "Animator", typeof(CS.UnityEngine.Animator))
end

--- 获取B01对象
---@param index number
---@return UnityEngine.GameObject|nil
function SantasGiftsExtraFeatureView:GetB01Object(index)
    if IsNull(self.b01Container) then return nil end
    
    local b01Name = "B01_" .. index
    return LuaUtil.Find(self.b01Container.transform, b01Name)
end

--- 获取B01结果显示对象
---@param index number
---@return UnityEngine.GameObject|nil
function SantasGiftsExtraFeatureView:GetB01ResultObject(index)
    local b01Obj = self:GetB01Object(index)
    if IsNull(b01Obj) then return nil end
    
    return LuaUtil.Find(b01Obj.transform, "Result")
end

--- 销毁时清理
function SantasGiftsExtraFeatureView:OnDestroy()
    -- 清理资源
    SlotsMachine.View.RemoveViewByName("SantasGiftsExtraFeatureView")
end

return SantasGiftsExtraFeatureView
