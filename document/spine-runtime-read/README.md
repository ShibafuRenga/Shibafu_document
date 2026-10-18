# Spine 骨骼 → 顶点（对照官方 spine-csharp 4.2）

完整仓库（本地可 git clone）：  
https://github.com/EsotericSoftware/spine-runtimes/tree/4.2/spine-csharp/src/Attachments

Unity 侧只是把下面算出来的 world vertices 填进 Mesh；**蒙皮公式在 spine-csharp，不在 spine-unity。**

## 先建立正确模型

- **骨骼**：层级变换，最终每根骨有世界矩阵（Spine 里常用 `a,b,c,d,worldX,worldY` 表示 2×3）。
- **真正画在屏幕上的永远是顶点**，不是「边」。
- **RegionAttachment**：固定 **4 个顶点** 的四边形贴图块，绑在 **slot 的那一根骨**上（`bones == null` 那条简化路径）。
- **MeshAttachment**：任意多顶点网格；继承 `VertexAttachment`，可走 **多骨权重蒙皮**。

你之前只看 Region 路径，会误以为「只扭四边形的边」——其实 Region 也是在扭 **四个角点（顶点）**；Mesh 则是更多顶点 + 可选多骨。

## 该读哪个文件

| 文件 | 看什么 |
|------|--------|
| `VertexAttachment.cs` | **核心**：`ComputeWorldVertices` 单骨 / 多骨权重 |
| `MeshAttachment.cs` | 几乎直接 `base.ComputeWorldVertices`（再加 UV/三角形/Sequence） |
| `RegionAttachment.cs` | `UpdateRegion` 算局部 4 点 `offset[]`，再单骨变到世界 |

本目录已放摘录；连不上 GitHub 时用这些也能看。

## 读代码顺序（今天）

1. `RegionAttachment.ComputeWorldVertices`：4 点 × 单骨矩阵  
2. `VertexAttachment` 里 `bones == null` 分支：和 Region 同一数学模型，只是顶点数可变  
3. `bones != null` 分支：每个顶点 `Σ weight_i * BoneWorld_i * (vx,vy)`  
4. deform 非空时：先 `vx += deform` 再蒙皮（FFD/网格变形时间轴）

## 官方链接（浏览器打开）

- https://github.com/EsotericSoftware/spine-runtimes/blob/4.2/spine-csharp/src/Attachments/VertexAttachment.cs  
- https://github.com/EsotericSoftware/spine-runtimes/blob/4.2/spine-csharp/src/Attachments/MeshAttachment.cs  
- https://github.com/EsotericSoftware/spine-runtimes/blob/4.2/spine-csharp/src/Attachments/RegionAttachment.cs  
- 用户指南（Mesh）：http://esotericsoftware.com/spine-meshes  
