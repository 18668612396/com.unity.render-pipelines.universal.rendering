using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering.RenderGraphModule;

namespace Unity.RenderPipelines.Universal.Rendering.Runtime
{
    public class ScreenDistortionData : ContextItem
    {
        public TextureHandle ScreenDistortionTexture;

        public override void Reset()
        {
            ScreenDistortionTexture = TextureHandle.nullHandle;
        }
    }
    public class ScreenSpaceDistortion : ScriptableRendererFeature
    {
        ScreenDistortionRender m_ScreenDistortionRender;
        ScreenSpaceDistortionFinal m_ScreenSpaceDistortionFinal;
        /// <inheritdoc/>
        public override void Create()
        {
            m_ScreenDistortionRender = new ScreenDistortionRender
            {
                renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing - 1,
            };

            m_ScreenSpaceDistortionFinal = new ScreenSpaceDistortionFinal
            {
                renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing,
            };
        }

        // Here you can inject one or multiple render passes in the renderer.
        // This method is called when setting up the renderer once per-camera.
        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            renderer.EnqueuePass(m_ScreenDistortionRender);
            renderer.EnqueuePass(m_ScreenSpaceDistortionFinal);
        }
    }
}