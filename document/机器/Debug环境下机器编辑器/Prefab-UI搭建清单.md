# TestBoard 机器编辑器 — Prefab UI 搭建清单

代码已改为**只吃序列化引用**，不再运行时拼控件。请按下面在 `TestBoardDataPanel.prefab` 上搭好并拖引用。

---

## 1. DataPanel 下：Tab + 三页

建议结构：

```
DataPanel
├── EditorTabBar                    (HorizontalLayout，置顶)
│   ├── TabBoard      Button        文案「牌面编辑」
│   ├── TabAP         Button        文案「AP设置」
│   └── TabMachineParam Button      文案「机器参数」
├── BoardPage                       (可选空节点，把原牌面相关 UI 挪进这里)
│   ├── MainPanel                   (原牌面)
│   ├── Scroll Snap Vertical...
│   ├── Scroll Snap Horizontal...
│   ├── Toggle / ToggleAlways
│   ├── ButtonServer / ButtonServerClear / Button / Button (1) ...
├── APTest                          (已有，继续当 AP 页)
└── MachineParamPage                ★新建，挂 TestBoardMachineParamPage
    └── ...见第 2 节
```

### 绑到 `TestBoardDataPanel`（根物体脚本）

| 字段 | 拖什么 |
|------|--------|
| `tabBoardButton` | TabBoard |
| `tabApButton` | TabAP |
| `tabMachineParamButton` | TabMachineParam |
| `boardPageRoots` | 牌面相关根节点数组（MainPanel、两个 Scroll、Toggle、牌面按钮…） |
| `apPageRoot` | APTest（可不拖，会回退到 `m_APTestGroup`） |
| `machineParamPage` | MachineParamPage 上的组件 |

按钮 OnClick **可不绑**（代码 `WireTabs` 会自动加）；若要手动绑：

- TabBoard → `TestBoardDataPanel.OnClickTabBoard`
- TabAP → `OnClickTabAP`
- TabMachineParam → `OnClickTabMachineParams`

---

## 2. MachineParamPage 内部

挂组件：`TestBoardMachineParamPage`

建议结构：

```
MachineParamPage
├── Toolbar
│   ├── SchemeDropdown          Dropdown
│   ├── NewSchemeNameInput      InputField（placeholder: 新方案名）
│   ├── NewSchemeButton         Button「新建方案」
│   ├── ServerUrlInput          InputField（默认可填 http://172.16.20.45:8765）
│   ├── ApplyButton             Button「应用」
│   ├── SaveButton              Button「保存本地」
│   ├── SendButton              Button「发送」
│   └── StatusText              Text
├── ParamScroll                 ScrollRect
│   └── Viewport / Mask
│       └── Content             ← VerticalLayoutGroup + ContentSizeFitter(Vertical Preferred)
└── SendingOverlay              全屏半透明 Image（默认隐藏）
    └── Text「发送中...」
```

### 绑到 `TestBoardMachineParamPage`

| 字段 | 拖什么 |
|------|--------|
| `itemRoot` | ParamScroll/…/Content |
| `paramItemPrefab` | 下面第 3 节的 Prefab |
| `schemeDropdown` | SchemeDropdown |
| `serverUrlInput` | ServerUrlInput |
| `newSchemeNameInput` | NewSchemeNameInput |
| `applyButton` / `saveButton` / `newSchemeButton` / `sendButton` / `clearSchemesButton` | 对应按钮（清除=清当前机器 PlayerPrefs 方案） |
| `statusText` | StatusText |
| `sendingOverlay` | SendingOverlay |

按钮 OnClick 也不用绑，`WireUi` 会挂。

默认 **MachineParamPage 设为 Inactive**（打开面板默认在牌面 Tab）。

---

## 3. 新建 Prefab：`MachineParamItem.prefab`

放在 `Assets/Tests/TestBoardDataPanel/`，可复制 `APTestItem` 改。

```
MachineParamItem          ← 挂 TestBoardMachineParamItem
├── Title                 Text（显示名）
└── ValueInput            InputField（数值）
```

建议高度约 48，宽撑满 Content。

### 绑到 `TestBoardMachineParamItem`

| 字段 | 拖什么 |
|------|--------|
| `title` | Title |
| `input` | ValueInput |

---

## 4. 验证

1. 编译通过，进机台打开 TestBoard  
2. 顶部应看到三个 Tab  
3. **机器参数** → 应刷出 Timing 等字段（BlazingWild100x）  
4. 改值 → 应用 / 发送  

缺引用时 Console 会有 Warning：`machineParamPage is null` 或 `itemRoot / paramItemPrefab 未绑定`。
