using UnityEngine;
using UnityEngine.Rendering;

namespace Unity.RenderPipelines.Universal.Rendering.Runtime
{
    [VolumeComponentMenu("Custom/Radius Blur")]
    public class RadialBlurVolume : VolumeComponent, IPostProcessComponent
    {
        // 示例参数
        public ClampedFloatParameter intensity = new ClampedFloatParameter(0f, 0f, 1f);

        public IntParameter loopCount = new IntParameter(1);

        public Vector2Parameter centerPoint = new Vector2Parameter(new Vector2(0.5f, 0.5f));

        // 实现IPostProcessComponent接口
        public bool IsActive() => intensity.value > 0;
        public bool IsTileCompatible() => false;
    }
}