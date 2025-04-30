using UnityEditor;
using UnityEngine;
using UnityEngine.SceneManagement;

public class ParticleSystemCreator : Editor
{
    [MenuItem("GameObject/Effects/空粒子系统", false, 10)]
    public static void CreateEmptyParticleSystem(MenuCommand menuCommand)
    {
        //创建一个新的GameObject
        GameObject go = new GameObject("Empty Particle");
        //设置父对象,如果当前选择了一个对象,则将新对象设置为当前选择对象的子对象
        GameObjectUtility.SetParentAndAlign(go, menuCommand.context as GameObject);
        //确保新对象在层级视图中正确显示
        Undo.RegisterCreatedObjectUndo(go, "Create " + go.name);
        //添加组件
        var particle = go.AddComponent<ParticleSystem>();
        //设置粒子系统的属性
        //1:关闭ShapeModule
        DisableShapeModule(particle);
        //关闭EmissionModule
        DisableEmissionModule(particle);
        //关闭Renderer模块
        particle.GetComponent<ParticleSystemRenderer>().enabled = false;
        //设置粒子的速度为0
        SetSpeedToZero(particle);
        //设置最大粒子数量
        SetMaxParticles(particle,0);
        //设置最大粒子尺寸
        SetMaxParticleSize(particle);
        //设置粒子的缩放模式
        SetScalingMode(particle);
        //选择当前这个GameObject
        Selection.activeObject = go;
    }



    [MenuItem("GameObject/Effects/静止单粒子Mesh", false, 10)]
    public static void CreateSingleMeshParticleSystem(MenuCommand menuCommand)
    {
        //创建一个新的GameObject
        GameObject go = new GameObject("Single Mesh Particle");
        //设置父对象,如果当前选择了一个对象,则将新对象设置为当前选择对象的子对象
        GameObjectUtility.SetParentAndAlign(go, menuCommand.context as GameObject);
        //确保新对象在层级视图中正确显示
        Undo.RegisterCreatedObjectUndo(go, "Create " + go.name);
        //添加组件
        var particle = go.AddComponent<ParticleSystem>();
        //设置粒子系统的属性
        //1:关闭ShapeModule
        DisableShapeModule(particle);
        //设置粒子为单次发射一个
        SetSinglePointEmission(particle);
        //设置粒子的速度为0
        SetSpeedToZero(particle);
        //设置粒子的渲染模式为Mesh
        SerRendererMeshFromSphere(particle);
        //设置粒子的材质
        SetRendererMaterial(particle);
        //设置最大粒子数量
        SetMaxParticles(particle,1);
        //设置最大粒子尺寸
        SetMaxParticleSize(particle);
        //设置粒子的缩放模式
        SetScalingMode(particle);
        //设置粒子的循环模式
        DisableLooping(particle);
        //选择当前这个GameObject
        Selection.activeObject = go;
    }
    [MenuItem("GameObject/Effects/静止单粒子Billboard", false, 10)]
    public static void CreateSingleBillboardParticleSystem(MenuCommand menuCommand)
    {
        //创建一个新的GameObject
        GameObject go = new GameObject("Single Billboard Particle");
        //设置父对象,如果当前选择了一个对象,则将新对象设置为当前选择对象的子对象
        GameObjectUtility.SetParentAndAlign(go, menuCommand.context as GameObject);
        //确保新对象在层级视图中正确显示
        Undo.RegisterCreatedObjectUndo(go, "Create " + go.name);
        //添加组件
        var particle = go.AddComponent<ParticleSystem>();
        //设置粒子系统的属性
        //1:关闭ShapeModule
        DisableShapeModule(particle);
        //设置粒子为单次发射一个
        SetSinglePointEmission(particle);
        //设置粒子的速度为0
        SetSpeedToZero(particle);
        //设置粒子的材质
        SetRendererMaterial(particle);
        //设置最大粒子数量
        SetMaxParticles(particle,1);
        //设置最大粒子尺寸
        SetMaxParticleSize(particle);
        //设置粒子的缩放模式
        SetScalingMode(particle);
        //设置粒子的循环模式
        DisableLooping(particle);
        //选择当前这个GameObject
        Selection.activeObject = go;
    }
    [MenuItem("GameObject/Effects/一次性发射器Billboard", false, 10)]
    public static void CreateSingleBillboardEmitter(MenuCommand menuCommand)
    {
        //创建一个新的GameObject
        GameObject go = new GameObject("Single Billboard Emitter");
        //设置父对象,如果当前选择了一个对象,则将新对象设置为当前选择对象的子对象
        GameObjectUtility.SetParentAndAlign(go, menuCommand.context as GameObject);
        //确保新对象在层级视图中正确显示
        Undo.RegisterCreatedObjectUndo(go, "Create " + go.name);
        //添加组件
        var particle = go.AddComponent<ParticleSystem>();
        //设置一些额外参数
        var main = particle.main;
        //设置start lifttime为在两个值之间随机
        main.startLifetime = new ParticleSystem.MinMaxCurve(0.5f, 1.5f);
        main.startSpeed = new ParticleSystem.MinMaxCurve(0.5f, 1.5f);
        main.startSize = new ParticleSystem.MinMaxCurve(0.5f, 1.5f);
        main.startColor = new ParticleSystem.MinMaxGradient(Color.white, Color.red);
        //设置粒子系统的属性
        //1:关闭ShapeModule
        //设置粒子为单次发射一个
        SetSinglePointEmission(particle,30);
        //设置粒子的材质
        SetRendererMaterial(particle);
        //设置最大粒子数量
        SetMaxParticles(particle,30);
        //设置最大粒子尺寸
        SetMaxParticleSize(particle);
        //设置粒子的缩放模式
        SetScalingMode(particle);
        //设置粒子的循环模式
        DisableLooping(particle);
        //选择当前这个GameObject
        Selection.activeObject = go;
    }
    

