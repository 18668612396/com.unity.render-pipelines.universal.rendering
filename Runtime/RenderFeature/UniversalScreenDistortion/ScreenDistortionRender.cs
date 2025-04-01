using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.Universal;

namespace Unity.RenderPipelines.Universal.Rendering.Runtime
{
    internal class ScreenDistortionRender : ScriptableRenderPass
    {
        private static readonly ProfilingSampler m_ProfilingSampler = new("Draw Screen Distortion Pass");

        static readonly int s_ScreenDistortionTextureID = Shader.PropertyToID("_ScreenDistortionTexture");

        private static readonly ShaderTagId s_ScreenDistortionShaderTagId = new("UniversalScreenDistortion");


        // This class stores the data needed by the RenderGraph pass.
        // It is passed as a parameter to the delegate function that executes the RenderGraph pass.
        private class PassData
        {
            public UniversalRenderingData renderingData;
            public UniversalCameraData cameraData;
            public UniversalResourceData resourceData;
            public UniversalLightData lightData;
            public TextureHandle screenDistortionTexture;
            public RendererListHandle renderListHandle { get; set; }
        }


        // This static method is passed as the RenderFunc delegate to the RenderGraph render pass.
        // It is used to execute draw commands.
        static void ExecutePass(PassData data, RasterGraphContext context)
        {
            context.cmd.ClearRenderTarget(true, true, Color.gray);
            context.cmd.DrawRendererList(data.renderListHandle);
        }

        // RecordRenderGraph is where the RenderGraph handle can be accessed, through which render passes can be added to the graph.
        // FrameData is a context container through which URP resources can be accessed and managed.
        public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
        {
            const string passName = "Render Screen Distortion RenderObjects";
            ScreenDistortionData screenDistortionData = frameData.GetOrCreate<ScreenDistortionData>();
            var resourceData = frameData.Get<UniversalResourceData>();
            var targetDesc = renderGraph.GetTextureDesc(resourceData.cameraColor);
            targetDesc.name = "_ScreenDistortionTexture";
            targetDesc.format = GraphicsFormat.R8G8_UNorm;
            screenDistortionData.ScreenDistortionTexture = renderGraph.CreateTexture(targetDesc);
            // This adds a raster render pass to the graph, specifying the name and the data type that will be passed to the ExecutePass function.
            using (var builder = renderGraph.AddRasterRenderPass<PassData>(passName, out var passData))
            {
                builder.AllowPassCulling(true);
                // builder.AllowGlobalStateModification(true);
                passData.renderingData = frameData.Get<UniversalRenderingData>();
                passData.cameraData = frameData.Get<UniversalCameraData>();
                passData.resourceData = frameData.Get<UniversalResourceData>();
                passData.lightData = frameData.Get<UniversalLightData>();

                passData.screenDistortionTexture = screenDistortionData.ScreenDistortionTexture;
                // This sets the render target of the pass to the active color texture. Change it to your own render target as needed.
                builder.SetRenderAttachment( passData.screenDistortionTexture, 0);
                DrawingSettings drawingSettings = CreateDrawingSettings(s_ScreenDistortionShaderTagId, passData.renderingData, passData.cameraData, passData.lightData, passData.cameraData.defaultOpaqueSortFlags);
                FilteringSettings filterSettings = new FilteringSettings(RenderQueueRange.all);
                RendererListParams param = new RendererListParams(passData.renderingData.cullResults, drawingSettings, filterSettings);

                RendererListHandle rendererList = renderGraph.CreateRendererList(param);
                builder.UseRendererList(rendererList);
                passData.renderListHandle = rendererList;
                // builder.SetGlobalTextureAfterPass(screenDistortionData.ScreenDistortionTexture, s_ScreenDistortionTextureID);
                // Assigns the ExecutePass function to the render pass delegate. This will be called by the render graph when executing the pass.
                builder.SetRenderFunc((PassData data, RasterGraphContext context) => ExecutePass(data, context));
            }
        }

        // NOTE: This method is part of the compatibility rendering path, please use the Render Graph API above instead.
        // Cleanup any allocated resources that were created during the execution of this render pass.
        public override void OnCameraCleanup(CommandBuffer cmd)
        {
        }
    }
}