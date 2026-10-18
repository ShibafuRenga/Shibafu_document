-- Santa's Gifts Feature 视图层
-- 负责UI展示和用户交互，不包含业务逻辑

local SantasGiftsFeatureView = BaseClass("SantasGiftsFeatureView")

-- 初始化
function SantasGiftsFeatureView:__init()
    -- UI组件引用
    self.featurePanel = nil
    self.bonusIcons = {}
    self.extraIcons = {}
    self.revealAnimations = {}
    
    -- 布局属性
    self.iconSpacing = 100
    self.iconSize = 80
    self.panelPadding = 20
    
    -- 动画属性
    self.revealDuration = 1.0
    self.revealDelay = 0.2
    self.particleEffectDuration = 2.0
    
    -- 状态
    self.isRevealing = false
    self.currentRevealIndex = 0
end

-- 初始化UI
function SantasGiftsFeatureView:Initialize(featurePanel)
    self.featurePanel = featurePanel
    self:SetupUI()
end

-- 设置UI布局
function SantasGiftsFeatureView:SetupUI()
    if IsNull(self.featurePanel) then
        Logger.LogError("Santa's Gifts Feature Panel is null")
        return
    end
    
    -- 设置面板位置和大小
    local rectTransform = self.featurePanel:GetComponent("RectTransform")
    if not IsNull(rectTransform) then
        rectTransform.anchoredPosition = Vector2.zero
        rectTransform.sizeDelta = Vector2(800, 600)
    end
    
    -- 初始化图标容器
    self:InitializeIconContainers()
end

-- 初始化图标容器
function SantasGiftsFeatureView:InitializeIconContainers()
    -- 创建B01图标容器
    local bonusContainer = self:CreateIconContainer("BonusContainer", Vector2(0, 100))
    self.bonusContainer = bonusContainer
    
    -- 创建B02图标容器
    local extraContainer = self:CreateIconContainer("ExtraContainer", Vector2(0, -100))
    self.extraContainer = extraContainer
end

-- 创建图标容器
function SantasGiftsFeatureView:CreateIconContainer(name, position)
    local container = CSLuaUtil.InstantiateGameObject(self:GetContainerPrefab(), self.featurePanel.transform)
    container.name = name
    
    local rectTransform = container:GetComponent("RectTransform")
    if not IsNull(rectTransform) then
        rectTransform.anchoredPosition = position
        rectTransform.sizeDelta = Vector2(600, 100)
    end
    
    return container
end

-- 获取容器预制体
function SantasGiftsFeatureView:GetContainerPrefab()
    -- 这里应该从资源管理器获取容器预制体
    -- 暂时返回一个简单的GameObject
    return CS.UnityEngine.GameObject("Container")
end

-- 显示Feature
function SantasGiftsFeatureView:ShowFeature(bonusIcons, extraIcons)
    self:ClearIcons()
    self:CreateBonusIcons(bonusIcons)
    self:CreateExtraIcons(extraIcons)
    self:PlayShowAnimation()
end

-- 创建B01图标
function SantasGiftsFeatureView:CreateBonusIcons(bonusIcons)
    for i, bonusIcon in ipairs(bonusIcons) do
        local iconObj = self:CreateIcon("BonusIcon_" .. i, bonusIcon.position, "B01")
        table.insert(self.bonusIcons, iconObj)
    end
end

-- 创建B02图标
function SantasGiftsFeatureView:CreateExtraIcons(extraIcons)
    for i, extraIcon in ipairs(extraIcons) do
        local iconObj = self:CreateIcon("ExtraIcon_" .. i, extraIcon.position, "B02")
        table.insert(self.extraIcons, iconObj)
    end
end

