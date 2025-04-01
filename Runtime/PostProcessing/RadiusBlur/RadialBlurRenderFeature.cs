using Unity.RenderPipelines.Universal.Rendering.Runtime;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering.RenderGraphModule;

public class RadialBlurRenderFeature : ScriptableRendererFeature
{
    RadialBlurRenderPass m_RadialBlurRenderPass;

    /// <inheritdoc/>
    public override void Create()
    {
        m_RadialBlurRenderPass = new RadialBlurRenderPass();
        // Configures where the render pass should be injected.
        m_RadialBlurRenderPass.renderPassEvent = RenderPassEvent.AfterRenderingPostProcessing;
    }

    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(m_RadialBlurRenderPass);
    }
}

class RadialBlurRenderPass : ScriptableRenderPass
{
    RadialBlurVolume m_Volume;
    Material m_Material;

    public RadialBlurRenderPass()
    {
        var stack = VolumeManager.instance.stack;
        m_Volume = stack.GetComponent<RadialBlurVolume>();
        m_Material = CoreUtils.CreateEngineMaterial("Hidden/Universal Render Pipeline/RadialBlur");
    }

    // This class stores the data needed by the RenderGraph pass.
    // It is passed as a parameter to the delegate function that executes the RenderGraph pass.
    private class PassData
    {

        public TextureHandle cameraColor { get; set; }
        public Material material { get; set; }
        public RadialBlurVolume volume { get; set; }
        public int Intensity = Shader.PropertyToID("_Intensity");
        public int CenterPoint = Shader.PropertyToID("_CenterPoint");
        public int LoopCount = Shader.PropertyToID("_LoopCount");
    }


    // RecordRenderGraph is where the RenderGraph handle can be accessed, through which render passes can be added to the graph.
    // FrameData is a context container through which URP resources can be accessed and managed.
    public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
    {
        if (!m_Volume) return;
        if (m_Volume.intensity.value < 0.01f || !m_Volume.active) return;
        const string passName = "Draw Radial Blur Pass";

        // This adds a raster render pass to the graph, specifying the name and the data type that will be passed to the ExecutePass function.
        using (var builder = renderGraph.AddRasterRenderPass<PassData>(passName, out var passData))
        {
            UniversalResourceData resourceData = frameData.Get<UniversalResourceData>();
            passData.material = m_Material;
            passData.cameraColor = resourceData.cameraColor;
            passData.volume = m_Volume;
            var descriptor = renderGraph.GetTextureDesc(resourceData.cameraColor);
            descriptor.name = "RadialBlur";
            var target = renderGraph.CreateTexture(descriptor); // Create a temporary render target texture.

            // This sets the render target of the pass to the active color texture. Change it to your own render target as needed.
            builder.SetRenderAttachment(target, 0);

            // Assigns the ExecutePass function to the render pass delegate. This will be called by the render graph when executing the pass.
            builder.SetRenderFunc((PassData data, RasterGraphContext context) => ExecutePass(data, context));

            resourceData.cameraColor = target;
        }
    }

    // This static method is passed as the RenderFunc delegate to the RenderGraph render pass.
    // It is used to execute draw commands.
    static void ExecutePass(PassData data, RasterGraphContext context)
    {
        data.material.SetFloat(data.Intensity, data.volume.intensity.value);
        data.material.SetVector(data.CenterPoint, new Vector4(data.volume.centerPoint.value.x, data.volume.centerPoint.value.y, 0, 0));
        data.material.SetFloat(data.LoopCount, data.volume.loopCount.value);
        Blitter.BlitTexture(context.cmd, data.cameraColor, new Vector4(1, 1, 0, 0), data.material, 0);
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