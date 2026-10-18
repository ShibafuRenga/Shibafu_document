local CSGamePlayFacade = CS.Blowfire.Slot.UI.GamePlay.GamePlayFacade
local CSLuaMachineUtility = CS.LuaFramework.LuaMachineUtility

local SantasGiftsExtraModel = BaseClass("SantasGiftsExtraModel")

-- B01图标索引
SantasGiftsExtraModel.B01_SYMBOL = 1

-- B02图标索引
SantasGiftsExtraModel.B02_SYMBOL = 2

-- B01 Reveal类型
SantasGiftsExtraModel.RevealType = {
    Credits = 1,        -- 分值
    FreeSpins5 = 2,     -- 5次Free Spins
    FreeSpins10 = 3,    -- 10次Free Spins
    JackpotBonus = 4,   -- Jackpot Bonus
    JackpotBonusRemove1 = 5,  -- Jackpot Bonus with 1 Remove Level
    JackpotBonusRemove2 = 6,  -- Jackpot Bonus with 2 Remove Level
}

-- B02 EXTRA类型
SantasGiftsExtraModel.ExtraType = {
    None = 0,       -- 没有EXTRA
    Extra1 = 1,     -- 1个EXTRA
    Extra2 = 2,     -- 2个EXTRA
    Extra3 = 3,     -- 3个EXTRA
}

-- 分值序列
SantasGiftsExtraModel.CreditValues = {
    [1] = 0.2,
    [2] = 0.5,
    [3] = 1,
    [4] = 2,
    [5] = 3,
    [6] = 5,
    [7] = 10,
    [8] = 15,
    [9] = 20
}

function SantasGiftsExtraModel:__init()
    self:ClearFeatureData()
end

--- 清理Feature数据
function SantasGiftsExtraModel:ClearFeatureData()
    self.b01Symbols = {}  -- B01符号列表
    self.b02Symbol = nil  -- B02符号（只有一个）
    self.hasFeature = false
    self.featureType = nil  -- Feature类型：credits, freespins, jackpot
    self.totalCredits = 0   -- 总分值
    self.freeSpinsTimes = 0  -- Free Spins次数
    self.extraType = SantasGiftsExtraModel.ExtraType.None
    self.jackpotRemoveLevel = 0  -- Jackpot移除的level数量
end

--- 解析当前Feature数据
---@return void
function SantasGiftsExtraModel:ParseFeatureData()
    self:ClearFeatureData()
    
    local gamePlay = CSGamePlayFacade.SpinResultEnumerator:GetCurrentGame()
    if IsNull(gamePlay) then return end
    
    local reels = CSLuaMachineUtility.GetReelsViewModel()
    if IsNull(reels) then return end
    
    local symbols = reels.Symbols2
    local extras = reels.Extra
    
    if IsNull(symbols) or IsNull(extras) then return end
    
    local position = 0
    -- 遍历所有位置，找到B01和B02符号
    for col = 0, symbols.Count - 1 do
        for row = 0, symbols[col].Count - 1 do
            local symbolIndex = symbols[col][row]
            local extra = extras[position]
            
            if symbolIndex == SantasGiftsExtraModel.B01_SYMBOL then
                -- 解析B01的额外信息
                local b01Data = self:ParseB01Extra(extra, position, col, row)
                if IsNotNull(b01Data) then
                    table.insert(self.b01Symbols, b01Data)
                end
            elseif symbolIndex == SantasGiftsExtraModel.B02_SYMBOL then
                -- 解析B02的额外信息
                local b02Data = self:ParseB02Extra(extra, position, col, row)
                if IsNotNull(b02Data) then
                    self.b02Symbol = b02Data
                    self.extraType = b02Data.extraType
                end
            end
            
            position = position + 1
        end
    end
    
    -- 检查是否触发Feature
    if #self.b01Symbols > 0 then
        self.hasFeature = true
        self:CalculateFeatureResult()
    end
end

--- 解析B01额外信息
---@param extra string 额外信息字符串
---@param position number 位置索引
---@param col number 列索引
---@param row number 行索引
---@return table|nil
function SantasGiftsExtraModel:ParseB01Extra(extra, position, col, row)
    if IsNullOrEmpty(extra) then return nil end
    
    -- Extra格式示例: "type:value"
    -- type: 1=credits, 2=freespins5, 3=freespins10, 4=jackpot
    -- value: 对于credits是分值索引(1-9)，对于其他是0
    local parts = LuaUtil.StringSplit(extra, ":")
    if IsNull(parts) or #parts < 2 then return nil end
    
    local revealType = tonumber(parts[1])
    local value = tonumber(parts[2])
    
    local b01Data = {
        position = position,
        col = col,
        row = row,
        revealType = revealType,
        value = value,
        credits = 0,
        freeSpins = 0,
        isJackpot = false
    }
    
    -- 根据类型设置具体数值
    if revealType == SantasGiftsExtraModel.RevealType.Credits then
        b01Data.credits = SantasGiftsExtraModel.CreditValues[value] or 0
    elseif revealType == SantasGiftsExtraModel.RevealType.FreeSpins5 then
        b01Data.freeSpins = 5
    elseif revealType == SantasGiftsExtraModel.RevealType.FreeSpins10 then
        b01Data.freeSpins = 10
    elseif revealType == SantasGiftsExtraModel.RevealType.JackpotBonus then
        b01Data.isJackpot = true
    elseif revealType == SantasGiftsExtraModel.RevealType.JackpotBonusRemove1 then
        b01Data.isJackpot = true
        b01Data.removeLevel = 1
    elseif revealType == SantasGiftsExtraModel.RevealType.JackpotBonusRemove2 then
        b01Data.isJackpot = true
        b01Data.removeLevel = 2
    end
    
    return b01Data
