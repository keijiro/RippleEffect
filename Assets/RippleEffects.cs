using UnityEngine;
using System.Collections;

public class RippleEffects : MonoBehaviour
{
    public AnimationCurve waveShape;

    Material tempMaterial;
    Texture2D gradTexture;

    Vector2 drop1;
    Vector2 drop2;

    float time1;
    float time2;

    void Awake()
    {
        tempMaterial = new Material(Shader.Find("Custom/Ripple Effects"));
        tempMaterial.SetVector("_Params", new Vector4(0.8f, 0, 0, 0));

        gradTexture = new Texture2D(1024, 1);
        gradTexture.wrapMode = TextureWrapMode.Clamp;

        for (var i = 0; i < gradTexture.width; i++)
        {
            var x = 1.0f / gradTexture.width * i;
            gradTexture.SetPixel(i, 0, Color.white * waveShape.Evaluate(x));
        }
        gradTexture.Apply();

        tempMaterial.SetTexture("_GradTex", gradTexture);
    }

    void Update()
    {
        time1 += Time.deltaTime;
        time2 += Time.deltaTime;

        if (time1 > 1.0f && Random.value < 0.1f)
        {
            drop1 = new Vector2(Random.value, Random.value);
            time1 = 0.0f;
        }

        if (time2 > 1.0f && Random.value < 0.1f)
        {
            drop2 = new Vector2(Random.value, Random.value);
            time2 = 0.0f;
        }

        tempMaterial.SetVector("_Drop1", new Vector4(drop1.x, drop1.y, time1, 0));
        tempMaterial.SetVector("_Drop2", new Vector4(drop2.x, drop2.y, time2, 0));
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, tempMaterial);
    }
}
