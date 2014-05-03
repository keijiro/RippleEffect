Shader "Custom/Ripple Effects"
{
    Properties
    {
        _MainTex("Base", 2D) = "white" {}
        _GradTex("Gradient", 2D) = "white" {}
        _Params("Parameters", Vector) = (1, 1, 0.8, 1)
        _Reflection("Reflection Color", Color) = (0, 0, 0, 0)
        _Drop1("Drop 1", Vector) = (0.49, 0.5, 0, 0)
        _Drop2("Drop 2", Vector) = (0.50, 0.5, 0, 0)
        _Drop3("Drop 3", Vector) = (0.51, 0.5, 0, 0)
    }

    CGINCLUDE

    #include "UnityCG.cginc"

    sampler2D _MainTex;
    float2 _MainTex_TexelSize;

    sampler2D _GradTex;

    float4 _Reflection;
    float4 _Params;
    float3 _Drop1;
    float3 _Drop2;
    float3 _Drop3;

    float wave(float2 position, float2 origin, float time)
    {
        float d = length((position - origin) * _Params.xy);
        float t = time - d * _Params.z;
        return (tex2D(_GradTex, float2(t, 0)).a - 0.5f) * 2;
    }

    float allwave(float2 position)
    {
        return
            wave(position, _Drop1.xy, _Drop1.z) +
            wave(position, _Drop2.xy, _Drop2.z) +
            wave(position, _Drop3.xy, _Drop3.z);
    }

    half4 frag(v2f_img i) : SV_Target
    {
        float2 dx = float2(0.01f, 0) * _Params.x;
        float2 dy = float2(0, 0.01f);

        float wc = allwave(i.uv);
        float wdx = allwave(i.uv + dx);
        float wdy = allwave(i.uv + dy);

        float2 dd = float2(wdx - wc, wdy - wc);

        float fr = min(pow(length(dd) * 2, 5), 1);

        return lerp(tex2D(_MainTex, i.uv + dd * 0.2f * _Params.w), _Reflection, fr);
    }

    ENDCG

    SubShader
    {
        Pass
        {
            ZTest Always Cull Off ZWrite Off
            Fog { Mode off }
            CGPROGRAM
            #pragma fragmentoption ARB_precision_hint_fastest 
            #pragma target 3.0
            #pragma vertex vert_img
            #pragma fragment frag
            ENDCG
        }
    } 
}