-- 创建单个图标
function SantasGiftsFeatureView:CreateIcon(name, position, symbolType)
    local iconObj = CSLuaUtil.InstantiateGameObject(self:GetIconPrefab(symbolType), self.featurePanel.transform)
    iconObj.name = name
    
    local rectTransform = iconObj:GetComponent("RectTransform")
    if not IsNull(rectTransform) then
        rectTransform.anchoredPosition = position
        rectTransform.sizeDelta = Vector2(self.iconSize, self.iconSize)
    end
    
    return iconObj
end

-- 获取图标预制体
function SantasGiftsFeatureView:GetIconPrefab(symbolType)
    -- 这里应该从资源管理器获取对应类型的图标预制体
    -- 暂时返回一个简单的GameObject
    return CS.UnityEngine.GameObject("Icon_" .. symbolType)
end

-- 播放显示动画
function SantasGiftsFeatureView:PlayShowAnimation()
    self:PlayPanelShowAnimation()
    self:PlayIconsShowAnimation()
end

-- 播放面板显示动画
function SantasGiftsFeatureView:PlayPanelShowAnimation()
    if IsNull(self.featurePanel) then
        return
    end
    
    -- 使用DOTween播放缩放动画
    local scale = self.featurePanel.transform.localScale
    self.featurePanel.transform.localScale = Vector3.zero
    
    DoTween.DOScale(self.featurePanel.transform, scale, 0.5)
        :SetEase(DoTween.Ease.OutBack)
end

-- 播放图标显示动画
function SantasGiftsFeatureView:PlayIconsShowAnimation()
    local allIcons = {}
    for _, icon in ipairs(self.bonusIcons) do
        table.insert(allIcons, icon)
    end
    for _, icon in ipairs(self.extraIcons) do
        table.insert(allIcons, icon)
    end
    
    for i, icon in ipairs(allIcons) do
        self:PlayIconShowAnimation(icon, i * self.revealDelay)
    end
end

-- 播放单个图标显示动画
function SantasGiftsFeatureView:PlayIconShowAnimation(icon, delay)
    if IsNull(icon) then
        return
    end
    
    local scale = icon.transform.localScale
    icon.transform.localScale = Vector3.zero
    
    DoTween.DOScale(icon.transform, scale, 0.3)
        :SetDelay(delay)
        :SetEase(DoTween.Ease.OutBounce)
end

-- 开始Reveal过程
function SantasGiftsFeatureView:StartRevealProcess()
    self.isRevealing = true
    self.currentRevealIndex = 0
    self:PlayRevealStartAnimation()
end

-- 播放Reveal开始动画
function SantasGiftsFeatureView:PlayRevealStartAnimation()
    -- 播放所有图标的等待动画
    for _, icon in ipairs(self.bonusIcons) do
        self:PlayIconWaitingAnimation(icon)
    end
    for _, icon in ipairs(self.extraIcons) do
        self:PlayIconWaitingAnimation(icon)
    end
end

-- 播放图标等待动画
function SantasGiftsFeatureView:PlayIconWaitingAnimation(icon)
    if IsNull(icon) then
        return
    end
    
    -- 播放呼吸灯效果
    DoTween.DOScale(icon.transform, Vector3(1.1, 1.1, 1.1), 0.5)
        :SetLoops(-1, DoTween.LoopType.Yoyo)
        :SetEase(DoTween.Ease.InOutSine)
end

-- Reveal单个图标
function SantasGiftsFeatureView:RevealIcon(iconType, index, revealType, revealValue)
    local icon = nil
    if iconType == "bonus" and index <= #self.bonusIcons then
        icon = self.bonusIcons[index]
    elseif iconType == "extra" and index <= #self.extraIcons then
        icon = self.extraIcons[index]
    end
    
    if IsNull(icon) then
        Logger.LogError("Icon not found for reveal: " .. iconType .. "_" .. index)
        return
    end
    
    self:PlayIconRevealAnimation(icon, revealType, revealValue)
end