end

--- 解析B02额外信息
---@param extra string 额外信息字符串
---@param position number 位置索引
---@param col number 列索引
---@param row number 行索引
---@return table|nil
function SantasGiftsExtraModel:ParseB02Extra(extra, position, col, row)
    if IsNullOrEmpty(extra) then return nil end
    
    -- Extra格式示例: "extraType"
    -- extraType: 1=EXTRA, 2=EXTRA2, 3=EXTRA3
    local extraType = tonumber(extra) or 0
    
    return {
        position = position,
        col = col,
        row = row,
        extraType = extraType
    }
end

--- 计算Feature最终结果（应用EXTRA加成）
function SantasGiftsExtraModel:CalculateFeatureResult()
    if #self.b01Symbols == 0 then return end
    
    -- 首先确定Feature类型（credits/freespins/jackpot）
    local hasCredits = false
    local hasFreeSpins = false
    local hasJackpot = false
    
    for _, b01 in ipairs(self.b01Symbols) do
        if b01.credits > 0 then
            hasCredits = true
        end
        if b01.freeSpins > 0 then
            hasFreeSpins = true
        end
        if b01.isJackpot then
            hasJackpot = true
        end
    end
    
    -- 应用EXTRA效果
    if hasCredits then
        self.featureType = "credits"
        self:ApplyCreditsExtra()
    elseif hasFreeSpins then
        self.featureType = "freespins"
        self:ApplyFreeSpinsExtra()
    elseif hasJackpot then
        self.featureType = "jackpot"
        self:ApplyJackpotExtra()
    end
end

--- 应用Credits的EXTRA加成
function SantasGiftsExtraModel:ApplyCreditsExtra()
    local multiplier = 1
    
    if self.extraType == SantasGiftsExtraModel.ExtraType.Extra1 then
        multiplier = 2
    elseif self.extraType == SantasGiftsExtraModel.ExtraType.Extra2 then
        multiplier = 3
    elseif self.extraType == SantasGiftsExtraModel.ExtraType.Extra3 then
        multiplier = 4
    end
    
    -- 计算总分值
    for _, b01 in ipairs(self.b01Symbols) do
        if b01.credits > 0 then
            b01.finalCredits = b01.credits * multiplier
            self.totalCredits = self.totalCredits + b01.finalCredits
        end
    end
end

--- 应用Free Spins的EXTRA加成
function SantasGiftsExtraModel:ApplyFreeSpinsExtra()
    local extraTimes = 0
    
    if self.extraType == SantasGiftsExtraModel.ExtraType.Extra1 then
        extraTimes = 5
    elseif self.extraType == SantasGiftsExtraModel.ExtraType.Extra2 then
        extraTimes = 10
    elseif self.extraType == SantasGiftsExtraModel.ExtraType.Extra3 then
        extraTimes = 15
    end
    
    -- 计算总Free Spins次数
    for _, b01 in ipairs(self.b01Symbols) do
        if b01.freeSpins > 0 then
            self.freeSpinsTimes = self.freeSpinsTimes + b01.freeSpins
        end
    end
    
    self.freeSpinsTimes = self.freeSpinsTimes + extraTimes
end

--- 应用Jackpot的EXTRA加成
function SantasGiftsExtraModel:ApplyJackpotExtra()
    local removeLevel = 0
    
    if self.extraType == SantasGiftsExtraModel.ExtraType.Extra1 then
        removeLevel = 1
    elseif self.extraType == SantasGiftsExtraModel.ExtraType.Extra2 then
        removeLevel = 2
    end
    
    -- 累加remove level（包括B01自带的）
    for _, b01 in ipairs(self.b01Symbols) do
        if b01.isJackpot and b01.removeLevel then
            removeLevel = removeLevel + b01.removeLevel
        end
    end
    
    self.jackpotRemoveLevel = removeLevel
end

--- 获取Feature类型
---@return string|nil
function SantasGiftsExtraModel:GetFeatureType()
    return self.featureType
end

--- 获取总分值
---@return number
function SantasGiftsExtraModel:GetTotalCredits()
    return self.totalCredits
end

--- 获取Free Spins次数
---@return number
function SantasGiftsExtraModel:GetFreeSpinsTimes()
    return self.freeSpinsTimes
end

--- 获取Jackpot Remove Level数量
---@return number
function SantasGiftsExtraModel:GetJackpotRemoveLevel()
    return self.jackpotRemoveLevel
end

--- 获取B01符号列表
---@return table
function SantasGiftsExtraModel:GetB01Symbols()
    return self.b01Symbols
end

--- 获取B02符号
---@return table|nil
function SantasGiftsExtraModel:GetB02Symbol()
    return self.b02Symbol
end

--- 是否有Feature
---@return boolean
function SantasGiftsExtraModel:HasFeature()
    return self.hasFeature
end

--- 获取EXTRA类型
---@return number
function SantasGiftsExtraModel:GetExtraType()
    return self.extraType
end

return SantasGiftsExtraModel
