using UnityEngine;

[ExecuteAlways]
public class Rotator : MonoBehaviour {
    public enum RotateSpace {
        World,
        Local
    }

    public enum Axis {
        X,
        Y,
        Z
    }

    public bool enable = true;

    public RotateSpace rotateSpace = RotateSpace.Local;

    public Axis axis = Axis.Y;

    public float speed = 90f;


    void Update() {
        if (!enable) return;

        Vector3 dir = Vector3.zero;
        switch (axis) {
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