-- 播放图标Reveal动画
function SantasGiftsFeatureView:PlayIconRevealAnimation(icon, revealType, revealValue)
    if IsNull(icon) then
        return
    end
    
    -- 停止等待动画
    DoTween.Kill(icon.transform)
    
    -- 播放Reveal动画
    DoTween.Sequence()
        :Append(DoTween.DOScale(icon.transform, Vector3(1.2, 1.2, 1.2), 0.2))
        :AppendCallback(function()
            self:UpdateIconAppearance(icon, revealType, revealValue)
        end)
        :Append(DoTween.DOScale(icon.transform, Vector3(1.0, 1.0, 1.0), 0.2))
        :AppendCallback(function()
            self:PlayRevealEffect(icon, revealType, revealValue)
        end)
end

-- 更新图标外观
function SantasGiftsFeatureView:UpdateIconAppearance(icon, revealType, revealValue)
    if IsNull(icon) then
        return
    end
    
    -- 根据reveal类型更新图标外观
    if revealType == "credits" then
        self:SetIconCreditsAppearance(icon, revealValue)
    elseif revealType == "freeSpins" then
        self:SetIconFreeSpinsAppearance(icon, revealValue)
    elseif revealType == "jackpotBonus" then
        self:SetIconJackpotAppearance(icon)
    elseif revealType == "extra" then
        self:SetIconExtraAppearance(icon, revealValue)
    end
end

-- 设置Credits图标外观
function SantasGiftsFeatureView:SetIconCreditsAppearance(icon, value)
    -- 更新图标为Credits样式
    -- 显示数值
    local textComponent = LuaUtil.FindComponent(icon.transform, "Text")
    if not IsNull(textComponent) then
        textComponent.text = tostring(value)
    end
end

-- 设置Free Spins图标外观
function SantasGiftsFeatureView:SetIconFreeSpinsAppearance(icon, count)
    -- 更新图标为Free Spins样式
    -- 显示次数
    local textComponent = LuaUtil.FindComponent(icon.transform, "Text")
    if not IsNull(textComponent) then
        textComponent.text = tostring(count) .. " FREE SPINS"
    end
end

-- 设置Jackpot图标外观
function SantasGiftsFeatureView:SetIconJackpotAppearance(icon)
    -- 更新图标为Jackpot样式
    local textComponent = LuaUtil.FindComponent(icon.transform, "Text")
    if not IsNull(textComponent) then
        textComponent.text = "JACKPOT BONUS"
    end
end

-- 设置Extra图标外观
function SantasGiftsFeatureView:SetIconExtraAppearance(icon, level)
    -- 更新图标为Extra样式
    -- 显示等级
    local textComponent = LuaUtil.FindComponent(icon.transform, "Text")
    if not IsNull(textComponent) then
        textComponent.text = "EXTRA " .. tostring(level)
    end
end

-- 播放Reveal特效
function SantasGiftsFeatureView:PlayRevealEffect(icon, revealType, revealValue)
    if IsNull(icon) then
        return
    end
    
    -- 播放粒子特效
    self:PlayParticleEffect(icon.transform.position, revealType)
    
    -- 播放音效
    self:PlayRevealSound(revealType)
    
    -- 播放震屏效果（如果是大奖）
    if revealType == "credits" and revealValue >= 10 then
        self:PlayCameraShake()
    end
end

-- 播放粒子特效
function SantasGiftsFeatureView:PlayParticleEffect(position, effectType)
    -- 根据效果类型播放不同的粒子特效
    local effectPrefab = self:GetEffectPrefab(effectType)
    if not IsNull(effectPrefab) then
        local effect = CSLuaUtil.InstantiateGameObject(effectPrefab)
        effect.transform.position = position
        
        -- 自动销毁特效
        DoTween.DOScale(effect.transform, Vector3.zero, self.particleEffectDuration)
            :OnComplete(function()
                if not IsNull(effect) then
                    GameObject.Destroy(effect)
                end
            end)
    end
end

