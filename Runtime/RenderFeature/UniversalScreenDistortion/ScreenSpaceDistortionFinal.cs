using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.Universal;

namespace Unity.RenderPipelines.Universal.Rendering.Runtime
{
    internal class ScreenSpaceDistortionFinal : ScriptableRenderPass
    {
        private Material m_Material { get; set; }
        public ScreenSpaceDistortionFinal()
        {
            m_Material = CoreUtils.CreateEngineMaterial(Shader.Find("Hidden/Universal Render Pipeline/ScreenDistortion"));
        }

        // This class stores the data needed by the RenderGraph pass.
        // It is passed as a parameter to the delegate function that executes the RenderGraph pass.
        private class PassData
        {
            public ScreenDistortionData screenDistortionData;
            public Material material;
            public TextureHandle cameraColor;
            public TextureHandle ScreenDistortionTexture;
        }


        // This static method is passed as the RenderFunc delegate to the RenderGraph render pass.
        // It is used to execute draw commands.
        static void ExecutePass(PassData data, RasterGraphContext context)
        {
            if (data.material != null)
            {
                data.material.SetTexture("_ScreenDistortionTexture", data.ScreenDistortionTexture);
            }
            Blitter.BlitTexture(context.cmd, data.cameraColor, new Vector4(1, 1, 0, 0), data.material, 0);
        }

        // RecordRenderGraph is where the RenderGraph handle can be accessed, through which render passes can be added to the graph.
        // FrameData is a context container through which URP resources can be accessed and managed.
        public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
        {
            const string passName = "ScreenSpaceDistortionFinal";
            // This adds a raster render pass to the graph, specifying the name and the data type that will be passed to the ExecutePass function.
            using var builder = renderGraph.AddRasterRenderPass<PassData>(passName, out var passData, new ProfilingSampler(passName));
     
            UniversalResourceData resourceData = frameData.Get<UniversalResourceData>();
            ScreenDistortionData distortionData = frameData.Get<ScreenDistortionData>();
            passData.cameraColor = resourceData.cameraColor;
            passData.material = m_Material;
            passData.ScreenDistortionTexture = distortionData.ScreenDistortionTexture;
            
            var descriptor = renderGraph.GetTextureDesc(resourceData.cameraColor);
            var target = renderGraph.CreateTexture(descriptor);

            builder.AllowPassCulling(true);
            builder.UseTexture(passData.ScreenDistortionTexture, AccessFlags.Read);
            builder.SetRenderAttachment(target, index: 0);
            builder.SetRenderFunc<PassData>(ExecutePass);
            
            resourceData.cameraColor = target;
        }

        // NOTE: This method is part of the compatibility rendering path, please use the Render Graph API above instead.
        // This method is called before executing the render pass.
        // It can be used to configure render targets and their clear state. Also to create temporary render target textures.
        // When empty this render pass will render to the active camera render target.
        // You should never call CommandBuffer.SetRenderTarget. Instead call <c>ConfigureTarget</c> and <c>ConfigureClear</c>.
        // The render pipeline will ensure target setup and clearing happens in a performant manner.
        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
        }

        // NOTE: This method is part of the compatibility rendering path, please use the Render Graph API above instead.
        // Here you can implement the rendering logic.
        // Use <c>ScriptableRenderContext</c> to issue drawing commands or execute command buffers
        // https://docs.unity3d.com/ScriptReference/Rendering.ScriptableRenderContext.html
        // You don't have to call ScriptableRenderContext.submit, the render pipeline will call it at specific points in the pipeline.
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
        }

        // NOTE: This method is part of the compatibility rendering path, please use the Render Graph API above instead.
        // Cleanup any allocated resources that were created during the execution of this render pass.
        public override void OnCameraCleanup(CommandBuffer cmd)
        {
        }
    }
}