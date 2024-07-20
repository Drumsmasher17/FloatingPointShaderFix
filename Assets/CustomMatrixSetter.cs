using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CustomMatrixSetter : MonoBehaviour
{
    public Material mat;

    public Camera cam;
    public Transform nvg;

    void Start()
    {

    }

    void OnPreRender()
    {
        /// This example is dependent on the NVGs being a child of the camera
        /// If you want them separate then consider using a dummy transform as a direct child of the camera to use in the TRS below
        /// and then have your real-NVG just move to it's position/rotation each frame for collisions/interactions to follow
        /// This will result in lower accuracy collisions and stuff (but this was an issue anyway)

        /// If you really want to be able to calculate a NVG -> View matrix based on world transforms 
        /// then perform the matrix multiply using doubles

        /// WorldView = World * View = CameraWorld * ObjectLocal * CameraWorld.inverse = ObjectLocal         
        Matrix4x4 matrix = Matrix4x4.TRS(nvg.localPosition, nvg.localRotation, nvg.localScale);

        /// We have to do this because of the OpenGL view convention:
        /// https://docs.unity3d.com/ScriptReference/Rendering.CommandBuffer.SetViewMatrix.html
        Matrix4x4 scaleMatrix = Matrix4x4.Scale(new Vector3(1.0f, 1.0f, -1.0f));
        mat.SetMatrix("_customMatrix", scaleMatrix * matrix);

        mat.EnableKeyword("USE_CUSTOM_VIEW");
    }

    void OnPostRender()
    {
        mat.DisableKeyword("USE_CUSTOM_VIEW");
    }
}
