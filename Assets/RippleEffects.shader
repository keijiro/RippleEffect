Shader "Custom/Ripple Effects"
{
    Properties
    {
        _MainTex("Base", 2D) = "white" {}
        _GradTex("Gradient", 2D) = "white" {}
        _Params("Parameters", Vector) = (1, 1, 1, 1)
        _Drop1("Drop 1", Vector) = (0.333, 0.333, 0, 0)
        _Drop2("Drop 2", Vector) = (0.666, 0.666, 0, 0)
    }

    CGINCLUDE

    #include "UnityCG.cginc"

    sampler2D _MainTex;
    sampler2D _GradTex;
    float4 _Params;
    float3 _Drop1;
    float3 _Drop2;

    float wave(float2 position, float2 origin, float time)
    {
        float d = length(position - origin);
        float t = time - d * _Params.x;
        //return sin(t * _Params.z * 2 * 3.14159265f) * exp(-_Params.y * t);
        return tex2D(_GradTex, float2(t, 0)).r;
    }

    half4 frag(v2f_img i) : SV_Target
    {
        float2 dx = float2(0.001f, 0);
        float2 dy = float2(0, 0.001f);

        float w = wave(i.uv, _Drop1.xy, _Drop1.z) + wave(i.uv, _Drop2.xy, _Drop2.z);
        float wdx = wave(i.uv + dx, _Drop1.xy, _Drop1.z) + wave(i.uv + dx, _Drop2.xy, _Drop2.z);
        float wdy = wave(i.uv + dy, _Drop1.xy, _Drop1.z) + wave(i.uv + dy, _Drop2.xy, _Drop2.z);

        float2 dd = float2(wdx - w, wdy - w);

        float fr = pow(length(dd) * 40, 3);

        return lerp(tex2D(_MainTex, i.uv + dd), half4(0), fr);
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
