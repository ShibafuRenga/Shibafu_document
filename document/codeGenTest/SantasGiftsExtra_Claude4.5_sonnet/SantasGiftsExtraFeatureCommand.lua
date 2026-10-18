--- Santa's Gifts Feature Command
--- 用于在游戏流程中触发和播放Santa's Gifts Feature
local SantasGiftsExtraFeatureCommand = BaseClass("SantasGiftsExtraFeatureCommand", SlotsMachine.Command)

SantasGiftsExtraFeatureCommand.Do = async(function(self)
    safe_execute(
        function()
            -- 获取Feature控制器
            local feature = SlotsMachine.View.GetView("SantasGiftsExtraFeature")
            
            if IsNull(feature) then
                Logger.LogWarning("SantasGiftsExtraFeature not found")
                return
            end
            
            -- 检查是否有Feature数据
            local model = feature:GetModel()
            if IsNull(model) then
                Logger.LogWarning("SantasGiftsExtraModel not found")
                return
            end
            
            -- 解析Feature数据
            model:ParseFeatureData()
            
            -- 如果没有Feature，直接返回
            if not model:HasFeature() then
                return
            end
            
            Logger.Log("Santa's Gifts Feature triggered")
            
            -- 播放Feature
            await(feature:PlayFeature())
            
            Logger.Log("Santa's Gifts Feature completed")
        end,
        "SantasGiftsExtraFeatureCommand:Do",
        function(error)
            Logger.LogError("Santa's Gifts Feature Command执行失败: " .. tostring(error))
        end
    )
end)

return SantasGiftsExtraFeatureCommand