    static void DisableLooping(ParticleSystem particle)
    {
        var main = particle.main;
        main.loop = false;
    }
    private static void DisableEmissionModule(ParticleSystem particle)
    {
        var emission = particle.emission;
        emission.enabled = false;
    }
    static void SetScalingMode(ParticleSystem particle)
    {
        var main = particle.main;
        main.scalingMode = ParticleSystemScalingMode.Hierarchy;
    }

    static void SetMaxParticles(ParticleSystem particle, int i)
    {
        var main = particle.main;
        main.maxParticles = i;
    }

    static void SetMaxParticleSize(ParticleSystem particle)
    {
        var renderer = particle.GetComponent<ParticleSystemRenderer>();
        renderer.maxParticleSize = 10;
    }

    static void DisableShapeModule(ParticleSystem particle)
    {
        var shape = particle.shape;
        shape.shapeType = ParticleSystemShapeType.Circle;
        shape.radius = 0.001f;
        shape.enabled = false;
    }

    static void SetSinglePointEmission(ParticleSystem particle,int count = 1)
    {
        var emission = particle.emission;
        emission.rateOverTime = 0;
        //设置粒子的发射模式为Burst
        emission.burstCount = 1;
        emission.SetBurst(0, new ParticleSystem.Burst(0, count));
    }

    static void SetSpeedToZero(ParticleSystem particle)
    {
        var main = particle.main;
        main.startSpeed = 0;
    }

    private static void SerRendererMeshFromSphere(ParticleSystem particle)
    {
        var renderer = particle.GetComponent<ParticleSystemRenderer>();
        renderer.renderMode = ParticleSystemRenderMode.Mesh;
        renderer.mesh = Resources.GetBuiltinResource<Mesh>("New-Sphere.fbx");
        renderer.alignment = ParticleSystemRenderSpace.Local;
    }

    private static void SetRendererMaterial(ParticleSystem particle)
    {
        var renderer = particle.GetComponent<ParticleSystemRenderer>();
        renderer.material = AssetDatabase.GetBuiltinExtraResource<Material>("Default-Particle.mat");
    }
}