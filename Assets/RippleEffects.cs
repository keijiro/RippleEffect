using UnityEngine;
using System.Collections;

public class RippleEffects : MonoBehaviour
{
    public AnimationCurve waveShape;

    [Range(0.01f, 1.0f)]
    public float refractionStrength = 0.3f;

    public Color reflectionColor;

    [Range(0.01f, 1.0f)]
    public float reflectionStrength = 0.8f;

    [Range(1.0f, 3.0f)]
    public float waveSpeed = 1.25f;


    Material tempMaterial;
    Texture2D gradTexture;

    Vector2 drop1;
    Vector2 drop2;
    Vector2 drop3;

    float time1;
    float time2;
    float time3;

    void Awake()
    {
        tempMaterial = new Material(Shader.Find("Custom/Ripple Effects"));
        tempMaterial.SetColor("_Reflection", reflectionColor);

        gradTexture = new Texture2D(2048, 1, TextureFormat.Alpha8, false);
        gradTexture.wrapMode = TextureWrapMode.Clamp;
        gradTexture.filterMode = FilterMode.Bilinear;

        for (var i = 0; i < gradTexture.width; i++)
        {
            var x = 1.0f / gradTexture.width * i;
            gradTexture.SetPixel(i, 0, new Color(0, 0, 0, waveShape.Evaluate(x)));
        }
        gradTexture.Apply();

        tempMaterial.SetTexture("_GradTex", gradTexture);
    }

    void Update()
    {
        time1 += Time.deltaTime;
        time2 += Time.deltaTime;
        time3 += Time.deltaTime;

        if (time1 > 2.0f && Random.value < 0.1f)
        {
            drop1 = new Vector2(Random.value * camera.aspect, Random.value);
            time1 = 0.0f;
        }

        if (time2 > 2.0f && Random.value < 0.1f)
        {
            drop2 = new Vector2(Random.value * camera.aspect, Random.value);
            time2 = 0.0f;
        }

        if (time3 > 2.0f && Random.value < 0.1f)
        {
            drop3 = new Vector2(Random.value * camera.aspect, Random.value);
            time3 = 0.0f;
        }

        tempMaterial.SetVector("_Drop1", new Vector4(drop1.x, drop1.y, time1, 0));
        tempMaterial.SetVector("_Drop2", new Vector4(drop2.x, drop2.y, time2, 0));
        tempMaterial.SetVector("_Drop3", new Vector4(drop3.x, drop3.y, time3, 0));

        tempMaterial.SetVector("_Params1", new Vector4(camera.aspect, 1, 1.0f / waveSpeed, 0));
        tempMaterial.SetVector("_Params2", new Vector4(1, 1.0f / camera.aspect, refractionStrength, reflectionStrength));
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, tempMaterial);
    }
}
