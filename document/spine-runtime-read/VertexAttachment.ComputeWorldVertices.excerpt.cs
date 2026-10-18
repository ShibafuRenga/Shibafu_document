// 摘自 EsotericSoftware/spine-runtimes 4.2 spine-csharp
// Attachments/VertexAttachment.cs — MeshAttachment 真正算世界顶点的地方
// MeshAttachment.ComputeWorldVertices 基本就是调用本方法（可先 Apply Sequence）

namespace Spine {
	public abstract class VertexAttachment /* : Attachment */ {
		internal int[] bones;      // null = 单骨（跟 slot.bone）；非 null = 多骨权重
		internal float[] vertices; // 绑定姿态局部数据（格式见下）
		internal int worldVerticesLength;

		/// <summary>
		/// local → world。若 slot.deform 非空则先叠加网格变形再变换。
		/// </summary>
		public virtual void ComputeWorldVertices(Slot slot, int start, int count, float[] worldVertices, int offset, int stride = 2) {
			count = offset + (count >> 1) * stride;
			ExposedList<float> deformArray = slot.deform;
			float[] vertices = this.vertices;
			int[] bones = this.bones;

			// ========== 路径 A：未绑定多骨 = 整块跟 slot 那一根骨（Mesh 简化 / 类似 Region）==========
			if (bones == null) {
				if (deformArray.Count > 0) vertices = deformArray.Items;
				Bone bone = slot.bone;
				float x = bone.worldX, y = bone.worldY;
				float a = bone.a, b = bone.b, c = bone.c, d = bone.d;
				for (int vv = start, w = offset; w < count; vv += 2, w += stride) {
					float vx = vertices[vv], vy = vertices[vv + 1];
					// 单骨：world = M * v_local
					worldVertices[w]     = vx * a + vy * b + x;
					worldVertices[w + 1] = vx * c + vy * d + y;
				}
				return;
			}

			// ========== 路径 B：多骨蒙皮 ==========
			// bones 编码：对每个输出顶点 → [影响骨数量 n, boneIndex0, ..., boneIndex{n-1}, ...]
			// vertices 对应：对每个影响 → [vx, vy, weight] 三元组（绑定姿态下相对该骨）
			int v = 0, skip = 0;
			for (int i = 0; i < start; i += 2) {
				int n = bones[v];
				v += n + 1;
				skip += n;
			}
			Bone[] skeletonBones = slot.bone.skeleton.bones.Items;

			if (deformArray.Count == 0) {
				for (int w = offset, b = skip * 3; w < count; w += stride) {
					float wx = 0, wy = 0;
					int n = bones[v++];
					n += v;
					for (; v < n; v++, b += 3) {
						Bone bone = skeletonBones[bones[v]];
						float vx = vertices[b], vy = vertices[b + 1], weight = vertices[b + 2];
						// 经典线性混合蒙皮：Σ w_i * (BoneWorld_i * v_i)
						wx += (vx * bone.a + vy * bone.b + bone.worldX) * weight;
						wy += (vx * bone.c + vy * bone.d + bone.worldY) * weight;
					}
					worldVertices[w] = wx;
					worldVertices[w + 1] = wy;
				}
			} else {
				// Deform 时间轴：在绑定局部坐标上先加位移，再蒙皮
				float[] deform = deformArray.Items;
				for (int w = offset, b = skip * 3, f = skip << 1; w < count; w += stride) {
					float wx = 0, wy = 0;
					int n = bones[v++];
					n += v;
					for (; v < n; v++, b += 3, f += 2) {
						Bone bone = skeletonBones[bones[v]];
						float vx = vertices[b] + deform[f], vy = vertices[b + 1] + deform[f + 1], weight = vertices[b + 2];
						wx += (vx * bone.a + vy * bone.b + bone.worldX) * weight;
						wy += (vx * bone.c + vy * bone.d + bone.worldY) * weight;
					}
					worldVertices[w] = wx;
					worldVertices[w + 1] = wy;
				}
			}
		}
	}
}
