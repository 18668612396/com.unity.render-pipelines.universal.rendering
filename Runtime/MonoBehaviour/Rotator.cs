using UnityEngine;
using Sirenix.OdinInspector;
[ExecuteAlways]
public class Rotator : MonoBehaviour
{
    public enum RotateSpace { World, Local }
    public enum Axis { X, Y, Z }
    
    [LabelText("启用")]
    public bool enable = true;

    [Title("旋转设置")]
    [LabelText("旋转空间")]
    public RotateSpace rotateSpace = RotateSpace.Local;

    [LabelText("旋转轴向")]
    public Axis axis = Axis.Y;

    [LabelText("速度")]
    public float speed = 90f;


    void Update()
    {
        if (!enable) return;

        Vector3 dir = Vector3.zero;
        switch (axis)
        {
            case Axis.X: dir = Vector3.right; break;
            case Axis.Y: dir = Vector3.up; break;
            case Axis.Z: dir = Vector3.forward; break;
        }

        if (rotateSpace == RotateSpace.World)
            transform.Rotate(dir, speed * Time.deltaTime, Space.World);
        else
            transform.Rotate(dir, speed * Time.deltaTime, Space.Self);
    }
}