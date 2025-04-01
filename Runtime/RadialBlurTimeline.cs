using Unity.RenderPipelines.Universal.Rendering.Runtime;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteAlways]
public class RadialBlurTimeline : MonoBehaviour
{
    public Volume targetVolume; // 引用Volume组件而不是直接引用Profile
    [Range(0,1)]public float intensity;
    public int loopCount;
    public Vector2 centerPoint;
    
    // 缓存组件引用以提高性能
    private RadialBlurVolume radialBlurVolume;
    private bool componentFound = false;
    
    private void Update()
    {
        if (targetVolume == null || targetVolume.profile == null)
            return;
            
        // 仅在第一次或Volume变化时查找组件
        if (!componentFound || radialBlurVolume == null)
        {
            // 使用TryGet方法而不是循环遍历所有组件
            componentFound = targetVolume.profile.TryGet<RadialBlurVolume>(out radialBlurVolume);
            if (!componentFound)
            {
                Debug.LogWarning("RadialBlurVolume not found in profile!");
                return;
            }
        }
        
        // 更新组件值
        radialBlurVolume.intensity.value = intensity;
        radialBlurVolume.loopCount.value = loopCount;
        radialBlurVolume.centerPoint.value = centerPoint;
    }
}