// 摘自 EsotericSoftware/spine-runtimes 4.2 spine-csharp
// Attachments/MeshAttachment.cs
// Mesh 自己几乎不算蒙皮：算世界顶点全在基类 VertexAttachment

namespace Spine {
	public class MeshAttachment : VertexAttachment {
		// regionUVs / uvs / triangles / hullLength ... 负责贴图与拓扑
		// 世界坐标：

		override public void ComputeWorldVertices(Slot slot, int start, int count, float[] worldVertices, int offset, int stride = 2) {
			if (sequence != null) sequence.Apply(slot, this); // 可选：换序列帧区域
			base.ComputeWorldVertices(slot, start, count, worldVertices, offset, stride);
			// ↑ 进 VertexAttachment：bones==null 单骨 或 bones!=null 多骨权重
		}

		Sequence sequence;
	}
}
