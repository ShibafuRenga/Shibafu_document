// 摘自 EsotericSoftware/spine-runtimes 4.2 spine-csharp
// Attachments/RegionAttachment.cs
// Region ≠「只扭边」：UpdateRegion 先算出局部 4 个角点 offset[8]，再全部乘 slot 那根骨的世界矩阵

namespace Spine {
	public class RegionAttachment /* : Attachment */ {
		// 局部四角：BL/UL/UR/BR 各 (x,y) → 共 8 float
		internal float[] offset = new float[8], uvs = new float[8];

		/// <summary>4 个局部角点 → 世界坐标（单骨，与 VertexAttachment bones==null 同构）</summary>
		public void ComputeWorldVertices(Slot slot, float[] worldVertices, int offset, int stride = 2) {
			float[] vertexOffset = this.offset;
			Bone bone = slot.Bone;
			float bwx = bone.worldX, bwy = bone.worldY;
			float a = bone.a, b = bone.b, c = bone.c, d = bone.d;
			float offsetX, offsetY;

			offsetX = vertexOffset[BRX];
			offsetY = vertexOffset[BRY];
			worldVertices[offset]     = offsetX * a + offsetY * b + bwx;
			worldVertices[offset + 1] = offsetX * c + offsetY * d + bwy;
			offset += stride;

			offsetX = vertexOffset[BLX];
			offsetY = vertexOffset[BLY];
			worldVertices[offset]     = offsetX * a + offsetY * b + bwx;
			worldVertices[offset + 1] = offsetX * c + offsetY * d + bwy;
			offset += stride;

			offsetX = vertexOffset[ULX];
			offsetY = vertexOffset[ULY];
			worldVertices[offset]     = offsetX * a + offsetY * b + bwx;
			worldVertices[offset + 1] = offsetX * c + offsetY * d + bwy;
			offset += stride;

			offsetX = vertexOffset[URX];
			offsetY = vertexOffset[URY];
			worldVertices[offset]     = offsetX * a + offsetY * b + bwx;
			worldVertices[offset + 1] = offsetX * c + offsetY * d + bwy;
		}

		public const int BLX = 0, BLY = 1, ULX = 2, ULY = 3, URX = 4, URY = 5, BRX = 6, BRY = 7;
	}
}