-- 获取特效预制体
function SantasGiftsFeatureView:GetEffectPrefab(effectType)
    -- 这里应该从资源管理器获取对应类型的特效预制体
    return nil
end

-- 播放Reveal音效
function SantasGiftsFeatureView:PlayRevealSound(revealType)
    -- 根据reveal类型播放不同的音效
    local soundName = "reveal_" .. revealType
    -- 这里应该调用音效管理器播放音效
    Logger.Log("Playing sound: " .. soundName)
end

-- 播放震屏效果
function SantasGiftsFeatureView:PlayCameraShake()
    -- 这里应该调用相机管理器播放震屏效果
    Logger.Log("Playing camera shake")
end

-- 完成Reveal过程
function SantasGiftsFeatureView:CompleteRevealProcess()
    self.isRevealing = false
    self:PlayRevealCompleteAnimation()
end

-- 播放Reveal完成动画
function SantasGiftsFeatureView:PlayRevealCompleteAnimation()
    -- 播放所有图标的完成动画
    for _, icon in ipairs(self.bonusIcons) do
        self:PlayIconCompleteAnimation(icon)
    end
    for _, icon in ipairs(self.extraIcons) do
        self:PlayIconCompleteAnimation(icon)
    end
    
    -- 播放整体完成特效
    self:PlayOverallCompleteEffect()
end

-- 播放单个图标完成动画
function SantasGiftsFeatureView:PlayIconCompleteAnimation(icon)
    if IsNull(icon) then
        return
    end
    
    DoTween.Sequence()
        :Append(DoTween.DOScale(icon.transform, Vector3(1.1, 1.1, 1.1), 0.2))
        :Append(DoTween.DOScale(icon.transform, Vector3(1.0, 1.0, 1.0), 0.2))
end

-- 播放整体完成特效
function SantasGiftsFeatureView:PlayOverallCompleteEffect()
    -- 播放全屏特效
    self:PlayFullScreenEffect()
    
    -- 播放完成音效
    self:PlayCompleteSound()
end

-- 播放全屏特效
function SantasGiftsFeatureView:PlayFullScreenEffect()
    -- 这里应该播放全屏特效
    Logger.Log("Playing full screen effect")
end

-- 播放完成音效
function SantasGiftsFeatureView:PlayCompleteSound()
    -- 这里应该播放完成音效
    Logger.Log("Playing complete sound")
end

-- 隐藏Feature
function SantasGiftsFeatureView:HideFeature()
    self:PlayHideAnimation()
end

-- 播放隐藏动画
function SantasGiftsFeatureView:PlayHideAnimation()
    if IsNull(self.featurePanel) then
        return
    end
    
    DoTween.DOScale(self.featurePanel.transform, Vector3.zero, 0.3)
        :SetEase(DoTween.Ease.InBack)
        :OnComplete(function()
            self:OnHideComplete()
        end)
end

-- 隐藏完成回调
function SantasGiftsFeatureView:OnHideComplete()
    self:ClearIcons()
    self:NotifyHideComplete()
end

-- 清理图标
function SantasGiftsFeatureView:ClearIcons()
    -- 清理B01图标
    for _, icon in ipairs(self.bonusIcons) do
        if not IsNull(icon) then
            DoTween.Kill(icon.transform)
            GameObject.Destroy(icon)
        end
    end
    self.bonusIcons = {}
    
    -- 清理B02图标
    for _, icon in ipairs(self.extraIcons) do
        if not IsNull(icon) then
            DoTween.Kill(icon.transform)
            GameObject.Destroy(icon)
        end
    end
    self.extraIcons = {}
end

-- 通知隐藏完成
function SantasGiftsFeatureView:NotifyHideComplete()
    -- 这里应该通知控制器隐藏完成
    Logger.Log("Santa's Gifts Feature hide complete")
end

-- 销毁
function SantasGiftsFeatureView:OnDispose()
    self:ClearIcons()
    self.featurePanel = nil
end

return SantasGiftsFeatureView
